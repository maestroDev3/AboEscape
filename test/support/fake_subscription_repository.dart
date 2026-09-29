import 'dart:async';

import 'package:abo_escape/domain/subscription.dart';
import 'package:abo_escape/domain/subscription_repository.dart';

/// In-memory [SubscriptionRepository] for widget tests.
class FakeSubscriptionRepository implements SubscriptionRepository {
  FakeSubscriptionRepository([List<Subscription> initial = const []])
    : _subscriptions = List.of(initial);

  List<Subscription> _subscriptions;
  final _changes = StreamController<List<Subscription>>.broadcast();

  /// Current content, for assertions.
  List<Subscription> get subscriptions => List.unmodifiable(_subscriptions);

  @override
  Stream<List<Subscription>> watchAll() {
    late final StreamController<List<Subscription>> controller;
    StreamSubscription<List<Subscription>>? changes;
    controller = StreamController<List<Subscription>>(
      onListen: () {
        controller.add(subscriptions);
        changes = _changes.stream.listen(controller.add);
      },
      onCancel: () => changes?.cancel(),
    );
    return controller.stream;
  }

  @override
  Future<void> save(Subscription subscription) async {
    final index = _subscriptions.indexWhere((s) => s.id == subscription.id);
    _subscriptions = [..._subscriptions];
    if (index == -1) {
      _subscriptions.add(subscription);
    } else {
      _subscriptions[index] = subscription;
    }
    _changes.add(subscriptions);
  }

  @override
  Future<void> delete(String id) async {
    _subscriptions = _subscriptions.where((s) => s.id != id).toList();
    _changes.add(subscriptions);
  }
}
