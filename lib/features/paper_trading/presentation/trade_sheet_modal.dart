import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/primary_button.dart';
import '../../app_state_provider.dart';
import '../../market_data/domain/market_models.dart';
import '../domain/trading_models.dart';
import '../services/virtual_portfolio_service.dart';

class TradeSheetModal extends ConsumerStatefulWidget {
  final StockQuote quote;
  final TransactionType initialType;

  const TradeSheetModal({
    super.key,
    required this.quote,
    this.initialType = TransactionType.buy,
  });

  static Future<void> show(
    BuildContext context, {
    required StockQuote quote,
    TransactionType type = TransactionType.buy,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TradeSheetModal(quote: quote, initialType: type),
    );
  }

  @override
  ConsumerState<TradeSheetModal> createState() => _TradeSheetModalState();
}

class _TradeSheetModalState extends ConsumerState<TradeSheetModal> {
  late TransactionType _type;
  int _quantity = 1;
  bool _isExecuting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);
    final portfolio = appState.portfolio;
    final quote = widget.quote;

    // Find current holdings for this symbol
    final existingHolding = portfolio.holdings
        .where((h) => h.symbol.toUpperCase() == quote.symbol.toUpperCase())
        .firstOrNull;
    final ownedQty = existingHolding?.quantity ?? 0;

    final totalValue = _quantity * quote.price;
    final isBuy = _type == TransactionType.buy;

    // Post-trade calculations
    final remainingCash = isBuy
        ? portfolio.cashBalance - totalValue
        : portfolio.cashBalance + totalValue;

    final postTradeQty = isBuy ? ownedQty + _quantity : ownedQty - _quantity;

    // Max affordable/sellable calculations
    final maxBuyQty = (portfolio.cashBalance / quote.price).floor();
    final maxSellQty = ownedQty;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
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

          // Header: Stock Info & Buy/Sell Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(quote.symbol, style: AppTypography.h2),
                  Text(
                    quote.name,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
              // Segmented Buy/Sell Control
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    _buildTypeButton(
                      type: TransactionType.buy,
                      label: 'BUY',
                      activeColor: AppColors.profit,
                    ),
                    _buildTypeButton(
                      type: TransactionType.sell,
                      label: 'SELL',
                      activeColor: AppColors.loss,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Quantity Stepper with Quick Max Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Quantity (Shares)', style: AppTypography.h3),
              Row(
                children: [
                  if ((isBuy && maxBuyQty > 0) || (!isBuy && maxSellQty > 0))
                    TextButton(
                      onPressed: () {
                        Haptics.selection();
                        setState(() {
                          _quantity = isBuy ? maxBuyQty : maxSellQty;
                          _errorMessage = null;
                        });
                      },
                      child: Text(
                        'MAX (${isBuy ? maxBuyQty : maxSellQty})',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  IconButton(
                    onPressed: _quantity > 1
                        ? () {
                            Haptics.selection();
                            setState(() {
                              _quantity--;
                              _errorMessage = null;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    color: AppColors.primary,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text('$_quantity', style: AppTypography.numericMedium),
                  ),
                  IconButton(
                    onPressed: () {
                      Haptics.selection();
                      setState(() {
                        _quantity++;
                        _errorMessage = null;
                      });
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 16),

          // Order Confirmation Summary Table
          _buildSummaryRow(
            label: 'Market Execution Price',
            value: CurrencyFormatter.format(quote.price),
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            label: isBuy ? 'Total Estimated Cost' : 'Total Estimated Proceeds',
            value: CurrencyFormatter.format(totalValue),
            valueColor: isBuy ? AppColors.textPrimary : AppColors.profit,
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            label: 'Virtual Cash Available',
            value: CurrencyFormatter.format(portfolio.cashBalance),
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            label: 'Cash Balance After Trade',
            value: CurrencyFormatter.format(remainingCash),
            valueColor: remainingCash < 0 ? AppColors.loss : AppColors.textSecondary,
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            label: 'Position After Trade',
            value: '$postTradeQty share(s)',
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.lossBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.loss.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.loss, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: AppTypography.caption.copyWith(color: AppColors.loss),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Execute Action Button
          PrimaryButton(
            text: isBuy ? 'Confirm Buy ($_quantity Shares)' : 'Confirm Sell ($_quantity Shares)',
            isLoading: _isExecuting,
            customColor: isBuy ? AppColors.profit : AppColors.loss,
            textColor: Colors.black,
            onPressed: () => _executeOrder(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton({
    required TransactionType type,
    required String label,
    required Color activeColor,
  }) {
    final isSelected = _type == type;
    return GestureDetector(
      onTap: () {
        Haptics.selection();
        setState(() {
          _type = type;
          _errorMessage = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isSelected ? Colors.black : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
        Text(
          value,
          style: AppTypography.numericSmall.copyWith(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _executeOrder(BuildContext context) async {
    setState(() {
      _isExecuting = true;
      _errorMessage = null;
    });

    final notifier = ref.read(appStateProvider.notifier);
    final isBuy = _type == TransactionType.buy;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    TradeExecutionResult result;
    if (isBuy) {
      result = await notifier.buyStock(
        symbol: widget.quote.symbol,
        assetName: widget.quote.name,
        quantity: _quantity,
        currentPrice: widget.quote.price,
      );
    } else {
      result = await notifier.sellStock(
        symbol: widget.quote.symbol,
        quantity: _quantity,
        currentPrice: widget.quote.price,
      );
    }

    if (!mounted) return;

    setState(() => _isExecuting = false);

    if (result.success) {
      Haptics.heavy();
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: isBuy ? AppColors.profit : AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.black, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result.message,
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      Haptics.medium();
      setState(() => _errorMessage = result.message);
    }
  }
}
