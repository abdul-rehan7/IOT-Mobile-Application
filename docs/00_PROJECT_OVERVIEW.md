# Project Overview — IoT Sensor Monitoring App

## What this is
A mobile app (Flutter, builds to APK) that connects to an ESP32-S3 device over WiFi (MQTT/HTTP), reads live sensor data, and displays it in a clean, real-time dashboard. Built to be **device-agnostic** — new sensors or ESP devices should be addable via config, not code rewrites.

## Core principle
> The app is a generic "sensor viewer" — it doesn't know what a sensor *is*, only that it has an id, name, unit, type, and a value stream. All sensor-specific logic lives in config, not in widgets.

## Read order for this doc set
1. `00_PROJECT_OVERVIEW.md` — this file
2. `01_ARCHITECTURE.md` — folder structure, layers, data flow
3. `02_DEVICE_CONNECTION.md` — how the app connects/discovers ESP devices
4. `03_DATA_MODEL.md` — Sensor/Device schema, config format
5. `04_UI_UX_SPEC.md` — screens, navigation, visual language
6. `05_ROADMAP.md` — phased build plan / feature status

## MVP Scope (Phase 1)
- Device connect screen (enter IP/broker manually; save profile)
- Dashboard with bottom nav: **Flow**, **Pressure (Coming Soon)**, **TDS (Coming Soon)**
- Flow tab: live flow rate + running total volume
- Real-time UI updates (no manual refresh)
- Local storage of device profiles (multi-ESP support)

## Explicitly out of scope for MVP
- User accounts / cloud login
- Historical data / long-term charts (stub only)
- GSM/cellular path (WiFi-first; GSM added later behind same interface)
- Firmware code (separate repo/spec)

## Tech stack
- **App:** Flutter (Dart) → APK
- **Transport:** MQTT (primary), HTTP REST (fallback), abstracted behind one interface
- **Local storage:** shared_preferences / Hive (device profiles, settings)
- **Charts:** fl_chart or syncfusion_flutter_charts
- **State management:** Riverpod or Provider (pick one, stay consistent)
