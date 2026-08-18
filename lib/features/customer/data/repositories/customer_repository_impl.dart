import 'package:fpdart/fpdart.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/debt_transaction.dart';
import '../../domain/repositories/customer_repository.dart';
import '../models/customer_model.dart';
import '../models/debt_transaction_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  @override
  Future<Either<Failure, List<Customer>>> getCustomers() async {
    try {
      final box = HiveDatabase.customersBox;
      final customers = box.values.toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return Right(customers);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Customer>> getCustomerById(String id) async {
    try {
      final box = HiveDatabase.customersBox;
      final customer = box.values.firstWhere(
        (c) => c.id == id,
        orElse: () => throw Exception('Customer not found'),
      );
      return Right(customer);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addCustomer(Customer customer) async {
    try {
      final box = HiveDatabase.customersBox;
      final model = CustomerModel.fromEntity(customer);
      await box.put(model.id, model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCustomer(Customer customer) async {
    try {
      final box = HiveDatabase.customersBox;
      final model = CustomerModel.fromEntity(customer);
      await box.put(model.id, model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCustomer(String id) async {
    try {
      final customersBox = HiveDatabase.customersBox;
      await customersBox.delete(id);

      // Clean up their ledger too.
      final debtBox = HiveDatabase.debtTransactionsBox;
      final keysToDelete = debtBox.toMap().entries
          .where((entry) => entry.value.customerId == id)
          .map((entry) => entry.key)
          .toList();
      await debtBox.deleteAll(keysToDelete);

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DebtTransaction>>> getTransactions(
      String customerId) async {
    try {
      final box = HiveDatabase.debtTransactionsBox;
      final transactions = box.values
          .where((t) => t.customerId == customerId)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return Right(transactions);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addTransaction(
      DebtTransaction transaction) async {
    try {
      final debtBox = HiveDatabase.debtTransactionsBox;
      final model = DebtTransactionModel.fromEntity(transaction);
      await debtBox.put(model.id, model);

      // Update the customer's running balance.
      final customersBox = HiveDatabase.customersBox;
      final existing = customersBox.get(transaction.customerId);
      if (existing != null) {
        final delta = transaction.type == DebtTransactionType.credit
            ? transaction.amount
            : -transaction.amount;
        final updated = CustomerModel(
          id: existing.id,
          name: existing.name,
          phone: existing.phone,
          notes: existing.notes,
          balance: existing.balance + delta,
          createdAt: existing.createdAt,
        );
        await customersBox.put(existing.id, updated);
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
