import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/disclaimer_card.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/price_change_badge.dart';
import '../../../core/widgets/streak_badge.dart';
import '../../../core/widgets/xp_bar.dart';
import '../../app_state_provider.dart';
import '../../games/presentation/daily_challenge_sheet.dart';
import '../../learning/data/learning_curriculum.dart';
import '../../learning/domain/learning_models.dart';
import '../../learning/presentation/lesson_screen.dart';
import '../../news/presentation/news_screen.dart';
import '../../paper_trading/presentation/stock_detail_screen.dart';
import 'main_navigation_shell.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final user = state.user;
    final portfolio = state.portfolio;

    // Next recommended lesson
    final completed = state.completedLessons;
    Lesson? nextLesson;
    LearningLevel? nextLevel;

    for (final lvl in LearningCurriculum.levels) {
      for (final l in lvl.lessons) {
        if (!completed.contains(l.id)) {
          nextLesson = l;
          nextLevel = lvl;
          break;
        }
      }
      if (nextLesson != null) break;
    }

    // Default to first lesson if completed all or none
    nextLesson ??= LearningCurriculum.levels.first.lessons.first;
    nextLevel ??= LearningCurriculum.levels.first;

    final isProfit = portfolio.totalPnL >= 0;

    return AppScaffold(
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceElevated,
        onRefresh: () async {
          Haptics.light();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Greeting, Avatar, Streak
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getGreeting()},',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        user?.displayName ?? 'Young Investor',
                        style: AppTypography.h1.copyWith(fontSize: 22),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      StreakBadge(streakDays: user?.streak ?? 1),
                      const SizedBox(width: 8),
                      // Rank Icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceHighlight,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // XP Bar
              XPBar(currentXp: user?.xp ?? 0),

              const SizedBox(height: 20),

              // Portfolio Snapshot Card
              GlassCard(
                padding: const EdgeInsets.all(18),
                backgroundColor: AppColors.surface.withValues(alpha: 0.95),
                borderColor: AppColors.primary.withValues(alpha: 0.3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'VIRTUAL PORTFOLIO VALUE',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            'SIMULATED',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.primary,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyFormatter.format(portfolio.totalPortfolioValue),
                      style: AppTypography.numericLarge.copyWith(fontSize: 32),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isProfit ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                          color: isProfit ? AppColors.profit : AppColors.loss,
                          size: 20,
                        ),
                        Text(
                          '${CurrencyFormatter.formatPnL(portfolio.totalPnL)} (${CurrencyFormatter.formatPercentage(portfolio.totalReturnPercentage)})',
                          style: AppTypography.numericSmall.copyWith(
                            color: isProfit ? AppColors.profit : AppColors.loss,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'All-Time Return',
                          style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(color: AppColors.divider),
                    const SizedBox(height: 14),

                    // Cash Balance vs Invested breakdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Virtual Cash',
                              style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(portfolio.cashBalance),
                              style: AppTypography.numericMedium.copyWith(fontSize: 15),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Invested Capital',
                              style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(portfolio.totalHoldingsValue),
                              style: AppTypography.numericMedium.copyWith(fontSize: 15),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Holdings',
                              style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${portfolio.holdings.length} Assets',
                              style: AppTypography.numericMedium.copyWith(fontSize: 15),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Educational Disclaimer
              const DisclaimerCard(compact: true),

              const SizedBox(height: 22),

              // Continue Learning Header & Card
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('CONTINUE LEARNING', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.8)),
                  Text(
                    'Level ${nextLevel.id} of 10',
                    style: AppTypography.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              GlassCard(
                padding: const EdgeInsets.all(16),
                onTap: () {
                  Haptics.selection();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LessonScreen(lesson: nextLesson!, level: nextLevel!),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: nextLevel.accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: nextLevel.accentColor.withValues(alpha: 0.4)),
                      ),
                      child: Icon(nextLevel.icon, color: nextLevel.accentColor, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Level ${nextLevel.id} • ${nextLevel.title}',
                            style: AppTypography.caption.copyWith(
                              color: nextLevel.accentColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(nextLesson.title, style: AppTypography.h3.copyWith(fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(
                            '${nextLesson.estimatedMinutes} min • +${nextLesson.xpReward} XP',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Start',
                        style: AppTypography.caption.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Today's Challenge Teaser Card
              GlassCard(
                padding: const EdgeInsets.all(16),
                borderColor: AppColors.accentGold.withValues(alpha: 0.4),
                backgroundColor: AppColors.accentGold.withValues(alpha: 0.08),
                onTap: () {
                  Haptics.selection();
                  DailyChallengeSheet.show(context);
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentGold.withValues(alpha: 0.2),
                      ),
                      child: const Icon(Icons.flash_on, color: AppColors.accentGold, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TODAY\'S CHALLENGE',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.accentGold,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Can you identify today\'s candlestick pattern?',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text('Reward: +50 XP & Keep Streak', style: AppTypography.caption),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.accentGold),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Quick Actions Grid
              Text('QUICK ACTIONS', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.8)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.candlestick_chart,
                      title: 'Trade',
                      subtitle: 'Simulate',
                      color: AppColors.primary,
                      onTap: () {
                        final navState = context.findAncestorStateOfType<MainNavigationShellState>();
                        navState?.switchTab(3);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.sports_esports,
                      title: 'Games',
                      subtitle: '6 Mini-Games',
                      color: AppColors.secondary,
                      onTap: () {
                        final navState = context.findAncestorStateOfType<MainNavigationShellState>();
                        navState?.switchTab(2);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.newspaper,
                      title: 'News',
                      subtitle: 'Market Briefs',
                      color: AppColors.profit,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NewsScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Market Watch Header & List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('MARKET WATCH', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.8)),
                  GestureDetector(
                    onTap: () {
                      final navState = context.findAncestorStateOfType<MainNavigationShellState>();
                      navState?.switchTab(3);
                    },
                    child: Text(
                      'View All Markets',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Stock Cards List
              ...state.quotes.take(5).map((q) => _buildStockCard(context, q)),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(title, style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text(subtitle, style: AppTypography.caption.copyWith(fontSize: 10, color: AppColors.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildStockCard(BuildContext context, dynamic quote) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surfaceHighlight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              alignment: Alignment.center,
              child: Text(
                quote.symbol.substring(0, quote.symbol.length > 3 ? 3 : quote.symbol.length),
                style: AppTypography.caption.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(quote.symbol, style: AppTypography.h3.copyWith(fontSize: 14)),
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
                  style: AppTypography.numericMedium.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 2),
                PriceChangeBadge(
                  change: quote.change,
                  changePercent: quote.changePercent,
                  compact: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
