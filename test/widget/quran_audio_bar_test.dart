import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_hadis/data/services/quran_audio_player_service.dart';
import 'package:quran_hadis/domain/models/reciter_model.dart';
import 'package:quran_hadis/features/quran/widgets/quran_audio_bar.dart';
import 'package:quran_hadis/features/quran/widgets/reciter_selection_sheet.dart';

class TestQuranAudioPlayerService extends ChangeNotifier implements QuranAudioPlayerService {
  Reciter _reciter = Reciter.defaultReciter;
  @override
  Reciter get currentReciter => _reciter;

  int? _surah = 1;
  @override
  int? get currentSurahNumber => _surah;

  int? _ayah = 3;
  @override
  int? get currentAyahNumber => _ayah;

  int _totalAyahs = 7;
  @override
  int get totalAyahsInCurrentSurah => _totalAyahs;

  bool _isPlaying = true;
  @override
  bool get isPlaying => _isPlaying;

  bool _isBuffering = false;
  @override
  bool get isBuffering => _isBuffering;

  double _speed = 1.0;
  @override
  double get speed => _speed;

  int _repeatTarget = 1;
  @override
  int get repeatTarget => _repeatTarget;

  int _repeatIteration = 1;
  @override
  int get repeatIteration => _repeatIteration;

  String? _errorMessage;
  @override
  String? get errorMessage => _errorMessage;

  @override
  Future<void> playAyah({required int surah, required int ayah, required int totalAyahs}) async {
    _surah = surah;
    _ayah = ayah;
    _totalAyahs = totalAyahs;
    _isPlaying = true;
    notifyListeners();
  }

  @override
  Future<void> pause() async {
    _isPlaying = false;
    notifyListeners();
  }

  @override
  Future<void> resume() async {
    _isPlaying = true;
    notifyListeners();
  }

  @override
  Future<void> togglePlayPause() async {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  @override
  Future<void> nextAyah() async {
    if (_ayah != null && _ayah! < _totalAyahs) {
      _ayah = _ayah! + 1;
      notifyListeners();
    }
  }

  @override
  Future<void> previousAyah() async {
    if (_ayah != null && _ayah! > 1) {
      _ayah = _ayah! - 1;
      notifyListeners();
    }
  }

  @override
  Future<void> stop() async {
    _isPlaying = false;
    _surah = null;
    _ayah = null;
    notifyListeners();
  }

  @override
  Future<void> setSpeed(double newSpeed) async {
    _speed = newSpeed;
    notifyListeners();
  }

  @override
  void setReciter(Reciter reciter) {
    _reciter = reciter;
    notifyListeners();
  }

  @override
  void setRepeatTarget(int target) {
    _repeatTarget = target;
    notifyListeners();
  }
}

void main() {
  group('QuranAudioBar Widget Tests', () {
    testWidgets('renders reciter name, ayah progress, play state, and controls', (tester) async {
      final service = TestQuranAudioPlayerService();
      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuranAudioBar(
              audioService: service,
              onClose: () => closed = true,
            ),
          ),
        ),
      );

      // Verify reciter pill
      expect(find.text('Mishary'), findsOneWidget);

      // Verify ayah progress
      expect(find.text('Ayah 3 of 7'), findsOneWidget);

      // Verify pause icon because isPlaying = true
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);

      // Verify speed chips
      expect(find.text('1x'), findsOneWidget);
      expect(find.text('1.5x'), findsOneWidget);

      // Tap pause button
      await tester.tap(find.byIcon(Icons.pause_rounded));
      await tester.pumpAndSettle();
      expect(service.isPlaying, isFalse);

      // Tap next button
      await tester.tap(find.byIcon(Icons.skip_next_rounded));
      await tester.pumpAndSettle();
      expect(service.currentAyahNumber, 4);

      // Tap close button
      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(closed, isTrue);
    });

    testWidgets('tapping reciter button opens ReciterSelectionSheet', (tester) async {
      final service = TestQuranAudioPlayerService();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuranAudioBar(
              audioService: service,
              onClose: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Mishary'));
      await tester.pumpAndSettle();

      // ReciterSelectionSheet header
      expect(find.text('Select Reciter'), findsOneWidget);
      expect(find.text('Abdul Basit Abdul Samad'), findsOneWidget);

      // Switch to Abdul Basit
      await tester.tap(find.text('Abdul Basit Abdul Samad'));
      await tester.pumpAndSettle();

      expect(service.currentReciter.id, 'abdul_basit');
    });

    testWidgets('tapping repeat badge cycles repeat modes', (tester) async {
      final service = TestQuranAudioPlayerService();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuranAudioBar(
              audioService: service,
              onClose: () {},
            ),
          ),
        ),
      );

      expect(find.text('Play Once'), findsOneWidget);

      // Tap repeat badge to cycle to 3x Loop
      await tester.tap(find.text('Play Once'));
      await tester.pumpAndSettle();
      expect(service.repeatTarget, 3);
      expect(find.text('3x Loop'), findsOneWidget);
    });
  });
}
