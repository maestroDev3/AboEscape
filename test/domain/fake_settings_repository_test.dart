import '../support/fake_settings_repository.dart';
import '../support/settings_repository_contract.dart';

void main() {
  runSettingsRepositoryContract(
    'FakeSettingsRepository',
    () async => FakeSettingsRepository(),
  );
}
