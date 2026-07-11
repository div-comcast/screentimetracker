import 'package:flutter/material.dart';
import '../data/mock_data.dart';

/// A simple vertical bar chart drawn with plain widgets (no chart package).
/// Highlights the peak bar and shows a label under each column.
class SimpleBarChart extends StatelessWidget {
  final List<BarData> bars;
  final double height;
  final Color color;

  const SimpleBarChart({
    super.key,
    required this.bars,
    this.height = 180,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxValue = bars.isEmpty
        ? 1
        : bars.map((b) => b.value).reduce((a, b) => a > b ? a : b);
    final safeMax = maxValue == 0 ? 1 : maxValue;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final bar in bars)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    bar.value == 0 ? '' : formatMinutes(bar.value),
                    style: TextStyle(
                      fontSize: 8.5,
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                  const SizedBox(height: 4),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    tween: Tween(begin: 0, end: bar.value / safeMax),
                    builder: (context, t, _) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: (height - 48) * t,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: bar.highlight
                              ? [color, color.withValues(alpha: 0.65)]
                              : [
                                  color.withValues(alpha: 0.55),
                                  color.withValues(alpha: 0.30),
                                ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    bar.label,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight:
                          bar.highlight ? FontWeight.w700 : FontWeight.w500,
                      color: bar.highlight ? color : scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class BarData {
  final String label;
  final int value;
  final bool highlight;
  const BarData({
    required this.label,
    required this.value,
    this.highlight = false,
  });
}
