import 'package:sqflite/sqflite.dart';
import 'package:sqlite_demo/models/note.dart';

const String tableName = "notes";

class SQLHelper {
  static Future _createTable(Database database) async {
    await database.execute('''
      CREATE TABLE $tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT,
        description TEXT
        );''');
  }

  static Future<Database> _getDatabase() async {
    return openDatabase(
      "Database.db",
      version: 1,
      onCreate: (db, version) async {
        await _createTable(db);
      },
    );
  }

  static void closeDatabase() async {
    final database = await _getDatabase();
    database.isOpen ? database.close() : null;
  }

  static Future<List<Note>?> getAllNotes() async {
    final database = await _getDatabase();
    final List<Map<String, Object?>> maps =
        await database.query(tableName, orderBy: "id");
    if (maps.isEmpty) return null;
    return List.generate(maps.length, (index) => Note.fromJson(maps[index]));
  }

  static Future<int> insertNote(Note note) async {
    final database = await _getDatabase();
    final id = await database.insert(tableName, note.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  static Future<int> updateNote(Note note) async {
    final database = await _getDatabase();
    final result = await database.update(
      tableName,
      note.toJson(),
      where: "id = ?",
      whereArgs: [note.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return result;
  }

  static Future deleteNote(int id) async {
    final database = await _getDatabase();
    try {
      await database.delete(tableName, where: "id=?", whereArgs: [id]);
    } catch (e) {
      print("Something went wrong during deleting an item: $e");
    }
  }
}
