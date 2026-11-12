import 'package:flutter_test/flutter_test.dart';
import 'package:responsi_profil_mahasiswa/models/note.dart';
import 'package:responsi_profil_mahasiswa/models/student.dart';
import 'package:responsi_profil_mahasiswa/services/secure_storage_service.dart';

void main() {
  group('Student', () {
    test('initials diambil dari dua kata pertama', () {
      const student = Student(
        name: 'Budi Santoso Putra',
        nim: '22.11.1234',
        programStudi: 'S1 Informatika',
        email: 'budi@example.com',
      );
      expect(student.initials, 'BS');
    });

    test('toJson dan fromJson menghasilkan data yang sama', () {
      final student = Student.initial.copyWith(name: 'Siti Aminah');
      expect(Student.fromJson(student.toJson()), student);
    });
  });

  group('Note', () {
    test('metadata JSON tidak berisi isi catatan', () {
      final note = Note.create(title: 'Judul', content: 'Isi rahasia');
      final json = note.toMetadataJson();

      expect(json.keys, containsAll(['id', 'title', 'createdAt']));
      expect(json.containsKey('content'), isFalse);
      expect(json.values, isNot(contains('Isi rahasia')));
    });

    test('toString tidak membocorkan isi catatan', () {
      final note = Note.create(title: 'Judul', content: 'Isi rahasia');
      expect(note.toString(), isNot(contains('Isi rahasia')));
    });
  });

  test('key secure storage memakai format note_content_<id>', () {
    expect(SecureStorageService.keyFor('123'), 'note_content_123');
  });
}
