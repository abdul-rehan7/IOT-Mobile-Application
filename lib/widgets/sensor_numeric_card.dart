import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/app_icons.dart';

class SensorNumericCard extends StatelessWidget {
  final double value;
  final String unit;
  final String label;
  final String icon;
  final bool isComingSoon;
  final Color accentColor;

  /// Decimal places shown for the value (e.g. temperature = 1).
  final int precision;

  const SensorNumericCard({
    super.key,
    required this.value,
    required this.unit,
    required this.label,
    this.icon = 'sensors',
    this.isComingSoon = false,
    this.accentColor = AppColors.primary,
    this.precision = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(AppIcons.fromKey(icon), color: accentColor, size: 20),
                const SizedBox(width: AppDimensions.paddingSm),
                Text(
                  label,
                  style: AppTheme.gaugeLabelStyle(),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingMd),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  isComingSoon ? '--' : value.toStringAsFixed(precision),
                  style: AppTheme.gaugeValueStyle(
                    fontSize: 36,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingSm),
                Text(
                  unit,
                  style: AppTheme.gaugeUnitStyle(fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
