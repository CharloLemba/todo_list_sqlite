import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_list_sqlite/model/model_todo.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  // Membuat database dengan nama 'todo_list.db'
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('todo_list.db');
    return _database!;
  }

  // Membuka database pada path, menentukan versi database, dan membuat tabel jika baru pertama kali dipasang
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
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

  // Fungsi CREATE (Menambah Data baru ke database dengan SQL Murni)
  Future<int> insertToDo(ToDo todo) async {
    final db = await instance.database;
    // Menggunakan rawInsert dengan placeholder '?' untuk keamanan terhadap SQL Injection
    return await db.rawInsert(
      'INSERT INTO todo_list (judul, todo) VALUES (?, ?)',
      [todo.judul, todo.todo],
    );
  }

  // Fungsi READ (Mengambil / Membaca Semua Data dari database dengan SQL Murni)
  Future<List<ToDo>> getToDo() async {
    final db = await instance.database;
    // Menggunakan rawQuery untuk SELECT semua data
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT * FROM todo_list',
    );
    return result.map((json) => ToDo.fromMap(json)).toList();
  }

  // Fungsi UPDATE (Mengubah / Memperbarui Data berdasarkan ID dengan SQL Murni)
  Future<int> updateToDo(ToDo todo) async {
    final db = await instance.database;
    // Menggunakan rawUpdate
    return await db.rawUpdate(
      'UPDATE todo_list SET judul = ?, todo = ? WHERE id = ?',
      [todo.judul, todo.todo, todo.id],
    );
  }

  // Fungsi DELETE (Menghapus Data dari database berdasarkan ID tertentu dengan SQL Murni)
  Future<int> deleteToDo(int id) async {
    final db = await instance.database;
    // Menggunakan rawDelete
    return await db.rawDelete('DELETE FROM todo_list WHERE id = ?', [id]);
  }
}
