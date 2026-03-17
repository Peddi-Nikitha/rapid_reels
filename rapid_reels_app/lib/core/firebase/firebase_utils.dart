/// Shared utilities for Firebase model parsing.
/// Handles Firestore returning boolean fields as strings (e.g. "true"/"false").
bool firebaseToBool(dynamic value, bool defaultValue) {
  if (value == null) return defaultValue;
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  return defaultValue;
}
