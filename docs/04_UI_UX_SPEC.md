# UI/UX Spec

## Design direction
Subject: industrial fluid monitoring (water/fuel flow + pressure) — not a generic "smart home" app. Lean into an **instrumentation panel** feel: precise, high-contrast, gauge-driven, like a modern flow-meter control panel — not a pastel consumer dashboard.

**Palette**
- Background: deep graphite `#12151B`
- Surface/card: `#1B1F27`
- Primary accent (flow/active data): cyan-teal `#2FD5C8`
- Secondary accent (alerts/high values): amber `#F2A93B`
- Muted text: `#8A93A3`
- Primary text: `#F5F7FA`

**Type**
- Display/numbers: a geometric mono or semi-mono face (e.g. "Space Mono" / "JetBrains Mono") for live readings — reinforces "instrument readout" feel
- UI/labels: a clean grotesk (e.g. "Inter" / "Manrope")

**Signature element**
A live-updating circular flow gauge with a subtle animated ring (like a speedometer needle sweep) on the Flow tab — this is the one "wow" element demoed to clients. Everything else stays calm and disciplined around it.

## Screens

### 1. Connect Device (onboarding)
- Minimal, dark, centered card: Device Name, Host/IP, Port, Connection Type dropdown
- "Connect" button with animated pulse while testing connection
- Success → slide transition into Dashboard

### 2. Dashboard Shell
- Bottom navigation, 3 tabs: **Flow**, **Pressure**, **TDS**
- Top bar: device name + connection status badge (green dot pulsing = live, gray = offline)

### 3. Flow Tab (fully functional)
- Hero: large circular animated gauge showing current flow rate (L/min), needle/arc animates smoothly on value change (not jumpy)
- Below: "Total Dispensed" counter — large mono digits, ticks up in real time
- Mini sparkline (last 60s) under the counter for trend context
- Card tap → expand to full-screen chart (stretch goal)

### 4. Pressure Tab — "Coming Soon"
- Same layout skeleton as Flow tab but with:
  - Shimmer/pulse animation over gauge silhouette (looks alive, not broken)
  - Fake but smooth-looking animated placeholder values drifting slightly (purely visual, clearly a demo state)
  - Banner: "Full pressure monitoring launching soon" (small, non-intrusive, bottom of card)

### 5. TDS Tab — "Coming Soon"
- Same treatment, different icon/accent (e.g. amber instead of teal) to visually distinguish

## Motion principles
- Value changes animate (tween), never snap
- Connection status transitions fade, not blink
- One orchestrated entrance animation on dashboard load (staggered card fade-up) — nothing more

## States to design for
- Loading (first connect)
- Live/connected
- Reconnecting (non-blocking banner, cached last values still shown)
- Disconnected/offline (clear but calm messaging, retry button)
- Coming soon (see above)

## Accessibility / quality floor
- Minimum contrast ratio AA on all text
- Touch targets ≥ 44px
- Works down to small phone screens (test at 360px width)
