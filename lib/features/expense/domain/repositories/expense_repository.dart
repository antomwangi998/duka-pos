import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, List<Expense>>> getExpenses();
  Future<Either<Failure, List<Expense>>> getExpensesInRange(
      DateTime start, DateTime end);
  Future<Either<Failure, void>> addExpense(Expense expense);
  Future<Either<Failure, void>> deleteExpense(String id);
}
