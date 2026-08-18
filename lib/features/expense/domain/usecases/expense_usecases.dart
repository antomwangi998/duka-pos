import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class GetExpensesUseCase implements UseCase<List<Expense>, NoParams> {
  final ExpenseRepository repository;

  GetExpensesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Expense>>> call(NoParams params) {
    return repository.getExpenses();
  }
}

class GetExpensesInRangeParams {
  final DateTime start;
  final DateTime end;

  GetExpensesInRangeParams({required this.start, required this.end});
}

class GetExpensesInRangeUseCase
    implements UseCase<List<Expense>, GetExpensesInRangeParams> {
  final ExpenseRepository repository;

  GetExpensesInRangeUseCase(this.repository);

  @override
  Future<Either<Failure, List<Expense>>> call(
      GetExpensesInRangeParams params) {
    return repository.getExpensesInRange(params.start, params.end);
  }
}

class AddExpenseUseCase implements UseCase<void, Expense> {
  final ExpenseRepository repository;

  AddExpenseUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(Expense params) {
    return repository.addExpense(params);
  }
}

class DeleteExpenseUseCase implements UseCase<void, String> {
  final ExpenseRepository repository;

  DeleteExpenseUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) {
    return repository.deleteExpense(params);
  }
}
