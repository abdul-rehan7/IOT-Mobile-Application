import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../models/device_profile.dart';
import '../../providers/providers.dart';
import '../../services/connection/connection_service.dart';
import '../dashboard/dashboard_shell.dart';

class ConnectDeviceScreen extends ConsumerStatefulWidget {
  const ConnectDeviceScreen({super.key});

  @override
  ConsumerState<ConnectDeviceScreen> createState() =>
      _ConnectDeviceScreenState();
}

class _ConnectDeviceScreenState extends ConsumerState<ConnectDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Tank Monitor');
  final _hostController = TextEditingController(text: 'broker.hivemq.com');
  final _portController = TextEditingController(text: '1883');
  final _topicPrefixController = TextEditingController(text: 'esp32/tank-01/');
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _connectionType = 'mqtt';
  bool _isConnecting = false;
  bool _useDemoMode = false;
  bool _showAuth = false;

  @override
  void dispose() {
    _nameController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _topicPrefixController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isConnecting = true);

    final topicPrefix = _topicPrefixController.text.trim();

    final profile = DeviceProfile.create(
      name: _nameController.text.trim(),
      connectionType: _connectionType,
      host: _hostController.text.trim(),
      port: int.parse(_portController.text.trim()),
      topicPrefix: topicPrefix,
      mqttUsername: _usernameController.text.trim().isEmpty
          ? null
          : _usernameController.text.trim(),
      mqttPassword: _passwordController.text.isEmpty
          ? null
          : _passwordController.text,
    );

    final notifier = ref.read(connectionServiceProvider.notifier);
    final success = await notifier.connect(profile);

    if (success && mounted) {
      await ref
          .read(activeDeviceProfileProvider.notifier)
          .setProfile(profile);
      ref.read(connectionStatusProvider.notifier).update(
            ConnectionStatus.connected,
          );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const DashboardShell(),
          ),
        );
      }
    } else if (mounted) {
      setState(() => _isConnecting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Can't reach broker. Check host/port and try again.",
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _connectDemo() async {
    setState(() {
      _isConnecting = true;
      _useDemoMode = true;
    });

    final profile = DeviceProfile.create(
      name: 'Demo Device',
      connectionType: 'mock',
      host: 'localhost',
      port: 0,
    );

    final notifier = ref.read(connectionServiceProvider.notifier);
    final success = await notifier.connect(profile);

    if (success && mounted) {
      await ref
          .read(activeDeviceProfileProvider.notifier)
          .setProfile(profile);
      ref.read(connectionStatusProvider.notifier).update(
            ConnectionStatus.connected,
          );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const DashboardShell(),
          ),
        );
      }
    } else if (mounted) {
      setState(() {
        _isConnecting = false;
        _useDemoMode = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingLg),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.sensors,
                        size: 48,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: AppDimensions.paddingMd),
                      Text(
                        AppStrings.connectDevice,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.paddingLg),

                      // Device Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.deviceName,
                          prefixIcon: Icon(Icons.label_outline),
                          hintText: 'e.g. Tank Monitor, Warehouse Sensor',
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: AppDimensions.paddingMd),

                      // Broker Host
                      TextFormField(
                        controller: _hostController,
                        decoration: const InputDecoration(
                          labelText: 'Broker Host',
                          prefixIcon: Icon(Icons.dns_outlined),
                          hintText: 'broker.hivemq.com',
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: AppDimensions.paddingMd),

                      // Port
                      TextFormField(
                        controller: _portController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.port,
                          prefixIcon: Icon(Icons.numbers),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if (int.tryParse(v.trim()) == null) {
                            return 'Must be a number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.paddingMd),

                      // Topic Prefix
                      TextFormField(
                        controller: _topicPrefixController,
                        decoration: const InputDecoration(
                          labelText: 'Topic Prefix',
                          prefixIcon: Icon(Icons.topic_outlined),
                          hintText: 'esp32/tank-01/',
                          helperText: 'ESP publishes to this prefix + "data"',
                          helperMaxLines: 2,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingMd),

                      // Connection Type
                      DropdownButtonFormField<String>(
                        initialValue: _connectionType,
                        decoration: const InputDecoration(
                          labelText: AppStrings.connectionType,
                          prefixIcon: Icon(Icons.swap_horiz),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'mqtt',
                            child: Text('WiFi - MQTT'),
                          ),
                          DropdownMenuItem(
                            value: 'http',
                            child: Text('WiFi - HTTP'),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _connectionType = v);
                        },
                      ),
                      const SizedBox(height: AppDimensions.paddingSm),

                      // Auth toggle
                      TextButton.icon(
                        onPressed: () => setState(() => _showAuth = !_showAuth),
                        icon: Icon(
                          _showAuth
                              ? Icons.expand_less
                              : Icons.expand_more,
                          size: 18,
                        ),
                        label: Text(
                          _showAuth ? 'Hide Authentication' : 'Broker Authentication (optional)',
                          style: const TextStyle(
                            color: AppColors.mutedText,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      // Auth fields
                      if (_showAuth) ...[
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person_outline),
                            hintText: 'Leave empty if none',
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingMd),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                            hintText: 'Leave empty if none',
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: AppDimensions.paddingMd),
                      ],

                      const SizedBox(height: AppDimensions.paddingMd),

                      // Connect button
                      ElevatedButton(
                        onPressed: _isConnecting ? null : _connect,
                        child: _isConnecting && !_useDemoMode
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.background,
                                ),
                              )
                            : Text(
                                _isConnecting
                                    ? AppStrings.connecting
                                    : AppStrings.connect,
                              ),
                      ),
                      const SizedBox(height: AppDimensions.paddingMd),

                      // Demo button
                      OutlinedButton(
                        onPressed: _isConnecting ? null : _connectDemo,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.mutedText),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.paddingMd,
                          ),
                        ),
                        child: _isConnecting && _useDemoMode
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              )
                            : const Text(
                                AppStrings.demoMode,
                                style: TextStyle(color: AppColors.mutedText),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
