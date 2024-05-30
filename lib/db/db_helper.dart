import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static const String tableName = 'storage_data_table';

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'dictionary_history.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY,
            text TEXT,
            time TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertData(Map<String, dynamic> data) async {
    final Database db = await database;
    await db.insert(tableName, data);
  }

  Future<List<Map<String, dynamic>>> getData() async {
    final Database db = await database;
    return await db.query(tableName, orderBy: "time DESC");
  }

  Future<void> deleteRecord(int id) async {
    final Database db = await database;
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
