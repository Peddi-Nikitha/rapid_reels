import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Wait for minimum display time (2.5 seconds)
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (!mounted || _hasNavigated) return;
    
    _navigateToNext();
  }

  void _navigateToNext() {
    if (_hasNavigated) return;
    _hasNavigated = true;

    _routeBasedOnAuth();
  }

  Future<void> _routeBasedOnAuth() async {
    final auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    // On cold starts currentUser may briefly be null before auth restores.
    if (user == null) {
      try {
        user = await auth.authStateChanges().first.timeout(
          const Duration(seconds: 2),
          onTimeout: () => null,
        );
      } catch (_) {
        user = null;
      }
    }

    if (!mounted) return;
    context.go(user != null ? AppRoutes.home : AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Image.asset(
          'assets/images/splash_screen.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            // If image fails to load, show black screen
            debugPrint('Error loading splash image: $error');
            return Container(
              color: Colors.black,
            );
          },
        ),
      ),
    );
  }
}
