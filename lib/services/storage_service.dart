import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/device_profile.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  static const String boxName = 'iot_monitor_storage';
  static const String _profilesKey = 'device_profiles';
  static const String _activeProfileKey = 'active_device_id';

  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(boxName);
  }

  List<DeviceProfile> getAllProfiles() {
    final raw = _box.get(_profilesKey);
    if (raw == null) return [];
    final list = jsonDecode(raw as String) as List;
    return list
        .map((e) => DeviceProfile.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveProfile(DeviceProfile profile) async {
    final profiles = getAllProfiles();
    final idx = profiles.indexWhere((p) => p.id == profile.id);
    if (idx >= 0) {
      profiles[idx] = profile;
    } else {
      profiles.add(profile);
    }
    await _box.put(
      _profilesKey,
      jsonEncode(profiles.map((p) => p.toJson()).toList()),
    );
  }

  Future<void> deleteProfile(String id) async {
    final profiles = getAllProfiles();
    profiles.removeWhere((p) => p.id == id);
    await _box.put(
      _profilesKey,
      jsonEncode(profiles.map((p) => p.toJson()).toList()),
    );

    if (_box.get(_activeProfileKey) == id) {
      if (profiles.isNotEmpty) {
        await setActiveProfile(profiles.first.id);
      } else {
        await _box.delete(_activeProfileKey);
      }
    }
  }

  String? getActiveProfileId() {
    return _box.get(_activeProfileKey) as String?;
  }

  DeviceProfile? getActiveProfile() {
    final id = getActiveProfileId();
    if (id == null) return null;
    final profiles = getAllProfiles();
    try {
      return profiles.firstWhere((p) => p.id == id);
    } catch (_) {
      return profiles.isNotEmpty ? profiles.first : null;
    }
  }

  Future<void> setActiveProfile(String id) async {
    await _box.put(_activeProfileKey, id);
  }

  bool hasAnyProfile() {
    return getAllProfiles().isNotEmpty;
  }
}
