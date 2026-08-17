import '../../../../core/data/hive_database.dart';
import '../models/sale_record_model.dart';

class SaleRepositoryImpl {
  Future<void> saveSale(SaleRecordModel sale) async {
    await HiveDatabase.salesBox.add(sale);
  }

  List<SaleRecordModel> getAllSales() {
    return HiveDatabase.salesBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<SaleRecordModel> getSalesByDateRange(DateTime from, DateTime to) {
    return HiveDatabase.salesBox.values
        .where((s) => s.date.isAfter(from) && s.date.isBefore(to))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Returns sales for today only
  List<SaleRecordModel> getTodaySales() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getSalesByDateRange(startOfDay, endOfDay);
  }

  /// Returns sales for this week (Mon–Sun)
  List<SaleRecordModel> getWeekSales() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final from = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final to = from.add(const Duration(days: 7));
    return getSalesByDateRange(from, to);
  }

  /// Returns sales for this calendar month
  List<SaleRecordModel> getMonthSales() {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, 1);
    final to = DateTime(now.year, now.month + 1, 1);
    return getSalesByDateRange(from, to);
  }
}
