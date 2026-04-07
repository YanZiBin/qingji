import 'package:intl/intl.dart';

/// 日期格式化工具类
class DateFormatter {
  /// 格式化为年月日 如：2026年4月6日
  static String fullDate(DateTime date) {
    return DateFormat('yyyy年M月d日').format(date);
  }
  
  /// 格式化为年月 如：2026年4月
  static String yearMonth(DateTime date) {
    return DateFormat('yyyy年M月').format(date);
  }
  
  /// 格式化为日期 如：4月6日
  static String monthDay(DateTime date) {
    return DateFormat('M月d日').format(date);
  }
  
  /// 格式化为时间 如：12:30
  static String time(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
  
  /// 格式化为完整时间 如：2026-04-06 12:30
  static String fullDateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }
  
  /// 获取日期分组标签
  static String dateGroupLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateDay = DateTime(date.year, date.month, date.day);
    
    if (dateDay == today) {
      return '今天';
    } else if (dateDay == yesterday) {
      return '昨天';
    } else {
      return monthDay(date);
    }
  }
}
