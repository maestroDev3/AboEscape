import 'package:flutter/material.dart';

import '../domain/costs.dart';
import '../domain/subscription.dart';
import '../domain/subscription_repository.dart';
import '../l10n/app_localizations.dart';
import 'format.dart';
import 'labels.dart';

/// Shows how the subscription costs split across categories.
class CostBreakdownScreen extends StatefulWidget {
  const CostBreakdownScreen({required this.repository, super.key});

  final SubscriptionRepository repository;

  @override
  State<CostBreakdownScreen> createState() => _CostBreakdownScreenState();
}

class _CostBreakdownScreenState extends State<CostBreakdownScreen> {
  late final Stream<List<Subscription>> _subscriptions = widget.repository
      .watchAll();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.costBreakdownTitle)),
      body: StreamBuilder<List<Subscription>>(
        stream: _subscriptions,
        builder: (context, snapshot) {
          final subscriptions = snapshot.data ?? const <Subscription>[];
          final monthlyTotals = {
            for (final summary in costSummaries(subscriptions))
              summary.monthly.currency: summary.monthly.cents,
          };
          final costs = categoryCosts(subscriptions);
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: costs.length,
            itemBuilder: (context, index) {
              final cost = costs[index];
              final monthly = cost.costs.monthly;
              return _CategoryRow(
                cost: cost,
                share: _share(monthly.cents, monthlyTotals[monthly.currency]),
              );
            },
          );
        },
      ),
    );
  }
}

/// Share of [part] in [total] for the progress bar (display only).
double _share(int part, int? total) =>
    total == null || total == 0 ? 0 : part / total;

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.cost, required this.share});

  final CategoryCost cost;
  final double share;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    categoryLabel(localizations, cost.category),
                    style: textTheme.titleMedium,
                  ),
                ),
                Text(
                  formatMoney(cost.costs.monthly, locale),
                  style: textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: share),
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                formatMoney(cost.costs.yearly, locale),
                style: textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
