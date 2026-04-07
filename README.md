# 轻记 Qingji - 可爱记账 APP

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.x-00589B?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Platform-Android-green?logo=android" alt="Platform">
  <img src="https://img.shields.io/badge/License-MIT-yellow" alt="License">
</p>

<p align="center">
  <strong>一款清新可爱的暗色模式本地记账 APP</strong><br>
  <em>快速记录日常收支，支持统计分析，数据完全本地存储，保护你的隐私</em>
</p>

---

## ✨ 功能特性

| 功能 | 描述 |
|------|------|
| ⚡ **快速记账** | 3 秒完成一笔记录，支持收入和支出 |
| 🌙 **暗色模式** | 清新薄荷绿配色，护眼舒适 |
| 🔒 **本地存储** | SQLite 本地数据库，数据完全保存在设备本地 |
| 📊 **统计分析** | 直观的柱状图和分类排行，一目了然 |
| 🎨 **可爱 UI** | 金黄色金币图标，高级感暗色设计 |
| 📦 **轻量应用** | 安装包 < 50MB，启动 < 1 秒 |
| 🏷️ **自定义分类** | 支持添加自定义分类，可选择或粘贴 Emoji 图标 |

## 📱 截图展示

> 首页、记账页、统计页、分类管理页

## 🛠️ 技术栈

- **框架**: [Flutter](https://flutter.dev/) 3.x
- **语言**: [Dart](https://dart.dev/) 3.x
- **数据库**: [sqflite](https://pub.dev/packages/sqflite) - SQLite 本地存储
- **状态管理**: [Provider](https://pub.dev/packages/provider) - 响应式状态管理
- **图表**: [fl_chart](https://pub.dev/packages/fl_chart) - 柱状图/饼图
- **路由**: [GoRouter](https://pub.dev/packages/go_router) - 声明式路由

## 📦 项目结构

```
lib/
├── core/                      # 核心配置
│   ├── constants.dart         # 颜色、尺寸、字符串常量
│   └── theme.dart             # 暗色主题配置
├── models/                    # 数据模型
│   ├── record.dart            # 记账记录模型
│   └── category.dart          # 分类模型
├── database/                  # 数据库层
│   └── database_helper.dart   # SQLite CRUD 操作
├── providers/                 # 状态管理
│   ├── record_provider.dart   # 记录状态
│   └── category_provider.dart # 分类状态
├── screens/                   # 页面
│   ├── home/                  # 首页（记录列表+月度总结）
│   ├── add_record/            # 记账页（金额输入+分类选择）
│   ├── stats/                 # 统计页（趋势图+分类排行）
│   └── categories/            # 分类管理页（添加/删除分类）
├── widgets/                   # 通用组件
│   └── bottom_nav.dart        # 底部导航栏
└── utils/                     # 工具类
    ├── date_formatter.dart    # 日期格式化
    └── currency_formatter.dart # 货币格式化
```

## 🚀 快速开始

### 环境要求

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android SDK（用于构建 APK）

### 安装依赖

```bash
cd qingji
flutter pub get
```

### 运行项目

**调试模式（推荐开发时使用）:**
```bash
flutter run
```

**指定设备运行:**
```bash
flutter devices  # 查看可用设备
flutter run -d <设备ID>
```

### 构建 APK

**Release 版本:**
```bash
flutter build apk --release
```

**分架构构建（更小体积）:**
```bash
flutter build apk --release --split-per-abi
```

构建产物位于: `build/app/outputs/flutter-apk/`

### 安装到手机

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

## 🎨 设计规范

### 色彩系统

| 类型 | 颜色 | 十六进制 |
|------|------|----------|
| 主背景 | 深色 | `#0F1419` |
| 次要背景 | 深灰 | `#1A2026` |
| 主色调 | 薄荷绿 | `#4ECDC4` |
| 收入 | 嫩绿色 | `#7BED9F` |
| 支出 | 珊瑚粉 | `#FF6B81` |

### 图标

APP 图标采用可爱金黄色金币风格：
- 圆润造型 + 萌萌表情 + ¥ 符号
- 22% 圆角，符合现代 APP 规范

## 📋 数据库设计

### 记录表 (records)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER | 主键，自增 |
| amount | REAL | 金额 |
| type | TEXT | 类型 (expense/income) |
| category_id | INTEGER | 分类 ID |
| note | TEXT | 备注 (可选) |
| date_time | TEXT | 记录时间 |

### 分类表 (categories)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER | 主键，自增 |
| name | TEXT | 分类名称 |
| icon | TEXT | 图标 Emoji |
| type | TEXT | 类型 (expense/income) |
| is_default | INTEGER | 是否预设分类 |

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 📝 开发计划

- [ ] 数据导出为 CSV/Excel
- [ ] 预算管理（设置月度预算，超支提醒）
- [ ] 多账本切换
- [ ] 定时提醒记账
- [ ] 手势密码/指纹锁
- [ ] 更多图表类型

## 📄 许可证

本项目采用 [MIT License](LICENSE) 开源协议。

## ⭐ 支持

如果这个项目对你有帮助，请给一个 Star，谢谢！

---

<p align="center">
  Made with ❤️ by YanZiBin
</p>
