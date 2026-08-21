import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../models/device_profile.dart';
import '../../providers/providers.dart';
import '../../services/connection/connection_service.dart';
import '../onboarding/connect_device_screen.dart';

class DeviceSettingsScreen extends ConsumerWidget {
  const DeviceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(allProfilesProvider);
    final activeProfile = ref.watch(activeDeviceProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myDevices),
      ),
      body: profiles.isEmpty
          ? const Center(
              child: Text(
                'No saved devices',
                style: TextStyle(color: AppColors.mutedText),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.paddingSm,
              ),
              itemCount: profiles.length,
              itemBuilder: (context, index) {
                final profile = profiles[index];
                final isActive = profile.id == activeProfile?.id;

                return ListTile(
                  leading: Icon(
                    Icons.device_hub,
                    color: isActive
                        ? AppColors.primary
                        : AppColors.mutedText,
                  ),
                  title: Text(
                    profile.name,
                    style: TextStyle(
                      color: isActive
                          ? AppColors.primaryText
                          : AppColors.mutedText,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  subtitle: Text(
                    '${profile.host}:${profile.port}',
                    style: const TextStyle(
                      color: AppColors.mutedText,
                      fontSize: 12,
                    ),
                  ),
                  trailing: isActive
                      ? const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: 20,
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.mutedText,
                            size: 20,
                          ),
                          onPressed: () => _confirmDelete(
                            context,
                            ref,
                            profile,
                          ),
                        ),
                  onTap: () async {
                    await ref
                        .read(activeDeviceProfileProvider.notifier)
                        .setProfile(profile);

                    final notifier =
                        ref.read(connectionServiceProvider.notifier);
                    final success = await notifier.connect(profile);
                    ref.read(connectionStatusProvider.notifier).update(
                          success
                              ? ConnectionStatus.connected
                              : ConnectionStatus.offline,
                        );

                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ConnectDeviceScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    DeviceProfile profile,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Remove Device',
          style: TextStyle(color: AppColors.primaryText),
        ),
        content: Text(
          'Remove "${profile.name}" from saved devices?',
          style: const TextStyle(color: AppColors.mutedText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.mutedText),
            ),
          ),
          TextButton(
            onPressed: () async {
              await ref
                  .read(activeDeviceProfileProvider.notifier)
                  .clearProfile();
              await ref
                  .read(storageServiceProvider)
                  .deleteProfile(profile.id);
              ref
                  .read(activeDeviceProfileProvider.notifier)
                  .refresh();
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
