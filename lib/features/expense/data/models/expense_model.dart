import 'package:hive/hive.dart';
import '../../domain/entities/expense.dart';

part 'expense_model.g.dart';

// NOTE: typeId 10 is used to avoid collision with existing models
// (Product=0, Shop=1, SaleItem=2, SaleRecord=3). If your on-device
// customer/deni module already registered typeId 10, bump this to
// the next free number and update hive_database.dart to match.
@HiveType(typeId: 10)
class ExpenseModel extends Expense {
  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String title;
  @override
  @HiveField(2)
  final double amount;
  @override
  @HiveField(3)
  final String category;
  @override
  @HiveField(4)
  final DateTime date;
  @override
  @HiveField(5)
  final String? note;

  const ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
  }) : super(
          id: id,
          title: title,
          amount: amount,
          category: category,
          date: date,
          note: note,
        );

  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      title: expense.title,
      amount: expense.amount,
      category: expense.category,
      date: expense.date,
      note: expense.note,
    );
  }

  Expense toEntity() {
    return Expense(
      id: id,
      title: title,
      amount: amount,
      category: category,
      date: date,
      note: note,
    );
  }
}
