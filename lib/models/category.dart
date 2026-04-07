import 'package:flutter/material.dart';
import '../models/record.dart';

/// 分类模型
class Category {
  final int? id;
  final String name;
  final String icon;
  final RecordType type;
  final bool isDefault;
  final int sortOrder;
  final Color? color;

  Category({
    this.id,
    required this.name,
    required this.icon,
    required this.type,
    this.isDefault = false,
    this.sortOrder = 0,
    this.color,
  });

  /// 从数据库Map创建Category
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      icon: map['icon'] as String,
      type: RecordType.fromDatabaseString(map['type'] as String),
      isDefault: map['is_default'] == 1,
      sortOrder: map['sort_order'] as int,
      color: map['color'] != null
          ? Color(int.parse(map['color'] as String))
          : null,
    );
  }

  /// 转换为数据库Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'type': type.toDatabaseString(),
      'is_default': isDefault ? 1 : 0,
      'sort_order': sortOrder,
      'color': color?.toARGB32().toRadixString(16),
    };
  }

  /// 复制并修改
  Category copyWith({
    int? id,
    String? name,
    String? icon,
    RecordType? type,
    bool? isDefault,
    int? sortOrder,
    Color? color,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
      color: color ?? this.color,
    );
  }
}
