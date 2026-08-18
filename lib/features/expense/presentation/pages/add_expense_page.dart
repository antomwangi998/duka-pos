import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../bloc/expense_bloc.dart';
import '../../domain/entities/expense.dart';
import '../../../../core/widgets/input_label.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/utils/app_validators.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  double _amount = 0.0;
  String _category = ExpenseCategories.other;
  String _note = '';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final expense = Expense(
        id: const Uuid().v4(),
        title: _title,
        amount: _amount,
        category: _category,
        date: DateTime.now(),
        note: _note.trim().isEmpty ? null : _note.trim(),
      );

      context.read<ExpenseBloc>().add(AddExpense(expense));
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left,
              size: 28, color: Theme.of(context).primaryColor),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: const Text('Add Expense',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const InputLabel(text: 'Title'),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'e.g. Restocked sugar & flour',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: AppValidators.required('Please enter a title'),
                  onSaved: (value) => _title = value!,
                ),
                const SizedBox(height: 24),
                const InputLabel(text: 'Amount'),
                TextFormField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    prefixText: 'KSh ',
                    prefixStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                  validator: AppValidators.price,
                  onSaved: (value) => _amount = double.parse(value!),
                ),
                const SizedBox(height: 24),
                const InputLabel(text: 'Category'),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  items: ExpenseCategories.all
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _category = value);
                  },
                ),
                const SizedBox(height: 24),
                const InputLabel(text: 'Note (optional)'),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Any extra detail',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onSaved: (value) => _note = value ?? '',
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: PrimaryButton(
        onPressed: _submit,
        icon: Icons.check_circle,
        label: 'Save Expense',
      ),
    );
  }
}
