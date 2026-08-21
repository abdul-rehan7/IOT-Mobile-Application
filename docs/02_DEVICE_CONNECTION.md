# Device Connection Flow

## Goal
User can connect the app to **any** ESP device without app code changes, and can store/switch between multiple devices.

## Flow
1. **First launch** → "Connect Device" screen
   - Fields: Device Name (label), IP Address / Broker Host, Port, Connection Type (WiFi-MQTT / WiFi-HTTP / GSM-future)
   - Optional: "Scan Network" button (mDNS/local discovery — Phase 2)
   - Optional: QR code scan (ESP displays a QR with its connection info on boot — Phase 2)
2. On submit → app tests connection (ping / subscribe / handshake) → shows success/fail state
3. On success → profile saved locally → user lands on Dashboard
4. **Switch device** anytime via Settings → "My Devices" list → tap to switch, or add another

## Data saved per device profile
```json
{
  "id": "uuid",
  "name": "Tank Monitor - Site A",
  "connectionType": "mqtt",
  "host": "192.168.1.50",
  "port": 1883,
  "topicPrefix": "esp32/site-a/",
  "lastConnected": "timestamp"
}
```

## Multi-device support
- Profiles stored as a list locally (Hive/shared_preferences)
- Each profile is fully independent — sensor config can differ per device
- Active device stored separately; dashboard always reads from "active" profile

## Connection resilience (must-have for good UX)
- Show a persistent connection status badge (Connected / Reconnecting / Offline)
- Auto-retry on drop, with backoff
- Cache last known values so UI doesn't go blank on brief disconnects

## Future: GSM path
Same `ConnectionService` interface, new implementation (`GsmService`) that polls a cloud endpoint the ESP pushes to over GPRS. UI and models remain unchanged.
