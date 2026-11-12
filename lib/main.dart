import 'package:flutter/material.dart';

void main() {
  runApp(const ResponsiApp());
}

/// Widget root aplikasi Profil Mahasiswa dengan Catatan Kuliah.
class ResponsiApp extends StatelessWidget {
  /// Membuat [ResponsiApp].
  const ResponsiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Profil Mahasiswa',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: Text('Responsi Profil Mahasiswa')),
      ),
    );
  }
}
