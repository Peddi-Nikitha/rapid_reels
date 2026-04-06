import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/provider_app_colors.dart';
import '../../../../shared/widgets/provider/provider_gradient_button.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/firebase/models/firebase_booking_model.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../booking/data/adapters/booking_firebase_mappers.dart';
import '../../../booking/data/models/event_booking_model.dart';

class ProviderVenueNavigationScreen extends StatelessWidget {
  final String bookingId;
  final String providerId;

  const ProviderVenueNavigationScreen({
    super.key,
    required this.bookingId,
    required this.providerId,
  });

  Future<void> _openMaps(EventBooking booking) async {
    final address = booking.venue.address;
    final encodedAddress = Uri.encodeComponent(address);

    final googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encodedAddress');

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      final fallbackUrl = Uri.parse('https://maps.google.com/?q=$encodedAddress');
      if (await canLaunchUrl(fallbackUrl)) {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      }
    }
  }

  Future<void> _shareAddress(EventBooking booking) async {
    final text =
        '${booking.eventName}\n${booking.venue.address}, ${booking.venue.city} ${booking.venue.pincode}';
    await Share.share(text);
  }

  Future<void> _copyAddress(BuildContext context, EventBooking booking) async {
    final text =
        '${booking.venue.address}, ${booking.venue.city} ${booking.venue.pincode}';
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address copied')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    return FutureBuilder<FirebaseBookingModel?>(
      future: firestore.getBooking(bookingId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: ProviderAppColors.background,
            appBar: AppBar(
              backgroundColor: ProviderAppColors.background,
              elevation: 0,
              title: const Text(
                'Venue Navigation',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return Scaffold(
            backgroundColor: ProviderAppColors.background,
            appBar: AppBar(
              backgroundColor: ProviderAppColors.background,
              title: const Text('Venue Navigation'),
            ),
            body: Center(child: Text('${snap.error}')),
          );
        }
        final raw = snap.data;
        if (raw == null || raw.providerId != providerId) {
          return Scaffold(
            backgroundColor: ProviderAppColors.background,
            appBar: AppBar(
              backgroundColor: ProviderAppColors.background,
              title: const Text('Venue Navigation'),
            ),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Booking not found or you do not have access.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final booking = BookingFirebaseMappers.toEventBooking(raw);

        return Scaffold(
          backgroundColor: ProviderAppColors.background,
          appBar: AppBar(
            backgroundColor: ProviderAppColors.background,
            elevation: 0,
            title: Text(
              'Venue Navigation',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ProviderAppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ProviderAppColors.outline.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.eventName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(booking.eventDate),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.access_time,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            booking.eventTime,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.map,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Map preview',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Open directions for live routing',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.my_location,
                            color: ProviderAppColors.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Venue Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ProviderAppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ProviderAppColors.outline.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: [
                      _buildVenueInfoItem(
                        icon: Icons.location_on,
                        label: 'Address',
                        value: booking.venue.address,
                      ),
                      const Divider(height: 24),
                      _buildVenueInfoItem(
                        icon: Icons.location_city,
                        label: 'City',
                        value: booking.venue.city,
                      ),
                      const Divider(height: 24),
                      _buildVenueInfoItem(
                        icon: Icons.pin_drop,
                        label: 'Pincode',
                        value: booking.venue.pincode,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ProviderGradientButton(
                  onPressed: () => _openMaps(booking),
                  icon: const Icon(Icons.directions),
                  label: 'Get Directions',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _copyAddress(context, booking),
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy address'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ProviderAppColors.primary,
                          side: const BorderSide(color: ProviderAppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _shareAddress(booking),
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ProviderAppColors.primary,
                          side: const BorderSide(color: ProviderAppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ProviderAppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ProviderAppColors.outline.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: ProviderAppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Travel',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: ProviderAppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Distance and ETA depend on your location. Use Get Directions '
                        'in Google Maps for accurate routing and live traffic.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: ProviderAppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVenueInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: ProviderAppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }
}
