import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';

/// Help & Support Screen - FAQ and contact options
class HelpSupportScreen extends ConsumerStatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  ConsumerState<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends ConsumerState<HelpSupportScreen> {
  final List<Map<String, dynamic>> _faqCategories = [
    {
      'title': 'Booking & Events',
      'icon': Icons.event,
      'color': AppColors.primary,
      'faqs': [
        {
          'question': 'How do I book an event?',
          'answer':
              'To book an event, tap on "Book Now" from the home screen, select your event type, choose a package, fill in event details, select venue and provider, customize your package, and proceed to payment.',
        },
        {
          'question': 'Can I reschedule my event?',
          'answer':
              'Yes, you can reschedule your event up to 48 hours before the scheduled time. Go to "My Events", select your booking, and tap "Reschedule". Note that rescheduling may be subject to provider availability.',
        },
        {
          'question': 'What happens if I cancel my booking?',
          'answer':
              'Cancellation policy varies based on timing:\n• 7+ days before: 90% refund\n• 3-7 days before: 50% refund\n• Less than 3 days: No refund\nAdvance payment is non-refundable.',
        },
        {
          'question': 'How long does it take to get my reels?',
          'answer':
              'Delivery time depends on your package:\n• Instant: Within 2 hours\n• Same Day: Within 24 hours\n• Next Day: Within 48 hours\nYou\'ll receive a notification when your reels are ready.',
        },
      ],
    },
    {
      'title': 'Payments & Refunds',
      'icon': Icons.payment,
      'color': Colors.green,
      'faqs': [
        {
          'question': 'What payment methods are accepted?',
          'answer':
              'We accept multiple payment methods:\n• UPI (Google Pay, PhonePe, Paytm)\n• Credit/Debit Cards\n• Net Banking\n• Digital Wallets\n• Rapid Reels Wallet',
        },
        {
          'question': 'Is advance payment mandatory?',
          'answer':
              'Yes, a 50% advance payment is required to confirm your booking. The remaining amount can be paid before or on the event day.',
        },
        {
          'question': 'How do refunds work?',
          'answer':
              'Refunds are processed within 5-7 business days to your original payment method. The amount depends on our cancellation policy. Wallet refunds are instant.',
        },
        {
          'question': 'Can I use multiple offers together?',
          'answer':
              'No, only one offer/coupon code can be applied per booking. Choose the offer that gives you maximum savings.',
        },
      ],
    },
    {
      'title': 'Reels & Content',
      'icon': Icons.video_library,
      'color': Colors.purple,
      'faqs': [
        {
          'question': 'How many reels will I receive?',
          'answer':
              'The number of reels depends on your package:\n• Bronze: 3-5 reels\n• Silver: 6-10 reels\n• Gold: 11-15 reels\n• Platinum: 16-20 reels\nAll reels are professionally edited.',
        },
        {
          'question': 'Can I download my reels?',
          'answer':
              'Yes! All your reels are available for download in HD quality. Go to "My Reels", select a reel, and tap the download button. Downloaded reels are saved to your device gallery.',
        },
        {
          'question': 'Can I request edits to my reels?',
          'answer':
              'Yes, you can request one free revision within 24 hours of receiving your reels. Additional revisions may incur extra charges.',
        },
        {
          'question': 'How long are reels stored?',
          'answer':
              'Your reels are stored permanently in your account. You can access and download them anytime. We recommend downloading important reels for backup.',
        },
      ],
    },
    {
      'title': 'Referral & Wallet',
      'icon': Icons.card_giftcard,
      'color': Colors.amber,
      'faqs': [
        {
          'question': 'How does the referral program work?',
          'answer':
              'Share your unique referral code with friends. When they sign up and make their first booking, you both get ₹100 in your wallet. There\'s no limit to how many friends you can refer!',
        },
        {
          'question': 'How can I use my wallet balance?',
          'answer':
              'Your wallet balance can be used to pay for bookings, either partially or fully. During checkout, select "Use Wallet" to apply your balance.',
        },
        {
          'question': 'Can I withdraw wallet money?',
          'answer':
              'Wallet balance cannot be withdrawn as cash. It can only be used for bookings on Rapid Reels. Refunds are credited back to your wallet or original payment method.',
        },
        {
          'question': 'Do wallet credits expire?',
          'answer':
              'No, wallet credits never expire. You can use them anytime for any booking.',
        },
      ],
    },
    {
      'title': 'Account & Privacy',
      'icon': Icons.security,
      'color': Colors.blue,
      'faqs': [
        {
          'question': 'How do I update my profile?',
          'answer':
              'Go to Profile > Edit Profile. You can update your name, email, phone number, and profile picture. Changes are saved automatically.',
        },
        {
          'question': 'Is my payment information secure?',
          'answer':
              'Yes, all payment information is encrypted and processed through secure payment gateways. We never store your complete card details.',
        },
        {
          'question': 'How do I delete my account?',
          'answer':
              'To delete your account, go to Settings > Account > Delete Account. Note that this action is irreversible and all your data will be permanently deleted.',
        },
        {
          'question': 'Who can see my reels?',
          'answer':
              'Your reels are private by default. Only you can view them. You can choose to share specific reels publicly or with specific people.',
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Help & Support',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Contact Options
            Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&q=80',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                      placeholder: (context, url) => Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                        ),
                        child: const Icon(Icons.error, color: Colors.white),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.black.withValues(alpha: 0.4),
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            'Need Immediate Help?',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Our support team is available 24/7',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildContactButton(
                                  'Call Us',
                                  Icons.phone,
                                  () => _makePhoneCall(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildContactButton(
                                  'WhatsApp',
                                  Icons.chat,
                                  () => _openWhatsApp(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildContactButton(
                                  'Email',
                                  Icons.email,
                                  () => _sendEmail(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildContactButton(
                                  'Live Chat',
                                  Icons.support_agent,
                                  () => _openLiveChat(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // FAQ Categories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _faqCategories.length,
                    itemBuilder: (context, index) {
                      return _buildFAQCategory(_faqCategories[index]);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton(String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQCategory(Map<String, dynamic> category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (category['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            category['icon'] as IconData,
            color: category['color'] as Color,
            size: 24,
          ),
        ),
        title: Text(
          category['title'] as String,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          '${(category['faqs'] as List).length} questions',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: (category['faqs'] as List).length,
            itemBuilder: (context, index) {
              final faq = (category['faqs'] as List)[index];
              return _buildFAQItem(faq);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(Map<String, dynamic> faq) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          faq['question'] as String,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              faq['answer'] as String,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+919876543210');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _showMessage('Unable to make phone call');
    }
  }

  Future<void> _openWhatsApp() async {
    final Uri whatsappUri = Uri.parse('https://wa.me/919876543210');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      _showMessage('WhatsApp not installed');
    }
  }

  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@rapidreels.com',
      query: 'subject=Support Request',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showMessage('Unable to open email client');
    }
  }

  void _openLiveChat() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Live Chat',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.support_agent,
                        size: 80,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Chat Feature',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Live chat will be available soon!\nFor now, please use other contact methods.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

