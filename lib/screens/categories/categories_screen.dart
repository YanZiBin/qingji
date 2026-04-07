import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/record.dart';
import '../../models/category.dart';
import '../../providers/category_provider.dart';

/// 分类管理页
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  bool _isEditing = false;
  RecordType _selectedType = RecordType.expense;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // 头部
        SliverToBoxAdapter(child: _buildHeader()),
        // 类型切换
        SliverToBoxAdapter(child: _buildTypeSwitcher()),
        // 分类网格
        SliverPadding(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          sliver: Consumer<CategoryProvider>(
            builder: (context, provider, _) {
              final allCategories = provider.categories;
              // 根据类型过滤
              final categories = allCategories
                  .where((c) => c.type == _selectedType)
                  .toList();

              return SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: AppDimensions.spacingMedium,
                  crossAxisSpacing: AppDimensions.spacingMedium,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index >= categories.length) {
                    return _buildAddCategoryButton();
                  }
                  return _buildCategoryItem(categories[index]);
                }, childCount: categories.length + 1),
              );
            },
          ),
        ),
        // 提示文本
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(AppDimensions.pagePadding),
            padding: const EdgeInsets.all(AppDimensions.spacingMedium),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              border: Border.all(color: AppColors.bgHover, width: 1),
            ),
            child: Consumer<CategoryProvider>(
              builder: (context, provider, _) {
                final allCategories = provider.categories;
                final categories = allCategories
                    .where((c) => c.type == _selectedType)
                    .toList();

                return Column(
                  children: [
                    const Text(
                      '点击「编辑」可删除分类\n点击「+」可添加新分类',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    if (categories.isEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        '💡 暂无分类，点击下方「+」添加',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.accent),
                      ),
                    ],
                  ],
                );
              },
            ),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            AppStrings.categoryManagement,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          TextButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
              overlayColor: Colors.transparent,
            ),
            child: Text(
              _isEditing ? AppStrings.done : AppStrings.edit,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
            ),
          ),
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
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedType = RecordType.expense),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedType == RecordType.expense
                      ? AppColors.bgCard
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusSmall,
                  ),
                ),
                child: Text(
                  '支出',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _selectedType == RecordType.expense
                        ? AppColors.accent
                        : AppColors.textSecondary,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedType = RecordType.income),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedType == RecordType.income
                      ? AppColors.bgCard
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusSmall,
                  ),
                ),
                child: Text(
                  '收入',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _selectedType == RecordType.income
                        ? AppColors.accent
                        : AppColors.textSecondary,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Category category) {
    return GestureDetector(
      onLongPress: () {
        if (_isEditing) {
          _confirmDelete(category);
        }
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(color: AppColors.bgHover, width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(category.icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 8),
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (_isEditing)
            Positioned(
              top: -6,
              right: -6,
              child: GestureDetector(
                onTap: () => _confirmDelete(category),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: AppColors.expense,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddCategoryButton() {
    return GestureDetector(
      onTap: _showAddCategoryDialog,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.textTertiary,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 28, color: AppColors.textSecondary),
            SizedBox(height: 8),
            Text(
              '自定义',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除分类'),
        content: Text('确定要删除「${category.name}」吗？'),
        actions: [
          GestureDetector(
            onTap: () => Navigator.pop(context, false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const Text(
                '取消',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context, true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const Text(
                '删除',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.expense,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<CategoryProvider>().deleteCategory(category.id!);
    }
  }

  Future<void> _showAddCategoryDialog() async {
    final nameController = TextEditingController();
    final emojiController = TextEditingController();
    String selectedIcon = '\u{1F4DD}';
    bool isCustomEmoji = false;

    // 只保留有实际图标的选项，删除空白
    final icons = [
      '\u{1F35C}', // 餐饮
      '\u{1F68C}', // 交通
      '\u{1F6D2}', // 购物
      '\u{1F3E0}', // 房租
      '\u{1F48A}', // 医疗
      '\u{1F4DA}', // 学习
      '\u{1F454}', // 服饰
      '\u{1F3AE}', // 娱乐
      '\u{1F381}', // 礼金
      '\u{1F4F1}', // 通讯
      '\u{1F3CB}\u{FE0F}', // 运动
      '\u{1F4B5}', // 其他
      '\u{1F4BC}', // 兼职
      '\u{1F4C8}', // 理财
    ];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('添加分类'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: '分类名称',
                      hintText: '请输入分类名称',
                    ),
                    maxLength: 10,
                  ),
                  const SizedBox(height: 16),
                  const Text('选择图标'),
                  const SizedBox(height: 8),
                  // 自定义 Emoji 输入框
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: emojiController,
                          decoration: const InputDecoration(
                            hintText: '粘贴自定义 Emoji',
                            prefixIcon: Icon(Icons.emoji_emotions),
                            border: OutlineInputBorder(),
                          ),
                          maxLength: 2,
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              setState(() {
                                selectedIcon = value;
                                isCustomEmoji = true;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '或从下方选择：',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 预设图标网格（已删除空白）
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: icons.map((icon) {
                      final isSelected = selectedIcon == icon && !isCustomEmoji;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIcon = icon;
                            isCustomEmoji = false;
                            emojiController.clear();
                          });
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.bgTertiary,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.accent
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              icon,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  // 显示当前选中的图标
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.bgTertiary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('当前图标：', style: TextStyle(fontSize: 13)),
                        Text(
                          selectedIcon,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: const Text(
                    '取消',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('请输入分类名称')));
                    return;
                  }
                  if (selectedIcon.isEmpty) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('请选择图标')));
                    return;
                  }

                  // 检查是否与现有分类重复
                  final provider = context.read<CategoryProvider>();
                  final existingCategory = provider.categories.firstWhere(
                    (c) => c.name == name,
                    orElse: () =>
                        Category(name: '', icon: '', type: _selectedType),
                  );

                  if (existingCategory.name.isNotEmpty) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('分类「$name」已存在，请使用其他名称')),
                    );
                    return;
                  }

                  final category = Category(
                    name: name,
                    icon: selectedIcon,
                    type: _selectedType,
                  );

                  final success = await provider.addCategory(category);
                  if (!context.mounted) return;

                  if (success) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('添加成功')));
                  } else {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('添加失败，请重试')));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: const Text(
                    '保存',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
