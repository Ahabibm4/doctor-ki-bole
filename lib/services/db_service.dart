import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/saved_result.dart';

class DBService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'doctor_ki_bole.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE results (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT,
            input TEXT,
            result TEXT,
            timestamp TEXT
          )
        ''');
      },
    );
  }

  static Future<int> insertResult(SavedResult result) async {
    final db = await database;
    return db.insert('results', result.toMap());
  }

  static Future<List<SavedResult>> getAllResults() async {
    final db = await database;
    final maps = await db.query('results', orderBy: 'timestamp DESC');
    return maps.map((map) => SavedResult.fromMap(map)).toList();
  }

  static Future<int> deleteResult(int id) async {
    final db = await database;
    return db.delete('results', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clearAll() async {
    final db = await database;
    await db.delete('results');
  }
}
