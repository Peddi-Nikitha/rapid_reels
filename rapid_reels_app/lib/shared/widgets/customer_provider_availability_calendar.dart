import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/booking/date_availability.dart';
import '../../core/constants/app_colors.dart';
import '../../core/firebase/models/firebase_booking_model.dart';
import '../../core/firebase/models/firebase_provider_model.dart';
import '../../core/firebase/services/firestore_service.dart';

bool sameCalendarDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Calendar for customers: selectable only on days the provider has open, not blocked, and not booked.
class CustomerProviderAvailabilityPanel extends StatelessWidget {
  final String providerId;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const CustomerProviderAvailabilityPanel({
    super.key,
    required this.providerId,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    return StreamBuilder<FirebaseProviderModel?>(
      stream: firestore.streamProviderDoc(providerId),
      builder: (context, pSnap) {
        if (pSnap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final provider = pSnap.data;
        if (provider == null) {
          return const Text('Could not load provider availability.');
        }
        return StreamBuilder<List<FirebaseBookingModel>>(
          stream: firestore.streamProviderBookings(providerId),
          builder: (context, bSnap) {
            final occupied = <String>{};
            for (final b in bSnap.data ?? []) {
              if (bookingStatusBlocksDay(b.status)) {
                occupied.add(b.eventDateKey);
              }
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _LegendRow(),
                const SizedBox(height: 12),
                _CustomerAvailabilityCalendarInner(
                  provider: provider,
                  occupiedDateKeys: occupied,
                  selectedDate: selectedDate,
                  onDateSelected: onDateSelected,
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _LegendRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(fontSize: 11, color: Colors.grey[700]!);
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        _legendDot(AppColors.primary, 'Available', textStyle),
        _legendDot(Colors.grey, 'Unavailable', textStyle),
      ],
    );
  }

  Widget _legendDot(Color c, String label, TextStyle textStyle) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: textStyle),
      ],
    );
  }
}

class _CustomerAvailabilityCalendarInner extends StatefulWidget {
  final FirebaseProviderModel provider;
  final Set<String> occupiedDateKeys;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _CustomerAvailabilityCalendarInner({
    required this.provider,
    required this.occupiedDateKeys,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<_CustomerAvailabilityCalendarInner> createState() =>
      _CustomerAvailabilityCalendarInnerState();
}

class _CustomerAvailabilityCalendarInnerState
    extends State<_CustomerAvailabilityCalendarInner> {
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDate;
  }

  @override
  void didUpdateWidget(covariant _CustomerAvailabilityCalendarInner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!sameCalendarDay(oldWidget.selectedDate, widget.selectedDate)) {
      _focusedDay = widget.selectedDate;
    }
  }

  bool _selectable(DateTime day) {
    return isDateAvailableForProvider(
      widget.provider,
      day,
      widget.occupiedDateKeys,
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = dateOnlyLocal(DateTime.now());
    return TableCalendar<void>(
      firstDay: today,
      lastDay: today.add(const Duration(days: 550)),
      focusedDay: _focusedDay,
      selectedDayPredicate: (d) => sameCalendarDay(d, widget.selectedDate),
      enabledDayPredicate: _selectable,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        disabledTextStyle: TextStyle(color: Colors.grey[600]),
        weekendTextStyle: TextStyle(color: Colors.grey[800]),
        selectedDecoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      onDaySelected: (selected, focused) {
        if (!_selectable(selected)) return;
        widget.onDateSelected(dateOnlyLocal(selected));
        setState(() => _focusedDay = focused);
      },
      onPageChanged: (focused) {
        setState(() => _focusedDay = focused);
      },
    );
  }
}

/// Picks a new event date; returns `null` if cancelled.
Future<DateTime?> showPickAvailableBookingDateDialog({
  required BuildContext context,
  required String providerId,
  required DateTime initialDate,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (ctx) {
      DateTime selected = dateOnlyLocal(initialDate);
      return StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Choose an available date'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 320,
                child: CustomerProviderAvailabilityPanel(
                  providerId: providerId,
                  selectedDate: selected,
                  onDateSelected: (d) {
                    setDialogState(() => selected = d);
                    Navigator.pop(ctx, d);
                  },
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    },
  );
}
