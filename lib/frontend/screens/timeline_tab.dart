import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/section_header.dart';

/// Day timeline: a vertical, chronological flow of app-usage blocks.
class TimelineTab extends StatelessWidget {
  const TimelineTab({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final blocks = MockData.timeline;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.timeline_rounded, color: scheme.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Your day, app by app',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  formatMinutes(MockData.totalScreenMinutes),
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: scheme.primary,
                      fontSize: 15),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const SectionHeader(
            title: 'Timeline flow', icon: Icons.route_rounded),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (var i = 0; i < blocks.length; i++)
                  _TimelineRow(
                    block: blocks[i],
                    isLast: i == blocks.length - 1,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final TimelineBlock block;
  final bool isLast;
  const _TimelineRow({required this.block, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 46,
            child: Column(
              children: [
                Text(
                  block.start,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  block.end,
                  style: TextStyle(
                    fontSize: 10,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: block.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: block.color.withValues(alpha: 0.3), width: 3),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: scheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: block.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: block.color.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: block.color.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child:
                          Icon(block.icon, color: block.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            block.appName,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700),
                          ),
                          Text(
                            block.category,
                            style: TextStyle(
                                fontSize: 11.5,
                                color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formatMinutes(block.minutes),
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: block.color),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
