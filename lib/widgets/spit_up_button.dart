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
  OverlayEntry? _overlayEntry;
  final _triggerKey = GlobalKey();

  final _smallKey = GlobalKey();
  final _mediumKey = GlobalKey();
  final _largeKey = GlobalKey();

  late AnimationController _arcController;
  late Animation<double> _arcAnimation;

  static const _smallColor = Color(0xFF5B9BD5);
  static const _mediumColor = Color(0xFFF4845F);
  static const _largeColor = Color(0xFFEF5350);

  static const _arcRadius = 100.0;
  static const _buttonSize = 58.0;
  // Angles: wider spread so buttons don't overlap
  static const _angles = [
    2.7,  // large  - leftmost
    2.0,  // medium - middle
    1.3,  // small  - upper-right
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
    _arcController.addListener(_updateOverlay);
  }

  @override
  void dispose() {
    _removeOverlay();
    _arcController.removeListener(_updateOverlay);
    _arcController.dispose();
    super.dispose();
  }

  void _updateOverlay() {
    _overlayEntry?.markNeedsBuild();
  }

  Offset _getTriggerCenter() {
    final box =
        _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return Offset.zero;
    final pos = box.localToGlobal(Offset.zero);
    return Offset(pos.dx + box.size.width / 2, pos.dy + box.size.height / 2);
  }

  void _showOverlay() {
    _removeOverlay();
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (_) => _buildOverlayContent(),
    );
    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildOverlayContent() {
    final colors = ref.read(colorsProvider);
    final s = ref.read(stringsProvider);
    final center = _getTriggerCenter();

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: List.generate(_values.length, (i) {
        final value = _values[i];
        final angle = _angles[i];
        final delay = i * 0.10;
        return _buildArcButtonOverlay(
          value: value,
          label: _labelFor(value, s),
          angle: angle,
          delay: delay,
          center: center,
          colors: colors,
        );
      }),
      ),
    );
  }

  Widget _buildArcButtonOverlay({
    required String value,
    required String label,
    required double angle,
    required double delay,
    required Offset center,
    required dynamic colors,
  }) {
    final isHighlighted = _highlighted == value;
    final chipColor = _chipColor(value);
    final key = _keyFor(value);

    final targetDx = cos(angle) * _arcRadius;
    final targetDy = -sin(angle) * _arcRadius;

    final raw =
        ((_arcAnimation.value - delay) / (1.0 - delay)).clamp(0.0, 1.0);

    final currentDx = targetDx * raw;
    final currentDy = targetDy * raw;

    final left = center.dx + currentDx - _buttonSize / 2;
    final top = center.dy + currentDy - _buttonSize / 2;

    return Positioned(
      left: left,
      top: top,
      child: Transform.scale(
        scale: raw,
        child: Opacity(
          opacity: raw,
          child: Container(
            key: key,
            width: _buttonSize,
            height: _buttonSize,
            decoration: BoxDecoration(
              color: isHighlighted ? chipColor : colors.card,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isHighlighted
                      ? chipColor.withValues(alpha: 0.4)
                      : Colors.black.withValues(alpha: 0.10),
                  blurRadius: isHighlighted ? 14 : 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isHighlighted ? 13 : 12,
                  fontWeight: FontWeight.w700,
                  color: isHighlighted ? Colors.white : chipColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _activate() {
    setState(() {
      _isActive = true;
      _highlighted = null;
    });
    _showOverlay();
    _arcController.forward(from: 0);
  }

  void _deactivate({String? selected}) {
    _arcController.reverse().then((_) {
      _removeOverlay();
    });
    setState(() => _isActive = false);
    if (selected != null) _recordSpitUp(selected);
    _highlighted = null;
  }

  void _onPanStart(DragStartDetails details) => _activate();

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isActive) return;
    final prev = _highlighted;
    _highlighted = _hitTest(details.globalPosition);
    if (_highlighted != prev) {
      setState(() {});
      _overlayEntry?.markNeedsBuild();
    }
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
      final rect = (topLeft & box.size).inflate(8);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _amountLabel(String amount, dynamic s) {
    switch (amount) {
      case 'small': return s.spitUpSmall;
      case 'medium': return s.spitUpMedium;
      case 'large': return s.spitUpLarge;
      default: return amount;
    }
  }

  Color _chipColor(String value) {
    switch (value) {
      case 'small': return _smallColor;
      case 'medium': return _mediumColor;
      case 'large': return _largeColor;
      default: return _smallColor;
    }
  }

  GlobalKey _keyFor(String value) {
    switch (value) {
      case 'small': return _smallKey;
      case 'medium': return _mediumKey;
      case 'large': return _largeKey;
      default: return _smallKey;
    }
  }

  String _labelFor(String value, dynamic s) {
    switch (value) {
      case 'small': return s.spitUpSmall;
      case 'medium': return s.spitUpMedium;
      case 'large': return s.spitUpLarge;
      default: return value;
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
            final prev = _highlighted;
            _highlighted = _hitTest(details.globalPosition);
            if (_highlighted != prev) {
              setState(() {});
              _overlayEntry?.markNeedsBuild();
            }
          },
          onLongPressEnd: (_) {
            if (!_isActive) return;
            _deactivate(selected: _highlighted);
          },
          child: Container(
            key: _triggerKey,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
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
      ),
    );
  }
}
