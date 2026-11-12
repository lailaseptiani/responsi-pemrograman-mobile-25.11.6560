import 'package:flutter/material.dart';

/// Tampilan informatif saat tidak ada data atau terjadi error.
///
/// Dipakai untuk:
/// * Empty state: belum ada catatan.
/// * Error state: gagal memuat data (dengan tombol "Coba lagi").
class EmptyState extends StatelessWidget {
  /// Ikon besar di bagian atas.
  final IconData icon;

  /// Judul singkat, misalnya "Belum ada catatan".
  final String title;

  /// Penjelasan tambahan untuk pengguna.
  final String message;

  /// Teks tombol aksi (opsional).
  final String? actionLabel;

  /// Aksi tombol (opsional). Tombol hanya tampil jika [actionLabel] dan
  /// [onAction] diisi.
  final VoidCallback? onAction;

  /// Ikon pada tombol aksi. Default ikon refresh.
  final IconData actionIcon;

  /// Warna ikon (opsional). Default memakai warna primer tema.
  final Color? iconColor;

  /// Membuat [EmptyState].
  const EmptyState({
    super.key,
    this.icon = Icons.note_alt_outlined,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.actionIcon = Icons.refresh,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 80,
              color: iconColor ?? theme.colorScheme.primary.withValues(
                alpha: 0.6,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: Icon(actionIcon),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
