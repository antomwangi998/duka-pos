import 'package:equatable/equatable.dart';

/// A single ledger entry against a customer's deni (credit) account.
///
/// [credit]  - a sale made on credit; increases the customer's balance owed.
/// [payment] - money the customer has paid back; decreases the balance owed.
enum DebtTransactionType { credit, payment }

class DebtTransaction extends Equatable {
  final String id;
  final String customerId;
  final DebtTransactionType type;
  final double amount;
  final String note;
  final DateTime date;
  final String? saleId; // links back to the originating sale, if any

  const DebtTransaction({
    required this.id,
    required this.customerId,
    required this.type,
    required this.amount,
    this.note = '',
    required this.date,
    this.saleId,
  });

  @override
  List<Object?> get props =>
      [id, customerId, type, amount, note, date, saleId];
}
