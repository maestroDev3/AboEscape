/// Stored format `subscriptions.v1` as written by the first release.
/// Never change this fixture – it guards backward compatibility.
const storedV1 = '''
[
  {
    "id": "a",
    "name": "Netflix",
    "priceCents": 1299,
    "currency": "EUR",
    "interval": {"type": "monthly"},
    "startDate": "2026-01-15",
    "minimumTerm": null,
    "noticePeriod": {"amount": 1, "unit": "months"},
    "category": "streaming"
  },
  {
    "id": "b",
    "name": "Gym",
    "priceCents": 2990,
    "currency": "EUR",
    "interval": {"type": "everyNWeeks", "weeks": 4},
    "startDate": "2025-11-01",
    "minimumTerm": {"amount": 12, "unit": "months"},
    "noticePeriod": {"amount": 14, "unit": "days"},
    "category": "fitness"
  }
]
''';
