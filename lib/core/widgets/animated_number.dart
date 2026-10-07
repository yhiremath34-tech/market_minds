import 'package:flutter/material.dart';
import '../utils/currency_formatter.dart';

class AnimatedNumber extends StatelessWidget {
  final double value;
  final TextStyle style;
  final Duration duration;
  final bool isCurrency;
  final String prefix;
  final String suffix;

  const AnimatedNumber({
    super.key,
    required this.value,
    required this.style,
    this.duration = const Duration(milliseconds: 650),
    this.isCurrency = false,
    this.prefix = '',
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedVal, child) {
        String displayText;
        if (isCurrency) {
          displayText = CurrencyFormatter.format(animatedVal);
        } else if (animatedVal % 1 == 0) {
          displayText = animatedVal.toInt().toString();
        } else {
          displayText = animatedVal.toStringAsFixed(2);
        }

        return Text(
          '$prefix$displayText$suffix',
          style: style,
        );
      },
    );
  }
}
