import 'package:flutter/material.dart';
import '../data/mock_data.dart';

/// Top filter bar: a date-range selector plus horizontally scrollable
/// category chips and a sort toggle. UI-only — selections are local state.
class FilterBar extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final String dateLabel;
  final VoidCallback onPickDate;
  final bool sortByTime;
  final ValueChanged<bool> onSortChanged;

  const FilterBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.dateLabel,
    required this.onPickDate,
    required this.sortByTime,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPickDate,
                icon: const Icon(Icons.calendar_today_rounded, size: 16),
                label: Text(dateLabel),
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _sortBtn(context, 'Time', sortByTime, () => onSortChanged(true)),
                  _sortBtn(context, 'Visits', !sortByTime, () => onSortChanged(false)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: MockData.categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final cat = MockData.categories[i];
              final selected = cat == selectedCategory;
              return ChoiceChip(
                label: Text(cat),
                selected: selected,
                onSelected: (_) => onCategorySelected(cat),
                labelStyle: TextStyle(
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? scheme.onPrimary : scheme.onSurface,
                ),
                selectedColor: scheme.primary,
                showCheckmark: false,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _sortBtn(
    BuildContext context,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
