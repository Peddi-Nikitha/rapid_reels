import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../../core/mock/mock_reels.dart';
import '../../../booking/data/models/service_provider_model.dart';

// Selected City Provider
final selectedCityProvider = StateProvider<String>((ref) => 'Siddipet');

// Trending Reels Provider
final trendingReelsProvider = FutureProvider<List<ReelModel>>((ref) async {
  // Simulate API delay
  await Future.delayed(const Duration(milliseconds: 500));
  return MockReels.getTrendingReels();
});

// Featured Providers Provider
final featuredProvidersProvider = FutureProvider<List<ServiceProvider>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  final mockData = MockDataService();
  return mockData.getAllProviders().take(5).toList();
});

// Event Categories
final eventCategoriesProvider = Provider<List<EventCategory>>((ref) {
  return [
    EventCategory(
      id: 'wedding',
      name: 'Wedding',
      icon: '💍',
      color: 0xFFFF6B9D,
      description: 'Capture your special day',
    ),
    EventCategory(
      id: 'birthday',
      name: 'Birthday',
      icon: '🎂',
      color: 0xFFFFD700,
      description: 'Celebrate in style',
    ),
    EventCategory(
      id: 'engagement',
      name: 'Engagement',
      icon: '💑',
      color: 0xFFFF1493,
      description: 'Mark the beginning',
    ),
    EventCategory(
      id: 'corporate',
      name: 'Corporate',
      icon: '🏢',
      color: 0xFF4169E1,
      description: 'Professional events',
    ),
    EventCategory(
      id: 'brand',
      name: 'Brand Collab',
      icon: '🤝',
      color: 0xFF9370DB,
      description: 'Brand partnerships',
    ),
  ];
});

// Event Category Model
class EventCategory {
  final String id;
  final String name;
  final String icon;
  final int color;
  final String description;

  EventCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });
}

// Home Screen State Notifier
class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(const HomeState());

  void setSelectedCity(String city) {
    state = state.copyWith(selectedCity: city);
  }

  void setSelectedCategory(String? categoryId) {
    state = state.copyWith(selectedCategoryId: categoryId);
  }
}

// Home State
class HomeState {
  final String selectedCity;
  final String? selectedCategoryId;
  final bool isLoading;

  const HomeState({
    this.selectedCity = 'Siddipet',
    this.selectedCategoryId,
    this.isLoading = false,
  });

  HomeState copyWith({
    String? selectedCity,
    String? selectedCategoryId,
    bool? isLoading,
  }) {
    return HomeState(
      selectedCity: selectedCity ?? this.selectedCity,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final homeNotifierProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});

