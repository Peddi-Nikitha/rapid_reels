import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/discover/presentation/screens/main_discover_screen.dart';
import '../../features/my_events/presentation/screens/dynamic_my_events_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import 'rapid_bottom_nav_bar.dart';

class MainScaffold extends StatefulWidget {
  final int initialTabIndex;

  const MainScaffold({super.key, this.initialTabIndex = 0});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _currentIndex;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MainDiscoverScreen(),
    const DynamicMyEventsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _screens[_currentIndex],
      bottomNavigationBar: RapidBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
