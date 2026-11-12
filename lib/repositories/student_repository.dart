import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/student.dart';
import '../utils/logger.dart';

/// Repository untuk menyimpan dan membaca profil mahasiswa.
///
/// Profil disimpan di SharedPreferences sebagai JSON agar perubahan
/// profil tetap ada setelah aplikasi ditutup.
class StudentRepository {
  /// Key SharedPreferences untuk data profil.
  static const String profileKey = 'student_profile';

  static const String _tag = 'StudentRepository';

  final Future<SharedPreferences> Function() _prefsProvider;

  /// Membuat repository. [prefsProvider] dapat di-inject untuk pengujian.
  StudentRepository({Future<SharedPreferences> Function()? prefsProvider})
      : _prefsProvider = prefsProvider ?? SharedPreferences.getInstance;

  /// Membaca profil tersimpan, atau [Student.initial] jika belum ada.
  Future<Student> getStudent() async {
    final prefs = await _prefsProvider();
    final raw = prefs.getString(profileKey);
    if (raw == null || raw.isEmpty) return Student.initial;

    try {
      return Student.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      Logger.error('Data profil tidak valid', error: e, tag: _tag);
      return Student.initial;
    }
  }

  /// Menyimpan [student] ke SharedPreferences.
  Future<void> saveStudent(Student student) async {
    final prefs = await _prefsProvider();
    await prefs.setString(profileKey, jsonEncode(student.toJson()));
    Logger.info('Profil disimpan', tag: _tag);
  }
}
