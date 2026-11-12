import 'package:flutter/material.dart';

import '../models/student.dart';
import '../providers/app_provider.dart';
import '../utils/validators.dart';
import '../widgets/profile_card.dart';

/// Halaman profil mahasiswa.
///
/// Menampilkan [ProfileCard] berisi data dari [AppProvider] dan tombol
/// "Edit Profil". Halaman ini tidak menyimpan data sendiri: perubahan
/// dikirim ke [AppProvider.updateStudent] (UI terpisah dari logika).
class ProfileScreen extends StatelessWidget {
  /// Membuat [ProfileScreen].
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final student = AppProvider.of(context).student;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Mahasiswa')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileCard(student: student),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openEditProfile(context, student),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profil'),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Membuka halaman edit, menunggu hasilnya, lalu menyimpan lewat provider.
  Future<void> _openEditProfile(BuildContext context, Student student) async {
    final updated = await Navigator.push<Student>(
      context,
      MaterialPageRoute(builder: (_) => EditProfileScreen(student: student)),
    );
    if (updated == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await AppProvider.read(context).updateStudent(updated);
      messenger.showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan profil')),
      );
    }
  }
}

/// Halaman form untuk mengedit profil mahasiswa.
///
/// Mengembalikan [Student] baru melalui `Navigator.pop` jika form valid,
/// atau `null` jika pengguna membatalkan.
class EditProfileScreen extends StatefulWidget {
  /// Data profil saat ini sebagai nilai awal form.
  final Student student;

  /// Membuat [EditProfileScreen].
  const EditProfileScreen({super.key, required this.student});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _nimController;
  late final TextEditingController _prodiController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student.name);
    _nimController = TextEditingController(text: widget.student.nim);
    _prodiController =
        TextEditingController(text: widget.student.programStudi);
    _emailController = TextEditingController(text: widget.student.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _prodiController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    // Semua input disanitasi sebelum dikembalikan.
    final updated = Student(
      name: Validators.sanitize(_nameController.text),
      nim: Validators.sanitize(_nimController.text),
      programStudi: Validators.sanitize(_prodiController.text),
      email: Validators.sanitize(_emailController.text),
    );
    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: Validators.validateName,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nimController,
              decoration: const InputDecoration(
                labelText: 'NIM',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              validator: Validators.validateNim,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _prodiController,
              decoration: const InputDecoration(
                labelText: 'Program Studi',
                prefixIcon: Icon(Icons.school_outlined),
              ),
              textInputAction: TextInputAction.next,
              validator: Validators.validateProgramStudi,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              validator: Validators.validateEmail,
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
