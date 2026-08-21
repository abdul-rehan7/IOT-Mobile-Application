# Tasks — Phase 1 (MVP, mock data, no hardware)

Execute top to bottom. Check off as completed. Do not skip ahead to Phase 2/3 items listed in `05_ROADMAP.md`.

## Setup
- [x] 1. Init Flutter project, add dependencies: `riverpod`, `hive`/`shared_preferences`, `fl_chart`, `mqtt_client` (added but unused until Phase 2)
- [x] 2. Set up folder structure exactly per `01_ARCHITECTURE.md`
- [x] 3. Build theme system in `core/theme/` per palette + type rules in `04_UI_UX_SPEC.md`

## Models & config
- [x] 4. Implement `Sensor` model (`models/sensor.dart`) per `03_DATA_MODEL.md`
- [x] 5. Implement `DeviceProfile` model (`models/device_profile.dart`) per `02_DEVICE_CONNECTION.md`
- [x] 6. Create sample `sensor_config.json` with flow (active) + pressure/tds (coming_soon) per `03_DATA_MODEL.md`

## Services
- [x] 7. Define abstract `ConnectionService` per `07_CODING_STANDARDS.md`
- [x] 8. Implement `MockConnectionService` — emits realistic simulated flow/total values on a timer (e.g. every 1–2s), with small random jitter for a "live" feel
- [x] 9. Implement `StorageService` — save/load/list `DeviceProfile`s locally

## Onboarding
- [x] 10. Build `ConnectDeviceScreen` using `DeviceProfileForm` component
- [x] 11. Wire up: no saved profile → show this screen; profile exists → skip straight to Dashboard
- [x] 12. Add "Use Demo Mode" option that connects via `MockConnectionService` without requiring real input

## Dashboard
- [x] 13. Build `DashboardShell` with bottom nav (Flow / Pressure / TDS), tabs driven by config
- [x] 14. Build `SensorGaugeCard`, `SensorTotalCard`, `SensorNumericCard`, `ComingSoonOverlay` per `06_COMPONENT_LIBRARY.md`
- [x] 15. Build Flow tab: gauge + total counter + sparkline, fed by `MockConnectionService` stream
- [x] 16. Build Pressure tab in Coming Soon state (teal accent, per `04_UI_UX_SPEC.md`)
- [x] 17. Build TDS tab in Coming Soon state
- [x] 18. Add `ConnectionStatusBadge` to top bar, wired to mock connection status (including simulated reconnect for testing that state)

## Settings
- [x] 19. Build minimal Settings screen: list saved devices, switch active device, add new device

## Polish / QA
- [x] 20. Test at 360px width (small phone) — verify no overflow
- [x] 21. Verify all animated value changes tween, not snap
- [x] 22. Verify offline/reconnecting states display correctly with cached values
- [x] 23. Build debug APK, sanity check on a real device/emulator

## Exit criteria for Phase 1
App runs standalone with zero real hardware, demonstrates the full intended UX (connect flow, live Flow tab, Coming Soon tabs, device switching), and is ready to show a client.

## Phase 1 hardening pass (post-review fixes)
- [x] Config-driven architecture: `sensor_config.json` is now actually loaded (`SensorConfigService`) — previously both services hardcoded sensor lists. Tabs render generically from config via `SensorTabView`; `FlowTab`/`PressureTab`/`TDSTab`/`TemperatureTab` deleted (per `06_COMPONENT_LIBRARY.md` DashboardShell contract).
- [x] Fixed failing widget test: Hive/storage/config init now happens in-test via `tester.runAsync` (real file I/O needs it inside fake-async); replaced `pumpAndSettle` with fixed pumps (indeterminate progress indicators never settle).
- [x] Temperature tab made real & active for testing (config `status: active`, mock simulates ~24.5 °C ± jitter).
- [x] Removed dead code (`overview_section.dart`, unused `SensorTotalCard` sparkline placeholder; `SensorTotalCard` now implements the highlighted total panel with tween animation).

### Assumptions noted
- Config schema extended with optional per-sensor fields: `accent` (palette token), `precision` (decimals), `sim` (mock simulation hints base/jitter/min/max). Additive only; keeps "new sensor = config change only" true for demo realism too.
- Tab labels derive from tab id (`flow` → Flow); tab icon from first sensor in the tab.
- Temperature activated in mock mode purely for testing convenience; flip `status` back to `coming_soon` in config to restore the shimmer state.
