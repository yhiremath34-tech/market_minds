import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/stat_card.dart';
import '../../app_state_provider.dart';
import '../../market_data/domain/market_models.dart';
import '../domain/trading_models.dart';
import 'interactive_chart_card.dart';
import 'trade_sheet_modal.dart';

class StockDetailScreen extends ConsumerStatefulWidget {
  final String symbol;

  const StockDetailScreen({super.key, required this.symbol});

  @override
  ConsumerState<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends ConsumerState<StockDetailScreen> {
  TimeFrame _timeFrame = TimeFrame.oneDay;
  List<CandleData> _candles = [];
  bool _isLoadingCandles = true;

  @override
  void initState() {
    super.initState();
    _loadCandles();
  }

  Future<void> _loadCandles() async {
    setState(() => _isLoadingCandles = true);
    final market = ref.read(marketDataProvider);
    final candles = await market.getCandlestickData(widget.symbol, _timeFrame);
    if (!mounted) return;
    setState(() {
      _candles = candles;
      _isLoadingCandles = false;
    });
  }

  void _onTimeFrameChanged(TimeFrame tf) {
    setState(() => _timeFrame = tf);
    _loadCandles();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final quote = state.quotes
        .where((q) => q.symbol.toUpperCase() == widget.symbol.toUpperCase())
        .firstOrNull;

    if (quote == null) {
      return AppScaffold(
        appBar: AppBar(title: Text(widget.symbol)),
        body: const Center(child: Text('Asset not found.')),
      );
    }

    final isWatchlisted = state.watchlist.contains(quote.symbol);

    // Current position check
    final position = state.portfolio.holdings
        .where((h) => h.symbol.toUpperCase() == quote.symbol.toUpperCase())
        .firstOrNull;

    return AppScaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(quote.symbol, style: AppTypography.h2),
            Text(
              quote.name,
              style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isWatchlisted ? Icons.star : Icons.star_border,
              color: isWatchlisted ? AppColors.accentGold : AppColors.textSecondary,
            ),
            tooltip: 'Watchlist',
            onPressed: () {
              Haptics.selection();
              ref.read(appStateProvider.notifier).toggleWatchlist(quote.symbol);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Interactive Chart Card
            _isLoadingCandles
                ? const SizedBox(
                    height: 280,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : InteractiveChartCard(
                    candles: _candles,
                    selectedTimeFrame: _timeFrame,
                    onTimeFrameChanged: _onTimeFrameChanged,
                    currentPrice: quote.price,
                    change: quote.change,
                    changePercent: quote.changePercent,
                  ),

            const SizedBox(height: 18),

            // User's Position Overview Card (if holding shares)
            if (position != null) ...[
              Text(
                'YOUR VIRTUAL POSITION',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              GlassCard(
                padding: const EdgeInsets.all(16),
                borderColor: AppColors.primary.withValues(alpha: 0.4),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Shares Owned', style: AppTypography.caption),
                            const SizedBox(height: 2),
                            Text('${position.quantity} Shares', style: AppTypography.numericMedium),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Average Buy Price', style: AppTypography.caption),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(position.averageBuyPrice),
                              style: AppTypography.numericMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: AppColors.divider),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Current Market Value', style: AppTypography.caption),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(position.currentMarketValue),
                              style: AppTypography.numericMedium,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Unrealized Return', style: AppTypography.caption),
                            const SizedBox(height: 2),
                            Text(
                              '${CurrencyFormatter.formatPnL(position.unrealizedPnL)} (${CurrencyFormatter.formatPercentage(position.returnPercentage)})',
                              style: AppTypography.numericMedium.copyWith(
                                color: position.unrealizedPnL >= 0
                                    ? AppColors.profit
                                    : AppColors.loss,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Key Financial Stats Grid
            Text(
              'KEY STATISTICS',
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Day High',
                    value: CurrencyFormatter.format(quote.high),
                    icon: Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    title: 'Day Low',
                    value: CurrencyFormatter.format(quote.low),
                    icon: Icons.trending_down,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Volume',
                    value: CurrencyFormatter.formatCompact(quote.volume),
                    icon: Icons.bar_chart,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    title: 'P/E Ratio',
                    value: quote.peRatio > 0 ? quote.peRatio.toStringAsFixed(1) : 'N/A',
                    icon: Icons.pie_chart_outline,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // About Company / Instrument
            Text(
              'ABOUT ${quote.symbol}',
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Text(
                quote.description,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 90), // Bottom button clearance
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          border: const Border(top: BorderSide(color: AppColors.border)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  text: 'SELL',
                  customColor: AppColors.loss,
                  textColor: Colors.black,
                  onPressed: position != null && position.quantity > 0
                      ? () => TradeSheetModal.show(context, quote: quote, type: TransactionType.sell)
                      : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: PrimaryButton(
                  text: 'BUY',
                  customColor: AppColors.profit,
                  textColor: Colors.black,
                  onPressed: () => TradeSheetModal.show(context, quote: quote, type: TransactionType.buy),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
