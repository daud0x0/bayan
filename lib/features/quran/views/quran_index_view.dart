import 'package:flutter/material.dart';
import '../../../app/bootstrap.dart';
import '../../../core/typography/app_typography.dart';
import '../../../domain/models/quran_models.dart';
import 'quran_reader_view.dart';

/// Surah index listing all 114 Surahs with search and resume progress.
/// Complies with Section 4.2 of the Product Plan.
class QuranIndexView extends StatefulWidget {
  const QuranIndexView({super.key});

  @override
  State<QuranIndexView> createState() => _QuranIndexViewState();
}

class _QuranIndexViewState extends State<QuranIndexView> {
  final TextEditingController _searchController = TextEditingController();
  List<QuranSurah> _surahs = [];
  List<QuranSurah> _filteredSurahs = [];
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
      _filteredSurahs = surahs;
      _isLoading = false;
    });
  }

  void _filter(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _filteredSurahs = _surahs);
      return;
    }

    setState(() {
      _filteredSurahs = _surahs.where((s) {
        final matchNum = s.number.toString().contains(q);
        final matchEn = s.nameEnglish.toLowerCase().contains(q);
        final matchTr = s.nameTranslation.toLowerCase().contains(q);
        final matchAr = s.nameArabic.contains(q);
        return matchNum || matchEn || matchTr || matchAr;
      }).toList();
    });
  }

  void _openSurah(QuranSurah surah, {int? ayahNumber}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuranReaderView(surah: surah, initialAyahNumber: ayahNumber),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final lastProgress = scope.lastQuranProgress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Holy Quran', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Quick resume banner if progress exists
                if (lastProgress != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.auto_stories_rounded,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Continue Reading',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              Text(
                                '${lastProgress.title} • ${lastProgress.subtitle}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final surahNum = int.tryParse(lastProgress.targetId) ?? 1;
                            final surah = await scope.contentRepository.getSurah(surahNum);
                            if (surah != null && context.mounted) {
                              _openSurah(surah, ayahNumber: lastProgress.itemNumber);
                            }
                          },
                          child: const Text('Resume'),
                        ),
                      ],
                    ),
                  ),

                // Search Surahs Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Surah by name or number...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: _filter,
                  ),
                ),

                // Surahs List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filteredSurahs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final surah = _filteredSurahs[index];

                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Container(
                            width: 38,
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              surah.number.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                surah.nameEnglish,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text(
                                surah.nameArabic,
                                style: AppTypography.arabic(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                surah.nameTranslation,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              Text(
                                '${surah.revelationType} • ${surah.ayahCount} verses',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _openSurah(surah),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
