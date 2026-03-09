import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/event_card.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../../shared/widgets/empty_state.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _mockData = MockDataService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _mockData.currentUser.userId;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'My Events',
        showBackButton: false,
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Live'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
          
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Upcoming Tab
                _buildEventsList(
                  _mockData.getUpcomingEvents(userId),
                  'No upcoming events',
                  'Book your first event to get started',
                ),
                
                // Live Tab
                _buildEventsList(
                  _mockData.getLiveEvents(userId),
                  'No live events',
                  'Your ongoing events will appear here',
                ),
                
                // Completed Tab
                _buildEventsList(
                  _mockData.getPastEvents(userId),
                  'No past events',
                  'Your completed events will appear here',
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(AppRoutes.eventTypeSelection);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Book Event',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEventsList(
    List<dynamic> events,
    String emptyTitle,
    String emptyMessage,
  ) {
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 3,
        itemBuilder: (context, index) => const ShimmerEventCard(),
      );
    }

    if (events.isEmpty) {
      return EmptyState(
        icon: Icons.event_busy,
        title: emptyTitle,
        message: emptyMessage,
        buttonText: 'Book Event',
        onButtonPressed: () {
          context.push(AppRoutes.eventTypeSelection);
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return EventCard(
            event: event,
            onTap: () {
              if (event.status == 'ongoing') {
                context.push(
                  AppRoutes.liveEventTracking,
                  extra: {'eventId': event.eventId},
                );
              } else {
                context.push(
                  AppRoutes.eventDetails,
                  extra: {'eventId': event.eventId},
                );
              }
            },
          );
        },
      ),
    );
  }
}

