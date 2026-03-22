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
import '../models/firebase_catalogue_event_model.dart';

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

  /// Update provider fields (partial update)
  Future<void> updateProvider(String providerId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.now();
      await _firestore.collection('providers').doc(providerId).update(updates);
    } catch (e) {
      throw Exception('Error updating provider: $e');
    }
  }

  /// Create provider from minimal registration data
  /// Used when a new provider signs up; starts as pending + not verified
  Future<void> createProviderFromRegistration({
    required String providerId,
    required String businessName,
    required String ownerName,
    required String email,
    required String phoneNumber,
  }) async {
    final now = DateTime.now();
    final model = FirebaseProviderModel(
      providerId: providerId,
      businessName: businessName,
      ownerName: ownerName,
      email: email,
      phoneNumber: phoneNumber,
      profileImage: '',
      coverImages: const [],
      bio: '',
      eventTypes: const [],
      packages: const [],
      portfolio: const [],
      location: ProviderLocation(
        address: '',
        city: '',
        state: '',
        pincode: '',
        latitude: 0,
        longitude: 0,
      ),
      serviceAreas: const [],
      serviceRadius: 50,
      teamSize: 1,
      equipment: const [],
      rating: 0,
      totalReviews: 0,
      totalEventsCompleted: 0,
      totalReelsDelivered: 0,
      averageDeliveryTime: 0,
      availability: const {},
      blockedDates: const [],
      bankDetails: null,
      commissionRate: 15,
      isVerified: false,
      isActive: false,
      isFeatured: false,
      verificationStatus: 'pending',
      rejectionReason: null,
      createdAt: now,
      updatedAt: now,
      metadata: const {
        'source': 'registration_form',
      },
    );
    await setProvider(model);
  }

  /// Get featured providers (isFeatured: true, approved). Optionally filter by city.
  Future<List<FirebaseProviderModel>> getFeaturedProviders({String? city}) async {
    try {
      final all = await getProviders(
        city: city,
        isActive: true,
        verificationStatus: 'approved',
      );
      final featured = all.where((p) => p.isFeatured).toList();
      if (featured.isNotEmpty) return featured;
      return all;
    } catch (e) {
      throw Exception('Error getting featured providers: $e');
    }
  }

  /// Get providers by filters
  Future<List<FirebaseProviderModel>> getProviders({
    String? city,
    List<String>? eventTypes,
    double? minRating,
    bool? isVerified,
    bool? isActive,
    String? verificationStatus,
  }) async {
    try {
      Query query = _firestore.collection('providers');

      // Equality filters first (order matches firestore.indexes.json composites), then range on `rating`.
      if (isActive != null) {
        query = query.where('isActive', isEqualTo: isActive);
      }
      if (city != null) {
        query = query.where('location.city', isEqualTo: city);
      }
      if (isVerified != null) {
        query = query.where('isVerified', isEqualTo: isVerified);
      }
      if (verificationStatus != null) {
        query = query.where('verificationStatus', isEqualTo: verificationStatus);
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

  /// Get a single provider by phone number, used for provider login.
  /// Tries multiple formats to be forgiving:
  /// - raw phone (digits only, as typed)
  /// - '<countryCode> <phone>'
  /// - '<countryCode><phone>'
  Future<FirebaseProviderModel?> getProviderByPhone(
    String phone, {
    String? countryCode,
  }) async {
    final candidates = <String>{
      phone,
      if (countryCode != null) '$countryCode $phone',
      if (countryCode != null) '$countryCode$phone',
    }.toList();

    try {
      for (final value in candidates) {
        final snapshot = await _firestore
            .collection('providers')
            .where('phoneNumber', isEqualTo: value)
            .limit(1)
            .get();
        if (snapshot.docs.isNotEmpty) {
          return FirebaseProviderModel.fromFirestore(snapshot.docs.first);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Error getting provider by phone: $e');
    }
  }

  /// Stream providers
  Stream<List<FirebaseProviderModel>> streamProviders({String? city, String? verificationStatus}) {
    Query query = _firestore.collection('providers');
    if (verificationStatus != null) {
      query = query.where('verificationStatus', isEqualTo: verificationStatus);
    } else {
      // Default: only active, approved providers for customer-facing flows
      query = query.where('isActive', isEqualTo: true);
    }
    if (city != null) {
      query = query.where('location.city', isEqualTo: city);
    }
    return query.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => FirebaseProviderModel.fromFirestore(doc)).toList(),
    );
  }

  /// Stream only pending providers (for admin verification screen)
  Stream<List<FirebaseProviderModel>> streamPendingProviders() {
    return _firestore
        .collection('providers')
        .where('verificationStatus', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => FirebaseProviderModel.fromFirestore(doc)).toList());
  }

  /// Update provider verification status from admin panel
  Future<void> updateProviderVerificationStatus({
    required String providerId,
    required String status, // pending / approved / rejected
    String? rejectionReason,
  }) async {
    try {
      final updates = <String, dynamic>{
        'verificationStatus': status,
        'updatedAt': Timestamp.now(),
      };
      if (status == 'approved') {
        updates['isVerified'] = true;
        updates['isActive'] = true;
        updates['rejectionReason'] = null;
      } else if (status == 'rejected') {
        updates['isVerified'] = false;
        updates['isActive'] = false;
        updates['rejectionReason'] = rejectionReason ?? '';
      }
      await _firestore.collection('providers').doc(providerId).update(updates);
    } catch (e) {
      throw Exception('Error updating provider verification status: $e');
    }
  }

  // ==================== PROVIDER CATALOGUE EVENTS ====================
  /// Subcollection: `providers/{providerId}/catalogue_events/{catalogueEventId}`

  CollectionReference<Map<String, dynamic>> _catalogueCollection(String providerId) {
    return _firestore.collection('providers').doc(providerId).collection('catalogue_events');
  }

  Stream<List<FirebaseCatalogueEventModel>> streamCatalogueEvents(String providerId) {
    return _catalogueCollection(providerId).snapshots().map((snapshot) {
      final list =
          snapshot.docs.map((doc) => FirebaseCatalogueEventModel.fromFirestore(doc, providerId)).toList();
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return list;
    });
  }

  Future<List<FirebaseCatalogueEventModel>> getCatalogueEvents(String providerId) async {
    try {
      final snapshot = await _catalogueCollection(providerId).get();
      final list =
          snapshot.docs.map((doc) => FirebaseCatalogueEventModel.fromFirestore(doc, providerId)).toList();
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return list;
    } catch (e) {
      throw Exception('Error getting catalogue events: $e');
    }
  }

  Future<FirebaseCatalogueEventModel?> getCatalogueEvent(
    String providerId,
    String catalogueEventId,
  ) async {
    try {
      final doc = await _catalogueCollection(providerId).doc(catalogueEventId).get();
      if (!doc.exists) return null;
      return FirebaseCatalogueEventModel.fromFirestore(doc, providerId);
    } catch (e) {
      throw Exception('Error getting catalogue event: $e');
    }
  }

  /// Creates new doc when [model.catalogueEventId] is empty; otherwise overwrites.
  Future<String> upsertCatalogueEvent(String providerId, FirebaseCatalogueEventModel model) async {
    try {
      final col = _catalogueCollection(providerId);
      if (model.catalogueEventId.isEmpty) {
        final ref = await col.add(model.toFirestore());
        return ref.id;
      }
      await col.doc(model.catalogueEventId).set(model.toFirestore(), SetOptions(merge: true));
      return model.catalogueEventId;
    } catch (e) {
      throw Exception('Error saving catalogue event: $e');
    }
  }

  Future<void> deleteCatalogueEvent(String providerId, String catalogueEventId) async {
    try {
      await _catalogueCollection(providerId).doc(catalogueEventId).delete();
    } catch (e) {
      throw Exception('Error deleting catalogue event: $e');
    }
  }

  Future<void> updateCatalogueEventPublish(
    String providerId,
    String catalogueEventId,
    bool isPublished,
  ) async {
    try {
      await _catalogueCollection(providerId).doc(catalogueEventId).update({
        'isPublished': isPublished,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Error updating catalogue publish flag: $e');
    }
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

  /// Get all bookings (admin view). Fetches all and optionally filters by status in memory
  /// to avoid composite index requirements.
  Future<List<FirebaseBookingModel>> getAllBookings({String? status}) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .orderBy('createdAt', descending: true)
          .get();
      var list = snapshot.docs.map((doc) => FirebaseBookingModel.fromFirestore(doc)).toList();
      if (status != null) {
        list = list.where((b) => b.status == status).toList();
      }
      return list;
    } catch (e) {
      throw Exception('Error getting all bookings: $e');
    }
  }

  /// Stream provider bookings for real-time updates
  Stream<List<FirebaseBookingModel>> streamProviderBookings(String providerId, {String? status}) {
    Query query = _firestore.collection('bookings').where('providerId', isEqualTo: providerId);
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    return query
        .orderBy('eventDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => FirebaseBookingModel.fromFirestore(doc)).toList());
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

  /// Stream user bookings count (updates in real-time).
  /// Uses snapshot size only (no document parsing) for better performance.
  Stream<int> streamUserBookingsCount(String userId) {
    return _firestore
        .collection('bookings')
        .where('customerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
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
      // Query without orderBy to avoid composite index; sort in memory.
      final snapshot = await _firestore
          .collection('reels')
          .where('customerId', isEqualTo: userId)
          .get();
      final reels = snapshot.docs.map((doc) => FirebaseReelModel.fromFirestore(doc)).toList();
      reels.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reels;
    } catch (e) {
      throw Exception('Error getting user reels: $e');
    }
  }

  /// Stream user reels count (updates in real-time).
  /// Uses snapshot size only (no document parsing) for better performance.
  Stream<int> streamUserReelsCount(String userId) {
    return _firestore
        .collection('reels')
        .where('customerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
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

  /// Get provider reels (portfolio uploads)
  Future<List<FirebaseReelModel>> getProviderReels(String providerId) async {
    try {
      // Query without orderBy to avoid requiring a composite index (works immediately).
      // Sort in memory - fine for typical provider reel counts.
      final snapshot = await _firestore
          .collection('reels')
          .where('providerId', isEqualTo: providerId)
          .get();
      final reels = snapshot.docs.map((doc) => FirebaseReelModel.fromFirestore(doc)).toList();
      reels.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reels;
    } catch (e) {
      throw Exception('Error getting provider reels: $e');
    }
  }

  /// Add portfolio item to provider document (syncs provider.portfolio with reels)
  Future<void> addPortfolioItemToProvider(
    String providerId,
    PortfolioItem item,
  ) async {
    try {
      await _firestore.collection('providers').doc(providerId).update({
        'portfolio': FieldValue.arrayUnion([item.toMap()]),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Error adding portfolio item: $e');
    }
  }

  /// Remove portfolio item from provider document (must match exact map for arrayRemove)
  Future<void> removePortfolioItemFromProvider(
    String providerId,
    PortfolioItem item,
  ) async {
    try {
      await _firestore.collection('providers').doc(providerId).update({
        'portfolio': FieldValue.arrayRemove([item.toMap()]),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Error removing portfolio item: $e');
    }
  }

  /// Delete reel document
  Future<void> deleteReel(String reelId) async {
    try {
      await _firestore.collection('reels').doc(reelId).delete();
    } catch (e) {
      throw Exception('Error deleting reel: $e');
    }
  }

  /// Get discover feed reels (public reels)
  /// When eventType is provided, fetches all and filters in memory to avoid composite index.
  Future<List<FirebaseReelModel>> getDiscoverReels({
    String? eventType,
    int limit = 20,
  }) async {
    try {
      // Fetch isPublic reels; filter by status in memory to include both delivered and published
      final query = _firestore
          .collection('reels')
          .where('isPublic', isEqualTo: true)
          .limit(eventType != null ? 100 : limit * 2);

      final snapshot = await query.get();
      var reels = snapshot.docs
          .map((doc) => FirebaseReelModel.fromFirestore(doc))
          .where((r) => r.status == 'delivered' || r.status == 'published')
          .toList();
      reels.sort((a, b) => b.analytics.views.compareTo(a.analytics.views));
      if (eventType != null) {
        reels = reels.where((r) => r.eventType == eventType).take(limit).toList();
      } else {
        reels = reels.take(limit).toList();
      }
      return reels;
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

  /// Toggle like for a reel by user.
  /// Returns true when reel is liked after operation, false when unliked.
  Future<bool> toggleReelLike({
    required String reelId,
    required String userId,
  }) async {
    try {
      final docRef = _firestore.collection('reels').doc(reelId);
      return await _firestore.runTransaction<bool>((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw Exception('Reel not found');
        }
        final data = snapshot.data() ?? <String, dynamic>{};
        final analytics = Map<String, dynamic>.from(
          data['analytics'] as Map<String, dynamic>? ?? const {},
        );
        final likedBy = List<String>.from(
          data['likedBy'] as List<dynamic>? ?? const [],
        );

        final isLiked = likedBy.contains(userId);
        if (isLiked) {
          likedBy.remove(userId);
          final currentLikes = ((analytics['likes'] ?? 0) as num).toInt();
          transaction.update(docRef, {
            'likedBy': likedBy,
            'analytics.likes': currentLikes > 0
                ? FieldValue.increment(-1)
                : 0,
          });
          return false;
        } else {
          likedBy.add(userId);
          transaction.update(docRef, {
            'likedBy': likedBy,
            'analytics.likes': FieldValue.increment(1),
          });
          return true;
        }
      });
    } catch (e) {
      throw Exception('Error toggling reel like: $e');
    }
  }

  /// Add a comment to a reel and increment comment count.
  Future<void> addReelComment({
    required String reelId,
    required String userId,
    required String commentText,
  }) async {
    try {
      final cleanText = commentText.trim();
      if (cleanText.isEmpty) return;

      final reelRef = _firestore.collection('reels').doc(reelId);
      final commentRef = reelRef.collection('comments').doc();

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(reelRef);
        if (!snapshot.exists) {
          throw Exception('Reel not found');
        }
        transaction.set(commentRef, {
          'commentId': commentRef.id,
          'reelId': reelId,
          'userId': userId,
          'text': cleanText,
          'createdAt': Timestamp.now(),
        });
        transaction.update(reelRef, {
          'analytics.comments': FieldValue.increment(1),
        });
      });
    } catch (e) {
      throw Exception('Error adding reel comment: $e');
    }
  }

  /// Increment share count for a reel.
  Future<void> incrementReelShares(String reelId) async {
    try {
      await _firestore.collection('reels').doc(reelId).update({
        'analytics.shares': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Error incrementing reel shares: $e');
    }
  }

  /// Live updates for a single reel document (analytics, likedBy, etc.).
  Stream<FirebaseReelModel?> streamReel(String reelId) {
    return _firestore.collection('reels').doc(reelId).snapshots().map(
          (doc) => doc.exists ? FirebaseReelModel.fromFirestore(doc) : null,
        );
  }

  /// Comments on a reel, newest first.
  Stream<List<ReelCommentDocument>> streamReelComments(
    String reelId, {
    int limit = 50,
  }) {
    return _firestore
        .collection('reels')
        .doc(reelId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snap) => snap.docs.map(ReelCommentDocument.fromFirestore).toList(),
        );
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

  /// Get homepage-ready reviews (approved + public).
  /// Note: city-based filtering should typically be done client-side after joining providers.
  Future<List<FirebaseReviewModel>> getApprovedPublicReviews({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('status', isEqualTo: 'approved')
          .where('isPublic', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs
          .map((doc) => FirebaseReviewModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error getting approved public reviews: $e');
    }
  }

  /// Admin: list reviews by status (e.g., pending/approved/rejected)
  Future<List<FirebaseReviewModel>> getReviewsForAdmin({
    String? status,
    bool? isPublic,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection('reviews');
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }
      if (isPublic != null) {
        query = query.where('isPublic', isEqualTo: isPublic);
      }
      query = query.orderBy('createdAt', descending: true);
      if (limit != null) {
        query = query.limit(limit);
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => FirebaseReviewModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error getting reviews for admin: $e');
    }
  }

  /// Admin: update review partial fields (e.g., `status`, `isPublic`)
  Future<void> updateReview(String reviewId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).update({
        ...updates,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Error updating review: $e');
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

  /// Mark booking complete and create provider payout.
  /// Fetches provider for commissionRate, calculates net amount, updates booking, creates payout.
  /// Idempotent for payout: skips if payout already exists for this booking.
  Future<void> completeBookingAndCreatePayout(FirebaseBookingModel booking) async {
    final provider = await getProvider(booking.providerId);
    final commissionRate = provider?.commissionRate ?? 0.0;
    final netAmount = booking.payment.totalAmount * (1 - commissionRate / 100);

    await updateBooking(booking.bookingId, {
      'status': 'completed',
      'completedAt': Timestamp.now(),
      'eventStatus.eventCompleted': Timestamp.now(),
    });

    await createProviderPayout(booking.providerId, booking.bookingId, netAmount);
  }

  /// Create provider payout when booking is marked complete.
  /// Net amount = totalAmount * (1 - commissionRate/100).
  /// Idempotent: skips if payout already exists for this booking.
  Future<void> createProviderPayout(String providerId, String bookingId, double netAmount) async {
    try {
      final existing = await _firestore
          .collection('wallet_transactions')
          .where('userId', isEqualTo: providerId)
          .where('reference.referenceId', isEqualTo: bookingId)
          .where('type', isEqualTo: 'provider_payout')
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) return;

      final now = DateTime.now();
      final transaction = FirebaseWalletTransactionModel(
        transactionId: '',
        userId: providerId,
        type: 'provider_payout',
        amount: netAmount,
        status: 'completed',
        reference: WalletTransactionReference(
          referenceType: 'booking',
          referenceId: bookingId,
        ),
        createdAt: now,
        completedAt: now,
      );
      await _firestore.collection('wallet_transactions').add(transaction.toFirestore());
    } catch (e) {
      throw Exception('Error creating provider payout: $e');
    }
  }

  /// Get all provider payouts (for admin earnings view).
  /// Returns wallet_transactions where type='provider_payout', ordered by createdAt desc.
  Future<List<FirebaseWalletTransactionModel>> getAllProviderPayouts({int? limit}) async {
    try {
      Query query = _firestore
          .collection('wallet_transactions')
          .where('type', isEqualTo: 'provider_payout')
          .orderBy('createdAt', descending: true);
      if (limit != null) {
        query = query.limit(limit);
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => FirebaseWalletTransactionModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error getting provider payouts: $e');
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

  /// Admin: list offers (optionally filter by active/public)
  Future<List<FirebaseOfferModel>> getOffersForAdmin({
    bool? isActive,
    bool? isPublic,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection('offers');

      if (isActive != null) {
        query = query.where('isActive', isEqualTo: isActive);
      }
      if (isPublic != null) {
        query = query.where('isPublic', isEqualTo: isPublic);
      }
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => FirebaseOfferModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error getting offers for admin: $e');
    }
  }

  /// Admin: create offer with stable document id (uses `offer.offerId`)
  Future<void> createOffer(FirebaseOfferModel offer) async {
    try {
      await _firestore
          .collection('offers')
          .doc(offer.offerId)
          .set(offer.toFirestore());
    } catch (e) {
      throw Exception('Error creating offer: $e');
    }
  }

  /// Admin: update offer partial fields
  Future<void> updateOffer(String offerId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('offers').doc(offerId).update({
        ...updates,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Error updating offer: $e');
    }
  }

  /// Admin: delete offer
  Future<void> deleteOffer(String offerId) async {
    try {
      await _firestore.collection('offers').doc(offerId).delete();
    } catch (e) {
      throw Exception('Error deleting offer: $e');
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

  /// Live dashboard stats: user/provider/booking counts, sum of booking `payment.totalAmount`, pending verifications.
  Future<AdminDashboardMetrics> getAdminDashboardMetrics() async {
    try {
      final counts = await Future.wait([
        _firestore.collection('users').count().get(),
        _firestore.collection('providers').count().get(),
        _firestore.collection('bookings').count().get(),
        _firestore
            .collection('providers')
            .where('verificationStatus', isEqualTo: 'pending')
            .count()
            .get(),
      ]);

      double totalRevenue = 0;
      try {
        final revAgg = await _firestore
            .collection('bookings')
            .aggregate(sum('payment.totalAmount'))
            .get();
        totalRevenue = revAgg.getSum('payment.totalAmount') ?? 0.0;
      } catch (_) {
        final snap = await _firestore.collection('bookings').get();
        for (final doc in snap.docs) {
          final payment = doc.data()['payment'];
          if (payment is Map<String, dynamic>) {
            totalRevenue += (payment['totalAmount'] ?? 0.0).toDouble();
          }
        }
      }

      return AdminDashboardMetrics(
        totalUsers: counts[0].count ?? 0,
        totalProviders: counts[1].count ?? 0,
        totalBookings: counts[2].count ?? 0,
        totalRevenueInr: totalRevenue,
        pendingProviderVerifications: counts[3].count ?? 0,
      );
    } catch (e) {
      throw Exception('Error loading admin dashboard metrics: $e');
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

  /// Get support tickets for a specific user (customer-facing “My Tickets”)
  Future<List<FirebaseSupportTicketModel>> getUserSupportTickets({
    required String userId,
    String? status,
    int? limit,
  }) async {
    try {
      Query query = _firestore
          .collection('support_tickets')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => FirebaseSupportTicketModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error getting user support tickets: $e');
    }
  }
}

