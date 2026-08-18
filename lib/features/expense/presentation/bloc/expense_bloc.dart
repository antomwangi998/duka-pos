import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/expense.dart';
import '../../domain/usecases/expense_usecases.dart';
import '../../../../core/usecase/usecase.dart';

part 'expense_event.dart';
part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final GetExpensesUseCase getExpensesUseCase;
  final AddExpenseUseCase addExpenseUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;

  ExpenseBloc({
    required this.getExpensesUseCase,
    required this.addExpenseUseCase,
    required this.deleteExpenseUseCase,
  }) : super(const ExpenseState()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpense>(_onAddExpense);
    on<DeleteExpense>(_onDeleteExpense);
  }

  Future<void> _onLoadExpenses(
      LoadExpenses event, Emitter<ExpenseState> emit) async {
    emit(state.copyWith(status: ExpenseStatus.loading));
    final result = await getExpensesUseCase(NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
          status: ExpenseStatus.error, message: failure.message)),
      (expenses) => emit(
          state.copyWith(status: ExpenseStatus.loaded, expenses: expenses)),
    );
  }

  Future<void> _onAddExpense(
      AddExpense event, Emitter<ExpenseState> emit) async {
    emit(state.copyWith(status: ExpenseStatus.loading));
    final result = await addExpenseUseCase(event.expense);
    result.fold(
      (failure) => emit(state.copyWith(
          status: ExpenseStatus.error, message: failure.message)),
      (_) {
        emit(state.copyWith(
            status: ExpenseStatus.success,
            message: 'Expense recorded'));
        add(LoadExpenses());
      },
    );
  }

  Future<void> _onDeleteExpense(
      DeleteExpense event, Emitter<ExpenseState> emit) async {
    emit(state.copyWith(status: ExpenseStatus.loading));
    final result = await deleteExpenseUseCase(event.id);
    result.fold(
      (failure) => emit(state.copyWith(
          status: ExpenseStatus.error, message: failure.message)),
      (_) {
        emit(state.copyWith(
            status: ExpenseStatus.success,
            message: 'Expense deleted'));
        add(LoadExpenses());
      },
    );
  }
}
