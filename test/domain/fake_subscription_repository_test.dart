import '../support/fake_subscription_repository.dart';
import '../support/subscription_repository_contract.dart';

void main() {
  runSubscriptionRepositoryContract(
    'FakeSubscriptionRepository',
    (initial) async => FakeSubscriptionRepository(initial),
  );
}
