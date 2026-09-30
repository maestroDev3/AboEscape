import 'package:flutter/material.dart';

import '../domain/change_currency.dart';
import '../domain/currencies.dart';
import '../domain/settings_repository.dart';
import '../domain/subscription_repository.dart';
import '../l10n/app_localizations.dart';
import 'format.dart';

/// App-wide settings, currently the app currency.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    required this.settings,
    required this.subscriptions,
    super.key,
  });

  final SettingsRepository settings;

  /// Switched to a newly chosen currency.
  final SubscriptionRepository subscriptions;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final Stream<String?> _currency = widget.settings.watchCurrency();

  Future<void> _chooseCurrency(String current) async {
    final chosen = await showDialog<String>(
      context: context,
      builder: (context) => _CurrencyDialog(current: current),
    );
    if (chosen == null || chosen == current) return;
    await changeAppCurrency(
      currency: chosen,
      settings: widget.settings,
      subscriptions: widget.subscriptions,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(title: Text(localizations.settings)),
      body: StreamBuilder<String?>(
        stream: _currency,
        builder: (context, snapshot) {
          final current = snapshot.data ?? currencyForLocale(locale);
          return ListView(
            children: [
              ListTile(
                key: const Key('currencyTile'),
                leading: const Icon(Icons.payments_outlined),
                title: Text(localizations.currencySettingLabel),
                subtitle: Text(current),
                onTap: () => _chooseCurrency(current),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(localizations.about),
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: localizations.appTitle,
                  children: [Text(localizations.disclaimerText)],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Lets the user pick one of [supportedCurrencies]; pops the chosen code.
class _CurrencyDialog extends StatelessWidget {
  const _CurrencyDialog({required this.current});

  final String current;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();

    return SimpleDialog(
      title: Text(localizations.currencySettingLabel),
      children: [
        for (final code in supportedCurrencies)
          ListTile(
            title: Text(code),
            subtitle: Text(currencySymbol(code, locale)),
            trailing: code == current ? const Icon(Icons.check) : null,
            onTap: () => Navigator.of(context).pop(code),
          ),
      ],
    );
  }
}
