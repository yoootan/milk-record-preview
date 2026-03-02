import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/feeding_record.dart';
import '../providers/feeding_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class SpitUpButton extends ConsumerStatefulWidget {
  const SpitUpButton({super.key});

  @override
  ConsumerState<SpitUpButton> createState() => _SpitUpButtonState();
}

class _SpitUpButtonState extends ConsumerState<SpitUpButton> {
  bool _isActive = false;
  String? _highlighted;

  final _smallKey = GlobalKey();
  final _mediumKey = GlobalKey();
  final _largeKey = GlobalKey();

  static const _smallColor = Color(0xFF5B9BD5); // Blue
  static const _mediumColor = Color(0xFFF4845F); // Orange
  static const _largeColor = Color(0xFFEF5350); // Red

  void _onPanStart(DragStartDetails details) {
    setState(() { _isActive = true; _highlighted = null; });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isActive) return;
    setState(() => _highlighted = _hitTest(details.globalPosition));
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isActive) return;
    setState(() => _isActive = false);
    if (_highlighted != null) _recordSpitUp(_highlighted!);
    _highlighted = null;
  }

  String? _hitTest(Offset globalPosition) {
    for (final entry in {
      'small': _smallKey,
      'medium': _mediumKey,
      'large': _largeKey,
    }.entries) {
      final box = entry.value.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final topLeft = box.localToGlobal(Offset.zero);
      final rect = topLeft & box.size;
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
          onLongPressStart: (_) {
            setState(() { _isActive = true; _highlighted = null; });
          },
          onLongPressMoveUpdate: (details) {
            if (!_isActive) return;
            setState(() => _highlighted = _hitTest(details.globalPosition));
          },
          onLongPressEnd: (_) {
            if (!_isActive) return;
            setState(() => _isActive = false);
            if (_highlighted != null) _recordSpitUp(_highlighted!);
            _highlighted = null;
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                decoration: BoxDecoration(
                  color: _isActive ? colors.red.withValues(alpha: 0.12) : colors.gray,
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
              // Popup
              if (_isActive)
                Positioned(
                  bottom: 40,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 20, offset: const Offset(0, -4)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildChip(s.spitUpSmall, 'small', _smallKey, colors),
                        const SizedBox(width: 6),
                        _buildChip(s.spitUpMedium, 'medium', _mediumKey, colors),
                        const SizedBox(width: 6),
                        _buildChip(s.spitUpLarge, 'large', _largeKey, colors),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, String value, GlobalKey key, ThemeColors colors) {
    final isHighlighted = _highlighted == value;
    final chipColor = _chipColor(value);
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isHighlighted ? chipColor.withValues(alpha: 0.18) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: isHighlighted ? Border.all(color: chipColor.withValues(alpha: 0.4), width: 1.5) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isHighlighted ? 15 : 14,
          fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w600,
          color: isHighlighted ? chipColor : colors.textSub,
        ),
      ),
    );
  }
}
