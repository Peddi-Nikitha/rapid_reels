import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/booking/date_availability.dart';
import '../../../core/firebase/models/firebase_provider_model.dart';
import '../../../features/booking/data/models/event_booking_model.dart';

/// Same-day check for calendar selection (normalized local dates).
bool providerCalendarIsSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Month [TableCalendar] used on the provider schedule / booking calendar.
/// Keeps layout and styling in one place.
class ProviderMonthCalendar extends StatelessWidget {
  const ProviderMonthCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.bookingsMap,
    required this.provider,
    required this.occupiedDateKeys,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final CalendarFormat calendarFormat;
  final Map<DateTime, List<EventBooking>> bookingsMap;
  final FirebaseProviderModel? provider;
  /// Date keys (`yyyy-MM-dd`) where the provider has a blocking booking.
  final Set<String> occupiedDateKeys;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final ValueChanged<CalendarFormat> onFormatChanged;
  final ValueChanged<DateTime> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;

    return TableCalendar<EventBooking>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: focusedDay,
      calendarFormat: calendarFormat,
      selectedDayPredicate: (day) => providerCalendarIsSameDay(selectedDay, day),
      eventLoader: (day) => bookingsMap[day] ?? [],
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendTextStyle: TextStyle(color: theme.dividerColor),
        defaultTextStyle: TextStyle(color: onSurface),
        selectedDecoration: BoxDecoration(
          color: primary,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: primary.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF4ADE80)
              : Colors.green,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 3,
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: true,
        formatButtonShowsNext: false,
        formatButtonDecoration: BoxDecoration(
          color: primary,
          borderRadius: BorderRadius.circular(8),
        ),
        formatButtonTextStyle: const TextStyle(color: Colors.white),
      ),
      enabledDayPredicate: (day) {
        if (provider == null) return true;
        final dayKey = DateTime(day.year, day.month, day.day);
        final dayBookings = bookingsMap[dayKey] ?? [];
        final open = isDateAvailableForProvider(
              provider!,
              day,
              occupiedDateKeys,
            ) ||
            dayBookings.isNotEmpty;
        return open;
      },
      onDaySelected: onDaySelected,
      onFormatChanged: onFormatChanged,
      onPageChanged: onPageChanged,
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, date, _) {
          if (provider == null) return null;
          final dayKey = DateTime(date.year, date.month, date.day);
          final hasBooking = (bookingsMap[dayKey] ?? []).isNotEmpty;
          final unavailable = !isDateAvailableForProvider(
                provider!,
                date,
                occupiedDateKeys,
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
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF4ADE80)
                    : Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }
}
