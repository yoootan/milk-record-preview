import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/feeding_record.dart';
import '../providers/feeding_provider.dart';
import '../theme/app_theme.dart';

class SpitUpButton extends ConsumerStatefulWidget {
  const SpitUpButton({super.key});

  @override
  ConsumerState<SpitUpButton> createState() => _SpitUpButtonState();
}

class _SpitUpButtonState extends ConsumerState<SpitUpButton> {
  bool _isActive = false;
  String? _highlighted; // 'small' | 'medium' | 'large' | null

  // Keys for hit-testing the option chips
  final _smallKey = GlobalKey();
  final _mediumKey = GlobalKey();
  final _largeKey = GlobalKey();

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isActive = true;
      _highlighted = null;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isActive) return;
    final pos = details.globalPosition;
    setState(() {
      _highlighted = _hitTest(pos);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isActive) return;
    setState(() => _isActive = false);

    if (_highlighted != null) {
      _recordSpitUp(_highlighted!);
    }
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
      if (rect.contains(globalPosition)) {
        return entry.key;
      }
    }
    return null;
  }

  void _recordSpitUp(String amount) {
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

    final label = _amountLabel(amount);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('吐き戻し（$label）記録しました'),
        backgroundColor: AppTheme.currentThemeColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _amountLabel(String amount) {
    switch (amount) {
      case 'small':
        return '少量';
      case 'medium':
        return '中量';
      case 'large':
        return '大量';
      default:
        return amount;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.currentThemeColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          // Also handle simple long press for non-drag
          onLongPressStart: (details) {
            setState(() {
              _isActive = true;
              _highlighted = null;
            });
          },
          onLongPressMoveUpdate: (details) {
            if (!_isActive) return;
            setState(() {
              _highlighted = _hitTest(details.globalPosition);
            });
          },
          onLongPressEnd: (details) {
            if (!_isActive) return;
            setState(() => _isActive = false);
            if (_highlighted != null) {
              _recordSpitUp(_highlighted!);
            }
            _highlighted = null;
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // The button itself
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                decoration: BoxDecoration(
                  color: _isActive
                      ? colors.red.withValues(alpha: 0.12)
                      : colors.gray,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      size: 14,
                      color: _isActive ? colors.red : colors.textSub,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '吐き戻し',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _isActive ? colors.red : colors.textSub,
                      ),
                    ),
                  ],
                ),
              ),
              // Popup options (positioned above button)
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
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 20,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildChip('少量', 'small', _smallKey, colors),
                        const SizedBox(width: 4),
                        _buildChip('中量', 'medium', _mediumKey, colors),
                        const SizedBox(width: 4),
                        _buildChip('大量', 'large', _largeKey, colors),
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

  Widget _buildChip(
    String label,
    String value,
    GlobalKey key,
    ThemeColors colors,
  ) {
    final isHighlighted = _highlighted == value;
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isHighlighted ? colors.accentLight : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 100),
        style: TextStyle(
          fontSize: isHighlighted ? 14 : 13,
          fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w600,
          color: isHighlighted ? colors.accent : colors.textSub,
        ),
        child: Text(label),
      ),
    );
  }
}
