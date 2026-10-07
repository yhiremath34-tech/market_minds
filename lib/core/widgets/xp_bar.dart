import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class XPBar extends StatelessWidget {
  final int currentXp;
  final bool showRankBadge;

  const XPBar({
    super.key,
    required this.currentXp,
    this.showRankBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    final rank = AppConstants.getRankForXp(currentXp);
    final range = (rank.maxXp - rank.minXp).clamp(1, 999999);
    final progress = ((currentXp - rank.minXp) / range).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showRankBadge)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: rank.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: rank.color.withValues(alpha: 0.4), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(rank.icon, size: 14, color: rank.color),
                        const SizedBox(width: 4),
                        Text(
                          rank.name,
                          style: AppTypography.caption.copyWith(
                            color: rank.color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                '$currentXp / ${rank.maxXp == 999999 ? 'MAX' : rank.maxXp} XP',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 8,
            width: double.infinity,
            color: AppColors.surfaceHighlight,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, val, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: val,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [rank.color.withValues(alpha: 0.7), rank.color],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
