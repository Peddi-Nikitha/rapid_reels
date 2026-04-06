import 'package:flutter/material.dart';
import '../../../features/booking/data/models/event_booking_model.dart';
import '../../../features/provider/presentation/screens/provider_booking_details_screen.dart';

/// Full-height draggable sheet listing bookings for a single day (reference: plan “DayAgendaBottomSheet”).
Future<void> showProviderDayAgendaBottomSheet({
  required BuildContext context,
  required DateTime day,
  required List<EventBooking> bookings,
  required String providerId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.45,
        minChildSize: 0.25,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text(
                  'Events · ${day.day}/${day.month}/${day.year}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: bookings.isEmpty
                    ? Center(
                        child: Text(
                          'No bookings this day',
                          style: TextStyle(color: Theme.of(context).hintColor),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: bookings.length,
                        itemBuilder: (context, i) {
                          final b = bookings[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              title: Text(b.eventName),
                              subtitle: Text(
                                '${b.eventTime} · ${b.status.toUpperCase()}',
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.of(context).push<void>(
                                  MaterialPageRoute<void>(
                                    builder: (_) => Theme(
                                      data: Theme.of(context),
                                      child: ProviderBookingDetailsScreen(
                                        bookingId: b.eventId,
                                        providerId: providerId,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
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
