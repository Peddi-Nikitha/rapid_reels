import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/firebase_booking_model.dart';

/// JSON-safe maps for [FirebaseFunctions] (Firestore Timestamp as seconds/nanoseconds).
class BookingCallablePayload {
  static Map<String, dynamic> encode(FirebaseBookingModel booking) {
    return _encodeValue(booking.toFirestore()) as Map<String, dynamic>;
  }

  static dynamic _encodeValue(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) {
      return {'seconds': v.seconds, 'nanoseconds': v.nanoseconds};
    }
    if (v is Map) {
      return v.map((k, val) => MapEntry(k.toString(), _encodeValue(val)));
    }
    if (v is List) {
      return v.map(_encodeValue).toList();
    }
    return v;
  }
}

class BookingDateTakenException implements Exception {
  final String message;
  BookingDateTakenException(this.message);

  @override
  String toString() => message;
}
