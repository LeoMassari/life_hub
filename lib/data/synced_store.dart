import 'local_store.dart';

/// Keeps a local copy for fast startup and sends changes to the cloud.
/// Existing local data is uploaded automatically when the remote row is empty.
class SyncedStore implements AppStore {
  SyncedStore({required this.local, required this.remote});

  final AppStore local;
  final AppStore remote;
  static const _pendingKey = '_lifeHubPendingSync';

  Map<String, dynamic> _clean(Map<String, dynamic> value) =>
      Map<String, dynamic>.from(value)..remove(_pendingKey);

  @override
  Future<Map<String, dynamic>?> load() async {
    final localData = await local.load();
    if (localData?[_pendingKey] == true) {
      final cleanLocal = _clean(localData!);
      try {
        await remote.save(cleanLocal);
        await local.save(cleanLocal);
      } catch (_) {
        // Keep the pending marker so a later launch can retry safely.
      }
      return cleanLocal;
    }
    try {
      final cloudData = await remote.load();
      if (cloudData != null) {
        await local.save(cloudData);
        return cloudData;
      }
      if (localData != null) await remote.save(localData);
      return localData;
    } catch (_) {
      return localData == null ? null : _clean(localData);
    }
  }

  @override
  Future<void> save(Map<String, dynamic> data) async {
    await local.save({...data, _pendingKey: true});
    try {
      await remote.save(data);
      await local.save(data);
    } catch (_) {
      // The pending marker triggers a retry on the next launch.
    }
  }
}
