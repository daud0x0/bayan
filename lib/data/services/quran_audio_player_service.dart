import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../../domain/models/reciter_model.dart';

/// Service managing verse-by-verse Quran audio playback and synchronization.
/// Powered by just_audio with auto-advancing, Hifz repetition loop, and reciter switching.
class QuranAudioPlayerService extends ChangeNotifier {
  QuranAudioPlayerService({
    AudioPlayer? player,
    Reciter? initialReciter,
  })  : _player = player ?? AudioPlayer(),
        _currentReciter = initialReciter ?? Reciter.defaultReciter {
    _initPlayerSubscription();
  }

  final AudioPlayer _player;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  Reciter _currentReciter;
  Reciter get currentReciter => _currentReciter;

  int? _currentSurahNumber;
  int? get currentSurahNumber => _currentSurahNumber;

  int? _currentAyahNumber;
  int? get currentAyahNumber => _currentAyahNumber;

  int _totalAyahsInCurrentSurah = 0;
  int get totalAyahsInCurrentSurah => _totalAyahsInCurrentSurah;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  bool _isBuffering = false;
  bool get isBuffering => _isBuffering;

  double _speed = 1.0;
  double get speed => _speed;

  /// Repeat count target: 1 = play once and advance; 3 = repeat 3 times; 999 = loop infinitely.
  int _repeatTarget = 1;
  int get repeatTarget => _repeatTarget;

  int _repeatIteration = 1;
  int get repeatIteration => _repeatIteration;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _initPlayerSubscription() {
    _playerStateSubscription = _player.playerStateStream.listen(
      (state) {
        final playing = state.playing;
        final procState = state.processingState;

        _isPlaying = playing && procState != ProcessingState.completed;
        _isBuffering = procState == ProcessingState.buffering ||
            procState == ProcessingState.loading;

        if (procState == ProcessingState.completed) {
          _handleAyahCompleted();
        }

        notifyListeners();
      },
      onError: (Object error) {
        _errorMessage = 'Recitation audio stream error. Please check your internet connection.';
        _isBuffering = false;
        _isPlaying = false;
        notifyListeners();
      },
    );
  }

  Future<void> _handleAyahCompleted() async {
    // If user set repetition for memorization (e.g. 3x or loop)
    if (_repeatTarget > 1 && _repeatIteration < _repeatTarget) {
      _repeatIteration++;
      notifyListeners();
      try {
        await _player.seek(Duration.zero);
        await _player.play();
      } catch (_) {}
      return;
    }

    // Reset repeat counter for next verse
    _repeatIteration = 1;

    // Check if next Ayah exists in current Surah
    if (_currentSurahNumber != null &&
        _currentAyahNumber != null &&
        _currentAyahNumber! < _totalAyahsInCurrentSurah) {
      final nextAyah = _currentAyahNumber! + 1;
      await playAyah(
        surah: _currentSurahNumber!,
        ayah: nextAyah,
        totalAyahs: _totalAyahsInCurrentSurah,
      );
    } else {
      // Completed entire surah
      _isPlaying = false;
      notifyListeners();
    }
  }

  /// Starts playback of a specific Ayah within a Surah.
  Future<void> playAyah({
    required int surah,
    required int ayah,
    required int totalAyahs,
  }) async {
    _currentSurahNumber = surah;
    _currentAyahNumber = ayah;
    _totalAyahsInCurrentSurah = totalAyahs;
    _errorMessage = null;
    _isBuffering = true;
    notifyListeners();

    final url = _currentReciter.getAyahUrl(surah, ayah);

    try {
      await _player.setSpeed(_speed);
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      _errorMessage = 'Could not load audio for Surah $surah Ayah $ayah. Check connection.';
      _isBuffering = false;
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (_) {}
  }

  Future<void> resume() async {
    try {
      await _player.play();
    } catch (_) {}
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      if (_currentSurahNumber != null && _currentAyahNumber != null) {
        await resume();
      }
    }
  }

  Future<void> nextAyah() async {
    if (_currentSurahNumber == null || _currentAyahNumber == null) return;
    if (_currentAyahNumber! < _totalAyahsInCurrentSurah) {
      _repeatIteration = 1;
      await playAyah(
        surah: _currentSurahNumber!,
        ayah: _currentAyahNumber! + 1,
        totalAyahs: _totalAyahsInCurrentSurah,
      );
    }
  }

  Future<void> previousAyah() async {
    if (_currentSurahNumber == null || _currentAyahNumber == null) return;
    if (_currentAyahNumber! > 1) {
      _repeatIteration = 1;
      await playAyah(
        surah: _currentSurahNumber!,
        ayah: _currentAyahNumber! - 1,
        totalAyahs: _totalAyahsInCurrentSurah,
      );
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
    _isPlaying = false;
    _isBuffering = false;
    _currentSurahNumber = null;
    _currentAyahNumber = null;
    _repeatIteration = 1;
    notifyListeners();
  }

  Future<void> setSpeed(double newSpeed) async {
    _speed = newSpeed;
    try {
      await _player.setSpeed(newSpeed);
    } catch (_) {}
    notifyListeners();
  }

  void setReciter(Reciter reciter) {
    if (_currentReciter.id == reciter.id) return;
    _currentReciter = reciter;
    notifyListeners();

    // If currently active, re-play current ayah with new reciter
    if (_currentSurahNumber != null && _currentAyahNumber != null && _isPlaying) {
      playAyah(
        surah: _currentSurahNumber!,
        ayah: _currentAyahNumber!,
        totalAyahs: _totalAyahsInCurrentSurah,
      );
    }
  }

  void setRepeatTarget(int target) {
    _repeatTarget = target;
    _repeatIteration = 1;
    notifyListeners();
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }
}
