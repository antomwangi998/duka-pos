import 'package:fpdart/fpdart.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  @override
  Future<Either<Failure, List<Expense>>> getExpenses() async {
    try {
      final box = HiveDatabase.expenseBox;
      final expenses = box.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return Right(expenses);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getExpensesInRange(
      DateTime start, DateTime end) async {
    try {
      final box = HiveDatabase.expenseBox;
      final expenses = box.values
          .where((e) =>
              !e.date.isBefore(start) &&
              e.date.isBefore(end.add(const Duration(days: 1))))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return Right(expenses);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addExpense(Expense expense) async {
    try {
      final box = HiveDatabase.expenseBox;
      final model = ExpenseModel.fromEntity(expense);
      await box.put(model.id, model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String id) async {
    try {
      final box = HiveDatabase.expenseBox;
      await box.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
