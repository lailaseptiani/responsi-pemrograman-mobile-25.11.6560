import 'package:flutter/material.dart';

import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';

/// Entry point aplikasi.
///
/// Memuat konfigurasi dari `.env`, lalu menjalankan aplikasi dengan
/// [AppProviderWrapper] di posisi paling atas agar semua halaman
/// (termasuk halaman hasil `Navigator.push`) dapat mengakses state.
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
    return AppProviderWrapper(
      child: MaterialApp(
        title: 'Profil Mahasiswa',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomeScreen(),
      ),
    );
  }
}
