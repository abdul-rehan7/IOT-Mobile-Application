import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/sensor.dart';

/// Loads the per-device sensor configuration from assets/config/sensor_config.json
/// (per 03_DATA_MODEL.md). Single source of truth for what tabs/sensors exist —
/// no sensor definitions live in Dart code.
class SensorConfigService {
  SensorConfigService._();
  static final SensorConfigService instance = SensorConfigService._();

  static const String _configAsset = 'assets/config/sensor_config.json';

  List<Sensor> _sensors = const [];
  String deviceId = '';

  List<Sensor> get sensors => List.unmodifiable(_sensors);

  Future<void> load() async {
    final raw = await rootBundle.loadString(_configAsset);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    deviceId = json['device_id'] as String? ?? '';
    _sensors = (json['sensors'] as List? ?? [])
        .map((e) => Sensor.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
