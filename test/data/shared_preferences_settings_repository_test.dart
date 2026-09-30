import 'package:abo_escape/data/shared_preferences_settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/settings_repository_contract.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  runSettingsRepositoryContract('SharedPreferencesSettingsRepository', () async {
    SharedPreferences.setMockInitialValues({});
    return SharedPreferencesSettingsRepository(
      await SharedPreferences.getInstance(),
    );
  });

  group('SharedPreferencesSettingsRepository', () {
    test('stores the currency under settings.currency.v1', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();

      await SharedPreferencesSettingsRepository(preferences).saveCurrency('GBP');

      expect(SharedPreferencesSettingsRepository.currencyKey, 'settings.currency.v1');
      expect(preferences.getString('settings.currency.v1'), 'GBP');
    });

    test('keeps the currency for a new instance', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();

      await SharedPreferencesSettingsRepository(preferences).saveCurrency('SEK');
      final reopened = SharedPreferencesSettingsRepository(preferences);

      expect(await reopened.watchCurrency().first, 'SEK');
    });
  });
}
