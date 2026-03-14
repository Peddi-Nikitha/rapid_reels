import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase User Model - Main user collection
/// Collection: users
/// Document ID: userId (same as Firebase Auth UID)
class FirebaseUserModel {
  final String userId;
  final String? phoneNumber;
  final String? email;
  final String fullName;
  final String? profileImage;
  final String userType; // 'customer' or 'provider' or 'admin'
  final LocationData? currentLocation;
  final List<SavedAddress>? savedAddresses;
  final PreferencesData? preferences;
  final String? referralCode;
  final String? referredBy; // userId of referrer
  final double walletBalance;
  final int totalEventsBooked;
  final int totalReelsReceived;
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic>? metadata;

  FirebaseUserModel({
    required this.userId,
    this.phoneNumber,
    this.email,
    required this.fullName,
    this.profileImage,
    this.userType = 'customer',
    this.currentLocation,
    this.savedAddresses,
    this.preferences,
    this.referralCode,
    this.referredBy,
    this.walletBalance = 0.0,
    this.totalEventsBooked = 0,
    this.totalReelsReceived = 0,
    this.isActive = true,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.metadata,
  });

  factory FirebaseUserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirebaseUserModel(
      userId: doc.id,
      phoneNumber: data['phoneNumber'],
      email: data['email'],
      fullName: data['fullName'] ?? '',
      profileImage: data['profileImage'],
      userType: data['userType'] ?? 'customer',
      currentLocation: data['currentLocation'] != null
          ? LocationData.fromMap(data['currentLocation'])
          : null,
      savedAddresses: data['savedAddresses'] != null
          ? (data['savedAddresses'] as List)
              .map((addr) => SavedAddress.fromMap(addr))
              .toList()
          : null,
      preferences: data['preferences'] != null
          ? PreferencesData.fromMap(data['preferences'])
          : null,
      referralCode: data['referralCode'],
      referredBy: data['referredBy'],
      walletBalance: (data['walletBalance'] ?? 0.0).toDouble(),
      totalEventsBooked: data['totalEventsBooked'] ?? 0,
      totalReelsReceived: data['totalReelsReceived'] ?? 0,
      isActive: data['isActive'] ?? true,
      isVerified: data['isVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'phoneNumber': phoneNumber,
      'email': email,
      'fullName': fullName,
      'profileImage': profileImage,
      'userType': userType,
      'currentLocation': currentLocation?.toMap(),
      'savedAddresses': savedAddresses?.map((addr) => addr.toMap()).toList(),
      'preferences': preferences?.toMap(),
      'referralCode': referralCode,
      'referredBy': referredBy,
      'walletBalance': walletBalance,
      'totalEventsBooked': totalEventsBooked,
      'totalReelsReceived': totalReelsReceived,
      'isActive': isActive,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'metadata': metadata,
    };
  }

  FirebaseUserModel copyWith({
    String? userId,
    String? phoneNumber,
    String? email,
    String? fullName,
    String? profileImage,
    String? userType,
    LocationData? currentLocation,
    List<SavedAddress>? savedAddresses,
    PreferencesData? preferences,
    String? referralCode,
    String? referredBy,
    double? walletBalance,
    int? totalEventsBooked,
    int? totalReelsReceived,
    bool? isActive,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? metadata,
  }) {
    return FirebaseUserModel(
      userId: userId ?? this.userId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      profileImage: profileImage ?? this.profileImage,
      userType: userType ?? this.userType,
      currentLocation: currentLocation ?? this.currentLocation,
      savedAddresses: savedAddresses ?? this.savedAddresses,
      preferences: preferences ?? this.preferences,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      walletBalance: walletBalance ?? this.walletBalance,
      totalEventsBooked: totalEventsBooked ?? this.totalEventsBooked,
      totalReelsReceived: totalReelsReceived ?? this.totalReelsReceived,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

class LocationData {
  final String city;
  final String state;
  final String country;
  final Coordinates coordinates;

  LocationData({
    required this.city,
    required this.state,
    required this.country,
    required this.coordinates,
  });

  factory LocationData.fromMap(Map<String, dynamic> map) {
    return LocationData(
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      country: map['country'] ?? '',
      coordinates: Coordinates.fromMap(map['coordinates']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'city': city,
      'state': state,
      'country': country,
      'coordinates': coordinates.toMap(),
    };
  }
}

class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates({required this.latitude, required this.longitude});

  factory Coordinates.fromMap(Map<String, dynamic> map) {
    return Coordinates(
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class SavedAddress {
  final String addressId;
  final String label;
  final String address;
  final String city;
  final String pincode;
  final Coordinates coordinates;

  SavedAddress({
    required this.addressId,
    required this.label,
    required this.address,
    required this.city,
    required this.pincode,
    required this.coordinates,
  });

  factory SavedAddress.fromMap(Map<String, dynamic> map) {
    return SavedAddress(
      addressId: map['addressId'] ?? '',
      label: map['label'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      pincode: map['pincode'] ?? '',
      coordinates: Coordinates.fromMap(map['coordinates']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'addressId': addressId,
      'label': label,
      'address': address,
      'city': city,
      'pincode': pincode,
      'coordinates': coordinates.toMap(),
    };
  }
}

class PreferencesData {
  final List<String> favoriteEditingStyles;
  final List<String> favoriteMusic;
  final String? defaultEventType;
  final String? defaultCity;

  PreferencesData({
    required this.favoriteEditingStyles,
    required this.favoriteMusic,
    this.defaultEventType,
    this.defaultCity,
  });

  factory PreferencesData.fromMap(Map<String, dynamic> map) {
    return PreferencesData(
      favoriteEditingStyles: List<String>.from(map['favoriteEditingStyles'] ?? []),
      favoriteMusic: List<String>.from(map['favoriteMusic'] ?? []),
      defaultEventType: map['defaultEventType'],
      defaultCity: map['defaultCity'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'favoriteEditingStyles': favoriteEditingStyles,
      'favoriteMusic': favoriteMusic,
      'defaultEventType': defaultEventType,
      'defaultCity': defaultCity,
    };
  }
}

