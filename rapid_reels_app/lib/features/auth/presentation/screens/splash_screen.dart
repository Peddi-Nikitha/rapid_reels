import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    
    // Navigate to onboarding
    if (mounted) {
      context.go('/onboarding');
    }
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
