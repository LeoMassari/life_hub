import 'local_store.dart';

/// Keeps a local copy for fast startup and sends changes to the cloud.
/// Existing local data is uploaded automatically when the remote row is empty.
class SyncedStore implements AppStore {
  SyncedStore({required this.local, required this.remote});

  final AppStore local;
  final AppStore remote;

  @override
  Future<Map<String, dynamic>?> load() async {
    try {
      final cloudData = await remote.load();
      if (cloudData != null) {
        await local.save(cloudData);
        return cloudData;
      }
      final localData = await local.load();
      if (localData != null) await remote.save(localData);
      return localData;
    } catch (_) {
      return local.load();
    }
  }

  @override
  Future<void> save(Map<String, dynamic> data) async {
    await local.save(data);
    try {
      await remote.save(data);
    } catch (_) {
      // The local copy remains usable while the device is offline.
    }
  }
}
