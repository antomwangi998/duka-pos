import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/cart_item.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/domain/usecases/product_usecases.dart';
import '../../../product/data/models/product_model.dart';
import '../../../../core/utils/printer_helper.dart';
import '../../../../core/data/hive_database.dart';
import '../../../sales/data/models/sale_record_model.dart';
import '../../../sales/data/repositories/sale_repository_impl.dart';

part 'billing_event.dart';
part 'billing_state.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final GetProductByBarcodeUseCase getProductByBarcodeUseCase;
  final GetProductsUseCase getProductsUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final SaleRepositoryImpl saleRepository;

  BillingBloc({
    required this.getProductByBarcodeUseCase,
    required this.getProductsUseCase,
    required this.updateProductUseCase,
    required this.saleRepository,
  }) : super(const BillingState()) {
    on<ScanBarcodeEvent>(_onScanBarcode);
    on<AddProductToCartEvent>(_onAddProductToCart);
    on<RemoveProductFromCartEvent>(_onRemoveProductFromCart);
    on<UpdateQuantityEvent>(_onUpdateQuantity);
    on<ClearCartEvent>(_onClearCart);
    on<CheckoutEvent>(_onCheckout);
    on<PrintReceiptEvent>(_onPrintReceipt);
  }

  Future<void> _onScanBarcode(
      ScanBarcodeEvent event, Emitter<BillingState> emit) async {
    final result = await getProductByBarcodeUseCase(event.barcode);
    result.fold(
      (failure) =>
          emit(state.copyWith(error: 'Product not found: ${event.barcode}')),
      (product) {
        add(AddProductToCartEvent(product));
      },
    );
  }

  void _onAddProductToCart(
      AddProductToCartEvent event, Emitter<BillingState> emit) {
    final cleanState = state.copyWith(error: null);
    final existingIndex = cleanState.cartItems
        .indexWhere((item) => item.product.id == event.product.id);
    if (existingIndex >= 0) {
      final existingItem = cleanState.cartItems[existingIndex];
      final updatedItems = List<CartItem>.from(cleanState.cartItems);
      updatedItems[existingIndex] =
          existingItem.copyWith(quantity: existingItem.quantity + 1);
      emit(cleanState.copyWith(cartItems: updatedItems, error: null));
    } else {
      final newItem = CartItem(product: event.product);
      emit(cleanState.copyWith(
          cartItems: [...cleanState.cartItems, newItem], error: null));
    }
  }

  void _onRemoveProductFromCart(
      RemoveProductFromCartEvent event, Emitter<BillingState> emit) {
    final updatedList = state.cartItems
        .where((item) => item.product.id != event.productId)
        .toList();
    emit(state.copyWith(cartItems: updatedList));
  }

  void _onUpdateQuantity(
      UpdateQuantityEvent event, Emitter<BillingState> emit) {
    if (event.quantity <= 0) {
      add(RemoveProductFromCartEvent(event.productId));
      return;
    }
    final index = state.cartItems
        .indexWhere((item) => item.product.id == event.productId);
    if (index >= 0) {
      final items = List<CartItem>.from(state.cartItems);
      items[index] = items[index].copyWith(quantity: event.quantity);
      emit(state.copyWith(cartItems: items));
    }
  }

  void _onClearCart(ClearCartEvent event, Emitter<BillingState> emit) {
    emit(const BillingState());
  }

  Future<void> _onCheckout(
      CheckoutEvent event, Emitter<BillingState> emit) async {
    emit(state.copyWith(isPrinting: true, clearError: true));

    try {
      // 1. Deduct stock for each cart item
      final box = HiveDatabase.productBox;
      for (final cartItem in state.cartItems) {
        // Hive boxes with integer keys: iterate entries to find matching product
        for (final entry in box.toMap().entries) {
          final productModel = entry.value;
          if (productModel.id == cartItem.product.id) {
            final newStock =
                (productModel.stock - cartItem.quantity).clamp(0, 99999);
            final updated = ProductModel(
              id: productModel.id,
              name: productModel.name,
              barcode: productModel.barcode,
              price: productModel.price,
              stock: newStock,
            );
            await box.put(entry.key, updated);
            break;
          }
        }
      }

      // 2. Persist sale record
      final saleItems = state.cartItems
          .map((item) => SaleItemModel(
                productId: item.product.id,
                productName: item.product.name,
                quantity: item.quantity,
                unitPrice: item.product.price,
                total: item.total,
              ))
          .toList();

      final sale = SaleRecordModel(
        id: const Uuid().v4(),
        date: DateTime.now(),
        items: saleItems,
        subtotal: state.subtotal,
        vatAmount: state.vatAmount,
        total: state.totalAmount,
        paymentMethod: event.paymentMethod,
        mpesaRef: event.mpesaRef,
      );
      await saleRepository.saveSale(sale);

      // 3. Print receipt if requested
      if (event.printReceipt) {
        final printerHelper = PrinterHelper();
        if (!printerHelper.isConnected) {
          final savedMac = HiveDatabase.settingsBox.get('printer_mac');
          if (savedMac != null) {
            await printerHelper.connect(savedMac);
          }
        }
        if (printerHelper.isConnected) {
          final items = state.cartItems
              .map((item) => {
                    'name': item.product.name,
                    'qty': item.quantity,
                    'price': item.product.price,
                    'total': item.total,
                  })
              .toList();
          await printerHelper.printReceiptKenya(
            shopName: event.shopName,
            address1: event.address1,
            address2: event.address2,
            phone: event.phone,
            kraPin: event.kraPin,
            items: items,
            subtotal: state.subtotal,
            vatAmount: state.vatAmount,
            vatRate: event.vatRate,
            total: state.totalAmount,
            paymentMethod: event.paymentMethod,
            mpesaRef: event.mpesaRef,
            footer: event.footer,
          );
        }
      }

      emit(state.copyWith(
          isPrinting: false, checkoutSuccess: true, printSuccess: true));
    } catch (e) {
      emit(state.copyWith(
          isPrinting: false, error: 'Checkout failed: $e', clearError: false));
      emit(state.copyWith(clearError: true));
    }
  }

  Future<void> _onPrintReceipt(
      PrintReceiptEvent event, Emitter<BillingState> emit) async {
    final printerHelper = PrinterHelper();
    if (!printerHelper.isConnected) {
      final savedMac = HiveDatabase.settingsBox.get('printer_mac');
      if (savedMac != null) {
        final connected = await printerHelper.connect(savedMac);
        if (!connected) {
          emit(state.copyWith(
              error: 'Failed to auto-connect to printer!', clearError: false));
          emit(state.copyWith(clearError: true));
          return;
        }
      } else {
        emit(state.copyWith(
            error: 'Printer not connected & no saved printer found!',
            clearError: false));
        emit(state.copyWith(clearError: true));
        return;
      }
    }

    emit(state.copyWith(isPrinting: true, printSuccess: false, clearError: true));

    try {
      final items = state.cartItems
          .map((item) => {
                'name': item.product.name,
                'qty': item.quantity,
                'price': item.product.price,
                'total': item.total,
              })
          .toList();

      await printerHelper.printReceipt(
          shopName: event.shopName,
          address1: event.address1,
          address2: event.address2,
          phone: event.phone,
          items: items,
          total: state.totalAmount,
          footer: event.footer);

      emit(state.copyWith(isPrinting: false, printSuccess: true));
    } catch (e) {
      emit(state.copyWith(
          isPrinting: false, error: 'Print failed: $e', clearError: false));
      emit(state.copyWith(clearError: true));
    }
  }
}
