class UserModel {
  final String userId;
  final String? phoneNumber;
  final String? email;
  final String fullName;
  final String? profileImage;
  final LocationData? currentLocation;
  final List<SavedAddress>? savedAddresses;
  final PreferencesData? preferences;
  final String? referralCode;
  final double walletBalance;
  final int totalEventsBooked;
  final int totalReelsReceived;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Getter aliases for convenience
  String get uid => userId;
  String? get profileImageUrl => profileImage;
  String get defaultCity => currentLocation?.city ?? preferences?.defaultCity ?? 'Mumbai';

  UserModel({
    required this.userId,
    this.phoneNumber,
    this.email,
    required this.fullName,
    this.profileImage,
    this.currentLocation,
    this.savedAddresses,
    this.preferences,
    this.referralCode,
    this.walletBalance = 0.0,
    this.totalEventsBooked = 0,
    this.totalReelsReceived = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      userId: id,
      phoneNumber: data['phoneNumber'],
      email: data['email'],
      fullName: data['fullName'] ?? '',
      profileImage: data['profileImage'],
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
      walletBalance: (data['walletBalance'] ?? 0.0).toDouble(),
      totalEventsBooked: data['totalEventsBooked'] ?? 0,
      totalReelsReceived: data['totalReelsReceived'] ?? 0,
      createdAt: data['createdAt'] is String ? DateTime.parse(data['createdAt']) : DateTime.now(),
      updatedAt: data['updatedAt'] is String ? DateTime.parse(data['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': phoneNumber,
      'email': email,
      'fullName': fullName,
      'profileImage': profileImage,
      'currentLocation': currentLocation?.toMap(),
      'savedAddresses': savedAddresses?.map((addr) => addr.toMap()).toList(),
      'preferences': preferences?.toMap(),
      'referralCode': referralCode,
      'walletBalance': walletBalance,
      'totalEventsBooked': totalEventsBooked,
      'totalReelsReceived': totalReelsReceived,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? userId,
    String? phoneNumber,
    String? email,
    String? fullName,
    String? profileImage,
    LocationData? currentLocation,
    List<SavedAddress>? savedAddresses,
    PreferencesData? preferences,
    String? referralCode,
    double? walletBalance,
    int? totalEventsBooked,
    int? totalReelsReceived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      profileImage: profileImage ?? this.profileImage,
      currentLocation: currentLocation ?? this.currentLocation,
      savedAddresses: savedAddresses ?? this.savedAddresses,
      preferences: preferences ?? this.preferences,
      referralCode: referralCode ?? this.referralCode,
      walletBalance: walletBalance ?? this.walletBalance,
      totalEventsBooked: totalEventsBooked ?? this.totalEventsBooked,
      totalReelsReceived: totalReelsReceived ?? this.totalReelsReceived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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

