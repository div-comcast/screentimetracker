import 'package:flutter/material.dart';
import '../../backend/bridge/cache_data.dart';

class LoadingScreen extends StatefulWidget {
  final Widget child;

  const LoadingScreen({super.key, required this.child});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  String _status = 'Loading your data...';
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final start = today.subtract(const Duration(days: 20));

      setState(() => _status = 'Fetching usage data...');
      await fetchRawCache(startDate: start, endDate: today);

      setState(() => _status = 'Almost ready...');
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        setState(() => _done = true);
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, _, _) => widget.child,
            transitionsBuilder: (_, anim, _, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _status = 'Could not load data.\nUsing offline mode.');
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => widget.child),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2EDE4),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated icon
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, _) {
                final scale = 1.0 + _pulseCtrl.value * 0.12;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE87070).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.hourglass_top_rounded,
                      size: 36,
                      color: Color(0xFFE87070),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Status text
            Text(
              _status,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            // Progress indicator
            if (!_done)
              const SizedBox(
                width: 140,
                child: LinearProgressIndicator(
                  backgroundColor: Color(0xFFE0D6CA),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xFFE87070)),
                  minHeight: 3,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
