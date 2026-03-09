import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';

/// Offers & Promotions Screen - Shows available offers and coupons
class OffersScreen extends ConsumerStatefulWidget {
  const OffersScreen({super.key});

  @override
  ConsumerState<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends ConsumerState<OffersScreen> {
  final List<Map<String, dynamic>> _offers = [
    {
      'id': 'offer_001',
      'title': 'First Booking Offer',
      'description': 'Get 25% OFF on your first event booking',
      'code': 'FIRST25',
      'discount': '25% OFF',
      'minAmount': 10000,
      'maxDiscount': 5000,
      'validUntil': DateTime.now().add(const Duration(days: 30)),
      'isActive': true,
      'type': 'percentage',
      'imageUrl': 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800&q=80',
    },
    {
      'id': 'offer_002',
      'title': 'Wedding Special',
      'description': 'Flat ₹3000 OFF on wedding event bookings',
      'code': 'WEDDING3K',
      'discount': '₹3000 OFF',
      'minAmount': 20000,
      'maxDiscount': 3000,
      'validUntil': DateTime.now().add(const Duration(days: 45)),
      'isActive': true,
      'type': 'flat',
      'imageUrl': 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800&q=80',
    },
    {
      'id': 'offer_003',
      'title': 'Referral Bonus',
      'description': 'Get ₹100 for every successful referral',
      'code': 'REFER100',
      'discount': '₹100',
      'minAmount': 0,
      'maxDiscount': 100,
      'validUntil': DateTime.now().add(const Duration(days: 90)),
      'isActive': true,
      'type': 'referral',
      'imageUrl': 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&q=80',
    },
    {
      'id': 'offer_004',
      'title': 'Weekend Bonanza',
      'description': '20% OFF on all bookings made on weekends',
      'code': 'WEEKEND20',
      'discount': '20% OFF',
      'minAmount': 15000,
      'maxDiscount': 4000,
      'validUntil': DateTime.now().add(const Duration(days: 15)),
      'isActive': true,
      'type': 'percentage',
      'imageUrl': 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800&q=80',
    },
    {
      'id': 'offer_005',
      'title': 'Birthday Bash',
      'description': 'Special 30% discount on birthday event packages',
      'code': 'BDAY30',
      'discount': '30% OFF',
      'minAmount': 8000,
      'maxDiscount': 3000,
      'validUntil': DateTime.now().add(const Duration(days: 20)),
      'isActive': true,
      'type': 'percentage',
      'imageUrl': 'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=800&q=80',
    },
    {
      'id': 'offer_006',
      'title': 'Corporate Deal',
      'description': 'Flat ₹5000 OFF on corporate event bookings above ₹30K',
      'code': 'CORP5K',
      'discount': '₹5000 OFF',
      'minAmount': 30000,
      'maxDiscount': 5000,
      'validUntil': DateTime.now().add(const Duration(days: 60)),
      'isActive': true,
      'type': 'flat',
      'imageUrl': 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800&q=80',
    },
    {
      'id': 'offer_007',
      'title': 'Early Bird Special',
      'description': 'Book 30 days in advance and save 15%',
      'code': 'EARLY15',
      'discount': '15% OFF',
      'minAmount': 12000,
      'maxDiscount': 2500,
      'validUntil': DateTime.now().add(const Duration(days: 25)),
      'isActive': true,
      'type': 'percentage',
      'imageUrl': 'https://images.unsplash.com/photo-1511578314322-379afb476865?w=800&q=80',
    },
    {
      'id': 'offer_008',
      'title': 'Monsoon Offer',
      'description': 'Flat ₹2000 OFF on all bookings this month',
      'code': 'MONSOON2K',
      'discount': '₹2000 OFF',
      'minAmount': 15000,
      'maxDiscount': 2000,
      'validUntil': DateTime.now().subtract(const Duration(days: 5)),
      'isActive': false,
      'type': 'flat',
      'imageUrl': 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final activeOffers = _offers.where((o) => o['isActive'] == true).toList();
    final expiredOffers = _offers.where((o) => o['isActive'] == false).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Offers & Coupons',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              _showUsedOffersDialog();
            },
            tooltip: 'Used Offers',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Save Big!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${activeOffers.length} active offers available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.local_offer,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Active Offers
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Active Offers',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${activeOffers.length} Active',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Active Offers List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: activeOffers.length,
              itemBuilder: (context, index) {
                return _buildOfferCard(activeOffers[index]);
              },
            ),

            if (expiredOffers.isNotEmpty) ...[
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Expired Offers',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${expiredOffers.length} Expired',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: expiredOffers.length,
                itemBuilder: (context, index) {
                  return _buildOfferCard(expiredOffers[index]);
                },
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer) {
    final isActive = offer['isActive'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Network Image Background
            CachedNetworkImage(
              imageUrl: offer['imageUrl'] as String? ?? 
                  'https://images.unsplash.com/photo-1511578314322-379afb476865?w=800&q=80',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, url) => Container(
                decoration: BoxDecoration(
                  gradient: isActive
                      ? AppColors.primaryGradient
                      : const LinearGradient(
                          colors: [Color(0xFF616161), Color(0xFF757575)],
                        ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                decoration: BoxDecoration(
                  gradient: isActive
                      ? AppColors.primaryGradient
                      : const LinearGradient(
                          colors: [Color(0xFF616161), Color(0xFF757575)],
                        ),
                ),
                child: const Icon(Icons.error, color: Colors.white),
              ),
            ),
            // Dark Overlay for better text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withValues(alpha: isActive ? 0.3 : 0.6),
                    Colors.black.withValues(alpha: isActive ? 0.5 : 0.7),
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              offer['title'] as String,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              offer['description'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          offer['discount'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Coupon Code
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Coupon Code',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                offer['code'] as String,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isActive)
                          ElevatedButton(
                            onPressed: () {
                              _copyCode(offer['code'] as String);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Copy'),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Terms
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Min. booking ₹${offer['minAmount']} • Max discount ₹${offer['maxDiscount']}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isActive
                                ? 'Valid till ${_formatDate(offer['validUntil'] as DateTime)}'
                                : 'Expired',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                      if (isActive)
                        TextButton(
                          onPressed: () {
                            _showOfferDetails(offer);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isActive)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      'EXPIRED',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Coupon code "$code" copied!'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showOfferDetails(Map<String, dynamic> offer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textTertiary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    offer['title'] as String,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    offer['description'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Terms & Conditions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTermItem('Minimum booking amount: ₹${offer['minAmount']}'),
                  _buildTermItem('Maximum discount: ₹${offer['maxDiscount']}'),
                  _buildTermItem('Valid till ${_formatDate(offer['validUntil'] as DateTime)}'),
                  _buildTermItem('Applicable on ${_getOfferType(offer['type'] as String)}'),
                  _buildTermItem('Cannot be combined with other offers'),
                  _buildTermItem('Offer can be used once per user'),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _copyCode(offer['code'] as String);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Copy Code & Apply',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getOfferType(String type) {
    switch (type) {
      case 'percentage':
        return 'all event types';
      case 'flat':
        return 'specific event categories';
      case 'referral':
        return 'referral program';
      default:
        return 'selected bookings';
    }
  }

  void _showUsedOffersDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Used Offers'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildUsedOfferItem('FIRST25', '₹1,250', '15 Dec 2026'),
              _buildUsedOfferItem('REFER100', '₹100', '10 Dec 2026'),
              _buildUsedOfferItem('WEEKEND20', '₹800', '5 Dec 2026'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUsedOfferItem(String code, String saved, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                code,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Text(
            'Saved $saved',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

