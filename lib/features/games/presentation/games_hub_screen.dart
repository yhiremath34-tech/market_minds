import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_card.dart';
import '../domain/game_models.dart';
import 'daily_challenge_sheet.dart';
import 'game_candlestick_screen.dart';
import 'game_portfolio_builder_screen.dart';
import 'game_quiz_battle_screen.dart';
import 'game_simulator_missions_screen.dart';
import 'game_up_down_screen.dart';

class GamesHubScreen extends StatelessWidget {
  const GamesHubScreen({super.key});

  final List<GameInfo> _games = const [
    GameInfo(
      id: 'up_or_down',
      title: 'Up or Down',
      subtitle: 'Market Scenario Predictor',
      description: 'Analyze real-life earnings and economic surprises. Test your intuition and discover market uncertainty.',
      icon: Icons.swap_vert,
      color: Color(0xFF00E5FF),
      xpReward: 40,
      badge: 'POPULAR',
    ),
    GameInfo(
      id: 'candlestick_puzzle',
      title: 'Candlestick Puzzle',
      subtitle: 'Chart Pattern Recognition',
      description: 'Identify Hammer, Doji, Bullish Engulfing, and Morning Star candles under real market conditions.',
      icon: Icons.candlestick_chart,
      color: Color(0xFFFFB703),
      xpReward: 60,
      badge: 'CHART IQ',
    ),
    GameInfo(
      id: 'build_portfolio',
      title: 'Build a Portfolio',
      subtitle: 'Asset Allocation Simulator',
      description: 'Distribute \$10,000 across Tech, Value, Bonds, and Cash. Master the diversification ratio score.',
      icon: Icons.pie_chart,
      color: Color(0xFF00E676),
      xpReward: 75,
      badge: 'STRATEGY',
    ),
    GameInfo(
      id: 'quiz_battle',
      title: 'Market Quiz Battle',
      subtitle: 'Fast-Paced Financial Trivia',
      description: 'Answer rapid-fire questions against the countdown timer to claim maximum XP multipliers.',
      icon: Icons.timer,
      color: Color(0xFF7C4DFF),
      xpReward: 80,
      badge: 'TIMED',
    ),
    GameInfo(
      id: 'trading_missions',
      title: 'Simulator Missions',
      subtitle: 'Objective-Based Simulations',
      description: 'Complete hands-on milestones like executing balanced trades while maintaining a safety cash buffer.',
      icon: Icons.flag_outlined,
      color: Color(0xFFFF5252),
      xpReward: 100,
      badge: 'MISSIONS',
    ),
    GameInfo(
      id: 'daily_challenge',
      title: 'Daily Challenge',
      subtitle: 'Fresh Puzzle Every 24 Hours',
      description: 'Keep your consecutive learning streak alive and earn bonus XP with today\'s market puzzle.',
      icon: Icons.local_fire_department,
      color: Color(0xFFFFD166),
      xpReward: 50,
      badge: 'DAILY',
    ),
  ];

  void _openGame(BuildContext context, GameInfo game) {
    Haptics.selection();
    Widget screen;
    switch (game.id) {
      case 'up_or_down':
        screen = const GameUpDownScreen();
        break;
      case 'candlestick_puzzle':
        screen = const GameCandlestickScreen();
        break;
      case 'build_portfolio':
        screen = const GamePortfolioBuilderScreen();
        break;
      case 'quiz_battle':
        screen = const GameQuizBattleScreen();
        break;
      case 'trading_missions':
        screen = const GameSimulatorMissionsScreen();
        break;
      case 'daily_challenge':
        DailyChallengeSheet.show(context);
        return;
      default:
        return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            title: Text('Market Arcade', style: AppTypography.h1),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Practice financial concepts through 6 interactive simulations.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final game = _games[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: GlassCard(
                      padding: const EdgeInsets.all(18),
                      borderColor: game.color.withValues(alpha: 0.3),
                      onTap: () => _openGame(context, game),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: game.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: game.color.withValues(alpha: 0.4)),
                                ),
                                child: Icon(game.icon, color: game.color, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(game.title, style: AppTypography.h3),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: game.color.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            game.badge,
                                            style: AppTypography.caption.copyWith(
                                              color: game.color,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      game.subtitle,
                                      style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.accentGold.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '+${game.xpReward} XP',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.accentGold,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            game.description,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _games.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
