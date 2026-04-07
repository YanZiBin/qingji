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
  
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // 头部
        SliverToBoxAdapter(
          child: _buildHeader(),
        ),
        // 分类网格
        SliverPadding(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: AppDimensions.spacingMedium,
              crossAxisSpacing: AppDimensions.spacingMedium,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final categories = context.watch<CategoryProvider>().categories;
                if (index >= categories.length) {
                  return _buildAddCategoryButton();
                }
                return _buildCategoryItem(categories[index]);
              },
              childCount: context.watch<CategoryProvider>().categories.length + 1,
            ),
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
            child: const Text(
              '点击「编辑」可删除自定义分类\n点击「+」可添加新分类',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
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
        border: Border(
          bottom: BorderSide(color: AppColors.bgHover, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            AppStrings.categoryManagement,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            child: Text(_isEditing ? AppStrings.done : AppStrings.edit),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryItem(Category category) {
    return GestureDetector(
      onLongPress: () {
        if (_isEditing && !category.isDefault) {
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
                Text(
                  category.icon,
                  style: const TextStyle(fontSize: 24),
                ),
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
          if (_isEditing && !category.isDefault)
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
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: Colors.white,
                  ),
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
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
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
    String selectedIcon = '\u{1F4DD}';
    
    final icons = ['\u{1F35C}', '\u{1F68C}', '\u{1F6D2}', '', '\u{1F3E0}', '\u{1F48A}', '\u{1F4DA}', '\u{1F454}', '', '\u{1F4F1}', '\u{1F3CB}\u{FE0F}', '\u{1F4B5}', '', '\u{1F4C8}'];
    
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
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: icons.map((icon) {
                      final isSelected = selectedIcon == icon;
                      return GestureDetector(
                        onTap: () => setState(() => selectedIcon = icon),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.bgTertiary,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.accent : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(icon, style: const TextStyle(fontSize: 22)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;
                  
                  final category = Category(
                    name: name,
                    icon: selectedIcon,
                    type: RecordType.expense,
                    isDefault: false,
                  );
                  
                  await context.read<CategoryProvider>().addCategory(category);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('保存'),
              ),
            ],
          );
        },
      ),
    );
  }
}
