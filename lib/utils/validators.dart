/// Kumpulan fungsi validasi dan sanitasi input pengguna.
///
/// Semua validator mengikuti kontrak `FormFieldValidator<String>`:
/// mengembalikan `null` jika valid, atau pesan error jika tidak valid,
/// sehingga bisa langsung dipakai di properti `validator` milik
/// `TextFormField`.
///
/// Validasi panjang dihitung **setelah** [sanitize], sehingga input yang
/// hanya berisi karakter berbahaya tidak lolos validasi.
class Validators {
  Validators._(); // Tidak perlu di-instansiasi.

  /// Panjang minimal judul catatan.
  static const int titleMinLength = 3;

  /// Panjang maksimal judul catatan.
  static const int titleMaxLength = 50;

  /// Panjang minimal isi catatan.
  static const int contentMinLength = 10;

  /// Panjang maksimal isi catatan.
  static const int contentMaxLength = 1000;

  static final RegExp _dangerousChars = RegExp(r'''[<>"']''');
  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _nameRegex = RegExp(r"^[a-zA-Z\s.,\-]+$");
  static final RegExp _nimRegex = RegExp(r'^[0-9.]+$');

  /// Membersihkan karakter berbahaya dari [input].
  ///
  /// Karakter `<`, `>`, `"`, dan `'` dihapus untuk mencegah injeksi
  /// (misalnya tag HTML/script), lalu spasi di awal dan akhir dipangkas.
  static String sanitize(String input) {
    return input.replaceAll(_dangerousChars, '').trim();
  }

  /// Memvalidasi judul catatan: wajib diisi, 3–50 karakter.
  static String? validateTitle(String? value) {
    return _validateLength(
      value,
      fieldName: 'Judul',
      min: titleMinLength,
      max: titleMaxLength,
    );
  }

  /// Memvalidasi isi catatan: wajib diisi, 10–1000 karakter.
  static String? validateContent(String? value) {
    return _validateLength(
      value,
      fieldName: 'Isi catatan',
      min: contentMinLength,
      max: contentMaxLength,
    );
  }

  /// Memvalidasi nama mahasiswa: wajib, 3–50 karakter, hanya huruf.
  static String? validateName(String? value) {
    final error = _validateLength(value, fieldName: 'Nama', min: 3, max: 50);
    if (error != null) return error;
    if (!_nameRegex.hasMatch(sanitize(value!))) {
      return 'Nama hanya boleh berisi huruf';
    }
    return null;
  }

  /// Memvalidasi NIM: wajib, 5–20 karakter, hanya angka dan titik.
  static String? validateNim(String? value) {
    final error = _validateLength(value, fieldName: 'NIM', min: 5, max: 20);
    if (error != null) return error;
    if (!_nimRegex.hasMatch(sanitize(value!))) {
      return 'NIM hanya boleh berisi angka dan titik';
    }
    return null;
  }

  /// Memvalidasi program studi: wajib, 3–60 karakter.
  static String? validateProgramStudi(String? value) {
    return _validateLength(
      value,
      fieldName: 'Program studi',
      min: 3,
      max: 60,
    );
  }

  /// Memvalidasi email: wajib dan sesuai format `nama@domain.tld`.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final email = sanitize(value);
    if (email.length > 100 || !_emailRegex.hasMatch(email)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  /// Validasi umum: wajib diisi dan panjang (setelah sanitasi) di antara
  /// [min] dan [max].
  static String? _validateLength(
    String? value, {
    required String fieldName,
    required int min,
    required int max,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    final length = sanitize(value).length;
    if (length < min) {
      return '$fieldName minimal $min karakter';
    }
    if (length > max) {
      return '$fieldName maksimal $max karakter';
    }
    return null;
  }
}
