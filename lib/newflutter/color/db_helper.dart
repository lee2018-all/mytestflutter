import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TypeBean {
  final int? id;
  final String tradeno;
  final int img;
  final String usercode;

  TypeBean({
    this.id,
    required this.tradeno,
    required this.img,
    required this.usercode,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tradeno': tradeno,
      'img': img,
      'usercode': usercode,
    };
  }

  factory TypeBean.fromMap(Map<String, dynamic> map) {
    return TypeBean(
      id: map['id'],
      tradeno: map['tradeno'] ?? '',
      img: map['img'] ?? 0,
      usercode: map['usercode'] ?? '',
    );
  }
}

class DbHelper {
  static Database? _database;
  static const String _dbName = 'lcm.db';
  static const int _version = 1;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 创建表，字段名与 Android 保持一致
    await db.execute('''
      CREATE TABLE typetb(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tradeno TEXT,
        img INTEGER,
        usercode TEXT
      )
    ''');
  }

  /// 根据用户代码获取颜色列表
  Future<List<TypeBean>> getUserList(String usercode) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'typetb',
      where: 'usercode = ?',
      whereArgs: [usercode],
    );
    return List.generate(maps.length, (i) => TypeBean.fromMap(maps[i]));
  }

  /// 根据用户代码和颜色获取列表
  Future<List<TypeBean>> getUserAndColorList(String usercode, int img) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'typetb',
      where: 'usercode = ? AND img = ?',
      whereArgs: [usercode, img],
    );
    return List.generate(maps.length, (i) => TypeBean.fromMap(maps[i]));
  }

  /// 添加颜色
  Future<void> add(String tradeno, String usercode, int img) async {
    final db = await database;
    await db.insert(
      'typetb',
      {
        'tradeno': tradeno,
        'img': img,
        'usercode': usercode,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 更新颜色
  Future<void> update(String tradeno, String usercode, int img) async {
    final db = await database;
    await db.update(
      'typetb',
      {'img': img},
      where: 'tradeno = ? AND usercode = ?',
      whereArgs: [tradeno, usercode],
    );
  }

  /// 根据交易号删除
  Future<void> deleteByTradeNo(String tradeno) async {
    final db = await database;
    await db.delete(
      'typetb',
      where: 'tradeno = ?',
      whereArgs: [tradeno],
    );
  }

  /// 根据用户代码删除
  Future<void> deleteByUserCode(String usercode) async {
    final db = await database;
    await db.delete(
      'typetb',
      where: 'usercode = ?',
      whereArgs: [usercode],
    );
  }
}