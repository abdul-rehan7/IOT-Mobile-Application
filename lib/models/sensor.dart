class Sensor {
  final String id;
  final String key;
  final String name;
  final String unit;
  final String type;
  final String tab;
  final String status;
  final String icon;

  /// Palette token name from AppColors ('primary', 'secondary', 'error').
  /// Assumption: optional config extension so accent color stays config-driven
  /// instead of being hardcoded per-tab in Dart.
  final String accent;

  /// Decimal places used when displaying the value (default 0).
  final int precision;

  /// Simulation hints for MockConnectionService: base/jitter/min/max.
  /// Assumption: optional config extension so demo realism is configurable
  /// per sensor without touching Dart code (mirrors 03_DATA_MODEL.md
  /// "adding a new sensor later = config change only").
  final Map<String, dynamic>? sim;

  const Sensor({
    required this.id,
    required this.key,
    required this.name,
    required this.unit,
    required this.type,
    required this.tab,
    required this.status,
    required this.icon,
    this.accent = 'primary',
    this.precision = 0,
    this.sim,
  });

  bool get isActive => status == 'active';
  bool get isComingSoon => status == 'coming_soon';

  double get simBase => _simDouble('base', 50.0);
  double get simJitter => _simDouble('jitter', 0.5);
  double get simMin => _simDouble('min', 0.0);
  double get simMax => _simDouble('max', 100.0);

  double _simDouble(String fieldKey, double fallback) {
    final value = sim?[fieldKey];
    if (value is num) return value.toDouble();
    return fallback;
  }

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      id: json['id'] as String,
      key: json['key'] as String,
      name: json['name'] as String,
      unit: json['unit'] as String,
      type: json['type'] as String,
      tab: json['tab'] as String,
      status: json['status'] as String,
      icon: json['icon'] as String? ?? 'sensors',
      accent: json['accent'] as String? ?? 'primary',
      precision: json['precision'] as int? ?? 0,
      sim: json['sim'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'name': name,
      'unit': unit,
      'type': type,
      'tab': tab,
      'status': status,
      'icon': icon,
      'accent': accent,
      'precision': precision,
      if (sim != null) 'sim': sim,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Sensor &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          key == other.key;

  @override
  int get hashCode => id.hashCode ^ key.hashCode;
}
