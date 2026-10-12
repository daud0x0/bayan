import 'package:flutter/material.dart';
import '../../../app/bootstrap.dart';
import '../../../core/typography/app_typography.dart';
import '../../../core/widgets/islamic_decorations.dart';
import '../../../domain/models/quran_models.dart';

/// Modal bottom sheet allowing users to quickly jump between the 114 Surahs
/// directly from the Quran Reader with full search and revelation filters.
class QuranSurahsSheet extends StatefulWidget {
  const QuranSurahsSheet({
    super.key,
    required this.currentSurahNumber,
    required this.onSelectSurah,
  });

  final int currentSurahNumber;
  final ValueChanged<QuranSurah> onSelectSurah;

  static void show(
    BuildContext context, {
    required int currentSurahNumber,
    required ValueChanged<QuranSurah> onSelectSurah,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuranSurahsSheet(
        currentSurahNumber: currentSurahNumber,
        onSelectSurah: onSelectSurah,
      ),
    );
  }

  @override
  State<QuranSurahsSheet> createState() => _QuranSurahsSheetState();
}

class _QuranSurahsSheetState extends State<QuranSurahsSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<QuranSurah> _surahs = [];
  List<QuranSurah> _filteredSurahs = [];
  String _revelationFilter = 'All';
  bool _isLoading = true;
  bool _initialized = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
    final list = await scope.contentRepository.getSurahs();
    if (!mounted) return;

    setState(() {
      _surahs = list;
      _isLoading = false;
      _applyFilter();
    });
  }

  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredSurahs = _surahs.where((s) {
        final matchesRevelation = _revelationFilter == 'All' ||
            s.revelationType.toLowerCase() == _revelationFilter.toLowerCase();
        if (!matchesRevelation) return false;

        if (query.isEmpty) return true;
        final matchNum = s.number.toString().contains(query);
        final matchEn = s.nameEnglish.toLowerCase().contains(query);
        final matchTr = s.nameTranslation.toLowerCase().contains(query);
        final matchAr = s.nameArabic.contains(query);
        return matchNum || matchEn || matchTr || matchAr;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.50,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F1E19) : const Color(0xFFFAF8F5),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: const Color(0xFFC5A059).withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Grab handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFC5A059).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jump to Surah',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          '${_surahs.length} Chapters of the Noble Quran',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Surah by name or number...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _applyFilter();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.35),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: const Color(0xFFC5A059).withValues(alpha: 0.25),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: const Color(0xFFC5A059).withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                  onChanged: (_) => _applyFilter(),
                ),
              ),

              // Revelation Filter Chips
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
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

              const Divider(height: 1),

              // Surahs List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredSurahs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 40,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No matching Surahs found',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.outline,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: _filteredSurahs.length,
                            separatorBuilder: (_, index) => const SizedBox(height: 6),
                            itemBuilder: (context, index) {
                              final surah = _filteredSurahs[index];
                              final isCurrent = surah.number == widget.currentSurahNumber;

                              return Card(
                                elevation: 0,
                                color: isCurrent
                                    ? const Color(0xFFC5A059).withValues(alpha: isDark ? 0.16 : 0.10)
                                    : null,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: isCurrent
                                        ? const Color(0xFFC5A059)
                                        : Theme.of(context).dividerColor.withValues(alpha: 0.2),
                                    width: isCurrent ? 1.4 : 0.8,
                                  ),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    widget.onSelectSurah(surah);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                    child: Row(
                                      children: [
                                        RubElHizbBadge(
                                          number: surah.number,
                                          size: 38,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    surah.nameEnglish,
                                                    style: TextStyle(
                                                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                                      fontSize: 15,
                                                      color: isCurrent ? const Color(0xFFC5A059) : null,
                                                    ),
                                                  ),
                                                  if (isCurrent) ...[
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFC5A059).withValues(alpha: 0.2),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: const Text(
                                                        'READING NOW',
                                                        style: TextStyle(
                                                          fontSize: 8.5,
                                                          fontWeight: FontWeight.bold,
                                                          letterSpacing: 0.4,
                                                          color: Color(0xFFC5A059),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                surah.nameTranslation,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Theme.of(context).colorScheme.outline,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              surah.nameArabic,
                                              style: AppTypography.arabic(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFFC5A059),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${surah.revelationType} • ${surah.ayahCount} v',
                                              style: TextStyle(
                                                fontSize: 10.5,
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
                          ),
              ),
            ],
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
        fontSize: 11.5,
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
        _applyFilter();
      },
    );
  }
}
