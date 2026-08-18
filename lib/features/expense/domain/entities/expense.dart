import 'package:equatable/equatable.dart';

/// Common expense categories for a small Kenyan shop.
/// Kept as plain strings (not an enum) so new categories can be
/// added later without a data migration.
class ExpenseCategories {
  static const String stock = 'Stock/Restocking';
  static const String rent = 'Rent';
  static const String utilities = 'Utilities';
  static const String salaries = 'Salaries/Wages';
  static const String transport = 'Transport';
  static const String other = 'Other';

  static const List<String> all = [
    stock,
    rent,
    utilities,
    salaries,
    transport,
    other,
  ];
}

class Expense extends Equatable {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? note;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
  });

  @override
  List<Object?> get props => [id, title, amount, category, date, note];
}
