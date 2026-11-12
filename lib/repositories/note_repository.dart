import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/note.dart';
import '../services/secure_storage_service.dart';
import '../utils/logger.dart';

/// Repository untuk seluruh akses data catatan (Repository pattern).
///
/// UI dan provider tidak perlu tahu di mana data disimpan; cukup
/// memanggil [getNotes], [addNote], dan [deleteNote].
///
/// Pembagian penyimpanan:
/// * Metadata (id, judul, tanggal) disimpan di SharedPreferences sebagai
///   JSON list dengan key [metadataKey].
/// * Isi catatan disimpan terenkripsi lewat [SecureStorageService] dengan
///   key `note_content_<id>`.
class NoteRepository {
  /// Key SharedPreferences untuk JSON list metadata catatan.
  static const String metadataKey = 'notes_metadata';

  static const String _tag = 'NoteRepository';

  final SecureStorageService _secureStorage;
  final Future<SharedPreferences> Function() _prefsProvider;

  /// Membuat repository. [secureStorage] dan [prefsProvider] dapat
  /// di-inject untuk pengujian.
  NoteRepository({
    SecureStorageService? secureStorage,
    Future<SharedPreferences> Function()? prefsProvider,
  })  : _secureStorage = secureStorage ?? SecureStorageService(),
        _prefsProvider = prefsProvider ?? SharedPreferences.getInstance;

  /// Mengambil semua catatan, terbaru di urutan teratas.
  ///
  /// Metadata dibaca dari SharedPreferences, lalu isi setiap catatan
  /// dibaca dari secure storage.
  Future<List<Note>> getNotes() async {
    final metadata = await _readMetadata();
    final notes = <Note>[];

    for (final item in metadata) {
      final id = item['id'] as String;
      final content = await _secureStorage.getContent(id) ?? '';
      notes.add(Note.fromMetadataJson(item, content: content));
    }

    notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    Logger.info('Memuat ${notes.length} catatan', tag: _tag);
    return notes;
  }

  /// Menyimpan [note] baru.
  ///
  /// Isi catatan disimpan terlebih dahulu ke secure storage. Jika gagal,
  /// metadata tidak ditulis sehingga tidak ada catatan "tanpa isi".
  Future<void> addNote(Note note) async {
    await _secureStorage.saveContent(note.id, note.content);

    final metadata = await _readMetadata();
    metadata.add(note.toMetadataJson());
    await _writeMetadata(metadata);

    // Hanya id yang dicatat, bukan judul atau isi catatan.
    Logger.info('Catatan disimpan (id: ${note.id})', tag: _tag);
  }

  /// Menghapus catatan dengan id [noteId] beserta isi terenkripsinya.
  Future<void> deleteNote(String noteId) async {
    final metadata = await _readMetadata();
    metadata.removeWhere((item) => item['id'] == noteId);
    await _writeMetadata(metadata);
    await _secureStorage.deleteContent(noteId);

    Logger.info('Catatan dihapus (id: $noteId)', tag: _tag);
  }

  /// Membaca JSON list metadata dari SharedPreferences.
  ///
  /// Jika data rusak (format tidak valid), dikembalikan list kosong agar
  /// aplikasi tidak crash.
  Future<List<Map<String, dynamic>>> _readMetadata() async {
    final prefs = await _prefsProvider();
    final raw = prefs.getString(metadataKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .where((item) => item['id'] is String && item['title'] is String)
          .toList();
    } catch (e) {
      Logger.error('Metadata catatan tidak valid', error: e, tag: _tag);
      return [];
    }
  }

  /// Menulis JSON list metadata ke SharedPreferences.
  Future<void> _writeMetadata(List<Map<String, dynamic>> metadata) async {
    final prefs = await _prefsProvider();
    await prefs.setString(metadataKey, jsonEncode(metadata));
  }
}
