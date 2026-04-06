/// Display helpers for sensitive fields (bank account, etc.).
abstract final class SensitiveDataMask {
  /// Returns `••••1234` when [digits] has length ≥ 4; otherwise masks all.
  static String accountNumberLast4(String digits) {
    final t = digits.trim();
    if (t.isEmpty) return '';
    if (t.length <= 4) return '••••$t';
    return '••••${t.substring(t.length - 4)}';
  }
}
