import 'package:flutter/foundation.dart';
import '../models/record.dart';
import '../database/database_helper.dart';

/// 记录状态管理
class RecordProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Record> _records = [];
  bool _isLoading = false;
  DateTime _selectedMonth = DateTime.now();

  List<Record> get records => _records;
  bool get isLoading => _isLoading;
  DateTime get selectedMonth => _selectedMonth;

  /// 获取月度收支总结
  Map<String, double> _monthSummary = {'income': 0.0, 'expense': 0.0};
  Map<String, double> get monthSummary => _monthSummary;

  /// 加载指定月份的记录
  Future<void> loadMonthRecords(DateTime month) async {
    _selectedMonth = month;
    _isLoading = true;
    notifyListeners();

    try {
      final startDate = DateTime(month.year, month.month, 1);
      final endDate = DateTime(month.year, month.month + 1, 1);

      _records = await _dbHelper.getRecords(
        startDate: startDate,
        endDate: endDate,
        limit: 50,
      );

      _monthSummary = await _dbHelper.getMonthSummary(month);
    } catch (e) {
      debugPrint('加载记录失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 添加记录
  Future<bool> addRecord(Record record) async {
    try {
      await _dbHelper.insertRecord(record);
      await loadMonthRecords(_selectedMonth);
      return true;
    } catch (e) {
      debugPrint('添加记录失败：$e');
      return false;
    }
  }

  /// 更新记录
  Future<bool> updateRecord(Record record) async {
    try {
      await _dbHelper.updateRecord(record);
      await loadMonthRecords(_selectedMonth);
      return true;
    } catch (e) {
      debugPrint('更新记录失败：$e');
      return false;
    }
  }

  /// 删除记录
  Future<bool> deleteRecord(int id) async {
    try {
      await _dbHelper.deleteRecord(id);
      await loadMonthRecords(_selectedMonth);
      return true;
    } catch (e) {
      debugPrint('删除记录失败: $e');
      return false;
    }
  }

  /// 切换月份
  void changeMonth(DateTime month) {
    loadMonthRecords(month);
  }
}
