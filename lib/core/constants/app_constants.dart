import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'MARKET MINDS';
  static const String appTagline = 'Learn. Play. Practice. Master the Market.';
  
  // Starting Virtual Capital
  static const double initialVirtualCash = 10000.00;
  
  // Minimum required age
  static const int minimumAge = 16;
  
  // Educational Disclaimer
  static const String educationalDisclaimer =
      'Educational Simulation Only. Market Minds uses 100% virtual currency. '
      'No real money is ever traded or deposited. Past simulation results '
      'do not reflect real market performance. Never make real investment decisions '
      'without independent certified financial counsel.';

  // Storage Keys
  static const String keyAgeVerified = 'market_minds_age_verified';
  static const String keyOnboardingComplete = 'market_minds_onboarded';
  static const String keyUserXP = 'market_minds_xp';
  static const String keyUserCoins = 'market_minds_coins';
  static const String keyUserStreak = 'market_minds_streak';
  static const String keyLastActiveDate = 'market_minds_last_active';
  static const String keyCompletedLessons = 'market_minds_completed_lessons';
  static const String keyPortfolio = 'market_minds_portfolio_state';
  static const String keyTransactions = 'market_minds_transactions_state';
  static const String keyWatchlist = 'market_minds_watchlist_state';
  static const String keyAchievements = 'market_minds_achievements_state';

  // Gamification Ranks
  static const List<RankTier> rankTiers = [
    RankTier(name: 'BEGINNER', minXp: 0, maxXp: 300, icon: Icons.eco, color: Color(0xFF94A3B8)),
    RankTier(name: 'INVESTOR', minXp: 300, maxXp: 800, icon: Icons.trending_up, color: Color(0xFF00E5FF)),
    RankTier(name: 'TRADER', minXp: 800, maxXp: 1600, icon: Icons.candlestick_chart, color: Color(0xFF00E676)),
    RankTier(name: 'ANALYST', minXp: 1600, maxXp: 2800, icon: Icons.insights, color: Color(0xFF7C4DFF)),
    RankTier(name: 'EXPERT', minXp: 2800, maxXp: 4500, icon: Icons.psychology, color: Color(0xFFFFB703)),
    RankTier(name: 'MARKET MASTER', minXp: 4500, maxXp: 7000, icon: Icons.workspace_premium, color: Color(0xFFFF5252)),
    RankTier(name: 'LEGEND', minXp: 7000, maxXp: 999999, icon: Icons.diamond, color: Color(0xFFFFD700)),
  ];

  static RankTier getRankForXp(int xp) {
    for (int i = rankTiers.length - 1; i >= 0; i--) {
      if (xp >= rankTiers[i].minXp) {
        return rankTiers[i];
      }
    }
    return rankTiers.first;
  }
}

class RankTier {
  final String name;
  final int minXp;
  final int maxXp;
  final IconData icon;
  final Color color;

  const RankTier({
    required this.name,
    required this.minXp,
    required this.maxXp,
    required this.icon,
    required this.color,
  });
}
