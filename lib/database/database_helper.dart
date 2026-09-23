import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_list_sqlite/model/model_todo.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('todo_list.db');

    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();

    final path = join(dbPath, filePath);

    // Membuka database pada path tersebut, menentukan versi database, dan membuat tabel jika baru pertama kali dipasang
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE todo_list (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            judul TEXT,
            todo TEXT
          )
        ''');
      },
    );
  }

  // Fungsi CREATE (Menambah Data baru ke database)
  Future<int> insertToDo(ToDo todo) async {
    final db = await instance.database;

    return await db.insert(
      'todo_list',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fungsi READ (Mengambil / Membaca Semua Data dari database)
  Future<List<ToDo>> getToDo() async {
    final db = await instance.database;

    final result = await db.query('todo_list');

    return result.map((json) => ToDo.fromMap(json)).toList();
  }

  // Fungsi UPDATE (Mengubah / Memperbarui Data yang sudah ada berdasarkan ID)
  Future<int> updateToDo(ToDo todo) async {
    final db = await instance.database;

    return await db.update(
      'todo_list',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  // Fungsi DELETE (Menghapus Data dari database berdasarkan ID tertentu)
  Future<int> deleteToDo(int id) async {
    final db = await instance.database;

    return await db.delete('todo_list', where: 'id = ?', whereArgs: [id]);
  }
}
