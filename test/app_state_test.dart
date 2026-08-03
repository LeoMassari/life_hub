import 'package:flutter_test/flutter_test.dart';
import 'package:life_hub/data/local_store.dart';
import 'package:life_hub/state/app_state.dart';

class MemoryStore implements AppStore {
  Map<String, dynamic>? value;
  @override
  Future<Map<String, dynamic>?> load() async => value;
  @override
  Future<void> save(Map<String, dynamic> data) async => value = data;
}

void main() {
  test('salva e ricarica i dati personali', () async {
    final store = MemoryStore();
    final first = AppState(store);
    await first.init();

    first.addTask('Prenota il dentista');
    first.addMovement('Cinema', -12.50);
    first.addReminder('Chiamare Marco', '18:30');
    await Future<void>.delayed(Duration.zero);

    final restored = AppState(store);
    await restored.init();

    expect(
      restored.tasks.any((item) => item.title == 'Prenota il dentista'),
      isTrue,
    );
    expect(restored.movements.any((item) => item.label == 'Cinema'), isTrue);
    expect(restored.reminders.any((item) => item.time == '18:30'), isTrue);
  });
}
