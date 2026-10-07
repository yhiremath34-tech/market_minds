import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_card.dart';
import '../../app_state_provider.dart';
import '../data/learning_curriculum.dart';
import '../domain/learning_models.dart';
import 'lesson_screen.dart';

class LearningHubScreen extends ConsumerWidget {
  const LearningHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final completed = state.completedLessons;
    final totalLessons = LearningCurriculum.levels
        .fold(0, (sum, lvl) => sum + lvl.lessons.length);
    final completedCount = completed.length;
    final progressPercent = (completedCount / totalLessons).clamp(0.0, 1.0);

    return AppScaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            title: Text('Financial Academy', style: AppTypography.h1),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(74),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('OVERALL PROGRESS', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(
                            '$completedCount of $totalLessons Modules Completed',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          '${(progressPercent * 100).toInt()}%',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Levels Progression List
          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final level = LearningCurriculum.levels[index];
                  final isLevelCompleted = level.lessons.every((l) => completed.contains(l.id));
                  final isUnlocked = index == 0 ||
                      LearningCurriculum.levels[index - 1].lessons.any((l) => completed.contains(l.id));

                  return _buildLevelCard(
                    context,
                    level: level,
                    isCompleted: isLevelCompleted,
                    isUnlocked: isUnlocked,
                    completedSet: completed,
                  );
                },
                childCount: LearningCurriculum.levels.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(
    BuildContext context, {
    required LearningLevel level,
    required bool isCompleted,
    required bool isUnlocked,
    required Set<String> completedSet,
  }) {
    final statusColor = isCompleted
        ? AppColors.profit
        : (isUnlocked ? level.accentColor : AppColors.textDisabled);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(18),
        borderColor: isCompleted
            ? AppColors.profit.withValues(alpha: 0.4)
            : (isUnlocked ? level.accentColor.withValues(alpha: 0.3) : AppColors.border),
        onTap: isUnlocked
            ? () {
                Haptics.selection();
                final lesson = level.lessons.first;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LessonScreen(lesson: lesson, level: level),
                  ),
                );
              }
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Level Icon Badge
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.check_circle
                        : (isUnlocked ? level.icon : Icons.lock_outline),
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'LEVEL ${level.id}',
                            style: AppTypography.caption.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                          Text(
                            '+${level.totalXp} XP',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.accentGold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(level.title, style: AppTypography.h3),
                      const SizedBox(height: 2),
                      Text(
                        level.subtitle,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              level.description,
              style: AppTypography.bodySmall.copyWith(
                color: isUnlocked ? AppColors.textSecondary : AppColors.textDisabled,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            // Bottom Action Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${level.lessons.length} Lesson • ~4 mins',
                  style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                ),
                if (isCompleted)
                  Row(
                    children: [
                      const Icon(Icons.check, size: 14, color: AppColors.profit),
                      const SizedBox(width: 4),
                      Text(
                        'Mastered',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.profit,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                else if (isUnlocked)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: level.accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Start Module',
                      style: AppTypography.caption.copyWith(
                        color: level.accentColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  Text(
                    'Complete previous level',
                    style: AppTypography.caption.copyWith(color: AppColors.textDisabled),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
