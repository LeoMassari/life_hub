import 'package:supabase_flutter/supabase_flutter.dart';
import 'local_store.dart';

/// Cloud implementation of [AppStore]. Row Level Security in the supplied
/// migration ensures each authenticated user can access only their own row.
class SupabaseStore implements AppStore {
  SupabaseStore(this.client);

  final SupabaseClient client;

  String get _userId {
    final id = client.auth.currentUser?.id;
    if (id == null) throw StateError('Cloud store requires authentication');
    return id;
  }

  @override
  Future<Map<String, dynamic>?> load() async {
    final row = await client
        .from('life_hub_data')
        .select('payload')
        .eq('user_id', _userId)
        .maybeSingle();
    if (row == null) return null;
    return Map<String, dynamic>.from(row['payload'] as Map);
  }

  @override
  Future<void> save(Map<String, dynamic> data) async {
    await client.from('life_hub_data').upsert({
      'user_id': _userId,
      'payload': data,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }
}
