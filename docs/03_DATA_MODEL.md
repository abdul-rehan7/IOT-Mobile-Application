# Data Model & Config

## Sensor model
```json
{
  "id": "flow_01",
  "key": "flow_rate",
  "name": "Flow Rate",
  "unit": "L/min",
  "type": "flow",
  "tab": "flow",
  "status": "active",
  "icon": "water_drop"
}
```

| field   | meaning                                            |
|---------|-----------------------------------------------------|
| id      | unique sensor instance id                           |
| key     | matches the key in incoming MQTT/HTTP payload        |
| name    | display label                                        |
| unit    | shown next to value                                  |
| type    | drives which widget renders it: `numeric`, `gauge`, `total`, `flow` |
| tab     | which dashboard tab it belongs to                    |
| status  | `active` \| `coming_soon`                            |
| icon    | icon key for UI                                      |

## Incoming payload (from ESP, example MQTT message)
```json
{
  "device_id": "esp32-s3-01",
  "timestamp": 1730000000,
  "readings": {
    "flow_rate": 12.4,
    "total_volume": 458.2
  }
}
```
App matches `readings.<key>` to `Sensor.key` — no hardcoded parsing per sensor.

## sensor_config.json (per device, defines what tabs/sensors exist)
```json
{
  "device_id": "esp32-s3-01",
  "sensors": [
    { "id": "flow_01", "key": "flow_rate", "name": "Flow Rate", "unit": "L/min", "type": "flow", "tab": "flow", "status": "active" },
    { "id": "flow_total", "key": "total_volume", "name": "Total Volume", "unit": "L", "type": "total", "tab": "flow", "status": "active" },
    { "id": "pressure_01", "key": "pressure", "name": "Tank Level (Pressure)", "unit": "kPa", "type": "gauge", "tab": "pressure", "status": "coming_soon" },
    { "id": "tds_01", "key": "tds", "name": "TDS", "unit": "ppm", "type": "numeric", "tab": "tds", "status": "coming_soon" }
  ]
}
```

## Adding a new sensor later (e.g. temperature)
1. ESP firmware adds `"temperature": 24.5` to its payload
2. Add one entry to `sensor_config.json`
3. Done — no Dart code changes required, as long as `type` maps to an existing widget
