import 'package:flutter/material.dart';

/// 颜色常量
class AppColors {
  // 背景色
  static const bgPrimary = Color(0xFF0F1419);
  static const bgSecondary = Color(0xFF1A2026);
  static const bgTertiary = Color(0xFF242B33);
  static const bgCard = Color(0xFF1E2630);
  static const bgHover = Color(0xFF2A3441);
  
  // 文字色
  static const textPrimary = Color(0xFFF0F4F8);
  static const textSecondary = Color(0xFFA8B5C4);
  static const textTertiary = Color(0xFF6B7C8D);
  
  // 功能色
  static const accent = Color(0xFF4ECDC4);
  static const accentSecondary = Color(0xFF44A8B3);
  static const income = Color(0xFF7BED9F);
  static const expense = Color(0xFFFF6B81);
  
  // 渐变
  static const accentGradient = LinearGradient(
    colors: [accent, accentSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// 尺寸常量
class AppDimensions {
  // 页面边距
  static const pagePadding = 20.0;
  static const cardPadding = 16.0;
  
  // 圆角
  static const radiusSmall = 8.0;
  static const radiusMedium = 12.0;
  static const radiusLarge = 16.0;
  static const radiusXLarge = 20.0;
  
  // 间距
  static const spacingSmall = 8.0;
  static const spacingMedium = 12.0;
  static const spacingLarge = 16.0;
  static const spacingXLarge = 20.0;
  
  // 图标尺寸
  static const iconSmall = 18.0;
  static const iconMedium = 24.0;
  static const iconLarge = 42.0;
  static const fabSize = 56.0;
}

/// 字符串常量
class AppStrings {
  static const appName = '轻记';
  static const home = '首页';
  static const stats = '统计';
  static const categories = '分类';
  static const addRecord = '记一笔';
  static const categoryManagement = '分类管理';
  static const thisMonth = '本月';
  static const income = '收入';
  static const expense = '支出';
  static const note = '备注';
  static const amount = '金额';
  static const save = '保存';
  static const cancel = '取消';
  static const confirm = '确定';
  static const edit = '编辑';
  static const done = '完成';
  static const add = '添加';
  static const delete = '删除';
}
