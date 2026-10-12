import 'package:flutter/material.dart';
import '../../../core/typography/app_typography.dart';
import '../../../core/widgets/islamic_decorations.dart';
import '../../../domain/models/hadith_models.dart';

/// Interactive modal sheet to explore and jump between canonical Hadith Books/Sections.
class HadithBooksSheet extends StatefulWidget {
  const HadithBooksSheet({
    super.key,
    required this.collectionName,
    required this.books,
    required this.selectedBookNumber,
    required this.onSelectBook,
  });

  final String collectionName;
  final List<HadithBook> books;
  final int? selectedBookNumber;
  final void Function(HadithBook? book) onSelectBook;

  static void show(
    BuildContext context, {
    required String collectionName,
    required List<HadithBook> books,
    required int? selectedBookNumber,
    required void Function(HadithBook? book) onSelectBook,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HadithBooksSheet(
        collectionName: collectionName,
        books: books,
        selectedBookNumber: selectedBookNumber,
        onSelectBook: onSelectBook,
      ),
    );
  }

  @override
  State<HadithBooksSheet> createState() => _HadithBooksSheetState();
}

class _HadithBooksSheetState extends State<HadithBooksSheet> {
  final TextEditingController _searchController = TextEditingController();
  late List<HadithBook> _filteredBooks;

  @override
  void initState() {
    super.initState();
    _filteredBooks = widget.books;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredBooks = widget.books;
      } else {
        _filteredBooks = widget.books.where((b) {
          final matchNum = b.bookNumber.toString().contains(q);
          final matchEn = b.nameEnglish.toLowerCase().contains(q);
          final matchAr = b.nameArabic.contains(q);
          return matchNum || matchEn || matchAr;
        }).toList();
      }
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
                        Text(
                          '${widget.collectionName} Books',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          '${widget.books.length} Books / Thematic Sections',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                    if (widget.selectedBookNumber != null)
                      TextButton.icon(
                        icon: const Icon(Icons.clear_rounded, size: 16),
                        label: const Text('View All'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onSelectBook(null);
                        },
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
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
                    hintText: 'Search book by name or number...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
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
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: const Color(0xFFC5A059).withValues(alpha: 0.25),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: const Color(0xFFC5A059).withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),

              const SizedBox(height: 6),
              const IslamicOrnamentalDivider(height: 12),
              const SizedBox(height: 4),

              // Books List
              Expanded(
                child: _filteredBooks.isEmpty
                    ? Center(
                        child: Text(
                          'No matching books found.',
                          style: TextStyle(color: Theme.of(context).colorScheme.outline),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _filteredBooks.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final book = _filteredBooks[index];
                          final isSelected = widget.selectedBookNumber == book.bookNumber;

                          return Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                      .withValues(alpha: 0.35)
                                  : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : const Color(0xFFC5A059).withValues(alpha: 0.18),
                                width: isSelected ? 1.4 : 1.0,
                              ),
                            ),
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              leading: RubElHizbBadge(
                                number: book.bookNumber,
                                size: 36,
                                accentColor: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : const Color(0xFFC5A059),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      book.nameEnglish,
                                      style: TextStyle(
                                        fontWeight:
                                            isSelected ? FontWeight.bold : FontWeight.w600,
                                        fontSize: 14.5,
                                      ),
                                    ),
                                  ),
                                  if (book.nameArabic.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      book.nameArabic,
                                      style: AppTypography.arabic(
                                        fontSize: 13,
                                        color: const Color(0xFFC5A059),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  '${book.hadithCount} Hadiths • Reference: #${book.firstHadithNumber} - #${book.lastHadithNumber}',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                              ),
                              trailing: Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.arrow_forward_ios_rounded,
                                size: isSelected ? 20 : 14,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline,
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                widget.onSelectBook(book);
                              },
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
}
