import 'package:intl/intl.dart';

import '../firebase/models/firebase_provider_model.dart';

/// Local calendar date (no time / timezone shift for display day).
///
/// Normalizes UTC timestamps (from Firestore) to local first so calendar-day
/// comparisons stay stable across timezones.
DateTime dateOnlyLocal(DateTime d) {
  final local = d.toLocal();
  return DateTime(local.year, local.month, local.day);
}

/// `yyyy-MM-dd` in local calendar for provider slot rules and [eventDateKey].
String dateKeyLocal(DateTime d) => DateFormat('yyyy-MM-dd').format(dateOnlyLocal(d));

String weekdayKeyLocal(DateTime d) {
  const keys = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];
  return keys[d.weekday - 1];
}

/// Statuses that reserve the provider for that calendar day (one slot per day).
bool bookingStatusBlocksDay(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
    case 'confirmed':
    case 'ongoing':
      return true;
    default:
      return false;
  }
}

/// When [FirebaseProviderModel.availability] has no entry for a weekday, treat as open (legacy providers).
bool isWeekdayOpenForDate(FirebaseProviderModel provider, DateTime date) {
  final key = weekdayKeyLocal(date);
  final day = provider.availability[key];
  if (day == null) return true;
  return day.isOpen;
}

bool isBlockedByProvider(FirebaseProviderModel provider, DateTime date) {
  final target = dateOnlyLocal(date);
  for (final b in provider.blockedDates) {
    if (dateOnlyLocal(b.date) == target) return true;
  }
  return false;
}

/// True if the customer can book this [date] for [provider] given precomputed occupied keys (same [dateKeyLocal]).
bool isDateAvailableForProvider(
  FirebaseProviderModel provider,
  DateTime date,
  Set<String> occupiedDateKeys,
) {
  final key = dateKeyLocal(date);
  if (occupiedDateKeys.contains(key)) return false;
  if (isBlockedByProvider(provider, date)) return false;
  if (!isWeekdayOpenForDate(provider, date)) return false;
  return true;
}
