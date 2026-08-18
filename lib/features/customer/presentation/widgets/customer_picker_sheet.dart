import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/customer.dart';
import '../bloc/customer_bloc.dart';

/// Shows a searchable list of customers plus a quick-add form, and resolves
/// with the [Customer] the cashier selected (or null if dismissed).
Future<Customer?> showCustomerPickerSheet(BuildContext context) {
  return showModalBottomSheet<Customer>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _CustomerPickerSheet(),
  );
}

class _CustomerPickerSheet extends StatefulWidget {
  const _CustomerPickerSheet();

  @override
  State<_CustomerPickerSheet> createState() => _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends State<_CustomerPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _showQuickAdd = false;

  final _quickAddNameController = TextEditingController();
  final _quickAddPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(LoadCustomers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quickAddNameController.dispose();
    _quickAddPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Select Customer',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _showQuickAdd = !_showQuickAdd),
                      icon: Icon(_showQuickAdd ? Icons.close : Icons.person_add,
                          size: 18),
                      label: Text(_showQuickAdd ? 'Cancel' : 'New'),
                    ),
                  ],
                ),
              ),
              if (_showQuickAdd)
                _buildQuickAddForm(context)
              else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: const InputDecoration(
                      hintText: 'Search by name or phone',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: BlocBuilder<CustomerBloc, CustomerState>(
                    builder: (context, state) {
                      final filtered = state.customers.where((c) {
                        if (_query.isEmpty) return true;
                        final q = _query.toLowerCase();
                        return c.name.toLowerCase().contains(q) ||
                            c.phone.toLowerCase().contains(q);
                      }).toList();

                      if (filtered.isEmpty) {
                        return Center(
                          child: Text(
                            state.customers.isEmpty
                                ? 'No customers yet. Tap "New" to add one.'
                                : 'No matches found.',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        );
                      }

                      return ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final customer = filtered[index];
                          return ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xFFE5E5EA)),
                            ),
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppTheme.primaryColor.withValues(alpha: 0.12),
                              child: Text(
                                customer.name.isNotEmpty
                                    ? customer.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(customer.name,
                                style:
                                    const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: customer.phone.isNotEmpty
                                ? Text(customer.phone)
                                : null,
                            trailing: customer.balance > 0
                                ? Text(
                                    'owes ${customer.balance.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        color: Color(0xFFDC2626), fontSize: 12))
                                : null,
                            onTap: () => Navigator.of(context).pop(customer),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAddForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        children: [
          TextField(
            controller: _quickAddNameController,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Customer Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _quickAddPhoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Phone (optional)'),
          ),
          const SizedBox(height: 16),
          BlocConsumer<CustomerBloc, CustomerState>(
            listener: (context, state) {
              if (state.status == CustomerStatus.success &&
                  state.lastAddedCustomer != null &&
                  _quickAddNameController.text.trim() ==
                      state.lastAddedCustomer!.name) {
                Navigator.of(context).pop(state.lastAddedCustomer);
              }
            },
            builder: (context, state) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_quickAddNameController.text.trim().isEmpty) return;
                    context.read<CustomerBloc>().add(AddCustomer(
                          name: _quickAddNameController.text.trim(),
                          phone: _quickAddPhoneController.text.trim(),
                        ));
                  },
                  child: const Text('Save & Select'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
