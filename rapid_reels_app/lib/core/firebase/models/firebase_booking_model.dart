import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase Booking/Event Model
/// Collection: bookings
/// Document ID: bookingId
class FirebaseBookingModel {
  final String bookingId;
  final String customerId; // Reference to users collection
  final String providerId; // Reference to providers collection
  final String eventType; // wedding, birthday, engagement, corporate, brand
  final String eventName;
  final DateTime eventDate;
  final String eventTime;
  final int duration; // in minutes
  final int guestCount;
  final VenueData venue;
  final PackageData package;
  final CustomizationsData? customizations;
  final String? specialRequirements;
  final List<String>? keyMoments;
  final String status; // pending, confirmed, ongoing, completed, cancelled
  final EventStatusTimestamps eventStatus;
  final PaymentData payment;
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
  final Map<String, dynamic>? metadata;

  FirebaseBookingModel({
    required this.bookingId,
    required this.customerId,
    required this.providerId,
    required this.eventType,
    required this.eventName,
    required this.eventDate,
    required this.eventTime,
    required this.duration,
    required this.guestCount,
    required this.venue,
    required this.package,
    this.customizations,
    this.specialRequirements,
    this.keyMoments,
    required this.status,
    required this.eventStatus,
    required this.payment,
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
    this.metadata,
  });

  factory FirebaseBookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirebaseBookingModel(
      bookingId: doc.id,
      customerId: data['customerId'] ?? '',
      providerId: data['providerId'] ?? '',
      eventType: data['eventType'] ?? '',
      eventName: data['eventName'] ?? '',
      eventDate: (data['eventDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      eventTime: data['eventTime'] ?? '',
      duration: data['duration'] ?? 0,
      guestCount: data['guestCount'] ?? 0,
      venue: VenueData.fromMap(data['venue']),
      package: PackageData.fromMap(data['package']),
      customizations: data['customizations'] != null
          ? CustomizationsData.fromMap(data['customizations'])
          : null,
      specialRequirements: data['specialRequirements'],
      keyMoments: data['keyMoments'] != null
          ? List<String>.from(data['keyMoments'])
          : null,
      status: data['status'] ?? 'pending',
      eventStatus: EventStatusTimestamps.fromMap(data['eventStatus'] ?? {}),
      payment: PaymentData.fromMap(data['payment']),
      contactPerson: data['contactPerson'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      alternateContact: data['alternateContact'],
      expectedReelsCount: data['expectedReelsCount'] ?? 0,
      deliveryTimeline: data['deliveryTimeline'] ?? 'same_day',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      cancelledAt: (data['cancelledAt'] as Timestamp?)?.toDate(),
      cancellationReason: data['cancellationReason'],
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'providerId': providerId,
      'eventType': eventType,
      'eventName': eventName,
      'eventDate': Timestamp.fromDate(eventDate),
      'eventTime': eventTime,
      'duration': duration,
      'guestCount': guestCount,
      'venue': venue.toMap(),
      'package': package.toMap(),
      'customizations': customizations?.toMap(),
      'specialRequirements': specialRequirements,
      'keyMoments': keyMoments,
      'status': status,
      'eventStatus': eventStatus.toMap(),
      'payment': payment.toMap(),
      'contactPerson': contactPerson,
      'contactNumber': contactNumber,
      'alternateContact': alternateContact,
      'expectedReelsCount': expectedReelsCount,
      'deliveryTimeline': deliveryTimeline,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'cancellationReason': cancellationReason,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'metadata': metadata,
    };
  }

  FirebaseBookingModel copyWith({
    String? bookingId,
    String? customerId,
    String? providerId,
    String? eventType,
    String? eventName,
    DateTime? eventDate,
    String? eventTime,
    int? duration,
    int? guestCount,
    VenueData? venue,
    PackageData? package,
    CustomizationsData? customizations,
    String? specialRequirements,
    List<String>? keyMoments,
    String? status,
    EventStatusTimestamps? eventStatus,
    PaymentData? payment,
    String? contactPerson,
    String? contactNumber,
    String? alternateContact,
    int? expectedReelsCount,
    String? deliveryTimeline,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    DateTime? completedAt,
    Map<String, dynamic>? metadata,
  }) {
    return FirebaseBookingModel(
      bookingId: bookingId ?? this.bookingId,
      customerId: customerId ?? this.customerId,
      providerId: providerId ?? this.providerId,
      eventType: eventType ?? this.eventType,
      eventName: eventName ?? this.eventName,
      eventDate: eventDate ?? this.eventDate,
      eventTime: eventTime ?? this.eventTime,
      duration: duration ?? this.duration,
      guestCount: guestCount ?? this.guestCount,
      venue: venue ?? this.venue,
      package: package ?? this.package,
      customizations: customizations ?? this.customizations,
      specialRequirements: specialRequirements ?? this.specialRequirements,
      keyMoments: keyMoments ?? this.keyMoments,
      status: status ?? this.status,
      eventStatus: eventStatus ?? this.eventStatus,
      payment: payment ?? this.payment,
      contactPerson: contactPerson ?? this.contactPerson,
      contactNumber: contactNumber ?? this.contactNumber,
      alternateContact: alternateContact ?? this.alternateContact,
      expectedReelsCount: expectedReelsCount ?? this.expectedReelsCount,
      deliveryTimeline: deliveryTimeline ?? this.deliveryTimeline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      completedAt: completedAt ?? this.completedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

class VenueData {
  final String name;
  final String address;
  final String city;
  final String pincode;
  final double latitude;
  final double longitude;

  VenueData({
    required this.name,
    required this.address,
    required this.city,
    required this.pincode,
    required this.latitude,
    required this.longitude,
  });

  factory VenueData.fromMap(Map<String, dynamic> map) {
    return VenueData(
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

class PackageData {
  final String packageId;
  final String name;
  final double price;
  final int duration;
  final int reelsCount;
  final String editingStyle;
  final int deliveryTime; // in minutes
  final List<String> features;

  PackageData({
    required this.packageId,
    required this.name,
    required this.price,
    required this.duration,
    required this.reelsCount,
    required this.editingStyle,
    required this.deliveryTime,
    required this.features,
  });

  factory PackageData.fromMap(Map<String, dynamic> map) {
    return PackageData(
      packageId: map['packageId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      duration: map['duration'] ?? 0,
      reelsCount: map['reelsCount'] ?? 0,
      editingStyle: map['editingStyle'] ?? '',
      deliveryTime: map['deliveryTime'] ?? 0,
      features: List<String>.from(map['features'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'packageId': packageId,
      'name': name,
      'price': price,
      'duration': duration,
      'reelsCount': reelsCount,
      'editingStyle': editingStyle,
      'deliveryTime': deliveryTime,
      'features': features,
    };
  }
}

class CustomizationsData {
  final String editingStyle;
  final String musicPreference;
  final String colorGrading;
  final bool includeDrone;
  final int additionalReels;
  final double additionalCost;

  CustomizationsData({
    required this.editingStyle,
    required this.musicPreference,
    required this.colorGrading,
    required this.includeDrone,
    required this.additionalReels,
    required this.additionalCost,
  });

  factory CustomizationsData.fromMap(Map<String, dynamic> map) {
    return CustomizationsData(
      editingStyle: map['editingStyle'] ?? '',
      musicPreference: map['musicPreference'] ?? '',
      colorGrading: map['colorGrading'] ?? '',
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
      bookingConfirmed: (map['bookingConfirmed'] as Timestamp?)?.toDate(),
      providerAccepted: (map['providerAccepted'] as Timestamp?)?.toDate(),
      eventStarted: (map['eventStarted'] as Timestamp?)?.toDate(),
      firstReelDelivered: (map['firstReelDelivered'] as Timestamp?)?.toDate(),
      eventCompleted: (map['eventCompleted'] as Timestamp?)?.toDate(),
      allReelsDelivered: (map['allReelsDelivered'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingConfirmed': bookingConfirmed != null
          ? Timestamp.fromDate(bookingConfirmed!)
          : null,
      'providerAccepted': providerAccepted != null
          ? Timestamp.fromDate(providerAccepted!)
          : null,
      'eventStarted': eventStarted != null
          ? Timestamp.fromDate(eventStarted!)
          : null,
      'firstReelDelivered': firstReelDelivered != null
          ? Timestamp.fromDate(firstReelDelivered!)
          : null,
      'eventCompleted': eventCompleted != null
          ? Timestamp.fromDate(eventCompleted!)
          : null,
      'allReelsDelivered': allReelsDelivered != null
          ? Timestamp.fromDate(allReelsDelivered!)
          : null,
    };
  }
}

class PaymentData {
  final double totalAmount;
  final double advanceAmount;
  final double remainingAmount;
  final String paymentStatus; // pending, advance_paid, fully_paid, refunded
  final List<PaymentTransaction>? transactions;

  PaymentData({
    required this.totalAmount,
    required this.advanceAmount,
    required this.remainingAmount,
    required this.paymentStatus,
    this.transactions,
  });

  factory PaymentData.fromMap(Map<String, dynamic> map) {
    return PaymentData(
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      advanceAmount: (map['advanceAmount'] ?? 0.0).toDouble(),
      remainingAmount: (map['remainingAmount'] ?? 0.0).toDouble(),
      paymentStatus: map['paymentStatus'] ?? 'pending',
      transactions: map['transactions'] != null
          ? (map['transactions'] as List)
              .map((t) => PaymentTransaction.fromMap(t))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalAmount': totalAmount,
      'advanceAmount': advanceAmount,
      'remainingAmount': remainingAmount,
      'paymentStatus': paymentStatus,
      'transactions': transactions?.map((t) => t.toMap()).toList(),
    };
  }
}

class PaymentTransaction {
  final String paymentId;
  final double amount;
  final String method;
  final String transactionId;
  final String status;
  final DateTime paidAt;

  PaymentTransaction({
    required this.paymentId,
    required this.amount,
    required this.method,
    required this.transactionId,
    required this.status,
    required this.paidAt,
  });

  factory PaymentTransaction.fromMap(Map<String, dynamic> map) {
    return PaymentTransaction(
      paymentId: map['paymentId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      method: map['method'] ?? '',
      transactionId: map['transactionId'] ?? '',
      status: map['status'] ?? '',
      paidAt: (map['paidAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'paymentId': paymentId,
      'amount': amount,
      'method': method,
      'transactionId': transactionId,
      'status': status,
      'paidAt': Timestamp.fromDate(paidAt),
    };
  }
}

