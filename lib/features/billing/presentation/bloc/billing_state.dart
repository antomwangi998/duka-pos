part of 'billing_bloc.dart';

class BillingState extends Equatable {
  final List<CartItem> cartItems;
  final String? error;
  final bool isPrinting;
  final bool printSuccess;
  final bool checkoutSuccess;
  final double vatRate;

  const BillingState({
    this.cartItems = const [],
    this.error,
    this.isPrinting = false,
    this.printSuccess = false,
    this.checkoutSuccess = false,
    this.vatRate = 0.16,
  });

  double get subtotal => cartItems.fold(0, (sum, item) => sum + item.total);
  // VAT is included in price (VAT-inclusive pricing, common in Kenya)
  // VAT amount = subtotal * vatRate / (1 + vatRate)
  double get vatAmount => subtotal * vatRate / (1 + vatRate);
  double get totalAmount => subtotal; // total already includes VAT

  BillingState copyWith({
    List<CartItem>? cartItems,
    String? error,
    bool clearError = false,
    bool? isPrinting,
    bool? printSuccess,
    bool? checkoutSuccess,
    double? vatRate,
  }) {
    return BillingState(
      cartItems: cartItems ?? this.cartItems,
      error: clearError ? null : (error ?? this.error),
      isPrinting: isPrinting ?? this.isPrinting,
      printSuccess: printSuccess ?? this.printSuccess,
      checkoutSuccess: checkoutSuccess ?? this.checkoutSuccess,
      vatRate: vatRate ?? this.vatRate,
    );
  }

  @override
  List<Object?> get props =>
      [cartItems, error, isPrinting, printSuccess, checkoutSuccess, vatRate];
}
