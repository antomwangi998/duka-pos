import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/customer.dart';
import '../entities/debt_transaction.dart';

abstract class CustomerRepository {
  Future<Either<Failure, List<Customer>>> getCustomers();
  Future<Either<Failure, Customer>> getCustomerById(String id);
  Future<Either<Failure, void>> addCustomer(Customer customer);
  Future<Either<Failure, void>> updateCustomer(Customer customer);
  Future<Either<Failure, void>> deleteCustomer(String id);

  Future<Either<Failure, List<DebtTransaction>>> getTransactions(
      String customerId);

  /// Records a ledger entry for [customerId] and atomically updates that
  /// customer's running balance (credit sales add to the balance, payments
  /// subtract from it).
  Future<Either<Failure, void>> addTransaction(DebtTransaction transaction);
}
