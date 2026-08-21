# AGENTS.md — Instructions for opencode agent

You are building a Flutter mobile app (IoT sensor dashboard) using **spec-driven development**. All specs live in `/docs`. Do not invent architecture or UI decisions that contradict these specs — if something is ambiguous, make the smallest reasonable choice consistent with the spec's stated principles, and note the assumption in a code comment.

## Read order (read ALL before writing any code)
1. `docs/00_PROJECT_OVERVIEW.md` — scope, MVP boundaries, tech stack
2. `docs/01_ARCHITECTURE.md` — folder structure, layering rules
3. `docs/02_DEVICE_CONNECTION.md` — connect/onboarding flow
4. `docs/03_DATA_MODEL.md` — Sensor/Device schema, config format
5. `docs/04_UI_UX_SPEC.md` — visual design system, screens, motion
6. `docs/05_ROADMAP.md` — phased build order (build Phase 1 only unless told otherwise)
7. `docs/06_COMPONENT_LIBRARY.md` — reusable widget contracts
8. `docs/07_CODING_STANDARDS.md` — naming, state management, style rules
9. `docs/08_TASKS.md` — the actual task checklist, execute top to bottom

## Non-negotiable rules
- **No sensor-name hardcoding.** Never write `if (key == "pressure")` in UI/widget code. Route everything through `Sensor.type` and config (see `03_DATA_MODEL.md`).
- **Mock-first.** Phase 1 must run fully on a `MockConnectionService` — no real ESP/MQTT required to demo the app. Real `MqttService` comes in Phase 2, behind the same `ConnectionService` interface.
- **Never skip the onboarding gate incorrectly.** Only show Connect Device screen if no saved device profile exists locally. Returning users go straight to Dashboard using cached data (see `02_DEVICE_CONNECTION.md`).
- **Follow the UI spec exactly** for palette, type, and the signature gauge element — do not substitute default Flutter Material theming.
- Match file/folder structure in `01_ARCHITECTURE.md` exactly. Do not flatten or reorganize without updating the doc first.

## Definition of done (per task in 08_TASKS.md)
- Code compiles and runs (`flutter run`)
- Matches the relevant spec section (cite which doc/section in your summary)
- No hardcoded sensor logic
- Widget/screen respects dark theme tokens from `04_UI_UX_SPEC.md`

## Workflow
1. Pick the next unchecked task in `08_TASKS.md`
2. Implement it against the relevant spec doc(s)
3. Mark it done in `08_TASKS.md`, note any assumptions made
4. Move to next task — do not jump ahead to Phase 2/3 tasks while Phase 1 is incomplete
5. After finishing a complete task, rebuild the APK (`flutter build apk --debug`) and overwrite `C:\Users\WorkSpace\Desktop\iot_monitor_debug.apk` so the user can test on a real device
