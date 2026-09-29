import 'package:abo_escape/data/shared_preferences_subscription_repository.dart';
import 'package:abo_escape/data/subscription_codec.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/stored_fixtures.dart';
import '../support/subscription_fixtures.dart';
import '../support/subscription_repository_contract.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  runSubscriptionRepositoryContract('SharedPreferencesSubscriptionRepository', (
    initial,
  ) async {
    SharedPreferences.setMockInitialValues({
      SharedPreferencesSubscriptionRepository.storageKey: encodeSubscriptions(
        initial,
      ),
    });
    return SharedPreferencesSubscriptionRepository(
      await SharedPreferences.getInstance(),
    );
  });

  group('SharedPreferencesSubscriptionRepository', () {
    test('stores under the versioned key subscriptions.v1', () {
      expect(
        SharedPreferencesSubscriptionRepository.storageKey,
        'subscriptions.v1',
      );
    });

    test('starts empty when nothing is stored', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = SharedPreferencesSubscriptionRepository(
        await SharedPreferences.getInstance(),
      );

      expect(await repository.watchAll().first, isEmpty);
    });

    test('keeps data for a new instance on the same preferences', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final subscription = buildSubscription();

      await SharedPreferencesSubscriptionRepository(preferences)
          .save(subscription);
      final reopened = SharedPreferencesSubscriptionRepository(preferences);

      expect(await reopened.watchAll().first, [subscription]);
    });

    test('loads data stored in the v1 format', () async {
      SharedPreferences.setMockInitialValues({'subscriptions.v1': storedV1});
      final repository = SharedPreferencesSubscriptionRepository(
        await SharedPreferences.getInstance(),
      );

      final loaded = await repository.watchAll().first;

      expect(loaded.map((s) => s.name), ['Netflix', 'Gym']);
    });
  });
}
