/// 记录类型枚举
enum RecordType {
  expense,
  income;

  String toDatabaseString() => name;

  static RecordType fromDatabaseString(String value) {
    return RecordType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => RecordType.expense,
    );
  }
}

/// 记账记录模型
class Record {
  final int? id;
  final double amount;
  final RecordType type;
  final int categoryId;
  final String? note;
  final DateTime dateTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 关联数据（非数据库字段）
  final String? categoryName;
  final String? categoryIcon;

  Record({
    this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    this.note,
    required this.dateTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.categoryName,
    this.categoryIcon,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// 从数据库Map创建Record
  factory Record.fromMap(
    Map<String, dynamic> map, {
    String? categoryName,
    String? categoryIcon,
  }) {
    return Record(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      type: RecordType.fromDatabaseString(map['type'] as String),
      categoryId: map['category_id'] as int,
      note: map['note'] as String?,
      dateTime: DateTime.parse(map['date_time'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      categoryName: categoryName,
      categoryIcon: categoryIcon,
    );
  }

  /// 转换为数据库Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type.toDatabaseString(),
      'category_id': categoryId,
      'note': note,
      'date_time': dateTime.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 复制并修改
  Record copyWith({
    int? id,
    double? amount,
    RecordType? type,
    int? categoryId,
    String? note,
    DateTime? dateTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? categoryName,
    String? categoryIcon,
  }) {
    return Record(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      dateTime: dateTime ?? this.dateTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
    );
  }
}
