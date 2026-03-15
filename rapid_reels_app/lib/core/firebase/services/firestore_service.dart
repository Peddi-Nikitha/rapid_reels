import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/firebase_user_model.dart';
import '../models/firebase_provider_model.dart';
import '../models/firebase_booking_model.dart';
import '../models/firebase_reel_model.dart';
import '../models/firebase_review_model.dart';
import '../models/firebase_referral_model.dart';
import '../models/firebase_wallet_model.dart';
import '../models/firebase_notification_model.dart';
import '../models/firebase_offer_model.dart';
import '../models/firebase_live_event_model.dart';
import '../models/firebase_admin_model.dart';

/// Comprehensive Firestore Service
/// Handles all database operations for Rapid Reels
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== USERS ====================

  /// Get user by ID
  Future<FirebaseUserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return FirebaseUserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting user: $e');
    }
  }

  /// Create or update user
  Future<void> setUser(FirebaseUserModel user) async {
    try {
      await _firestore.collection('users').doc(user.userId).set(user.toFirestore());
    } catch (e) {
      // Provide more detailed error information
      if (e.toString().contains('PERMISSION_DENIED')) {
        throw Exception(
          'Permission denied: Firestore security rules are blocking this operation. '
          'Please deploy the security rules from firestore.rules file to Firebase Console. '
          'See FIRESTORE_SECURITY_RULES_SETUP.md for instructions. Error: $e'
        );
      }
      throw Exception('Error setting user: $e');
    }
  }

  /// Update user fields
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.now();
      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  /// Stream user data
  Stream<FirebaseUserModel?> streamUser(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? FirebaseUserModel.fromFirestore(doc) : null);
  }

  // ==================== PROVIDERS ====================

  /// Get provider by ID
  Future<FirebaseProviderModel?> getProvider(String providerId) async {
    try {
      final doc = await _firestore.collection('providers').doc(providerId).get();
      if (doc.exists) {
        return FirebaseProviderModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting provider: $e');
    }
  }

  /// Create or update provider
  Future<void> setProvider(FirebaseProviderModel provider) async {
    try {
      await _firestore.collection('providers').doc(provider.providerId).set(provider.toFirestore());
    } catch (e) {
      throw Exception('Error setting provider: $e');
    }
  }

  /// Get providers by filters
  Future<List<FirebaseProviderModel>> getProviders({
    String? city,
    List<String>? eventTypes,
    double? minRating,
    bool? isVerified,
    bool? isActive,
  }) async {
    try {
      Query query = _firestore.collection('providers');

      if (city != null) {
        query = query.where('location.city', isEqualTo: city);
      }
      if (isVerified != null) {
        query = query.where('isVerified', isEqualTo: isVerified);
      }
      if (isActive != null) {
        query = query.where('isActive', isEqualTo: isActive);
      }
      if (minRating != null) {
        query = query.where('rating', isGreaterThanOrEqualTo: minRating);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => FirebaseProviderModel.fromFirestore(doc))
          .where((provider) {
            if (eventTypes != null && eventTypes.isNotEmpty) {
              return provider.eventTypes.any((type) => eventTypes.contains(type));
            }
            return true;
          })
          .toList();
    } catch (e) {
      throw Exception('Error getting providers: $e');
    }
  }

  /// Stream providers
  Stream<List<FirebaseProviderModel>> streamProviders({String? city}) {
    Query query = _firestore.collection('providers').where('isActive', isEqualTo: true);
    if (city != null) {
      query = query.where('location.city', isEqualTo: city);
    }
    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => FirebaseProviderModel.fromFirestore(doc)).toList());
  }

  // ==================== BOOKINGS ====================

  /// Get booking by ID
  Future<FirebaseBookingModel?> getBooking(String bookingId) async {
    try {
      final doc = await _firestore.collection('bookings').doc(bookingId).get();
      if (doc.exists) {
        return FirebaseBookingModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting booking: $e');
    }
  }

  /// Create booking
  Future<String> createBooking(FirebaseBookingModel booking) async {
    try {
      final docRef = await _firestore.collection('bookings').add(booking.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating booking: $e');
    }
  }

  /// Update booking
  Future<void> updateBooking(String bookingId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.now();
      await _firestore.collection('bookings').doc(bookingId).update(updates);
    } catch (e) {
      throw Exception('Error updating booking: $e');
    }
  }

  /// Get user bookings
  Future<List<FirebaseBookingModel>> getUserBookings(String userId, {String? status}) async {
    try {
      Query query = _firestore.collection('bookings').where('customerId', isEqualTo: userId);
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }
      final snapshot = await query.orderBy('eventDate', descending: true).get();
      return snapshot.docs.map((doc) => FirebaseBookingModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error getting user bookings: $e');
    }
  }

  /// Get provider bookings
  Future<List<FirebaseBookingModel>> getProviderBookings(String providerId, {String? status}) async {
    try {
      Query query = _firestore.collection('bookings').where('providerId', isEqualTo: providerId);
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }
      final snapshot = await query.orderBy('eventDate', descending: true).get();
      return snapshot.docs.map((doc) => FirebaseBookingModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error getting provider bookings: $e');
    }
  }

  /// Stream user bookings
  Stream<List<FirebaseBookingModel>> streamUserBookings(String userId, {String? status}) {
    Query query = _firestore.collection('bookings').where('customerId', isEqualTo: userId);
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    return query
        .orderBy('eventDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => FirebaseBookingModel.fromFirestore(doc)).toList());
  }

  // ==================== REELS ====================

  /// Get reel by ID
  Future<FirebaseReelModel?> getReel(String reelId) async {
    try {
      final doc = await _firestore.collection('reels').doc(reelId).get();
      if (doc.exists) {
        return FirebaseReelModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting reel: $e');
    }
  }

  /// Create reel
  Future<String> createReel(FirebaseReelModel reel) async {
    try {
      final docRef = await _firestore.collection('reels').add(reel.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating reel: $e');
    }
  }

  /// Update reel
  Future<void> updateReel(String reelId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('reels').doc(reelId).update(updates);
    } catch (e) {
      throw Exception('Error updating reel: $e');
    }
  }

  /// Get user reels
  Future<List<FirebaseReelModel>> getUserReels(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('reels')
          .where('customerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => FirebaseReelModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error getting user reels: $e');
    }
  }

  /// Get booking reels
  Future<List<FirebaseReelModel>> getBookingReels(String bookingId) async {
    try {
      final snapshot = await _firestore
          .collection('reels')
          .where('bookingId', isEqualTo: bookingId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => FirebaseReelModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error getting booking reels: $e');
    }
  }

  /// Get discover feed reels (public reels)
  Future<List<FirebaseReelModel>> getDiscoverReels({
    String? eventType,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection('reels')
          .where('isPublic', isEqualTo: true)
          .where('status', isEqualTo: 'delivered')
          .orderBy('analytics.views', descending: true)
          .limit(limit);

      if (eventType != null) {
        query = query.where('eventType', isEqualTo: eventType);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => FirebaseReelModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error getting discover reels: $e');
    }
  }

  /// Increment reel views
  Future<void> incrementReelViews(String reelId) async {
    try {
      await _firestore.collection('reels').doc(reelId).update({
        'analytics.views': FieldValue.increment(1),
        'analytics.lastViewedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Error incrementing reel views: $e');
    }
  }

  // ==================== REVIEWS ====================

  /// Create review
  Future<String> createReview(FirebaseReviewModel review) async {
    try {
      final docRef = await _firestore.collection('reviews').add(review.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating review: $e');
    }
  }

  /// Get provider reviews
  Future<List<FirebaseReviewModel>> getProviderReviews(String providerId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('providerId', isEqualTo: providerId)
          .where('status', isEqualTo: 'approved')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => FirebaseReviewModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error getting provider reviews: $e');
    }
  }

  // ==================== REFERRALS ====================

  /// Create referral
  Future<String> createReferral(FirebaseReferralModel referral) async {
    try {
      final docRef = await _firestore.collection('referrals').add(referral.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating referral: $e');
    }
  }

  /// Get user referrals
  Future<List<FirebaseReferralModel>> getUserReferrals(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('referrals')
          .where('referrerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => FirebaseReferralModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error getting user referrals: $e');
    }
  }

  /// Check if referral code exists
  Future<bool> checkReferralCode(String code) async {
    try {
      final snapshot = await _firestore.collection('users').where('referralCode', isEqualTo: code).limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Error checking referral code: $e');
    }
  }

  // ==================== WALLET ====================

  /// Create wallet transaction
  Future<String> createWalletTransaction(FirebaseWalletTransactionModel transaction) async {
    try {
      final docRef = await _firestore.collection('wallet_transactions').add(transaction.toFirestore());
      
      // Update user wallet balance
      if (transaction.type == 'credit' && transaction.status == 'completed') {
        await _firestore.collection('users').doc(transaction.userId).update({
          'walletBalance': FieldValue.increment(transaction.amount),
        });
      } else if (transaction.type == 'debit' && transaction.status == 'completed') {
        await _firestore.collection('users').doc(transaction.userId).update({
          'walletBalance': FieldValue.increment(-transaction.amount),
        });
      }
      
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating wallet transaction: $e');
    }
  }

  /// Get user wallet transactions
  Future<List<FirebaseWalletTransactionModel>> getUserWalletTransactions(String userId, {int? limit}) async {
    try {
      Query query = _firestore
          .collection('wallet_transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true);
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => FirebaseWalletTransactionModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error getting wallet transactions: $e');
    }
  }

  // ==================== NOTIFICATIONS ====================

  /// Create notification
  Future<String> createNotification(FirebaseNotificationModel notification) async {
    try {
      final docRef = await _firestore.collection('notifications').add(notification.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating notification: $e');
    }
  }

  /// Get user notifications
  Future<List<FirebaseNotificationModel>> getUserNotifications(String userId, {bool? isRead, int? limit}) async {
    try {
      Query query = _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true);
      
      if (isRead != null) {
        query = query.where('isRead', isEqualTo: isRead);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => FirebaseNotificationModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error getting notifications: $e');
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'readAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }

  /// Stream user notifications
  Stream<List<FirebaseNotificationModel>> streamUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => FirebaseNotificationModel.fromFirestore(doc)).toList());
  }

  // ==================== OFFERS ====================

  /// Get active offers
  Future<List<FirebaseOfferModel>> getActiveOffers({String? eventType}) async {
    try {
      Query query = _firestore
          .collection('offers')
          .where('isActive', isEqualTo: true)
          .where('isPublic', isEqualTo: true);
      
      if (eventType != null) {
        query = query.where('applicableEventTypes', arrayContains: eventType);
      }
      
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => FirebaseOfferModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error getting offers: $e');
    }
  }

  /// Validate offer code
  Future<FirebaseOfferModel?> validateOfferCode(String code, String userId) async {
    try {
      final snapshot = await _firestore.collection('offers').where('code', isEqualTo: code).limit(1).get();
      if (snapshot.docs.isEmpty) return null;
      
      final offer = FirebaseOfferModel.fromFirestore(snapshot.docs.first);
      
      // Check if offer is valid
      if (!offer.isActive) return null;
      if (offer.expiresAt != null && offer.expiresAt!.isBefore(DateTime.now())) return null;
      if (offer.usedCount >= offer.maxUses) return null;
      
      // Check user eligibility
      final usageSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('offer_usage')
          .doc(offer.offerId)
          .get();
      
      if (usageSnapshot.exists) {
        final usage = FirebaseUserOfferUsageModel.fromFirestore(usageSnapshot);
        if (offer.eligibility.maxUsesPerUser != null &&
            usage.usageCount >= offer.eligibility.maxUsesPerUser!) {
          return null;
        }
      }
      
      return offer;
    } catch (e) {
      throw Exception('Error validating offer code: $e');
    }
  }

  // ==================== LIVE EVENTS ====================

  /// Get live event
  Future<FirebaseLiveEventModel?> getLiveEvent(String bookingId) async {
    try {
      final doc = await _firestore.collection('live_events').doc(bookingId).get();
      if (doc.exists) {
        return FirebaseLiveEventModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting live event: $e');
    }
  }

  /// Create or update live event
  Future<void> setLiveEvent(FirebaseLiveEventModel liveEvent) async {
    try {
      await _firestore.collection('live_events').doc(liveEvent.bookingId).set(liveEvent.toFirestore());
    } catch (e) {
      throw Exception('Error setting live event: $e');
    }
  }

  /// Stream live event
  Stream<FirebaseLiveEventModel?> streamLiveEvent(String bookingId) {
    return _firestore
        .collection('live_events')
        .doc(bookingId)
        .snapshots()
        .map((doc) => doc.exists ? FirebaseLiveEventModel.fromFirestore(doc) : null);
  }

  // ==================== ADMIN ====================

  /// Get admin analytics
  Future<FirebaseAdminAnalyticsModel?> getAdminAnalytics(String date) async {
    try {
      final doc = await _firestore.collection('admin_analytics').doc(date).get();
      if (doc.exists) {
        return FirebaseAdminAnalyticsModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting admin analytics: $e');
    }
  }

  /// Get support tickets
  Future<List<FirebaseSupportTicketModel>> getSupportTickets({
    String? status,
    String? priority,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection('support_tickets').orderBy('createdAt', descending: true);
      
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }
      if (priority != null) {
        query = query.where('priority', isEqualTo: priority);
      }
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => FirebaseSupportTicketModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error getting support tickets: $e');
    }
  }

  /// Create support ticket
  Future<String> createSupportTicket(FirebaseSupportTicketModel ticket) async {
    try {
      final docRef = await _firestore.collection('support_tickets').add(ticket.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating support ticket: $e');
    }
  }
}

