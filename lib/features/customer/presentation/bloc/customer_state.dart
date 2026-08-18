part of 'customer_bloc.dart';

enum CustomerStatus { initial, loading, loaded, error, success }

class CustomerState extends Equatable {
  final CustomerStatus status;
  final List<Customer> customers;
  final CustomerStatus transactionsStatus;
  final List<DebtTransaction> transactions;
  final String? message;
  final Customer? lastAddedCustomer;

  const CustomerState({
    this.status = CustomerStatus.initial,
    this.customers = const [],
    this.transactionsStatus = CustomerStatus.initial,
    this.transactions = const [],
    this.message,
    this.lastAddedCustomer,
  });

  double get totalOutstanding =>
      customers.fold(0.0, (sum, c) => sum + (c.balance > 0 ? c.balance : 0));

  CustomerState copyWith({
    CustomerStatus? status,
    List<Customer>? customers,
    CustomerStatus? transactionsStatus,
    List<DebtTransaction>? transactions,
    String? message,
    Customer? lastAddedCustomer,
  }) {
    return CustomerState(
      status: status ?? this.status,
      customers: customers ?? this.customers,
      transactionsStatus: transactionsStatus ?? this.transactionsStatus,
      transactions: transactions ?? this.transactions,
      message: message,
      lastAddedCustomer: lastAddedCustomer ?? this.lastAddedCustomer,
    );
  }

  @override
  List<Object?> get props => [
        status,
        customers,
        transactionsStatus,
        transactions,
        message,
        lastAddedCustomer,
      ];
}
