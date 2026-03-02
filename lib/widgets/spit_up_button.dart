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

class _SpitUpButtonState extends ConsumerState<SpitUpButton>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
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
        content: Text('吐き戻し（$label）を記録しました'),
        backgroundColor: AppTheme.currentThemeColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    _toggle();
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_isExpanded)
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAmountChip('少量', 'small', const Color(0xFFFFF3E0)),
                    const SizedBox(width: 4),
                    _buildAmountChip('中量', 'medium', const Color(0xFFFFE0B2)),
                    const SizedBox(width: 4),
                    _buildAmountChip('大量', 'large', const Color(0xFFFFCCBC)),
                  ],
                ),
              ),
            ),
          GestureDetector(
            onTap: _toggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _isExpanded
                    ? const Color(0xFFEF5350).withValues(alpha: 0.12)
                    : AppTheme.currentThemeColors.gray,
                borderRadius: BorderRadius.circular(20),
                border: _isExpanded
                    ? Border.all(
                        color: const Color(0xFFEF5350).withValues(alpha: 0.3))
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_upward_rounded,
                    size: 16,
                    color: _isExpanded
                        ? const Color(0xFFEF5350)
                        : AppTheme.currentThemeColors.textSub,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '吐き戻し',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _isExpanded
                          ? const Color(0xFFEF5350)
                          : AppTheme.currentThemeColors.textSub,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountChip(String label, String value, Color bgColor) {
    return GestureDetector(
      onTap: () => _recordSpitUp(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF5D4037),
          ),
        ),
      ),
    );
  }
}
