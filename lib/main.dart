import 'package:flutter/material.dart';

import 'config/app_config.dart';
import 'config/app_theme.dart';

/// Entry point aplikasi: memuat konfigurasi `.env` lalu menjalankan app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.load();
  runApp(const ResponsiApp());
}

/// Widget root aplikasi Profil Mahasiswa dengan Catatan Kuliah.
class ResponsiApp extends StatelessWidget {
  /// Membuat [ResponsiApp].
  const ResponsiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profil Mahasiswa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const Scaffold(
        body: Center(child: Text('Responsi Profil Mahasiswa')),
      ),
    );
  }
}
