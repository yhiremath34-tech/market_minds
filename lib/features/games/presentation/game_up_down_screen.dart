import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../app_state_provider.dart';

class GameUpDownScreen extends ConsumerStatefulWidget {
  const GameUpDownScreen({super.key});

  @override
  ConsumerState<GameUpDownScreen> createState() => _GameUpDownScreenState();
}

class _GameUpDownScreenState extends ConsumerState<GameUpDownScreen> {
  int _scenarioIndex = 0;
  bool? _userPredictionUp;
  bool _revealed = false;
  int _score = 0;

  final List<_Scenario> _scenarios = const [
    _Scenario(
      company: 'TechCorp International',
      event: 'Announces quarterly profits grew by 35%, beating analyst expectations. However, future quarter sales guidance was revised downward by 5%.',
      resultIsUp: false,
      lesson: 'Markets are forward-looking! Even when past earnings are great, if the future guidance is weaker, institutions often sell, causing short-term drops.',
    ),
    _Scenario(
      company: 'GreenEnergy Logistics',
      event: 'Signs a 5-year federal contract to deliver 50,000 electric charging hubs across national highways.',
      resultIsUp: true,
      lesson: 'Guaranteed multi-year revenue contracts provide revenue certainty, attracting long-term institutional buying pressure.',
    ),
    _Scenario(
      company: 'Global Retail Holdings',
      event: 'Launches a major discount shopping holiday, boosting transaction volume by 20%, but inflation raised shipping costs by 22%.',
      resultIsUp: false,
      lesson: 'High revenue without margin expansion does not create earnings. Operating cost inflation often outweighs volume increases.',
    ),
  ];

  void _predict(bool isUp) {
    Haptics.selection();
    final scenario = _scenarios[_scenarioIndex];
    final isCorrect = isUp == scenario.resultIsUp;

    if (isCorrect) {
      Haptics.heavy();
      ref.read(appStateProvider.notifier).addXp(40);
      setState(() {
        _userPredictionUp = isUp;
        _revealed = true;
        _score++;
      });
    } else {
      Haptics.medium();
      ref.read(appStateProvider.notifier).addXp(15);
      setState(() {
        _userPredictionUp = isUp;
        _revealed = true;
      });
    }
  }

  void _next() {
    Haptics.selection();
    if (_scenarioIndex < _scenarios.length - 1) {
      setState(() {
        _scenarioIndex++;
        _userPredictionUp = null;
        _revealed = false;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scenario = _scenarios[_scenarioIndex];

    return AppScaffold(
      appBar: AppBar(
        title: Text('Up or Down?', style: AppTypography.h2),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Scenario ${_scenarioIndex + 1} of ${_scenarios.length}',
                  style: AppTypography.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Score: $_score Correct',
                  style: AppTypography.caption.copyWith(color: AppColors.accentGold, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Scenario Card
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      scenario.company.toUpperCase(),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Market Scenario:', style: AppTypography.h3),
                  const SizedBox(height: 8),
                  Text(
                    scenario.event,
                    style: AppTypography.bodyLarge.copyWith(height: 1.45),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Prediction Buttons
            if (!_revealed) ...[
              Text(
                'How will the stock price react short-term?',
                style: AppTypography.body.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.profit,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => _predict(true),
                      icon: const Icon(Icons.arrow_upward, color: Colors.black),
                      label: Text('UP', style: AppTypography.button),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.loss,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => _predict(false),
                      icon: const Icon(Icons.arrow_downward, color: Colors.black),
                      label: Text('DOWN', style: AppTypography.button),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Result Reveal Card
              GlassCard(
                padding: const EdgeInsets.all(18),
                borderColor: scenario.resultIsUp ? AppColors.profit : AppColors.loss,
                backgroundColor: (scenario.resultIsUp ? AppColors.profit : AppColors.loss).withValues(alpha: 0.08),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          scenario.resultIsUp ? Icons.trending_up : Icons.trending_down,
                          color: scenario.resultIsUp ? AppColors.profit : AppColors.loss,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          scenario.resultIsUp ? 'Price Moved UP!' : 'Price Moved DOWN!',
                          style: AppTypography.h2.copyWith(
                            color: scenario.resultIsUp ? AppColors.profit : AppColors.loss,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _userPredictionUp == scenario.resultIsUp
                          ? '🎉 Great job! You identified the driving market catalyst (+40 XP).'
                          : '💡 Short-term price reactions often surprise beginners (+15 XP for practicing).',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      scenario.lesson,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.4),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              PrimaryButton(
                text: _scenarioIndex < _scenarios.length - 1 ? 'Next Scenario' : 'Finish Game',
                onPressed: _next,
              ),
            ],
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _Scenario {
  final String company;
  final String event;
  final bool resultIsUp;
  final String lesson;

  const _Scenario({
    required this.company,
    required this.event,
    required this.resultIsUp,
    required this.lesson,
  });
}
