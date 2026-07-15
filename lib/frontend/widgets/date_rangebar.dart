import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DateBar extends StatelessWidget {
  final DateTime start;
  final DateTime? end;
  final VoidCallback onTap;       // tapping date label opens calendar
  final VoidCallback? onBack;     // null = arrow disabled
  final VoidCallback? onForward;  // null = arrow disabled

  const DateBar({
    super.key,
    required this.start,
    this.end,
    required this.onTap,
    this.onBack,
    this.onForward,
  });

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String get _label {
    if (end == null) {
      return '${_months[start.month - 1]} ${start.day}, ${start.year}';
    }
    if (start.year == end!.year) {
      return '${_months[start.month - 1]} ${start.day} – '
          '${_months[end!.month - 1]} ${end!.day}, ${start.year}';
    }
    return '${_months[start.month - 1]} ${start.day}, ${start.year} – '
        '${_months[end!.month - 1]} ${end!.day}, ${end!.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Back arrow
          _ArrowButton(
            icon: Icons.chevron_left_rounded,
            onTap: onBack,
          ),
          const SizedBox(width: 2),
          // Date label — tapping opens calendar
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 2),
          // Forward arrow
          _ArrowButton(
            icon: Icons.chevron_right_rounded,
            onTap: onForward,
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ArrowButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 22,
          color: enabled ? AppColors.textPrimary : Colors.grey.shade300,
        ),
      ),
    );
  }
}
