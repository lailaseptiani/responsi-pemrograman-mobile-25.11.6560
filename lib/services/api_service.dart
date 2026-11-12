import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/post.dart';
import '../utils/logger.dart';

/// Exception API dengan pesan yang aman ditampilkan ke pengguna.
class ApiException implements Exception {
  /// Pesan ramah pengguna (tidak membocorkan detail teknis).
  final String message;

  /// Membuat [ApiException] dengan [message].
  const ApiException(this.message);

  @override
  String toString() => message;
}

/// Service untuk request HTTP ke API publik.
///
/// Base URL dan API key dibaca dari [AppConfig] (file `.env`). Setiap
/// request memakai timeout, dan error jaringan diubah menjadi
/// [ApiException] dengan pesan yang mudah dipahami. Header (termasuk
/// API key) tidak pernah dicetak ke log.
class ApiService {
  static const String _tag = 'ApiService';

  final http.Client _client;
  final String _baseUrl;

  /// Membuat service. [client] dan [baseUrl] dapat di-inject untuk
  /// pengujian.
  ApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.baseUrl;

  /// Mengambil daftar post dari endpoint `/posts`.
  Future<List<Post>> getPosts() async {
    final body = await _get('/posts');
    if (body is! List) {
      throw const ApiException('Format data tidak valid.');
    }
    return body
        .whereType<Map<String, dynamic>>()
        .map(Post.fromJson)
        .toList();
  }

  /// Melakukan request GET ke [endpoint] dan mengembalikan body JSON.
  Future<dynamic> _get(String endpoint) async {
    if (_baseUrl.isEmpty) {
      throw const ApiException(
        'BASE_URL belum diatur. Periksa file .env Anda.',
      );
    }

    try {
      // Yang dicatat hanya endpoint, bukan header atau API key.
      Logger.info('GET $endpoint', tag: _tag);

      final response = await _client
          .get(Uri.parse('$_baseUrl$endpoint'), headers: _buildHeaders())
          .timeout(AppConfig.requestTimeout);

      Logger.debug('Status: ${response.statusCode}', tag: _tag);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw const ApiException('Data tidak ditemukan.');
      } else {
        throw ApiException(
          'Gagal memuat data (status ${response.statusCode}).',
        );
      }
    } on ApiException {
      rethrow;
    } on TimeoutException catch (e) {
      Logger.error('Request timeout', error: e, tag: _tag);
      throw const ApiException(
        'Request timeout. Periksa koneksi internet Anda.',
      );
    } on SocketException catch (e) {
      Logger.error('Tidak ada koneksi', error: e, tag: _tag);
      throw const ApiException(
        'Tidak ada koneksi internet. Periksa jaringan Anda.',
      );
    } on http.ClientException catch (e) {
      Logger.error('Koneksi gagal', error: e, tag: _tag);
      throw const ApiException('Gagal terhubung ke server.');
    } on FormatException catch (e) {
      Logger.error('Format response tidak valid', error: e, tag: _tag);
      throw const ApiException('Format data tidak valid.');
    } catch (e) {
      Logger.error('Error tidak terduga', error: e, tag: _tag);
      throw const ApiException('Terjadi kesalahan. Silakan coba lagi.');
    }
  }

  /// Header request. API key diambil dari `.env`, bukan hardcoded.
  Map<String, String> _buildHeaders() {
    return {
      'Accept': 'application/json',
      'X-API-Key': AppConfig.apiKey,
    };
  }

  /// Menutup HTTP client. Panggil saat service tidak dipakai lagi.
  void dispose() {
    _client.close();
  }
}
