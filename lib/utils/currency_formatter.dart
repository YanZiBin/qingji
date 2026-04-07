import 'package:intl/intl.dart';

/// 货币格式化工具类
class CurrencyFormatter {
  static final _currencyFormat = NumberFormat('#,##0.00', 'zh_CN');

  /// 格式化金额 如：¥1,234.56
  static String format(double amount) {
    return '¥${_currencyFormat.format(amount)}';
  }

  /// 格式化金额（无符号）
  static String formatWithoutSymbol(double amount) {
    return _currencyFormat.format(amount);
  }

  /// 格式化金额（带正负号）
  static String formatWithSign(double amount, {bool showPlus = false}) {
    if (amount >= 0 && showPlus) {
      return '+¥${_currencyFormat.format(amount)}';
    }
    return '¥${_currencyFormat.format(amount)}';
  }

  /// 解析字符串为金额
  static double parse(String input) {
    try {
      final cleaned = input.replaceAll(',', '').replaceAll('¥', '');
      return double.parse(cleaned);
    } catch (e) {
      return 0.0;
    }
  }
}
