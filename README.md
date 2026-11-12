# Responsi Profil Mahasiswa

Aplikasi Flutter **Profil Mahasiswa dengan Catatan Kuliah** untuk Responsi
Pemrograman Mobile (materi pertemuan 1–6).

## Fitur

- **Profil Mahasiswa**: menampilkan nama, NIM, program studi, email, dan
  foto berupa inisial (`CircleAvatar`). Profil dapat diedit dengan validasi.
- **Catatan Kuliah**: tambah, lihat, dan hapus catatan (dengan dialog
  konfirmasi). Judul 3–50 karakter, isi 10–1000 karakter, input disanitasi.
- **Penyimpanan aman**: metadata catatan (id, judul, tanggal) di
  SharedPreferences, isi catatan terenkripsi di `flutter_secure_storage`
  dengan key `note_content_<id>`.
- **HTTP**: `GET /posts` dari JSONPlaceholder dengan timeout, penanganan
  `SocketException`, dan logging aman.

## Arsitektur

```
UI (screens, widgets)
  └─> AppProvider (InheritedWidget) / AppProviderWrapper (StatefulWidget)
        └─> NoteRepository, StudentRepository (Repository pattern)
              ├─> SharedPreferences      (metadata catatan, profil)
              └─> SecureStorageService   (isi catatan terenkripsi)
UI (PostListScreen) ─> ApiService ─> HTTP API (BASE_URL dari .env)
```

## Struktur Proyek

```
lib/
├── main.dart
├── config/
│   ├── app_config.dart        # konfigurasi dari .env
│   └── app_theme.dart         # ThemeData terpusat
├── models/
│   ├── student.dart
│   ├── note.dart
│   └── post.dart              # model data API
├── repositories/
│   ├── note_repository.dart
│   └── student_repository.dart
├── providers/
│   └── app_provider.dart      # AppProvider + AppProviderWrapper
├── screens/
│   ├── home_screen.dart
│   ├── profile_screen.dart    # ProfileScreen + EditProfileScreen
│   ├── note_form_screen.dart
│   └── post_list_screen.dart  # data dari API
├── services/
│   ├── secure_storage_service.dart
│   └── api_service.dart
├── utils/
│   ├── validators.dart
│   └── logger.dart            # logging aman
└── widgets/
    ├── profile_card.dart
    ├── note_card.dart
    └── empty_state.dart
```

## Cara Menjalankan

1. Salin konfigurasi:
   - Windows (PowerShell): `Copy-Item .env.example .env`
   - Linux/macOS: `cp .env.example .env`
2. Install dependency: `flutter pub get`
3. Jalankan: `flutter run`
4. Jalankan unit test: `flutter test`

> File `.env` wajib ada karena didaftarkan sebagai asset di `pubspec.yaml`.

## Keamanan

- Tidak ada credential hardcoded; `BASE_URL` dan `API_KEY` dibaca dari `.env`
  (diabaikan Git).
- Isi catatan tidak pernah dicetak ke log; logger hanya mencatat id/jumlah
  data dan menyamarkan pola seperti `token=...`.
- `AndroidManifest.xml`: permission `INTERNET` dan `android:allowBackup="false"`.
