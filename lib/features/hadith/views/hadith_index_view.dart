import 'package:flutter/material.dart';
import '../../../app/bootstrap.dart';
import '../../../core/typography/app_typography.dart';
import '../../../core/widgets/islamic_decorations.dart';
import '../../../domain/models/hadith_models.dart';
import 'hadith_books_sheet.dart';
import 'hadith_reader_view.dart';

/// Hadith collection explorer supporting Sahih al-Bukhari and Sahih Muslim.
/// Complies with Section 4.2 of the Product Plan with illuminated Islamic styling.
class HadithIndexView extends StatefulWidget {
  const HadithIndexView({
    super.key,
    this.initialCollectionId = 'bukhari',
    this.showAppBar = false,
  });

  final String initialCollectionId;
  final bool showAppBar;

  @override
  State<HadithIndexView> createState() => _HadithIndexViewState();
}

class _HadithIndexViewState extends State<HadithIndexView> {
  late String _selectedCollectionId;
  List<HadithCollection> _collections = [];
  List<HadithItem> _hadiths = [];
  List<HadithBook> _books = [];
  List<HadithItem> _filteredHadiths = [];
  int? _selectedBookNumber;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _selectedCollectionId = widget.initialCollectionId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _loadData();
      _initialized = true;
    }
  }

  Future<void> _loadData() async {
    final scope = AppScope.of(context);
    final cols = await scope.contentRepository.getHadithCollections();
    final hadiths = await scope.contentRepository.getHadiths(collectionId: _selectedCollectionId);
    final books = await scope.contentRepository.getHadithBooks(_selectedCollectionId);
    if (!mounted) return;

    setState(() {
      _collections = cols;
      _hadiths = hadiths;
      _books = books;
      _applyFilter();
      _isLoading = false;
    });
  }

  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();
    var list = _hadiths;

    if (_selectedBookNumber != null) {
      list = list.where((h) => h.bookNumber == _selectedBookNumber).toList();
    }

    if (query.isNotEmpty) {
      list = list.where((h) {
        return h.hadithNumber.toString().contains(query) ||
            h.narrator.toLowerCase().contains(query) ||
            h.englishTranslation.toLowerCase().contains(query) ||
            h.bookNameEnglish.toLowerCase().contains(query) ||
            h.arabicText.contains(query);
      }).toList();
    }

    _filteredHadiths = list;
  }

  void _switchCollection(String colId) async {
    if (colId == _selectedCollectionId) return;
    setState(() {
      _selectedCollectionId = colId;
      _selectedBookNumber = null;
      _isLoading = true;
    });
    final scope = AppScope.of(context);
    final hadiths = await scope.contentRepository.getHadiths(collectionId: colId);
    final books = await scope.contentRepository.getHadithBooks(colId);
    if (!mounted) return;

    setState(() {
      _hadiths = hadiths;
      _books = books;
      _applyFilter();
      _isLoading = false;
    });
  }

  void _openBooksSheet() {
    final colName = _selectedCollectionId == 'bukhari' ? 'Sahih al-Bukhari' : 'Sahih Muslim';
    HadithBooksSheet.show(
      context,
      collectionName: colName,
      books: _books,
      selectedBookNumber: _selectedBookNumber,
      onSelectBook: (book) {
        setState(() {
          _selectedBookNumber = book?.bookNumber;
          _applyFilter();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final currentCol = _collections.firstWhere(
      (c) => c.id == _selectedCollectionId,
      orElse: () => HadithCollection(
        id: _selectedCollectionId,
        nameEnglish: _selectedCollectionId == 'bukhari' ? 'Sahih al-Bukhari' : 'Sahih Muslim',
        nameArabic: _selectedCollectionId == 'bukhari' ? 'صحيح البخاري' : 'صحيح مسلم',
        author: _selectedCollectionId == 'bukhari'
            ? 'Imam Muhammad al-Bukhari'
            : 'Imam Muslim ibn al-Hajjaj',
        description: '',
        totalHadiths: 0,
        attribution: '',
      ),
    );

    final lastProgress = scope.lastHadithProgress;
    final selectedBook = _selectedBookNumber != null
        ? _books.firstWhere((b) => b.bookNumber == _selectedBookNumber,
            orElse: () => HadithBook(
                  collectionId: _selectedCollectionId,
                  bookNumber: _selectedBookNumber!,
                  nameEnglish: 'Book $_selectedBookNumber',
                  nameArabic: '',
                  hadithCount: 0,
                  firstHadithNumber: 0,
                  lastHadithNumber: 0,
                ))
        : null;

    Widget body = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // Collection Segmented Selector
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 4.0),
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'bukhari',
                      label: Text('Sahih al-Bukhari', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    ButtonSegment(
                      value: 'muslim',
                      label: Text('Sahih Muslim', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                  selected: {_selectedCollectionId},
                  onSelectionChanged: (set) => _switchCollection(set.first),
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),

              // Book filter and collection summary strip
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Row(
                  children: [
                    Flexible(
                      child: ActionChip(
                        avatar: Icon(
                          Icons.menu_book_rounded,
                          size: 16,
                          color: selectedBook != null ? Theme.of(context).colorScheme.primary : null,
                        ),
                        label: Text(
                          selectedBook != null
                              ? 'Book ${selectedBook.bookNumber}: ${selectedBook.nameEnglish}'
                              : 'Browse ${_books.length} Books',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: selectedBook != null ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        onPressed: _openBooksSheet,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    if (selectedBook != null) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16),
                        tooltip: 'Clear book filter',
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          setState(() {
                            _selectedBookNumber = null;
                            _applyFilter();
                          });
                        },
                      ),
                    ],
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${currentCol.nameArabic} • ${_filteredHadiths.length} Hadiths',
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Resume Banner
              if (lastProgress != null && lastProgress.targetId == _selectedCollectionId)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFC5A059).withValues(alpha: 0.12),
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFC5A059).withValues(alpha: 0.30),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC5A059).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_stories_rounded,
                          color: Color(0xFFC5A059),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'RESUME READING',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.7,
                                color: Color(0xFFC5A059),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${lastProgress.title} • ${lastProgress.subtitle}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                            ),
                          ],
                        ),
                      ),
                      FilledButton.tonal(
                        onPressed: () {
                          final hadith = _hadiths.firstWhere(
                            (h) => h.hadithNumber == lastProgress.itemNumber,
                            orElse: () => _hadiths.first,
                          );
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => HadithReaderView(hadith: hadith),
                            ),
                          );
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

              // Search Hadiths Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: selectedBook != null
                        ? 'Search inside Book ${selectedBook.bookNumber}...'
                        : 'Search hadith, narrator, or keyword...',
                    prefixIcon: Icon(Icons.search, size: 20, color: Theme.of(context).colorScheme.outline),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(_applyFilter);
                              FocusScope.of(context).unfocus();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
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
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                        width: 1.2,
                      ),
                    ),
                  ),
                  onChanged: (_) => setState(_applyFilter),
                ),
              ),

                // Hadiths List
                Expanded(
                  child: _filteredHadiths.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off_rounded,
                                  size: 40, color: Theme.of(context).colorScheme.outline),
                              const SizedBox(height: 8),
                              Text(
                                'No matching hadiths found',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          itemCount: _filteredHadiths.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final hadith = _filteredHadiths[index];

                            return Card(
                              elevation: 0,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => HadithReaderView(hadith: hadith),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Top row: RubElHizbBadge + Narrator + Grading
                                      Row(
                                        children: [
                                          RubElHizbBadge(
                                            number: hadith.hadithNumber,
                                            size: 38,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Narrated by ${hadith.narrator}',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(
                                                color: Colors.green.withValues(alpha: 0.35),
                                                width: 0.8,
                                              ),
                                            ),
                                            child: Text(
                                              hadith.grading.toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),

                                      // Arabic excerpt snippet
                                      if (hadith.arabicText.isNotEmpty)
                                        Container(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest
                                                .withValues(alpha: 0.25),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            hadith.arabicText,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.right,
                                            textDirection: TextDirection.rtl,
                                            style: AppTypography.arabic(
                                              fontSize: 15,
                                              height: 1.4,
                                              color: const Color(0xFFC5A059),
                                            ),
                                          ),
                                        ),

                                      // English translation
                                      Text(
                                        hadith.englishTranslation,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          height: 1.45,
                                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      // Footer: Book name and chapter
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.library_books_rounded,
                                            size: 13,
                                            color: Theme.of(context).colorScheme.outline,
                                          ),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                              'Book ${hadith.bookNumber}: ${hadith.bookNameEnglish}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                color: Theme.of(context).colorScheme.outline,
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
                        ),
                ),
              ],
            );

    if (widget.showAppBar) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Hadith Collections', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu_book_rounded),
              tooltip: 'Browse by Book',
              onPressed: _openBooksSheet,
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: body,
      );
    }

    return body;
  }
}
