import 'package:flutter/material.dart';
import '../../../../core/firebase/models/firebase_booking_model.dart';
import '../../../../core/mock/mock_packages.dart';
import '../models/service_provider_model.dart';

/// Adapter to convert bookingData map (from package customization/summary flow)
/// to FirebaseBookingModel for Firestore persistence.
class BookingFirebaseAdapter {
  /// Maps bookingData from the booking flow to FirebaseBookingModel.
  /// [data] - Map from event details, venue, provider selection, package customization
  /// [customerId] - Current user's Firebase UID
  static FirebaseBookingModel fromBookingData(
    Map<String, dynamic> data,
    String customerId,
  ) {
    final packageId = data['packageId'] as String? ?? '';
    final package = MockPackages.getPackageById(packageId);
    final totalAmount = (data['totalAmount'] ?? 0.0) as num;
    final totalAmountDouble = totalAmount.toDouble();
    final advanceAmount = totalAmountDouble * 0.5;
    final remainingAmount = totalAmountDouble - advanceAmount;
    final durationHours = (data['duration'] ?? 4) as num;
    final durationMinutes = (durationHours.toInt() * 60);

    // Venue
    final venue = VenueData(
      name: data['venueName']?.toString() ?? '',
      address: data['venueAddress']?.toString() ?? '',
      city: data['venueCity']?.toString() ?? '',
      pincode: data['venuePincode']?.toString() ?? '',
      latitude: _toDouble(data['venueLatitude']),
      longitude: _toDouble(data['venueLongitude']),
    );

    // Package - from MockPackages
    final pkg = package ?? PackageOffering(
      packageId: packageId,
      name: 'Custom',
      price: totalAmountDouble,
      duration: durationMinutes,
      reelsCount: 0,
      editingStyle: 'standard',
      deliveryTime: 60,
      features: [],
    );
    final packageData = PackageData(
      packageId: pkg.packageId,
      name: pkg.name,
      price: pkg.price,
      duration: pkg.duration,
      reelsCount: pkg.reelsCount,
      editingStyle: pkg.editingStyle,
      deliveryTime: pkg.deliveryTime,
      features: pkg.features,
    );

    // Customizations
    final customizations = CustomizationsData(
      editingStyle: data['editingStyle']?.toString() ?? '',
      musicPreference: data['musicPreference']?.toString() ?? '',
      colorGrading: data['colorGrading']?.toString() ?? '',
      includeDrone: data['includeDrone'] == true,
      additionalReels: (data['additionalReels'] ?? 0) as int,
      additionalCost: _toDouble(data['additionalCost']),
    );

    // Event time - handle TimeOfDay or String
    final eventTimeRaw = data['eventTime'];
    final eventTimeStr = _eventTimeToString(eventTimeRaw);

    // Expected reels count
    final baseReels = pkg.reelsCount < 0 ? 10 : pkg.reelsCount;
    final additionalReels = (data['additionalReels'] ?? 0) as int;
    final expectedReelsCount = baseReels + additionalReels;

    // Event date
    final eventDate = data['eventDate'] is DateTime
        ? data['eventDate'] as DateTime
        : DateTime.now();

    final now = DateTime.now();

    return FirebaseBookingModel(
      bookingId: '',
      customerId: customerId,
      providerId: data['providerId']?.toString() ?? '',
      eventType: data['eventType']?.toString() ?? '',
      eventName: data['eventName']?.toString() ?? '',
      eventDate: eventDate,
      eventTime: eventTimeStr,
      duration: durationMinutes,
      guestCount: (data['guestCount'] ?? 0) as int,
      venue: venue,
      package: packageData,
      customizations: customizations,
      specialRequirements: data['specialRequirements']?.toString(),
      keyMoments: data['keyMoments'] != null
          ? List<String>.from(data['keyMoments'] as List)
          : null,
      status: 'pending',
      eventStatus: EventStatusTimestamps(),
      payment: PaymentData(
        totalAmount: totalAmountDouble,
        advanceAmount: advanceAmount,
        remainingAmount: remainingAmount,
        paymentStatus: 'pending',
        transactions: null,
      ),
      contactPerson: data['contactPerson']?.toString() ?? '',
      contactNumber: data['contactNumber']?.toString() ?? '',
      alternateContact: null,
      expectedReelsCount: expectedReelsCount,
      deliveryTimeline: 'same_day',
      createdAt: now,
      updatedAt: now,
      cancelledAt: null,
      cancellationReason: null,
      completedAt: null,
      metadata: null,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static String _eventTimeToString(dynamic eventTime) {
    if (eventTime == null) return '10:00';
    if (eventTime is TimeOfDay) {
      return '${eventTime.hour.toString().padLeft(2, '0')}:'
          '${eventTime.minute.toString().padLeft(2, '0')}';
    }
    if (eventTime is String) return eventTime;
    return '10:00';
  }
}
