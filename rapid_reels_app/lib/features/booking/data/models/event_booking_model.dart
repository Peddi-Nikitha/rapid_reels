class EventBooking {
  final String eventId;
  final String customerId;
  final String providerId;
  final String eventType;
  final String eventName;
  final DateTime eventDate;
  final String eventTime;
  final int duration; // in minutes
  final int guestCount;
  final VenueDetails venue;
  final String packageId;
  final String packageName;
  final double packagePrice;
  final EventCustomizations? customizations;
  final String? specialRequirements;
  final List<String> keyMoments;
  final String status; // pending, confirmed, ongoing, completed, cancelled
  final EventStatusTimestamps eventStatus;
  final double totalAmount;
  final double advanceAmount;
  final double remainingAmount;
  final String paymentStatus; // pending, advance_paid, fully_paid, refunded
  final List<PaymentRecord> payments;
  final String contactPerson;
  final String contactNumber;
  final String? alternateContact;
  final int expectedReelsCount;
  final String deliveryTimeline; // instant, same_day, next_day
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final DateTime? completedAt;

  EventBooking({
    required this.eventId,
    required this.customerId,
    required this.providerId,
    required this.eventType,
    required this.eventName,
    required this.eventDate,
    required this.eventTime,
    required this.duration,
    required this.guestCount,
    required this.venue,
    required this.packageId,
    required this.packageName,
    required this.packagePrice,
    this.customizations,
    this.specialRequirements,
    required this.keyMoments,
    required this.status,
    required this.eventStatus,
    required this.totalAmount,
    required this.advanceAmount,
    required this.remainingAmount,
    required this.paymentStatus,
    required this.payments,
    required this.contactPerson,
    required this.contactNumber,
    this.alternateContact,
    required this.expectedReelsCount,
    required this.deliveryTimeline,
    required this.createdAt,
    required this.updatedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.completedAt,
  });

  factory EventBooking.fromMap(Map<String, dynamic> data, String id) {
    return EventBooking(
      eventId: id,
      customerId: data['customerId'] ?? '',
      providerId: data['providerId'] ?? '',
      eventType: data['eventType'] ?? '',
      eventName: data['eventName'] ?? '',
      eventDate: data['eventDate'] is String ? DateTime.parse(data['eventDate']) : DateTime.now(),
      eventTime: data['eventTime'] ?? '',
      duration: data['duration'] ?? 0,
      guestCount: data['guestCount'] ?? 0,
      venue: VenueDetails.fromMap(data['venue']),
      packageId: data['packageId'] ?? '',
      packageName: data['packageName'] ?? '',
      packagePrice: (data['packagePrice'] ?? 0.0).toDouble(),
      customizations: data['customizations'] != null
          ? EventCustomizations.fromMap(data['customizations'])
          : null,
      specialRequirements: data['specialRequirements'],
      keyMoments: List<String>.from(data['keyMoments'] ?? []),
      status: data['status'] ?? 'pending',
      eventStatus: EventStatusTimestamps.fromMap(data['eventStatus'] ?? {}),
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      advanceAmount: (data['advanceAmount'] ?? 0.0).toDouble(),
      remainingAmount: (data['remainingAmount'] ?? 0.0).toDouble(),
      paymentStatus: data['paymentStatus'] ?? 'pending',
      payments: (data['payments'] as List?)
              ?.map((p) => PaymentRecord.fromMap(p))
              .toList() ??
          [],
      contactPerson: data['contactPerson'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      alternateContact: data['alternateContact'],
      expectedReelsCount: data['expectedReelsCount'] ?? 0,
      deliveryTimeline: data['deliveryTimeline'] ?? 'instant',
      createdAt: data['createdAt'] is String ? DateTime.parse(data['createdAt']) : DateTime.now(),
      updatedAt: data['updatedAt'] is String ? DateTime.parse(data['updatedAt']) : DateTime.now(),
      cancelledAt: data['cancelledAt'] != null && data['cancelledAt'] is String
          ? DateTime.parse(data['cancelledAt'])
          : null,
      cancellationReason: data['cancellationReason'],
      completedAt: data['completedAt'] != null && data['completedAt'] is String
          ? DateTime.parse(data['completedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'providerId': providerId,
      'eventType': eventType,
      'eventName': eventName,
      'eventDate': eventDate.toIso8601String(),
      'eventTime': eventTime,
      'duration': duration,
      'guestCount': guestCount,
      'venue': venue.toMap(),
      'packageId': packageId,
      'packageName': packageName,
      'packagePrice': packagePrice,
      'customizations': customizations?.toMap(),
      'specialRequirements': specialRequirements,
      'keyMoments': keyMoments,
      'status': status,
      'eventStatus': eventStatus.toMap(),
      'totalAmount': totalAmount,
      'advanceAmount': advanceAmount,
      'remainingAmount': remainingAmount,
      'paymentStatus': paymentStatus,
      'payments': payments.map((p) => p.toMap()).toList(),
      'contactPerson': contactPerson,
      'contactNumber': contactNumber,
      'alternateContact': alternateContact,
      'expectedReelsCount': expectedReelsCount,
      'deliveryTimeline': deliveryTimeline,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}

class VenueDetails {
  final String name;
  final String address;
  final String city;
  final String pincode;
  final double latitude;
  final double longitude;

  VenueDetails({
    required this.name,
    required this.address,
    required this.city,
    required this.pincode,
    required this.latitude,
    required this.longitude,
  });

  factory VenueDetails.fromMap(Map<String, dynamic> map) {
    return VenueDetails(
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      pincode: map['pincode'] ?? '',
      latitude: (map['coordinates']?['latitude'] ?? 0.0).toDouble(),
      longitude: (map['coordinates']?['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'city': city,
      'pincode': pincode,
      'coordinates': {
        'latitude': latitude,
        'longitude': longitude,
      },
    };
  }
}

class EventCustomizations {
  final String editingStyle;
  final String musicPreference;
  final String colorGrading;
  final bool includeDrone;
  final int additionalReels;
  final double additionalCost;

  EventCustomizations({
    required this.editingStyle,
    required this.musicPreference,
    required this.colorGrading,
    this.includeDrone = false,
    this.additionalReels = 0,
    this.additionalCost = 0.0,
  });

  factory EventCustomizations.fromMap(Map<String, dynamic> map) {
    return EventCustomizations(
      editingStyle: map['editingStyle'] ?? 'standard',
      musicPreference: map['musicPreference'] ?? 'bollywood',
      colorGrading: map['colorGrading'] ?? 'neutral',
      includeDrone: map['includeDrone'] ?? false,
      additionalReels: map['additionalReels'] ?? 0,
      additionalCost: (map['additionalCost'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'editingStyle': editingStyle,
      'musicPreference': musicPreference,
      'colorGrading': colorGrading,
      'includeDrone': includeDrone,
      'additionalReels': additionalReels,
      'additionalCost': additionalCost,
    };
  }
}

class EventStatusTimestamps {
  final DateTime? bookingConfirmed;
  final DateTime? providerAccepted;
  final DateTime? eventStarted;
  final DateTime? firstReelDelivered;
  final DateTime? eventCompleted;
  final DateTime? allReelsDelivered;

  EventStatusTimestamps({
    this.bookingConfirmed,
    this.providerAccepted,
    this.eventStarted,
    this.firstReelDelivered,
    this.eventCompleted,
    this.allReelsDelivered,
  });

  factory EventStatusTimestamps.fromMap(Map<String, dynamic> map) {
    return EventStatusTimestamps(
      bookingConfirmed: map['bookingConfirmed'] != null && map['bookingConfirmed'] is String
          ? DateTime.parse(map['bookingConfirmed'])
          : null,
      providerAccepted: map['providerAccepted'] != null && map['providerAccepted'] is String
          ? DateTime.parse(map['providerAccepted'])
          : null,
      eventStarted: map['eventStarted'] != null && map['eventStarted'] is String
          ? DateTime.parse(map['eventStarted'])
          : null,
      firstReelDelivered: map['firstReelDelivered'] != null && map['firstReelDelivered'] is String
          ? DateTime.parse(map['firstReelDelivered'])
          : null,
      eventCompleted: map['eventCompleted'] != null && map['eventCompleted'] is String
          ? DateTime.parse(map['eventCompleted'])
          : null,
      allReelsDelivered: map['allReelsDelivered'] != null && map['allReelsDelivered'] is String
          ? DateTime.parse(map['allReelsDelivered'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingConfirmed': bookingConfirmed?.toIso8601String(),
      'providerAccepted': providerAccepted?.toIso8601String(),
      'eventStarted': eventStarted?.toIso8601String(),
      'firstReelDelivered': firstReelDelivered?.toIso8601String(),
      'eventCompleted': eventCompleted?.toIso8601String(),
      'allReelsDelivered': allReelsDelivered?.toIso8601String(),
    };
  }
}

class PaymentRecord {
  final String paymentId;
  final double amount;
  final String method;
  final String transactionId;
  final String status;
  final DateTime paidAt;

  PaymentRecord({
    required this.paymentId,
    required this.amount,
    required this.method,
    required this.transactionId,
    required this.status,
    required this.paidAt,
  });

  factory PaymentRecord.fromMap(Map<String, dynamic> map) {
    return PaymentRecord(
      paymentId: map['paymentId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      method: map['method'] ?? '',
      transactionId: map['transactionId'] ?? '',
      status: map['status'] ?? '',
      paidAt: map['paidAt'] is String ? DateTime.parse(map['paidAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'paymentId': paymentId,
      'amount': amount,
      'method': method,
      'transactionId': transactionId,
      'status': status,
      'paidAt': paidAt.toIso8601String(),
    };
  }
}

