import 'package:flutter/material.dart';

import '../models/note.dart';
import '../providers/app_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/note_card.dart';
import '../widgets/profile_card.dart';
import 'note_form_screen.dart';
import 'post_list_screen.dart';
import 'profile_screen.dart';

/// Halaman utama aplikasi.
///
/// Berisi:
/// * Profil singkat (nama & NIM) di bagian atas.
/// * Daftar catatan memakai `ListView.builder` dan [NoteCard].
/// * [EmptyState] jika belum ada catatan, serta loading & error state.
/// * `FloatingActionButton` untuk menambah catatan.
/// * Dialog konfirmasi sebelum menghapus catatan.
class HomeScreen extends StatelessWidget {
  /// Membuat [HomeScreen].
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = AppProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Kuliah'),
        actions: [
          IconButton(
            icon: const Icon(Icons.public),
            tooltip: 'Data API',
            onPressed: () => _openPostList(context),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profil',
            onPressed: () => _openProfile(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileCard(
            student: provider.student,
            compact: true,
            onTap: () => _openProfile(context),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Catatan Saya (${provider.notes.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(child: _buildNotes(context, provider)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNoteForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Catatan'),
        tooltip: 'Tambah catatan',
      ),
    );
  }

  /// Menentukan tampilan daftar: loading, error, kosong, atau berisi data.
  Widget _buildNotes(BuildContext context, AppProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat catatan...'),
          ],
        ),
      );
    }

    if (provider.errorMessage != null) {
      return EmptyState(
        icon: Icons.error_outline,
        iconColor: Theme.of(context).colorScheme.error,
        title: 'Terjadi Kesalahan',
        message: provider.errorMessage!,
        actionLabel: 'Coba Lagi',
        onAction: provider.reload,
      );
    }

    if (provider.notes.isEmpty) {
      return EmptyState(
        title: 'Belum ada catatan',
        message: 'Tekan tombol "+ Catatan" untuk menambahkan '
            'catatan kuliah pertamamu.',
        actionLabel: 'Tambah Catatan',
        actionIcon: Icons.add,
        onAction: () => _openNoteForm(context),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: provider.notes.length,
      itemBuilder: (context, index) {
        final note = provider.notes[index];
        return NoteCard(
          key: ValueKey(note.id),
          note: note,
          onTap: () => _showNoteDetail(context, note),
          onDelete: () => _confirmDelete(context, note),
        );
      },
    );
  }

  /// HomeScreen → NoteFormScreen. Menerima `true` jika catatan tersimpan.
  Future<void> _openNoteForm(BuildContext context) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const NoteFormScreen()),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan berhasil disimpan')),
      );
    }
  }

  /// HomeScreen → ProfileScreen.
  void _openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  /// HomeScreen → PostListScreen (data dari API publik).
  void _openPostList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PostListScreen()),
    );
  }

  /// Menampilkan isi lengkap catatan dalam bottom sheet.
  void _showNoteDetail(BuildContext context, Note note) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          children: [
            Text(
              note.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              NoteCard.dateFormat.format(note.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Divider(height: 24),
            Text(note.content, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  /// Menampilkan dialog konfirmasi; catatan dihapus hanya jika disetujui.
  Future<void> _confirmDelete(BuildContext context, Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.delete_outline),
        title: const Text('Hapus Catatan?'),
        content: Text(
          'Catatan "${note.title}" akan dihapus permanen dan tidak dapat '
          'dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await AppProvider.read(context).deleteNote(note.id);
      messenger.showSnackBar(
        const SnackBar(content: Text('Catatan dihapus')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Gagal menghapus catatan')),
      );
    }
  }
}
