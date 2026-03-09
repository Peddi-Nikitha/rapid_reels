import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider Dashboard Stats
final providerStatsProvider = FutureProvider.family<ProviderStats, String>((ref, providerId) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return ProviderStats(
    totalBookings: 45,
    upcomingBookings: 8,
    completedBookings: 37,
    totalReelsDelivered: 234,
    averageRating: 4.8,
    totalEarnings: 125000.0,
    pendingPayouts: 15000.0,
    thisMonthEarnings: 28000.0,
  );
});

// Provider Earnings Data
final providerEarningsProvider = FutureProvider.family<List<EarningRecord>, String>((ref, providerId) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return [
    EarningRecord(
      id: 'earn_1',
      bookingId: 'evt_1',
      eventName: 'Rajesh & Priya Wedding',
      amount: 25000.0,
      commission: 3750.0,
      netAmount: 21250.0,
      date: DateTime.now().subtract(const Duration(days: 5)),
      status: PayoutStatus.paid,
    ),
    EarningRecord(
      id: 'earn_2',
      bookingId: 'evt_2',
      eventName: 'Amit Birthday Party',
      amount: 15000.0,
      commission: 2250.0,
      netAmount: 12750.0,
      date: DateTime.now().subtract(const Duration(days: 12)),
      status: PayoutStatus.pending,
    ),
  ];
});

// Live Event State Notifier
class LiveEventNotifier extends StateNotifier<LiveEventState> {
  LiveEventNotifier() : super(const LiveEventState());

  void startEvent(String eventId) {
    state = state.copyWith(
      eventId: eventId,
      isLive: true,
      startTime: DateTime.now(),
    );
  }

  void endEvent() {
    state = state.copyWith(
      isLive: false,
      endTime: DateTime.now(),
    );
  }

  void addShotCompleted(String shotName) {
    state = state.copyWith(
      completedShots: [...state.completedShots, shotName],
    );
  }

  void uploadFootage(String footageId) {
    state = state.copyWith(
      uploadedFootage: [...state.uploadedFootage, footageId],
    );
  }

  void deliverReel(String reelId) {
    state = state.copyWith(
      deliveredReels: [...state.deliveredReels, reelId],
    );
  }
}

// Live Event State
class LiveEventState {
  final String? eventId;
  final bool isLive;
  final DateTime? startTime;
  final DateTime? endTime;
  final List<String> completedShots;
  final List<String> uploadedFootage;
  final List<String> deliveredReels;

  const LiveEventState({
    this.eventId,
    this.isLive = false,
    this.startTime,
    this.endTime,
    this.completedShots = const [],
    this.uploadedFootage = const [],
    this.deliveredReels = const [],
  });

  LiveEventState copyWith({
    String? eventId,
    bool? isLive,
    DateTime? startTime,
    DateTime? endTime,
    List<String>? completedShots,
    List<String>? uploadedFootage,
    List<String>? deliveredReels,
  }) {
    return LiveEventState(
      eventId: eventId ?? this.eventId,
      isLive: isLive ?? this.isLive,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      completedShots: completedShots ?? this.completedShots,
      uploadedFootage: uploadedFootage ?? this.uploadedFootage,
      deliveredReels: deliveredReels ?? this.deliveredReels,
    );
  }
}

final liveEventNotifierProvider = StateNotifierProvider<LiveEventNotifier, LiveEventState>((ref) {
  return LiveEventNotifier();
});

// Reel Editor State Notifier
class ReelEditorNotifier extends StateNotifier<ReelEditorState> {
  ReelEditorNotifier() : super(const ReelEditorState());

  void selectClips(List<String> clipIds) {
    state = state.copyWith(selectedClips: clipIds);
  }

  void applyFilter(String filterId) {
    state = state.copyWith(selectedFilter: filterId);
  }

  void selectMusic(String musicId) {
    state = state.copyWith(selectedMusic: musicId);
  }

  void addTransition(String transitionId) {
    state = state.copyWith(
      transitions: [...state.transitions, transitionId],
    );
  }

  void setExporting(bool isExporting) {
    state = state.copyWith(isExporting: isExporting);
  }

  void reset() {
    state = const ReelEditorState();
  }
}

// Reel Editor State
class ReelEditorState {
  final List<String> selectedClips;
  final String? selectedFilter;
  final String? selectedMusic;
  final List<String> transitions;
  final bool isExporting;

  const ReelEditorState({
    this.selectedClips = const [],
    this.selectedFilter,
    this.selectedMusic,
    this.transitions = const [],
    this.isExporting = false,
  });

  ReelEditorState copyWith({
    List<String>? selectedClips,
    String? selectedFilter,
    String? selectedMusic,
    List<String>? transitions,
    bool? isExporting,
  }) {
    return ReelEditorState(
      selectedClips: selectedClips ?? this.selectedClips,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedMusic: selectedMusic ?? this.selectedMusic,
      transitions: transitions ?? this.transitions,
      isExporting: isExporting ?? this.isExporting,
    );
  }
}

final reelEditorNotifierProvider = StateNotifierProvider<ReelEditorNotifier, ReelEditorState>((ref) {
  return ReelEditorNotifier();
});

// Models
class ProviderStats {
  final int totalBookings;
  final int upcomingBookings;
  final int completedBookings;
  final int totalReelsDelivered;
  final double averageRating;
  final double totalEarnings;
  final double pendingPayouts;
  final double thisMonthEarnings;

  ProviderStats({
    required this.totalBookings,
    required this.upcomingBookings,
    required this.completedBookings,
    required this.totalReelsDelivered,
    required this.averageRating,
    required this.totalEarnings,
    required this.pendingPayouts,
    required this.thisMonthEarnings,
  });
}

enum PayoutStatus {
  pending,
  processing,
  paid,
  failed,
}

class EarningRecord {
  final String id;
  final String bookingId;
  final String eventName;
  final double amount;
  final double commission;
  final double netAmount;
  final DateTime date;
  final PayoutStatus status;

  EarningRecord({
    required this.id,
    required this.bookingId,
    required this.eventName,
    required this.amount,
    required this.commission,
    required this.netAmount,
    required this.date,
    required this.status,
  });
}

