import 'package:flutter_test/flutter_test.dart';
import 'package:life_hub/data/local_store.dart';
import 'package:life_hub/data/synced_store.dart';

class MemoryStore implements AppStore {
  MemoryStore([this.value]);
  Map<String, dynamic>? value;
  bool fail = false;
  @override
  Future<Map<String, dynamic>?> load() async {
    if (fail) throw Exception('offline');
    return value;
  }

  @override
  Future<void> save(Map<String, dynamic> data) async {
    if (fail) throw Exception('offline');
    value = data;
  }
}

void main() {
  test('migra i dati locali quando il cloud è vuoto', () async {
    final local = MemoryStore({'tasks': <Object>[]});
    final remote = MemoryStore();
    final store = SyncedStore(local: local, remote: remote);

    expect(await store.load(), local.value);
    expect(remote.value, local.value);
  });

  test('continua a salvare localmente quando il cloud è offline', () async {
    final local = MemoryStore();
    final remote = MemoryStore()..fail = true;
    final store = SyncedStore(local: local, remote: remote);

    await store.save({'darkMode': true});
    expect(local.value?['darkMode'], isTrue);
    expect(local.value?['_lifeHubPendingSync'], isTrue);
  });

  test('invia al cloud le modifiche rimaste in attesa', () async {
    final local = MemoryStore({'darkMode': true, '_lifeHubPendingSync': true});
    final remote = MemoryStore({'darkMode': false});
    final store = SyncedStore(local: local, remote: remote);

    expect(await store.load(), {'darkMode': true});
    expect(remote.value, {'darkMode': true});
    expect(local.value?.containsKey('_lifeHubPendingSync'), isFalse);
  });
}
