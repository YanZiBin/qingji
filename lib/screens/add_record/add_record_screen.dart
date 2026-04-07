import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/record.dart';
import '../../models/category.dart';
import '../../providers/record_provider.dart';
import '../../providers/category_provider.dart';
import '../../utils/date_formatter.dart';
import '../categories/categories_screen.dart';

/// 记账页
class AddRecordScreen extends StatefulWidget {
  const AddRecordScreen({super.key});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  RecordType _type = RecordType.expense;
  double _amount = 0;
  int? _selectedCategoryId;
  String _note = '';
  DateTime _dateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            AppStrings.cancel,
            style: TextStyle(decoration: TextDecoration.none),
          ),
        ),
        title: const Text(AppStrings.addRecord),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveRecord,
            child: const Text(
              AppStrings.save,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 类型切换
          _buildTypeSwitcher(),
          // 金额显示
          _buildAmountDisplay(),
          // 已选分类
          _buildSelectedCategory(),
          // 备注输入
          _buildNoteInput(),
          // 时间显示
          _buildDateTimeRow(),
          // 分类网格
          Expanded(child: _buildCategoryGrid()),
        ],
      ),
    );
  }

  Widget _buildTypeSwitcher() {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.pagePadding),
      decoration: BoxDecoration(
        color: AppColors.bgTertiary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(child: _buildTypeButton(RecordType.expense)),
          Expanded(child: _buildTypeButton(RecordType.income)),
        ],
      ),
    );
  }

  Widget _buildTypeButton(RecordType type) {
    final isSelected = _type == type;
    return GestureDetector(
      onTap: () => setState(() => _type = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.bgCard : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withAlpha(26), blurRadius: 8)]
              : null,
        ),
        child: Text(
          type == RecordType.expense ? '支出' : '收入',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildAmountDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: TextField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w300),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: '0.00',
        ),
        onChanged: (value) {
          setState(() {
            _amount = double.tryParse(value) ?? 0;
          });
        },
      ),
    );
  }

  Widget _buildSelectedCategory() {
    return Consumer<CategoryProvider>(
      builder: (context, provider, _) {
        final category = provider.categories.firstWhere(
          (c) => c.id == _selectedCategoryId,
          orElse: () => Category(name: '选择分类', icon: '📝', type: _type),
        );

        return GestureDetector(
          onTap: () => _showCategorySelector(context, provider),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.pagePadding,
              vertical: AppDimensions.spacingSmall,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bgTertiary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(category.icon, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(category.name),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCategorySelector(BuildContext context, CategoryProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSecondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部标题
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.bgHover, width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    '选择分类',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      // 切换到对应类型后跳转到分类管理页
                      provider.switchType(_type);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CategoriesScreen(),
                        ),
                      ).then((_) {
                        // 返回后重新加载分类
                        provider.loadCategories();
                      });
                    },
                    child: const Text(
                      '管理',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 类型提示
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: AppColors.bgTertiary,
              child: Text(
                _type == RecordType.expense ? '支出分类' : '收入分类',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            // 分类网格
            Consumer<CategoryProvider>(
              builder: (context, provider, _) {
                final categories = provider.categories
                    .where((c) => c.type == _type)
                    .toList();

                if (categories.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(60),
                    child: Column(
                      children: [
                        const Text('📝', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        const Text(
                          '暂无分类',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            // 切换到对应类型后跳转到分类管理页
                            provider.switchType(_type);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CategoriesScreen(),
                              ),
                            ).then((_) {
                              provider.loadCategories();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.bgTertiary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '去管理',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.accent,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = _selectedCategoryId == category.id;

                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategoryId = category.id);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.bgCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.bgHover,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              category.icon,
                              style: TextStyle(
                                fontSize: 26,
                                color: isSelected ? Colors.white : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePadding,
      ),
      child: TextField(
        decoration: const InputDecoration(
          hintText: '添加备注...',
          border: InputBorder.none,
        ),
        maxLength: 100,
        onChanged: (value) => _note = value,
      ),
    );
  }

  Widget _buildDateTimeRow() {
    return ListTile(
      leading: const Icon(Icons.access_time, size: 20),
      title: const Text('时间'),
      trailing: Text(
        DateFormatter.fullDateTime(_dateTime),
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      onTap: _selectDateTime,
    );
  }

  Widget _buildCategoryGrid() {
    return Consumer<CategoryProvider>(
      builder: (context, provider, _) {
        final categories = provider.categories;
        return GridView.builder(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: AppDimensions.spacingMedium,
            crossAxisSpacing: AppDimensions.spacingMedium,
            childAspectRatio: 0.85,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = _selectedCategoryId == category.id;

            return GestureDetector(
              onTap: () => setState(() => _selectedCategoryId = category.id),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                  border: Border.all(
                    color: isSelected ? AppColors.accent : AppColors.bgHover,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      category.icon,
                      style: TextStyle(
                        fontSize: 24,
                        color: isSelected ? Colors.white : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dateTime),
      );

      if (time != null && mounted) {
        setState(() {
          _dateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveRecord() async {
    // 验证
    if (_amount <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入金额')));
      return;
    }

    if (_selectedCategoryId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请选择分类')));
      return;
    }

    // 保存
    final record = Record(
      amount: _amount,
      type: _type,
      categoryId: _selectedCategoryId!,
      note: _note.isEmpty ? null : _note,
      dateTime: _dateTime,
    );

    final success = await context.read<RecordProvider>().addRecord(record);

    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('保存成功')));
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('保存失败，请重试')));
    }
  }
}
