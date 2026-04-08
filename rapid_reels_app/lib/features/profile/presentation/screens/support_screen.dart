import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/firebase/models/firebase_admin_model.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import 'package:uuid/uuid.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedCategory = 'Booking Issue';
  final _firestoreService = FirestoreService();
  final _uuid = const Uuid();

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Help & Support',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Help Cards
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Help',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickHelpCard(
                          icon: Icons.phone,
                          title: 'Call Us',
                          subtitle: '+44 7596 251678',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Opening dialer...')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickHelpCard(
                          icon: Icons.chat,
                          title: 'Live Chat',
                          subtitle: 'Available 24/7',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Starting chat...')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // FAQ Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFAQCard(
                    question: 'How do I book an event?',
                    answer:
                        'Go to Home > Select Event Type > Choose Package > Fill Details > Confirm Booking.',
                  ),
                  _buildFAQCard(
                    question: 'When will I receive my reels?',
                    answer:
                        'Reels are typically delivered within 24-48 hours after your event completion.',
                  ),
                  _buildFAQCard(
                    question: 'How do I cancel a booking?',
                    answer:
                        'Go to My Events > Select Event > Cancel Booking. Refund policy applies.',
                  ),
                  _buildFAQCard(
                    question: 'How does the referral program work?',
                    answer:
                        'Share your referral code. When friends book, both get £200 credits.',
                  ),
                ],
              ),
            ),
            
            // Contact Form
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Still need help?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fill out the form and we\'ll get back to you',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Booking Issue',
                            child: Text('Booking Issue'),
                          ),
                          DropdownMenuItem(
                            value: 'Payment Issue',
                            child: Text('Payment Issue'),
                          ),
                          DropdownMenuItem(
                            value: 'Reel Quality',
                            child: Text('Reel Quality'),
                          ),
                          DropdownMenuItem(
                            value: 'Provider Issue',
                            child: Text('Provider Issue'),
                          ),
                          DropdownMenuItem(
                            value: 'Other',
                            child: Text('Other'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedCategory = value!);
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      CustomTextField(
                        controller: _subjectController,
                        labelText: 'Subject',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a subject';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          labelText: 'Message',
                          hintText: 'Describe your issue in detail...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a message';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      CustomButton(
                        text: 'Submit Ticket',
                        onPressed: _submitTicket,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickHelpCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQCard({
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to submit a ticket.')),
      );
      return;
    }

    final subject = _subjectController.text.trim();
    final description = _messageController.text.trim();

    String type;
    switch (_selectedCategory) {
      case 'Booking Issue':
        type = 'booking_issue';
        break;
      case 'Payment Issue':
        type = 'payment_issue';
        break;
      case 'Reel Quality':
        type = 'technical';
        break;
      case 'Provider Issue':
        type = 'general';
        break;
      case 'Other':
      default:
        type = 'complaint';
    }

    final createdAt = DateTime.now();
    final message = SupportMessage(
      messageId: _uuid.v4(),
      senderId: user.uid,
      senderType: 'user',
      message: description,
      sentAt: createdAt,
      isRead: false,
    );

    final ticket = FirebaseSupportTicketModel(
      ticketId: _uuid.v4(),
      userId: user.uid,
      providerId: null,
      type: type,
      priority: 'medium',
      status: 'open',
      subject: subject,
      description: description,
      attachments: null,
      bookingId: null,
      messages: [message],
      assignedTo: null,
      createdAt: createdAt,
      resolvedAt: null,
      closedAt: null,
      metadata: null,
    );

    try {
      await _firestoreService.createSupportTicket(ticket);
      if (!mounted) return;

      _subjectController.clear();
      _messageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Support ticket submitted successfully!')),
      );
      // Optionally navigate to My Tickets in a later step.
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit ticket: $e')),
      );
    }
  }
}

