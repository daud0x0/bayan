import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hadis/domain/models/reciter_model.dart';

void main() {
  group('Reciter Model Tests', () {
    test('contains 5 curated master Qaris', () {
      expect(Reciter.availableReciters.length, 5);
      final defaultReciter = Reciter.defaultReciter;
      expect(defaultReciter.id, 'mishary_alafasy');
      expect(defaultReciter.folder, 'Alafasy_128kbps');
    });

    test('getAyahUrl generates correct EveryAyah CDN URLs with zero padding', () {
      final mishary = Reciter.findById('mishary_alafasy');
      expect(
        mishary.getAyahUrl(1, 1),
        'https://everyayah.com/data/Alafasy_128kbps/001001.mp3',
      );
      expect(
        mishary.getAyahUrl(2, 255),
        'https://everyayah.com/data/Alafasy_128kbps/002255.mp3',
      );
      expect(
        mishary.getAyahUrl(114, 6),
        'https://everyayah.com/data/Alafasy_128kbps/114006.mp3',
      );
    });

    test('findById returns matching reciter or defaults safely', () {
      final abdulBasit = Reciter.findById('abdul_basit');
      expect(abdulBasit.name, 'Abdul Basit Abdul Samad');
      expect(abdulBasit.folder, 'Abdul_Basit_Mujawwad_128kbps');

      final unknown = Reciter.findById('non_existent_reciter');
      expect(unknown.id, 'mishary_alafasy');
    });

    test('all reciters have valid non-empty metadata', () {
      for (final r in Reciter.availableReciters) {
        expect(r.id.isNotEmpty, isTrue);
        expect(r.name.isNotEmpty, isTrue);
        expect(r.arabicName.isNotEmpty, isTrue);
        expect(r.folder.isNotEmpty, isTrue);
        expect(r.style.isNotEmpty, isTrue);
      }
    });
  });
}
