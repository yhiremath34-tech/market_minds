import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_calculator.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../app_state_provider.dart';
import 'onboarding_screen.dart';

class AgeVerificationScreen extends ConsumerStatefulWidget {
  const AgeVerificationScreen({super.key});

  @override
  ConsumerState<AgeVerificationScreen> createState() => _AgeVerificationScreenState();
}

class _AgeVerificationScreenState extends ConsumerState<AgeVerificationScreen> {
  DateTime? _selectedDate;
  int? _calculatedAge;
  bool? _isEligible;

  void _selectDate(BuildContext context) async {
    Haptics.selection();
    final now = DateTime.now();
    final initial = DateTime(now.year - 17, now.month, now.day);
    final firstDate = DateTime(now.year - 100);
    final lastDate = now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.black,
              surface: AppColors.surfaceElevated,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final age = DateCalculator.calculateAge(picked);
      final eligible = age >= AppConstants.minimumAge;
      setState(() {
        _selectedDate = picked;
        _calculatedAge = age;
        _isEligible = eligible;
      });
      if (eligible) {
        Haptics.medium();
      } else {
        Haptics.heavy();
      }
    }
  }

  void _proceed() async {
    if (_isEligible == true) {
      Haptics.medium();
      await ref.read(appStateProvider.notifier).verifyAge(true);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),

            // Badge Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
              ),
              child: const Icon(
                Icons.verified_user_outlined,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Age Verification',
              style: AppTypography.h1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Market Minds is an educational trading simulation designed for learners aged 16 and above.',
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Date of birth selection card
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Select Your Date of Birth',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: () => _selectDate(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHighlight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                              const SizedBox(width: 12),
                              Text(
                                _selectedDate == null
                                    ? 'Tap to choose birth date'
                                    : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}',
                                style: AppTypography.bodyLarge.copyWith(
                                  color: _selectedDate == null
                                      ? AppColors.textTertiary
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),

                  // Eligibility result state
                  if (_calculatedAge != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _isEligible!
                            ? AppColors.profitBackground
                            : AppColors.lossBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (_isEligible! ? AppColors.profit : AppColors.loss)
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            _isEligible! ? Icons.check_circle : Icons.block,
                            color: _isEligible! ? AppColors.profit : AppColors.loss,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isEligible!
                                      ? 'Eligible (Age: $_calculatedAge years)'
                                      : 'Age Restricted (Age: $_calculatedAge years)',
                                  style: AppTypography.h3.copyWith(
                                    color: _isEligible! ? AppColors.profit : AppColors.loss,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _isEligible!
                                      ? 'You meet the minimum age requirement of 16 years. Welcome to Market Minds!'
                                      : 'This app is designed for users aged 16 years and above. Please return when you reach 16.',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),
            Text(
              'Privacy Note: We only verify age eligibility. Your date of birth is never shared or stored remotely.',
              style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            // CTA Button
            PrimaryButton(
              text: 'Enter Market Minds',
              onPressed: _isEligible == true ? _proceed : null,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
