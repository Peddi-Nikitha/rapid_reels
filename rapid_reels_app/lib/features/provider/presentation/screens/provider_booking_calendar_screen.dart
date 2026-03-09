import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../../features/booking/data/models/event_booking_model.dart';

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
  State<ProviderBookingCalendarScreen> createState() => _ProviderBookingCalendarScreenState();
}

class _ProviderBookingCalendarScreenState extends State<ProviderBookingCalendarScreen> {
  late ValueNotifier<List<EventBooking>> _selectedBookings;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  String? _selectedStatusFilter;

  @override
  void initState() {
    super.initState();
    _selectedBookings = ValueNotifier(_getBookingsForDay(_selectedDay));
  }

  @override
  void dispose() {
    _selectedBookings.dispose();
    super.dispose();
  }

  List<EventBooking> _getBookingsForDay(DateTime day) {
    final mockData = MockDataService();
    final allBookings = mockData.getProviderEvents(widget.providerId);
    
    var filteredBookings = allBookings.where((booking) {
      return isSameDay(booking.eventDate, day);
    }).toList();

    if (_selectedStatusFilter != null && _selectedStatusFilter!.isNotEmpty) {
      filteredBookings = filteredBookings.where((booking) {
        return booking.status == _selectedStatusFilter;
      }).toList();
    }

    return filteredBookings;
  }

  Map<DateTime, List<EventBooking>> _getBookingsMap() {
    final mockData = MockDataService();
    final allBookings = mockData.getProviderEvents(widget.providerId);
    
    Map<DateTime, List<EventBooking>> bookingsMap = {};
    
    for (var booking in allBookings) {
      final date = DateTime(
        booking.eventDate.year,
        booking.eventDate.month,
        booking.eventDate.day,
      );
      
      if (_selectedStatusFilter == null || _selectedStatusFilter!.isEmpty || booking.status == _selectedStatusFilter) {
        bookingsMap[date] = (bookingsMap[date] ?? [])..add(booking);
      }
    }
    
    return bookingsMap;
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
    final mockData = MockDataService();
    final bookingsMap = _getBookingsMap();

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
      body: Column(
        children: [
          // Status Filter Chips
          if (_selectedStatusFilter != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    backgroundColor: _getStatusColor(_selectedStatusFilter!).withValues(alpha: 0.2),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        _selectedStatusFilter = null;
                        _selectedBookings.value = _getBookingsForDay(_selectedDay);
                      });
                    },
                  ),
                ],
              ),
            ),

          // Calendar
          TableCalendar<EventBooking>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: (day) => bookingsMap[day] ?? [],
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: Colors.grey[600]),
              selectedDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: AppColors.primary,
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
              formatButtonTextStyle: const TextStyle(color: Colors.white),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _selectedBookings.value = _getBookingsForDay(selectedDay);
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
              markerBuilder: (context, date, bookings) {
                if (bookings.isEmpty) return const SizedBox.shrink();
                
                final statusColors = bookings.map((b) => _getStatusColor(b.status)).toSet();
                if (statusColors.length == 1) {
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColors.first,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                
                return Positioned(
                  bottom: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: statusColors.take(3).map((color) => Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    )).toList(),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Selected Day Bookings
          Expanded(
            child: ValueListenableBuilder<List<EventBooking>>(
              valueListenable: _selectedBookings,
              builder: (context, bookings, _) {
                if (bookings.isEmpty) {
                  return Center(
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
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return _buildBookingCard(booking);
                  },
                );
              },
            ),
          ),
        ],
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status).withValues(alpha: 0.2),
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
    final isSelected = _selectedStatusFilter == status;
    return ListTile(
      title: Text(label),
      leading: Radio<String?>(
        value: status,
        groupValue: _selectedStatusFilter,
        onChanged: (value) {
          setState(() {
            _selectedStatusFilter = value;
            _selectedBookings.value = _getBookingsForDay(_selectedDay);
          });
          Navigator.pop(context);
        },
      ),
    );
  }
}

