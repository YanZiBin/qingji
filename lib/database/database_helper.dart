import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/record.dart';
import '../models/category.dart';

/// 数据库助手类
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'qingji.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // 创建分类表
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE CHECK(LENGTH(name) <= 10),
        icon TEXT NOT NULL,
        type TEXT NOT NULL CHECK(type IN ('expense', 'income')),
        is_default INTEGER NOT NULL DEFAULT 0,
        sort_order INTEGER NOT NULL DEFAULT 0,
        color TEXT
      )
    ''');

    // 创建记录表
    await db.execute('''
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
      )
    ''');

    // 创建索引
    await db.execute(
      'CREATE INDEX idx_records_date ON records(date_time DESC)',
    );
    await db.execute('CREATE INDEX idx_records_type ON records(type)');
    await db.execute(
      'CREATE INDEX idx_records_category ON records(category_id)',
    );

    // 插入默认分类
    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    // 支出分类
    final expenseCategories = [
      {'name': '餐饮', 'icon': '🍜', 'sortOrder': 1},
      {'name': '交通', 'icon': '🚌', 'sortOrder': 2},
      {'name': '购物', 'icon': '🛒', 'sortOrder': 3},
      {'name': '娱乐', 'icon': '🎮', 'sortOrder': 4},
      {'name': '房租', 'icon': '🏠', 'sortOrder': 5},
      {'name': '医疗', 'icon': '💊', 'sortOrder': 6},
      {'name': '学习', 'icon': '📚', 'sortOrder': 7},
      {'name': '服饰', 'icon': '👔', 'sortOrder': 8},
      {'name': '礼金', 'icon': '🎁', 'sortOrder': 9},
      {'name': '通讯', 'icon': '📱', 'sortOrder': 10},
      {'name': '运动', 'icon': '🏋️', 'sortOrder': 11},
    ];

    for (var cat in expenseCategories) {
      await db.insert('categories', {
        'name': cat['name'],
        'icon': cat['icon'],
        'type': RecordType.expense.toDatabaseString(),
        'is_default': 1,
        'sort_order': cat['sortOrder'],
      });
    }

    // 收入分类
    final incomeCategories = [
      {'name': '工资', 'icon': '💰', 'sortOrder': 1},
      {'name': '兼职', 'icon': '💼', 'sortOrder': 2},
      {'name': '理财', 'icon': '📈', 'sortOrder': 3},
      {'name': '礼金', 'icon': '🎁', 'sortOrder': 4},
      {'name': '其他', 'icon': '💵', 'sortOrder': 5},
    ];

    for (var cat in incomeCategories) {
      await db.insert('categories', {
        'name': cat['name'],
        'icon': cat['icon'],
        'type': RecordType.income.toDatabaseString(),
        'is_default': 1,
        'sort_order': cat['sortOrder'],
      });
    }
  }

  // ========== Category CRUD ==========

  Future<List<Category>> getCategories(RecordType type) async {
    final db = await database;
    final maps = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type.toDatabaseString()],
      orderBy: 'sort_order ASC',
    );

    return maps.map((map) => Category.fromMap(map)).toList();
  }

  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete(
      'categories',
      where: 'id = ? AND is_default = 0',
      whereArgs: [id],
    );
  }

  // ========== Record CRUD ==========

  Future<int> insertRecord(Record record) async {
    final db = await database;
    return await db.insert('records', record.toMap());
  }

  Future<List<Record>> getRecords({
    int limit = 50,
    int offset = 0,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;

    String? where;
    List<dynamic>? whereArgs;

    if (startDate != null && endDate != null) {
      where = 'date_time >= ? AND date_time < ?';
      whereArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
    }

    final maps = await db.query(
      'records',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date_time DESC',
      limit: limit,
      offset: offset,
    );

    // 关联查询分类信息
    final records = <Record>[];
    for (var map in maps) {
      final categoryMaps = await db.query(
        'categories',
        where: 'id = ?',
        whereArgs: [map['category_id']],
      );

      if (categoryMaps.isNotEmpty) {
        records.add(
          Record.fromMap(
            map,
            categoryName: categoryMaps.first['name'] as String,
            categoryIcon: categoryMaps.first['icon'] as String,
          ),
        );
      }
    }

    return records;
  }

  Future<Record?> getRecord(int id) async {
    final db = await database;
    final maps = await db.query('records', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      final map = maps.first;
      final categoryMaps = await db.query(
        'categories',
        where: 'id = ?',
        whereArgs: [map['category_id']],
      );

      return Record.fromMap(
        map,
        categoryName: categoryMaps.first['name'] as String,
        categoryIcon: categoryMaps.first['icon'] as String,
      );
    }

    return null;
  }

  Future<int> updateRecord(Record record) async {
    final db = await database;
    return await db.update(
      'records',
      record.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteRecord(int id) async {
    final db = await database;
    return await db.delete('records', where: 'id = ?', whereArgs: [id]);
  }

  // ========== 统计查询 ==========

  Future<Map<String, double>> getMonthSummary(DateTime month) async {
    final db = await database;
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 1);

    final incomeResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM records WHERE type = ? AND date_time >= ? AND date_time < ?',
      [
        RecordType.income.toDatabaseString(),
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
    );

    final expenseResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM records WHERE type = ? AND date_time >= ? AND date_time < ?',
      [
        RecordType.expense.toDatabaseString(),
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
    );

    return {
      'income': (incomeResult.first['total'] as num?)?.toDouble() ?? 0.0,
      'expense': (expenseResult.first['total'] as num?)?.toDouble() ?? 0.0,
    };
  }

  Future<List<Map<String, dynamic>>> getCategoryStats(
    DateTime month,
    RecordType type,
  ) async {
    final db = await database;
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 1);

    return await db.rawQuery(
      '''
      SELECT c.name, c.icon, SUM(r.amount) as total, COUNT(*) as count
      FROM records r
      JOIN categories c ON r.category_id = c.id
      WHERE r.type = ? AND r.date_time >= ? AND r.date_time < ?
      GROUP BY r.category_id
      ORDER BY total DESC
      ''',
      [
        type.toDatabaseString(),
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> getDailyStats(DateTime month) async {
    final db = await database;
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 1);

    return await db.rawQuery(
      '''
      SELECT DATE(date_time) as date, SUM(amount) as total
      FROM records
      WHERE type = ? AND date_time >= ? AND date_time < ?
      GROUP BY DATE(date_time)
      ORDER BY date ASC
      ''',
      [
        RecordType.expense.toDatabaseString(),
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
