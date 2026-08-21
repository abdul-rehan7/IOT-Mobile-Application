import 'package:uuid/uuid.dart';

class DeviceProfile {
  final String id;
  final String name;
  final String connectionType;
  final String host;
  final int port;
  final String topicPrefix;
  final String? mqttUsername;
  final String? mqttPassword;
  final String? lastConnected;

  const DeviceProfile({
    required this.id,
    required this.name,
    required this.connectionType,
    required this.host,
    required this.port,
    required this.topicPrefix,
    this.mqttUsername,
    this.mqttPassword,
    this.lastConnected,
  });

  factory DeviceProfile.create({
    required String name,
    required String connectionType,
    required String host,
    required int port,
    String topicPrefix = '',
    String? mqttUsername,
    String? mqttPassword,
  }) {
    return DeviceProfile(
      id: const Uuid().v4(),
      name: name,
      connectionType: connectionType,
      host: host,
      port: port,
      topicPrefix: topicPrefix,
      mqttUsername: mqttUsername,
      mqttPassword: mqttPassword,
    );
  }

  factory DeviceProfile.fromJson(Map<String, dynamic> json) {
    return DeviceProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      connectionType: json['connectionType'] as String,
      host: json['host'] as String,
      port: json['port'] as int,
      topicPrefix: json['topicPrefix'] as String? ?? '',
      mqttUsername: json['mqttUsername'] as String?,
      mqttPassword: json['mqttPassword'] as String?,
      lastConnected: json['lastConnected'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'connectionType': connectionType,
      'host': host,
      'port': port,
      'topicPrefix': topicPrefix,
      'mqttUsername': mqttUsername,
      'mqttPassword': mqttPassword,
      'lastConnected': lastConnected,
    };
  }

  DeviceProfile copyWith({
    String? name,
    String? connectionType,
    String? host,
    int? port,
    String? topicPrefix,
    String? mqttUsername,
    String? mqttPassword,
    String? lastConnected,
  }) {
    return DeviceProfile(
      id: id,
      name: name ?? this.name,
      connectionType: connectionType ?? this.connectionType,
      host: host ?? this.host,
      port: port ?? this.port,
      topicPrefix: topicPrefix ?? this.topicPrefix,
      mqttUsername: mqttUsername ?? this.mqttUsername,
      mqttPassword: mqttPassword ?? this.mqttPassword,
      lastConnected: lastConnected ?? this.lastConnected,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceProfile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
