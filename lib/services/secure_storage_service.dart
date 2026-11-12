import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service untuk menyimpan isi catatan secara terenkripsi.
///
/// Menggunakan `flutter_secure_storage`, yang di Android memakai
/// EncryptedSharedPreferences (kunci di Android Keystore) dan di iOS
/// memakai Keychain. Setiap isi catatan disimpan dengan key
/// `note_content_<id>`.
///
/// Service ini sengaja tidak melakukan logging apa pun agar isi catatan
/// tidak mungkin tercetak ke log.
class SecureStorageService {
  /// Prefix key untuk isi catatan.
  static const String noteContentPrefix = 'note_content_';

  final FlutterSecureStorage _storage;

  /// Membuat service. [storage] dapat di-inject (misalnya mock) saat
  /// pengujian.
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  /// Menghasilkan key secure storage untuk catatan dengan [noteId].
  ///
  /// Contoh: id `123` menghasilkan key `note_content_123`.
  static String keyFor(String noteId) => '$noteContentPrefix$noteId';

  /// Menyimpan [content] catatan dengan id [noteId] secara terenkripsi.
  ///
  /// Jika key sudah ada, nilainya akan ditimpa.
  Future<void> saveContent(String noteId, String content) {
    return _storage.write(key: keyFor(noteId), value: content);
  }

  /// Membaca isi catatan dengan id [noteId].
  ///
  /// Mengembalikan `null` jika isi catatan tidak ditemukan.
  Future<String?> getContent(String noteId) {
    return _storage.read(key: keyFor(noteId));
  }

  /// Menghapus isi catatan dengan id [noteId] dari secure storage.
  Future<void> deleteContent(String noteId) {
    return _storage.delete(key: keyFor(noteId));
  }
}
