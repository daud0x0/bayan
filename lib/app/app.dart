import 'package:flutter/material.dart';
import '../domain/models/bookmark_model.dart';
import '../domain/models/content_item.dart';
import '../features/bookmarks/views/saved_view.dart';
import '../features/discover/views/discover_view.dart';
import '../features/hadith/views/hadith_reader_view.dart';
import '../features/quran/views/quran_reader_view.dart';
import '../features/read/views/read_view.dart';
import '../features/settings/views/settings_view.dart';
import 'bootstrap.dart';
import 'theme/app_theme.dart';

/// Root application widget.
class QuranHadithApp extends StatelessWidget {
  const QuranHadithApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final prefs = scope.preferences;

    return MaterialApp(
      title: 'Quran & Hadith Discovery',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(
        palette: prefs.themePalette,
        eyeComfortSepia: prefs.eyeComfortSepia,
      ),
      darkTheme: AppTheme.dark(
        palette: prefs.themePalette,
        pureBlack: prefs.pureBlackDark,
      ),
      themeMode: prefs.themeMode,
      home: const MainNavigationScaffold(),
    );
  }
}

/// Primary Navigation Scaffold featuring the four main destinations.
/// Complies with Section 4 of the Product Plan.
class MainNavigationScaffold extends StatefulWidget {
  const MainNavigationScaffold({super.key});

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  int _currentIndex = 0;

  Future<void> _handleNavigateToContext(ContentItem item) async {
    final scope = AppScope.of(context);

    if (item.contentType == ContentType.quran && item.surahNumber != null) {
      final surah = await scope.contentRepository.getSurah(item.surahNumber!);
      if (surah != null && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => QuranReaderView(
              surah: surah,
              initialAyahNumber: item.ayahNumber,
            ),
          ),
        );
      }
    } else if (item.contentType == ContentType.hadith && item.collectionId != null) {
      final hadiths = await scope.contentRepository.getHadiths(
        collectionId: item.collectionId,
      );
      final hadith = hadiths.firstWhere(
        (h) => h.hadithNumber == item.hadithNumber,
        orElse: () => hadiths.first,
      );
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HadithReaderView(hadith: hadith),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DiscoverView(onOpenContext: _handleNavigateToContext),
      const ReadView(),
      const SavedView(),
      const SettingsView(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Read',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border_rounded),
            selectedIcon: Icon(Icons.bookmark_rounded),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
