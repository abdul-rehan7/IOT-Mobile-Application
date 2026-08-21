import 'dart:async';
import 'dart:math';

import '../sensor_config_service.dart';
import 'connection_service.dart';
import '../../models/device_profile.dart';
import '../../models/sensor.dart';

/// Simulates a live device entirely from sensor_config.json: every sensor with
/// status "active" gets a realistic value stream, behavior driven by its
/// `type` and optional `sim` hints. No sensor keys are hardcoded here.
class MockConnectionService implements ConnectionService {
  final _controller = StreamController<SensorReading>.broadcast();
  Timer? _timer;
  ConnectionStatus _status = ConnectionStatus.offline;
  final _random = Random();

  /// Current simulated value per active sensor key.
  final _values = <String, double>{};
  DateTime? _sessionStart;
  Duration _elapsed = Duration.zero;

  @override
  ConnectionStatus get status => _status;

  @override
  Stream<SensorReading> get readings => _controller.stream;

  @override
  List<Sensor> get sensors => SensorConfigService.instance.sensors;

  Duration get elapsed => _elapsed;
  List<double> get flowHistory => List.unmodifiable(_flowHistory);
  final List<double> _flowHistory = [];
  static const int _maxHistory = 60;

  String? get _flowKey => _activeOfType('flow')?.key;

  Sensor? _activeOfType(String type) {
    for (final s in sensors) {
      if (s.isActive && s.type == type) return s;
    }
    return null;
  }

  @override
  Future<bool> connect(DeviceProfile profile) async {
    _status = ConnectionStatus.reconnecting;
    await Future.delayed(const Duration(milliseconds: 800));

    _status = ConnectionStatus.connected;
    _sessionStart = DateTime.now();
    _elapsed = Duration.zero;
    _flowHistory.clear();
    _seedValues();
    _startEmitting();
    return true;
  }

  /// Seeds every active sensor at its configured base value.
  void _seedValues() {
    _values.clear();
    for (final sensor in sensors) {
      if (!sensor.isActive) continue;
      // Totals start at zero; everything else starts at its base.
      _values[sensor.key] =
          sensor.type == 'total' ? 0.0 : sensor.simBase;
    }
  }

  @override
  Future<void> disconnect() async {
    _timer?.cancel();
    _status = ConnectionStatus.offline;
    _sessionStart = null;
    _elapsed = Duration.zero;
    _flowHistory.clear();
  }

  void resume() {
    _status = ConnectionStatus.connected;
    _sessionStart ??= DateTime.now();
    _startEmitting();
  }

  void _startEmitting() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      if (_status != ConnectionStatus.connected) return;

      if (_sessionStart != null) {
        _elapsed = DateTime.now().difference(_sessionStart!);
      }

      final now = DateTime.now();

      for (final sensor in sensors) {
        if (!sensor.isActive) continue;
        final value = _nextValueFor(sensor);
        _values[sensor.key] = value;
        if (sensor.type == 'flow') {
          _flowHistory.add(value);
          if (_flowHistory.length > _maxHistory) {
            _flowHistory.removeAt(0);
          }
        }
        _controller.add(SensorReading(
          sensorKey: sensor.key,
          value: double.parse(value.toStringAsFixed(sensor.precision)),
          timestamp: now,
        ));
      }
    });
  }

  /// Advances the simulation one tick for a sensor, per its type.
  double _nextValueFor(Sensor sensor) {
    switch (sensor.type) {
      case 'flow':
        return _randomWalk(sensor);
      case 'total':
        // Total accumulates from the flow rate over elapsed time.
        final flowKey = _flowKey;
        final flowRate = flowKey != null ? (_values[flowKey] ?? 0.0) : 0.0;
        final elapsedMinutes = _elapsed.inSeconds / 60.0;
        return double.parse(
          (flowRate * elapsedMinutes).toStringAsFixed(sensor.precision),
        );
      case 'gauge':
      case 'numeric':
      default:
        return _randomWalk(sensor);
    }
  }

  /// Random walk around [Sensor.simBase], clamped to [simMin, simMax].
  double _randomWalk(Sensor sensor) {
    final current = _values[sensor.key] ?? sensor.simBase;
    final delta = (_random.nextDouble() - 0.5) * 2 * sensor.simJitter;
    var next = (current + delta).clamp(sensor.simMin, sensor.simMax);
    return double.parse(next.toStringAsFixed(sensor.precision));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.close();
  }

  void simulateDisconnect() {
    _status = ConnectionStatus.reconnecting;
    _timer?.cancel();
    Future.delayed(const Duration(seconds: 3), () {
      _status = ConnectionStatus.connected;
      _startEmitting();
    });
  }
}
