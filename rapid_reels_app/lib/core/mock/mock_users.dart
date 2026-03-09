import '../../features/auth/data/models/user_model.dart';

class MockUsers {
  static final UserModel currentUser = UserModel(
    userId: 'user_001',
    phoneNumber: '+919876543210',
    email: 'rajesh.kumar@example.com',
    fullName: 'Rajesh Kumar',
    profileImage: 'https://i.pravatar.cc/300?img=12',
    currentLocation: LocationData(
      city: 'Siddipet',
      state: 'Telangana',
      country: 'India',
      coordinates: Coordinates(latitude: 18.1023, longitude: 78.8514),
    ),
    savedAddresses: [
      SavedAddress(
        addressId: 'addr_001',
        label: 'Home',
        address: '123, MG Road, Siddipet',
        city: 'Siddipet',
        pincode: '502103',
        coordinates: Coordinates(latitude: 18.1023, longitude: 78.8514),
      ),
      SavedAddress(
        addressId: 'addr_002',
        label: 'Green Gardens Convention Hall',
        address: '456, Garden Road, Siddipet',
        city: 'Siddipet',
        pincode: '502103',
        coordinates: Coordinates(latitude: 18.1050, longitude: 78.8550),
      ),
    ],
    referralCode: 'RAJESH2024',
    walletBalance: 500.0,
    createdAt: DateTime.now().subtract(const Duration(days: 180)),
    updatedAt: DateTime.now(),
  );

  static final List<UserModel> allUsers = [
    currentUser,
    UserModel(
      userId: 'user_002',
      phoneNumber: '+919876543211',
      email: 'priya.sharma@example.com',
      fullName: 'Priya Sharma',
      profileImage: 'https://i.pravatar.cc/300?img=45',
      currentLocation: LocationData(
        city: 'Hyderabad',
        state: 'Telangana',
        country: 'India',
        coordinates: Coordinates(latitude: 17.3850, longitude: 78.4867),
      ),
      referralCode: 'PRIYA2024',
      walletBalance: 1200.0,
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
      updatedAt: DateTime.now(),
    ),
    UserModel(
      userId: 'user_003',
      phoneNumber: '+919876543212',
      email: 'amit.patel@example.com',
      fullName: 'Amit Patel',
      profileImage: 'https://i.pravatar.cc/300?img=33',
      currentLocation: LocationData(
        city: 'Mumbai',
        state: 'Maharashtra',
        country: 'India',
        coordinates: Coordinates(latitude: 19.0760, longitude: 72.8777),
      ),
      referralCode: 'AMIT2024',
      walletBalance: 800.0,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now(),
    ),
    UserModel(
      userId: 'user_004',
      phoneNumber: '+919876543213',
      email: 'sneha.reddy@example.com',
      fullName: 'Sneha Reddy',
      profileImage: 'https://i.pravatar.cc/300?img=20',
      currentLocation: LocationData(
        city: 'Bangalore',
        state: 'Karnataka',
        country: 'India',
        coordinates: Coordinates(latitude: 12.9716, longitude: 77.5946),
      ),
      referralCode: 'SNEHA2024',
      walletBalance: 300.0,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now(),
    ),
    UserModel(
      userId: 'user_005',
      phoneNumber: '+919876543214',
      email: 'vikram.singh@example.com',
      fullName: 'Vikram Singh',
      profileImage: 'https://i.pravatar.cc/300?img=15',
      currentLocation: LocationData(
        city: 'Delhi',
        state: 'Delhi',
        country: 'India',
        coordinates: Coordinates(latitude: 28.7041, longitude: 77.1025),
      ),
      referralCode: 'VIKRAM2024',
      walletBalance: 1500.0,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now(),
    ),
  ];

  static UserModel? getUserById(String userId) {
    try {
      return allUsers.firstWhere((user) => user.userId == userId);
    } catch (e) {
      return null;
    }
  }
}

