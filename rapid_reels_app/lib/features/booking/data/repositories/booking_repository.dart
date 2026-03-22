import '../models/event_booking_model.dart';
import '../models/service_provider_model.dart';
import '../adapters/booking_firebase_mappers.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../../core/firebase/models/firebase_booking_model.dart' as fb;

/// Booking repository - uses Firestore for providers and bookings (dynamic data).
class BookingRepository {
  final FirestoreService _firestore = FirestoreService();

  Future<List<ServiceProvider>> getProvidersByEventType({
    required String eventType,
    required String city,
  }) async {
    final list = await _firestore.getProviders(
      city: city,
      eventTypes: [eventType],
      isActive: true,
      verificationStatus: 'approved',
    );
    return list.map((p) => ServiceProvider.fromFirebase(p)).toList();
  }

  Future<List<ServiceProvider>> getAllProviders({String? city}) async {
    final list = await _firestore.getProviders(
      city: city,
      isActive: true,
      verificationStatus: 'approved',
    );
    return list.map((p) => ServiceProvider.fromFirebase(p)).toList();
  }

  Future<List<ServiceProvider>> getFeaturedProviders({String? city}) async {
    final list = await _firestore.getFeaturedProviders(city: city);
    return list.map((p) => ServiceProvider.fromFirebase(p)).toList();
  }

  Future<ServiceProvider?> getProviderDetails(String providerId) async {
    final p = await _firestore.getProvider(providerId);
    return p != null ? ServiceProvider.fromFirebase(p) : null;
  }

  Future<String> createBooking(EventBooking booking) async {
    final firebaseBooking = _eventBookingToFirebase(booking);
    return _firestore.createBooking(firebaseBooking);
  }

  Stream<List<EventBooking>> getUserBookings(String userId) {
    return _firestore.streamUserBookings(userId).map(
          (list) => list.map((b) => BookingFirebaseMappers.toEventBooking(b)).toList(),
        );
  }

  Stream<List<EventBooking>> getUserUpcomingBookings(String userId) {
    return _firestore.streamUserBookings(userId).map(
          (list) => list
              .where((b) =>
                  b.status == 'confirmed' &&
                  b.eventDate.isAfter(DateTime.now()) &&
                  b.status != 'cancelled')
              .map((b) => BookingFirebaseMappers.toEventBooking(b))
              .toList(),
        );
  }

  Stream<List<EventBooking>> getUserOngoingBookings(String userId) {
    return _firestore.streamUserBookings(userId).map(
          (list) => list
              .where((b) => b.status == 'ongoing')
              .map((b) => BookingFirebaseMappers.toEventBooking(b))
              .toList(),
        );
  }

  Stream<List<EventBooking>> getUserPastBookings(String userId) {
    return _firestore.streamUserBookings(userId, status: 'completed').map(
          (list) => list.map((b) => BookingFirebaseMappers.toEventBooking(b)).toList(),
        );
  }

  Future<EventBooking?> getBookingById(String bookingId) async {
    final b = await _firestore.getBooking(bookingId);
    return b != null ? BookingFirebaseMappers.toEventBooking(b) : null;
  }

  Stream<List<EventBooking>> getProviderBookings(String providerId) {
    return _firestore.streamProviderBookings(providerId).map(
          (list) => list.map((b) => BookingFirebaseMappers.toEventBooking(b)).toList(),
        );
  }

  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    await _firestore.updateBooking(bookingId, {'status': status});
  }

  Future<void> cancelBooking({
    required String bookingId,
    required String reason,
  }) async {
    await _firestore.updateBooking(bookingId, {
      'status': 'cancelled',
      'cancellationReason': reason,
      'cancelledAt': DateTime.now(),
    });
  }

  Future<void> rescheduleBooking({
    required String bookingId,
    required DateTime newDate,
    required String newTime,
  }) async {
    await _firestore.updateBooking(bookingId, {
      'eventDate': newDate,
      'eventTime': newTime,
    });
  }

  Future<void> updatePaymentStatus({
    required String bookingId,
    required String paymentStatus,
    required PaymentRecord payment,
  }) async {
    await _firestore.updateBooking(bookingId, {
      'payment.paymentStatus': paymentStatus,
    });
  }

  Future<void> acceptBooking(String bookingId) async {
    await _firestore.updateBooking(bookingId, {'status': 'confirmed'});
  }

  Future<void> declineBooking({
    required String bookingId,
    required String reason,
  }) async {
    await _firestore.updateBooking(bookingId, {
      'status': 'cancelled',
      'cancellationReason': reason,
    });
  }

  Future<void> startEvent(String bookingId) async {
    await _firestore.updateBooking(bookingId, {'status': 'ongoing'});
  }

  Future<void> completeEvent(String bookingId) async {
    await _firestore.updateBooking(bookingId, {
      'status': 'completed',
      'completedAt': DateTime.now(),
    });
  }

  /// Convert EventBooking to FirebaseBookingModel for create (bookingId will be assigned by Firestore).
  static fb.FirebaseBookingModel _eventBookingToFirebase(EventBooking e) {
    return fb.FirebaseBookingModel(
      bookingId: '',
      customerId: e.customerId,
      providerId: e.providerId,
      eventType: e.eventType,
      eventName: e.eventName,
      eventDate: e.eventDate,
      eventTime: e.eventTime,
      duration: e.duration,
      guestCount: e.guestCount,
      venue: fb.VenueData(
        name: e.venue.name,
        address: e.venue.address,
        city: e.venue.city,
        pincode: e.venue.pincode,
        latitude: e.venue.latitude,
        longitude: e.venue.longitude,
      ),
      package: fb.PackageData(
        packageId: e.packageId,
        name: e.packageName,
        price: e.packagePrice,
        duration: e.duration,
        reelsCount: 0,
        editingStyle: 'standard',
        deliveryTime: 60,
        features: [],
      ),
      customizations: e.customizations != null
          ? fb.CustomizationsData(
              editingStyle: e.customizations!.editingStyle,
              musicPreference: e.customizations!.musicPreference,
              colorGrading: e.customizations!.colorGrading,
              includeDrone: e.customizations!.includeDrone,
              additionalReels: e.customizations!.additionalReels,
              additionalCost: e.customizations!.additionalCost,
            )
          : null,
      specialRequirements: e.specialRequirements,
      keyMoments: e.keyMoments,
      status: e.status,
      eventStatus: fb.EventStatusTimestamps(
        bookingConfirmed: e.eventStatus.bookingConfirmed,
        providerAccepted: e.eventStatus.providerAccepted,
        eventStarted: e.eventStatus.eventStarted,
        firstReelDelivered: e.eventStatus.firstReelDelivered,
        eventCompleted: e.eventStatus.eventCompleted,
        allReelsDelivered: e.eventStatus.allReelsDelivered,
      ),
      payment: fb.PaymentData(
        totalAmount: e.totalAmount,
        advanceAmount: e.advanceAmount,
        remainingAmount: e.remainingAmount,
        paymentStatus: e.paymentStatus,
        transactions: e.payments.isEmpty
            ? null
            : e.payments
                .map((p) => fb.PaymentTransaction(
                      paymentId: p.paymentId,
                      amount: p.amount,
                      method: p.method,
                      transactionId: p.transactionId,
                      status: p.status,
                      paidAt: p.paidAt,
                    ))
                .toList(),
      ),
      contactPerson: e.contactPerson,
      contactNumber: e.contactNumber,
      alternateContact: e.alternateContact,
      expectedReelsCount: e.expectedReelsCount,
      deliveryTimeline: e.deliveryTimeline,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      cancelledAt: e.cancelledAt,
      cancellationReason: e.cancellationReason,
      completedAt: e.completedAt,
      metadata: null,
      catalogueEventId: e.catalogueEventId,
      catalogueTitle: e.catalogueTitle,
      catalogueHeroUrl: e.catalogueHeroUrl,
    );
  }
}
