import 'package:abo_escape/domain/billing_interval.dart';
import 'package:abo_escape/domain/money.dart';
import 'package:abo_escape/domain/period.dart';
import 'package:abo_escape/domain/subscription.dart';
import 'package:abo_escape/domain/subscription_category.dart';

/// Builds a subscription with sensible defaults, so tests only spell out the
/// values they care about.
Subscription buildSubscription({
  String id = 'sub-1',
  String name = 'Netflix',
  int cents = 1299,
  String currency = 'EUR',
  BillingInterval interval = const Monthly(),
  DateTime? startDate,
  Period? minimumTerm,
  Period? noticePeriod,
  SubscriptionCategory category = SubscriptionCategory.streaming,
}) => Subscription(
  id: id,
  name: name,
  price: Money(cents: cents, currency: currency),
  interval: interval,
  startDate: startDate ?? DateTime.utc(2026, 1, 15),
  minimumTerm: minimumTerm,
  noticePeriod: noticePeriod,
  category: category,
);
