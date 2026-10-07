import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/primary_button.dart';
import '../../app_state_provider.dart';

class DailyChallengeSheet extends ConsumerStatefulWidget {
  const DailyChallengeSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const DailyChallengeSheet(),
    );
  }

  @override
  ConsumerState<DailyChallengeSheet> createState() => _DailyChallengeSheetState();
}

class _DailyChallengeSheetState extends ConsumerState<DailyChallengeSheet> {
  int? _selectedChoice;
  bool _answered = false;

  final List<String> _options = const [
    'Morning Star (Bullish Reversal)',
    'Evening Star (Bearish Reversal)',
    'Three Black Crows',
    'Spinning Top',
  ];
  final int _correctIndex = 0;

  void _choose(int index) {
    if (_answered) return;
    Haptics.selection();
    final isCorrect = index == _correctIndex;

    if (isCorrect) {
      Haptics.heavy();
      ref.read(appStateProvider.notifier).addXp(50);
    } else {
      Haptics.medium();
      ref.read(appStateProvider.notifier).addXp(15);
    }

    setState(() {
      _selectedChoice = index;
      _answered = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.flash_on, color: AppColors.accentGold, size: 22),
                  const SizedBox(width: 8),
                  Text('Today\'s Challenge', style: AppTypography.h2),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '+50 XP',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.accentGold,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Examine this 3-candle sequence: A long red candle, a small indecisive gapping candle, followed by a large green candle recovering above the midpoint.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.4),
          ),

          const SizedBox(height: 18),

          // Candle sequence graphic
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.surfaceHighlight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Candle 1: Tall Red
                  Column(
                    children: [
                      Container(width: 2, height: 6, color: AppColors.loss),
                      Container(width: 18, height: 42, color: AppColors.loss),
                      Container(width: 2, height: 6, color: AppColors.loss),
                    ],
                  ),
                  const SizedBox(width: 14),
                  // Candle 2: Small gapping candle
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(width: 2, height: 6, color: AppColors.textSecondary),
                      Container(width: 14, height: 12, color: AppColors.textSecondary),
                      Container(width: 2, height: 6, color: AppColors.textSecondary),
                    ],
                  ),
                  const SizedBox(width: 14),
                  // Candle 3: Tall Green
                  Column(
                    children: [
                      Container(width: 2, height: 6, color: AppColors.profit),
                      Container(width: 18, height: 46, color: AppColors.profit),
                      Container(width: 2, height: 6, color: AppColors.profit),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          ...List.generate(_options.length, (idx) {
            final isSelected = _selectedChoice == idx;
            final isCorrect = idx == _correctIndex;

            Color border = AppColors.border;
            Color bg = AppColors.surface;

            if (_answered) {
              if (isCorrect) {
                border = AppColors.profit;
                bg = AppColors.profitBackground;
              } else if (isSelected) {
                border = AppColors.loss;
                bg = AppColors.lossBackground;
              }
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => _choose(idx),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: border, width: isSelected ? 1.5 : 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _options[idx],
                        style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (_answered && isCorrect)
                        const Icon(Icons.check_circle, color: AppColors.profit, size: 18)
                      else if (_answered && isSelected && !isCorrect)
                        const Icon(Icons.cancel, color: AppColors.loss, size: 18),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          if (_answered) ...[
            Text(
              _selectedChoice == _correctIndex
                  ? '🎯 Exactly! The Morning Star pattern signals seller exhaustion and strong bullish buyer reversal (+50 XP).'
                  : '💡 This is a classic Morning Star pattern. The small middle star shows selling slowed before bulls took over.',
              style: AppTypography.bodySmall.copyWith(
                color: _selectedChoice == _correctIndex ? AppColors.profit : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Done',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ],
      ),
    );
  }
}
