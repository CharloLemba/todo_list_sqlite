import 'package:flutter/material.dart';
import 'package:todo_list_sqlite/model/model_todo.dart';
import 'package:todo_list_sqlite/database/database_helper.dart';
import 'package:todo_list_sqlite/widget/modal.dart';
import 'package:todo_list_sqlite/database/sp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesHelper.init();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();

  // Helper static untuk mengakses state dari widget di bawahnya jika diperlukan
  static _MainAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MainAppState>();
}

class _MainAppState extends State<MainApp> {
  bool _isDarkTheme = false;

  @override
  void initState() {
    super.initState();
    // Ambil preferensi tema yang tersimpan saat aplikasi pertama kali dibuka
    _isDarkTheme = SharedPreferencesHelper.getBool("isDarkTheme") ?? false;
  }

  // Fungsi untuk mengubah tema secara global
  void toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
      SharedPreferencesHelper.setBool("isDarkTheme", _isDarkTheme);
    });
  }

  bool get isDarkTheme => _isDarkTheme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      home: const ToDoHomePage(),
    );
  }
}

class ToDoHomePage extends StatefulWidget {
  const ToDoHomePage({super.key});

  @override
  State<ToDoHomePage> createState() => _ToDoHomePageState();
}

class _ToDoHomePageState extends State<ToDoHomePage> {
  // Fungsi buat nge-refresh tampilan UI data SQLite
  void _refreshData() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Mengecek status tema saat ini dari MainApp
    final mainAppState = MainApp.of(context);
    final isDark = mainAppState?.isDarkTheme ?? false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text("To-Do List SQLite"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              mainAppState?.toggleTheme();
            },
            icon: Icon(isDark ? Icons.sunny : Icons.nightlight),
          ),
        ],
      ),
      // Mengambil data secara asynchronous dari SQLite
      body: FutureBuilder<List<ToDo>>(
        future: DatabaseHelper.instance.getToDo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada To-Do. Silakan tambah data! 🗿",
                style: TextStyle(fontSize: 20, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          }

          final todoList = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListView.builder(
              itemCount: todoList.length,
              itemBuilder: (context, index) {
                final item = todoList[index];
                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      item.judul,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(item.todo),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tombol Edit
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            TodoModal.showForm(
                              context,
                              todoItem: item,
                              onSave: (judulBaru, todoBaru) async {
                                await DatabaseHelper.instance.updateToDo(
                                  ToDo(
                                    id: item.id,
                                    judul: judulBaru,
                                    todo: todoBaru,
                                  ),
                                );
                                _refreshData();
                              },
                            );
                          },
                        ),
                        const SizedBox(width: 5),
                        // Tombol Delete
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            TodoModal.showDeleteDialog(
                              context,
                              onDelete: () async {
                                await DatabaseHelper.instance.deleteToDo(
                                  item.id!,
                                );
                                _refreshData();
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      // Tombol Tambah Data Baru
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          TodoModal.showForm(
            context,
            onSave: (judulBaru, todoBaru) async {
              await DatabaseHelper.instance.insertToDo(
                ToDo(id: null, judul: judulBaru, todo: todoBaru),
              );
              _refreshData();
            },
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
