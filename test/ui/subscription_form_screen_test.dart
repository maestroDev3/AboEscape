import 'package:abo_escape/domain/billing_interval.dart';
import 'package:abo_escape/domain/money.dart';
import 'package:abo_escape/domain/period.dart';
import 'package:abo_escape/domain/subscription.dart';
import 'package:abo_escape/domain/subscription_category.dart';
import 'package:abo_escape/ui/subscription_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_subscription_repository.dart';
import '../support/pump_app.dart';
import '../support/subscription_fixtures.dart';

final _now = DateTime(2026, 9, 29, 10, 30);

/// Opens the form from a launcher screen, so saving can pop it.
Future<void> _openForm(
  WidgetTester tester,
  FakeSubscriptionRepository repository, {
  Subscription? subscription,
}) async {
  await tester.pumpApp(
    Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: TextButton(
            key: const Key('open'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SubscriptionFormScreen(
                  repository: repository,
                  subscription: subscription,
                  clock: () => _now,
                ),
              ),
            ),
            child: const SizedBox.square(dimension: 48),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.byKey(const Key('open')));
  await tester.pumpAndSettle();
}

Future<void> _enter(WidgetTester tester, String key, String text) async {
  final field = find.byKey(Key(key));
  await tester.ensureVisible(field);
  await tester.enterText(field, text);
  await tester.pump();
}

Future<void> _choose(WidgetTester tester, String key, String option) async {
  final field = find.byKey(Key(key));
  await tester.ensureVisible(field);
  await tester.pumpAndSettle();
  await tester.tap(field);
  await tester.pumpAndSettle();
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
}

Future<void> _save(WidgetTester tester) async {
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

void main() {
  group('SubscriptionFormScreen', () {
    testWidgets('shows an error and does not save without a name', (
      tester,
    ) async {
      final repository = FakeSubscriptionRepository();
      await _openForm(tester, repository);
      await _enter(tester, 'priceField', '9,99');

      await _save(tester);

      expect(find.text('Please enter a name'), findsOneWidget);
      expect(repository.subscriptions, isEmpty);
    });

    testWidgets('shows an error and does not save with an invalid price', (
      tester,
    ) async {
      final repository = FakeSubscriptionRepository();
      await _openForm(tester, repository);
      await _enter(tester, 'nameField', 'Netflix');
      await _enter(tester, 'priceField', 'abc');

      await _save(tester);

      expect(find.text('Please enter a valid price'), findsOneWidget);
      expect(repository.subscriptions, isEmpty);
    });

    testWidgets('saves a new monthly subscription and closes', (tester) async {
      final repository = FakeSubscriptionRepository();
      await _openForm(tester, repository);
      expect(find.text('Add subscription'), findsOneWidget);
      await _enter(tester, 'nameField', 'Netflix');
      await _enter(tester, 'priceField', '12,99');
      await _choose(tester, 'intervalField', 'Monthly');

      await _save(tester);

      final saved = repository.subscriptions.single;
      expect(saved.name, 'Netflix');
      expect(saved.price, Money(cents: 1299, currency: 'USD'));
      expect(saved.interval, const Monthly());
      expect(saved.id, isNotEmpty);
      expect(find.byType(SubscriptionFormScreen), findsNothing);
    });

    testWidgets('asks for the number of weeks for "Every n weeks"', (
      tester,
    ) async {
      final repository = FakeSubscriptionRepository();
      await _openForm(tester, repository);
      expect(find.byKey(const Key('weeksField')), findsNothing);
      await _enter(tester, 'nameField', 'Meal box');
      await _enter(tester, 'priceField', '49');

      await _choose(tester, 'intervalField', 'Every n weeks');
      expect(find.byKey(const Key('weeksField')), findsOneWidget);
      await _enter(tester, 'weeksField', '2');
      await _save(tester);

      expect(repository.subscriptions.single.interval, EveryNWeeks(2));
    });

    testWidgets('rejects an invalid number of weeks', (tester) async {
      final repository = FakeSubscriptionRepository();
      await _openForm(tester, repository);
      await _enter(tester, 'nameField', 'Meal box');
      await _enter(tester, 'priceField', '49');
      await _choose(tester, 'intervalField', 'Every n weeks');
      await _enter(tester, 'weeksField', '0');

      await _save(tester);

      expect(find.text('Please enter a number of weeks'), findsOneWidget);
      expect(repository.subscriptions, isEmpty);
    });

    testWidgets('defaults the start date to the day of the clock', (
      tester,
    ) async {
      final repository = FakeSubscriptionRepository();
      await _openForm(tester, repository);
      expect(find.text('Sep 29, 2026'), findsOneWidget);
      await _enter(tester, 'nameField', 'Netflix');
      await _enter(tester, 'priceField', '12.99');

      await _save(tester);

      expect(
        repository.subscriptions.single.startDate,
        DateTime.utc(2026, 9, 29),
      );
    });

    testWidgets('stores no periods when they are left empty', (tester) async {
      final repository = FakeSubscriptionRepository();
      await _openForm(tester, repository);
      await _enter(tester, 'nameField', 'Netflix');
      await _enter(tester, 'priceField', '12.99');

      await _save(tester);

      final saved = repository.subscriptions.single;
      expect(saved.minimumTerm, isNull);
      expect(saved.noticePeriod, isNull);
    });

    testWidgets('stores minimum term, notice period and category', (
      tester,
    ) async {
      final repository = FakeSubscriptionRepository();
      await _openForm(tester, repository);
      await _enter(tester, 'nameField', 'Gym');
      await _enter(tester, 'priceField', '29,90');
      await _choose(tester, 'categoryField', 'Fitness');
      await _enter(tester, 'minimumTermAmountField', '12');
      await _enter(tester, 'noticePeriodAmountField', '14');
      await _choose(tester, 'noticePeriodUnitField', 'days');

      await _save(tester);

      final saved = repository.subscriptions.single;
      expect(saved.minimumTerm, Period(12, PeriodUnit.months));
      expect(saved.noticePeriod, Period(14, PeriodUnit.days));
      expect(saved.category, SubscriptionCategory.fitness);
    });

    testWidgets('rejects a period that is not a whole number', (tester) async {
      final repository = FakeSubscriptionRepository();
      await _openForm(tester, repository);
      await _enter(tester, 'nameField', 'Gym');
      await _enter(tester, 'priceField', '29,90');
      await _enter(tester, 'minimumTermAmountField', '1.5');

      await _save(tester);

      expect(find.text('Please enter a whole number'), findsOneWidget);
      expect(repository.subscriptions, isEmpty);
    });

    testWidgets('pre-fills an existing subscription and keeps its id', (
      tester,
    ) async {
      final existing = buildSubscription(
        id: 'existing',
        name: 'Gym',
        cents: 2990,
        interval: EveryNWeeks(4),
        startDate: DateTime.utc(2025, 11, 1),
        minimumTerm: Period(12, PeriodUnit.months),
        noticePeriod: Period(14, PeriodUnit.days),
        category: SubscriptionCategory.fitness,
      );
      final repository = FakeSubscriptionRepository([existing]);
      await _openForm(tester, repository, subscription: existing);

      expect(find.text('Edit subscription'), findsOneWidget);
      expect(find.text('Gym'), findsOneWidget);
      expect(find.text('29.90'), findsOneWidget);
      expect(find.text('Every n weeks'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('Nov 1, 2025'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('14'), findsOneWidget);
      expect(find.text('Fitness'), findsOneWidget);

      await _enter(tester, 'nameField', 'Gym Plus');
      await _save(tester);

      expect(repository.subscriptions.single, existing.copyWith(name: 'Gym Plus'));
    });
  });
}
