import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class AppStore {
  Future<Map<String, dynamic>?> load();
  Future<void> save(Map<String, dynamic> data);
}

class LocalStore implements AppStore {
  LocalStore() : _userId = null, _key = _legacyKey;

  LocalStore.forUser(String userId)
    : assert(userId.isNotEmpty),
      _userId = userId,
      _key = '${_legacyKey}_user_$userId';

  static const _legacyKey = 'life_hub_data_v1';
  static const _legacyOwnerKey = 'life_hub_data_v1_legacy_owner';

  final String? _userId;
  final String _key;

  @override
  Future<Map<String, dynamic>?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_key);
    if (raw != null) return _decode(raw);

    final userId = _userId;
    if (userId == null) return null;

    // The first account used on an existing installation receives the old
    // anonymous data. Later accounts never read that shared legacy cache.
    final legacyRaw = preferences.getString(_legacyKey);
    final legacyOwner = preferences.getString(_legacyOwnerKey);
    if (legacyRaw == null || (legacyOwner != null && legacyOwner != userId)) {
      return null;
    }
    if (legacyOwner == null) {
      await preferences.setString(_legacyOwnerKey, userId);
    }
    await preferences.setString(_key, legacyRaw);
    return _decode(legacyRaw);
  }

  @override
  Future<void> save(Map<String, dynamic> data) async {
    await (await SharedPreferences.getInstance()).setString(
      _key,
      jsonEncode(data),
    );
  }

  Map<String, dynamic> _decode(String raw) =>
      Map<String, dynamic>.from(jsonDecode(raw) as Map);
}
