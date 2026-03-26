import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'app.dart';
import 'core/config/stripe_config.dart';
import 'core/constants/app_colors.dart';
import 'core/firebase/services/firebase_init_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const stripePublishableFromDefine = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
  );
  final stripePublishableKey = stripePublishableFromDefine.isNotEmpty
      ? stripePublishableFromDefine
      : StripeConfig.publishableKey; // or override via --dart-define

  final supportsStripeMobile =
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  if (supportsStripeMobile && stripePublishableKey.isNotEmpty) {
    Stripe.publishableKey = stripePublishableKey;
    Stripe.urlScheme = 'rapidreels';
    await Stripe.instance.applySettings();
  }

  // Initialize Firebase (Auth, Firestore, Analytics, Crashlytics)
  await FirebaseInitService.initialize();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: RapidReelsApp()));
}
