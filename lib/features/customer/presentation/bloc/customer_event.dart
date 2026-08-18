part of 'customer_bloc.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();
  @override
  List<Object?> get props => [];
}

class LoadCustomers extends CustomerEvent {}

class AddCustomer extends CustomerEvent {
  final String name;
  final String phone;
  final String notes;
  const AddCustomer({required this.name, this.phone = '', this.notes = ''});
  @override
  List<Object?> get props => [name, phone, notes];
}

class UpdateCustomer extends CustomerEvent {
  final Customer customer;
  const UpdateCustomer(this.customer);
  @override
  List<Object?> get props => [customer];
}

class DeleteCustomer extends CustomerEvent {
  final String id;
  const DeleteCustomer(this.id);
  @override
  List<Object?> get props => [id];
}

class LoadCustomerTransactions extends CustomerEvent {
  final String customerId;
  const LoadCustomerTransactions(this.customerId);
  @override
  List<Object?> get props => [customerId];
}

class RecordCustomerPayment extends CustomerEvent {
  final String customerId;
  final double amount;
  final String note;
  const RecordCustomerPayment(
      {required this.customerId, required this.amount, this.note = ''});
  @override
  List<Object?> get props => [customerId, amount, note];
}
