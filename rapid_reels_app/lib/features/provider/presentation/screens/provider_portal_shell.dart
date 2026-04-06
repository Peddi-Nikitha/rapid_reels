import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/provider/provider_bottom_nav_bar.dart';

/// Wraps [StatefulNavigationShell] with provider bottom navigation.
class ProviderPortalShell extends StatelessWidget {
  const ProviderPortalShell({
    super.key,
    required this.providerId,
    required this.navigationShell,
  });

  final String providerId;
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: ProviderBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
