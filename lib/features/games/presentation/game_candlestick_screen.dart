import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../app_state_provider.dart';
import '../domain/game_models.dart';

class GameCandlestickScreen extends ConsumerStatefulWidget {
  const GameCandlestickScreen({super.key});

  @override
  ConsumerState<GameCandlestickScreen> createState() => _GameCandlestickScreenState();
}

class _GameCandlestickScreenState extends ConsumerState<GameCandlestickScreen> {
  int _puzzleIndex = 0;
  int? _selectedOption;
  bool _answered = false;

  final List<CandlestickPuzzle> _puzzles = const [
    CandlestickPuzzle(
      patternName: 'Hammer',
      description: 'A small body near the top with a lower shadow at least twice the size of the body, indicating buyers rejected lower prices.',
      bullishBearish: 'Bullish Reversal',
      options: ['Hammer', 'Shooting Star', 'Doji', 'Bearish Engulfing'],
      correctIndex: 0,
      explanation: 'A Hammer occurs at the bottom of a downtrend. The long lower wick proves sellers pushed price down, but aggressive buyers rallied it back up.',
      visualKey: 'hammer',
    ),
    CandlestickPuzzle(
      patternName: 'Doji',
      description: 'Open and close prices are virtually identical, creating a thin cross or plus sign.',
      bullishBearish: 'Market Indecision',
      options: ['Marubozu', 'Morning Star', 'Doji', 'Spinning Top'],
      correctIndex: 2,
      explanation: 'A Doji represents equilibrium: neither buyers nor sellers could take control, signaling a potential pause or trend shift.',
      visualKey: 'doji',
    ),
    CandlestickPuzzle(
      patternName: 'Shooting Star',
      description: 'Small body near the bottom with a long upper wick at the top of an uptrend.',
      bullishBearish: 'Bearish Reversal',
      options: ['Inverted Hammer', 'Shooting Star', 'Hammer', 'Bullish Harami'],
      correctIndex: 1,
      explanation: 'A Shooting Star shows buyers tried to push to new highs, but heavy sellers rejected the move and pushed price back down.',
      visualKey: 'shooting_star',
    ),
  ];

  void _chooseOption(int index) {
    if (_answered) return;
    Haptics.selection();
    final puzzle = _puzzles[_puzzleIndex];
    final isCorrect = index == puzzle.correctIndex;

    if (isCorrect) {
      Haptics.heavy();
      ref.read(appStateProvider.notifier).addXp(60);
    } else {
      Haptics.medium();
      ref.read(appStateProvider.notifier).addXp(20);
    }

    setState(() {
      _selectedOption = index;
      _answered = true;
    });
  }

  void _next() {
    Haptics.selection();
    if (_puzzleIndex < _puzzles.length - 1) {
      setState(() {
        _puzzleIndex++;
        _selectedOption = null;
        _answered = false;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final puzzle = _puzzles[_puzzleIndex];

    return AppScaffold(
      appBar: AppBar(
        title: Text('Candlestick Puzzle', style: AppTypography.h2),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Puzzle ${_puzzleIndex + 1} of ${_puzzles.length}',
                  style: AppTypography.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
                Text(
                  puzzle.bullishBearish.toUpperCase(),
                  style: AppTypography.caption.copyWith(color: AppColors.accentGold, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Visual Candlestick Representation
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Center(
                child: Column(
                  children: [
                    _buildCandleGraphic(puzzle.visualKey),
                    const SizedBox(height: 16),
                    Text('What candlestick pattern is shown above?', style: AppTypography.h3),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Choices Grid
            ...List.generate(puzzle.options.length, (index) {
              final isSelected = _selectedOption == index;
              final isCorrect = puzzle.correctIndex == index;

              Color border = AppColors.border;
              Color bg = AppColors.surface;

              if (_answered) {
                if (isCorrect) {
                  border = AppColors.profit;
                  bg = AppColors.profitBackground;
                } else if (isSelected) {
                  border = AppColors.loss;
                  bg = AppColors.lossBackground;
                }
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => _chooseOption(index),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border, width: isSelected ? 1.5 : 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(puzzle.options[index], style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                        if (_answered && isCorrect)
                          const Icon(Icons.check_circle, color: AppColors.profit, size: 20)
                        else if (_answered && isSelected && !isCorrect)
                          const Icon(Icons.cancel, color: AppColors.loss, size: 20),
                      ],
                    ),
                  ),
                ),
              );
            }),

            if (_answered) ...[
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(14),
                child: Text(
                  puzzle.explanation,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.4),
                ),
              ),
              const Spacer(),
              PrimaryButton(
                text: _puzzleIndex < _puzzles.length - 1 ? 'Next Pattern' : 'Finish Challenge',
                onPressed: _next,
              ),
            ],
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildCandleGraphic(String key) {
    if (key == 'hammer') {
      return Column(
        children: [
          Container(width: 2, height: 6, color: AppColors.profit),
          Container(
            width: 28,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.profit,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(width: 2, height: 50, color: AppColors.profit),
        ],
      );
    } else if (key == 'doji') {
      return Column(
        children: [
          Container(width: 2, height: 35, color: AppColors.textPrimary),
          Container(width: 28, height: 2, color: AppColors.textPrimary),
          Container(width: 2, height: 35, color: AppColors.textPrimary),
        ],
      );
    } else {
      return Column(
        children: [
          Container(width: 2, height: 50, color: AppColors.loss),
          Container(
            width: 28,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.loss,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(width: 2, height: 6, color: AppColors.loss),
        ],
      );
    }
  }
}
