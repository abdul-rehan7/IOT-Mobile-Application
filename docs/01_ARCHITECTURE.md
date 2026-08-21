# Architecture

## Layered structure
```
lib/
├── main.dart
├── core/
│   ├── constants/          # colors, spacing, text styles, durations
│   ├── theme/               # ThemeData, gradients, animations config
│   └── utils/                # formatters, validators
├── models/
│   ├── device_profile.dart   # {id, name, connectionType, ip, port, mqttTopic}
│   └── sensor.dart           # {id, key, name, unit, type, icon, status}
├── services/
│   ├── connection/
│   │   ├── connection_service.dart   # abstract interface
│   │   ├── mqtt_service.dart         # implements interface
│   │   └── http_service.dart         # implements interface (fallback)
│   ├── storage_service.dart          # save/load device profiles locally
│   └── discovery_service.dart        # mDNS / network scan (optional Phase 2)
├── providers/                # Riverpod/Provider state (device state, sensor streams)
├── screens/
│   ├── onboarding/
│   │   └── connect_device_screen.dart
│   ├── dashboard/
│   │   ├── dashboard_shell.dart      # bottom nav container
│   │   ├── flow_tab.dart
│   │   ├── pressure_tab.dart         # "Coming Soon"
│   │   └── tds_tab.dart              # "Coming Soon"
│   └── settings/
│       └── device_settings_screen.dart
├── widgets/
│   ├── sensor_card.dart              # reusable numeric/gauge card
│   ├── live_chart.dart               # reusable real-time line chart
│   ├── coming_soon_shimmer.dart      # animated placeholder widget
│   └── connection_status_badge.dart
└── config/
    └── sensor_config.json            # defines which sensors exist per device
```

## Data flow
```
ESP32-S3  --(MQTT/HTTP)-->  ConnectionService  -->  Provider (stream)  -->  Screens/Widgets
```

- **ConnectionService** is an interface. `MqttService` and `HttpService` both implement it, so swapping transport (or adding GSM later) doesn't touch UI code.
- Sensor widgets never hardcode "pressure" or "flow" — they take a `Sensor` object and render generically based on its `type` (numeric / gauge / total).
- Adding a new sensor = add an entry to `sensor_config.json` + assign it to a tab. No new widget code needed unless it's a genuinely new visualization type.

## Key rule for extensibility
Any time you're tempted to write `if (sensorName == "pressure")` — stop. Route behavior through the sensor's `type` field or config, not its name.
