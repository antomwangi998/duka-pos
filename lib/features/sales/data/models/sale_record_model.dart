import 'package:hive/hive.dart';

part 'sale_record_model.g.dart';

@HiveType(typeId: 2)
class SaleItemModel extends HiveObject {
  @HiveField(0)
  final String productId;
  @HiveField(1)
  final String productName;
  @HiveField(2)
  final int quantity;
  @HiveField(3)
  final double unitPrice;
  @HiveField(4)
  final double total;

  SaleItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });
}

@HiveType(typeId: 3)
class SaleRecordModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final DateTime date;
  @HiveField(2)
  final List<SaleItemModel> items;
  @HiveField(3)
  final double subtotal;
  @HiveField(4)
  final double vatAmount;
  @HiveField(5)
  final double total;
  @HiveField(6)
  final String paymentMethod; // 'cash' | 'mpesa' | 'credit'
  @HiveField(7)
  final String? mpesaRef;
  @HiveField(8)
  final String? customerId; // set when paymentMethod == 'credit'
  @HiveField(9)
  final String? customerName;

  SaleRecordModel({
    required this.id,
    required this.date,
    required this.items,
    required this.subtotal,
    required this.vatAmount,
    required this.total,
    required this.paymentMethod,
    this.mpesaRef,
    this.customerId,
    this.customerName,
  });
}
