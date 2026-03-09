import '../../features/booking/data/models/event_booking_model.dart';

class MockEvents {
  static final List<EventBooking> allEvents = [
    // Upcoming Events
    EventBooking(
      eventId: 'event_001',
      customerId: 'user_001',
      providerId: 'provider_001',
      eventType: 'wedding',
      eventName: 'Rajesh & Priya Wedding',
      eventDate: DateTime.now().add(const Duration(days: 15)),
      eventTime: '10:00 AM',
      duration: 360,
      guestCount: 500,
      venue: VenueDetails(
        name: 'Green Gardens Convention Hall',
        address: '456, Garden Road, Siddipet, Telangana',
        city: 'Siddipet',
        pincode: '502103',
        latitude: 18.1050,
        longitude: 78.8550,
      ),
      packageId: 'pkg_gold',
      packageName: 'Gold',
      packagePrice: 25000,
      customizations: EventCustomizations(
        editingStyle: 'cinematic',
        musicPreference: 'bollywood',
        colorGrading: 'warm',
        includeDrone: true,
        additionalReels: 2,
        additionalCost: 6000,
      ),
      specialRequirements: 'Please focus on couple entry and ring ceremony. Need reels ready before reception starts.',
      keyMoments: [
        'Bride Entry',
        'Groom Entry',
        'Varmala Ceremony',
        'Ring Exchange',
        'First Dance',
      ],
      status: 'confirmed',
      eventStatus: EventStatusTimestamps(
        bookingConfirmed: DateTime.now().subtract(const Duration(days: 5)),
        providerAccepted: DateTime.now().subtract(const Duration(days: 4)),
      ),
      totalAmount: 31000,
      advanceAmount: 15500,
      remainingAmount: 15500,
      paymentStatus: 'advance_paid',
      payments: [
        PaymentRecord(
          paymentId: 'pay_001',
          amount: 15500,
          method: 'razorpay',
          transactionId: 'txn_abc123',
          status: 'success',
          paidAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ],
      contactPerson: 'Rajesh Kumar',
      contactNumber: '+919876543210',
      alternateContact: '+919876543211',
      expectedReelsCount: 7,
      deliveryTimeline: 'instant',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    
    EventBooking(
      eventId: 'event_002',
      customerId: 'user_001',
      providerId: 'provider_003',
      eventType: 'birthday',
      eventName: 'Aarav\'s 5th Birthday',
      eventDate: DateTime.now().add(const Duration(days: 7)),
      eventTime: '4:00 PM',
      duration: 120,
      guestCount: 50,
      venue: VenueDetails(
        name: 'Home',
        address: '123, MG Road, Siddipet, Telangana',
        city: 'Siddipet',
        pincode: '502103',
        latitude: 18.1023,
        longitude: 78.8514,
      ),
      packageId: 'pkg_bronze',
      packageName: 'Bronze',
      packagePrice: 8000,
      keyMoments: [
        'Cake Cutting',
        'Games',
        'Gift Opening',
      ],
      status: 'confirmed',
      eventStatus: EventStatusTimestamps(
        bookingConfirmed: DateTime.now().subtract(const Duration(days: 2)),
        providerAccepted: DateTime.now().subtract(const Duration(days: 1)),
      ),
      totalAmount: 8000,
      advanceAmount: 4000,
      remainingAmount: 4000,
      paymentStatus: 'advance_paid',
      payments: [
        PaymentRecord(
          paymentId: 'pay_002',
          amount: 4000,
          method: 'razorpay',
          transactionId: 'txn_def456',
          status: 'success',
          paidAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ],
      contactPerson: 'Rajesh Kumar',
      contactNumber: '+919876543210',
      expectedReelsCount: 1,
      deliveryTimeline: 'same_day',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),

    // Live Event
    EventBooking(
      eventId: 'event_003',
      customerId: 'user_002',
      providerId: 'provider_002',
      eventType: 'engagement',
      eventName: 'Priya & Rohit Engagement',
      eventDate: DateTime.now(),
      eventTime: '6:00 PM',
      duration: 240,
      guestCount: 200,
      venue: VenueDetails(
        name: 'The Grand Banquet',
        address: '789, Jubilee Hills, Hyderabad, Telangana',
        city: 'Hyderabad',
        pincode: '500033',
        latitude: 17.4326,
        longitude: 78.4071,
      ),
      packageId: 'pkg_silver',
      packageName: 'Silver',
      packagePrice: 15000,
      keyMoments: [
        'Ring Exchange',
        'Couple Entry',
        'Family Photos',
      ],
      status: 'ongoing',
      eventStatus: EventStatusTimestamps(
        bookingConfirmed: DateTime.now().subtract(const Duration(days: 20)),
        providerAccepted: DateTime.now().subtract(const Duration(days: 19)),
        eventStarted: DateTime.now().subtract(const Duration(hours: 2)),
        firstReelDelivered: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      totalAmount: 15000,
      advanceAmount: 7500,
      remainingAmount: 7500,
      paymentStatus: 'advance_paid',
      payments: [
        PaymentRecord(
          paymentId: 'pay_003',
          amount: 7500,
          method: 'razorpay',
          transactionId: 'txn_ghi789',
          status: 'success',
          paidAt: DateTime.now().subtract(const Duration(days: 20)),
        ),
      ],
      contactPerson: 'Priya Sharma',
      contactNumber: '+919876543211',
      expectedReelsCount: 3,
      deliveryTimeline: 'instant',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),

    // Past Events
    EventBooking(
      eventId: 'event_004',
      customerId: 'user_001',
      providerId: 'provider_001',
      eventType: 'wedding',
      eventName: 'Amit & Sneha Wedding',
      eventDate: DateTime.now().subtract(const Duration(days: 30)),
      eventTime: '11:00 AM',
      duration: 360,
      guestCount: 400,
      venue: VenueDetails(
        name: 'Royal Palace',
        address: '234, Banjara Hills, Hyderabad, Telangana',
        city: 'Hyderabad',
        pincode: '500034',
        latitude: 17.4239,
        longitude: 78.4738,
      ),
      packageId: 'pkg_platinum',
      packageName: 'Platinum',
      packagePrice: 45000,
      customizations: EventCustomizations(
        editingStyle: 'cinematic',
        musicPreference: 'bollywood',
        colorGrading: 'warm',
        includeDrone: true,
        additionalReels: 0,
        additionalCost: 0,
      ),
      keyMoments: [
        'Baraat Entry',
        'Bride Entry',
        'Varmala',
        'Phere',
        'Vidai',
      ],
      status: 'completed',
      eventStatus: EventStatusTimestamps(
        bookingConfirmed: DateTime.now().subtract(const Duration(days: 60)),
        providerAccepted: DateTime.now().subtract(const Duration(days: 59)),
        eventStarted: DateTime.now().subtract(const Duration(days: 30)),
        firstReelDelivered: DateTime.now().subtract(const Duration(days: 30)),
        eventCompleted: DateTime.now().subtract(const Duration(days: 30)),
        allReelsDelivered: DateTime.now().subtract(const Duration(days: 30)),
      ),
      totalAmount: 45000,
      advanceAmount: 22500,
      remainingAmount: 22500,
      paymentStatus: 'fully_paid',
      payments: [
        PaymentRecord(
          paymentId: 'pay_004',
          amount: 22500,
          method: 'razorpay',
          transactionId: 'txn_jkl012',
          status: 'success',
          paidAt: DateTime.now().subtract(const Duration(days: 60)),
        ),
        PaymentRecord(
          paymentId: 'pay_005',
          amount: 22500,
          method: 'razorpay',
          transactionId: 'txn_mno345',
          status: 'success',
          paidAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
      ],
      contactPerson: 'Rajesh Kumar',
      contactNumber: '+919876543210',
      expectedReelsCount: 10,
      deliveryTimeline: 'instant',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      completedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),

    EventBooking(
      eventId: 'event_005',
      customerId: 'user_001',
      providerId: 'provider_004',
      eventType: 'corporate',
      eventName: 'TechCorp Annual Day',
      eventDate: DateTime.now().subtract(const Duration(days: 45)),
      eventTime: '5:00 PM',
      duration: 180,
      guestCount: 300,
      venue: VenueDetails(
        name: 'Hyderabad Convention Center',
        address: '567, Madhapur, Hyderabad, Telangana',
        city: 'Hyderabad',
        pincode: '500081',
        latitude: 17.4485,
        longitude: 78.3908,
      ),
      packageId: 'pkg_gold',
      packageName: 'Gold',
      packagePrice: 25000,
      keyMoments: [
        'CEO Speech',
        'Award Ceremony',
        'Team Performance',
      ],
      status: 'completed',
      eventStatus: EventStatusTimestamps(
        bookingConfirmed: DateTime.now().subtract(const Duration(days: 75)),
        providerAccepted: DateTime.now().subtract(const Duration(days: 74)),
        eventStarted: DateTime.now().subtract(const Duration(days: 45)),
        firstReelDelivered: DateTime.now().subtract(const Duration(days: 45)),
        eventCompleted: DateTime.now().subtract(const Duration(days: 45)),
        allReelsDelivered: DateTime.now().subtract(const Duration(days: 45)),
      ),
      totalAmount: 25000,
      advanceAmount: 12500,
      remainingAmount: 12500,
      paymentStatus: 'fully_paid',
      payments: [
        PaymentRecord(
          paymentId: 'pay_006',
          amount: 12500,
          method: 'razorpay',
          transactionId: 'txn_pqr678',
          status: 'success',
          paidAt: DateTime.now().subtract(const Duration(days: 75)),
        ),
        PaymentRecord(
          paymentId: 'pay_007',
          amount: 12500,
          method: 'razorpay',
          transactionId: 'txn_stu901',
          status: 'success',
          paidAt: DateTime.now().subtract(const Duration(days: 45)),
        ),
      ],
      contactPerson: 'Rajesh Kumar',
      contactNumber: '+919876543210',
      expectedReelsCount: 5,
      deliveryTimeline: 'instant',
      createdAt: DateTime.now().subtract(const Duration(days: 75)),
      updatedAt: DateTime.now().subtract(const Duration(days: 45)),
      completedAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
  ];

  static EventBooking? getEventById(String eventId) {
    try {
      return allEvents.firstWhere((event) => event.eventId == eventId);
    } catch (e) {
      return null;
    }
  }

  static List<EventBooking> getUserEvents(String userId) {
    return allEvents.where((event) => event.customerId == userId).toList();
  }

  static List<EventBooking> getUpcomingEvents(String userId) {
    return allEvents
        .where((event) =>
            event.customerId == userId &&
            event.eventDate.isAfter(DateTime.now()) &&
            (event.status == 'confirmed' || event.status == 'pending'))
        .toList();
  }

  static List<EventBooking> getLiveEvents(String userId) {
    return allEvents
        .where((event) =>
            event.customerId == userId &&
            event.status == 'ongoing')
        .toList();
  }

  static List<EventBooking> getPastEvents(String userId) {
    return allEvents
        .where((event) =>
            event.customerId == userId &&
            (event.status == 'completed' || event.status == 'cancelled'))
        .toList();
  }

  static List<EventBooking> getProviderEvents(String providerId) {
    return allEvents
        .where((event) => event.providerId == providerId)
        .toList();
  }
}

