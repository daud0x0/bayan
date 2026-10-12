import 'package:flutter/material.dart';
import '../data/database/app_database.dart';
import '../data/repositories/bookmark_repository.dart';
import '../data/repositories/content_repository.dart';
import '../data/repositories/preferences_repository.dart';
import '../data/repositories/reading_progress_repository.dart';
import '../domain/models/bookmark_model.dart';
import '../domain/models/content_item.dart';
import '../domain/models/reading_progress_model.dart';
import '../domain/models/user_preferences.dart';
import '../visual_engine/generator/seeded_generator.dart';

/// Central dependency container and state coordinator.
/// Complies with Section 8 of the Product Plan.
class AppScope extends ChangeNotifier {
  AppScope({
    required this.contentRepository,
    required this.bookmarkRepository,
    required this.readingProgressRepository,
    required this.preferencesRepository,
    required UserPreferences initialPreferences,
  }) : _preferences = initialPreferences;

  final ContentRepository contentRepository;
  final BookmarkRepository bookmarkRepository;
  final ReadingProgressRepository readingProgressRepository;
  final PreferencesRepository preferencesRepository;

  UserPreferences _preferences;
  UserPreferences get preferences => _preferences;

  final Set<String> _bookmarkedIds = {};
  Set<String> get bookmarkedIds => _bookmarkedIds;

  ReadingProgress? _lastQuranProgress;
  ReadingProgress? get lastQuranProgress => _lastQuranProgress;

  ReadingProgress? _lastHadithProgress;
  ReadingProgress? get lastHadithProgress => _lastHadithProgress;

  bool _isReady = false;
  bool get isReady => _isReady;

  static AppScope of(BuildContext context) => AppScopeProvider.of(context);

  static Future<AppScope> create() async {
    final contentRepo = ContentRepository();
    final bookmarkRepo = BookmarkRepository();
    final progressRepo = ReadingProgressRepository();
    final prefsRepo = PreferencesRepository();

    final prefs = await prefsRepo.loadPreferences();

    final scope = AppScope(
      contentRepository: contentRepo,
      bookmarkRepository: bookmarkRepo,
      readingProgressRepository: progressRepo,
      preferencesRepository: prefsRepo,
      initialPreferences: prefs,
    );

    await scope._init();
    return scope;
  }

  Future<void> _init() async {
    await contentRepository.initialize();
    await loadBookmarks();
    await _loadProgress();
    _isReady = true;
    notifyListeners();
  }

  Future<void> loadBookmarks() async {
    final bookmarks = await bookmarkRepository.getBookmarks();
    _bookmarkedIds.clear();
    _bookmarkedIds.addAll(bookmarks.map((b) => b.contentId));
  }

  Future<void> _loadProgress() async {
    _lastQuranProgress = await readingProgressRepository.getProgress(ContentType.quran);
    _lastHadithProgress = await readingProgressRepository.getProgress(ContentType.hadith);
  }

  Future<void> updatePreferences(UserPreferences newPreferences) async {
    _preferences = newPreferences;
    await preferencesRepository.savePreferences(newPreferences);
    SeededVisualGenerator.clearCache();
    notifyListeners();
  }

  Future<void> toggleBookmark(ContentItem item) async {
    final contentId = item.id;
    if (_bookmarkedIds.contains(contentId)) {
      _bookmarkedIds.remove(contentId);
      await bookmarkRepository.removeBookmark(contentId);
    } else {
      _bookmarkedIds.add(contentId);
      final bookmark = Bookmark(
        id: contentId,
        contentType: item.contentType,
        contentId: contentId,
        title: item.reference,
        reference: item.reference,
        arabicExcerpt: item.arabicText.length > 100
            ? '${item.arabicText.substring(0, 100)}...'
            : item.arabicText,
        translationExcerpt: item.englishTranslation.length > 140
            ? '${item.englishTranslation.substring(0, 140)}...'
            : item.englishTranslation,
        createdAt: DateTime.now(),
      );
      await bookmarkRepository.addBookmark(bookmark);
    }
    notifyListeners();
  }

  bool isBookmarked(String contentId) => _bookmarkedIds.contains(contentId);

  Future<void> recordProgress(ReadingProgress progress) async {
    if (progress.contentType == ContentType.quran) {
      _lastQuranProgress = progress;
    } else {
      _lastHadithProgress = progress;
    }
    await readingProgressRepository.saveProgress(progress);
    notifyListeners();
  }

  Future<void> resetAllLocalData() async {
    await AppDatabase.instance.clearAllUserData();
    await preferencesRepository.clearPreferences();
    _bookmarkedIds.clear();
    _lastQuranProgress = null;
    _lastHadithProgress = null;
    _preferences = const UserPreferences();
    SeededVisualGenerator.clearCache();
    notifyListeners();
  }
}

/// InheritedWidget providing [AppScope] to the widget tree.
class AppScopeProvider extends InheritedNotifier<AppScope> {
  const AppScopeProvider({
    super.key,
    required AppScope scope,
    required super.child,
  }) : super(notifier: scope);

  static AppScope of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppScopeProvider>();
    assert(provider != null, 'No AppScopeProvider found in context');
    return provider!.notifier!;
  }
}
