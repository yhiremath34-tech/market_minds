import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/disclaimer_card.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/streak_badge.dart';
import '../../../core/widgets/xp_bar.dart';
import '../../app_state_provider.dart';
import '../domain/certificate_model.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showCertificateDialog(BuildContext context, FinancialCertificate cert) {
    Haptics.selection();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.accentGold, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentGold.withValues(alpha: 0.2),
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentGold.withValues(alpha: 0.15),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.accentGold,
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'OFFICIAL CERTIFICATE',
                style: AppTypography.caption.copyWith(
                  color: AppColors.accentGold,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                cert.courseTitle,
                textAlign: TextAlign.center,
                style: AppTypography.h3,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Text(
                      'CONFERRED UPON',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                        letterSpacing: 1.0,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cert.recipientName,
                      style: AppTypography.h2.copyWith(color: AppColors.primary),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Completed ${cert.totalLessonsCompleted} modules of foundational curriculum in simulated financial market dynamics and risk management.',
                      textAlign: TextAlign.center,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Divider(color: AppColors.border.withValues(alpha: 0.5)),
                    const SizedBox(height: 8),
                    Text(
                      'Certificate ID: ${cert.certificateId}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      cert.issuer,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGold,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Close Certificate'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmResetSimulation(BuildContext context, WidgetRef ref) {
    Haptics.heavy();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.loss, width: 1),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.loss, size: 28),
            const SizedBox(width: 10),
            Text('Reset Simulator', style: AppTypography.h2),
          ],
        ),
        content: Text(
          'This will reset your simulated paper trading balance to \$10,000.00 and clear all transaction logs. '
          'Your educational XP, rank, and completed lessons will NOT be lost.',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(appStateProvider.notifier).resetPortfolio();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.surfaceElevated,
                    content: Text(
                      'Portfolio successfully reset to \$10,000.00',
                      style: AppTypography.bodySmall,
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.loss,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset Account'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final user = state.user;
    final portfolio = state.portfolio;
    final rank = AppConstants.getRankForXp(user?.xp ?? 0);

    return AppScaffold(
      useSafeArea: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: rank.color.withValues(alpha: 0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(rank.icon, color: Colors.black, size: 32),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user?.displayName ?? 'Market Learner',
                              style: AppTypography.h2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (user?.isGuest ?? true)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.textTertiary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'GUEST',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: rank.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              rank.name,
                              style: AppTypography.caption.copyWith(
                                color: rank.color,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Level ${user?.level ?? 1}',
                            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const StreakBadge(streakDays: 7),
              ],
            ),

            const SizedBox(height: 20),

            // XP Progression Card
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('LEVEL PROGRESS', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w800)),
                      Text('${user?.xp ?? 0} XP', style: AppTypography.numericMedium.copyWith(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  XPBar(
                    currentXp: user?.xp ?? 0,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.monetization_on, color: AppColors.accentGold, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '${user?.coins ?? 0} Market Coins',
                            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      Text(
                        '${rank.maxXp - (user?.xp ?? 0)} XP to next tier',
                        style: AppTypography.caption.copyWith(color: AppColors.textTertiary, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Simulated Portfolio Stats
            Text('SIMULATED PORTFOLIO METRICS', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.8)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Total Worth',
                    value: CurrencyFormatter.format(portfolio.totalPortfolioValue),
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Cash Balance',
                    value: CurrencyFormatter.format(portfolio.cashBalance),
                    icon: Icons.attach_money,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Realized P&L',
                    value: CurrencyFormatter.format(portfolio.realizedPnL),
                    icon: Icons.analytics_outlined,
                    iconColor: portfolio.realizedPnL >= 0 ? AppColors.profit : AppColors.loss,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Holdings',
                    value: '${portfolio.holdings.length} Assets',
                    icon: Icons.pie_chart_outline,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Certificates Section
            Text('CREDENTIALS & CERTIFICATES', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.8)),
            const SizedBox(height: 10),
            if (state.certificates.isEmpty)
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.school_outlined, color: AppColors.textTertiary, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Foundations Certificate', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(
                            'Complete all 10 educational levels to unlock your certified graduation credential.',
                            style: AppTypography.caption.copyWith(color: AppColors.textSecondary, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: state.certificates.map((cert) {
                  return GlassCard(
                    onTap: () => _showCertificateDialog(context, cert),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.accentGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.accentGold, width: 1),
                          ),
                          child: const Icon(Icons.workspace_premium, color: AppColors.accentGold, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cert.courseTitle, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text('Tap to view official certificate credential', style: AppTypography.caption.copyWith(color: AppColors.accentGold)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                      ],
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 24),

            // Achievements Unlocked
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('BADGES & ACHIEVEMENTS', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.8)),
                Text(
                  '${state.achievements.where((a) => a.isUnlocked).length} / ${state.achievements.length}',
                  style: AppTypography.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.2,
              ),
              itemCount: state.achievements.length,
              itemBuilder: (context, index) {
                final ach = state.achievements[index];
                final isUnlocked = ach.isUnlocked;

                return GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : AppColors.surfaceElevated,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          ach.icon,
                          size: 18,
                          color: isUnlocked ? AppColors.primary : AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ach.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                                color: isUnlocked ? AppColors.textPrimary : AppColors.textTertiary,
                              ),
                            ),
                            Text(
                              isUnlocked ? '+${ach.xpReward} XP' : 'Locked',
                              style: AppTypography.caption.copyWith(
                                fontSize: 10,
                                color: isUnlocked ? AppColors.accentGold : AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Simulation & Safety Controls
            Text('SIMULATOR CONTROLS', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.8)),
            const SizedBox(height: 10),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.restart_alt_rounded, color: AppColors.loss),
                    title: Text('Reset Simulation Portfolio', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                    subtitle: Text('Re-initialize starting virtual cash to \$10,000.00', style: AppTypography.caption),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                    onTap: () => _confirmResetSimulation(context, ref),
                  ),
                  const Divider(color: AppColors.border, height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.wifi_off_outlined, color: AppColors.textSecondary),
                    title: Text('Simulate Offline Mode', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                    subtitle: Text('Test offline indicator & cache reliability', style: AppTypography.caption),
                    trailing: Switch(
                      value: state.isOffline,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) {
                        ref.read(appStateProvider.notifier).toggleOffline(val);
                      },
                    ),
                  ),
                  const Divider(color: AppColors.border, height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.logout, color: AppColors.textSecondary),
                    title: Text('Sign Out / Reset Profile', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                    onTap: () {
                      ref.read(appStateProvider.notifier).logout();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.surfaceElevated,
                          content: Text('Switched to Guest Trader mode', style: AppTypography.bodySmall),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Mandatory Educational Disclaimer
            const DisclaimerCard(),

            const SizedBox(height: 24),

            Center(
              child: Text(
                '${AppConstants.appName} • v1.0.0 (Education Build)',
                style: AppTypography.caption.copyWith(color: AppColors.textTertiary, fontSize: 11),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
