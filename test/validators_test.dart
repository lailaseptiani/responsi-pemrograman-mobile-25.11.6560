import 'package:flutter_test/flutter_test.dart';
import 'package:responsi_profil_mahasiswa/utils/validators.dart';

void main() {
  group('Validators.sanitize', () {
    test('menghapus karakter berbahaya < > " \'', () {
      expect(
        Validators.sanitize('<script>alert("x")</script>'),
        'scriptalert(x)/script',
      );
      expect(Validators.sanitize("  It's ok  "), 'Its ok');
    });
  });

  group('Validators.validateTitle', () {
    test('kosong tidak valid', () {
      expect(Validators.validateTitle(''), isNotNull);
      expect(Validators.validateTitle(null), isNotNull);
    });

    test('kurang dari 3 karakter tidak valid', () {
      expect(Validators.validateTitle('ab'), isNotNull);
    });

    test('lebih dari 50 karakter tidak valid', () {
      expect(Validators.validateTitle('a' * 51), isNotNull);
    });

    test('3–50 karakter valid', () {
      expect(Validators.validateTitle('abc'), isNull);
      expect(Validators.validateTitle('a' * 50), isNull);
    });

    test('panjang dihitung setelah sanitasi', () {
      expect(Validators.validateTitle('<<>>a'), isNotNull);
    });
  });

  group('Validators.validateContent', () {
    test('kurang dari 10 karakter tidak valid', () {
      expect(Validators.validateContent('pendek'), isNotNull);
    });

    test('lebih dari 1000 karakter tidak valid', () {
      expect(Validators.validateContent('a' * 1001), isNotNull);
    });

    test('10–1000 karakter valid', () {
      expect(Validators.validateContent('Materi Flutter dasar'), isNull);
    });
  });

  group('Validators profil', () {
    test('email', () {
      expect(Validators.validateEmail('budi@example.com'), isNull);
      expect(Validators.validateEmail('budi@'), isNotNull);
    });

    test('NIM hanya angka dan titik', () {
      expect(Validators.validateNim('22.11.1234'), isNull);
      expect(Validators.validateNim('22-ABC'), isNotNull);
    });

    test('nama hanya huruf', () {
      expect(Validators.validateName('Budi Santoso'), isNull);
      expect(Validators.validateName('Budi123'), isNotNull);
    });
  });
}
