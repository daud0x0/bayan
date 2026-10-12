import 'package:flutter/material.dart';
import '../../../app/bootstrap.dart';
import '../../../core/typography/app_typography.dart';
import '../../../core/widgets/islamic_decorations.dart';
import '../../../domain/models/quran_juz.dart';
import '../../../domain/models/quran_models.dart';
import 'quran_reader_view.dart';

/// Surah and Juz index listing all 114 Surahs and 30 Ajza' with search and resume progress.
/// Complies with Section 4.2 of the Product Plan.
class QuranIndexView extends StatefulWidget {
  const QuranIndexView({super.key, this.showAppBar = false});

  final bool showAppBar;

  @override
  State<QuranIndexView> createState() => _QuranIndexViewState();
}

class _QuranIndexViewState extends State<QuranIndexView> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 0; // 0: Surahs, 1: Juz
  List<QuranSurah> _surahs = [];
  List<QuranSurah> _filteredSurahs = [];
  List<QuranJuz> _filteredJuz = QuranJuz.allJuz;
  String _revelationFilter = 'All';
  bool _isLoading = true;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _loadSurahs();
      _initialized = true;
    }
  }

  Future<void> _loadSurahs() async {
    final scope = AppScope.of(context);
    final surahs = await scope.contentRepository.getSurahs();
    if (!mounted) return;

    setState(() {
      _surahs = surahs;
      _isLoading = false;
    });
    _applyFilters();
  }

  void _applyFilters() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      if (_selectedTab == 0) {
        _filteredSurahs = _surahs.where((s) {
          final matchesRevelation = _revelationFilter == 'All' ||
              s.revelationType.toLowerCase() == _revelationFilter.toLowerCase();
          if (!matchesRevelation) return false;

          if (q.isEmpty) return true;
          final matchNum = s.number.toString().contains(q);
          final matchEn = s.nameEnglish.toLowerCase().contains(q);
          final matchTr = s.nameTranslation.toLowerCase().contains(q);
          final matchAr = s.nameArabic.contains(q);
          return matchNum || matchEn || matchTr || matchAr;
        }).toList();
      } else {
        _filteredJuz = QuranJuz.allJuz.where((j) {
          if (q.isEmpty) return true;
          final matchNum = j.number.toString().contains(q);
          final matchEn = j.nameEnglish.toLowerCase().contains(q);
          final matchAr = j.nameArabic.contains(q);
          final matchRange = j.rangeDescription.toLowerCase().contains(q);
          return matchNum || matchEn || matchAr || matchRange;
        }).toList();
      }
    });
  }

  void _filter(String query) {
    _applyFilters();
  }

  void _openSurah(QuranSurah surah, {int? ayahNumber}) {
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuranReaderView(surah: surah, initialAyahNumber: ayahNumber),
      ),
    );
  }

  Future<void> _openJuz(QuranJuz juz) async {
    FocusScope.of(context).unfocus();
    final scope = AppScope.of(context);
    final surah = await scope.contentRepository.getSurah(juz.startSurahNumber);
    if (surah != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QuranReaderView(
            surah: surah,
            initialAyahNumber: juz.startAyahNumber,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final lastProgress = scope.lastQuranProgress;

    Widget body = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // Quick resume banner if progress exists
              if (lastProgress != null)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                        const Color(0xFFC5A059).withValues(alpha: 0.10),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFC5A059).withValues(alpha: 0.35),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC5A059).withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bookmark_added_rounded,
                          size: 18,
                          color: Color(0xFFC5A059),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Continue Reading',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC5A059).withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Ayah ${lastProgress.itemNumber}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFC5A059),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              lastProgress.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                            ),
                          ],
                        ),
                      ),
                      FilledButton.tonal(
                        onPressed: () async {
                          final surahNum = int.tryParse(lastProgress.targetId) ?? 1;
                          final surah = await scope.contentRepository.getSurah(surahNum);
                          if (surah != null && context.mounted) {
                            _openSurah(surah, ayahNumber: lastProgress.itemNumber);
                          }
                        },
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        child: const Text('Resume'),
                      ),
                    ],
                  ),
                ),

              // Segmented Button: Surahs vs Juz
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(
                        value: 0,
                        icon: Icon(Icons.menu_book_rounded, size: 15),
                        label: Text('Surahs (114)', style: TextStyle(fontSize: 12)),
                      ),
                      ButtonSegment(
                        value: 1,
                        icon: Icon(Icons.auto_stories_rounded, size: 15),
                        label: Text('Juz / Paras (30)', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                    selected: {_selectedTab},
                    onSelectionChanged: (set) {
                      setState(() {
                        _selectedTab = set.first;
                        _applyFilters();
                      });
                    },
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: _selectedTab == 0
                        ? 'Search Surah by name or number...'
                        : 'Search Juz by number or name...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _filter('');
                              FocusScope.of(context).unfocus();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: const Color(0xFFC5A059).withValues(alpha: 0.25),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: const Color(0xFFC5A059).withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                  onChanged: _filter,
                ),
              ),

              // Revelation Filter Chips (only when on Surahs tab)
              if (_selectedTab == 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                  child: Row(
                    children: [
                      _buildRevelationChip('All', _surahs.length),
                      const SizedBox(width: 8),
                      _buildRevelationChip('Meccan', 86),
                      const SizedBox(width: 8),
                      _buildRevelationChip('Medinan', 28),
                    ],
                  ),
                ),

              // Content List (Surahs or Juz)
              Expanded(
                child: _selectedTab == 0
                    ? _buildSurahsList(context)
                    : _buildJuzList(context),
              ),
            ],
          );

    if (widget.showAppBar) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Holy Quran', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: body,
      );
    }

    return body;
  }

  Widget _buildSurahsList(BuildContext context) {
    if (_filteredSurahs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 40, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 8),
            Text(
              'No Surahs found',
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredSurahs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final surah = _filteredSurahs[index];

        return Card(
          elevation: 0,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _openSurah(surah),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  RubElHizbBadge(
                    number: surah.number,
                    size: 42,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          surah.nameEnglish,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          surah.nameTranslation,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        surah.nameArabic,
                        textAlign: TextAlign.right,
                        style: AppTypography.arabic(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                          color: const Color(0xFFC5A059),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${surah.revelationType} • ${surah.ayahCount} verses',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildJuzList(BuildContext context) {
    if (_filteredJuz.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 40, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 8),
            Text(
              'No Juz found',
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredJuz.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final juz = _filteredJuz[index];

        return Card(
          elevation: 0,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _openJuz(juz),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  RubElHizbBadge(
                    number: juz.number,
                    size: 42,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Juz ${juz.number} • ${juz.nameEnglish}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          juz.rangeDescription,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        juz.nameArabic,
                        textAlign: TextAlign.right,
                        style: AppTypography.arabic(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                          color: const Color(0xFFC5A059),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC5A059).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${juz.totalAyahs} Verses',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC5A059),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRevelationChip(String type, int count) {
    final isSelected = _revelationFilter == type;
    final theme = Theme.of(context);
    return FilterChip(
      label: Text('$type ($count)'),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? theme.colorScheme.onSecondaryContainer : theme.colorScheme.onSurfaceVariant,
      ),
      selected: isSelected,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      onSelected: (_) {
        setState(() {
          _revelationFilter = type;
        });
        _applyFilters();
      },
    );
  }
}
