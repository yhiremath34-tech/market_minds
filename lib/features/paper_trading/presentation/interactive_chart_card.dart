import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/glass_card.dart';
import '../../market_data/domain/market_models.dart';

class InteractiveChartCard extends StatefulWidget {
  final List<CandleData> candles;
  final TimeFrame selectedTimeFrame;
  final Function(TimeFrame) onTimeFrameChanged;
  final double currentPrice;
  final double change;
  final double changePercent;

  const InteractiveChartCard({
    super.key,
    required this.candles,
    required this.selectedTimeFrame,
    required this.onTimeFrameChanged,
    required this.currentPrice,
    required this.change,
    required this.changePercent,
  });

  @override
  State<InteractiveChartCard> createState() => _InteractiveChartCardState();
}

class _InteractiveChartCardState extends State<InteractiveChartCard> {
  bool _showCandlesticks = false;
  bool _showMovingAverage = true;
  int? _scrubbedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.candles.isEmpty) {
      return const SizedBox(
        height: 280,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final isPositive = widget.change >= 0;
    final activeColor = isPositive ? AppColors.profit : AppColors.loss;

    // Determine displayed price based on scrubbed point
    final displayPrice = _scrubbedIndex != null && _scrubbedIndex! < widget.candles.length
        ? widget.candles[_scrubbedIndex!].close
        : widget.currentPrice;

    final displayTime = _scrubbedIndex != null && _scrubbedIndex! < widget.candles.length
        ? widget.candles[_scrubbedIndex!].time
        : null;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price and Scrubber Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    CurrencyFormatter.format(displayPrice),
                    style: AppTypography.numericLarge.copyWith(fontSize: 26),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        color: activeColor,
                        size: 18,
                      ),
                      Text(
                        '${CurrencyFormatter.formatPnL(widget.change)} (${CurrencyFormatter.formatPercentage(widget.changePercent)})',
                        style: AppTypography.numericSmall.copyWith(
                          color: activeColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (displayTime != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '• ${displayTime.hour.toString().padLeft(2, '0')}:${displayTime.minute.toString().padLeft(2, '0')}',
                          style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              // Chart View Mode Toggles
              Row(
                children: [
                  // MA Toggle
                  IconButton(
                    icon: Icon(
                      Icons.ssid_chart,
                      color: _showMovingAverage ? AppColors.accentGold : AppColors.textDisabled,
                      size: 20,
                    ),
                    tooltip: 'Toggle 20 Moving Average',
                    onPressed: () {
                      Haptics.selection();
                      setState(() => _showMovingAverage = !_showMovingAverage);
                    },
                  ),
                  // Candlestick vs Line Toggle
                  IconButton(
                    icon: Icon(
                      _showCandlesticks ? Icons.show_chart : Icons.candlestick_chart,
                      color: _showCandlesticks ? AppColors.primary : AppColors.textSecondary,
                      size: 20,
                    ),
                    tooltip: _showCandlesticks ? 'Switch to Line' : 'Switch to Candlesticks',
                    onPressed: () {
                      Haptics.selection();
                      setState(() => _showCandlesticks = !_showCandlesticks);
                    },
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Interactive Chart Canvas
          SizedBox(
            height: 190,
            width: double.infinity,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                final RenderBox box = context.findRenderObject() as RenderBox;
                final localX = details.localPosition.dx.clamp(0.0, box.size.width);
                final index = ((localX / box.size.width) * (widget.candles.length - 1))
                    .round()
                    .clamp(0, widget.candles.length - 1);
                if (_scrubbedIndex != index) {
                  Haptics.selection();
                  setState(() => _scrubbedIndex = index);
                }
              },
              onHorizontalDragEnd: (_) => setState(() => _scrubbedIndex = null),
              onTapDown: (details) {
                final RenderBox box = context.findRenderObject() as RenderBox;
                final localX = details.localPosition.dx.clamp(0.0, box.size.width);
                final index = ((localX / box.size.width) * (widget.candles.length - 1))
                    .round()
                    .clamp(0, widget.candles.length - 1);
                Haptics.selection();
                setState(() => _scrubbedIndex = index);
              },
              onTapUp: (_) => setState(() => _scrubbedIndex = null),
              child: CustomPaint(
                painter: _MarketChartPainter(
                  candles: widget.candles,
                  showCandlesticks: _showCandlesticks,
                  showMovingAverage: _showMovingAverage,
                  scrubbedIndex: _scrubbedIndex,
                  lineColor: activeColor,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Timeframe Selector Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: TimeFrame.values.map((tf) {
              final isSelected = widget.selectedTimeFrame == tf;
              return GestureDetector(
                onTap: () {
                  Haptics.selection();
                  widget.onTimeFrameChanged(tf);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.surfaceHighlight : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    tf.label,
                    style: AppTypography.caption.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textTertiary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _MarketChartPainter extends CustomPainter {
  final List<CandleData> candles;
  final bool showCandlesticks;
  final bool showMovingAverage;
  final int? scrubbedIndex;
  final Color lineColor;

  _MarketChartPainter({
    required this.candles,
    required this.showCandlesticks,
    required this.showMovingAverage,
    required this.scrubbedIndex,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    double minPrice = double.infinity;
    double maxPrice = double.negativeInfinity;

    for (final c in candles) {
      if (c.low < minPrice) minPrice = c.low;
      if (c.high > maxPrice) maxPrice = c.high;
    }

    final priceRange = (maxPrice - minPrice).clamp(0.01, double.infinity);
    final dx = size.width / (candles.length - 1);

    // Grid lines
    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;
    for (int i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (showCandlesticks) {
      _paintCandles(canvas, size, minPrice, priceRange, dx);
    } else {
      _paintLineAndGradient(canvas, size, minPrice, priceRange, dx);
    }

    if (showMovingAverage && candles.length >= 5) {
      _paintMovingAverage(canvas, size, minPrice, priceRange, dx);
    }

    // Scrubber Line & Highlight Indicator
    if (scrubbedIndex != null && scrubbedIndex! < candles.length) {
      final scrubX = scrubbedIndex! * dx;
      final scrubY = size.height - ((candles[scrubbedIndex!].close - minPrice) / priceRange) * size.height;

      final scrubLinePaint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.7)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(scrubX, 0), Offset(scrubX, size.height), scrubLinePaint);

      // Scrubber point pulse
      final dotBgPaint = Paint()..color = AppColors.primary.withValues(alpha: 0.25);
      canvas.drawCircle(Offset(scrubX, scrubY), 8, dotBgPaint);

      final dotPaint = Paint()..color = AppColors.primary;
      canvas.drawCircle(Offset(scrubX, scrubY), 4, dotPaint);
    }
  }

  void _paintLineAndGradient(
    Canvas canvas,
    Size size,
    double minPrice,
    double priceRange,
    double dx,
  ) {
    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < candles.length; i++) {
      final x = i * dx;
      final y = size.height - ((candles[i].close - minPrice) / priceRange) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Gradient Fill
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        lineColor.withValues(alpha: 0.25),
        lineColor.withValues(alpha: 0.0),
      ],
    );

    final fillPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Stroke Path
    final strokePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);
  }

  void _paintCandles(
    Canvas canvas,
    Size size,
    double minPrice,
    double priceRange,
    double dx,
  ) {
    final candleWidth = max(2.5, dx * 0.65);

    for (int i = 0; i < candles.length; i++) {
      final c = candles[i];
      final x = i * dx;
      final color = c.isBullish ? AppColors.profit : AppColors.loss;

      final openY = size.height - ((c.open - minPrice) / priceRange) * size.height;
      final closeY = size.height - ((c.close - minPrice) / priceRange) * size.height;
      final highY = size.height - ((c.high - minPrice) / priceRange) * size.height;
      final lowY = size.height - ((c.low - minPrice) / priceRange) * size.height;

      // Wick (shadow)
      final wickPaint = Paint()
        ..color = color
        ..strokeWidth = 1.0;
      canvas.drawLine(Offset(x, highY), Offset(x, lowY), wickPaint);

      // Real Body
      final bodyTop = min(openY, closeY);
      final bodyHeight = max(2.0, (openY - closeY).abs());

      final bodyPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - (candleWidth / 2), bodyTop, candleWidth, bodyHeight),
          const Radius.circular(1.5),
        ),
        bodyPaint,
      );
    }
  }

  void _paintMovingAverage(
    Canvas canvas,
    Size size,
    double minPrice,
    double priceRange,
    double dx,
  ) {
    const period = 5;
    final maPath = Path();
    bool started = false;

    for (int i = period - 1; i < candles.length; i++) {
      double sum = 0;
      for (int j = 0; j < period; j++) {
        sum += candles[i - j].close;
      }
      final maPrice = sum / period;
      final x = i * dx;
      final y = size.height - ((maPrice - minPrice) / priceRange) * size.height;

      if (!started) {
        maPath.moveTo(x, y);
        started = true;
      } else {
        maPath.lineTo(x, y);
      }
    }

    final maPaint = Paint()
      ..color = AppColors.accentGold.withValues(alpha: 0.8)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(maPath, maPaint);
  }

  @override
  bool shouldRepaint(covariant _MarketChartPainter oldDelegate) {
    return oldDelegate.candles != candles ||
        oldDelegate.showCandlesticks != showCandlesticks ||
        oldDelegate.showMovingAverage != showMovingAverage ||
        oldDelegate.scrubbedIndex != scrubbedIndex ||
        oldDelegate.lineColor != lineColor;
  }
}
