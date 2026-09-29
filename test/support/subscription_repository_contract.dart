import 'package:abo_escape/domain/subscription.dart';
import 'package:abo_escape/domain/subscription_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'subscription_fixtures.dart';

/// Creates a repository that already contains [initial].
typedef RepositoryFactory =
    Future<SubscriptionRepository> Function(List<Subscription> initial);

/// Behaviour every [SubscriptionRepository] implementation must fulfil.
void runSubscriptionRepositoryContract(String name, RepositoryFactory create) {
  group('$name (SubscriptionRepository contract)', () {
    final netflix = buildSubscription(id: 'a', name: 'Netflix');
    final spotify = buildSubscription(id: 'b', name: 'Spotify', cents: 1099);

    Future<List<List<Subscription>>> record(
      SubscriptionRepository repository,
      Future<void> Function() actions,
    ) async {
      final emitted = <List<Subscription>>[];
      final subscription = repository.watchAll().listen(emitted.add);
      await _settle();
      await actions();
      await _settle();
      await subscription.cancel();
      return emitted;
    }

    test('emits the stored list first', () async {
      final repository = await create([netflix]);

      final emitted = await record(repository, () async {});

      expect(emitted, [
        [netflix],
      ]);
    });

    test('emits a new list after every save and delete', () async {
      final repository = await create([]);

      final emitted = await record(repository, () async {
        await repository.save(netflix);
        await _settle();
        await repository.save(spotify);
        await _settle();
        await repository.delete(netflix.id);
      });

      expect(emitted, [
        <Subscription>[],
        [netflix],
        [netflix, spotify],
        [spotify],
      ]);
    });

    test('replaces a subscription saved with an existing id', () async {
      final repository = await create([netflix, spotify]);
      final renamed = netflix.copyWith(name: 'Netflix Premium');

      final emitted = await record(repository, () => repository.save(renamed));

      expect(emitted.last, [renamed, spotify]);
    });

    test('deletes only the subscription with the given id', () async {
      final repository = await create([netflix, spotify]);

      final emitted = await record(
        repository,
        () => repository.delete(spotify.id),
      );

      expect(emitted.last, [netflix]);
    });

    test('ignores deleting an unknown id', () async {
      final repository = await create([netflix]);

      final emitted = await record(
        repository,
        () => repository.delete('unknown'),
      );

      expect(emitted.last, [netflix]);
    });
  });
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);
