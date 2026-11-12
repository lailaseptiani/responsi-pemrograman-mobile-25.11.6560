/// Model data catatan kuliah.
///
/// Sebuah catatan terdiri dari dua bagian yang disimpan di tempat berbeda:
/// * **Metadata** ([id], [title], [createdAt]) disimpan di
///   SharedPreferences melalui [toMetadataJson].
/// * **Isi** ([content]) disimpan terenkripsi di flutter_secure_storage
///   dan **tidak** ikut masuk ke JSON metadata.
class Note {
  /// Id unik catatan, dipakai juga sebagai bagian key secure storage.
  final String id;

  /// Judul catatan.
  final String title;

  /// Isi catatan (data sensitif, tidak boleh dicetak ke log).
  final String content;

  /// Waktu catatan dibuat.
  final DateTime createdAt;

  /// Membuat objek [Note].
  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  /// Membuat catatan baru dengan id dan waktu dibuat otomatis.
  ///
  /// Id dibentuk dari timestamp mikrodetik sehingga unik untuk satu
  /// perangkat.
  factory Note.create({required String title, required String content}) {
    final now = DateTime.now();
    return Note(
      id: now.microsecondsSinceEpoch.toString(),
      title: title,
      content: content,
      createdAt: now,
    );
  }

  /// Mengubah metadata catatan (tanpa isi) menjadi `Map` JSON.
  Map<String, dynamic> toMetadataJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
      };

  /// Membuat [Note] dari metadata JSON dan [content] dari secure storage.
  factory Note.fromMetadataJson(
    Map<String, dynamic> json, {
    String content = '',
  }) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      content: content,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  /// Membuat salinan [Note] dengan field tertentu yang diganti.
  Note copyWith({String? title, String? content}) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
    );
  }

  /// Representasi teks yang aman untuk log: isi catatan tidak disertakan.
  @override
  String toString() => 'Note(id: $id)';
}
