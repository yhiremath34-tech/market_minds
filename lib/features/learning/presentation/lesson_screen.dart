import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../app_state_provider.dart';
import '../domain/learning_models.dart';

class LessonScreen extends ConsumerStatefulWidget {
  final Lesson lesson;
  final LearningLevel level;

  const LessonScreen({
    super.key,
    required this.lesson,
    required this.level,
  });

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  int _currentStepIndex = 0;
  int? _selectedChoiceIndex;
  bool _hasAnswered = false;

  void _onChoiceSelected(int index) {
    if (_hasAnswered) return;
    Haptics.selection();
    setState(() {
      _selectedChoiceIndex = index;
    });
  }

  void _checkAnswer(QuizQuestion quiz) {
    if (_selectedChoiceIndex == null) return;
    final isCorrect = _selectedChoiceIndex == quiz.correctIndex;
    if (isCorrect) {
      Haptics.heavy();
    } else {
      Haptics.medium();
    }
    setState(() {
      _hasAnswered = true;
    });
  }

  void _nextStep() {
    Haptics.selection();
    if (_currentStepIndex < widget.lesson.steps.length - 1) {
      setState(() {
        _currentStepIndex++;
        _selectedChoiceIndex = null;
        _hasAnswered = false;
      });
    } else {
      _finishLesson();
    }
  }

  void _finishLesson() async {
    Haptics.heavy();
    await ref.read(appStateProvider.notifier).completeLesson(
      widget.lesson.id,
      widget.lesson.xpReward,
      widget.lesson.coinReward,
    );

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: AppColors.border, width: 1.5)),
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.workspace_premium, color: Colors.black, size: 44),
            ),
            const SizedBox(height: 20),
            Text('Module Mastered!', style: AppTypography.h1),
            const SizedBox(height: 6),
            Text(
              'You successfully completed "${widget.lesson.title}". Your financial competence is growing!',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt, color: AppColors.accentGold, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '+${widget.lesson.xpReward} XP',
                        style: AppTypography.h3.copyWith(color: AppColors.accentGold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.monetization_on, color: AppColors.primary, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '+${widget.lesson.coinReward} Coins',
                        style: AppTypography.h3.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            PrimaryButton(
              text: 'Claim Rewards & Return',
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.lesson.steps[_currentStepIndex];
    final progress = (_currentStepIndex + 1) / widget.lesson.steps.length;

    return AppScaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Back, Level badge, Progress
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceHighlight,
                      valueColor: AlwaysStoppedAnimation<Color>(widget.level.accentColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${_currentStepIndex + 1}/${widget.lesson.steps.length}',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Step Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Level & Step Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.level.accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: widget.level.accentColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        'LEVEL ${widget.level.id} • ${step.type.name.toUpperCase()}',
                        style: AppTypography.caption.copyWith(
                          color: widget.level.accentColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(step.title, style: AppTypography.h1),
                    const SizedBox(height: 14),

                    // Visual diagram representation if specified
                    if (step.diagramType != null) ...[
                      _buildDiagramCard(step.diagramType!),
                      const SizedBox(height: 18),
                    ],

                    Text(
                      step.content,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.55,
                      ),
                    ),

                    // Quiz Step Interactive Choices
                    if (step.quiz != null) ...[
                      const SizedBox(height: 24),
                      Text(step.quiz!.question, style: AppTypography.h3),
                      const SizedBox(height: 14),
                      ...List.generate(step.quiz!.choices.length, (index) {
                        return _buildQuizOption(index, step.quiz!);
                      }),

                      if (_hasAnswered) ...[
                        const SizedBox(height: 16),
                        _buildFeedbackCard(step.quiz!),
                      ],
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Navigation CTA
            const SizedBox(height: 14),
            if (step.quiz != null && !_hasAnswered)
              PrimaryButton(
                text: 'Check Answer',
                onPressed: _selectedChoiceIndex != null ? () => _checkAnswer(step.quiz!) : null,
              )
            else
              PrimaryButton(
                text: _currentStepIndex == widget.lesson.steps.length - 1 ? 'Complete Module' : 'Continue',
                onPressed: _nextStep,
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagramCard(String type) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      backgroundColor: AppColors.surfaceHighlight.withValues(alpha: 0.5),
      child: Center(
        child: Column(
          children: [
            Icon(
              type.contains('candle')
                  ? Icons.candlestick_chart
                  : (type.contains('shield')
                      ? Icons.shield
                      : (type.contains('growth') ? Icons.trending_up : Icons.pie_chart)),
              size: 54,
              color: widget.level.accentColor,
            ),
            const SizedBox(height: 12),
            Text(
              type.replaceAll('_', ' ').toUpperCase(),
              style: AppTypography.caption.copyWith(
                color: widget.level.accentColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizOption(int index, QuizQuestion quiz) {
    final isSelected = _selectedChoiceIndex == index;
    final isCorrect = quiz.correctIndex == index;

    Color borderColor = AppColors.border;
    Color bgColor = AppColors.surface;

    if (_hasAnswered) {
      if (isCorrect) {
        borderColor = AppColors.profit;
        bgColor = AppColors.profitBackground;
      } else if (isSelected) {
        borderColor = AppColors.loss;
        bgColor = AppColors.lossBackground;
      }
    } else if (isSelected) {
      borderColor = AppColors.primary;
      bgColor = AppColors.primary.withValues(alpha: 0.1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => _onChoiceSelected(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor),
                  color: isSelected ? borderColor : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(
                        _hasAnswered
                            ? (isCorrect ? Icons.check : Icons.close)
                            : Icons.circle,
                        size: 14,
                        color: Colors.black,
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  quiz.choices[index].text,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(QuizQuestion quiz) {
    final isCorrect = _selectedChoiceIndex == quiz.correctIndex;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? AppColors.profitBackground : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isCorrect ? AppColors.profit : AppColors.primary).withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.lightbulb_outline,
                color: isCorrect ? AppColors.profit : AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Nice! You understand the basic idea.' : 'Not quite. Let\'s understand why:',
                style: AppTypography.h3.copyWith(
                  fontSize: 15,
                  color: isCorrect ? AppColors.profit : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            quiz.explanation,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
