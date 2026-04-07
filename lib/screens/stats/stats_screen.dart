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
                      horizontalInterval: _calculateMaxY(provider) / 4,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(color: AppColors.bgHover, strokeWidth: 1);
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: _getLabelInterval(provider),
                          getTitlesWidget: (value, meta) {
                            final day = value.toInt() + 1;
                            return Text(
                              '$day',
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
                    maxX: _getMaxX(provider).toDouble(),
                    minY: 0,
                    maxY: _calculateMaxY(provider),
                    lineBarsData: _generateLineBars(provider),
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final day = spot.x.toInt() + 1;
                            return LineTooltipItem(
                              '$day 日\n¥${spot.y.toStringAsFixed(2)}',
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

  int _getMaxX(RecordProvider provider) {
    final daysInMonth = DateTime(
      provider.selectedMonth.year,
      provider.selectedMonth.month + 1,
      0,
    ).day;
    return daysInMonth - 1;
  }

  double _getLabelInterval(RecordProvider provider) {
    final daysInMonth = DateTime(
      provider.selectedMonth.year,
      provider.selectedMonth.month + 1,
      0,
    ).day;
    if (daysInMonth <= 10) return 2;
    if (daysInMonth <= 20) return 5;
    return 10;
  }

  List<LineChartBarData> _generateLineBars(RecordProvider provider) {
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

    // 生成折线图数据点
    final spots = <FlSpot>[];
    for (var day = 1; day <= daysInMonth; day++) {
      spots.add(FlSpot((day - 1).toDouble(), dailyTotals[day] ?? 0.0));
    }

    return [
      LineChartBarData(
        spots: spots,
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
    ];
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
