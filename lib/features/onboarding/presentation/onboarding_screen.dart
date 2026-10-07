import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/primary_button.dart';
import '../../app_state_provider.dart';
import '../../auth/presentation/login_screen.dart';
import '../../home/presentation/main_navigation_shell.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<_OnboardingSlide> _slides = const [
    _OnboardingSlide(
      title: 'Welcome to\nMarket Minds',
      subtitle: 'Learn. Play. Practice. Master the Market.',
      description:
          'The premier educational simulation teaching high-impact financial literacy and market decision-making.',
      icon: Icons.rocket_launch_outlined,
      accentColor: AppColors.primary,
    ),
    _OnboardingSlide(
      title: 'Interactive Short Lessons',
      subtitle: 'Bite-Sized Modules & Quizzes',
      description:
          'Master stocks, indices, candlestick charts, ETFs, and risk management through 10 gamified levels. No boring walls of text.',
      icon: Icons.school_outlined,
      accentColor: AppColors.profit,
    ),
    _OnboardingSlide(
      title: '\$10,000 Virtual Capital',
      subtitle: 'Zero Risk Paper Trading',
      description:
          'Practice buying and selling real-world assets with simulated currency. Learn portfolio sizing and discipline before real investing.',
      icon: Icons.monetization_on_outlined,
      accentColor: AppColors.accentGold,
    ),
    _OnboardingSlide(
      title: 'Play, Compete & Earn XP',
      subtitle: 'Market Games & Leaderboards',
      description:
          'Challenge yourself with Up or Down predictions, Candlestick Puzzles, and Portfolio Battles to earn badges and climb ranks.',
      icon: Icons.emoji_events_outlined,
      accentColor: AppColors.secondary,
    ),
  ];

  void _onNext() async {
    Haptics.selection();
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() async {
    await ref.read(appStateProvider.notifier).completeOnboarding();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentIndex == _slides.length - 1;

    return AppScaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          children: [
            // Top Skip Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(
                    _slides.length,
                    (index) => Container(
                      margin: const EdgeInsets.only(right: 6),
                      width: _currentIndex == index ? 24 : 8,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _currentIndex == index
                            ? AppColors.primary
                            : AppColors.surfaceHighlight,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _finishOnboarding,
                  child: Text(
                    'Skip',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Page View
            SizedBox(
              height: 380,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (idx) => setState(() => _currentIndex = idx),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: slide.accentColor.withValues(alpha: 0.15),
                          border: Border.all(
                            color: slide.accentColor.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: slide.accentColor.withValues(alpha: 0.2),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          slide.icon,
                          size: 48,
                          color: slide.accentColor,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        slide.title,
                        textAlign: TextAlign.center,
                        style: AppTypography.display.copyWith(fontSize: 28),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        slide.subtitle,
                        textAlign: TextAlign.center,
                        style: AppTypography.h3.copyWith(
                          color: slide.accentColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        slide.description,
                        textAlign: TextAlign.center,
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const Spacer(),

            // Action Buttons
            PrimaryButton(
              text: isLast ? 'Start Exploring' : 'Continue',
              onPressed: _onNext,
            ),
            const SizedBox(height: 12),
            if (isLast)
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: Text(
                  'Already have an account? Log In',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color accentColor;

  const _OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}
