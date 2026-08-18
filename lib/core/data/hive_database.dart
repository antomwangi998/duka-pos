import 'package:hive_flutter/hive_flutter.dart';
import '../../features/product/data/models/product_model.dart';
import '../../features/shop/data/models/shop_model.dart';
import '../../features/sales/data/models/sale_record_model.dart';
import '../../features/customer/data/models/customer_model.dart';
import '../../features/customer/data/models/debt_transaction_model.dart';
import '../../features/expense/data/models/expense_model.dart';

class HiveDatabase {
  static const String productBoxName = 'products';
  static const String shopBoxName = 'shop';
  static const String settingsBoxName = 'settings';
  static const String salesBoxName = 'sales';
  static const String customersBoxName = 'customers';
  static const String debtTransactionsBoxName = 'debt_transactions';
  static const String expenseBoxName = 'expenses';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(ProductModelAdapter());
    Hive.registerAdapter(ShopModelAdapter());
    Hive.registerAdapter(SaleItemModelAdapter());
    Hive.registerAdapter(SaleRecordModelAdapter());
    Hive.registerAdapter(CustomerModelAdapter());
    Hive.registerAdapter(DebtTransactionModelAdapter());
    Hive.registerAdapter(ExpenseModelAdapter());

    // Open Boxes
    await Hive.openBox<ProductModel>(productBoxName);
    await Hive.openBox<ShopModel>(shopBoxName);
    await Hive.openBox(settingsBoxName);
    await Hive.openBox<SaleRecordModel>(salesBoxName);
    await Hive.openBox<CustomerModel>(customersBoxName);
    await Hive.openBox<DebtTransactionModel>(debtTransactionsBoxName);
    await Hive.openBox<ExpenseModel>(expenseBoxName);
  }

  static Box<ProductModel> get productBox =>
      Hive.box<ProductModel>(productBoxName);
  static Box<ShopModel> get shopBox => Hive.box<ShopModel>(shopBoxName);
  static Box get settingsBox => Hive.box(settingsBoxName);
  static Box<SaleRecordModel> get salesBox =>
      Hive.box<SaleRecordModel>(salesBoxName);
  static Box<CustomerModel> get customersBox =>
      Hive.box<CustomerModel>(customersBoxName);
  static Box<DebtTransactionModel> get debtTransactionsBox =>
      Hive.box<DebtTransactionModel>(debtTransactionsBoxName);
  static Box<ExpenseModel> get expenseBox =>
      Hive.box<ExpenseModel>(expenseBoxName);
}
