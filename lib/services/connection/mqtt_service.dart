import 'dart:async';
import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../sensor_config_service.dart';
import 'connection_service.dart';
import '../../models/device_profile.dart';
import '../../models/sensor.dart';

class MqttService implements ConnectionService {
  MqttServerClient? _client;
  ConnectionStatus _status = ConnectionStatus.offline;
  final _controller = StreamController<SensorReading>.broadcast();
  DeviceProfile? _profile;
  Timer? _reconnectTimer;
  StreamSubscription? _updatesSubscription;
  int _reconnectAttempt = 0;
  static const int _maxReconnectAttempts = 10;
  bool _intentionalDisconnect = false;

  @override
  ConnectionStatus get status => _status;

  @override
  Stream<SensorReading> get readings => _controller.stream;

  @override
  List<Sensor> get sensors => SensorConfigService.instance.sensors;

  @override
  Future<bool> connect(DeviceProfile profile) async {
    _intentionalDisconnect = false;
    _profile = profile;
    _status = ConnectionStatus.reconnecting;

    try {
      _client = MqttServerClient.withPort(
        profile.host,
        'flutter_${profile.id}',
        profile.port,
      );

      _client!.logging(on: false);
      _client!.keepAlivePeriod = 30;
      _client!.autoReconnect = false;
      _client!.onConnected = _onConnected;
      _client!.onDisconnected = _onDisconnected;
      _client!.onAutoReconnect = _onAutoReconnect;
      _client!.onAutoReconnected = _onAutoReconnected;

      final connMessage = MqttConnectMessage()
          .withClientIdentifier('flutter_${profile.id}')
          .startClean()
          .withWillQos(MqttQos.atMostOnce);

      if (profile.mqttUsername != null && profile.mqttUsername!.isNotEmpty) {
        connMessage.authenticateAs(
          profile.mqttUsername,
          profile.mqttPassword ?? '',
        );
      }

      _client!.connectionMessage = connMessage;

      final status = await _client!.connect().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          _client?.disconnect();
          return null;
        },
      );

      if (status == null ||
          _client!.connectionStatus?.state != MqttConnectionState.connected) {
        _status = ConnectionStatus.offline;
        _client?.disconnect();
        return false;
      }

      _status = ConnectionStatus.connected;
      _reconnectAttempt = 0;

      _subscribeAndListen(profile);

      return true;
    } catch (e) {
      _status = ConnectionStatus.offline;
      _client?.disconnect();
      return false;
    }
  }

  void _subscribeAndListen(DeviceProfile profile) {
    final topic = '${profile.topicPrefix}data';
    _client!.subscribe(topic, MqttQos.atMostOnce);

    _updatesSubscription?.cancel();
    _updatesSubscription = _client!.updates!.listen(
      (List<MqttReceivedMessage<MqttMessage>> messages) {
        for (final message in messages) {
          final pubMessage = message.payload as MqttPublishMessage;
          _handleMessage(pubMessage);
        }
      },
      onError: (_) {
        if (!_intentionalDisconnect) {
          _handleDisconnect();
        }
      },
    );
  }

  void _handleMessage(MqttPublishMessage message) {
    try {
      final payload = MqttPublishPayload.bytesToStringAsString(
        message.payload.message,
      );
      final json = jsonDecode(payload) as Map<String, dynamic>;

      final readings = json['readings'] as Map<String, dynamic>?;
      if (readings == null) return;

      final ts = json['timestamp'] as int?;
      final timestamp = ts != null
          ? DateTime.fromMillisecondsSinceEpoch(ts * 1000)
          : DateTime.now();

      for (final entry in readings.entries) {
        final value = entry.value;
        if (value is num) {
          _controller.add(SensorReading(
            sensorKey: entry.key,
            value: value.toDouble(),
            timestamp: timestamp,
          ));
        }
      }
    } catch (_) {
      // Ignore malformed messages
    }
  }

  void _onConnected() {
    _status = ConnectionStatus.connected;
    _reconnectAttempt = 0;
  }

  void _onDisconnected() {
    if (!_intentionalDisconnect) {
      _handleDisconnect();
    }
  }

  void _onAutoReconnect() {
    _status = ConnectionStatus.reconnecting;
  }

  void _onAutoReconnected() {
    _status = ConnectionStatus.connected;
    _reconnectAttempt = 0;
    if (_profile != null) {
      _subscribeAndListen(_profile!);
    }
  }

  void _handleDisconnect() {
    _status = ConnectionStatus.reconnecting;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();

    if (_intentionalDisconnect) return;
    if (_reconnectAttempt >= _maxReconnectAttempts) {
      _status = ConnectionStatus.offline;
      return;
    }

    final delaySeconds = [
      1, 2, 4, 8, 15, 30, 30, 30, 60, 60,
    ][_reconnectAttempt.clamp(0, 9)];
    _reconnectAttempt++;

    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () async {
      if (_intentionalDisconnect || _profile == null) return;

      try {
        _client?.disconnect();
      } catch (_) {}

      final success = await connect(_profile!);
      if (!success && !_intentionalDisconnect) {
        _scheduleReconnect();
      }
    });
  }

  @override
  Future<void> disconnect() async {
    _intentionalDisconnect = true;
    _reconnectTimer?.cancel();
    _updatesSubscription?.cancel();
    _client?.disconnect();
    _status = ConnectionStatus.offline;
    _profile = null;
    _reconnectAttempt = 0;
  }

  Future<void> reconnect() async {
    if (_profile == null) return;
    _intentionalDisconnect = false;
    _reconnectAttempt = 0;

    try {
      _client?.disconnect();
    } catch (_) {}

    final success = await connect(_profile!);
    if (!success) {
      _scheduleReconnect();
    }
  }

  @override
  void dispose() {
    _intentionalDisconnect = true;
    _reconnectTimer?.cancel();
    _updatesSubscription?.cancel();
    _client?.disconnect();
    _controller.close();
  }
}
