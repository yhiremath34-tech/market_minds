import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../app_state_provider.dart';

class GameQuizBattleScreen extends ConsumerStatefulWidget {
  const GameQuizBattleScreen({super.key});

  @override
  ConsumerState<GameQuizBattleScreen> createState() => _GameQuizBattleScreenState();
}

class _GameQuizBattleScreenState extends ConsumerState<GameQuizBattleScreen> {
  int _questionIndex = 0;
  int _secondsLeft = 15;
  Timer? _timer;
  int _totalScore = 0;
  int? _selectedChoice;
  bool _answered = false;

  final List<_BattleQuestion> _questions = const [
    _BattleQuestion(
      question: 'Which of the following is an Exchange Traded Fund (ETF)?',
      choices: ['AAPL', 'SPY', 'TSLA', 'BTC'],
      correctIndex: 1,
      explanation: 'SPY is the SPDR S&P 500 ETF Trust tracking the 500 largest US companies.',
    ),
    _BattleQuestion(
      question: 'What does a "Stop Loss" order do automatically?',
      choices: [
        'Buys double the shares when price drops',
        'Sells your shares at a predetermined price to limit potential downside',
        'Guarantees 50% profit',
        'Cancels all previous dividends',
      ],
      correctIndex: 1,
      explanation: 'Stop losses protect capital by cutting losses at your defined risk boundary.',
    ),
    _BattleQuestion(
      question: 'What is the Net Asset Value (NAV) of a Mutual Fund?',
      choices: [
        'The per-unit market value of all securities held in the fund minus liabilities',
        'The salary of the fund manager',
        'The tax paid on withdrawal',
        'The government interest rate',
      ],
      correctIndex: 0,
      explanation: 'NAV represents the per-share value of the mutual fund\'s portfolio assets.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = 15;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft > 1) {
        setState(() => _secondsLeft--);
      } else {
        t.cancel();
        _timeRanOut();
      }
    });
  }

  void _timeRanOut() {
    if (_answered) return;
    Haptics.heavy();
    setState(() {
      _answered = true;
      _selectedChoice = -1; // timed out
    });
  }

  void _selectChoice(int index) {
    if (_answered) return;
    _timer?.cancel();
    final q = _questions[_questionIndex];
    final isCorrect = index == q.correctIndex;

    if (isCorrect) {
      Haptics.heavy();
      final speedBonus = _secondsLeft * 5;
      final points = 50 + speedBonus;
      _totalScore += points;
      ref.read(appStateProvider.notifier).addXp(points);
    } else {
      Haptics.medium();
      ref.read(appStateProvider.notifier).addXp(15);
    }

    setState(() {
      _selectedChoice = index;
      _answered = true;
    });
  }

  void _next() {
    Haptics.selection();
    if (_questionIndex < _questions.length - 1) {
      setState(() {
        _questionIndex++;
        _selectedChoice = null;
        _answered = false;
      });
      _startTimer();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_questionIndex];

    return AppScaffold(
      appBar: AppBar(
        title: Text('Market Quiz Battle', style: AppTypography.h2),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Timer & Score
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: _secondsLeft <= 5 ? AppColors.loss : AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_secondsLeft}s',
                      style: AppTypography.numericMedium.copyWith(
                        color: _secondsLeft <= 5 ? AppColors.loss : AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Score: $_totalScore pts',
                  style: AppTypography.numericMedium.copyWith(color: AppColors.accentGold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _secondsLeft / 15,
                backgroundColor: AppColors.surfaceHighlight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _secondsLeft <= 5 ? AppColors.loss : AppColors.primary,
                ),
                minHeight: 6,
              ),
            ),

            const SizedBox(height: 24),

            // Question Card
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'QUESTION ${_questionIndex + 1} OF ${_questions.length}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(q.question, style: AppTypography.h3),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Choices
            ...List.generate(q.choices.length, (idx) {
              final isSelected = _selectedChoice == idx;
              final isCorrect = q.correctIndex == idx;

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
                  onTap: () => _selectChoice(idx),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border, width: isSelected ? 1.5 : 1),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${String.fromCharCode(65 + idx)}.',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            q.choices[idx],
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            if (_answered) ...[
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(12),
                child: Text(
                  q.explanation,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ),
              const Spacer(),
              PrimaryButton(
                text: _questionIndex < _questions.length - 1 ? 'Next Question' : 'Finish Battle',
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

class _BattleQuestion {
  final String question;
  final List<String> choices;
  final int correctIndex;
  final String explanation;

  const _BattleQuestion({
    required this.question,
    required this.choices,
    required this.correctIndex,
    required this.explanation,
  });
}
