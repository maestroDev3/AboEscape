import 'subscription.dart';

/// Single source of the user's subscriptions; the UI only talks to this
/// interface, so storage can later be replaced by a backend or sync.
abstract interface class SubscriptionRepository {
  /// Emits all subscriptions immediately on listen and again after every
  /// change.
  Stream<List<Subscription>> watchAll();

  /// Adds [subscription] or replaces the one with the same `id`.
  Future<void> save(Subscription subscription);

  /// Removes the subscription with [id]; unknown ids are ignored.
  Future<void> delete(String id);
}
