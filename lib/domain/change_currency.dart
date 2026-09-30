import 'money.dart';
import 'settings_repository.dart';
import 'subscription_repository.dart';

/// Makes [currency] the app currency and switches every subscription to it,
/// keeping the amounts (decision: no conversion).
Future<void> changeAppCurrency({
  required String currency,
  required SettingsRepository settings,
  required SubscriptionRepository subscriptions,
}) async {
  await settings.saveCurrency(currency);
  final current = await subscriptions.watchAll().first;
  for (final subscription in current) {
    if (subscription.price.currency == currency) continue;
    await subscriptions.save(
      subscription.copyWith(
        price: Money(cents: subscription.price.cents, currency: currency),
      ),
    );
  }
}
