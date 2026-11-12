import 'package:flutter/material.dart';

import '../models/note.dart';
import '../providers/app_provider.dart';
import '../utils/validators.dart';

/// Halaman form untuk menambah catatan kuliah.
///
/// * Judul divalidasi dengan [Validators.validateTitle] (3–50 karakter).
/// * Isi divalidasi dengan [Validators.validateContent] (10–1000 karakter).
/// * Sebelum disimpan, input dibersihkan dengan [Validators.sanitize].
///
/// Jika berhasil, halaman ditutup dengan `Navigator.pop(context, true)`
/// sehingga `HomeScreen` bisa menampilkan pesan sukses.
class NoteFormScreen extends StatefulWidget {
  /// Membuat [NoteFormScreen].
  const NoteFormScreen({super.key});

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Hilangkan fokus keyboard agar pesan error terlihat.
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      // Setelah submit pertama gagal, validasi berjalan saat mengetik.
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      return;
    }

    setState(() => _isSaving = true);

    final note = Note.create(
      title: Validators.sanitize(_titleController.text),
      content: Validators.sanitize(_contentController.text),
    );

    try {
      await AppProvider.read(context).addNote(note);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan catatan. Coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Catatan')),
      body: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              enabled: !_isSaving,
              decoration: const InputDecoration(
                labelText: 'Judul',
                hintText: 'Contoh: Pertemuan 5 - Secure Storage',
                prefixIcon: Icon(Icons.title),
              ),
              maxLength: Validators.titleMaxLength,
              textInputAction: TextInputAction.next,
              validator: Validators.validateTitle,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contentController,
              enabled: !_isSaving,
              decoration: const InputDecoration(
                labelText: 'Isi Catatan',
                hintText: 'Tulis ringkasan materi kuliah...',
                alignLabelWithHint: true,
              ),
              maxLength: Validators.contentMaxLength,
              minLines: 6,
              maxLines: 12,
              keyboardType: TextInputType.multiline,
              validator: Validators.validateContent,
            ),
            const SizedBox(height: 8),
            Text(
              'Isi catatan disimpan terenkripsi di perangkat. '
              'Karakter < > " \' akan dihapus otomatis.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _submit,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Catatan'),
            ),
          ],
        ),
      ),
    );
  }
}
