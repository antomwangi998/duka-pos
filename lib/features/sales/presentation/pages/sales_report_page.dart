import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/sale_record_model.dart';
import '../../data/repositories/sale_repository_impl.dart';

class SalesReportPage extends StatefulWidget {
  const SalesReportPage({super.key});

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _repo = SaleRepositoryImpl();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Reports',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'This Week'),
            Tab(text: 'This Month'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ReportView(sales: _repo.getTodaySales(), period: 'Today'),
          _ReportView(sales: _repo.getWeekSales(), period: 'This Week'),
          _ReportView(sales: _repo.getMonthSales(), period: 'This Month'),
        ],
      ),
    );
  }
}

class _ReportView extends StatelessWidget {
  final List<SaleRecordModel> sales;
  final String period;

  const _ReportView({required this.sales, required this.period});

  @override
  Widget build(BuildContext context) {
    if (sales.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No sales for $period',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey)),
          ],
        ),
      );
    }

    // Aggregate
    final totalRevenue = sales.fold<double>(0, (s, r) => s + r.total);
    final totalVat = sales.fold<double>(0, (s, r) => s + r.vatAmount);
    final cashSales = sales
        .where((r) => r.paymentMethod == 'cash')
        .fold<double>(0, (s, r) => s + r.total);
    final mpesaSales = sales
        .where((r) => r.paymentMethod == 'mpesa')
        .fold<double>(0, (s, r) => s + r.total);
    final creditSales = sales
        .where((r) => r.paymentMethod == 'credit')
        .fold<double>(0, (s, r) => s + r.total);

    // Top products
    final Map<String, double> productTotals = {};
    for (final sale in sales) {
      for (final item in sale.items) {
        productTotals[item.productName] =
            (productTotals[item.productName] ?? 0) + item.total;
      }
    }
    final topProducts = productTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Row(
            children: [
              _StatCard(
                label: 'Revenue',
                value: 'KSh ${totalRevenue.toStringAsFixed(2)}',
                icon: Icons.attach_money,
                color: Colors.green,
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'Transactions',
                value: '${sales.length}',
                icon: Icons.receipt_long,
                color: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatCard(
                label: 'VAT Collected',
                value: 'KSh ${totalVat.toStringAsFixed(2)}',
                icon: Icons.account_balance,
                color: Colors.purple,
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'Avg Sale',
                value:
                    'KSh ${(totalRevenue / sales.length).toStringAsFixed(2)}',
                icon: Icons.trending_up,
                color: Colors.orange,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Payment breakdown
          _SectionHeader('Payment Breakdown'),
          const SizedBox(height: 8),
          _PaymentBar(label: 'Cash', amount: cashSales, total: totalRevenue),
          const SizedBox(height: 6),
          _PaymentBar(
              label: 'M-Pesa',
              amount: mpesaSales,
              total: totalRevenue,
              color: Colors.green),
          const SizedBox(height: 6),
          _PaymentBar(
              label: 'Credit',
              amount: creditSales,
              total: totalRevenue,
              color: Colors.orange),

          const SizedBox(height: 24),

          // Top products
          if (topProducts.isNotEmpty) ...[
            _SectionHeader('Top Products'),
            const SizedBox(height: 8),
            ...topProducts.take(5).map((e) => _TopProductRow(
                  name: e.key,
                  amount: e.value,
                  totalRevenue: totalRevenue,
                )),
          ],

          const SizedBox(height: 24),

          // Recent transactions
          _SectionHeader('Recent Sales'),
          const SizedBox(height: 8),
          ...sales.take(20).map((sale) => _SaleRow(sale: sale)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Theme.of(context).primaryColor));
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}

class _PaymentBar extends StatelessWidget {
  final String label;
  final double amount;
  final double total;
  final Color color;

  const _PaymentBar({
    required this.label,
    required this.amount,
    required this.total,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? amount / total : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('KSh ${amount.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _TopProductRow extends StatelessWidget {
  final String name;
  final double amount;
  final double totalRevenue;

  const _TopProductRow({
    required this.name,
    required this.amount,
    required this.totalRevenue,
  });

  @override
  Widget build(BuildContext context) {
    final pct = totalRevenue > 0 ? (amount / totalRevenue * 100) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(name,
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          Text('${pct.toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(width: 8),
          Text('KSh ${amount.toStringAsFixed(0)}',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SaleRow extends StatelessWidget {
  final SaleRecordModel sale;
  const _SaleRow({required this.sale});

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm').format(sale.date);
    final payIcon = sale.paymentMethod == 'mpesa'
        ? Icons.phone_android
        : sale.paymentMethod == 'credit'
            ? Icons.credit_card
            : Icons.money;
    final payColor = sale.paymentMethod == 'mpesa'
        ? Colors.green
        : sale.paymentMethod == 'credit'
            ? Colors.orange
            : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(payIcon, color: payColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${sale.items.length} item${sale.items.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text(time,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Text('KSh ${sale.total.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
