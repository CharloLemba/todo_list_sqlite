import 'package:flutter/material.dart';
import 'package:todo_list_sqlite/model/model_todo.dart';
import 'package:todo_list_sqlite/database/database_helper.dart';
import 'package:todo_list_sqlite/widget/modal.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: ToDoHomePage());
  }
}

class ToDoHomePage extends StatefulWidget {
  const ToDoHomePage({super.key});

  @override
  State<ToDoHomePage> createState() => _ToDoHomePageState();
}

class _ToDoHomePageState extends State<ToDoHomePage> {
  // Fungsi buat nge-refresh tampilan UI
  void _refreshData() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text("To-Do List SQLite (Modular)"),
        centerTitle: true,
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
                style: TextStyle(fontSize: 16, color: Colors.grey),
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
                        // Tombol Edit (Manggil modal dari file modal.dart)
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.black),
                          onPressed: () {
                            TodoModal.showForm(
                              context,
                              todoItem: item,
                              onSave: (judulBaru, todoBaru) async {
                                // Eksekusi update database
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
                        // Tombol Delete (Manggil dialog hapus dari file modal.dart)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            TodoModal.showDeleteDialog(
                              context,
                              onDelete: () async {
                                // Eksekusi delete database berdasarkan ID
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
              // Eksekusi insert database
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
