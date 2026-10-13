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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.50,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Apple-style Grab handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 36,
                height: 4.5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 16, 8),
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
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          '${_surahs.length} Chapters of the Noble Quran',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      tooltip: 'Close',
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Apple-style Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Surah by name or number...',
                    prefixIcon: Icon(Icons.search, size: 20, color: theme.colorScheme.outline),
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
                    fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary.withValues(alpha: 0.4),
                        width: 1.2,
                      ),
                    ),
                  ),
                  onChanged: (_) => _applyFilter(),
                ),
              ),

              // Apple-style Revelation Segmented Control
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E1E1E)
                        : const Color(0xFFEBEBF0),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    children: [
                      _buildAppleSegment('All', _surahs.length, isDark),
                      _buildAppleSegment('Meccan', 86, isDark),
                      _buildAppleSegment('Medinan', 28, isDark),
                    ],
                  ),
                ),
              ),

              Divider(
                height: 1,
                thickness: 0.6,
                color: theme.dividerColor.withValues(alpha: 0.12),
              ),

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
                                  color: theme.colorScheme.outline,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No matching Surahs found',
                                  style: TextStyle(
                                    color: theme.colorScheme.outline,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            itemCount: _filteredSurahs.length,
                            separatorBuilder: (_, index) => Divider(
                              height: 1,
                              thickness: 0.6,
                              indent: 54,
                              color: theme.dividerColor.withValues(alpha: 0.12),
                            ),
                            itemBuilder: (context, index) {
                              final surah = _filteredSurahs[index];
                              final isCurrent = surah.number == widget.currentSurahNumber;

                              return Material(
                                color: isCurrent
                                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.22)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    widget.onSelectSurah(surah);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    child: Row(
                                      children: [
                                        RubElHizbBadge(
                                          number: surah.number,
                                          size: 36,
                                          accentColor: isCurrent ? theme.colorScheme.primary : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      surah.nameEnglish,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                                        fontSize: 15,
                                                        color: isCurrent ? theme.colorScheme.primary : null,
                                                      ),
                                                    ),
                                                  ),
                                                  if (isCurrent) ...[
                                                    const SizedBox(width: 6),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                                      decoration: BoxDecoration(
                                                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: Text(
                                                        'READING NOW',
                                                        style: TextStyle(
                                                          fontSize: 8.5,
                                                          fontWeight: FontWeight.bold,
                                                          letterSpacing: 0.3,
                                                          color: theme.colorScheme.primary,
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
                                                  color: theme.colorScheme.outline,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 105),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                surah.nameArabic,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: AppTypography.arabic(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(0xFFC5A059),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${surah.revelationType} • ${surah.ayahCount} v',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  color: theme.colorScheme.outline,
                                                ),
                                              ),
                                            ],
                                          ),
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

  Widget _buildAppleSegment(String type, int count, bool isDark) {
    final isSelected = _revelationFilter == type;
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _revelationFilter = type;
          });
          _applyFilter();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF2C2C2E) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Text(
            '$type ($count)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.outline,
            ),
          ),
        ),
      ),
    );
  }
}
