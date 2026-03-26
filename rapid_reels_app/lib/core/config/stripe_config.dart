/// Stripe app config.
abstract final class StripeConfig {
  /// Keep empty and pass with --dart-define=STRIPE_PUBLISHABLE_KEY=...
  static const String publishableKey = '';

  /// For server-side intent creation only. Prefer passing at runtime via:
  /// --dart-define=STRIPE_SECRET_KEY=...
  /// Never hardcode live keys in source control.
  static const String secretKey = String.fromEnvironment('STRIPE_SECRET_KEY');
}
