import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/subscription.dart';
import '../domain/subscription_repository.dart';
import 'subscription_codec.dart';

/// Stores all subscriptions on the device as one JSON list in
/// [SharedPreferences].
class SharedPreferencesSubscriptionRepository
    implements SubscriptionRepository {
  SharedPreferencesSubscriptionRepository(this._preferences);

  /// Versioned key; a format change gets a new key plus a migration.
  static const storageKey = 'subscriptions.v1';

  final SharedPreferences _preferences;
  final _changes = StreamController<List<Subscription>>.broadcast();

  @override
  Stream<List<Subscription>> watchAll() {
    late final StreamController<List<Subscription>> controller;
    StreamSubscription<List<Subscription>>? changes;
    controller = StreamController<List<Subscription>>(
      onListen: () {
        controller.add(_load());
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
  Future<void> save(Subscription subscription) async {
    final subscriptions = _load();
    final index = subscriptions.indexWhere((s) => s.id == subscription.id);
    if (index == -1) {
      subscriptions.add(subscription);
    } else {
      subscriptions[index] = subscription;
    }
    await _store(subscriptions);
  }

  @override
  Future<void> delete(String id) async {
    final subscriptions = _load();
    await _store(subscriptions.where((s) => s.id != id).toList());
  }

  List<Subscription> _load() => switch (_preferences.getString(storageKey)) {
    final String stored => decodeSubscriptions(stored),
    null => <Subscription>[],
  };

  Future<void> _store(List<Subscription> subscriptions) async {
    await _preferences.setString(
      storageKey,
      encodeSubscriptions(subscriptions),
    );
    _changes.add(List.unmodifiable(subscriptions));
  }
}
