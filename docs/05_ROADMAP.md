# Roadmap

## Phase 1 — MVP (build now, no hardware needed)
- [ ] Project scaffold + theme system
- [ ] Device connect screen (manual entry, save profile locally)
- [ ] Mock data service (simulates MQTT payloads on a timer)
- [ ] Dashboard shell + bottom nav
- [ ] Flow tab: animated gauge + running total + sparkline
- [ ] Pressure tab: "Coming Soon" shimmer UI
- [ ] TDS tab: "Coming Soon" shimmer UI
- [ ] Connection status badge + reconnect logic (simulated)

## Phase 2 — Real hardware integration
- [ ] Replace mock service with real MqttService (test against ESP32-S3)
- [ ] Confirm payload schema matches `03_DATA_MODEL.md`
- [ ] Handle real disconnect/reconnect edge cases
- [ ] Multi-device switching (test with 2+ ESP boards)

## Phase 3 — Feature expansion
- [ ] Pressure tab goes live (dip tube sensor)
- [ ] TDS tab goes live
- [ ] Historical charts / data export
- [ ] mDNS auto-discovery / QR onboarding
- [ ] GSM connection path (GsmService)

## Phase 4 — Polish / client delivery
- [ ] App icon, splash screen, branding pass
- [ ] Build signed release APK
- [ ] Client demo + feedback pass
