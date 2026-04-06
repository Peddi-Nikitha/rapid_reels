import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/booking/date_availability.dart';
import '../../../../core/theme/provider_app_colors.dart';
import '../../../../core/firebase/models/firebase_booking_model.dart';
import '../../../../core/firebase/models/firebase_provider_model.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../booking/data/adapters/booking_firebase_mappers.dart';
import '../../../booking/data/models/event_booking_model.dart';
import '../../../../shared/widgets/provider/provider_day_agenda_bottom_sheet.dart';
import '../../../../shared/widgets/provider/provider_month_calendar.dart';
import 'provider_booking_details_screen.dart';

class ProviderBookingCalendarScreen extends StatefulWidget {
  final String providerId;

  /// When true, no [Scaffold] / AppBar — for embedding in [ProviderScheduleScreen].
  final bool embedded;

  const ProviderBookingCalendarScreen({
    super.key,
    required this.providerId,
    this.embedded = false,
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
    var filtered =
        all.where((b) => providerCalendarIsSameDay(b.eventDate, day)).toList();
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
    final body = _buildCalendarBody(context);
    if (widget.embedded) {
      return ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: body,
      );
    }
    return Scaffold(
      backgroundColor: ProviderAppColors.background,
      appBar: AppBar(
        backgroundColor: ProviderAppColors.background,
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
      body: body,
    );
  }

  Widget _buildCalendarBody(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;

    return StreamBuilder<FirebaseProviderModel?>(
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
                  if (widget.embedded)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.filter_list),
                            onPressed: _showFilterDialog,
                          ),
                        ],
                      ),
                    ),
                  if (_selectedStatusFilter != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      color: surface,
                      child: Row(
                        children: [
                          Text(
                            'Filter: ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: theme.hintColor,
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
                  ProviderMonthCalendar(
                    focusedDay: _focusedDay,
                    selectedDay: _selectedDay,
                    calendarFormat: _calendarFormat,
                    bookingsMap: bookingsMap,
                    provider: provider,
                    occupiedDateKeys: occupied,
                    onDaySelected: (selectedDay, focusedDay) {
                      if (!providerCalendarIsSameDay(_selectedDay, selectedDay)) {
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
                  ),
                  const Divider(height: 1),
                  if (bookingsForDay.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            final day = DateTime(
                              _selectedDay.year,
                              _selectedDay.month,
                              _selectedDay.day,
                            );
                            showProviderDayAgendaBottomSheet(
                              context: context,
                              day: day,
                              bookings: bookingsForDay,
                              providerId: widget.providerId,
                            );
                          },
                          icon: const Icon(Icons.view_agenda_outlined, size: 20),
                          label: const Text('Day agenda'),
                        ),
                      ),
                    ),
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
    );
  }

  Widget _buildBookingCard(EventBooking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ProviderAppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(booking.status).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (ctx) => Theme(
                data: Theme.of(context),
                child: ProviderBookingDetailsScreen(
                  bookingId: booking.eventId,
                  providerId: widget.providerId,
                ),
              ),
            ),
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
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filter by Status'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip(dialogContext, 'All', null),
              _buildFilterChip(dialogContext, 'Pending', 'pending'),
              _buildFilterChip(dialogContext, 'Confirmed', 'confirmed'),
              _buildFilterChip(dialogContext, 'Ongoing', 'ongoing'),
              _buildFilterChip(dialogContext, 'Completed', 'completed'),
              _buildFilterChip(dialogContext, 'Cancelled', 'cancelled'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext dialogContext,
    String label,
    String? status,
  ) {
    final selected = status == null
        ? _selectedStatusFilter == null
        : _selectedStatusFilter == status;
    return FilterChip(
      showCheckmark: false,
      selected: selected,
      label: Text(label),
      onSelected: (_) {
        setState(() => _selectedStatusFilter = status);
        Navigator.pop(dialogContext);
      },
    );
  }
}
