// Membuat sebuah kelas (Blueprint) bernama ToDo untuk menampung data
class ToDo {
  final int? id;
  final String judul;
  final String todo;
  ToDo({required this.id, required this.judul, required this.todo});

  // Fungsi untuk mengubah objek ToDo menjadi bentuk Map (pasangan key-value) agar bisa dibaca oleh sqflite saat Insert/Update
  Map<String, Object?> toMap() {
    return {
      'id': id, // Memasukkan nilai id ke key 'id'
      'judul': judul, // Memasukkan nilai judul ke key 'judul'
      'todo': todo, // Memasukkan nilai todo ke key 'todo'
    };
  }

  // Konstruktor tambahan (Factory) untuk mengubah data dari format Map/Database kembali menjadi bentuk objek ToDo
  factory ToDo.fromMap(Map<String, dynamic> map) {
    return ToDo(
      id: map['id'] as int?,
      judul: map['judul'] as String,
      todo: map['todo'] as String,
    );
  }

  // Override fungsi toString agar saat objek dicetak/di-print ke console, bentuknya terbaca jelas
  @override
  String toString() => 'ToDo{id: $id, judul: $judul, todo: $todo}';
}
