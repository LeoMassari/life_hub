import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class AppStore {
  Future<Map<String, dynamic>?> load();
  Future<void> save(Map<String, dynamic> data);
}

class LocalStore implements AppStore {
  static const _key = 'life_hub_data_v1';
  @override
  Future<Map<String, dynamic>?> load() async {
    final raw = (await SharedPreferences.getInstance()).getString(_key);
    return raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
  }

  @override
  Future<void> save(Map<String, dynamic> data) async =>
      (await SharedPreferences.getInstance()).setString(_key, jsonEncode(data));
}
