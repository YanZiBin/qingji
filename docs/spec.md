# 记账APP 设计文档

## 1. 应用概述

### 1.1 产品名称
**轻记** - 一款简洁、快速、护眼的本地记账应用

### 1.2 产品定位
面向个人用户的轻量级记账工具，专注于快速记录日常收支，提供清晰的统计分析，所有数据本地存储，保护用户隐私。

### 1.3 核心特性
- ⚡ **快速记账** - 3秒完成一笔记录
- 🌙 **暗色模式** - 清新薄荷绿配色，护眼舒适
- 🔒 **本地存储** - 数据完全保存在设备本地
- 📊 **统计分析** - 直观的图表和分类排行
- 🎨 **可爱UI** - 高级感暗色设计，简洁有质感
- 📦 **轻量应用** - 安装包 < 20MB，启动 < 1秒

### 1.4 目标平台
- Android 8.0+ (API 26+)
- 独立APK安装包，无需网络权限

---

## 2. 技术架构

### 2.1 技术栈

| 层级 | 技术 | 说明 |
|------|------|------|
| **框架** | Flutter 3.x | 跨平台UI框架，编译为原生代码 |
| **语言** | Dart 3.x | 类型安全，空安全 |
| **数据库** | SQLite (sqflite) | 本地轻量级关系数据库 |
| **状态管理** | Provider | 简单高效的响应式状态管理 |
| **图表** | fl_chart | Flutter图表库，支持柱状图/饼图 |
| **本地化** | intl | 国际化支持（中文为主） |
| **路由** | GoRouter | 声明式路由管理 |

### 2.2 项目结构

```
lib/
├── main.dart                    # 应用入口
├── core/                        # 核心配置
│   ├── constants.dart           # 常量定义（颜色、尺寸等）
│   ├── theme.dart               # 主题配置
│   └── routes.dart              # 路由配置
├── models/                      # 数据模型
│   ├── record.dart              # 记账记录模型
│   └── category.dart            # 分类模型
├── database/                    # 数据库层
│   ├── database_helper.dart     # 数据库助手类
│   └── migrations/              # 数据库迁移脚本
├── providers/                   # 状态管理
│   ├── record_provider.dart     # 记录状态
│   ├── category_provider.dart   # 分类状态
│   └── stats_provider.dart      # 统计状态
├── screens/                     # 页面
│   ├── home/                    # 首页
│   │   ├── home_screen.dart
│   │   └── widgets/
│   │       ├── summary_card.dart
│   │       └── record_list.dart
│   ├── add_record/              # 记账页
│   │   ├── add_record_screen.dart
│   │   └── widgets/
│   │       ├── amount_input.dart
│   │       ├── category_picker.dart
│   │       └── custom_keyboard.dart
│   ├── stats/                   # 统计页
│   │   ├── stats_screen.dart
│   │   └── widgets/
│   │       ├── trend_chart.dart
│   │       └── category_ranking.dart
│   └── categories/              # 分类管理页
│       ├── categories_screen.dart
│       └── widgets/
│           ├── category_grid.dart
│           └── add_category_dialog.dart
├── widgets/                     # 通用组件
│   ├── app_bar.dart
│   ├── bottom_nav.dart
│   └── fab_button.dart
└── utils/                       # 工具类
    ├── date_formatter.dart
    ├── currency_formatter.dart
    └── export_helper.dart
```

---

## 3. 数据模型

### 3.1 记账记录 (Record)

```dart
class Record {
  final int? id;              // 主键，自增
  final double amount;        // 金额（精确到分）
  final RecordType type;      // 类型：收入/支出
  final int categoryId;       // 分类ID（外键）
  final String? note;         // 备注（可选，最多100字）
  final DateTime dateTime;    // 记录时间
  final DateTime createdAt;   // 创建时间
  final DateTime updatedAt;   // 更新时间

  // 关联查询字段
  String get categoryName;    // 分类名称
  String get categoryIcon;    // 分类图标emoji
}

enum RecordType {
  expense,  // 支出
  income,   // 收入
}
```

**数据库表结构：**
```sql
CREATE TABLE records (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  amount REAL NOT NULL CHECK(amount > 0),
  type TEXT NOT NULL CHECK(type IN ('expense', 'income')),
  category_id INTEGER NOT NULL,
  note TEXT CHECK(LENGTH(note) <= 100),
  date_time TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);

-- 索引优化查询
CREATE INDEX idx_records_date ON records(date_time DESC);
CREATE INDEX idx_records_type ON records(type);
CREATE INDEX idx_records_category ON records(category_id);
```

### 3.2 分类 (Category)

```dart
class Category {
  final int? id;              // 主键，自增
  final String name;          // 分类名称（最多10字）
  final String icon;          // 图标emoji
  final CategoryType type;    // 类型：收入/支出
  final bool isDefault;       // 是否预设分类（不可删除）
  final int sortOrder;        // 排序顺序
  final Color? color;         // 分类颜色（可选）
}

enum CategoryType {
  expense,  // 支出分类
  income,   // 收入分类
}
```

**数据库表结构：**
```sql
CREATE TABLE categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE CHECK(LENGTH(name) <= 10),
  icon TEXT NOT NULL,
  type TEXT NOT NULL CHECK(type IN ('expense', 'income')),
  is_default INTEGER NOT NULL DEFAULT 0,
  sort_order INTEGER NOT NULL DEFAULT 0,
  color TEXT  -- 可选，十六进制颜色值
);

-- 插入预设支出分类
INSERT INTO categories (name, icon, type, is_default, sort_order) VALUES
  ('餐饮', '🍜', 'expense', 1, 1),
  ('交通', '🚌', 'expense', 1, 2),
  ('购物', '🛒', 'expense', 1, 3),
  ('娱乐', '🎮', 'expense', 1, 4),
  ('房租', '🏠', 'expense', 1, 5),
  ('医疗', '💊', 'expense', 1, 6),
  ('学习', '📚', 'expense', 1, 7),
  ('服饰', '👔', 'expense', 1, 8),
  ('礼金', '🎁', 'expense', 1, 9),
  ('通讯', '📱', 'expense', 1, 10),
  ('运动', '🏋️', 'expense', 1, 11);

-- 插入预设收入分类
INSERT INTO categories (name, icon, type, is_default, sort_order) VALUES
  ('工资', '💰', 'income', 1, 1),
  ('兼职', '💼', 'income', 1, 2),
  ('理财', '📈', 'income', 1, 3),
  ('礼金', '🎁', 'income', 1, 4),
  ('其他', '💵', 'income', 1, 5);
```

---

## 4. UI设计

### 4.1 设计语言

**设计理念：** 清新可爱 + 高级质感 + 护眼暗色

**色彩系统：**

```dart
// 核心颜色
const Color bgPrimary = Color(0xFF0F1419);      // 主背景
const Color bgSecondary = Color(0xFF1A2026);    // 次要背景
const Color bgTertiary = Color(0xFF242B33);     // 第三背景
const Color bgCard = Color(0xFF1E2630);         // 卡片背景
const Color bgHover = Color(0xFF2A3441);        // 悬停背景

const Color textPrimary = Color(0xFFF0F4F8);    // 主文字
const Color textSecondary = Color(0xFFA8B5C4);  // 次要文字
const Color textTertiary = Color(0xFF6B7C8D);   // 辅助文字

const Color accent = Color(0xFF4ECDC4);         // 主色调（薄荷绿）
const Color income = Color(0xFF7BED9F);         // 收入（嫩绿）
const Color expense = Color(0xFFFF6B81);        // 支出（珊瑚粉）

// 渐变
const LinearGradient accentGradient = LinearGradient(
  colors: [Color(0xFF4ECDC4), Color(0xFF44A8B3)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
```

**字体规范：**
- 标题：18-22px, FontWeight.w600
- 正文：15-16px, FontWeight.w400
- 次要：12-14px, FontWeight.w400
- 金额：24-48px, FontWeight.w300（轻量字体突出数字）

**圆角规范：**
- 小圆角：8-10px（按钮、标签）
- 中圆角：12-14px（列表项、输入框）
- 大圆角：16-20px（卡片、弹窗）

**间距规范：**
- 页面边距：20px
- 卡片间距：12-16px
- 列表项间距：14px
- 按钮内边距：14-18px

### 4.2 页面设计

#### 4.2.1 首页 (HomeScreen)

**布局结构：**
```
┌─────────────────────────┐
│ 状态栏                   │
├─────────────────────────┤
│ 我的账本      [2026年4月▼]│
│ ┌─────────┬───────────┐ │
│ │本月收入  │本月支出    │ │
│ │¥8,500   │¥3,280     │ │
│ └─────────┴───────────┘ │
├─────────────────────────┤
│ 最近记录          查看全部 │
│                         │
│ 今天 4月6日      支出¥156│
│ 🍜 餐饮  -¥86           │
│    午餐·同事聚餐         │
│ 🚌 交通  -¥70           │
│    地铁充值              │
│                         │
│ 昨天 4月5日      支出¥245│
│ 🛒 购物  -¥128          │
│ 🎮 娱乐  -¥117          │
│                         │
│              [+ FAB]    │
├─────────────────────────┤
│ 🏠首页  📊统计  🌐分类   │
└─────────────────────────┘
```

**核心功能：**
- 月度收支总览卡片（顶部）
- 按日期分组的记录列表
- 右上角月份选择器
- 右下角FAB快速记账按钮
- 底部导航栏

#### 4.2.2 记账页 (AddRecordScreen)

**布局结构：**
```
┌─────────────────────────┐
│ 取消    记一笔    保存    │
├─────────────────────────┤
│  ┌─────┴──────┐        │
│  │  支出  收入 │        │
│  └────────────┘        │
│                         │
│      86.00              │
│   (大号金额输入)         │
│                         │
│ 🍜 餐饮                 │
│ [添加备注...]            │
│ 时间  2026-04-06 12:30  │
├─────────────────────────┤
│ 选择分类                 │
│ 🍜餐饮 🚌交通 🛒购物 🎮娱乐│
│ 🏠房租 💊医疗 📚学习 👔服饰│
│ 🎁礼金 📱通讯 🏋️运动 ➕添加│
├─────────────────────────┤
│  1   2   3              │
│  4   5   6              │
│  7   8   9              │
│  .   0  [确定]           │
└─────────────────────────┘
```

**交互流程：**
1. 点击FAB进入记账页
2. 默认选中"支出"和当前时间
3. 弹出数字键盘输入金额
4. 选择分类（网格布局）
5. 可选填写备注
6. 点击保存完成记账

#### 4.2.3 统计页 (StatsScreen)

**布局结构：**
```
┌─────────────────────────┐
│ 统计分析                 │
│  [周] [月] [年]         │
├─────────────────────────┤
│   4月总支出              │
│     ¥3,280              │
│ ┌─────────┬───────────┐ │
│ │日均支出  │记账天数    │ │
│ │¥109     │6天        │ │
│ └─────────┴───────────┘ │
├─────────────────────────┤
│ 每日支出趋势             │
│  │  █                    │
│  │ ███  ██              │
│  └─────────────         │
│   1  2  3  4  5  6      │
├─────────────────────────┤
│ 分类排行                 │
│ 🍜 餐饮 ███████░  ¥1240│
│ 🏠 房租 ████░░░░  ¥800 │
│ 🛒 购物 ███░░░░░  ¥580 │
│ 🚌 交通 ██░░░░░░  ¥420 │
│ 🎮 娱乐 █░░░░░░░  ¥240 │
└─────────────────────────┘
```

**统计维度：**
- **时间维度：** 周/月/年切换
- **总览数据：** 总收入、总支出、日均、记账天数
- **趋势图表：** 柱状图展示每日/每周/每月支出趋势
- **分类排行：** 按金额降序排列，显示进度条和百分比

#### 4.2.4 分类管理页 (CategoriesScreen)

**布局结构：**
```
┌─────────────────────────┐
│ 分类管理          [编辑]  │
├─────────────────────────┤
│  ┌─────┴──────┐        │
│  │  支出  收入 │        │
│  └────────────┘        │
├─────────────────────────┤
│ 常用分类          [+]   │
│                         │
│ 🍜餐饮 🚌交通 🛒购物 🎮娱乐│
│ 🏠房租 💊医疗 📚学习 👔服饰│
│ 🎁礼金 📱通讯 🏋️运动 ➕自定义│
│                         │
│ 💡 点击「编辑」可删除      │
│    点击「+」可添加新分类   │
├─────────────────────────┤
│ 🏠首页  📊统计  🌐分类   │
└─────────────────────────┘
```

**功能说明：**
- 默认分类不可删除（is_default = true）
- 用户自定义分类可删除
- 添加分类弹窗：名称输入 + 图标选择
- 编辑模式下显示删除按钮

---

## 5. 功能规格

### 5.1 核心功能

#### F1: 快速记账
- **触发：** 点击首页FAB或底部"+"按钮
- **输入：**
  - 金额（必填，0.01 - 999,999.99）
  - 类型（收入/支出，默认支出）
  - 分类（必填，从分类列表选择）
  - 备注（选填，最多100字）
  - 时间（必填，默认当前时间，可选择历史时间）
- **验证：**
  - 金额必须大于0
  - 必须选择分类
- **输出：** 保存记录，返回首页，显示成功提示
- **性能：** 保存操作 < 100ms

#### F2: 查看记录列表
- **默认排序：** 按时间倒序
- **分组方式：** 按日期分组，显示每日小计
- **显示内容：** 分类图标、分类名称、备注、金额
- **分页：** 初始加载50条，滚动到底部加载更多

#### F3: 月度总览
- **计算范围：** 当前自然月（可切换月份）
- **显示数据：** 本月总收入、本月总支出
- **数据源：** SQLite聚合查询（SUM）

#### F4: 统计分析
- **时间维度：** 周/月/年
- **周视图：** 最近7天每日统计
- **月视图：** 当月每日统计
- **年视图：** 当月月度统计
- **图表类型：** 柱状图（趋势）、进度条（排行）
- **分类排行：** 按金额降序，显示占比百分比

#### F5: 分类管理
- **查看分类：** 支出/收入分类切换
- **添加分类：** 名称 + 图标选择（emoji）
- **删除分类：** 仅用户自定义分类可删除
- **限制：** 分类名称唯一，最多50个自定义分类

### 5.2 辅助功能

#### F6: 月份切换
- 首页顶部月份选择器
- 点击弹出月份选择弹窗
- 可回溯查看历史记录

#### F7: 数据导出（未来扩展）
- 导出格式：CSV
- 导出范围：当前月份所有记录
- 存储位置：设备Downloads文件夹

#### F8: 主题切换（未来扩展）
- 默认：暗色模式（清新薄荷绿）
- 可选：亮色模式、其他配色

---

## 6. 错误处理

### 6.1 数据库错误
- **初始化失败：** 显示错误页面，提示重启应用
- **写入失败：** Toast提示"保存失败，请重试"
- **查询失败：** 显示空状态，提示"加载失败，请重试"

### 6.2 输入验证
- **金额格式错误：** 输入框变红，提示"请输入有效金额"
- **备注超长：** 截断或提示"备注最多100字"
- **未选分类：** 分类区域高亮，提示"请选择分类"

### 6.3 边界情况
- **空数据状态：** 首页显示插画 + "还没有记录，开始记账吧"
- **单月无数据：** 统计页显示"本月暂无记录"
- **删除最后一条记录：** 正常删除，显示空状态

---

## 7. 性能优化

### 7.1 数据库优化
- 使用索引加速日期范围查询
- 聚合查询使用SQL SUM/COUNT而非Dart层计算
- 批量操作使用事务

### 7.2 UI优化
- 列表使用ListView.builder懒加载
- 图片/图标使用缓存
- 避免在build方法中执行重计算

### 7.3 内存管理
- Provider及时dispose
- 避免全局setState，使用细粒度更新
- 大列表分页加载

### 7.4 应用体积
- 目标APK大小：< 20MB
- 使用`flutter build apk --split-per-abi`生成架构特定包
- 仅包含必要依赖

---

## 8. 打包与部署

### 8.1 Android配置

```xml
<!-- AndroidManifest.xml -->
<manifest>
  <!-- 不需要网络权限 -->
  <application
    android:label="轻记"
    android:icon="@mipmap/ic_launcher"
    android:allowBackup="false">
  </application>
</manifest>
```

### 8.2 构建命令

```bash
# 开发调试
flutter run

# 生成Release APK
flutter build apk --release

# 生成架构特定APK（更小体积）
flutter build apk --release --split-per-abi

# 生成AAB（用于Google Play）
flutter build appbundle --release
```

### 8.3 输出产物
- `build/app/outputs/flutter-apk/app-release.apk` - 通用APK
- `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` - ARM 32位
- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` - ARM 64位（推荐）

---

## 9. 原型文件

HTML原型文件位于 `prototype/` 目录：

- `prototype/01-home.html` - 首页原型
- `prototype/02-add-record.html` - 记账页原型
- `prototype/03-stats.html` - 统计页原型
- `prototype/04-categories.html` - 分类管理页原型

所有原型均采用暗色模式 + 清新薄荷绿配色，可在浏览器中直接打开预览。

---

## 10. 开发计划

### Phase 1: 基础框架（1-2天）
- [ ] 初始化Flutter项目
- [ ] 配置主题和颜色系统
- [ ] 创建数据库表和模型
- [ ] 搭建路由和导航

### Phase 2: 核心功能（3-4天）
- [ ] 实现首页布局和记录列表
- [ ] 实现记账页和数字键盘
- [ ] 实现增删改查逻辑
- [ ] 实现分类管理

### Phase 3: 统计分析（2-3天）
- [ ] 集成fl_chart图表库
- [ ] 实现统计查询逻辑
- [ ] 实现趋势图和分类排行

### Phase 4: 优化与测试（2-3天）
- [ ] 动画和交互优化
- [ ] 边界情况处理
- [ ] 真机测试
- [ ] 性能优化

### Phase 5: 打包发布（1天）
- [ ] 应用图标和启动页
- [ ] 生成Release APK
- [ ] 真机安装测试

---

## 11. 未来扩展

- [ ] 数据导出为CSV/Excel
- [ ] 预算管理（设置月度预算，超支提醒）
- [ ] 多账本切换（旅行账本、生意账本）
- [ ] 定时提醒记账
- [ ] 数据备份到云盘
- [ ] 手势密码/指纹锁
- [ ] 亮色模式切换
- [ ] 更多图表类型（饼图、折线图）

---

## 12. 技术规范

### 12.1 代码规范
- 遵循Effective Dart指南
- 使用dart format格式化代码
- 运行dart analyze检查问题
- 所有公开API添加文档注释

### 12.2 命名规范
- 文件名：snake_case
- 类名：PascalCase
- 变量/函数：camelCase
- 常量：camelCase（首字母小写）

### 12.3 Git提交规范
```
feat: 新增XX功能
fix: 修复XX问题
refactor: 重构XX模块
style: 调整UI样式
docs: 更新文档
chore: 依赖更新/配置修改
```

---

**文档版本：** v1.0  
**创建日期：** 2026-04-06  
**最后更新：** 2026-04-06
