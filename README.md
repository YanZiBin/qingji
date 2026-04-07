# 轻记 - 简洁记账APP

一款清新可爱、护眼暗色模式的本地记账APP，专注于快速记录日常收支。

## 特性

- ⚡ 快速记账 - 3秒完成一笔记录
- 🌙 暗色模式 - 清新薄荷绿配色，护眼舒适
- 🔒 本地存储 - 数据完全保存在设备本地
- 📊 统计分析 - 直观的图表和分类排行
- 🎨 可爱UI - 高级感暗色设计，简洁有质感
- 📦 轻量应用 - 安装包 < 20MB，启动 < 1秒

## 技术栈

- Flutter 3.x
- Dart 3.x
- SQLite (sqflite)
- Provider
- fl_chart

## 开发

```bash
# 安装依赖
flutter pub get

# 运行
flutter run

# 构建APK
flutter build apk --release
```

## 构建产物

- `build/app/outputs/flutter-apk/app-release.apk` - 通用APK
- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` - ARM 64位（推荐）

## 安装

将APK文件传输到安卓手机，点击安装即可。

## License

MIT
