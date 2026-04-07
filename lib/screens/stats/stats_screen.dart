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
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w500 : null,
              color: isSelected ? AppColors.accent : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Consumer<RecordProvider>(
      builder: (context, provider, _) {
        final summary = provider.monthSummary;
        final expense = summary['expense'] ?? 0.0;

        // 计算当月实际天数
        final now = DateTime.now();
        final selectedMonth = provider.selectedMonth;
        final isCurrentMonth =
            selectedMonth.year == now.year && selectedMonth.month == now.month;

        // 如果是当月，使用今天的天数；否则使用当月总天数
        final daysInMonth = DateTime(
          selectedMonth.year,
          selectedMonth.month + 1,
          0,
        ).day;
        final daysToCount = isCurrentMonth ? now.day : daysInMonth;

        // 计算实际记账天数（去重）
        final uniqueDays = provider.records
            .map(
              (r) =>
                  DateTime(r.dateTime.year, r.dateTime.month, r.dateTime.day),
            )
            .toSet()
            .length;

        return Container(
          padding: const EdgeInsets.all(AppDimensions.cardPadding),
          decoration: BoxDecoration(
            gradient: AppColors.accentGradient,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
          ),
          child: Column(
            children: [
              Text(
                '${DateFormatter.yearMonth(provider.selectedMonth)}总支出',
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
                      '日均支出',
                      CurrencyFormatter.format(expense / daysToCount),
                    ),
                  ),
                  Expanded(child: _buildSummaryItem('记账天数', '$uniqueDays 天')),
                ],
              ),
            ],
          ),
        );
      },
    );
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
        if (provider.records.isEmpty) {
          return _buildEmptyChart();
        }

        // 简化的柱状图
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
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _calculateMaxY(provider),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final startDay = _getStartDay(provider);
                          final day = startDay + groupIndex;
                          return BarTooltipItem(
                            '$day 日\n¥${rod.toY.toStringAsFixed(2)}',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final startDay = _getStartDay(provider);
                            final day = startDay + value.toInt();
                            return Text(
                              '$day',
                              style: const TextStyle(
                                fontSize: 11,
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
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: _generateBarGroups(provider),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<BarChartGroupData> _generateBarGroups(RecordProvider provider) {
    // 获取当月天数
    final daysInMonth = DateTime(
      provider.selectedMonth.year,
      provider.selectedMonth.month + 1,
      0,
    ).day;

    // 按日期分组统计支出
    final dailyTotals = <int, double>{};
    for (var i = 1; i <= daysInMonth; i++) {
      dailyTotals[i] = 0.0;
    }

    for (var record in provider.records) {
      if (record.type == RecordType.expense) {
        final day = record.dateTime.day;
        dailyTotals[day] = (dailyTotals[day] ?? 0) + record.amount;
      }
    }

    // 生成柱状图数据（显示最近 7 天）
    final startDay = _getStartDay(provider);
    final daysToShow = daysInMonth > 7 ? 7 : daysInMonth;
    return List.generate(daysToShow, (index) {
      final day = startDay + index;
      final amount = dailyTotals[day] ?? 0.0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: amount,
            gradient: AppColors.accentGradient,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );
    });
  }

  double _calculateMaxY(RecordProvider provider) {
    final daysInMonth = DateTime(
      provider.selectedMonth.year,
      provider.selectedMonth.month + 1,
      0,
    ).day;

    // 按日期汇总
    final dailyTotals = <int, double>{};
    for (var record in provider.records) {
      if (record.type == RecordType.expense) {
        final day = record.dateTime.day;
        dailyTotals[day] = (dailyTotals[day] ?? 0) + record.amount;
      }
    }

    // 只计算最近 7 天的最大值
    final startDay = _getStartDay(provider);
    final daysToShow = daysInMonth > 7 ? 7 : daysInMonth;
    double maxDailyTotal = 0;
    for (var i = 0; i < daysToShow; i++) {
      final day = startDay + i;
      final total = dailyTotals[day] ?? 0;
      if (total > maxDailyTotal) {
        maxDailyTotal = total;
      }
    }

    return maxDailyTotal > 0 ? maxDailyTotal * 1.2 : 100.0;
  }

  int _getStartDay(RecordProvider provider) {
    final daysInMonth = DateTime(
      provider.selectedMonth.year,
      provider.selectedMonth.month + 1,
      0,
    ).day;
    return daysInMonth > 7 ? daysInMonth - 6 : 1;
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
