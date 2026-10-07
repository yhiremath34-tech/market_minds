import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/disclaimer_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/price_change_badge.dart';
import '../../app_state_provider.dart';
import '../../market_data/domain/market_models.dart';
import 'stock_detail_screen.dart';
import 'transaction_history_screen.dart';

class PaperTradingScreen extends ConsumerStatefulWidget {
  const PaperTradingScreen({super.key});

  @override
  ConsumerState<PaperTradingScreen> createState() => _PaperTradingScreenState();
}

class _PaperTradingScreenState extends ConsumerState<PaperTradingScreen> {
  final TextEditingController _searchController = TextEditingController();
  AssetCategory _selectedCategory = AssetCategory.all;
  int _selectedTabIndex = 0; // 0: Explore Markets, 1: My Positions, 2: Watchlist

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final portfolio = state.portfolio;
    final query = _searchController.text.trim().toLowerCase();

    // Filter quotes
    final filteredQuotes = state.quotes.where((q) {
      final matchesQuery = q.symbol.toLowerCase().contains(query) ||
          q.name.toLowerCase().contains(query);
      final matchesCat =
          _selectedCategory == AssetCategory.all || q.category == _selectedCategory;
      return matchesQuery && matchesCat;
    }).toList();

    // Watchlist quotes
    final watchlistQuotes = state.quotes
        .where((q) => state.watchlist.contains(q.symbol))
        .toList();

    return AppScaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            title: Text('Paper Trading', style: AppTypography.h1),
            actions: [
              IconButton(
                icon: const Icon(Icons.history, color: AppColors.primary),
                tooltip: 'Transaction Ledger',
                onPressed: () {
                  Haptics.selection();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TransactionHistoryScreen(),
                    ),
                  );
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(130),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search stocks, ETFs, mutual funds...',
                        prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textTertiary),
                        suffixIcon: query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Navigation Segmented Bar (Markets, Positions, Watchlist)
                    Row(
                      children: [
                        _buildTabButton(0, 'Explore Markets'),
                        const SizedBox(width: 8),
                        _buildTabButton(1, 'Positions (${portfolio.holdings.length})'),
                        const SizedBox(width: 8),
                        _buildTabButton(2, 'Watchlist (${state.watchlist.length})'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Portfolio Header Stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Column(
                children: [
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: AppColors.surfaceElevated,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AVAILABLE VIRTUAL CASH',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(portfolio.cashBalance),
                              style: AppTypography.numericLarge.copyWith(fontSize: 22),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'UNREALIZED P&L',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.formatPnL(portfolio.totalUnrealizedPnL),
                              style: AppTypography.numericMedium.copyWith(
                                fontSize: 16,
                                color: portfolio.totalUnrealizedPnL >= 0
                                    ? AppColors.profit
                                    : AppColors.loss,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const DisclaimerCard(compact: true),
                ],
              ),
            ),
          ),

          // Category Filter Chips (when exploring markets)
          if (_selectedTabIndex == 0)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                  itemCount: AssetCategory.values.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = AssetCategory.values[index];
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat.label),
                      selected: isSelected,
                      onSelected: (_) {
                        Haptics.selection();
                        setState(() => _selectedCategory = cat);
                      },
                      labelStyle: AppTypography.caption.copyWith(
                        color: isSelected ? Colors.black : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    );
                  },
                ),
              ),
            ),

          // Main Tab Views
          if (_selectedTabIndex == 0) ...[
            // Explore Markets List
            if (filteredQuotes.isEmpty)
              const SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.search_off,
                  title: 'No assets found',
                  description: 'Try adjusting your search keywords or category filters.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(20.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildQuoteItem(context, filteredQuotes[index], state),
                    childCount: filteredQuotes.length,
                  ),
                ),
              ),
          ] else if (_selectedTabIndex == 1) ...[
            // Active Positions List
            if (portfolio.holdings.isEmpty)
              SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'No Virtual Positions Yet',
                  description: 'Select an asset from the Explore tab and execute your first paper trade.',
                  ctaText: 'Explore Markets',
                  onCtaPressed: () => setState(() => _selectedTabIndex = 0),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(20.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final holding = portfolio.holdings[index];
                      return _buildHoldingItem(context, holding);
                    },
                    childCount: portfolio.holdings.length,
                  ),
                ),
              ),
          ] else ...[
            // Watchlist Tab
            if (watchlistQuotes.isEmpty)
              SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.bookmark_border,
                  title: 'Your Watchlist is Empty',
                  description: 'Tap the star icon on any asset to track it here in real-time.',
                  ctaText: 'Find Stocks to Watch',
                  onCtaPressed: () => setState(() => _selectedTabIndex = 0),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(20.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildQuoteItem(context, watchlistQuotes[index], state),
                    childCount: watchlistQuotes.length,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Haptics.selection();
          setState(() => _selectedTabIndex = index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceHighlight : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary.withValues(alpha: 0.6) : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteItem(BuildContext context, StockQuote quote, AppState state) {
    final isWatchlisted = state.watchlist.contains(quote.symbol);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        onTap: () {
          Haptics.selection();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StockDetailScreen(symbol: quote.symbol),
            ),
          );
        },
        child: Row(
          children: [
            // Category Icon Badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceHighlight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              alignment: Alignment.center,
              child: Text(
                quote.symbol.substring(0, quote.symbol.length > 3 ? 3 : quote.symbol.length),
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(quote.symbol, style: AppTypography.h3.copyWith(fontSize: 15)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHighlight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          quote.category.label.toUpperCase(),
                          style: AppTypography.caption.copyWith(fontSize: 9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    quote.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.format(quote.price),
                  style: AppTypography.numericMedium.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 2),
                PriceChangeBadge(
                  change: quote.change,
                  changePercent: quote.changePercent,
                  compact: true,
                ),
              ],
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                isWatchlisted ? Icons.star : Icons.star_border,
                color: isWatchlisted ? AppColors.accentGold : AppColors.textDisabled,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                Haptics.selection();
                ref.read(appStateProvider.notifier).toggleWatchlist(quote.symbol);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoldingItem(BuildContext context, dynamic holding) {
    final isProfit = holding.unrealizedPnL >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        onTap: () {
          Haptics.selection();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StockDetailScreen(symbol: holding.symbol),
            ),
          );
        },
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(holding.symbol, style: AppTypography.h3),
                    Text(
                      '${holding.quantity} Shares • Avg \$${holding.averageBuyPrice.toStringAsFixed(2)}',
                      style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(holding.currentMarketValue),
                      style: AppTypography.numericMedium,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          isProfit ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                          color: isProfit ? AppColors.profit : AppColors.loss,
                          size: 16,
                        ),
                        Text(
                          '${CurrencyFormatter.formatPnL(holding.unrealizedPnL)} (${CurrencyFormatter.formatPercentage(holding.returnPercentage)})',
                          style: AppTypography.numericSmall.copyWith(
                            color: isProfit ? AppColors.profit : AppColors.loss,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
