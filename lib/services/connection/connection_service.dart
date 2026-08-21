import '../../models/device_profile.dart';
import '../../models/sensor.dart';

enum ConnectionStatus { connected, reconnecting, offline }

class SensorReading {
  final String sensorKey;
  final double value;
  final DateTime timestamp;

  const SensorReading({
    required this.sensorKey,
    required this.value,
    required this.timestamp,
  });
}

abstract class ConnectionService {
  Stream<SensorReading> get readings;
  Future<bool> connect(DeviceProfile profile);
  Future<void> disconnect();
  ConnectionStatus get status;
  List<Sensor> get sensors;
  void dispose();
}
