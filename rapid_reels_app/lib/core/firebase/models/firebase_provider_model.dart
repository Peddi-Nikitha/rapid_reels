import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase Provider Model
/// Collection: providers
/// Document ID: providerId (same as userId in users collection)
class FirebaseProviderModel {
  final String providerId; // Reference to users collection
  final String businessName;
  final String ownerName;
  final String email;
  final String phoneNumber;
  final String profileImage;
  final List<String> coverImages;
  final String bio;
  final List<String> eventTypes;
  final List<PackageOffering> packages;
  final List<PortfolioItem> portfolio;
  final ProviderLocation location;
  final List<String> serviceAreas;
  final int serviceRadius; // in km
  final int teamSize;
  final List<String> equipment;
  final double rating;
  final int totalReviews;
  final int totalEventsCompleted;
  final int totalReelsDelivered;
  final int averageDeliveryTime; // in minutes
  final Map<String, DayAvailability> availability;
  final List<BlockedDate> blockedDates;
  final BankDetails? bankDetails;
  final double commissionRate;
  final bool isVerified;
  final bool isActive;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  FirebaseProviderModel({
    required this.providerId,
    required this.businessName,
    required this.ownerName,
    required this.email,
    required this.phoneNumber,
    required this.profileImage,
    required this.coverImages,
    required this.bio,
    required this.eventTypes,
    required this.packages,
    required this.portfolio,
    required this.location,
    required this.serviceAreas,
    required this.serviceRadius,
    required this.teamSize,
    required this.equipment,
    required this.rating,
    required this.totalReviews,
    required this.totalEventsCompleted,
    required this.totalReelsDelivered,
    required this.averageDeliveryTime,
    required this.availability,
    required this.blockedDates,
    this.bankDetails,
    required this.commissionRate,
    required this.isVerified,
    required this.isActive,
    required this.isFeatured,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  factory FirebaseProviderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirebaseProviderModel(
      providerId: doc.id,
      businessName: data['businessName'] ?? '',
      ownerName: data['ownerName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      profileImage: data['profileImage'] ?? '',
      coverImages: List<String>.from(data['coverImages'] ?? []),
      bio: data['bio'] ?? '',
      eventTypes: List<String>.from(data['eventTypes'] ?? []),
      packages: (data['packages'] as List?)
              ?.map((p) => PackageOffering.fromMap(p))
              .toList() ??
          [],
      portfolio: (data['portfolio'] as List?)
              ?.map((p) => PortfolioItem.fromMap(p))
              .toList() ??
          [],
      location: ProviderLocation.fromMap(data['location']),
      serviceAreas: List<String>.from(data['serviceAreas'] ?? []),
      serviceRadius: data['serviceRadius'] ?? 50,
      teamSize: data['teamSize'] ?? 1,
      equipment: List<String>.from(data['equipment'] ?? []),
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      totalEventsCompleted: data['totalEventsCompleted'] ?? 0,
      totalReelsDelivered: data['totalReelsDelivered'] ?? 0,
      averageDeliveryTime: data['averageDeliveryTime'] ?? 0,
      availability: (data['availability'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, DayAvailability.fromMap(value)),
          ) ??
          {},
      blockedDates: (data['blockedDates'] as List?)
              ?.map((d) => BlockedDate.fromMap(d))
              .toList() ??
          [],
      bankDetails: data['bankDetails'] != null
          ? BankDetails.fromMap(data['bankDetails'])
          : null,
      commissionRate: (data['commissionRate'] ?? 15.0).toDouble(),
      isVerified: data['isVerified'] ?? false,
      isActive: data['isActive'] ?? true,
      isFeatured: data['isFeatured'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'businessName': businessName,
      'ownerName': ownerName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'coverImages': coverImages,
      'bio': bio,
      'eventTypes': eventTypes,
      'packages': packages.map((p) => p.toMap()).toList(),
      'portfolio': portfolio.map((p) => p.toMap()).toList(),
      'location': location.toMap(),
      'serviceAreas': serviceAreas,
      'serviceRadius': serviceRadius,
      'teamSize': teamSize,
      'equipment': equipment,
      'rating': rating,
      'totalReviews': totalReviews,
      'totalEventsCompleted': totalEventsCompleted,
      'totalReelsDelivered': totalReelsDelivered,
      'averageDeliveryTime': averageDeliveryTime,
      'availability': availability.map((key, value) => MapEntry(key, value.toMap())),
      'blockedDates': blockedDates.map((d) => d.toMap()).toList(),
      'bankDetails': bankDetails?.toMap(),
      'commissionRate': commissionRate,
      'isVerified': isVerified,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'metadata': metadata,
    };
  }
}

class PackageOffering {
  final String packageId;
  final String name;
  final double price;
  final int duration;
  final int reelsCount;
  final String editingStyle;
  final int deliveryTime;
  final bool highlightVideo;
  final bool liveReelStation;
  final List<String> features;

  PackageOffering({
    required this.packageId,
    required this.name,
    required this.price,
    required this.duration,
    required this.reelsCount,
    required this.editingStyle,
    required this.deliveryTime,
    this.highlightVideo = false,
    this.liveReelStation = false,
    required this.features,
  });

  factory PackageOffering.fromMap(Map<String, dynamic> map) {
    return PackageOffering(
      packageId: map['packageId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      duration: map['duration'] ?? 0,
      reelsCount: map['reelsCount'] ?? 0,
      editingStyle: map['editingStyle'] ?? '',
      deliveryTime: map['deliveryTime'] ?? 0,
      highlightVideo: map['highlightVideo'] ?? false,
      liveReelStation: map['liveReelStation'] ?? false,
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
      'highlightVideo': highlightVideo,
      'liveReelStation': liveReelStation,
      'features': features,
    };
  }
}

class PortfolioItem {
  final String reelId; // Reference to reels collection
  final String eventType;
  final String thumbnailUrl;
  final String videoUrl;
  final int duration;
  final int views;
  final int likes;

  PortfolioItem({
    required this.reelId,
    required this.eventType,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.duration,
    required this.views,
    required this.likes,
  });

  factory PortfolioItem.fromMap(Map<String, dynamic> map) {
    return PortfolioItem(
      reelId: map['reelId'] ?? '',
      eventType: map['eventType'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      duration: map['duration'] ?? 0,
      views: map['views'] ?? 0,
      likes: map['likes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reelId': reelId,
      'eventType': eventType,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'duration': duration,
      'views': views,
      'likes': likes,
    };
  }
}

class ProviderLocation {
  final String address;
  final String city;
  final String state;
  final String pincode;
  final double latitude;
  final double longitude;

  ProviderLocation({
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.latitude,
    required this.longitude,
  });

  factory ProviderLocation.fromMap(Map<String, dynamic> map) {
    return ProviderLocation(
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      pincode: map['pincode'] ?? '',
      latitude: (map['coordinates']?['latitude'] ?? 0.0).toDouble(),
      longitude: (map['coordinates']?['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'coordinates': {
        'latitude': latitude,
        'longitude': longitude,
      },
    };
  }
}

class DayAvailability {
  final bool isOpen;
  final List<TimeSlot> slots;

  DayAvailability({required this.isOpen, required this.slots});

  factory DayAvailability.fromMap(Map<String, dynamic> map) {
    return DayAvailability(
      isOpen: map['isOpen'] ?? false,
      slots: (map['slots'] as List?)
              ?.map((s) => TimeSlot.fromMap(s))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isOpen': isOpen,
      'slots': slots.map((s) => s.toMap()).toList(),
    };
  }
}

class TimeSlot {
  final String startTime;
  final String endTime;
  final int slotDuration;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.slotDuration,
  });

  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      slotDuration: map['slotDuration'] ?? 60,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'slotDuration': slotDuration,
    };
  }
}

class BlockedDate {
  final DateTime date;
  final String reason;
  final String? bookingId;

  BlockedDate({
    required this.date,
    required this.reason,
    this.bookingId,
  });

  factory BlockedDate.fromMap(Map<String, dynamic> map) {
    return BlockedDate(
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reason: map['reason'] ?? '',
      bookingId: map['bookingId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'reason': reason,
      'bookingId': bookingId,
    };
  }
}

class BankDetails {
  final String accountNumber;
  final String ifscCode;
  final String accountHolderName;
  final String upiId;

  BankDetails({
    required this.accountNumber,
    required this.ifscCode,
    required this.accountHolderName,
    required this.upiId,
  });

  factory BankDetails.fromMap(Map<String, dynamic> map) {
    return BankDetails(
      accountNumber: map['accountNumber'] ?? '',
      ifscCode: map['ifscCode'] ?? '',
      accountHolderName: map['accountHolderName'] ?? '',
      upiId: map['upiId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      'accountHolderName': accountHolderName,
      'upiId': upiId,
    };
  }
}

