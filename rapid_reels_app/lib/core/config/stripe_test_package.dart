import '../../features/booking/data/models/service_provider_model.dart';

/// Optional Stripe live/test charge: **£2.00 GBP** (single payment).
/// Use only for payment integration testing; remove or hide in production UX if desired.
abstract final class StripeTestPackage {
  static const String packageId = 'stripe_test_1gbp';

  /// Fixed single payment total.
  static const double totalGbp = 2.0;

  static PackageOffering get offering => PackageOffering(
        packageId: packageId,
        name: 'Stripe test (£2)',
        price: totalGbp,
        duration: 60,
        reelsCount: 1,
        editingStyle: 'standard',
        deliveryTime: 60,
        features: const [
          'Integration test only — £2.00 GBP total (single payment)',
          'GBP-only so UK Stripe minimums apply correctly',
        ],
      );

  static bool isStripeTestPackage(String? id) => id == packageId;

  /// Display helper for package list rows in GBP.
  static String formatListedPrice(PackageOffering p) {
    return '£${p.price.toStringAsFixed(2)}';
  }

  static String formatBookingMoney(double amount, {required bool isGbp}) {
    return '£${amount.toStringAsFixed(2)}';
  }
}
