import 'package:flutter/widgets.dart';

import '../models/note.dart';
import '../models/student.dart';
import '../repositories/note_repository.dart';
import '../repositories/student_repository.dart';
import '../utils/logger.dart';

/// Penyedia state aplikasi berbasis [InheritedWidget].
///
/// Widget di bawahnya dapat membaca [student] dan [notes], serta memanggil
/// [updateStudent], [addNote], dan [deleteNote] tanpa perlu meneruskan
/// data lewat constructor (prop drilling).
///
/// State-nya sendiri dikelola oleh [AppProviderWrapper].
class AppProvider extends InheritedWidget {
  /// Profil mahasiswa saat ini.
  final Student student;

  /// Daftar catatan (tidak dapat diubah langsung dari luar).
  final List<Note> notes;

  /// `true` saat data awal masih dimuat dari penyimpanan lokal.
  final bool isLoading;

  /// Pesan error saat memuat data, atau `null` jika tidak ada error.
  final String? errorMessage;

  /// Memperbarui profil mahasiswa dan menyimpannya.
  final Future<void> Function(Student student) updateStudent;

  /// Menambahkan catatan baru dan menyimpannya.
  final Future<void> Function(Note note) addNote;

  /// Menghapus catatan berdasarkan id.
  final Future<void> Function(String noteId) deleteNote;

  /// Memuat ulang data dari penyimpanan lokal (dipakai tombol "Coba lagi").
  final Future<void> Function() reload;

  /// Membuat [AppProvider]. Biasanya hanya dibuat oleh [AppProviderWrapper].
  const AppProvider({
    super.key,
    required this.student,
    required this.notes,
    required this.isLoading,
    required this.errorMessage,
    required this.updateStudent,
    required this.addNote,
    required this.deleteNote,
    required this.reload,
    required super.child,
  });

  /// Mengambil [AppProvider] terdekat dan mendaftarkan [context] agar
  /// di-rebuild saat state berubah. Dipakai di dalam `build`.
  static AppProvider of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<AppProvider>();
    assert(provider != null, 'AppProvider tidak ditemukan di widget tree');
    return provider!;
  }

  /// Mengambil [AppProvider] tanpa mendaftarkan dependensi rebuild.
  ///
  /// Dipakai di callback (misalnya `onPressed`) yang hanya perlu memanggil
  /// fungsi, sesuai prinsip least privilege.
  static AppProvider read(BuildContext context) {
    final provider = context.getInheritedWidgetOfExactType<AppProvider>();
    assert(provider != null, 'AppProvider tidak ditemukan di widget tree');
    return provider!;
  }

  /// Widget turunan hanya di-rebuild jika data yang ditampilkan berubah.
  @override
  bool updateShouldNotify(AppProvider oldWidget) {
    return student != oldWidget.student ||
        !identical(notes, oldWidget.notes) ||
        isLoading != oldWidget.isLoading ||
        errorMessage != oldWidget.errorMessage;
  }
}

/// [StatefulWidget] yang mengelola state aplikasi dan menyediakan
/// [AppProvider] ke seluruh subtree.
///
/// Semua perubahan state hanya terjadi di sini (single source of truth).
/// Setiap fungsi hanya mengubah bagian state yang relevan
/// (least privilege), misalnya [AppProvider.addNote] hanya mengganti list
/// catatan tanpa menyentuh profil.
class AppProviderWrapper extends StatefulWidget {
  /// Subtree yang dapat mengakses [AppProvider].
  final Widget child;

  /// Repository catatan (dapat di-inject untuk pengujian).
  final NoteRepository? noteRepository;

  /// Repository profil (dapat di-inject untuk pengujian).
  final StudentRepository? studentRepository;

  /// Membuat [AppProviderWrapper].
  const AppProviderWrapper({
    super.key,
    required this.child,
    this.noteRepository,
    this.studentRepository,
  });

  @override
  State<AppProviderWrapper> createState() => _AppProviderWrapperState();
}

class _AppProviderWrapperState extends State<AppProviderWrapper> {
  static const String _tag = 'AppProvider';

  late final NoteRepository _noteRepository;
  late final StudentRepository _studentRepository;

  Student _student = Student.initial;
  List<Note> _notes = const [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _noteRepository = widget.noteRepository ?? NoteRepository();
    _studentRepository = widget.studentRepository ?? StudentRepository();
    _loadData();
  }

  /// Memuat profil dan catatan dari penyimpanan lokal.
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final student = await _studentRepository.getStudent();
      final notes = await _noteRepository.getNotes();
      if (!mounted) return;
      setState(() {
        _student = student;
        _notes = List.unmodifiable(notes);
        _isLoading = false;
      });
    } catch (e) {
      Logger.error('Gagal memuat data lokal', error: e, tag: _tag);
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat data. Silakan coba lagi.';
        _isLoading = false;
      });
    }
  }

  /// Menyimpan profil, lalu hanya mengganti state [_student].
  Future<void> _updateStudent(Student student) async {
    await _studentRepository.saveStudent(student);
    if (!mounted) return;
    setState(() => _student = student);
  }

  /// Menyimpan catatan, lalu hanya mengganti state [_notes].
  Future<void> _addNote(Note note) async {
    await _noteRepository.addNote(note);
    if (!mounted) return;
    setState(() => _notes = List.unmodifiable([note, ..._notes]));
  }

  /// Menghapus catatan, lalu hanya mengganti state [_notes].
  Future<void> _deleteNote(String noteId) async {
    await _noteRepository.deleteNote(noteId);
    if (!mounted) return;
    setState(() {
      _notes = List.unmodifiable(_notes.where((note) => note.id != noteId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppProvider(
      student: _student,
      notes: _notes,
      isLoading: _isLoading,
      errorMessage: _errorMessage,
      updateStudent: _updateStudent,
      addNote: _addNote,
      deleteNote: _deleteNote,
      reload: _loadData,
      child: widget.child,
    );
  }
}
