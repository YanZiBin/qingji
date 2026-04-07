// This is a basic Flutter widget test for the Qingji accounting app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:qingji/main.dart';
import 'package:qingji/providers/record_provider.dart';
import 'package:qingji/providers/category_provider.dart';
import 'package:qingji/core/constants.dart';

void main() {
  // 注意：测试使用内存数据库，每次测试后会自动清理
  // 不需要额外配置 databaseFactory

  testWidgets('应用启动并显示首页', (WidgetTester tester) async {
    // 构建应用（使用 Provider 包裹）
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => RecordProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 验证首页标题
    expect(find.text('轻记'), findsOneWidget);

    // 验证底部导航栏存在
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });

  testWidgets('记账页面可以打开', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => RecordProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 点击 FAB 打开记账页
    final fabFinder = find.byType(FloatingActionButton);
    expect(fabFinder, findsOneWidget);
    await tester.tap(fabFinder);
    await tester.pumpAndSettle();

    // 验证记账页标题
    expect(find.text('记一笔'), findsOneWidget);

    // 验证金额输入框存在
    expect(find.text('0.00'), findsOneWidget);
  });

  testWidgets('底部导航栏切换页面', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => RecordProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 验证首页元素
    expect(find.text('轻记'), findsOneWidget);

    // 点击统计标签
    final statsTab = find.text(AppStrings.stats);
    expect(statsTab, findsOneWidget);
    await tester.tap(statsTab);
    await tester.pumpAndSettle();

    // 验证统计页标题
    expect(find.text('统计分析'), findsOneWidget);
  });
}
