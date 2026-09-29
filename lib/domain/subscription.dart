import 'billing_interval.dart';
import 'clock.dart';
import 'money.dart';
import 'period.dart';
import 'subscription_category.dart';

/// A recurring contract the user pays for; the central entity of the app.
final class Subscription {
  Subscription({
    required this.id,
    required String name,
    required this.price,
    required this.interval,
    required DateTime startDate,
    required this.category,
    this.minimumTerm,
    this.noticePeriod,
  }) : name = name.trim(),
       startDate = dayOf(startDate) {
    if (this.name.isEmpty) {
      throw ArgumentError.value(name, 'name', 'must not be empty');
    }
  }

  /// Marks an optional argument of [copyWith] as "not given".
  static const _keep = Object();

  final String id;
  final String name;
  final Money price;
  final BillingInterval interval;

  /// First day of the subscription, normalized with [dayOf].
  final DateTime startDate;

  /// Minimum contract term; null if the subscription can be cancelled anytime.
  final Period? minimumTerm;

  /// Notice period before cancellation takes effect; null if there is none.
  final Period? noticePeriod;

  final SubscriptionCategory category;

  /// Returns a copy with the given fields replaced; passing `null` for
  /// [minimumTerm] or [noticePeriod] clears that period.
  Subscription copyWith({
    String? name,
    Money? price,
    BillingInterval? interval,
    DateTime? startDate,
    Object? minimumTerm = _keep,
    Object? noticePeriod = _keep,
    SubscriptionCategory? category,
  }) => Subscription(
    id: id,
    name: name ?? this.name,
    price: price ?? this.price,
    interval: interval ?? this.interval,
    startDate: startDate ?? this.startDate,
    minimumTerm: identical(minimumTerm, _keep)
        ? this.minimumTerm
        : minimumTerm as Period?,
    noticePeriod: identical(noticePeriod, _keep)
        ? this.noticePeriod
        : noticePeriod as Period?,
    category: category ?? this.category,
  );

  @override
  bool operator ==(Object other) =>
      other is Subscription &&
      other.id == id &&
      other.name == name &&
      other.price == price &&
      other.interval == interval &&
      other.startDate == startDate &&
      other.minimumTerm == minimumTerm &&
      other.noticePeriod == noticePeriod &&
      other.category == category;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    price,
    interval,
    startDate,
    minimumTerm,
    noticePeriod,
    category,
  );

  @override
  String toString() => 'Subscription($id, $name)';
}
