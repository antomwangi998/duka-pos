import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/customer.dart';
import '../entities/debt_transaction.dart';
import '../repositories/customer_repository.dart';

class GetCustomersUseCase implements UseCase<List<Customer>, NoParams> {
  final CustomerRepository repository;
  GetCustomersUseCase(this.repository);

  @override
  Future<Either<Failure, List<Customer>>> call(NoParams params) {
    return repository.getCustomers();
  }
}

class AddCustomerUseCase implements UseCase<void, Customer> {
  final CustomerRepository repository;
  AddCustomerUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(Customer params) {
    return repository.addCustomer(params);
  }
}

class UpdateCustomerUseCase implements UseCase<void, Customer> {
  final CustomerRepository repository;
  UpdateCustomerUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(Customer params) {
    return repository.updateCustomer(params);
  }
}

class DeleteCustomerUseCase implements UseCase<void, String> {
  final CustomerRepository repository;
  DeleteCustomerUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) {
    return repository.deleteCustomer(params);
  }
}

class GetCustomerTransactionsUseCase
    implements UseCase<List<DebtTransaction>, String> {
  final CustomerRepository repository;
  GetCustomerTransactionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<DebtTransaction>>> call(String params) {
    return repository.getTransactions(params);
  }
}

class RecordPaymentParams {
  final String customerId;
  final double amount;
  final String note;
  const RecordPaymentParams(
      {required this.customerId, required this.amount, this.note = ''});
}

/// Records money the customer has paid back against their deni balance.
class RecordPaymentUseCase implements UseCase<void, RecordPaymentParams> {
  final CustomerRepository repository;
  RecordPaymentUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RecordPaymentParams params) {
    return repository.addTransaction(DebtTransaction(
      id: const Uuid().v4(),
      customerId: params.customerId,
      type: DebtTransactionType.payment,
      amount: params.amount,
      note: params.note,
      date: DateTime.now(),
    ));
  }
}
