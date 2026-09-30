import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/settings_repository.dart';

/// Stores settings in [SharedPreferences].
class SharedPreferencesSettingsRepository implements SettingsRepository {
  SharedPreferencesSettingsRepository(this._preferences);

  /// Versioned key of the app currency.
  static const currencyKey = 'settings.currency.v1';

  final SharedPreferences _preferences;
  final _changes = StreamController<String?>.broadcast();

  @override
  Stream<String?> watchCurrency() {
    late final StreamController<String?> controller;
    StreamSubscription<String?>? changes;
    controller = StreamController<String?>(
      onListen: () {
        controller.add(_preferences.getString(currencyKey));
        changes = _changes.stream.listen(controller.add);
      },
      onCancel: () => changes?.cancel(),
    );
    return controller.stream;
  }

  @override
  Future<void> saveCurrency(String code) async {
    await _preferences.setString(currencyKey, code);
    _changes.add(code);
  }
}
