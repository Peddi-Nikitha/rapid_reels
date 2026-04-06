import 'package:flutter/material.dart';
import '../../../../core/theme/provider_app_colors.dart';
import 'provider_availability_calendar_screen.dart';
import 'provider_booking_calendar_screen.dart';

/// Unified schedule: event calendar + availability editor.
class ProviderScheduleScreen extends StatefulWidget {
  const ProviderScheduleScreen({super.key, required this.providerId});

  final String providerId;

  @override
  State<ProviderScheduleScreen> createState() => _ProviderScheduleScreenState();
}

class _ProviderScheduleScreenState extends State<ProviderScheduleScreen> {
  int _segment = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Schedule'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  label: Text('Events'),
                  icon: Icon(Icons.event_outlined, size: 18),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text('Availability'),
                  icon: Icon(Icons.schedule_outlined, size: 18),
                ),
              ],
              selected: {_segment},
              onSelectionChanged: (s) {
                setState(() => _segment = s.first);
              },
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return ProviderAppColors.onPrimary;
                  }
                  return ProviderAppColors.textSecondary;
                }),
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return ProviderAppColors.primary;
                  }
                  return ProviderAppColors.surface;
                }),
              ),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _segment,
              children: [
                ProviderBookingCalendarScreen(
                  providerId: widget.providerId,
                  embedded: true,
                ),
                const ProviderAvailabilityCalendarScreen(embedded: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
