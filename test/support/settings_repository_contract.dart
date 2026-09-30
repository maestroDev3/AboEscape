import 'package:abo_escape/domain/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Behaviour every [SettingsRepository] implementation must fulfil.
void runSettingsRepositoryContract(
  String name,
  Future<SettingsRepository> Function() create,
) {
  group('$name (SettingsRepository contract)', () {
    test('emits null before a currency is chosen', () async {
      final repository = await create();

      expect(await repository.watchCurrency().first, isNull);
    });

    test('emits the saved currency', () async {
      final repository = await create();

      await repository.saveCurrency('GBP');

      expect(await repository.watchCurrency().first, 'GBP');
    });

    test('notifies listeners about a new currency', () async {
      final repository = await create();
      final emitted = <String?>[];
      final subscription = repository.watchCurrency().listen(emitted.add);
      await Future<void>.delayed(Duration.zero);

      await repository.saveCurrency('CHF');
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(emitted, [null, 'CHF']);
    });
  });
}
