/// App-wide user settings, stored on the device.
abstract interface class SettingsRepository {
  /// Emits the chosen app currency (ISO 4217 code) on listen and after every
  /// change; null until the user picks one.
  Stream<String?> watchCurrency();

  /// Stores [code] as the app currency.
  Future<void> saveCurrency(String code);

  /// Whether the user has confirmed the disclaimer shown on first start.
  Future<bool> isDisclaimerAccepted();

  /// Remembers that the user has confirmed the disclaimer.
  Future<void> acceptDisclaimer();
}
