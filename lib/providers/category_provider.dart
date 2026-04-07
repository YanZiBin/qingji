import 'package:flutter/foundation.dart' hide Category;
import '../models/record.dart';
import '../models/category.dart';
import '../database/database_helper.dart';

/// 分类状态管理
class CategoryProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Category> _expenseCategories = [];
  List<Category> _incomeCategories = [];
  RecordType _selectedType = RecordType.expense;

  List<Category> get categories => _selectedType == RecordType.expense
      ? _expenseCategories
      : _incomeCategories;
  RecordType get selectedType => _selectedType;

  /// 加载所有分类
  Future<void> loadCategories() async {
    try {
      _expenseCategories = await _dbHelper.getCategories(RecordType.expense);
      _incomeCategories = await _dbHelper.getCategories(RecordType.income);
      notifyListeners();
    } catch (e) {
      debugPrint('加载分类失败: $e');
    }
  }

  /// 切换类型
  void switchType(RecordType type) {
    _selectedType = type;
    notifyListeners();
  }

  /// 添加分类
  Future<bool> addCategory(Category category) async {
    try {
      await _dbHelper.insertCategory(category);
      await loadCategories();
      return true;
    } catch (e) {
      debugPrint('添加分类失败: $e');
      return false;
    }
  }

  /// 删除分类
  Future<bool> deleteCategory(int id) async {
    try {
      await _dbHelper.deleteCategory(id);
      await loadCategories();
      return true;
    } catch (e) {
      debugPrint('删除分类失败: $e');
      return false;
    }
  }
}
