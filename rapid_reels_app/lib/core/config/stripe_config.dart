/// Stripe app config.
abstract final class StripeConfig {
  /// Prefer `--dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_...` (or pk_test) when building.
  /// You may set a live/test publishable key here for release APKs if you do not use dart-defines.
  /// Publishable keys are safe to embed in the app (never put secret keys here).
  static const String publishableKey = 'pk_live_51RdCZ7KPz48WhVEJdliENUwdUXbsSlk9b9Tv68LalEllYTJ1AabLu5GwC30eFXNZCTygHbkIydpWFij8PuNQx25e00Fj6wAbEo';
}
