import 'package:flutter/material.dart';

/// Maps config icon keys (Sensor.icon) to Material icons.
/// Single shared mapping so every widget resolves icons identically.
class AppIcons {
  AppIcons._();

  static IconData fromKey(String key) {
    switch (key) {
      case 'water_drop':
        return Icons.water_drop;
      case 'speed':
        return Icons.speed;
      case 'science':
        return Icons.science;
      case 'straighten':
        return Icons.straighten;
      case 'thermostat':
        return Icons.thermostat;
      case 'show_chart':
        return Icons.show_chart;
      default:
        return Icons.sensors;
    }
  }
}
