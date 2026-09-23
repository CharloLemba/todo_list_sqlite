import 'package:flutter/material.dart';
import 'package:todo_list_sqlite/model/model_todo.dart';

class TodoModal {
  /*
   MODAL FORM TAMBAH / EDIT TO-DO
  */
  static void showForm(
    BuildContext context, {
    ToDo? todoItem,
    required Function(String judul, String todo) onSave,
  }) {
    // Controller untuk mengambil text dari TextField Judul dan Todo
    final TextEditingController judulController = TextEditingController(
      text: todoItem != null ? todoItem.judul : '',
    );
    final TextEditingController deskripsiController = TextEditingController(
      text: todoItem != null ? todoItem.todo : '',
    );

    // Menampilkan Modal Bottom Sheet
    showModalBottomSheet(
      context: context,
      isDismissible: false, // Sentuhan di luar modal tidak diizinkan
      enableDrag: false, // Modal tidak bisa digeser ke bawah
      isScrollControlled: true, // Menyesuaikan ukuran keyboard HP
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul Modal Dinamis (Tambah atau Edit)
              Text(
                todoItem == null ? 'Tambah To-Do Baru' : 'Edit To-Do',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              // TextField untuk Judul
              TextField(
                controller: judulController,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              // TextField untuk isi To-Do
              TextField(
                controller: deskripsiController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Isi To-Do',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              // Tombol Simpan dan Batal
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Tombol Batal
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Batal',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Tombol Simpan
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () {
                      if (judulController.text.isNotEmpty &&
                          deskripsiController.text.isNotEmpty) {
                        // Mengirim data kembali ke main.dart lewat fungsi onSave
                        onSave(judulController.text, deskripsiController.text);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      'Simpan',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  /*
   DIALOG KONFIRMASI HAPUS
  */
  static void showDeleteDialog(
    BuildContext context, {
    required VoidCallback onDelete,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false, // Sentuhan di luar dialog tidak diizinkan
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Yakin ingin menghapus todo ini?'),
          actions: [
            // Tombol Batal
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            // Tombol Hapus
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                // Menjalankan perintah hapus yang dikirim dari main.dart
                onDelete();
                Navigator.pop(context);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
