import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/device_profile.dart';
import '../models/sensor.dart';
import '../services/connection/connection_service.dart';
import '../services/connection/mock_connection_service.dart';
import '../services/connection/mqtt_service.dart';
import '../services/storage_service.dart';

// Storage
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService.instance;
});

// Connection service — dynamically selects Mock or Mqtt based on active profile
final connectionServiceProvider =
    StateNotifierProvider<ConnectionServiceNotifier, ConnectionService>((ref) {
  return ConnectionServiceNotifier(ref.watch(storageServiceProvider));
});

class ConnectionServiceNotifier extends StateNotifier<ConnectionService>
    implements ConnectionService {
  final StorageService _storage;

  /// Profile of the last connect attempt — used by [ensureConnected] to
  /// re-establish the connection (e.g. app restart straight into Dashboard).
  DeviceProfile? _activeProfile;
  bool _connecting = false;

  ConnectionServiceNotifier(this._storage) : super(MockConnectionService());

  @override
  Stream<SensorReading> get readings => state.readings;

  @override
  ConnectionStatus get status => state.status;

  @override
  List<Sensor> get sensors => state.sensors;

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  @override
  Future<bool> connect(DeviceProfile profile) async {
    _activeProfile = profile;
    _connecting = true;
    state.dispose();

    ConnectionService service;
    switch (profile.connectionType) {
      case 'mqtt':
        service = MqttService();
        break;
      case 'mock':
        service = MockConnectionService();
        break;
      default:
        service = MockConnectionService();
    }

    final success = await service.connect(profile);
    if (success) {
      state = service;
    } else {
      service.dispose();
    }
    _connecting = false;

    return success;
  }

  /// Reconnects using the last profile if the current service is not live.
  /// Covers the returning-user path: app restart lands directly on the
  /// Dashboard with a saved profile but no connection attempt yet.
  Future<void> ensureConnected() async {
    if (_connecting) return;
    if (state.status == ConnectionStatus.connected) return;
    final profile = _activeProfile ?? _storage.getActiveProfile();
    if (profile == null) return;
    await connect(profile);
  }

  @override
  Future<void> disconnect() async {
    await state.disconnect();
    state.dispose();
    state = MockConnectionService();
    _activeProfile = null;
  }

  void resume() {
    if (state is MockConnectionService) {
      (state as MockConnectionService).resume();
    } else if (state is MqttService) {
      (state as MqttService).reconnect();
    }
  }
}

// Active device profile
final activeDeviceProfileProvider =
    StateNotifierProvider<ActiveDeviceProfileNotifier, DeviceProfile?>(
  (ref) {
    final storage = ref.watch(storageServiceProvider);
    return ActiveDeviceProfileNotifier(storage);
  },
);

class ActiveDeviceProfileNotifier extends StateNotifier<DeviceProfile?> {
  final StorageService _storage;

  ActiveDeviceProfileNotifier(this._storage) : super(null) {
    _load();
  }

  void _load() {
    state = _storage.getActiveProfile();
  }

  Future<void> setProfile(DeviceProfile profile) async {
    await _storage.saveProfile(profile);
    await _storage.setActiveProfile(profile.id);
    state = profile;
  }

  Future<void> clearProfile() async {
    state = null;
  }

  void refresh() {
    state = _storage.getActiveProfile();
  }
}

// Whether any profile exists
final hasDeviceProfileProvider = Provider<bool>((ref) {
  final profile = ref.watch(activeDeviceProfileProvider);
  return profile != null;
});

// All saved profiles
final allProfilesProvider = Provider<List<DeviceProfile>>((ref) {
  ref.watch(activeDeviceProfileProvider);
  return ref.watch(storageServiceProvider).getAllProfiles();
});

// Connection status
final connectionStatusProvider =
    StateNotifierProvider<ConnectionStatusNotifier, ConnectionStatus>(
  (ref) {
    return ConnectionStatusNotifier();
  },
);

class ConnectionStatusNotifier extends StateNotifier<ConnectionStatus> {
  ConnectionStatusNotifier() : super(ConnectionStatus.offline);

  void update(ConnectionStatus status) {
    state = status;
  }
}

// Sensor readings stream
final sensorReadingsProvider =
    StreamNotifierProvider<SensorReadingsNotifier, Map<String, double>>(
  SensorReadingsNotifier.new,
);

class SensorReadingsNotifier extends StreamNotifier<Map<String, double>> {
  final _latestValues = <String, double>{};

  @override
  Stream<Map<String, double>> build() async* {
    final connection = ref.watch(connectionServiceProvider);
    final statusNotifier = ref.read(connectionStatusProvider.notifier);

    await for (final reading in connection.readings) {
      _latestValues[reading.sensorKey] = reading.value;
      statusNotifier.update(connection.status);
      yield Map.from(_latestValues);
    }
  }
}

// Sensors for current device
final deviceSensorsProvider = Provider<List<Sensor>>((ref) {
  return ref.watch(connectionServiceProvider).sensors;
});

// Sensors grouped by tab
final sensorsByTabProvider = Provider<Map<String, List<Sensor>>>((ref) {
  final sensors = ref.watch(deviceSensorsProvider);
  final grouped = <String, List<Sensor>>{};
  for (final sensor in sensors) {
    grouped.putIfAbsent(sensor.tab, () => []).add(sensor);
  }
  return grouped;
});
