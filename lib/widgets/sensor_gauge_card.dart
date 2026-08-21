import 'dart:math';

import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../core/theme/app_theme.dart';

class SensorGaugeCard extends StatefulWidget {
  final double value;
  final String unit;
  final String label;
  final double min;
  final double max;
  final Color accentColor;
  final bool isComingSoon;
  final bool isLoading;

  const SensorGaugeCard({
    super.key,
    required this.value,
    required this.unit,
    required this.label,
    required this.min,
    required this.max,
    this.accentColor = AppColors.primary,
    this.isComingSoon = false,
    this.isLoading = false,
  });

  @override
  State<SensorGaugeCard> createState() => _SensorGaugeCardState();
}

class _SensorGaugeCardState extends State<SensorGaugeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _valueAnimation;
  double _displayedValue = 0;

  @override
  void initState() {
    super.initState();
    _displayedValue = widget.value;
    _animController = AnimationController(
      vsync: this,
      duration: AppDimensions.durationTween,
    );
    _valueAnimation = AlwaysStoppedAnimation(widget.value);
  }

  @override
  void didUpdateWidget(SensorGaugeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !widget.isComingSoon) {
      final start = _displayedValue;
      _valueAnimation = Tween<double>(
        begin: start,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOut,
      ));
      _animController.forward(from: 0);
      _animController.addListener(() {
        setState(() => _displayedValue = _valueAnimation.value);
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fraction = widget.max > 0
        ? (widget.value / widget.max).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLg),
        child: Column(
          children: [
            Text(
              widget.label,
              style: AppTheme.gaugeLabelStyle(),
            ),
            const SizedBox(height: AppDimensions.paddingLg),
            SizedBox(
              width: 200,
              height: 200,
              child: CustomPaint(
                painter: _GaugePainter(
                  fraction: widget.isComingSoon ? 0.5 : fraction,
                  accentColor: widget.accentColor,
                  isComingSoon: widget.isComingSoon,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.isComingSoon
                            ? '--'
                            : _displayedValue.toStringAsFixed(1),
                        style: AppTheme.gaugeValueStyle(
                          color: widget.accentColor,
                        ),
                      ),
                      Text(
                        widget.unit,
                        style: AppTheme.gaugeUnitStyle(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double fraction;
  final Color accentColor;
  final bool isComingSoon;

  _GaugePainter({
    required this.fraction,
    required this.accentColor,
    required this.isComingSoon,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    // Background arc
    final bgPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi * 0.75,
      pi * 1.5,
      false,
      bgPaint,
    );

    // Value arc
    final valuePaint = Paint()
      ..color = isComingSoon
          ? accentColor.withAlpha(60)
          : accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final sweepAngle = pi * 1.5 * fraction;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi * 0.75,
      sweepAngle,
      false,
      valuePaint,
    );

    // Tick marks
    final tickPaint = Paint()
      ..color = AppColors.mutedText.withAlpha(80)
      ..strokeWidth = 1;

    for (int i = 0; i <= 10; i++) {
      final angle = pi * 0.75 + (pi * 1.5 * i / 10);
      final inner = Offset(
        center.dx + cos(angle) * (radius - 10),
        center.dy + sin(angle) * (radius - 10),
      );
      final outer = Offset(
        center.dx + cos(angle) * (radius - 4),
        center.dy + sin(angle) * (radius - 4),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }

    // Needle
    if (!isComingSoon && fraction > 0) {
      final needleAngle = pi * 0.75 + pi * 1.5 * fraction;
      final needlePaint = Paint()
        ..color = accentColor
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      final needleEnd = Offset(
        center.dx + cos(needleAngle) * (radius - 16),
        center.dy + sin(needleAngle) * (radius - 16),
      );
      canvas.drawLine(center, needleEnd, needlePaint);

      // Needle center dot
      canvas.drawCircle(center, 4, Paint()..color = accentColor);
    }
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      fraction != old.fraction || accentColor != old.accentColor;
}
