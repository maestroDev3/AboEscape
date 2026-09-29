/// Supplies the current time, so logic never calls `DateTime.now()` directly
/// and tests can pass a fixed moment instead.
typedef Clock = DateTime Function();

/// Normalizes [moment] to UTC midnight of its own calendar day.
///
/// Day-based calculations (billing dates, deadlines) compare these values, so
/// a daylight saving time switch can never shift a result by one day.
DateTime dayOf(DateTime moment) =>
    DateTime.utc(moment.year, moment.month, moment.day);
