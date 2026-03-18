import 'package:flutter/material.dart';
import 'profile_screen.dart';

/// Kept for backward compatibility with older routes/widgets.
/// The app now uses the Firestore-backed `ProfileScreen`.
class MainProfileScreen extends StatelessWidget {
  const MainProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen();
  }
}

