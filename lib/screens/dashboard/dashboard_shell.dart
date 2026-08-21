import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_icons.dart';
import '../../providers/providers.dart';
import '../../services/connection/connection_service.dart';
import '../../widgets/connection_status_badge.dart';
import '../../widgets/sensor_tab_view.dart';
import '../onboarding/connect_device_screen.dart';

/// Bottom-nav container. Per 06_COMPONENT_LIBRARY.md the tab list is read
/// from the device's sensor_config.json grouping — a new tab is a config
/// change, not a shell rewrite.
class DashboardShell extends ConsumerStatefulWidget {
  const DashboardShell({super.key});

  @override
  ConsumerState<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends ConsumerState<DashboardShell>
    with WidgetsBindingObserver {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Returning-user path (02_DEVICE_CONNECTION.md): app can start straight
    // on the Dashboard with a saved profile — re-establish the connection.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(connectionServiceProvider.notifier).ensureConnected();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _reloadConnection();
    }
  }

  void _reloadConnection() {
    final notifier = ref.read(connectionServiceProvider.notifier);
    notifier.resume();
    ref.read(connectionStatusProvider.notifier).update(ConnectionStatus.connected);
  }

  void _showDisconnectDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          AppStrings.exitDemoConfirm,
          style: TextStyle(color: AppColors.primaryText),
        ),
        content: const Text(
          AppStrings.exitDemoMessage,
          style: TextStyle(color: AppColors.mutedText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              AppStrings.cancel,
              style: TextStyle(color: AppColors.mutedText),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _disconnect();
            },
            child: const Text(
              AppStrings.exit,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _disconnect() async {
    await ref.read(connectionServiceProvider.notifier).disconnect();
    ref.read(connectionStatusProvider.notifier).update(ConnectionStatus.offline);
    await ref.read(activeDeviceProfileProvider.notifier).clearProfile();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ConnectDeviceScreen()),
        (route) => false,
      );
    }
  }

  /// 'flow_rate_history' -> 'Flow Rate History'; short ids like
  /// 'tds' stay uppercase ('TDS').
  String _tabLabel(String tabId) {
    if (tabId.length <= 3) return tabId.toUpperCase();
    final words = tabId.split('_').map((w) => w.isEmpty
        ? w
        : w[0].toUpperCase() + w.substring(1));
    return words.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(activeDeviceProfileProvider);
    final connStatus = ref.watch(connectionStatusProvider);
    final tabsByTabId = ref.watch(sensorsByTabProvider);

    final tabIds = tabsByTabId.keys.toList(growable: false);
    if (_currentIndex >= tabIds.length) {
      _currentIndex = 0;
    }

    BadgeStatus badgeStatus;
    switch (connStatus) {
      case ConnectionStatus.connected:
        badgeStatus = BadgeStatus.connected;
        break;
      case ConnectionStatus.reconnecting:
        badgeStatus = BadgeStatus.reconnecting;
        break;
      case ConnectionStatus.offline:
        badgeStatus = BadgeStatus.offline;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(profile?.name ?? AppStrings.dashboard),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Center(
              child: ConnectionStatusBadge(status: badgeStatus),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.mutedText,
              size: 22,
            ),
            tooltip: 'Reload',
            onPressed: _reloadConnection,
          ),
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: AppColors.mutedText,
              size: 22,
            ),
            tooltip: AppStrings.exitDemo,
            onPressed: _showDisconnectDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: tabIds.isEmpty
          ? Center(
              child: Text(
                'No sensors configured for this device.',
                style: AppTheme.gaugeUnitStyle(),
              ),
            )
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: KeyedSubtree(
                key: ValueKey(tabIds[_currentIndex]),
                child: SensorTabView(
                  sensors: tabsByTabId[tabIds[_currentIndex]]!,
                ),
              ),
            ),
      bottomNavigationBar: tabIds.isEmpty
          ? null
          : BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              type: BottomNavigationBarType.fixed,
              items: [
                for (final tabId in tabIds)
                  BottomNavigationBarItem(
                    // Icon derives from the first sensor configured in the tab.
                    icon: Icon(
                      AppIcons.fromKey(tabsByTabId[tabId]!.first.icon),
                    ),
                    label: _tabLabel(tabId),
                  ),
              ],
            ),
    );
  }
}
