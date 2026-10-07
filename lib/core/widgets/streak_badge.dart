import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class StreakBadge extends StatelessWidget {
  final int streakDays;
  final bool compact;

  const StreakBadge({
    super.key,
    required this.streakDays,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentGold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department,
            color: AppColors.accentGold,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '$streakDays ${streakDays == 1 ? 'DAY' : 'DAYS'}',
            style: AppTypography.caption.copyWith(
              color: AppColors.accentGold,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
