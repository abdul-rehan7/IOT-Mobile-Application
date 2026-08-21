# Component Library

Reusable widgets — build these once, reuse across all tabs/sensors. Never build a one-off "PressureCard" or "FlowCard" — build generic components driven by props/config.

## `SensorGaugeCard`
Circular animated gauge (the signature element). Used for `type: gauge` and `type: flow` sensors.
- Props: `value` (double), `unit` (String), `label` (String), `min`, `max`, `accentColor`, `isLoading`
- Animates value changes with a tween (300–500ms ease-out), never snaps
- Renders in `Coming Soon` mode with a shimmer overlay when `isComingSoon: true`

## `SensorTotalCard`
Large numeric readout for cumulative values (e.g. total volume). Used for `type: total`.
- Props: `value`, `unit`, `label`, `sparklineData` (List<double>, optional)
- Mono font for the number, ticks up smoothly rather than jump-updating
- Optional sparkline strip below the number

## `SensorNumericCard`
Simple label + value card for `type: numeric` (e.g. TDS ppm).
- Props: `value`, `unit`, `label`, `icon`, `isComingSoon`

## `ComingSoonOverlay`
Wraps any card above to produce the animated "coming soon" state.
- Shimmer/pulse animation over the card silhouette
- Optional slowly-drifting fake value (visual only, clearly not live data)
- Small non-intrusive banner: "Full monitoring launching soon"

## `ConnectionStatusBadge`
Small pill shown in the top bar.
- States: `connected` (green/teal dot, pulsing), `reconnecting` (amber, pulsing), `offline` (gray, static)
- Fade transition between states, never an abrupt blink

## `DeviceProfileForm`
Used on Connect Device screen and Settings → Add Device.
- Fields: name, host/IP, port, connection type dropdown
- Validates required fields before enabling submit
- Shows inline connecting/success/error state on the submit button itself (no separate modal)

## `DashboardShell`
Bottom-nav container wrapping the 3 tabs. Reads tab list from device's `sensor_config.json` grouping (so a 4th tab in future = config change, not shell rewrite).

## Widget-to-type mapping (keep this table updated as new types are added)
| Sensor `type` | Widget                |
|----------------|------------------------|
| `flow`         | `SensorGaugeCard`      |
| `gauge`        | `SensorGaugeCard`      |
| `total`        | `SensorTotalCard`      |
| `numeric`      | `SensorNumericCard`    |
