import 'package:flutter/material.dart';

import '../domain/billing.dart';
import '../domain/clock.dart';
import '../domain/costs.dart';
import '../domain/subscription.dart';
import '../domain/subscription_repository.dart';
import '../l10n/app_localizations.dart';
import 'cost_breakdown_screen.dart';
import 'format.dart';
import 'labels.dart';
import 'subscription_form_screen.dart';

/// Start screen listing the user's subscriptions, with an empty state until
/// there are any.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.repository,
    this.clock = DateTime.now,
    super.key,
  });

  final SubscriptionRepository repository;
  final Clock clock;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Stream<List<Subscription>> _subscriptions = widget.repository
      .watchAll();

  void _openForm([Subscription? subscription]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SubscriptionFormScreen(
          repository: widget.repository,
          subscription: subscription,
          clock: widget.clock,
        ),
      ),
    );
  }

  void _openCostBreakdown() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CostBreakdownScreen(repository: widget.repository),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: Text(localizations.addSubscription),
      ),
      body: StreamBuilder<List<Subscription>>(
        stream: _subscriptions,
        builder: (context, snapshot) {
          final subscriptions = switch (snapshot.data) {
            final data? => sortByNextBillingDate(data, widget.clock()),
            null => null,
          };
          return CustomScrollView(
            slivers: [
              SliverAppBar.large(title: Text(localizations.appTitle)),
              if (subscriptions case final list? when list.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(message: localizations.emptySubscriptions),
                )
              else if (subscriptions case final list?) ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: _CostCard(
                      summaries: costSummaries(list),
                      onTap: _openCostBreakdown,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                  sliver: SliverList.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) => _SubscriptionTile(
                      subscription: list[index],
                      nextBilling: nextBillingDate(list[index], widget.clock()),
                      onTap: () => _openForm(list[index]),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Total monthly and yearly cost, one pair of rows per currency.
class _CostCard extends StatelessWidget {
  const _CostCard({required this.summaries, required this.onTap});

  final List<CostSummary> summaries;

  /// Opens the breakdown by category.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();

    return Card.filled(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              for (final summary in summaries) ...[
                _CostRow(
                  label: localizations.costPerMonth,
                  amount: formatMoney(summary.monthly, locale),
                  emphasized: true,
                ),
                const SizedBox(height: 4),
                _CostRow(
                  label: localizations.costPerYear,
                  amount: formatMoney(summary.yearly, locale),
                  emphasized: false,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  const _CostRow({
    required this.label,
    required this.amount,
    required this.emphasized,
  });

  final String label;
  final String amount;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final style = emphasized ? textTheme.titleLarge : textTheme.bodyLarge;

    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(amount, style: style),
      ],
    );
  }
}

class _SubscriptionTile extends StatelessWidget {
  const _SubscriptionTile({
    required this.subscription,
    required this.nextBilling,
    required this.onTap,
  });

  final Subscription subscription;
  final DateTime nextBilling;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(subscription.name),
        isThreeLine: true,
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(intervalLabel(localizations, subscription.interval)),
            Text(
              localizations.nextBillingDate(formatDate(nextBilling, locale)),
            ),
          ],
        ),
        trailing: Text(
          formatMoney(subscription.price, locale),
          style: theme.textTheme.titleMedium,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
