import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int xpReward;
  final int coinReward;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.xpReward,
    required this.coinReward,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      xpReward: xpReward,
      coinReward: coinReward,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  static List<Achievement> getInitialAchievements() {
    return [
      const Achievement(
        id: 'first_lesson',
        title: 'FIRST LESSON',
        description: 'Completed your first educational financial module.',
        icon: Icons.school,
        xpReward: 50,
        coinReward: 25,
      ),
      const Achievement(
        id: 'first_trade',
        title: 'FIRST TRADE',
        description: 'Executed your first virtual paper trade in the simulator.',
        icon: Icons.trending_up,
        xpReward: 100,
        coinReward: 50,
      ),
      const Achievement(
        id: '7_day_streak',
        title: '7 DAY STREAK',
        description: 'Maintained a consecutive 7-day market learning streak.',
        icon: Icons.local_fire_department,
        xpReward: 200,
        coinReward: 100,
      ),
      const Achievement(
        id: 'risk_aware',
        title: 'RISK AWARE',
        description: 'Completed the Level 8 Risk Management module.',
        icon: Icons.shield,
        xpReward: 150,
        coinReward: 75,
      ),
      const Achievement(
        id: 'diversifier',
        title: 'DIVERSIFIER',
        description: 'Constructed a portfolio holding at least 3 distinct asset classes.',
        icon: Icons.pie_chart,
        xpReward: 120,
        coinReward: 60,
      ),
      const Achievement(
        id: 'market_master',
        title: 'MARKET MASTER',
        description: 'Completed all 10 core financial literacy levels.',
        icon: Icons.workspace_premium,
        xpReward: 500,
        coinReward: 250,
      ),
      const Achievement(
        id: 'puzzle_solver',
        title: 'CANDLE PRO',
        description: 'Successfully identified candlestick patterns in the Play zone.',
        icon: Icons.candlestick_chart,
        xpReward: 80,
        coinReward: 40,
      ),
    ];
  }
}
