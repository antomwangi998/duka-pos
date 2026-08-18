import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/debt_transaction.dart';
import '../bloc/customer_bloc.dart';

class CustomerDetailPage extends StatefulWidget {
  final Customer customer;
  const CustomerDetailPage({super.key, required this.customer});

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<CustomerBloc>()
        .add(LoadCustomerTransactions(widget.customer.id));
  }

  void _showRecordPaymentSheet(BuildContext context) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Record Payment',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('From ${widget.customer.name}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: amountController,
                    autofocus: true,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount (KSh)',
                      prefixIcon: Icon(Icons.payments),
                    ),
                    validator: (v) {
                      final value = double.tryParse(v ?? '');
                      if (value == null || value <= 0) {
                        return 'Enter a valid amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                      prefixIcon: Icon(Icons.notes),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Save Payment',
                    icon: Icons.check_circle,
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        context.read<CustomerBloc>().add(RecordCustomerPayment(
                              customerId: widget.customer.id,
                              amount: double.parse(amountController.text),
                              note: noteController.text.trim(),
                            ));
                        Navigator.of(sheetContext).pop();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left,
              size: 28, color: Theme.of(context).primaryColor),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (widget.customer.phone.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.call, color: AppTheme.primaryColor),
              onPressed: () =>
                  launchUrl(Uri.parse('tel:${widget.customer.phone}')),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: BlocConsumer<CustomerBloc, CustomerState>(
        listenWhen: (previous, current) =>
            current.status == CustomerStatus.error,
        listener: (context, state) {
          if (state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message!), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          // Keep the balance fresh from the customer list state.
          final freshCustomer = state.customers.firstWhere(
            (c) => c.id == widget.customer.id,
            orElse: () => widget.customer,
          );
          final owesMoney = freshCustomer.balance > 0;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: owesMoney
                        ? const Color(0xFFDC2626)
                        : AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CURRENT BALANCE',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text(
                        'KSh ${freshCustomer.balance.abs().toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900),
                      ),
                      Text(
                        owesMoney
                            ? 'owed to the shop'
                            : freshCustomer.balance < 0
                                ? 'in credit'
                                : 'fully settled',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PrimaryButton(
                  label: 'Record Payment',
                  icon: Icons.add_card,
                  onPressed: () => _showRecordPaymentSheet(context),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Transaction History',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              Expanded(
                child: state.transactionsStatus == CustomerStatus.loading &&
                        state.transactions.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : state.transactions.isEmpty
                        ? Center(
                            child: Text('No transactions yet',
                                style: TextStyle(color: Colors.grey[400])))
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            itemCount: state.transactions.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final tx = state.transactions[index];
                              return _TransactionTile(transaction: tx);
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove customer?'),
        content: Text(
            'This will delete ${widget.customer.name} and their transaction history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<CustomerBloc>().add(DeleteCustomer(widget.customer.id));
              context.pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final DebtTransaction transaction;
  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type == DebtTransactionType.credit;
    final color = isCredit ? const Color(0xFFDC2626) : const Color(0xFF16A34A);
    final sign = isCredit ? '+' : '-';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5EA)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(isCredit ? Icons.shopping_bag : Icons.payments,
                size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isCredit ? 'Credit sale' : 'Payment received',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                Text(
                  DateFormat('d MMM yyyy, h:mm a').format(transaction.date),
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
                if (transaction.note.isNotEmpty)
                  Text(transaction.note,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          Text('$sign KSh ${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
