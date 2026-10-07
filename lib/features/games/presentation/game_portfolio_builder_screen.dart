import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../app_state_provider.dart';

class GamePortfolioBuilderScreen extends ConsumerStatefulWidget {
  const GamePortfolioBuilderScreen({super.key});

  @override
  ConsumerState<GamePortfolioBuilderScreen> createState() =>
      _GamePortfolioBuilderScreenState();
}

class _GamePortfolioBuilderScreenState
    extends ConsumerState<GamePortfolioBuilderScreen> {
  double _largeCap = 40;
  double _techGrowth = 30;
  double _bonds = 20;
  double _cash = 10;
  bool _evaluated = false;

  double get _totalPct => _largeCap + _techGrowth + _bonds + _cash;

  int _calculateDiversificationScore() {
    // Balanced distribution earns higher score
    double score = 100;
    if (_techGrowth > 50) score -= (_techGrowth - 50) * 1.5;
    if (_largeCap > 60) score -= (_largeCap - 60);
    if (_cash > 40) score -= (_cash - 40);
    if (_bonds < 10) score -= 15;
    return score.clamp(10, 100).round();
  }

  String _getRiskProfile() {
    if (_techGrowth > 50) return 'Aggressive / High Volatility';
    if (_cash > 50) return 'Extremely Conservative (Inflation Drag)';
    if (_bonds > 40) return 'Capital Preservation Focus';
    return 'Balanced Growth & Defense';
  }

  void _evaluate() {
    Haptics.heavy();
    ref.read(appStateProvider.notifier).addXp(75);
    setState(() => _evaluated = true);
  }

  @override
  Widget build(BuildContext context) {
    const totalCapital = 10000.0;
    final isTotal100 = (_totalPct - 100).abs() < 1;

    return AppScaffold(
      appBar: AppBar(
        title: Text('Build a Portfolio', style: AppTypography.h2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Allocate \$10,000 Capital', style: AppTypography.h1),
            const SizedBox(height: 6),
            Text(
              'Distribute your capital across asset classes. Total must equal 100%.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // Total Allocation Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TOTAL ALLOCATION', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700)),
                Text(
                  '${_totalPct.toStringAsFixed(0)}% / 100%',
                  style: AppTypography.numericMedium.copyWith(
                    color: isTotal100 ? AppColors.profit : AppColors.loss,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                height: 12,
                color: AppColors.surfaceHighlight,
                child: Row(
                  children: [
                    Expanded(flex: _largeCap.round(), child: Container(color: AppColors.primary)),
                    Expanded(flex: _techGrowth.round(), child: Container(color: AppColors.secondary)),
                    Expanded(flex: _bonds.round(), child: Container(color: AppColors.profit)),
                    Expanded(flex: _cash.round(), child: Container(color: AppColors.accentGold)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Sliders
            _buildAssetSlider(
              name: 'Large Cap Index (e.g. S&P 500 / Nifty 50)',
              color: AppColors.primary,
              value: _largeCap,
              amount: totalCapital * (_largeCap / 100),
              onChanged: (v) => setState(() => _largeCap = v),
            ),
            const SizedBox(height: 14),
            _buildAssetSlider(
              name: 'High-Growth Tech (e.g. NVDA, AAPL)',
              color: AppColors.secondary,
              value: _techGrowth,
              amount: totalCapital * (_techGrowth / 100),
              onChanged: (v) => setState(() => _techGrowth = v),
            ),
            const SizedBox(height: 14),
            _buildAssetSlider(
              name: 'Fixed Income Bonds & Debt',
              color: AppColors.profit,
              value: _bonds,
              amount: totalCapital * (_bonds / 100),
              onChanged: (v) => setState(() => _bonds = v),
            ),
            const SizedBox(height: 14),
            _buildAssetSlider(
              name: 'Cash Safety Reserve',
              color: AppColors.accentGold,
              value: _cash,
              amount: totalCapital * (_cash / 100),
              onChanged: (v) => setState(() => _cash = v),
            ),

            const SizedBox(height: 24),

            if (!_evaluated)
              PrimaryButton(
                text: isTotal100 ? 'Analyze Diversification' : 'Adjust to 100% to Evaluate',
                onPressed: isTotal100 ? _evaluate : null,
              )
            else ...[
              // Evaluation Results Card
              GlassCard(
                padding: const EdgeInsets.all(20),
                borderColor: AppColors.profit,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('DIVERSIFICATION SCORE', style: AppTypography.caption.copyWith(color: AppColors.profit, fontWeight: FontWeight.w800)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.profitBackground,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${_calculateDiversificationScore()}/100',
                            style: AppTypography.h3.copyWith(color: AppColors.profit),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text('Risk Profile: ${_getRiskProfile()}', style: AppTypography.h3.copyWith(fontSize: 15)),
                    const SizedBox(height: 8),
                    Text(
                      _calculateDiversificationScore() > 70
                          ? 'Excellent balance! You have combined steady broad index foundation with controlled growth upside and defensive debt reserves (+75 XP earned).'
                          : 'High concentration risk detected. Having too much in high-volatility tech or excessive cash lowers overall portfolio efficiency.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                text: 'Done',
                onPressed: () => Navigator.pop(context),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetSlider({
    required String name,
    required Color color,
    required double value,
    required double amount,
    required Function(double) onChanged,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text(name, style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ],
              ),
              Text(
                '${value.toStringAsFixed(0)}% (${CurrencyFormatter.format(amount)})',
                style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700, color: color),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: AppColors.surfaceHighlight,
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 100,
              divisions: 20,
              onChanged: (newVal) {
                Haptics.selection();
                onChanged(newVal);
                setState(() => _evaluated = false);
              },
            ),
          ),
        ],
      ),
    );
  }
}
