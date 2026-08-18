import 'package:hive/hive.dart';
import '../../domain/entities/debt_transaction.dart';

part 'debt_transaction_model.g.dart';

@HiveType(typeId: 5)
class DebtTransactionModel extends DebtTransaction {
  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String customerId;
  @HiveField(2)
  final int typeIndex;
  @override
  @HiveField(3)
  final double amount;
  @override
  @HiveField(4)
  final String note;
  @override
  @HiveField(5)
  final DateTime date;
  @override
  @HiveField(6)
  final String? saleId;

  const DebtTransactionModel({
    required this.id,
    required this.customerId,
    required this.typeIndex,
    required this.amount,
    required this.note,
    required this.date,
    this.saleId,
  }) : super(
          id: id,
          customerId: customerId,
          type: typeIndex == 0
              ? DebtTransactionType.credit
              : DebtTransactionType.payment,
          amount: amount,
          note: note,
          date: date,
          saleId: saleId,
        );

  factory DebtTransactionModel.fromEntity(DebtTransaction transaction) {
    return DebtTransactionModel(
      id: transaction.id,
      customerId: transaction.customerId,
      typeIndex: transaction.type.index,
      amount: transaction.amount,
      note: transaction.note,
      date: transaction.date,
      saleId: transaction.saleId,
    );
  }

  DebtTransaction toEntity() {
    return DebtTransaction(
      id: id,
      customerId: customerId,
      type: type,
      amount: amount,
      note: note,
      date: date,
      saleId: saleId,
    );
  }
}
