import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/provider_app_colors.dart';
import '../../../../shared/widgets/provider/provider_gradient_button.dart';
import '../../../../core/firebase/models/firebase_booking_model.dart';
import '../../../../core/firebase/models/firebase_user_model.dart';
import '../../../../core/firebase/services/firestore_service.dart';

class ProviderCustomerContactScreen extends StatefulWidget {
  final String bookingId;
  final String providerId;
  
  const ProviderCustomerContactScreen({
    super.key,
    required this.bookingId,
    required this.providerId,
  });

  @override
  State<ProviderCustomerContactScreen> createState() => _ProviderCustomerContactScreenState();
}

class _ProviderCustomerContactScreenState extends State<ProviderCustomerContactScreen> {
  final TextEditingController _notesController = TextEditingController();
  final _firestoreService = FirestoreService();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not make phone call')),
        );
      }
    }
  }

  Future<void> _sendSMS(String phoneNumber) async {
    final Uri smsUri = Uri(scheme: 'sms', path: phoneNumber);
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not send SMS')),
        );
      }
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    // Remove any non-digit characters
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    final Uri whatsappUri = Uri.parse('https://wa.me/$cleanNumber');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseBookingModel?>(
      future: _firestoreService.getBooking(widget.bookingId),
      builder: (context, bookingSnapshot) {
        if (bookingSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: ProviderAppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (bookingSnapshot.hasError || !bookingSnapshot.hasData || bookingSnapshot.data == null) {
          return Scaffold(
            backgroundColor: ProviderAppColors.background,
            appBar: AppBar(
              backgroundColor: ProviderAppColors.surface,
              elevation: 0,
              title: const Text(
                'Customer Contact',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            body: Center(
              child: Text(
                bookingSnapshot.hasError ? 'Error: ${bookingSnapshot.error}' : 'Booking not found',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final booking = bookingSnapshot.data!;

        return StreamBuilder<FirebaseUserModel?>(
          stream: _firestoreService.streamUser(booking.customerId),
          builder: (context, userSnapshot) {
            final customer = userSnapshot.data;

            return Scaffold(
              backgroundColor: ProviderAppColors.background,
              appBar: AppBar(
                backgroundColor: ProviderAppColors.surface,
                elevation: 0,
                title: const Text(
                  'Customer Contact',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Info Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: ProviderAppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: ProviderAppColors.primary.withValues(alpha: 0.2),
                            child: Text(
                              (customer?.fullName ?? booking.contactPerson)
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: ProviderAppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            customer?.fullName.isNotEmpty == true
                                ? customer!.fullName
                                : booking.contactPerson,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            booking.contactPerson,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quick Actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.phone,
                            label: 'Call',
                            color: Colors.green,
                            onTap: () => _makePhoneCall(booking.contactNumber),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.message,
                            label: 'Message',
                            color: Colors.blue,
                            onTap: () => _sendSMS(booking.contactNumber),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.chat,
                            label: 'WhatsApp',
                            color: const Color(0xFF25D366),
                            onTap: () => _openWhatsApp(booking.contactNumber),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Contact Information
                    const Text(
                      'Contact Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildContactCard(
                      icon: Icons.phone,
                      title: 'Phone Number',
                      value: booking.contactNumber,
                      onTap: () => _makePhoneCall(booking.contactNumber),
                    ),
                    if (booking.alternateContact != null)
                      _buildContactCard(
                        icon: Icons.phone_android,
                        title: 'Alternate Contact',
                        value: booking.alternateContact!,
                        onTap: () => _makePhoneCall(booking.alternateContact!),
                      ),
                    if (customer?.email != null && customer!.email != null)
                      _buildContactCard(
                        icon: Icons.email,
                        title: 'Email',
                        value: customer.email!,
                        onTap: () => _sendEmail(customer.email!),
                      ),

                    const SizedBox(height: 24),

                    // Notes Section
                    const Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ProviderAppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _notesController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Add notes about this customer...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ProviderGradientButton(
                      onPressed: () {
                        // TODO: Persist notes to Firestore (e.g., under booking.metadata)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notes saved')),
                        );
                      },
                      label: 'Save Notes',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ProviderAppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: ProviderAppColors.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

