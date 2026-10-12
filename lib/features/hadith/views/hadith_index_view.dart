import 'package:flutter/material.dart';
import '../../../app/bootstrap.dart';
import '../../../core/typography/app_typography.dart';
import '../../../domain/models/hadith_models.dart';
import 'hadith_reader_view.dart';

/// Hadith collection explorer supporting Sahih al-Bukhari and Sahih Muslim.
/// Complies with Section 4.2 of the Product Plan.
class HadithIndexView extends StatefulWidget {
  const HadithIndexView({super.key, this.initialCollectionId = 'bukhari'});

  final String initialCollectionId;

  @override
  State<HadithIndexView> createState() => _HadithIndexViewState();
}

class _HadithIndexViewState extends State<HadithIndexView> {
  late String _selectedCollectionId;
  List<HadithCollection> _collections = [];
  List<HadithItem> _hadiths = [];
  bool _isLoading = true;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _selectedCollectionId = widget.initialCollectionId;
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
    if (!mounted) return;

    setState(() {
      _collections = cols;
      _hadiths = hadiths;
      _isLoading = false;
    });
  }

  void _switchCollection(String colId) async {
    if (colId == _selectedCollectionId) return;
    setState(() {
      _selectedCollectionId = colId;
      _isLoading = true;
    });
    final scope = AppScope.of(context);
    final hadiths = await scope.contentRepository.getHadiths(collectionId: colId);
    if (!mounted) return;

    setState(() {
      _hadiths = hadiths;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final currentCol = _collections.firstWhere(
      (c) => c.id == _selectedCollectionId,
      orElse: () => HadithCollection(
        id: _selectedCollectionId,
        nameEnglish: _selectedCollectionId == 'bukhari' ? 'Sahih al-Bukhari' : 'Sahih Muslim',
        nameArabic: '',
        author: '',
        description: '',
        totalHadiths: 0,
        attribution: '',
      ),
    );

    final lastProgress = scope.lastHadithProgress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hadith Collections', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Collection Segmented Selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'bukhari',
                        label: Text('Sahih al-Bukhari'),
                      ),
                      ButtonSegment(
                        value: 'muslim',
                        label: Text('Sahih Muslim'),
                      ),
                    ],
                    selected: {_selectedCollectionId},
                    onSelectionChanged: (set) => _switchCollection(set.first),
                  ),
                ),

                // Resume Banner
                if (lastProgress != null && lastProgress.targetId == _selectedCollectionId)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                                'Resume Reading',
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
                          child: const Text('Resume'),
                        ),
                      ],
                    ),
                  ),

                // Collection Overview Banner
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentCol.nameEnglish,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              currentCol.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        currentCol.nameArabic,
                        style: AppTypography.arabic(fontSize: 18, height: 1.4),
                      ),
                    ],
                  ),
                ),

                // Hadiths List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _hadiths.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final hadith = _hadiths[index];

                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            child: Text(
                              hadith.hadithNumber.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          title: Text(
                            'Narrated by ${hadith.narrator}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                hadith.englishTranslation,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12.5),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    hadith.bookNameEnglish,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      hadith.grading.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => HadithReaderView(hadith: hadith),
                              ),
                            );
                          },
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
