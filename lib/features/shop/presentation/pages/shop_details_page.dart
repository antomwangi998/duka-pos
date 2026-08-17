import 'package:billing_app/core/widgets/input_label.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/shop.dart';
import '../bloc/shop_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_validators.dart';

class ShopDetailsPage extends StatefulWidget {
  const ShopDetailsPage({super.key});

  @override
  State<ShopDetailsPage> createState() => _ShopDetailsPageState();
}

class _ShopDetailsPageState extends State<ShopDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _address1Controller;
  late TextEditingController _address2Controller;
  late TextEditingController _phoneController;
  late TextEditingController _tillController;     // was upiId
  late TextEditingController _footerController;
  late TextEditingController _kraPinController;
  late TextEditingController _vatRateController;
  late TextEditingController _lowStockController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _address1Controller = TextEditingController();
    _address2Controller = TextEditingController();
    _phoneController = TextEditingController();
    _tillController = TextEditingController();
    _footerController = TextEditingController();
    _kraPinController = TextEditingController();
    _vatRateController = TextEditingController(text: '16');
    _lowStockController = TextEditingController(text: '5');
    context.read<ShopBloc>().add(LoadShopEvent());
  }

  void _updateControllers(Shop shop) {
    if (_nameController.text.isEmpty && shop.name.isNotEmpty) {
      _nameController.text = shop.name;
      _address1Controller.text = shop.addressLine1;
      _address2Controller.text = shop.addressLine2;
      _phoneController.text = shop.phoneNumber;
      _tillController.text = shop.upiId;
      _footerController.text = shop.footerText;
      _kraPinController.text = shop.kraPin;
      _vatRateController.text =
          (shop.vatRate * 100).toStringAsFixed(0);
      _lowStockController.text = shop.lowStockThreshold.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _phoneController.dispose();
    _tillController.dispose();
    _footerController.dispose();
    _kraPinController.dispose();
    _vatRateController.dispose();
    _lowStockController.dispose();
    super.dispose();
  }

  void _saveShop() {
    if (_formKey.currentState!.validate()) {
      final vatRate =
          (double.tryParse(_vatRateController.text) ?? 16) / 100;
      final lowStock = int.tryParse(_lowStockController.text) ?? 5;
      final shop = Shop(
        name: _nameController.text.trim(),
        addressLine1: _address1Controller.text.trim(),
        addressLine2: _address2Controller.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        upiId: _tillController.text.trim(),
        footerText: _footerController.text.trim(),
        kraPin: _kraPinController.text.trim().toUpperCase(),
        vatRate: vatRate,
        lowStockThreshold: lowStock,
      );
      context.read<ShopBloc>().add(UpdateShopEvent(shop));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop Details')),
      body: BlocConsumer<ShopBloc, ShopState>(
        listener: (context, state) {
          if (state is ShopLoaded) {
            _updateControllers(state.shop);
          } else if (state is ShopOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Shop details saved!'),
                backgroundColor: Colors.green));
            context.pop();
          } else if (state is ShopError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red));
          }
        },
        buildWhen: (p, c) => c is ShopLoading || c is ShopLoaded,
        builder: (context, state) {
          if (state is ShopLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionTitle('Shop Info'),
                  const SizedBox(height: 16),
                  const InputLabel(text: 'Shop Name'),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'e.g. Baba\'s Duka',
                    validator: AppValidators.required('Required'),
                  ),
                  const SizedBox(height: 12),
                  const InputLabel(text: 'Address Line 1'),
                  _buildTextField(
                    controller: _address1Controller,
                    hint: 'Mama Ngina Street',
                    validator: AppValidators.required('Required'),
                  ),
                  const SizedBox(height: 12),
                  const InputLabel(text: 'Address Line 2 (optional)'),
                  _buildTextField(
                    controller: _address2Controller,
                    hint: 'Nairobi, Kenya',
                  ),
                  const SizedBox(height: 12),
                  const InputLabel(text: 'Phone Number'),
                  _buildTextField(
                    controller: _phoneController,
                    hint: '+254 700 000 000',
                    keyboardType: TextInputType.phone,
                    validator: AppValidators.required('Required'),
                  ),
                  const SizedBox(height: 12),
                  const InputLabel(text: 'Receipt Footer'),
                  _buildTextField(
                    controller: _footerController,
                    hint: 'Asante! Karibu tena.',
                    maxLines: 2,
                    maxLength: 150,
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle('M-Pesa & KRA'),
                  const SizedBox(height: 16),
                  const InputLabel(text: 'M-Pesa Till / Paybill Number'),
                  _buildTextField(
                    controller: _tillController,
                    hint: 'e.g. 123456',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  const InputLabel(text: 'KRA PIN'),
                  _buildTextField(
                    controller: _kraPinController,
                    hint: 'P000000000A',
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 12),
                  const InputLabel(text: 'VAT Rate (%)'),
                  _buildTextField(
                    controller: _vatRateController,
                    hint: '16',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = double.tryParse(v ?? '');
                      if (n == null || n < 0 || n > 100) {
                        return 'Enter a valid rate (0–100)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle('Inventory Alerts'),
                  const SizedBox(height: 16),
                  const InputLabel(text: 'Low Stock Threshold (units)'),
                  _buildTextField(
                    controller: _lowStockController,
                    hint: '5',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: PrimaryButton(
        onPressed: _saveShop,
        icon: Icons.save,
        label: 'Save Details',
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: AppTheme.primaryColor.withValues(alpha: 0.9)));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
    TextCapitalization textCapitalization = TextCapitalization.words,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      validator: validator,
      decoration: InputDecoration(hintText: hint),
    );
  }
}
