import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_reels_app/core/booking/date_availability.dart';
import 'package:rapid_reels_app/core/firebase/models/firebase_provider_model.dart';

void main() {
  group('dateKeyLocal', () {
    test('stable local calendar formatting', () {
      final d = DateTime(2026, 4, 3, 15, 30);
      expect(dateKeyLocal(d), '2026-04-03');
    });

    test('normalizes UTC timestamp to local day before formatting', () {
      final utc = DateTime.utc(2026, 4, 10, 0, 0);
      expect(dateKeyLocal(utc), dateKeyLocal(utc.toLocal()));
    });
  });

  group('isWeekdayOpenForDate / empty availability', () {
    test('treats missing weekday as open', () {
      final p = _minimalProvider(availability: const {});
      final d = DateTime(2026, 4, 6); // Monday
      expect(isWeekdayOpenForDate(p, d), true);
    });

    test('respects closed weekday', () {
      final p = _minimalProvider(
        availability: {
          'monday': DayAvailability(isOpen: false, slots: const []),
        },
      );
      final mon = DateTime(2026, 4, 6);
      expect(isWeekdayOpenForDate(p, mon), false);
    });
  });

  group('isBlockedByProvider', () {
    test('detects blocked calendar day', () {
      final p = _minimalProvider(
        blockedDates: [
          BlockedDate(
            date: DateTime(2026, 5, 1, 10),
            reason: 'x',
          ),
        ],
      );
      expect(isBlockedByProvider(p, DateTime(2026, 5, 1)), true);
      expect(isBlockedByProvider(p, DateTime(2026, 5, 2)), false);
    });
  });

  group('isDateAvailableForProvider', () {
    test('false when day occupied', () {
      final p = _minimalProvider();
      final d = DateTime(2026, 6, 1);
      expect(
        isDateAvailableForProvider(p, d, {'2026-06-01'}),
        false,
      );
    });

    test('true when open and free', () {
      final p = _minimalProvider();
      final d = DateTime(2026, 6, 2);
      expect(
        isDateAvailableForProvider(p, d, {}),
        true,
      );
    });
  });

  group('bookingStatusBlocksDay', () {
    test('completed does not block', () {
      expect(bookingStatusBlocksDay('completed'), false);
    });
    test('pending blocks', () {
      expect(bookingStatusBlocksDay('pending'), true);
    });
  });
}

FirebaseProviderModel _minimalProvider({
  Map<String, DayAvailability> availability = const {},
  List<BlockedDate> blockedDates = const [],
}) {
  return FirebaseProviderModel(
    providerId: 'p1',
    businessName: 'Biz',
    ownerName: 'Owner',
    email: 'e@test',
    phoneNumber: '1',
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
    availability: availability,
    blockedDates: blockedDates,
    bankDetails: null,
    commissionRate: 0,
    isVerified: true,
    isActive: true,
    isFeatured: false,
    verificationStatus: 'approved',
    rejectionReason: null,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    metadata: null,
  );
}
