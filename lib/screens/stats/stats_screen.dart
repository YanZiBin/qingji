import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants.dart';
import '../../models/record.dart';
import '../../providers/record_provider.dart';
import '../../utils/date_formatter.dart';
import '../../utils/currency_formatter.dart';

/// 统计页
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _timeIndex = 1; // 0:周 1:月 2:年

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // 头部
        SliverToBoxAdapter(child: _buildHeader()),
        // 月度总结
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.pagePadding),
            child: _buildSummaryCard(),
          ),
        ),
        // 趋势图
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.pagePadding,
            ),
            child: _buildTrendChart(),
          ),
        ),
        // 分类排行
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.pagePadding),
            child: _buildCategoryRanking(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.pagePadding,
        40,
        AppDimensions.pagePadding,
        AppDimensions.cardPadding,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(bottom: BorderSide(color: AppColors.bgHover, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '统计分析',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgTertiary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _buildTimeTab('周', 0),
                _buildTimeTab('月', 1),
                _buildTimeTab('年', 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTab(String label, int index) {
    final isSelected = _timeIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _timeIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.bgCard : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.accent : AppColors.textSecondary,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Consumer<RecordProvider>(
      builder: (context, provider, _) {
        // 根据时间维度计算数据
        final timeRangeData = _getTimeRangeData(provider);
        final expense = timeRangeData['expense'] ?? 0.0;
        final periodLabel = timeRangeData['label'] as String;
        final periodCount = timeRangeData['count'] as int;
        final uniquePeriods = timeRangeData['uniquePeriods'] as int;

        return Container(
          padding: const EdgeInsets.all(AppDimensions.cardPadding),
          decoration: BoxDecoration(
            gradient: AppColors.accentGradient,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
          ),
          child: Column(
            children: [
              Text(
                periodLabel,
                style: const TextStyle(fontSize: 13, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                CurrencyFormatter.format(expense),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      _getAverageLabel(),
                      CurrencyFormatter.format(
                        _getAverageValue(expense, periodCount),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      _getRecordPeriodsLabel(),
                      '$uniquePeriods ${_getRecordPeriodsUnit()}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, dynamic> _getTimeRangeData(RecordProvider provider) {
    final now = DateTime.now();
    final records = provider.records;

    if (_timeIndex == 0) {
      // 周：计算本周数据
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStartDateTime = DateTime(
        weekStart.year,
        weekStart.month,
        weekStart.day,
      );
      final weekRecords = records
          .where((r) => r.dateTime.isAfter(weekStartDateTime))
          .toList();
      final expense = weekRecords.fold<double>(
        0,
        (sum, r) => r.type == RecordType.expense ? sum + r.amount : sum,
      );
      final uniqueDays = weekRecords
          .map(
            (r) => DateTime(r.dateTime.year, r.dateTime.month, r.dateTime.day),
          )
          .toSet()
          .length;

      return {
        'expense': expense,
        'label': '本周总支出',
        'count': 7,
        'uniquePeriods': uniqueDays,
      };
    } else if (_timeIndex == 1) {
      // 月：计算本月数据
      final summary = provider.monthSummary;
      final expense = summary['expense'] ?? 0.0;
      final selectedMonth = provider.selectedMonth;
      final isCurrentMonth =
          selectedMonth.year == now.year && selectedMonth.month == now.month;
      final daysInMonth = DateTime(
        selectedMonth.year,
        selectedMonth.month + 1,
        0,
      ).day;
      final daysToCount = isCurrentMonth ? now.day : daysInMonth;
      final uniqueDays = records
          .map(
            (r) => DateTime(r.dateTime.year, r.dateTime.month, r.dateTime.day),
          )
          .toSet()
          .length;

      return {
        'expense': expense,
        'label': '${DateFormatter.yearMonth(selectedMonth)}总支出',
        'count': daysToCount,
        'uniquePeriods': uniqueDays,
      };
    } else {
      // 年：计算本年数据
      final yearStart = DateTime(now.year, 1, 1);
      final yearRecords = records
          .where((r) => r.dateTime.isAfter(yearStart))
          .toList();
      final expense = yearRecords.fold<double>(
        0,
        (sum, r) => r.type == RecordType.expense ? sum + r.amount : sum,
      );
      final uniqueMonths = yearRecords
          .map((r) => DateTime(r.dateTime.year, r.dateTime.month))
          .toSet()
          .length;

      return {
        'expense': expense,
        'label': '${now.year}年总支出',
        'count': now.month,
        'uniquePeriods': uniqueMonths,
      };
    }
  }

  String _getAverageLabel() {
    if (_timeIndex == 0) return '日均支出';
    if (_timeIndex == 1) return '日均支出';
    return '月均支出';
  }

  double _getAverageValue(double expense, int periodCount) {
    return periodCount > 0 ? expense / periodCount : 0;
  }

  String _getRecordPeriodsLabel() {
    if (_timeIndex == 0) return '记账天数';
    if (_timeIndex == 1) return '记账天数';
    return '记账月数';
  }

  String _getRecordPeriodsUnit() {
    if (_timeIndex == 0) return '天';
    if (_timeIndex == 1) return '天';
    return '月';
  }

  Widget _buildSummaryItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart() {
    return Consumer<RecordProvider>(
      builder: (context, provider, _) {
        final chartData = _getChartData(provider);
        if (chartData['spots'] == null ||
            (chartData['spots'] as List).isEmpty) {
          return _buildEmptyChart();
        }

        // 折线图
        return Container(
          padding: const EdgeInsets.all(AppDimensions.cardPadding),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(color: AppColors.bgHover, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '支出趋势',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: (chartData['maxY'] as double) / 4,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(color: AppColors.bgHover, strokeWidth: 1);
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: chartData['labelInterval'] as double,
                          getTitlesWidget: (value, meta) {
                            final label = _getXAxisLabel(value.toInt());
                            return Text(
                              label,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: chartData['maxX'] as double,
                    minY: 0,
                    maxY: chartData['maxY'] as double,
                    lineBarsData: [
                      LineChartBarData(
                        spots: chartData['spots'] as List<FlSpot>,
                        isCurved: true,
                        color: AppColors.accent,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.accent.withOpacity(0.3),
                              AppColors.accent.withOpacity(0.05),
                            ],
                          ),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final label = _getTooltipLabel(spot.x.toInt());
                            return LineTooltipItem(
                              '$label\n¥${spot.y.toStringAsFixed(2)}',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, dynamic> _getChartData(RecordProvider provider) {
    final now = DateTime.now();
    final records = provider.records;
    List<FlSpot> spots = [];
    double maxY = 100;
    double maxX = 0;
    double labelInterval = 1;

    if (_timeIndex == 0) {
      // 周：显示本周 7 天的数据
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStartDateTime = DateTime(
        weekStart.year,
        weekStart.month,
        weekStart.day,
      );

      final dailyTotals = <int, double>{};
      for (var i = 0; i < 7; i++) {
        dailyTotals[i] = 0.0;
      }

      for (var record in records) {
        if (record.dateTime.isAfter(weekStartDateTime) &&
            record.type == RecordType.expense) {
          final dayIndex = record.dateTime.difference(weekStartDateTime).inDays;
          dailyTotals[dayIndex] = (dailyTotals[dayIndex] ?? 0) + record.amount;
        }
      }

      spots = List.generate(
        7,
        (i) => FlSpot(i.toDouble(), dailyTotals[i] ?? 0.0),
      );
      maxY = dailyTotals.values.reduce((a, b) => a > b ? a : b);
      maxX = 6;
      labelInterval = 1;
    } else if (_timeIndex == 1) {
      // 月：显示当月每天的数据
      final daysInMonth = DateTime(
        provider.selectedMonth.year,
        provider.selectedMonth.month + 1,
        0,
      ).day;

      final dailyTotals = <int, double>{};
      for (var i = 1; i <= daysInMonth; i++) {
        dailyTotals[i] = 0.0;
      }

      for (var record in records) {
        if (record.type == RecordType.expense) {
          dailyTotals[record.dateTime.day] =
              (dailyTotals[record.dateTime.day] ?? 0) + record.amount;
        }
      }

      spots = List.generate(
        daysInMonth,
        (i) => FlSpot(i.toDouble(), dailyTotals[i + 1] ?? 0.0),
      );
      maxX = daysInMonth - 1;
      labelInterval = daysInMonth <= 10 ? 2 : (daysInMonth <= 20 ? 5 : 10);
    } else {
      // 年：显示 12 个月的数据
      final monthlyTotals = <int, double>{};
      for (var i = 1; i <= 12; i++) {
        monthlyTotals[i] = 0.0;
      }

      final yearStart = DateTime(now.year, 1, 1);
      for (var record in records) {
        if (record.dateTime.isAfter(yearStart) &&
            record.type == RecordType.expense) {
          final month = record.dateTime.month;
          monthlyTotals[month] = (monthlyTotals[month] ?? 0) + record.amount;
        }
      }

      spots = List.generate(
        12,
        (i) => FlSpot(i.toDouble(), monthlyTotals[i + 1] ?? 0.0),
      );
      maxX = 11;
      labelInterval = 2;
    }

    maxY = maxY > 0 ? maxY * 1.2 : 100;

    return {
      'spots': spots,
      'maxY': maxY,
      'maxX': maxX,
      'labelInterval': labelInterval,
    };
  }

  String _getXAxisLabel(int value) {
    if (_timeIndex == 0) {
      // 周：显示周一到周日
      const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
      return '周${weekdays[value]}';
    } else if (_timeIndex == 1) {
      // 月：显示日期
      return '$value';
    } else {
      // 年：显示月份
      return '${value + 1}月';
    }
  }

  String _getTooltipLabel(int value) {
    if (_timeIndex == 0) {
      const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      return weekdays[value];
    } else if (_timeIndex == 1) {
      return '${value + 1}日';
    } else {
      return '${value + 1}月';
    }
  }

  Widget _buildEmptyChart() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.bgHover, width: 1),
      ),
      child: const Center(child: Text('本月暂无记录')),
    );
  }

  Widget _buildCategoryRanking() {
    return Consumer<RecordProvider>(
      builder: (context, provider, _) {
        if (provider.records.isEmpty) {
          return const SizedBox.shrink();
        }

        // 按分类汇总
        final categoryTotals = <String, double>{};
        for (var record in provider.records) {
          if (record.type == RecordType.expense) {
            final key = '${record.categoryIcon} ${record.categoryName}';
            categoryTotals[key] = (categoryTotals[key] ?? 0) + record.amount;
          }
        }

        final sortedCategories = categoryTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        final totalExpense = categoryTotals.values.fold<double>(
          0,
          (sum, val) => sum + val,
        );

        return Container(
          padding: const EdgeInsets.all(AppDimensions.cardPadding),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(color: AppColors.bgHover, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '分类排行',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              ...sortedCategories.take(5).map((entry) {
                final percent = totalExpense > 0
                    ? (entry.value / totalExpense * 100).toInt()
                    : 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: percent / 100.0,
                            backgroundColor: AppColors.bgTertiary,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.accent,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 80,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              CurrencyFormatter.format(entry.value),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '$percent%',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
