import 'package:hive/hive.dart';
import '../../domain/entities/customer.dart';

part 'customer_model.g.dart';

@HiveType(typeId: 4)
class CustomerModel extends Customer {
  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String name;
  @override
  @HiveField(2)
  final String phone;
  @override
  @HiveField(3)
  final String notes;
  @override
  @HiveField(4)
  final double balance;
  @override
  @HiveField(5)
  final DateTime createdAt;

  const CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.notes,
    required this.balance,
    required this.createdAt,
  }) : super(
          id: id,
          name: name,
          phone: phone,
          notes: notes,
          balance: balance,
          createdAt: createdAt,
        );

  factory CustomerModel.fromEntity(Customer customer) {
    return CustomerModel(
      id: customer.id,
      name: customer.name,
      phone: customer.phone,
      notes: customer.notes,
      balance: customer.balance,
      createdAt: customer.createdAt,
    );
  }

  Customer toEntity() {
    return Customer(
      id: id,
      name: name,
      phone: phone,
      notes: notes,
      balance: balance,
      createdAt: createdAt,
    );
  }
}
