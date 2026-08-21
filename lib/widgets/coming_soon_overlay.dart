import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../core/constants/app_strings.dart';

class ComingSoonOverlay extends StatefulWidget {
  final Widget child;

  const ComingSoonOverlay({super.key, required this.child});

  @override
  State<ComingSoonOverlay> createState() => _ComingSoonOverlayState();
}

class _ComingSoonOverlayState extends State<ComingSoonOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The actual card (dimmed)
        Opacity(
          opacity: 0.6,
          child: widget.child,
        ),
        // Shimmer overlay
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, _) {
              return CustomPaint(
                painter: _ShimmerPainter(
                  progress: _shimmerController.value,
                ),
              );
            },
          ),
        ),
        // "Coming Soon" banner
        Positioned(
          bottom: AppDimensions.paddingLg,
          left: AppDimensions.paddingLg,
          right: AppDimensions.paddingLg,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMd,
              vertical: AppDimensions.paddingSm,
            ),
            decoration: BoxDecoration(
              color: AppColors.background.withAlpha(200),
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusSm),
              border: Border.all(
                color: AppColors.mutedText.withAlpha(40),
                width: 1,
              ),
            ),
            child: const Text(
              AppStrings.comingSoon,
              style: TextStyle(
                color: AppColors.mutedText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  final double progress;

  _ShimmerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: const Alignment(-1, 0),
        end: const Alignment(1, 0),
        colors: [
          Colors.transparent,
          Colors.white.withAlpha(20),
          Colors.transparent,
        ],
        stops: [progress - 0.3, progress, progress + 0.3],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ShimmerPainter old) => progress != old.progress;
}
