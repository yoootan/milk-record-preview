import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';
import '../theme/app_theme.dart';

class LiveBanner extends ConsumerStatefulWidget {
  const LiveBanner({super.key});

  @override
  ConsumerState<LiveBanner> createState() => _LiveBannerState();
}

class _LiveBannerState extends ConsumerState<LiveBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _updateTimer;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _generateCount();
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _generateCount();
    });
  }

  void _generateCount() {
    final h = DateTime.now().hour;
    final base = 800 + Random().nextInt(600);
    double mult = 1;
    if (h >= 0 && h < 5) {
      mult = 0.3;
    } else if (h >= 5 && h < 8) {
      mult = 0.7;
    } else if (h >= 8 && h < 12) {
      mult = 1.2;
    } else if (h >= 12 && h < 18) {
      mult = 1.0;
    } else if (h >= 18 && h < 21) {
      mult = 1.3;
    } else {
      mult = 0.8;
    }
    setState(() {
      _count = (base * mult + Random().nextInt(50) - 25).round();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.currentThemeColors;
    final s = ref.watch(stringsProvider);
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colors.liveBg,
        border: Border.all(color: colors.liveBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _pulseAnimation.value,
                child: Transform.scale(
                  scale: 0.85 + (_pulseAnimation.value * 0.15),
                  child: child,
                ),
              );
            },
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: colors.green, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            s.liveBanner(_count),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.textSub,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
