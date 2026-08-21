# Coding Standards

## State management
- Pick **Riverpod** (recommended for testability with mock services). Use it consistently — no mixing with setState-heavy patterns for data flow.
- One provider per concern: `deviceProfileProvider`, `activeSensorStreamProvider`, `connectionStatusProvider`.

## Naming
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/functions: `camelCase`
- Sensor config keys: `snake_case` (must match ESP payload keys exactly)

## Folder discipline
- Match `01_ARCHITECTURE.md` exactly. If a new file doesn't obviously belong in an existing folder, stop and flag it rather than guessing.

## Services
- All connection logic implements the abstract `ConnectionService`:
  ```dart
  abstract class ConnectionService {
    Stream<SensorReading> get readings;
    Future<bool> connect(DeviceProfile profile);
    Future<void> disconnect();
    ConnectionStatus get status;
  }
  ```
- `MockConnectionService`, `MqttService`, `HttpService` all implement this. UI code depends only on the interface, never on a concrete implementation.

## Error handling
- Never let a connection drop crash the UI. Catch, set status to `reconnecting`/`offline`, keep last known values visible.
- User-facing error text follows plain, direct language: say what happened + what to do (e.g. "Can't reach device. Check it's powered on and try again.") — no raw exception strings shown to users.

## Testing (minimum bar for Phase 1)
- Unit test the `Sensor` and `DeviceProfile` model parsing (JSON in/out)
- Widget test: Dashboard renders correct tabs from a given `sensor_config.json`
- Widget test: Coming Soon overlay renders when `status: coming_soon`

## Comments
- Only comment *why*, not *what*. Code should be self-explanatory for *what*.
- Mark any spec-deviation or assumption with `// ASSUMPTION:` so it's greppable later.

## Git hygiene (if using version control)
- Small commits per task in `08_TASKS.md`
- Commit message references the task, e.g. `feat: add SensorGaugeCard (Task 6)`
