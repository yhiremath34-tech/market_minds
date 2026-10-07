import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_card.dart';
import '../../app_state_provider.dart';
import '../../home/presentation/main_navigation_shell.dart';
import '../domain/game_models.dart';

class GameSimulatorMissionsScreen extends ConsumerStatefulWidget {
  const GameSimulatorMissionsScreen({super.key});

  @override
  ConsumerState<GameSimulatorMissionsScreen> createState() =>
      _GameSimulatorMissionsScreenState();
}

class _GameSimulatorMissionsScreenState
    extends ConsumerState<GameSimulatorMissionsScreen> {
  final List<SimulatorMission> _missions = const [
    SimulatorMission(
      id: 'm1',
      title: 'First Market Execution',
      goal: 'Execute at least 1 virtual trade',
      description: 'Acquire shares of any stock or ETF in the paper trading simulator to test order processing.',
      xpReward: 80,
      coinReward: 40,
    ),
    SimulatorMission(
      id: 'm2',
      title: 'Diversified Foundation',
      goal: 'Hold at least 3 distinct instruments',
      description: 'Avoid single-stock concentration by distributing capital across 3 different securities or funds.',
      xpReward: 120,
      coinReward: 60,
    ),
    SimulatorMission(
      id: 'm3',
      title: 'Liquidity Safety Buffer',
      goal: 'Maintain at least \$2,000 virtual cash buffer',
      description: 'Never go 100% all-in. Keep cash on hand to capitalize on unexpected market pullbacks.',
      xpReward: 100,
      coinReward: 50,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final portfolio = state.portfolio;
    final transactions = state.transactions;

    return AppScaffold(
      appBar: AppBar(
        title: Text('Simulator Missions', style: AppTypography.h2),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Active Directives', style: AppTypography.h1),
            const SizedBox(height: 6),
            Text(
              'Complete practical portfolio milestones to build institutional-grade habits.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.separated(
                itemCount: _missions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final mission = _missions[index];

                  // Evaluate completion dynamically
                  bool isDone = false;
                  if (mission.id == 'm1') {
                    isDone = transactions.isNotEmpty;
                  } else if (mission.id == 'm2') {
                    isDone = portfolio.holdings.length >= 3;
                  } else if (mission.id == 'm3') {
                    isDone = portfolio.cashBalance >= 2000.0;
                  }

                  return GlassCard(
                    padding: const EdgeInsets.all(18),
                    borderColor: isDone
                        ? AppColors.profit.withValues(alpha: 0.5)
                        : AppColors.border,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: isDone ? AppColors.profit : AppColors.textTertiary,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Text(mission.title, style: AppTypography.h3),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.accentGold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '+${mission.xpReward} XP',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.accentGold,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Goal: ${mission.goal}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mission.description,
                          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (isDone)
                              Text(
                                'Completed',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.profit,
                                  fontWeight: FontWeight.w800,
                                ),
                              )
                            else
                              TextButton(
                                onPressed: () {
                                  Haptics.selection();
                                  Navigator.pop(context);
                                  final navState = context.findAncestorStateOfType<MainNavigationShellState>();
                                  navState?.switchTab(3);
                                },
                                child: Text(
                                  'Go to Trade Simulator →',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
