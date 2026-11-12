/// Model data profil mahasiswa.
///
/// Bersifat immutable: perubahan data dilakukan dengan [copyWith] sehingga
/// state lama tidak ikut berubah secara tidak sengaja.
class Student {
  /// Nama lengkap mahasiswa.
  final String name;

  /// Nomor Induk Mahasiswa.
  final String nim;

  /// Program studi mahasiswa.
  final String programStudi;

  /// Alamat email mahasiswa.
  final String email;

  /// Membuat objek [Student].
  const Student({
    required this.name,
    required this.nim,
    required this.programStudi,
    required this.email,
  });

  /// Data profil awal yang dipakai sebelum pengguna mengedit profilnya.
  static const Student initial = Student(
    name: 'Nama Mahasiswa',
    nim: '00.00.0000',
    programStudi: 'S1 Informatika',
    email: 'mahasiswa@example.com',
  );

  /// Inisial nama (maksimal 2 huruf) untuk ditampilkan di `CircleAvatar`.
  ///
  /// Contoh: `"Budi Santoso"` menjadi `"BS"`.
  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  /// Membuat salinan [Student] dengan field tertentu yang diganti.
  Student copyWith({
    String? name,
    String? nim,
    String? programStudi,
    String? email,
  }) {
    return Student(
      name: name ?? this.name,
      nim: nim ?? this.nim,
      programStudi: programStudi ?? this.programStudi,
      email: email ?? this.email,
    );
  }

  /// Mengubah objek menjadi `Map` untuk disimpan sebagai JSON.
  Map<String, dynamic> toJson() => {
        'name': name,
        'nim': nim,
        'programStudi': programStudi,
        'email': email,
      };

  /// Membuat [Student] dari `Map` hasil decode JSON.
  ///
  /// Field yang hilang diisi dengan nilai dari [Student.initial].
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      name: json['name'] as String? ?? initial.name,
      nim: json['nim'] as String? ?? initial.nim,
      programStudi: json['programStudi'] as String? ?? initial.programStudi,
      email: json['email'] as String? ?? initial.email,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Student &&
          other.name == name &&
          other.nim == nim &&
          other.programStudi == programStudi &&
          other.email == email;

  @override
  int get hashCode => Object.hash(name, nim, programStudi, email);
}
