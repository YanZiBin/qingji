# 轻记 Qingji - Agent Guidelines

## 项目概述

Flutter 暗色模式本地记账 APP，支持快速记账、统计分析、分类管理，数据使用 SQLite 本地存储。

## 开发命令

```bash
# 安装依赖
flutter pub get

# 运行项目
flutter run

# 运行测试
flutter test

# 代码分析
flutter analyze

# 代码格式化
dart format .

# 构建 Release APK
flutter build apk --release

# 构建分架构 APK（更小体积）
flutter build apk --release --split-per-abi
```

## 项目结构

```
lib/
├── main.dart                    # 应用入口
├── core/                        # 核心配置
│   ├── constants.dart           # 颜色、尺寸、字符串常量
│   └── theme.dart               # 暗色主题配置
├── models/                      # 数据模型
│   ├── record.dart              # 记账记录模型
│   └── category.dart            # 分类模型
├── database/                    # 数据库层
│   └── database_helper.dart     # SQLite CRUD 操作
├── providers/                   # 状态管理 (Provider)
│   ├── record_provider.dart     # 记录状态
│   └── category_provider.dart   # 分类状态
├── screens/                     # 页面
│   ├── home/                    # 首页（记录列表 + 月度总结）
│   ├── add_record/              # 记账页
│   ├── stats/                   # 统计页（趋势图 + 分类排行）
│   └── categories/              # 分类管理页
├── widgets/                     # 通用组件
│   └── bottom_nav.dart          # 底部导航栏
└── utils/                       # 工具类
    ├── date_formatter.dart      # 日期格式化
    └── currency_formatter.dart  # 货币格式化
```

## 技术栈

- **框架**: Flutter 3.x
- **语言**: Dart 3.x (SDK ^3.11.4)
- **状态管理**: Provider
- **数据库**: sqflite (SQLite)
- **图表**: fl_chart
- **路由**: 直接导航（未使用 GoRouter）
- **国际化**: intl

## 开发规范

### 代码风格

- 文件名：`snake_case`
- 类名：`PascalCase`
- 变量/函数：`camelCase`
- 使用 `dart format` 格式化代码
- 提交前运行 `flutter analyze` 检查问题

### Git 提交规范

```
feat: 新增功能
fix: 修复问题
refactor: 重构
style: 调整 UI 样式
docs: 更新文档
chore: 依赖更新/配置修改
```

## 注意事项

1. **数据完全本地存储** - 不需要网络权限，所有数据保存在 SQLite 本地数据库
2. **暗色模式** - 清新薄荷绿配色 (#4ECDC4)，护眼设计
3. **Provider 状态管理** - 修改状态后及时调用 `notifyListeners()`
4. **数据库操作** - 使用 `DatabaseHelper.instance` 单例，所有 CRUD 都是异步操作
5. **分类管理** - 预设分类 (`is_default=true`) 不可删除，仅用户自定义分类可删除

## 测试

运行所有测试：
```bash
flutter test
```

更新测试后提交：
```bash
git add .
git commit -m "test: 添加/更新 XX 测试"
```

## 相关文件

- `docs/spec.md` - 详细设计文档
- `docs/plan.md` - 实施计划（含任务分解）
- `README.md` - 项目说明
