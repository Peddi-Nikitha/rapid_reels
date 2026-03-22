import '../../../../core/firebase/models/firebase_booking_model.dart' as fb;
import '../models/event_booking_model.dart';

/// Mappers between Firebase booking model and app EventBooking model.
class BookingFirebaseMappers {
  /// Convert Firestore FirebaseBookingModel to EventBooking for UI/repository.
  static EventBooking toEventBooking(fb.FirebaseBookingModel b) {
    return EventBooking(
      eventId: b.bookingId,
      customerId: b.customerId,
      providerId: b.providerId,
      eventType: b.eventType,
      eventName: b.eventName,
      eventDate: b.eventDate,
      eventTime: b.eventTime,
      duration: b.duration,
      guestCount: b.guestCount,
      venue: VenueDetails.fromMap(b.venue.toMap()),
      packageId: b.package.packageId,
      packageName: b.package.name,
      packagePrice: b.package.price,
      customizations: b.customizations != null
          ? EventCustomizations.fromMap(b.customizations!.toMap())
          : null,
      specialRequirements: b.specialRequirements,
      keyMoments: b.keyMoments ?? [],
      status: b.status,
      eventStatus: EventStatusTimestamps(
        bookingConfirmed: b.eventStatus.bookingConfirmed,
        providerAccepted: b.eventStatus.providerAccepted,
        eventStarted: b.eventStatus.eventStarted,
        firstReelDelivered: b.eventStatus.firstReelDelivered,
        eventCompleted: b.eventStatus.eventCompleted,
        allReelsDelivered: b.eventStatus.allReelsDelivered,
      ),
      totalAmount: b.payment.totalAmount,
      advanceAmount: b.payment.advanceAmount,
      remainingAmount: b.payment.remainingAmount,
      paymentStatus: b.payment.paymentStatus,
      payments: b.payment.transactions
              ?.map((t) => PaymentRecord(
                    paymentId: t.paymentId,
                    amount: t.amount,
                    method: t.method,
                    transactionId: t.transactionId,
                    status: t.status,
                    paidAt: t.paidAt,
                  ))
              .toList() ??
          [],
      contactPerson: b.contactPerson,
      contactNumber: b.contactNumber,
      alternateContact: b.alternateContact,
      expectedReelsCount: b.expectedReelsCount,
      deliveryTimeline: b.deliveryTimeline,
      createdAt: b.createdAt,
      updatedAt: b.updatedAt,
      cancelledAt: b.cancelledAt,
      cancellationReason: b.cancellationReason,
      completedAt: b.completedAt,
      catalogueEventId: b.catalogueEventId,
      catalogueTitle: b.catalogueTitle,
      catalogueHeroUrl: b.catalogueHeroUrl,
    );
  }
}
