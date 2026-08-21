import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'screens/onboarding/connect_device_screen.dart';
import 'screens/dashboard/dashboard_shell.dart';
import 'services/storage_service.dart';
import 'providers/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await StorageService.instance.init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF12151B),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: IoTMonitorApp(),
    ),
  );
}

class IoTMonitorApp extends ConsumerWidget {
  const IoTMonitorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasProfile = ref.watch(hasDeviceProfileProvider);

    return MaterialApp(
      title: 'IoT Monitor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: hasProfile ? const DashboardShell() : const ConnectDeviceScreen(),
    );
  }
}
