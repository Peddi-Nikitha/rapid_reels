import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripePaymentIntentData {
  final String clientSecret;
  final String paymentIntentId;

  StripePaymentIntentData({
    required this.clientSecret,
    required this.paymentIntentId,
  });
}

class StripePaymentService {
  StripePaymentService({FirebaseFunctions? functions})
      : _functions =
            functions ?? FirebaseFunctions.instanceFor(region: 'us-central1');

  final FirebaseFunctions _functions;

  /// Creates a PaymentIntent via secure server callable function.
  Future<StripePaymentIntentData> createPaymentIntent({
    required String bookingId,
  }) async {
    final callable = _functions.httpsCallable(
      'createStripePaymentIntent',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 60)),
    );
    try {
      final response = await callable.call(<String, dynamic>{
        'bookingId': bookingId,
      });
      final raw = response.data;
      if (raw is! Map) {
        throw Exception('Invalid payment intent response');
      }
      final data = Map<String, dynamic>.from(raw);
      final clientSecret = data['clientSecret']?.toString() ?? '';
      final id = data['paymentIntentId']?.toString() ?? '';
      if (clientSecret.isEmpty || id.isEmpty) {
        throw Exception('Invalid payment intent response');
      }

      return StripePaymentIntentData(
        clientSecret: clientSecret,
        paymentIntentId: id,
      );
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? e.code);
    }
  }

  Future<void> presentPaymentSheet({
    required String clientSecret,
    required String merchantDisplayName,
  }) async {
    // Matches AndroidManifest intent-filter (3DS / bank redirects).
    // Omit Google Pay until it is enabled for your Stripe account + app; cards still work.
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: merchantDisplayName,
        style: ThemeMode.system,
        returnURL: 'rapidreels://redirect',
      ),
    );

    await Stripe.instance.presentPaymentSheet();
  }
}
