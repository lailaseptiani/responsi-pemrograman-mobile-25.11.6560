import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../utils/logger.dart';

/// Konfigurasi aplikasi yang dimuat dari file `.env`.
///
/// Semua nilai konfigurasi (URL API dan API key) dibaca dari `.env`
/// sehingga tidak ada credential yang ditulis langsung (hardcoded) di
/// kode sumber. File `.env` diabaikan oleh Git melalui `.gitignore`;
/// gunakan `.env.example` sebagai template.
class AppConfig {
  AppConfig._(); // Tidak perlu di-instansiasi.

  static const String _tag = 'AppConfig';

  /// Nama file konfigurasi yang dimuat saat aplikasi dimulai.
  static const String envFileName = '.env';

  /// Batas waktu maksimal untuk setiap request HTTP.
  static const Duration requestTimeout = Duration(seconds: 10);

  /// Memuat file `.env` ke memori.
  ///
  /// Jika file tidak ditemukan atau gagal dibaca, aplikasi tetap berjalan
  /// (fitur profil & catatan tetap bisa dipakai), hanya fitur HTTP yang
  /// akan menampilkan pesan bahwa konfigurasi belum lengkap.
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: envFileName);
      if (isConfigured) {
        Logger.info('Konfigurasi .env berhasil dimuat', tag: _tag);
      } else {
        Logger.warning('Konfigurasi .env belum lengkap', tag: _tag);
      }
    } catch (e) {
      Logger.error('Gagal memuat file .env', error: e, tag: _tag);
    }
  }

  /// Base URL API publik, misalnya `https://jsonplaceholder.typicode.com`.
  static String get baseUrl => _read('BASE_URL');

  /// API key (dummy) yang dikirim lewat header request.
  ///
  /// Nilai ini tidak pernah dicetak ke log.
  static String get apiKey => _read('API_KEY');

  /// Mengembalikan `true` jika `BASE_URL` dan `API_KEY` sudah terisi.
  static bool get isConfigured => baseUrl.isNotEmpty && apiKey.isNotEmpty;

  /// Membaca satu nilai dari `.env` dengan aman.
  ///
  /// Mengembalikan string kosong jika `.env` belum dimuat atau kunci
  /// tidak ditemukan, sehingga tidak terjadi crash.
  static String _read(String key) {
    if (!dotenv.isInitialized) return '';
    return dotenv.env[key]?.trim() ?? '';
  }
}
