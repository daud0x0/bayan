import 'package:flutter/material.dart';
import '../../app/bootstrap.dart';
import '../../domain/models/category_models.dart';

/// Modal bottom sheet to explore all 15 editorial categories.
/// Complies with Section 5.1 of the Product Plan.
class CategoryExplorerSheet extends StatelessWidget {
  const CategoryExplorerSheet({super.key, required this.onSelectCategory});

  final ValueChanged<Category> onSelectCategory;

  static void show(BuildContext context, {required ValueChanged<Category> onSelectCategory}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategoryExplorerSheet(onSelectCategory: onSelectCategory),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.40,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Editorial Categories',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Curated thematic discovery aids',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: FutureBuilder<List<Category>>(
                  future: scope.contentRepository.getCategories(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final categories = snapshot.data!;
                    final selectedIds = scope.preferences.selectedCategoryIds;

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: categories.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected = selectedIds.contains(cat.id);

                        return Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            title: Text(
                              cat.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                cat.description,
                                style: const TextStyle(fontSize: 12.5),
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                isSelected ? Icons.check_circle : Icons.add_circle_outline,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline,
                              ),
                              tooltip: isSelected ? 'Remove from feed' : 'Add to feed',
                              onPressed: () {
                                final updated = Set<String>.from(selectedIds);
                                if (isSelected) {
                                  updated.remove(cat.id);
                                } else {
                                  updated.add(cat.id);
                                }
                                scope.updatePreferences(
                                  scope.preferences.copyWith(selectedCategoryIds: updated),
                                );
                              },
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                              onSelectCategory(cat);
                            },
                          ),
                        );
                      },
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
