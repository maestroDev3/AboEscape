import '../domain/billing_interval.dart';
import '../domain/period.dart';
import '../domain/subscription_category.dart';
import '../l10n/app_localizations.dart';

/// Localized name of a billing interval, e.g. "Every 2 weeks".
String intervalLabel(AppLocalizations localizations, BillingInterval interval) =>
    switch (interval) {
      Monthly() => localizations.intervalMonthly,
      Quarterly() => localizations.intervalQuarterly,
      Yearly() => localizations.intervalYearly,
      EveryNWeeks(:final weeks) => localizations.intervalEveryNWeeks(weeks),
    };

/// Localized name of a subscription category.
String categoryLabel(
  AppLocalizations localizations,
  SubscriptionCategory category,
) => switch (category) {
  SubscriptionCategory.streaming => localizations.categoryStreaming,
  SubscriptionCategory.music => localizations.categoryMusic,
  SubscriptionCategory.software => localizations.categorySoftware,
  SubscriptionCategory.news => localizations.categoryNews,
  SubscriptionCategory.gaming => localizations.categoryGaming,
  SubscriptionCategory.fitness => localizations.categoryFitness,
  SubscriptionCategory.cloud => localizations.categoryCloud,
  SubscriptionCategory.mobile => localizations.categoryMobile,
  SubscriptionCategory.insurance => localizations.categoryInsurance,
  SubscriptionCategory.other => localizations.categoryOther,
};

/// Localized name of a period unit, e.g. "months".
String periodUnitLabel(AppLocalizations localizations, PeriodUnit unit) =>
    switch (unit) {
      PeriodUnit.days => localizations.periodUnitDays,
      PeriodUnit.weeks => localizations.periodUnitWeeks,
      PeriodUnit.months => localizations.periodUnitMonths,
    };
