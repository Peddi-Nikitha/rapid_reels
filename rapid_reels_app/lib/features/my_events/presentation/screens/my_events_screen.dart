import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/event_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../booking/data/models/event_booking_model.dart';
import '../../../booking/presentation/providers/booking_provider.dart';

class MyEventsScreen extends ConsumerStatefulWidget {
  const MyEventsScreen({super.key});

  @override
  ConsumerState<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends ConsumerState<MyEventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final userId = currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'My Events',
        showBackButton: false,
      ),
      body: Column(
        children: [
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
          Expanded(
            child: userId.isEmpty
                ? const Center(child: Text('Please login to view events'))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _eventsListFromProvider(
                        ref.watch(userUpcomingBookingsProvider(userId)),
                        emptyTitle: 'No upcoming events',
                        emptyMessage: 'Book your first event to get started',
                      ),
                      _eventsListFromProvider(
                        ref.watch(userBookingsProvider(userId)),
                        filter: (e) => e.status == 'ongoing',
                        emptyTitle: 'No live events',
                        emptyMessage: 'Your ongoing events will appear here',
                      ),
                      _eventsListFromProvider(
                        ref.watch(userPastBookingsProvider(userId)),
                        emptyTitle: 'No past events',
                        emptyMessage: 'Your completed events will appear here',
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

  Widget _eventsListFromProvider(
    AsyncValue<List<EventBooking>> eventsAsync, {
    bool Function(EventBooking e)? filter,
    required String emptyTitle,
    required String emptyMessage,
  }) {
    return eventsAsync.when(
      data: (events) {
        final list = filter == null ? events : events.where(filter).toList();
        if (list.isEmpty) {
          return EmptyState(
            icon: Icons.event_busy,
            title: emptyTitle,
            message: emptyMessage,
            buttonText: 'Book Event',
            onButtonPressed: () {
              // ignore: use_build_context_synchronously
              context.push(AppRoutes.eventTypeSelection);
            },
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final event = list[index];
            return EventCard(
              event: event,
              onTap: () {
                context.push('${AppRoutes.eventDetails2}/${event.eventId}');
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => EmptyState(
        icon: Icons.error_outline,
        title: 'Error',
        message: 'Could not load events',
      ),
    );
  }
}

