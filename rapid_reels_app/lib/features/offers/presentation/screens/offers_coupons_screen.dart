import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';

/// Offers & Coupons Screen
class OffersCouponsScreen extends ConsumerStatefulWidget {
  const OffersCouponsScreen({super.key});

  @override
  ConsumerState<OffersCouponsScreen> createState() => _OffersCouponsScreenState();
}

class _OffersCouponsScreenState extends ConsumerState<OffersCouponsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Offer> _activeOffers = [
    Offer(
      id: '1',
      code: 'RAPID20',
      title: '20% Off on All Events',
      description: 'Get flat 20% discount on your next event booking',
      discount: '20%',
      minAmount: 5000,
      maxDiscount: 2000,
      validTill: DateTime.now().add(const Duration(days: 7)),
      type: OfferType.percentage,
      category: 'All Events',
      termsAndConditions: [
        'Valid on minimum booking of ₹5,000',
        'Maximum discount of ₹2,000',
        'Cannot be combined with other offers',
        'Valid for first-time users only',
      ],
    ),
    Offer(
      id: '2',
      code: 'WEDDING500',
      title: '₹500 Off on Weddings',
      description: 'Special discount for wedding events',
      discount: '₹500',
      minAmount: 10000,
      maxDiscount: 500,
      validTill: DateTime.now().add(const Duration(days: 15)),
      type: OfferType.flat,
      category: 'Wedding',
      termsAndConditions: [
        'Valid on wedding bookings only',
        'Minimum booking amount ₹10,000',
        'One-time use per user',
      ],
    ),
    Offer(
      id: '3',
      code: 'FIRST100',
      title: 'First Booking Bonus',
      description: 'Get ₹100 cashback on your first booking',
      discount: '₹100',
      minAmount: 3000,
      maxDiscount: 100,
      validTill: DateTime.now().add(const Duration(days: 30)),
      type: OfferType.cashback,
      category: 'All Events',
      termsAndConditions: [
        'Valid for first booking only',
        'Cashback credited within 24 hours',
        'Minimum booking of ₹3,000',
      ],
    ),
  ];

  final List<Offer> _expiredOffers = [
    Offer(
      id: '4',
      code: 'NEWYEAR',
      title: 'New Year Special',
      description: 'Flat 30% off on all bookings',
      discount: '30%',
      minAmount: 5000,
      maxDiscount: 3000,
      validTill: DateTime.now().subtract(const Duration(days: 45)),
      type: OfferType.percentage,
      category: 'All Events',
      termsAndConditions: [],
    ),
    Offer(
      id: '5',
      code: 'BIRTHDAY50',
      title: 'Birthday Bash',
      description: '₹50 off on birthday events',
      discount: '₹50',
      minAmount: 2000,
      maxDiscount: 50,
      validTill: DateTime.now().subtract(const Duration(days: 10)),
      type: OfferType.flat,
      category: 'Birthday',
      termsAndConditions: [],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Offers & Coupons',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      _showOfferInfo();
                    },
                  ),
                ],
              ),
            ),

            // Apply Coupon Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_offer,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Have a coupon code?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Enter code to get discount',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _showApplyCouponDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Active'),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_activeOffers.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Tab(text: 'Expired'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOfferList(_activeOffers, true),
                  _buildOfferList(_expiredOffers, false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferList(List<Offer> offers, bool isActive) {
    if (offers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'No offers available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final offer = offers[index];
        return _buildOfferCard(offer, isActive);
      },
    );
  }

  Widget _buildOfferCard(Offer offer, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? _getOfferColor(offer.type).withOpacity(0.3)
              : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getOfferColor(offer.type).withOpacity(isActive ? 0.2 : 0.1),
                  _getOfferColor(offer.type).withOpacity(isActive ? 0.1 : 0.05),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getOfferColor(offer.type).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getOfferIcon(offer.type),
                    color: _getOfferColor(offer.type),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        offer.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Coupon Code
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _getOfferColor(offer.type).withOpacity(0.3),
                            style: BorderStyle.solid,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.confirmation_number,
                              size: 18,
                              color: _getOfferColor(offer.type),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              offer.code,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _getOfferColor(offer.type),
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (isActive)
                      ElevatedButton(
                        onPressed: () {
                          _copyCouponCode(offer.code);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getOfferColor(offer.type),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Copy'),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Details
                _buildDetailRow(
                  Icons.category,
                  'Category',
                  offer.category,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.shopping_bag,
                  'Min. Amount',
                  '₹${offer.minAmount}',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.discount,
                  'Max. Discount',
                  '₹${offer.maxDiscount}',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.calendar_today,
                  'Valid Till',
                  _formatDate(offer.validTill),
                  color: isActive ? Colors.green : Colors.red,
                ),

                if (isActive) ...[
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      _showTermsAndConditions(offer);
                    },
                    child: const Text('View Terms & Conditions'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Color _getOfferColor(OfferType type) {
    switch (type) {
      case OfferType.percentage:
        return Colors.blue;
      case OfferType.flat:
        return Colors.green;
      case OfferType.cashback:
        return Colors.orange;
    }
  }

  IconData _getOfferIcon(OfferType type) {
    switch (type) {
      case OfferType.percentage:
        return Icons.percent;
      case OfferType.flat:
        return Icons.currency_rupee;
      case OfferType.cashback:
        return Icons.account_balance_wallet;
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  void _copyCouponCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Coupon code "$code" copied!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showApplyCouponDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Apply Coupon'),
          content: TextField(
            decoration: InputDecoration(
              labelText: 'Enter Coupon Code',
              hintText: 'e.g., RAPID20',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Coupon applied successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  void _showTermsAndConditions(Offer offer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Terms & Conditions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    offer.code,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: offer.termsAndConditions.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  offer.termsAndConditions[index],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showOfferInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('How to Use Coupons'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1. Browse available offers'),
              SizedBox(height: 8),
              Text('2. Copy the coupon code'),
              SizedBox(height: 8),
              Text('3. Apply at checkout'),
              SizedBox(height: 8),
              Text('4. Enjoy your discount!'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }
}

enum OfferType {
  percentage,
  flat,
  cashback,
}

class Offer {
  final String id;
  final String code;
  final String title;
  final String description;
  final String discount;
  final double minAmount;
  final double maxDiscount;
  final DateTime validTill;
  final OfferType type;
  final String category;
  final List<String> termsAndConditions;

  Offer({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.discount,
    required this.minAmount,
    required this.maxDiscount,
    required this.validTill,
    required this.type,
    required this.category,
    required this.termsAndConditions,
  });
}

