import 'dart:convert';

import '../domain/billing_interval.dart';
import '../domain/money.dart';
import '../domain/period.dart';
import '../domain/subscription.dart';
import '../domain/subscription_category.dart';

// JSON format of stored subscriptions (version 1, key `subscriptions.v1`).
// Only add optional fields; renaming or removing one needs a new version and
// a migration test.

/// Encodes a list of subscriptions as a JSON string for storage.
String encodeSubscriptions(List<Subscription> subscriptions) =>
    jsonEncode([for (final s in subscriptions) subscriptionToJson(s)]);

/// Decodes a JSON string written by [encodeSubscriptions].
List<Subscription> decodeSubscriptions(String source) => switch (jsonDecode(
  source,
)) {
  final List<Object?> list => [
    for (final item in list)
      switch (item) {
        final Map<String, Object?> json => subscriptionFromJson(json),
        _ => throw FormatException('Invalid subscription entry: $item'),
      },
  ],
  final other => throw FormatException('Expected a list, got: $other'),
};

Map<String, Object?> subscriptionToJson(Subscription subscription) => {
  'id': subscription.id,
  'name': subscription.name,
  'priceCents': subscription.price.cents,
  'currency': subscription.price.currency,
  'interval': _intervalToJson(subscription.interval),
  'startDate': _dateToJson(subscription.startDate),
  'minimumTerm': _periodToJson(subscription.minimumTerm),
  'noticePeriod': _periodToJson(subscription.noticePeriod),
  'category': subscription.category.name,
};

Subscription subscriptionFromJson(Map<String, Object?> json) => switch (json) {
  {
    'id': final String id,
    'name': final String name,
    'priceCents': final int cents,
    'currency': final String currency,
    'interval': final Object interval,
    'startDate': final String startDate,
    'category': final String category,
  } =>
    Subscription(
      id: id,
      name: name,
      price: Money(cents: cents, currency: currency),
      interval: _intervalFromJson(interval),
      startDate: DateTime.parse(startDate),
      minimumTerm: _periodFromJson(json['minimumTerm']),
      noticePeriod: _periodFromJson(json['noticePeriod']),
      category: SubscriptionCategory.values.asNameMap()[category] ??
          SubscriptionCategory.other,
    ),
  _ => throw FormatException('Invalid subscription: $json'),
};

Map<String, Object?> _intervalToJson(BillingInterval interval) =>
    switch (interval) {
      Monthly() => {'type': 'monthly'},
      Quarterly() => {'type': 'quarterly'},
      Yearly() => {'type': 'yearly'},
      EveryNWeeks(:final weeks) => {'type': 'everyNWeeks', 'weeks': weeks},
    };

BillingInterval _intervalFromJson(Object json) => switch (json) {
  {'type': 'monthly'} => const Monthly(),
  {'type': 'quarterly'} => const Quarterly(),
  {'type': 'yearly'} => const Yearly(),
  {'type': 'everyNWeeks', 'weeks': final int weeks} => EveryNWeeks(weeks),
  _ => throw FormatException('Invalid interval: $json'),
};

Map<String, Object?>? _periodToJson(Period? period) => switch (period) {
  null => null,
  Period(:final amount, :final unit) => {'amount': amount, 'unit': unit.name},
};

Period? _periodFromJson(Object? json) => switch (json) {
  null => null,
  {'amount': final int amount, 'unit': final String unit} => Period(
    amount,
    PeriodUnit.values.asNameMap()[unit] ??
        (throw FormatException('Invalid period unit: $unit')),
  ),
  _ => throw FormatException('Invalid period: $json'),
};

String _dateToJson(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-'
    '${day.month.toString().padLeft(2, '0')}-'
    '${day.day.toString().padLeft(2, '0')}';
