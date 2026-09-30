import 'package:abo_escape/domain/change_currency.dart';
import 'package:abo_escape/domain/currencies.dart';
import 'package:abo_escape/domain/money.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_settings_repository.dart';
import '../support/fake_subscription_repository.dart';
import '../support/subscription_fixtures.dart';

void main() {
  group('changeAppCurrency', () {
    test('stores the currency and switches every subscription', () async {
      final settings = FakeSettingsRepository(currency: 'EUR');
      final netflix = buildSubscription(id: 'n', cents: 1299);
      final gym = buildSubscription(id: 'g', cents: 2990, currency: 'USD');
      final subscriptions = FakeSubscriptionRepository([netflix, gym]);

      await changeAppCurrency(
        currency: 'GBP',
        settings: settings,
        subscriptions: subscriptions,
      );

      expect(settings.currency, 'GBP');
      expect(subscriptions.subscriptions, [
        netflix.copyWith(price: Money(cents: 1299, currency: 'GBP')),
        gym.copyWith(price: Money(cents: 2990, currency: 'GBP')),
      ]);
    });

    test('leaves subscriptions already in the currency unchanged', () async {
      final netflix = buildSubscription(id: 'n', cents: 1299, currency: 'GBP');
      final subscriptions = FakeSubscriptionRepository([netflix]);

      await changeAppCurrency(
        currency: 'GBP',
        settings: FakeSettingsRepository(),
        subscriptions: subscriptions,
      );

      expect(subscriptions.subscriptions, [netflix]);
    });
  });

  group('supportedCurrencies', () {
    test('offers euro and US dollar as three-letter codes', () {
      expect(supportedCurrencies, containsAll(['EUR', 'USD']));
      expect(
        supportedCurrencies.every(
          (code) => RegExp(r'^[A-Z]{3}$').hasMatch(code),
        ),
        isTrue,
      );
    });
  });
}
