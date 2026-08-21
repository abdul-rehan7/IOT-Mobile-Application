import 'package:flutter/material.dart';

enum BadgeStatus { connected, reconnecting, offline }

class ConnectionStatusBadge extends StatefulWidget {
  final BadgeStatus status;

  const ConnectionStatusBadge({super.key, required this.status});

  @override
  State<ConnectionStatusBadge> createState() => _ConnectionStatusBadgeState();
}

class _ConnectionStatusBadgeState extends State<ConnectionStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.status != BadgeStatus.offline) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ConnectionStatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status != oldWidget.status) {
      if (widget.status == BadgeStatus.offline) {
        _pulseController.stop();
        _pulseController.value = 0;
      } else {
        _pulseController.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _dotColor {
    switch (widget.status) {
      case BadgeStatus.connected:
        return const Color(0xFF2FD5C8);
      case BadgeStatus.reconnecting:
        return const Color(0xFFF2A93B);
      case BadgeStatus.offline:
        return const Color(0xFF8A93A3);
    }
  }

  String get _label {
    switch (widget.status) {
      case BadgeStatus.connected:
        return 'Live';
      case BadgeStatus.reconnecting:
        return 'Reconnecting';
      case BadgeStatus.offline:
        return 'Offline';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final opacity =
            widget.status == BadgeStatus.offline ? 1.0 : 0.5 + _pulseController.value * 0.5;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _dotColor.withAlpha((opacity * 0.15 * 255).toInt()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _dotColor.withAlpha((opacity * 255).toInt()),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _label,
                style: TextStyle(
                  color: _dotColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
