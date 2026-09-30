import 'dart:async';

import 'package:abo_escape/domain/settings_repository.dart';

/// In-memory [SettingsRepository] for tests.
class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository({this.currency, this.disclaimerAccepted = true});

  /// Current app currency, for assertions; null until one is chosen.
  String? currency;
  final _changes = StreamController<String?>.broadcast();

  /// Accepted by default, so widget tests don't see the first-start dialog.
  bool disclaimerAccepted;

  @override
  Stream<String?> watchCurrency() {
    late final StreamController<String?> controller;
    StreamSubscription<String?>? changes;
    controller = StreamController<String?>(
      onListen: () {
        controller.add(currency);
        changes = _changes.stream.listen(controller.add);
      },
      // Returning the cancel future would make `first` wait for it, which
      // never completes inside fake-async widget tests.
      onCancel: () {
        changes?.cancel();
      },
    );
    return controller.stream;
  }

  @override
  Future<void> saveCurrency(String code) async {
    currency = code;
    _changes.add(code);
  }

  @override
  Future<bool> isDisclaimerAccepted() async => disclaimerAccepted;

  @override
  Future<void> acceptDisclaimer() async => disclaimerAccepted = true;
}
