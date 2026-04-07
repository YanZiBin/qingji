import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/record_provider.dart';
import '../../providers/category_provider.dart';
import '../../utils/date_formatter.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/bottom_nav.dart';
import '../add_record/add_record_screen.dart';
import '../stats/stats_screen.dart';
import '../categories/categories_screen.dart';
import '../../models/record.dart';

/// 首页
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _HomeContent(),
    StatsScreen(),
    CategoriesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final recordProvider = context.read<RecordProvider>();
    final categoryProvider = context.read<CategoryProvider>();
    await recordProvider.loadMonthRecords(DateTime.now());
    if (mounted) {
      await categoryProvider.loadCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddRecordScreen()),
          ).then((_) => _loadData());
        },
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

/// 首页内容
class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // 顶部头部
        SliverToBoxAdapter(child: _buildHeader(context)),
        // 月度总结
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.pagePadding),
            child: _buildMonthSummary(context),
          ),
        ),
        // 记录列表标题
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.pagePadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '最近记录',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                TextButton(onPressed: () {}, child: const Text('查看全部')),
              ],
            ),
          ),
        ),
        // 记录列表
        const _RecordList(),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            AppStrings.appName,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          GestureDetector(
            onTap: () => _showMonthPicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bgTertiary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Consumer<RecordProvider>(
                    builder: (context, provider, _) {
                      return Text(
                        DateFormatter.yearMonth(provider.selectedMonth),
                        style: const TextStyle(fontSize: 14),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSummary(BuildContext context) {
    return Consumer<RecordProvider>(
      builder: (context, provider, _) {
        final summary = provider.monthSummary;
        return Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                label: '本月收入',
                amount: summary['income'] ?? 0.0,
                color: AppColors.income,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              child: _buildSummaryCard(
                label: '本月支出',
                amount: summary['expense'] ?? 0.0,
                color: AppColors.expense,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required double amount,
    required Color color,
  }) {
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            CurrencyFormatter.format(amount),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showMonthPicker(BuildContext context) {
    final recordProvider = context.read<RecordProvider>();
    final currentDate = recordProvider.selectedMonth;

    showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
    ).then((date) {
      if (date != null) {
        recordProvider.changeMonth(date);
      }
    });
  }
}

/// 记录列表
class _RecordList extends StatelessWidget {
  const _RecordList();

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.records.isEmpty) {
          return const SliverToBoxAdapter(child: _EmptyState());
        }

        // 按日期分组
        final groupedRecords = <String, List<Record>>{};
        for (var record in provider.records) {
          final dateKey = DateFormatter.dateGroupLabel(record.dateTime);
          groupedRecords.putIfAbsent(dateKey, () => []);
          groupedRecords[dateKey]!.add(record);
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final dates = groupedRecords.keys.toList();
            if (index >= dates.length) return null;

            final date = dates[index];
            final records = groupedRecords[date]!;

            return _buildDateGroup(date, records);
          }),
        );
      },
    );
  }

  Widget _buildDateGroup(String date, List<Record> records) {
    double dailyTotal = 0;
    for (var record in records) {
      if (record.type == RecordType.expense) {
        dailyTotal += record.amount;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pagePadding,
            vertical: AppDimensions.spacingSmall,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '支出 ${CurrencyFormatter.format(dailyTotal)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.expense,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        ...records.map((record) => _buildRecordItem(record)),
      ],
    );
  }

  Widget _buildRecordItem(Record record) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePadding,
        vertical: 4,
      ),
      leading: Container(
        width: AppDimensions.iconLarge,
        height: AppDimensions.iconLarge,
        decoration: BoxDecoration(
          color: AppColors.bgTertiary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: Center(
          child: Text(
            record.categoryIcon ?? '\u{1F4DD}',
            style: const TextStyle(fontSize: AppDimensions.iconMedium),
          ),
        ),
      ),
      title: Text(
        record.categoryName ?? '未知',
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: record.note != null
          ? Text(
              record.note!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            )
          : null,
      trailing: Text(
        record.type == RecordType.expense
            ? '-${CurrencyFormatter.format(record.amount)}'
            : '+${CurrencyFormatter.format(record.amount)}',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: record.type == RecordType.expense
              ? AppColors.expense
              : AppColors.income,
        ),
      ),
    );
  }
}

/// 空状态
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const Text('\u{1F4DD}', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            '还没有记录',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          const Text(
            '点击下方 + 开始记账吧',
            style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
