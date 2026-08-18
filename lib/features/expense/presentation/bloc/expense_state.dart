part of 'expense_bloc.dart';

enum ExpenseStatus { initial, loading, loaded, error, success }

class ExpenseState extends Equatable {
  final ExpenseStatus status;
  final List<Expense> expenses;
  final String? message;

  const ExpenseState({
    this.status = ExpenseStatus.initial,
    this.expenses = const [],
    this.message,
  });

  double get total => expenses.fold(0.0, (sum, e) => sum + e.amount);

  Map<String, double> get totalsByCategory {
    final map = <String, double>{};
    for (final e in expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  ExpenseState copyWith({
    ExpenseStatus? status,
    List<Expense>? expenses,
    String? message,
  }) {
    return ExpenseState(
      status: status ?? this.status,
      expenses: expenses ?? this.expenses,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, expenses, message];
}
