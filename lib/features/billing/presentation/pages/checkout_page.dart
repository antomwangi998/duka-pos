import 'package:dukaepos/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../../customer/domain/entities/customer.dart';
import '../../../customer/presentation/widgets/customer_picker_sheet.dart';
import '../bloc/billing_bloc.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _paymentMethod = 'cash'; // 'cash' | 'mpesa' | 'credit'
  final _mpesaRefController = TextEditingController();
  Customer? _selectedCustomer;

  Future<void> _pickCustomer() async {
    final customer = await showCustomerPickerSheet(context);
    if (customer != null && mounted) {
      setState(() => _selectedCustomer = customer);
    }
  }

  @override
  void dispose() {
    _mpesaRefController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFE5E5EA);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        context.read<BillingBloc>().add(ClearCartEvent());
        context.go('/');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Checkout',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.chevron_left,
                size: 28, color: Theme.of(context).primaryColor),
            onPressed: () {
              context.read<BillingBloc>().add(ClearCartEvent());
              context.go('/');
            },
          ),
        ),
        body: BlocConsumer<BillingBloc, BillingState>(
          listener: (context, state) {
            if (state.checkoutSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Sale completed!'),
                  backgroundColor: Colors.green));
              context.read<BillingBloc>().add(ClearCartEvent());
              context.go('/');
            }
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.error!),
                  backgroundColor: Colors.red));
            }
          },
          builder: (context, billingState) {
            return BlocBuilder<ShopBloc, ShopState>(
              builder: (context, shopState) {
                String tillNumber = '';
                String shopName = 'Duka';
                String address1 = '';
                String address2 = '';
                String phone = '';
                String footer = 'Asante! Karibu tena.';
                String kraPin = '';
                double vatRate = 0.16;

                if (shopState is ShopLoaded) {
                  tillNumber = shopState.shop.upiId;
                  shopName = shopState.shop.name;
                  address1 = shopState.shop.addressLine1;
                  address2 = shopState.shop.addressLine2;
                  phone = shopState.shop.phoneNumber;
                  footer = shopState.shop.footerText;
                  kraPin = shopState.shop.kraPin;
                  vatRate = shopState.shop.vatRate;
                }

                final subtotal = billingState.subtotal;
                final vatAmount = subtotal * vatRate / (1 + vatRate);
                final vatExcl = subtotal - vatAmount;
                final vatPct = (vatRate * 100).toStringAsFixed(0);

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Items table
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Table(
                                  border: const TableBorder(
                                    horizontalInside:
                                        BorderSide(color: borderColor),
                                    bottom: BorderSide(color: borderColor),
                                  ),
                                  children: [
                                    TableRow(
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF8FAFC),
                                      ),
                                      children: [
                                        _buildHeaderCell('Item', TextAlign.left),
                                        _buildHeaderCell('Unit', TextAlign.right),
                                        _buildHeaderCell('Total', TextAlign.right),
                                      ],
                                    ),
                                    ...billingState.cartItems.map((item) {
                                      return TableRow(children: [
                                        _buildDataCell(
                                            '${item.quantity}x ${item.product.name}',
                                            TextAlign.left),
                                        _buildDataCell(
                                            'KSh ${item.product.price.toStringAsFixed(2)}',
                                            TextAlign.right,
                                            isSubtitle: true),
                                        _buildDataCell(
                                            'KSh ${item.total.toStringAsFixed(2)}',
                                            TextAlign.right,
                                            isBold: true),
                                      ]);
                                    }),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // VAT breakdown
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: Column(
                                children: [
                                  _buildSummaryRow(
                                      'Excl. VAT',
                                      'KSh ${vatExcl.toStringAsFixed(2)}',
                                      isSmall: true),
                                  _buildSummaryRow(
                                      'VAT ($vatPct%)',
                                      'KSh ${vatAmount.toStringAsFixed(2)}',
                                      isSmall: true),
                                  const Divider(height: 16),
                                  _buildSummaryRow(
                                      'TOTAL',
                                      'KSh ${subtotal.toStringAsFixed(2)}',
                                      isBold: true),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Payment method selector
                            const Text('Payment Method',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildPaymentChip('Cash', 'cash',
                                    Icons.money),
                                const SizedBox(width: 8),
                                _buildPaymentChip('M-Pesa', 'mpesa',
                                    Icons.phone_android),
                                const SizedBox(width: 8),
                                _buildPaymentChip('Credit', 'credit',
                                    Icons.credit_card),
                              ],
                            ),

                            // Credit (deni) section
                            if (_paymentMethod == 'credit') ...[
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: _pickCustomer,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: _selectedCustomer == null
                                            ? Colors.red.shade200
                                            : borderColor),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.person,
                                          color: _selectedCustomer == null
                                              ? Colors.red
                                              : Theme.of(context)
                                                  .primaryColor),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _selectedCustomer?.name ??
                                              'Select a customer for this deni',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: _selectedCustomer == null
                                                  ? Colors.red
                                                  : Colors.black87),
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right,
                                          color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                            ],

                            // M-Pesa section
                            if (_paymentMethod == 'mpesa') ...[
                              const SizedBox(height: 16),
                              if (tillNumber.isNotEmpty) ...[
                                Center(
                                  child: Column(
                                    children: [
                                      const Text('Scan to Pay via M-Pesa',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: 160,
                                        height: 160,
                                        child: PrettyQrView.data(
                                          // Safaricom Lipa na M-Pesa till QR format
                                          data:
                                              'https://payment.safaricom.co.ke/till?till=$tillNumber&amount=${subtotal.toStringAsFixed(0)}',
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('Till No: $tillNumber',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              TextFormField(
                                controller: _mpesaRefController,
                                decoration: const InputDecoration(
                                  labelText: 'M-Pesa Ref (optional)',
                                  hintText: 'e.g. QHX3K8L9P2',
                                  prefixIcon: Icon(Icons.confirmation_number),
                                ),
                                textCapitalization: TextCapitalization.characters,
                              ),
                            ],
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    ),

                    // Bottom action
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: PrimaryButton(
                        isLoading: billingState.isPrinting,
                        onPressed: billingState.isPrinting ||
                                (_paymentMethod == 'credit' &&
                                    _selectedCustomer == null)
                            ? null
                            : () {
                                context.read<BillingBloc>().add(CheckoutEvent(
                                      shopName: shopName,
                                      address1: address1,
                                      address2: address2,
                                      phone: phone,
                                      footer: footer,
                                      kraPin: kraPin,
                                      vatRate: vatRate,
                                      paymentMethod: _paymentMethod,
                                      mpesaRef: _mpesaRefController.text.trim().isEmpty
                                          ? null
                                          : _mpesaRefController.text.trim(),
                                      printReceipt: true,
                                      customerId: _selectedCustomer?.id,
                                      customerName: _selectedCustomer?.name,
                                    ));
                              },
                        label: _paymentMethod == 'credit' &&
                                _selectedCustomer == null
                            ? 'Select a Customer'
                            : 'Complete Sale',
                        icon: Icons.check_circle,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPaymentChip(String label, String value, IconData icon) {
    final selected = _paymentMethod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _paymentMethod = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade300,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 18,
                  color: selected ? Colors.white : Colors.grey.shade600),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : Colors.grey.shade700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, bool isSmall = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: isSmall ? 13 : 15,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: isSmall ? Colors.grey.shade600 : Colors.black87)),
          Text(value,
              style: TextStyle(
                  fontSize: isSmall ? 13 : 15,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  color: isBold
                      ? Theme.of(context).primaryColor
                      : Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, TextAlign align) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(text.toUpperCase(),
          textAlign: align,
          style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: Colors.grey)),
    );
  }

  Widget _buildDataCell(String text, TextAlign align,
      {bool isBold = false, bool isSubtitle = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Text(text,
          textAlign: align,
          style: TextStyle(
              fontSize: isSubtitle ? 12 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isSubtitle ? Colors.grey[500] : Colors.black87)),
    );
  }
}
