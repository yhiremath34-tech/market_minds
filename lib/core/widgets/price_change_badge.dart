import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/currency_formatter.dart';

class PriceChangeBadge extends StatelessWidget {
  final double change;
  final double changePercent;
  final bool showAmount;
  final bool compact;

  const PriceChangeBadge({
    super.key,
    required this.change,
    required this.changePercent,
    this.showAmount = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = change >= 0;
    final isZero = change == 0;

    final color = isZero
        ? AppColors.neutral
        : (isPositive ? AppColors.profit : AppColors.loss);

    final bgColor = isZero
        ? AppColors.surfaceElevated
        : (isPositive ? AppColors.profitBackground : AppColors.lossBackground);

    final icon = isZero
        ? Icons.remove
        : (isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: compact ? 14 : 16,
          ),
          const SizedBox(width: 2),
          Text(
            showAmount
                ? '${CurrencyFormatter.formatPnL(change)} (${CurrencyFormatter.formatPercentage(changePercent)})'
                : CurrencyFormatter.formatPercentage(changePercent),
            style: (compact ? AppTypography.caption : AppTypography.numericSmall)
                .copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
