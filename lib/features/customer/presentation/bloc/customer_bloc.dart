import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/debt_transaction.dart';
import '../../domain/usecases/customer_usecases.dart';
import '../../../../core/usecase/usecase.dart';

part 'customer_event.dart';
part 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final GetCustomersUseCase getCustomersUseCase;
  final AddCustomerUseCase addCustomerUseCase;
  final UpdateCustomerUseCase updateCustomerUseCase;
  final DeleteCustomerUseCase deleteCustomerUseCase;
  final GetCustomerTransactionsUseCase getCustomerTransactionsUseCase;
  final RecordPaymentUseCase recordPaymentUseCase;

  CustomerBloc({
    required this.getCustomersUseCase,
    required this.addCustomerUseCase,
    required this.updateCustomerUseCase,
    required this.deleteCustomerUseCase,
    required this.getCustomerTransactionsUseCase,
    required this.recordPaymentUseCase,
  }) : super(const CustomerState()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<AddCustomer>(_onAddCustomer);
    on<UpdateCustomer>(_onUpdateCustomer);
    on<DeleteCustomer>(_onDeleteCustomer);
    on<LoadCustomerTransactions>(_onLoadTransactions);
    on<RecordCustomerPayment>(_onRecordPayment);
  }

  Future<void> _onLoadCustomers(
      LoadCustomers event, Emitter<CustomerState> emit) async {
    emit(state.copyWith(status: CustomerStatus.loading));
    final result = await getCustomersUseCase(NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
          status: CustomerStatus.error, message: failure.message)),
      (customers) => emit(state.copyWith(
          status: CustomerStatus.loaded, customers: customers)),
    );
  }

  Future<void> _onAddCustomer(
      AddCustomer event, Emitter<CustomerState> emit) async {
    final customer = Customer(
      id: const Uuid().v4(),
      name: event.name,
      phone: event.phone,
      notes: event.notes,
      createdAt: DateTime.now(),
    );
    final result = await addCustomerUseCase(customer);
    result.fold(
      (failure) => emit(state.copyWith(
          status: CustomerStatus.error, message: failure.message)),
      (_) {
        emit(state.copyWith(
            status: CustomerStatus.success,
            message: 'Customer added',
            lastAddedCustomer: customer));
        add(LoadCustomers());
      },
    );
  }

  Future<void> _onUpdateCustomer(
      UpdateCustomer event, Emitter<CustomerState> emit) async {
    final result = await updateCustomerUseCase(event.customer);
    result.fold(
      (failure) => emit(state.copyWith(
          status: CustomerStatus.error, message: failure.message)),
      (_) {
        emit(state.copyWith(
            status: CustomerStatus.success, message: 'Customer updated'));
        add(LoadCustomers());
      },
    );
  }

  Future<void> _onDeleteCustomer(
      DeleteCustomer event, Emitter<CustomerState> emit) async {
    final result = await deleteCustomerUseCase(event.id);
    result.fold(
      (failure) => emit(state.copyWith(
          status: CustomerStatus.error, message: failure.message)),
      (_) {
        emit(state.copyWith(
            status: CustomerStatus.success, message: 'Customer removed'));
        add(LoadCustomers());
      },
    );
  }

  Future<void> _onLoadTransactions(
      LoadCustomerTransactions event, Emitter<CustomerState> emit) async {
    emit(state.copyWith(transactionsStatus: CustomerStatus.loading));
    final result = await getCustomerTransactionsUseCase(event.customerId);
    result.fold(
      (failure) => emit(state.copyWith(
          transactionsStatus: CustomerStatus.error, message: failure.message)),
      (transactions) => emit(state.copyWith(
          transactionsStatus: CustomerStatus.loaded,
          transactions: transactions)),
    );
  }

  Future<void> _onRecordPayment(
      RecordCustomerPayment event, Emitter<CustomerState> emit) async {
    final result = await recordPaymentUseCase(RecordPaymentParams(
      customerId: event.customerId,
      amount: event.amount,
      note: event.note,
    ));
    result.fold(
      (failure) => emit(state.copyWith(
          status: CustomerStatus.error, message: failure.message)),
      (_) {
        emit(state.copyWith(
            status: CustomerStatus.success, message: 'Payment recorded'));
        add(LoadCustomers());
        add(LoadCustomerTransactions(event.customerId));
      },
    );
  }
}
