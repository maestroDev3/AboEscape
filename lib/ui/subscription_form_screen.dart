import 'dart:math';

import 'package:flutter/material.dart';

import '../domain/amount_parser.dart';
import '../domain/billing_interval.dart';
import '../domain/clock.dart';
import '../domain/money.dart';
import '../domain/period.dart';
import '../domain/settings_repository.dart';
import '../domain/subscription.dart';
import '../domain/subscription_category.dart';
import '../domain/subscription_repository.dart';
import '../l10n/app_localizations.dart';
import 'format.dart';
import 'labels.dart';

/// Choices of the billing interval field; "every n weeks" needs a number.
enum _IntervalKind { monthly, quarterly, yearly, everyNWeeks }

/// Form to create a new subscription or edit [subscription].
class SubscriptionFormScreen extends StatefulWidget {
  const SubscriptionFormScreen({
    required this.repository,
    required this.settings,
    this.subscription,
    this.clock = DateTime.now,
    super.key,
  });

  final SubscriptionRepository repository;

  /// Provides the app currency for new subscriptions.
  final SettingsRepository settings;

  /// The subscription to edit; null creates a new one.
  final Subscription? subscription;

  final Clock clock;

  @override
  State<SubscriptionFormScreen> createState() => _SubscriptionFormScreenState();
}

class _SubscriptionFormScreenState extends State<SubscriptionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _weeks = TextEditingController();
  final _minimumTermAmount = TextEditingController();
  final _noticePeriodAmount = TextEditingController();

  var _intervalKind = _IntervalKind.monthly;
  var _category = SubscriptionCategory.other;
  var _minimumTermUnit = PeriodUnit.months;
  var _noticePeriodUnit = PeriodUnit.months;
  late DateTime _startDate;
  var _prefilled = false;

  @override
  void initState() {
    super.initState();
    _startDate = dayOf(widget.clock());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;
    _prefilled = true;
    if (widget.subscription case final subscription?) {
      _prefill(subscription, Localizations.localeOf(context).toString());
    }
  }

  void _prefill(Subscription subscription, String locale) {
    _name.text = subscription.name;
    _price.text = formatAmountForInput(subscription.price.cents, locale);
    _intervalKind = switch (subscription.interval) {
      Monthly() => _IntervalKind.monthly,
      Quarterly() => _IntervalKind.quarterly,
      Yearly() => _IntervalKind.yearly,
      EveryNWeeks() => _IntervalKind.everyNWeeks,
    };
    if (subscription.interval case EveryNWeeks(:final weeks)) {
      _weeks.text = '$weeks';
    }
    _startDate = subscription.startDate;
    _category = subscription.category;
    if (subscription.minimumTerm case final term?) {
      _minimumTermAmount.text = '${term.amount}';
      _minimumTermUnit = term.unit;
    }
    if (subscription.noticePeriod case final notice?) {
      _noticePeriodAmount.text = '${notice.amount}';
      _noticePeriodUnit = notice.unit;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _weeks.dispose();
    _minimumTermAmount.dispose();
    _noticePeriodAmount.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_startDate.year, _startDate.month, _startDate.day),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (!mounted || picked == null) return;
    setState(() => _startDate = dayOf(picked));
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final cents = parseAmountToCents(_price.text);
    if (cents == null) return;

    final existing = widget.subscription;
    final localeCurrency = currencyForLocale(
      Localizations.localeOf(context).toString(),
    );
    final currency =
        existing?.price.currency ??
        await widget.settings.watchCurrency().first ??
        localeCurrency;
    final subscription = Subscription(
      id: existing?.id ?? _newId(),
      name: _name.text,
      price: Money(cents: cents, currency: currency),
      interval: _interval(),
      startDate: _startDate,
      minimumTerm: _period(_minimumTermAmount.text, _minimumTermUnit),
      noticePeriod: _period(_noticePeriodAmount.text, _noticePeriodUnit),
      category: _category,
    );

    await widget.repository.save(subscription);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final subscription = widget.subscription;
    if (subscription == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _DeleteDialog(name: subscription.name),
    );
    if (confirmed != true) return;
    await widget.repository.delete(subscription.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  BillingInterval _interval() => switch (_intervalKind) {
    _IntervalKind.monthly => const Monthly(),
    _IntervalKind.quarterly => const Quarterly(),
    _IntervalKind.yearly => const Yearly(),
    _IntervalKind.everyNWeeks => EveryNWeeks(_wholeNumber(_weeks.text) ?? 1),
  };

  String _newId() =>
      '${widget.clock().microsecondsSinceEpoch.toRadixString(36)}-'
      '${Random().nextInt(1 << 31).toRadixString(36)}';

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.subscription == null
              ? localizations.addSubscription
              : localizations.editSubscription,
        ),
        actions: [
          if (widget.subscription != null)
            IconButton(
              onPressed: _confirmDelete,
              tooltip: localizations.delete,
              icon: const Icon(Icons.delete_outline),
            ),
          TextButton(onPressed: _save, child: Text(localizations.save)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('nameField'),
                controller: _name,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: localizations.nameFieldLabel,
                ),
                validator: (value) => (value ?? '').trim().isEmpty
                    ? localizations.nameRequiredError
                    : null,
              ),
              const _Gap(),
              TextFormField(
                key: const Key('priceField'),
                controller: _price,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: localizations.priceFieldLabel,
                ),
                validator: (value) => parseAmountToCents(value ?? '') == null
                    ? localizations.priceInvalidError
                    : null,
              ),
              const _Gap(),
              DropdownButtonFormField<_IntervalKind>(
                key: const Key('intervalField'),
                initialValue: _intervalKind,
                decoration: InputDecoration(
                  labelText: localizations.billingIntervalFieldLabel,
                ),
                items: [
                  for (final kind in _IntervalKind.values)
                    DropdownMenuItem(
                      value: kind,
                      child: Text(_intervalKindLabel(localizations, kind)),
                    ),
                ],
                onChanged: (kind) => setState(
                  () => _intervalKind = kind ?? _IntervalKind.monthly,
                ),
              ),
              if (_intervalKind == _IntervalKind.everyNWeeks) ...[
                const _Gap(),
                TextFormField(
                  key: const Key('weeksField'),
                  controller: _weeks,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: localizations.weeksFieldLabel,
                  ),
                  validator: (value) => _wholeNumber(value ?? '') == null
                      ? localizations.weeksInvalidError
                      : null,
                ),
              ],
              const _Gap(),
              ListTile(
                key: const Key('startDateField'),
                contentPadding: EdgeInsets.zero,
                title: Text(localizations.startDateFieldLabel),
                subtitle: Text(formatDate(_startDate, locale)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: _pickStartDate,
              ),
              const _Gap(),
              DropdownButtonFormField<SubscriptionCategory>(
                key: const Key('categoryField'),
                initialValue: _category,
                decoration: InputDecoration(
                  labelText: localizations.categoryFieldLabel,
                ),
                items: [
                  for (final category in SubscriptionCategory.values)
                    DropdownMenuItem(
                      value: category,
                      child: Text(categoryLabel(localizations, category)),
                    ),
                ],
                onChanged: (category) => setState(
                  () => _category = category ?? SubscriptionCategory.other,
                ),
              ),
              const _Gap(),
              _PeriodField(
                amountKey: const Key('minimumTermAmountField'),
                unitKey: const Key('minimumTermUnitField'),
                label: localizations.minimumTermFieldLabel,
                controller: _minimumTermAmount,
                unit: _minimumTermUnit,
                onUnitChanged: (unit) =>
                    setState(() => _minimumTermUnit = unit),
              ),
              const _Gap(),
              _PeriodField(
                amountKey: const Key('noticePeriodAmountField'),
                unitKey: const Key('noticePeriodUnitField'),
                label: localizations.noticePeriodFieldLabel,
                controller: _noticePeriodAmount,
                unit: _noticePeriodUnit,
                onUnitChanged: (unit) =>
                    setState(() => _noticePeriodUnit = unit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _intervalKindLabel(AppLocalizations localizations, _IntervalKind kind) =>
    switch (kind) {
      _IntervalKind.monthly => localizations.intervalMonthly,
      _IntervalKind.quarterly => localizations.intervalQuarterly,
      _IntervalKind.yearly => localizations.intervalYearly,
      _IntervalKind.everyNWeeks => localizations.intervalEveryNWeeksOption,
    };

/// Parses a positive whole number; null for empty or invalid text.
int? _wholeNumber(String text) => switch (int.tryParse(text.trim())) {
  final number? when number >= 1 => number,
  _ => null,
};

/// Parses an optional period; empty text means "no period".
Period? _period(String amount, PeriodUnit unit) =>
    switch (_wholeNumber(amount)) {
      final number? => Period(number, unit),
      null => null,
    };

/// Optional amount plus unit, used for minimum term and notice period.
class _PeriodField extends StatelessWidget {
  const _PeriodField({
    required this.amountKey,
    required this.unitKey,
    required this.label,
    required this.controller,
    required this.unit,
    required this.onUnitChanged,
  });

  final Key amountKey;
  final Key unitKey;
  final String label;
  final TextEditingController controller;
  final PeriodUnit unit;
  final ValueChanged<PeriodUnit> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            key: amountKey,
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: label,
              hintText: localizations.optionalFieldHint,
            ),
            validator: (value) {
              final text = (value ?? '').trim();
              if (text.isEmpty || _wholeNumber(text) != null) return null;
              return localizations.wholeNumberError;
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<PeriodUnit>(
            key: unitKey,
            initialValue: unit,
            decoration: InputDecoration(
              labelText: localizations.periodUnitFieldLabel,
            ),
            items: [
              for (final value in PeriodUnit.values)
                DropdownMenuItem(
                  value: value,
                  child: Text(periodUnitLabel(localizations, value)),
                ),
            ],
            onChanged: (value) => onUnitChanged(value ?? unit),
          ),
        ),
      ],
    );
  }
}

/// Asks before deleting; pops `true` when the user confirms.
class _DeleteDialog extends StatelessWidget {
  const _DeleteDialog({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(localizations.deleteSubscriptionTitle),
      content: Text(localizations.deleteSubscriptionMessage(name)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(localizations.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(localizations.delete),
        ),
      ],
    );
  }
}

class _Gap extends StatelessWidget {
  const _Gap();

  @override
  Widget build(BuildContext context) => const SizedBox(height: 16);
}
