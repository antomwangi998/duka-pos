import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/customer_bloc.dart';

/// Add a new customer. If [returnOnSave] is true, pops with the newly
/// created customer's name once saved (used by the checkout credit-sale
/// quick-add flow); otherwise just returns to the customer list.
class AddCustomerPage extends StatefulWidget {
  final bool returnOnSave;
  const AddCustomerPage({super.key, this.returnOnSave = false});

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Customer',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left,
              size: 28, color: Theme.of(context).primaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<CustomerBloc, CustomerState>(
        listener: (context, state) {
          if (state.status == CustomerStatus.success &&
              state.lastAddedCustomer != null) {
            if (widget.returnOnSave) {
              context.pop(state.lastAddedCustomer);
            } else {
              context.pop();
            }
          }
          if (state.status == CustomerStatus.error &&
              state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message!), backgroundColor: Colors.red));
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Full Name',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'e.g. Mama Njeri'),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              const Text('Phone Number',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(hintText: 'e.g. 07XX XXX XXX'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              const Text('Notes (optional)',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                decoration:
                    const InputDecoration(hintText: 'e.g. Neighbour, pays weekly'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              BlocBuilder<CustomerBloc, CustomerState>(
                builder: (context, state) {
                  return PrimaryButton(
                    isLoading: state.status == CustomerStatus.loading,
                    label: 'Save Customer',
                    icon: Icons.check_circle,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<CustomerBloc>().add(AddCustomer(
                              name: _nameController.text.trim(),
                              phone: _phoneController.text.trim(),
                              notes: _notesController.text.trim(),
                            ));
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
