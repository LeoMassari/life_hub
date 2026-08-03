import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:life_hub/data/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('mantiene separate le cache locali di due account', () async {
    final leo = LocalStore.forUser('leo');
    final partner = LocalStore.forUser('partner');

    await leo.save({'owner': 'leo'});
    await partner.save({'owner': 'partner'});

    expect(await leo.load(), {'owner': 'leo'});
    expect(await partner.load(), {'owner': 'partner'});
  });

  test('i dati anonimi vengono migrati soltanto al primo account', () async {
    SharedPreferences.setMockInitialValues({
      'life_hub_data_v1': jsonEncode({'owner': 'legacy'}),
    });
    final firstAccount = LocalStore.forUser('first');
    final secondAccount = LocalStore.forUser('second');

    expect(await firstAccount.load(), {'owner': 'legacy'});
    expect(await secondAccount.load(), isNull);
  });
}
