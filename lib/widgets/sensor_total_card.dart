import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../core/theme/app_theme.dart';

/// Large numeric readout for cumulative values (`type: total`, per
/// 06_COMPONENT_LIBRARY.md). Tween-animated — never snaps.
class SensorTotalCard extends StatefulWidget {
  final double value;
  final String unit;
  final String label;
  final Color accentColor;

  /// Decimal places shown for the value.
  final int precision;

  /// Session duration shown under the value (optional).
  final Duration? elapsed;

  const SensorTotalCard({
    super.key,
    required this.value,
    required this.unit,
    required this.label,
    this.accentColor = AppColors.primary,
    this.precision = 1,
    this.elapsed,
  });

  @override
  State<SensorTotalCard> createState() => _SensorTotalCardState();
}

class _SensorTotalCardState extends State<SensorTotalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _anim;
  double _displayedValue = 0;

  @override
  void initState() {
    super.initState();
    _displayedValue = widget.value;
    _animController = AnimationController(
      vsync: this,
      duration: AppDimensions.durationTween,
    );
    _anim = AlwaysStoppedAnimation(widget.value);
  }

  @override
  void didUpdateWidget(SensorTotalCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      final start = _displayedValue;
      _anim = Tween<double>(
        begin: start,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOut,
      ));
      _animController.forward(from: 0);
      _animController.addListener(() {
        setState(() => _displayedValue = _anim.value);
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMd,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLg,
          vertical: AppDimensions.paddingMd,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accent.withAlpha(25),
              accent.withAlpha(10),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: accent.withAlpha(50),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              widget.label.toUpperCase(),
              style: AppTheme.gaugeLabelStyle(
                fontSize: 11,
                color: accent.withAlpha(180),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _displayedValue.toStringAsFixed(widget.precision),
                  style: AppTheme.gaugeValueStyle(
                    fontSize: 42,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    widget.unit,
                    style: AppTheme.gaugeUnitStyle(
                      fontSize: 18,
                      color: accent.withAlpha(180),
                    ),
                  ),
                ),
              ],
            ),
            if (widget.elapsed != null) ...[
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 12,
                    color: AppColors.mutedText.withAlpha(150),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDuration(widget.elapsed!),
                    style: AppTheme.gaugeUnitStyle(
                      fontSize: 12,
                      color: AppColors.mutedText.withAlpha(150),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
