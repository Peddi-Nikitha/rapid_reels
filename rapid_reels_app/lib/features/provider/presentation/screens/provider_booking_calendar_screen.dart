import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/booking/date_availability.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/firebase/models/firebase_booking_model.dart';
import '../../../../core/firebase/models/firebase_provider_model.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../booking/data/adapters/booking_firebase_mappers.dart';
import '../../../booking/data/models/event_booking_model.dart';

bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class ProviderBookingCalendarScreen extends StatefulWidget {
  final String providerId;

  const ProviderBookingCalendarScreen({
    super.key,
    required this.providerId,
  });

  @override
  State<ProviderBookingCalendarScreen> createState() =>
      _ProviderBookingCalendarScreenState();
}

class _ProviderBookingCalendarScreenState
    extends State<ProviderBookingCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  String? _selectedStatusFilter;
  final _firestore = FirestoreService();

  List<EventBooking> _filteredBookings(
    List<EventBooking> all,
    DateTime day,
  ) {
    var filtered = all.where((b) => isSameDay(b.eventDate, day)).toList();
    if (_selectedStatusFilter != null &&
        _selectedStatusFilter!.isNotEmpty) {
      filtered = filtered
          .where((b) => b.status == _selectedStatusFilter)
          .toList();
    }
    return filtered;
  }

  Map<DateTime, List<EventBooking>> _bookingsMap(List<EventBooking> all) {
    final map = <DateTime, List<EventBooking>>{};
    for (var booking in all) {
      final date = DateTime(
        booking.eventDate.year,
        booking.eventDate.month,
        booking.eventDate.day,
      );
      if (_selectedStatusFilter == null ||
          _selectedStatusFilter!.isEmpty ||
          booking.status == _selectedStatusFilter) {
        map[date] = (map[date] ?? [])..add(booking);
      }
    }
    return map;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'ongoing':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Booking Calendar',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: StreamBuilder<FirebaseProviderModel?>(
        stream: _firestore.streamProviderDoc(widget.providerId),
        builder: (context, provSnap) {
          return StreamBuilder<List<FirebaseBookingModel>>(
            stream: _firestore.streamProviderBookings(widget.providerId),
            builder: (context, bookSnap) {
              final provider = provSnap.data;
              final raw = bookSnap.data ?? [];
              final all = raw.map(BookingFirebaseMappers.toEventBooking).toList();
              final occupied = <String>{};
              for (final b in raw) {
                if (bookingStatusBlocksDay(b.status)) {
                  occupied.add(b.eventDateKey);
                }
              }
              final bookingsMap = _bookingsMap(all);
              final bookingsForDay = _filteredBookings(all, _selectedDay);

              return Column(
                children: [
                  if (_selectedStatusFilter != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      color: AppColors.surface,
                      child: Row(
                        children: [
                          Text(
                            'Filter: ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          Chip(
                            label: Text(_selectedStatusFilter!.toUpperCase()),
                            backgroundColor: _getStatusColor(
                                    _selectedStatusFilter!)
                                .withValues(alpha: 0.2),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () {
                              setState(() => _selectedStatusFilter = null);
                            },
                          ),
                        ],
                      ),
                    ),
                  TableCalendar<EventBooking>(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) =>
                        isSameDay(_selectedDay, day),
                    eventLoader: (day) => bookingsMap[day] ?? [],
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      weekendTextStyle: TextStyle(color: Colors.grey[600]),
                      selectedDecoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      /// Green dots: any booking on that day (status-agnostic).
                      markerDecoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      markersMaxCount: 3,
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: true,
                      formatButtonShowsNext: false,
                      formatButtonDecoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      formatButtonTextStyle:
                          const TextStyle(color: Colors.white),
                    ),
                    enabledDayPredicate: (day) {
                      if (provider == null) return true;
                      final dayKey =
                          DateTime(day.year, day.month, day.day);
                      final dayBookings = bookingsMap[dayKey] ?? [];
                      final open = isDateAvailableForProvider(
                            provider,
                            day,
                            occupied,
                          ) ||
                          dayBookings.isNotEmpty;
                      return open;
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      if (!isSameDay(_selectedDay, selectedDay)) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      }
                    },
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, date, _) {
                        if (provider == null) return null;
                        final dayKey =
                            DateTime(date.year, date.month, date.day);
                        final hasBooking =
                            (bookingsMap[dayKey] ?? []).isNotEmpty;
                        final unavailable = !isDateAvailableForProvider(
                              provider,
                              date,
                              occupied,
                            ) &&
                            !hasBooking;
                        if (!unavailable) return null;
                        return Center(
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                          ),
                        );
                      },
                      markerBuilder: (context, date, bookings) {
                        if (bookings.isEmpty) return const SizedBox.shrink();
                        return Positioned(
                          bottom: 1,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: bookingsForDay.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.event_busy,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No bookings for this day',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: bookingsForDay.length,
                            itemBuilder: (context, index) {
                              final booking = bookingsForDay[index];
                              return _buildBookingCard(booking);
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(EventBooking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(booking.status).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          context.push(
            '${AppRoutes.providerBookings}/details',
            extra: {
              'bookingId': booking.eventId,
              'providerId': widget.providerId,
            },
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        _getStatusColor(booking.status).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(booking.status),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  booking.eventTime,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              booking.eventName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              booking.eventType.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    booking.venue.address,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption('All', null),
            _buildFilterOption('Pending', 'pending'),
            _buildFilterOption('Confirmed', 'confirmed'),
            _buildFilterOption('Ongoing', 'ongoing'),
            _buildFilterOption('Completed', 'completed'),
            _buildFilterOption('Cancelled', 'cancelled'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, String? status) {
    return ListTile(
      title: Text(label),
      leading: Radio<String?>(
        value: status,
        groupValue: _selectedStatusFilter,
        onChanged: (value) {
          setState(() => _selectedStatusFilter = value);
          Navigator.pop(context);
        },
      ),
    );
  }
}
