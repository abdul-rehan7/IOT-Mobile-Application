import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

import 'package:iot_monitor/main.dart';
import 'package:iot_monitor/models/device_profile.dart';
import 'package:iot_monitor/providers/providers.dart';
import 'package:iot_monitor/screens/dashboard/dashboard_shell.dart';
import 'package:iot_monitor/services/sensor_config_service.dart';
import 'package:iot_monitor/services/storage_service.dart';

void main() {
  Future<void> initServices(WidgetTester tester) async {
    // Init storage + sensor config the same way main() does, but with a
    // throwaway Hive directory (path_provider is unavailable in tests).
    // runAsync is required: real file I/O never completes inside the
    // test binding's fake-async zone.
    await tester.runAsync(() async {
      final tempDir =
          await Directory.systemTemp.createTemp('iot_monitor_test');
      // Hive caches open boxes globally: close any box left open by a
      // previous test so each test starts with isolated storage.
      if (Hive.isBoxOpen(StorageService.boxName)) {
        await Hive.box(StorageService.boxName).close();
      }
      Hive.init(tempDir.path);
      await StorageService.instance.init();
      await SensorConfigService.instance.load();
    });
    GoogleFonts.config.allowRuntimeFetching = false;
  }

  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await initServices(tester);

    await tester.pumpWidget(
      const ProviderScope(child: IoTMonitorApp()),
    );
    // Fixed pumps instead of pumpAndSettle: the connect screen contains
    // indeterminate progress indicators that never stop animating.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
    expect(find.byType(IoTMonitorApp), findsOneWidget);
  });

  testWidgets('Returning user with saved profile lands on live dashboard',
      (WidgetTester tester) async {
    await initServices(tester);

    // Simulate a previous session: a demo profile was saved locally.
    await tester.runAsync(() async {
      final profile = DeviceProfile.create(
        name: 'Demo Device',
        connectionType: 'mock',
        host: 'localhost',
        port: 0,
      );
      await StorageService.instance.saveProfile(profile);
      await StorageService.instance.setActiveProfile(profile.id);
    });

    // App restart: must skip the connect screen, auto-reconnect the mock
    // service on dashboard entry, and show live values.
    await tester.pumpWidget(
      const ProviderScope(child: IoTMonitorApp()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(seconds: 2));

    expect(tester.takeException(), isNull);
    expect(find.text('Use Demo Mode'), findsNothing);
    expect(find.byType(DashboardShell), findsOneWidget);

    // Live mock readings on the default (Flow) tab.
    expect(find.textContaining('L/min'), findsWidgets);

    // Switch to the Temperature tab and verify its live value too.
    await tester.tap(find.text('Temperature'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.textContaining('\u00B0C'), findsWidgets);
  });

  testWidgets('Demo mode connect starts streaming sensor readings',
      (WidgetTester tester) async {
    await initServices(tester);

    await tester.pumpWidget(
      const ProviderScope(child: IoTMonitorApp()),
    );
    await tester.pump();

    // The demo button sits below the fold on the default test surface.
    await tester.ensureVisible(find.text('Use Demo Mode'));
    await tester.pump();
    await tester.tap(find.text('Use Demo Mode'));
    // Connect has an 800ms simulated handshake; then the timer ticks at 1.5s.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(seconds: 2));

    expect(tester.takeException(), isNull);

    // Assert on the readings stream: navigation to the dashboard awaits a
    // Hive disk write that cannot complete under the test binding's
    // fake-async zone, so verify the data layer directly instead.
    final container = ProviderScope.containerOf(
      tester.element(find.byType(IoTMonitorApp)),
    );
    // Activate the stream first — it's a broadcast stream, so ticks emitted
    // before any subscriber are dropped.
    container.read(sensorReadingsProvider);
    await tester.pump(const Duration(seconds: 2));

    final readings = container.read(sensorReadingsProvider);
    expect(readings.value, isNotNull);
    expect(readings.value!.containsKey('flow_rate'), isTrue);
    expect(readings.value!.containsKey('temperature'), isTrue);
    expect(readings.value!['flow_rate'], greaterThan(0));
  });
}
