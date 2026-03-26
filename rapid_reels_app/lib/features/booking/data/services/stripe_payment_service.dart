import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

import '../../../../core/config/stripe_config.dart';

class StripePaymentIntentData {
  final String clientSecret;
  final String paymentIntentId;

  StripePaymentIntentData({
    required this.clientSecret,
    required this.paymentIntentId,
  });
}

class StripePaymentService {
  StripePaymentService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _stripeApi = 'https://api.stripe.com/v1/payment_intents';

  /// Creates a PaymentIntent via Stripe HTTP API (no Cloud Functions).
  Future<StripePaymentIntentData> createPaymentIntent({
    required String bookingId,
    required String userId,
    required double amount,
    String currency = 'inr',
  }) async {
    if (StripeConfig.secretKey.isEmpty) {
      throw Exception('Stripe secret key missing in StripeConfig');
    }

    final amountSmallest = (amount * 100).round();
    if (amountSmallest <= 0) {
      throw Exception('Invalid payment amount');
    }

    final body = <String, String>{
      'amount': '$amountSmallest',
      'currency': currency.toLowerCase(),
      'automatic_payment_methods[enabled]': 'true',
      'metadata[bookingId]': bookingId,
      'metadata[userId]': userId,
    };

    final encodedBody = body.entries
        .map(
          (e) =>
              '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}',
        )
        .join('&');

    final response = await _client.post(
      Uri.parse(_stripeApi),
      headers: {
        'Authorization': 'Bearer ${StripeConfig.secretKey}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: encodedBody,
    );

    final dynamic decoded =
        response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final err = decoded is Map<String, dynamic> ? decoded['error'] : null;
      final msg = err is Map ? err['message']?.toString() : null;
      throw Exception(
        msg ?? 'Stripe error (${response.statusCode})',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid Stripe response');
    }

    final clientSecret = decoded['client_secret']?.toString() ?? '';
    final id = decoded['id']?.toString() ?? '';
    if (clientSecret.isEmpty || id.isEmpty) {
      throw Exception('Invalid payment intent response');
    }

    return StripePaymentIntentData(
      clientSecret: clientSecret,
      paymentIntentId: id,
    );
  }

  Future<void> presentPaymentSheet({
    required String clientSecret,
    required String merchantDisplayName,
  }) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: merchantDisplayName,
        style: ThemeMode.system,
        googlePay: const PaymentSheetGooglePay(
          merchantCountryCode: 'IN',
          testEnv: true,
        ),
      ),
    );

    await Stripe.instance.presentPaymentSheet();
  }
}
