import 'package:flutter/material.dart';
import '../../../app/bootstrap.dart';
import '../../../domain/models/category_models.dart';

/// Full-screen Topic Preferences screen for managing which editorial
/// categories are prioritised in the discovery feed.
///
/// Complies with Section 4.3, 5.1, and 5.2 of the Product Plan:
/// - Personalization is explicit and manually adjustable.
/// - No category is marked as an authoritative religious ruling.
/// - Toggling a category only affects feed weighting, never hides content.
class TopicPreferencesView extends StatefulWidget {
  const TopicPreferencesView({super.key});

  @override
  State<TopicPreferencesView> createState() => _TopicPreferencesViewState();
}

class _TopicPreferencesViewState extends State<TopicPreferencesView> {
  late Set<String> _selected;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selected = Set<String>.from(AppScope.of(context).preferences.selectedCategoryIds);
  }

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  Future<void> _save() async {
    final scope = AppScope.of(context);
    await scope.updatePreferences(
      scope.preferences.copyWith(selectedCategoryIds: Set<String>.from(_selected)),
    );
    if (mounted) Navigator.of(context).pop();
  }

  void _selectAll(List<Category> categories) {
    setState(() => _selected = {for (final c in categories) c.id});
  }

  void _clearAll() {
    setState(() => _selected = {});
  }

  static IconData _iconForName(String iconName) {
    const map = <String, IconData>{
      'self_improvement': Icons.self_improvement,
      'spa': Icons.spa,
      'volunteer_activism': Icons.volunteer_activism,
      'healing': Icons.healing,
      'family_restroom': Icons.family_restroom,
      'connect_without_contact': Icons.connect_without_contact,
      'travel_explore': Icons.travel_explore,
      'school': Icons.school,
      'church': Icons.church,
      'mosque': Icons.mosque,
      'star': Icons.star,
      'lightbulb': Icons.lightbulb,
      'favorite': Icons.favorite,
      'water': Icons.water,
      'nature': Icons.nature,
    };
    return map[iconName] ?? Icons.label_outline;
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Topic Preferences',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Bulk options',
            onSelected: (value) async {
              final cats = await scope.contentRepository.getCategories();
              if (value == 'all') _selectAll(cats);
              if (value == 'none') _clearAll();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'all', child: Text('Select all topics')),
              PopupMenuItem(value: 'none', child: Text('Clear all topics')),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<Category>>(
        future: scope.contentRepository.getCategories(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = snapshot.data!;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'Choose the topics you want to see more of in your Discover feed. '
                  'These are editorial discovery aids — not authoritative rulings.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
              // Selection count chip
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _selected.isEmpty
                          ? Chip(
                              key: const ValueKey('all'),
                              avatar: const Icon(Icons.all_inclusive, size: 16),
                              label: const Text('All topics active'),
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                            )
                          : Chip(
                              key: ValueKey(_selected.length),
                              avatar: Icon(
                                Icons.check_circle_outline,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              label: Text('${_selected.length} of ${categories.length} prioritised'),
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                            ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
                  itemBuilder: (context, i) {
                    final cat = categories[i];
                    final isSelected = _selected.contains(cat.id);

                    return CheckboxListTile(
                      secondary: CircleAvatar(
                        radius: 20,
                        backgroundColor: isSelected
                            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Icon(
                          _iconForName(cat.iconName),
                          size: 18,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      title: Text(
                        cat.title,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
                      ),
                      subtitle: Text(
                        cat.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      value: isSelected,
                      onChanged: (_) => _toggle(cat.id),
                      controlAffinity: ListTileControlAffinity.trailing,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    );
                  },
                ),
              ),
              // Pinned Save Button
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  12 + MediaQuery.of(context).padding.bottom,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Save Topic Preferences'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
