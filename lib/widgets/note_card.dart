import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/note.dart';

/// Kartu untuk menampilkan satu catatan di daftar catatan.
///
/// Menampilkan judul, tanggal dibuat, dan cuplikan isi (maksimal 2 baris).
/// Aksi tap dan hapus diteruskan ke parent melalui callback sehingga
/// widget ini tidak berisi logika penyimpanan.
class NoteCard extends StatelessWidget {
  /// Catatan yang ditampilkan.
  final Note note;

  /// Dipanggil saat kartu ditekan (misalnya untuk melihat detail).
  final VoidCallback? onTap;

  /// Dipanggil saat tombol hapus ditekan.
  final VoidCallback? onDelete;

  /// Membuat [NoteCard].
  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onDelete,
  });

  /// Format tanggal yang dipakai di kartu, misalnya `12/11/2026 16:30`.
  static final DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.sticky_note_2_outlined,
                    color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateFormat.format(note.createdAt),
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      note.content,
                      style: textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: colorScheme.error,
                tooltip: 'Hapus catatan',
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
