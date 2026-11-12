import 'package:flutter/material.dart';

import '../models/student.dart';

/// Kartu yang menampilkan profil mahasiswa.
///
/// Mendukung dua mode:
/// * Lengkap (default): foto inisial, nama, NIM, program studi, email.
/// * Ringkas ([compact] = `true`): foto inisial, nama, dan NIM dalam satu
///   baris; dipakai di bagian atas `HomeScreen`.
///
/// Widget ini hanya bertugas menampilkan data (tanpa logika), sehingga UI
/// terpisah dari pengelolaan state.
class ProfileCard extends StatelessWidget {
  /// Data mahasiswa yang ditampilkan.
  final Student student;

  /// Menampilkan versi ringkas jika `true`.
  final bool compact;

  /// Aksi saat kartu ditekan (opsional).
  final VoidCallback? onTap;

  /// Membuat [ProfileCard].
  const ProfileCard({
    super.key,
    required this.student,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: compact ? _buildCompact(context) : _buildFull(context),
          ),
        ),
      ),
    );
  }

  Widget _buildCompact(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        _Avatar(initials: student.initials, radius: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                student.name,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text('NIM: ${student.nim}', style: textTheme.bodyMedium),
            ],
          ),
        ),
        if (onTap != null) const Icon(Icons.chevron_right),
      ],
    );
  }

  Widget _buildFull(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        const SizedBox(height: 8),
        _Avatar(initials: student.initials, radius: 48),
        const SizedBox(height: 16),
        Text(
          student.name,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'NIM: ${student.nim}',
          style: textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
        ),
        const SizedBox(height: 16),
        const Divider(),
        _InfoRow(
          icon: Icons.badge_outlined,
          label: 'NIM',
          value: student.nim,
        ),
        _InfoRow(
          icon: Icons.school_outlined,
          label: 'Program Studi',
          value: student.programStudi,
        ),
        _InfoRow(
          icon: Icons.email_outlined,
          label: 'Email',
          value: student.email,
        ),
      ],
    );
  }
}

/// Foto profil berupa [CircleAvatar] berisi inisial nama.
class _Avatar extends StatelessWidget {
  final String initials;
  final double radius;

  const _Avatar({required this.initials, required this.radius});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: radius,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: radius * 0.7,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Satu baris informasi: ikon, label, dan nilai.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
