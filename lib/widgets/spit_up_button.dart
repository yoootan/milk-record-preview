import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/feeding_record.dart';
import '../providers/feeding_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';

class SpitUpButton extends ConsumerStatefulWidget {
  const SpitUpButton({super.key});

  @override
  ConsumerState<SpitUpButton> createState() => _SpitUpButtonState();
}

class _SpitUpButtonState extends ConsumerState<SpitUpButton>
    with TickerProviderStateMixin {
  bool _isActive = false;
  String? _highlighted;

  final _smallKey = GlobalKey();
  final _mediumKey = GlobalKey();
  final _largeKey = GlobalKey();

  late AnimationController _arcController;
  late Animation<double> _arcAnimation;

  static const _smallColor = Color(0xFF5B9BD5);
  static const _mediumColor = Color(0xFFF4845F);
  static const _largeColor = Color(0xFFEF5350);

  // Arc config: 3 buttons arranged in an arc above-left of the trigger button
  // Angles in radians from the trigger button center (0 = right, pi/2 = up, pi = left)
  static const _arcRadius = 80.0;
  static const _buttonSize = 52.0;
  // Angles: spread across upper-left arc
  static const _angles = [
    2.6,   // large  - leftmost
    2.05,  // medium - middle
    1.5,   // small  - topmost (≈ straight up)
  ];
  static const _values = ['large', 'medium', 'small'];

  @override
  void initState() {
    super.initState();
    _arcController = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );
    _arcAnimation = CurvedAnimation(
      parent: _arcController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _arcController.dispose();
    super.dispose();
  }

  void _activate() {
    setState(() {
      _isActive = true;
      _highlighted = null;
    });
    _arcController.forward(from: 0);
  }

  void _deactivate({String? selected}) {
    setState(() => _isActive = false);
    _arcController.reverse();
    if (selected != null) _recordSpitUp(selected);
    _highlighted = null;
  }

  void _onPanStart(DragStartDetails details) => _activate();

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isActive) return;
    setState(() => _highlighted = _hitTest(details.globalPosition));
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isActive) return;
    _deactivate(selected: _highlighted);
  }

  String? _hitTest(Offset globalPosition) {
    final keys = {
      'small': _smallKey,
      'medium': _mediumKey,
      'large': _largeKey,
    };
    for (final entry in keys.entries) {
      final box =
          entry.value.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final topLeft = box.localToGlobal(Offset.zero);
      // Expand hit area slightly for easier targeting
      final rect = (topLeft & box.size).inflate(6);
      if (rect.contains(globalPosition)) return entry.key;
    }
    return null;
  }

  void _recordSpitUp(String amount) {
    final s = ref.read(stringsProvider);
    final colors = ref.read(colorsProvider);
    final now = DateTime.now();
    final record = FeedingRecord(
      id: const Uuid().v4(),
      type: 'spitUp',
      durationSeconds: 0,
      startedAt: now,
      endedAt: now,
      spitUpAmount: amount,
    );
    ref.read(feedingRecordsProvider.notifier).addRecord(record);

    final label = _amountLabel(amount, s);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.spitUpRecorded(label)),
        backgroundColor: colors.accent,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _amountLabel(String amount, dynamic s) {
    switch (amount) {
      case 'small':
        return s.spitUpSmall;
      case 'medium':
        return s.spitUpMedium;
      case 'large':
        return s.spitUpLarge;
      default:
        return amount;
    }
  }

  Color _chipColor(String value) {
    switch (value) {
      case 'small':
        return _smallColor;
      case 'medium':
        return _mediumColor;
      case 'large':
        return _largeColor;
      default:
        return _smallColor;
    }
  }

  GlobalKey _keyFor(String value) {
    switch (value) {
      case 'small':
        return _smallKey;
      case 'medium':
        return _mediumKey;
      case 'large':
        return _largeKey;
      default:
        return _smallKey;
    }
  }

  String _labelFor(String value, dynamic s) {
    switch (value) {
      case 'small':
        return s.spitUpSmall;
      case 'medium':
        return s.spitUpMedium;
      case 'large':
        return s.spitUpLarge;
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(colorsProvider);
    final s = ref.watch(stringsProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          onLongPressStart: (_) => _activate(),
          onLongPressMoveUpdate: (details) {
            if (!_isActive) return;
            setState(
                () => _highlighted = _hitTest(details.globalPosition));
          },
          onLongPressEnd: (_) {
            if (!_isActive) return;
            _deactivate(selected: _highlighted);
          },
          child: SizedBox(
            width: _arcRadius + _buttonSize + 20,
            height: _arcRadius + _buttonSize + 20,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Arc buttons
                ...List.generate(_values.length, (i) {
                  final value = _values[i];
                  final angle = _angles[i];
                  // Stagger: each button starts slightly later
                  final delay = i * 0.12;
                  return _buildArcButton(
                    value: value,
                    label: _labelFor(value, s),
                    angle: angle,
                    delay: delay,
                    colors: colors,
                  );
                }),
                // Trigger button (bottom-right of the SizedBox)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 7),
                    decoration: BoxDecoration(
                      color: _isActive
                          ? colors.red.withValues(alpha: 0.12)
                          : colors.gray,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      s.spitUp,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _isActive ? colors.red : colors.textSub,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArcButton({
    required String value,
    required String label,
    required double angle,
    required double delay,
    required dynamic colors,
  }) {
    final isHighlighted = _highlighted == value;
    final chipColor = _chipColor(value);
    final key = _keyFor(value);

    // Position: offset from bottom-right corner (trigger button center)
    final dx = cos(angle) * _arcRadius;
    final dy = -sin(angle) * _arcRadius;

    return AnimatedBuilder(
      animation: _arcAnimation,
      builder: (context, child) {
        // Staggered progress
        final raw =
            ((_arcAnimation.value - delay) / (1.0 - delay)).clamp(0.0, 1.0);
        final progress = raw;

        return Positioned(
          bottom: -dy * progress + (_buttonSize / 2) - 4,
          right: -dx * progress + (_buttonSize / 2) - 20,
          child: Transform.scale(
            scale: progress,
            child: Opacity(
              opacity: progress,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        key: key,
        width: _buttonSize,
        height: _buttonSize,
        decoration: BoxDecoration(
          color: isHighlighted
              ? chipColor
              : colors.card,
          shape: BoxShape.circle,
          border: Border.all(
            color: isHighlighted
                ? chipColor
                : chipColor.withValues(alpha: 0.3),
            width: isHighlighted ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isHighlighted
                  ? chipColor.withValues(alpha: 0.35)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: isHighlighted ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isHighlighted ? 12 : 11,
              fontWeight: FontWeight.w700,
              color: isHighlighted ? Colors.white : chipColor,
            ),
          ),
        ),
      ),
    );
  }
}
