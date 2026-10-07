import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_card.dart';
import '../../app_state_provider.dart';
import '../domain/leaderboard_models.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  int _selectedTab = 0; // 0: Weekly, 1: Monthly, 2: All-Time

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final user = state.user;
    final portfolio = state.portfolio;

    final entries = LeaderboardEntry.getWeeklySample(
      userXp: user?.xp ?? 0,
      userReturn: portfolio.totalReturnPercentage,
    );

    return AppScaffold(
      appBar: AppBar(
        title: Text('Leaderboard', style: AppTypography.h1),
      ),
      body: Column(
        children: [
          // Segmented timeframe control
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.all(3),
              child: Row(
                children: [
                  _buildTab(0, 'Weekly'),
                  _buildTab(1, 'Monthly'),
                  _buildTab(2, 'All-Time'),
                ],
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              children: [
                // Top 3 Podium
                _buildPodium(entries.take(3).toList()),

                const SizedBox(height: 24),
                Text(
                  'TOP LEARNERS & TRADERS',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),

                // Remaining Rows
                ...entries.map((entry) => _buildLeaderboardRow(entry)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Haptics.selection();
          setState(() => _selectedTab = index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceHighlight : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPodium(List<LeaderboardEntry> top3) {
    if (top3.length < 3) return const SizedBox();
    final first = top3[0];
    final second = top3[1];
    final third = top3[2];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place
          _buildPodiumPillar(entry: second, rank: 2, height: 110, color: const Color(0xFFC0C0C0)),
          const SizedBox(width: 14),
          // 1st Place
          _buildPodiumPillar(entry: first, rank: 1, height: 140, color: const Color(0xFFFFD700), isFirst: true),
          const SizedBox(width: 14),
          // 3rd Place
          _buildPodiumPillar(entry: third, rank: 3, height: 90, color: const Color(0xFFCD7F32)),
        ],
      ),
    );
  }

  Widget _buildPodiumPillar({
    required LeaderboardEntry entry,
    required int rank,
    required double height,
    required Color color,
    bool isFirst = false,
  }) {
    return Column(
      children: [
        if (isFirst)
          const Icon(Icons.workspace_premium, color: Color(0xFFFFD700), size: 24),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
            color: AppColors.surfaceHighlight,
          ),
          alignment: Alignment.center,
          child: Text(
            entry.displayName[0],
            style: AppTypography.h3.copyWith(color: color),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          entry.displayName.split(' ').first,
          style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          '${entry.xp} XP',
          style: AppTypography.caption.copyWith(fontSize: 10, color: AppColors.textTertiary),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.05)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          alignment: Alignment.center,
          child: Text(
            '#$rank',
            style: AppTypography.h2.copyWith(color: color),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardRow(LeaderboardEntry entry) {
    final isMe = entry.isCurrentUser;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        borderColor: isMe ? AppColors.primary : AppColors.border,
        backgroundColor: isMe ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '#${entry.rank}',
                style: AppTypography.numericMedium.copyWith(
                  fontSize: 14,
                  color: entry.rank <= 3 ? AppColors.accentGold : AppColors.textTertiary,
                ),
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isMe ? AppColors.primary : AppColors.surfaceHighlight,
              ),
              alignment: Alignment.center,
              child: Text(
                entry.displayName[0],
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isMe ? Colors.black : AppColors.textPrimary,
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
                      Text(
                        entry.displayName,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: isMe ? FontWeight.w800 : FontWeight.w600,
                          color: isMe ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'YOU',
                            style: AppTypography.caption.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Level ${entry.level} • ${entry.badge}',
                    style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.xp} XP',
                  style: AppTypography.numericSmall.copyWith(
                    color: AppColors.accentGold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Return: ${CurrencyFormatter.formatPercentage(entry.portfolioReturn)}',
                  style: AppTypography.caption.copyWith(
                    color: entry.portfolioReturn >= 0 ? AppColors.profit : AppColors.loss,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
