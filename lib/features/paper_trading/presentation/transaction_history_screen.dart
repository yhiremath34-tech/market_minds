import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass_card.dart';
import '../../app_state_provider.dart';
import '../domain/trading_models.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final transactions = state.transactions;

    return AppScaffold(
      appBar: AppBar(
        title: Text('Transaction Ledger', style: AppTypography.h2),
      ),
      body: transactions.isEmpty
          ? const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No Transactions Yet',
              description: 'All your simulated paper trading executions will appear here with detailed records.',
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              itemCount: transactions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final isBuy = tx.type == TransactionType.buy;
                final badgeColor = isBuy ? AppColors.profit : AppColors.loss;

                return GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Buy/Sell Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          tx.type.name.toUpperCase(),
                          style: AppTypography.caption.copyWith(
                            color: badgeColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx.symbol, style: AppTypography.h3.copyWith(fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(
                              '${tx.quantity} share(s) @ \$${tx.price.toStringAsFixed(2)}',
                              style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${tx.timestamp.day}/${tx.timestamp.month}/${tx.timestamp.year} • ${tx.timestamp.hour.toString().padLeft(2, '0')}:${tx.timestamp.minute.toString().padLeft(2, '0')}',
                              style: AppTypography.caption.copyWith(fontSize: 10, color: AppColors.textDisabled),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.format(tx.totalValue),
                            style: AppTypography.numericMedium.copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'SIMULATED',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.primary,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
