import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../core/theme/app_theme.dart';
import '../models/sensor.dart';
import '../providers/providers.dart';
import '../services/connection/mock_connection_service.dart';
import 'coming_soon_overlay.dart';
import 'sensor_gauge_card.dart';
import 'sensor_numeric_card.dart';
import 'sensor_total_card.dart';

/// Generic, config-driven tab renderer (per 06_COMPONENT_LIBRARY.md):
/// draws every sensor in the tab group using the widget mapped to its
/// `type`, and wraps non-active sensors in the Coming Soon state.
/// A new sensor/tab is a config change, not a shell rewrite.
class SensorTabView extends ConsumerWidget {
  final List<Sensor> sensors;

  const SensorTabView({super.key, required this.sensors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readings = ref.watch(sensorReadingsProvider);
    final values = readings.value ?? const {};

    // Trend history / session timer are mock-only niceties.
    final connection = ref.read(connectionServiceProvider);
    final mock = connection is MockConnectionService ? connection : null;

    final hasFlow =
        sensors.any((s) => s.type == 'flow' && s.isActive);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.paddingMd,
      ),
      child: Column(
        children: [
          for (final sensor in sensors)
            Padding(
              padding: const EdgeInsets.only(
                bottom: AppDimensions.paddingMd,
              ),
              child: _buildSensorCard(
                sensor,
                values[sensor.key] ?? 0.0,
                elapsed: mock?.elapsed,
              ),
            ),
          // Flow trend chart appended last to keep the established
          // Flow tab layout: gauge -> total -> trend.
          if (hasFlow && mock != null) _buildTrendSection(mock),
        ],
      ),
    );
  }

  Widget _buildSensorCard(Sensor sensor, double value,
      {Duration? elapsed}) {
    final accent = AppColors.byName(sensor.accent);

    Widget card;
    switch (sensor.type) {
      case 'flow':
      case 'gauge':
        card = SensorGaugeCard(
          value: value,
          unit: sensor.unit,
          label: sensor.name,
          min: 0,
          max: sensor.simMax > 0 ? sensor.simMax : 100,
          accentColor: accent,
        );
        break;
      case 'total':
        card = SensorTotalCard(
          value: value,
          unit: sensor.unit,
          label: sensor.name,
          accentColor: accent,
          precision: sensor.precision,
          elapsed: elapsed,
        );
        break;
      case 'numeric':
      default:
        card = SensorNumericCard(
          value: value,
          unit: sensor.unit,
          label: sensor.name,
          icon: sensor.icon,
          precision: sensor.precision,
          accentColor: accent,
        );
        break;
    }

    if (sensor.isComingSoon) {
      return ComingSoonOverlay(child: card);
    }
    return card;
  }

  Widget _buildTrendSection(MockConnectionService mock) {
    final flowSensor =
        sensors.firstWhere((s) => s.type == 'flow' && s.isActive);
    final accent = AppColors.byName(flowSensor.accent);
    final history = mock.flowHistory;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMd,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.show_chart,
                  size: 14,
                  color: accent.withAlpha(180),
                ),
                const SizedBox(width: 6),
                Text(
                  '${flowSensor.name.toUpperCase()} TREND',
                  style: AppTheme.gaugeLabelStyle(
                    fontSize: 11,
                    color: AppColors.mutedText.withAlpha(180),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingSm),
            SizedBox(
              height: 120,
              child: history.length < 2
                  ? Center(
                      child: Text(
                        'Collecting data...',
                        style: AppTheme.gaugeUnitStyle(
                          fontSize: 12,
                          color: AppColors.mutedText.withAlpha(120),
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSm,
                      ),
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _TrendChartPainter(
                          data: history,
                          color: accent,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'min: ${history.isEmpty ? '--' : history.reduce(min).toStringAsFixed(1)} ${flowSensor.unit}',
                  style: AppTheme.gaugeUnitStyle(
                    fontSize: 10,
                    color: AppColors.mutedText.withAlpha(120),
                  ),
                ),
                Text(
                  'max: ${history.isEmpty ? '--' : history.reduce(max).toStringAsFixed(1)} ${flowSensor.unit}',
                  style: AppTheme.gaugeUnitStyle(
                    fontSize: 10,
                    color: AppColors.mutedText.withAlpha(120),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class _TrendChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _TrendChartPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final minVal = data.reduce(min);
    final maxVal = data.reduce(max);
    final range = (maxVal - minVal).clamp(0.1, double.infinity);

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withAlpha(40),
          color.withAlpha(5),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final linePath = Path();
    final fillPath = Path();

    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = size.width * i / (data.length - 1);
      final y = size.height - ((data[i] - minVal) / range) * (size.height - 8) - 4;
      points.add(Offset(x, y));
    }

    linePath.moveTo(points.first.dx, points.first.dy);
    fillPath.moveTo(points.first.dx, size.height);
    fillPath.lineTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final cx = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(cx, prev.dy, cx, curr.dy, curr.dx, curr.dy);
      fillPath.cubicTo(cx, prev.dy, cx, curr.dy, curr.dx, curr.dy);
    }

    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);

    // Glow dot on latest point
    final last = points.last;
    final glowPaint = Paint()
      ..color = color.withAlpha(60)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(last, 4, glowPaint);
    canvas.drawCircle(last, 3, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_TrendChartPainter old) => data != old.data;
}
