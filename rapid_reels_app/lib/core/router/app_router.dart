import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Auth screens
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/phone_login_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/profile_setup_screen.dart';
import '../../features/auth/presentation/screens/city_selection_screen.dart';

// Booking screens
import '../../features/booking/presentation/screens/event_type_selection_screen.dart';
import '../../features/booking/presentation/screens/package_selection_screen.dart';
import '../../features/booking/presentation/screens/event_details_form_screen.dart';
import '../../features/booking/presentation/screens/venue_selection_screen.dart';
import '../../features/booking/presentation/screens/provider_selection_screen.dart';
import '../../features/booking/presentation/screens/provider_portfolio_screen.dart';
import '../../features/booking/presentation/screens/package_customization_screen.dart';
import '../../features/booking/presentation/screens/booking_summary_screen.dart';
import '../../features/booking/presentation/screens/payment_screen.dart';

// My Events screens
import '../../features/my_events/presentation/screens/my_events_screen.dart';
import '../../features/my_events/presentation/screens/event_details_screen.dart';
import '../../features/my_events/presentation/screens/live_event_tracking_screen.dart';

// Reels screens
import '../../features/reels/presentation/screens/my_reels_gallery_screen.dart';
import '../../features/reels/presentation/screens/reel_player_screen.dart';
import '../../features/reels/presentation/screens/reel_share_screen.dart';

// Discover screens
import '../../features/discover/presentation/screens/discover_feed_screen.dart';
import '../../features/discover/presentation/screens/trending_reels_screen.dart';

// Referral screens
import '../../features/referral/presentation/screens/referral_dashboard_screen.dart';
import '../../features/referral/presentation/screens/wallet_screen.dart';
import '../../features/referral/presentation/screens/referral_history_screen.dart';
import '../../features/referral/presentation/screens/redemption_screen.dart';

// Profile screens
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/saved_venues_screen.dart';
import '../../features/profile/presentation/screens/payment_methods_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/support_screen.dart';

// Provider screens
import '../../features/provider/presentation/screens/provider_login_screen.dart';
import '../../features/provider/presentation/screens/provider_dashboard_screen.dart';
import '../../features/provider/presentation/screens/provider_bookings_screen.dart';
import '../../features/provider/presentation/screens/provider_booking_details_screen.dart';
import '../../features/provider/presentation/screens/provider_booking_calendar_screen.dart';
import '../../features/provider/presentation/screens/provider_booking_timeline_screen.dart';
import '../../features/provider/presentation/screens/provider_customer_contact_screen.dart';
import '../../features/provider/presentation/screens/provider_venue_navigation_screen.dart';
import '../../features/provider/presentation/screens/provider_pre_event_checklist_screen.dart';
import '../../features/provider/presentation/screens/provider_booking_status_screen.dart';
import '../../features/provider/presentation/screens/live_event_mode_screen.dart';
import '../../features/provider/presentation/screens/reel_editor_screen.dart';
import '../../features/provider/presentation/screens/provider_earnings_screen.dart';
import '../../features/provider/presentation/screens/upload_footage_screen.dart';
import '../../features/provider/presentation/screens/provider_registration_screen.dart';
import '../../features/provider/presentation/screens/provider_business_profile_screen.dart';
import '../../features/provider/presentation/screens/provider_portfolio_upload_screen.dart';
import '../../features/provider/presentation/screens/provider_service_areas_screen.dart';
import '../../features/provider/presentation/screens/provider_document_upload_screen.dart';
import '../../features/provider/presentation/screens/provider_availability_calendar_screen.dart';
import '../../features/provider/presentation/screens/provider_verification_screen.dart';

// Admin screens
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_user_management_screen.dart';
import '../../features/admin/presentation/screens/admin_booking_management_screen.dart';
import '../../features/admin/presentation/screens/admin_provider_verification_screen.dart';
import '../../features/admin/presentation/screens/admin_content_moderation_screen.dart';
import '../../features/admin/presentation/screens/admin_analytics_screen.dart';
import '../../features/admin/presentation/screens/admin_payment_management_screen.dart';
import '../../features/admin/presentation/screens/admin_support_tickets_screen.dart';

// Main scaffold
import '../../shared/widgets/main_scaffold.dart';

// Constants
import '../constants/app_routes.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // ==================== Auth Routes ====================
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context,
          state,
          const SplashScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const PhoneLoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.otpVerification,
        name: 'otpVerification',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return _buildPageWithSlideTransition(
            context,
            state,
            OTPVerificationScreen(
              verificationId: extra?['verificationId'] ?? '',
              phoneNumber: extra?['phoneNumber'] ?? '',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        name: 'profileSetup',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const ProfileSetupScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.citySelection,
        name: 'citySelection',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const CitySelectionScreen(),
        ),
      ),

      // ==================== Main App (with Bottom Nav) ====================
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const MainScaffold(),
      ),

      // ==================== Booking Flow Routes ====================
      GoRoute(
        path: AppRoutes.eventTypeSelection,
        name: 'eventTypeSelection',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const EventTypeSelectionScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.packageSelection,
        name: 'packageSelection',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return _buildPageWithSlideTransition(
            context,
            state,
            PackageSelectionScreen(
              eventType: extra?['eventType'] ?? 'wedding',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.eventDetails,
        name: 'eventDetails',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return _buildPageWithSlideTransition(
            context,
            state,
            EventDetailsFormScreen(
              eventType: extra?['eventType'] ?? 'wedding',
              packageId: extra?['packageId'] ?? 'pkg_gold',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.venueSelection,
        name: 'venueSelection',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return _buildPageWithSlideTransition(
            context,
            state,
            VenueSelectionScreen(bookingData: extra ?? {}),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.providerSelection,
        name: 'providerSelection',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return _buildPageWithSlideTransition(
            context,
            state,
            ProviderSelectionScreen(bookingData: extra ?? {}),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.providerPortfolio,
        name: 'providerPortfolio',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return _buildPageWithSlideTransition(
            context,
            state,
            ProviderPortfolioScreen(
              provider: extra?['provider'],
              bookingData: extra?['bookingData'] ?? {},
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.packageCustomization,
        name: 'packageCustomization',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return _buildPageWithSlideTransition(
            context,
            state,
            PackageCustomizationScreen(bookingData: extra ?? {}),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.bookingSummary,
        name: 'bookingSummary',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return _buildPageWithSlideTransition(
            context,
            state,
            BookingSummaryScreen(bookingData: extra ?? {}),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.payment,
        name: 'payment',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final booking = extra?['booking'];
          if (booking == null) {
            // Handle missing booking - redirect or show error
            return _buildPageWithSlideTransition(
              context,
              state,
              const Scaffold(
                body: Center(child: Text('Booking information not found')),
              ),
            );
          }
          return _buildPageWithSlideTransition(
            context,
            state,
            PaymentScreen(
              booking: booking,
              isAdvancePayment: extra?['isAdvancePayment'] ?? true,
            ),
          );
        },
      ),

      // ==================== My Events Routes ====================
      GoRoute(
        path: AppRoutes.myEvents,
        name: 'myEvents',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const MyEventsScreen(),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.eventDetails2}/:eventId',
        name: 'eventDetailsView',
        pageBuilder: (context, state) {
          final eventId = state.pathParameters['eventId'] ?? '';
          return _buildPageWithSlideTransition(
            context,
            state,
            EventDetailsScreen(eventId: eventId),
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.eventTracking}/:eventId',
        name: 'eventTracking',
        pageBuilder: (context, state) {
          final eventId = state.pathParameters['eventId'] ?? '';
          return _buildPageWithSlideTransition(
            context,
            state,
            LiveEventTrackingScreen(eventId: eventId),
          );
        },
      ),

      // ==================== Reels Routes ====================
      GoRoute(
        path: AppRoutes.reels,
        name: 'reelsGallery',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context,
          state,
          const MyReelsGalleryScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.reelPlayer,
        name: 'reelPlayer',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return _buildPageWithFadeTransition(
            context,
            state,
            ReelPlayerScreen(
              reelId: extra?['reelId'] ?? '',
              reels: extra?['reels'] ?? [],
              initialIndex: extra?['initialIndex'] ?? 0,
            ),
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.reelDetails}/:reelId/share',
        name: 'reelShare',
        pageBuilder: (context, state) {
          final reelId = state.pathParameters['reelId'] ?? '';
          return _buildPageWithSlideTransition(
            context,
            state,
            ReelShareScreen(reelId: reelId),
          );
        },
      ),

      // ==================== Discover Routes ====================
      GoRoute(
        path: AppRoutes.discover,
        name: 'discover',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context,
          state,
          const DiscoverFeedScreen(),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.discover}/trending',
        name: 'trending',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const TrendingReelsScreen(),
        ),
      ),

      // ==================== Referral & Wallet Routes ====================
      GoRoute(
        path: AppRoutes.referralDashboard,
        name: 'referralDashboard',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const ReferralDashboardScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.wallet,
        name: 'wallet',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const WalletScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.referralHistory,
        name: 'referralHistory',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const ReferralHistoryScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.redemption,
        name: 'redemption',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const RedemptionScreen(),
        ),
      ),

      // ==================== Profile Routes ====================
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context,
          state,
          const ProfileScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        name: 'editProfile',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const EditProfileScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.savedVenues,
        name: 'savedVenues',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const SavedVenuesScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.paymentMethods,
        name: 'paymentMethods',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const PaymentMethodsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.support,
        name: 'support',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const SupportScreen(),
        ),
      ),

      // ==================== Provider App Routes ====================
      GoRoute(
        path: '${AppRoutes.providerDashboard}/:providerId',
        name: 'providerDashboard',
        pageBuilder: (context, state) {
          final providerId = state.pathParameters['providerId'] ?? '';
          return _buildPageWithSlideTransition(
            context,
            state,
            ProviderDashboardScreen(providerId: providerId),
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.providerBookings}/:providerId',
        name: 'providerBookings',
        pageBuilder: (context, state) {
          final providerId = state.pathParameters['providerId'] ?? '';
          return _buildPageWithSlideTransition(
            context,
            state,
            ProviderBookingsScreen(providerId: providerId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.liveEventMode,
        name: 'liveEventMode',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context,
          state,
          const LiveEventModeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.reelEditor,
        name: 'reelEditor',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const ReelEditorScreen(),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.providerEarnings}/:providerId',
        name: 'providerEarnings',
        pageBuilder: (context, state) {
          final providerId = state.pathParameters['providerId'] ?? '';
          return _buildPageWithSlideTransition(
            context,
            state,
            ProviderEarningsScreen(providerId: providerId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.uploadFootage,
        name: 'uploadFootage',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const UploadFootageScreen(),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.providerBookingCalendar}/:providerId',
        name: 'providerBookingCalendar',
        pageBuilder: (context, state) {
          final providerId = state.pathParameters['providerId'] ?? '';
          return _buildPageWithSlideTransition(
            context,
            state,
            ProviderBookingCalendarScreen(providerId: providerId),
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.providerBookingTimeline}/:providerId/:bookingId',
        name: 'providerBookingTimeline',
        pageBuilder: (context, state) {
          final providerId = state.pathParameters['providerId'] ?? '';
          final bookingId = state.pathParameters['bookingId'] ?? '';
          return _buildPageWithSlideTransition(
            context,
            state,
            ProviderBookingTimelineScreen(
              providerId: providerId,
              bookingId: bookingId,
            ),
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.providerCustomerContact}/:providerId/:bookingId',
        name: 'providerCustomerContact',
        pageBuilder: (context, state) {
          final providerId = state.pathParameters['providerId'] ?? '';
          final bookingId = state.pathParameters['bookingId'] ?? '';
          return _buildPageWithSlideTransition(
            context,
            state,
            ProviderCustomerContactScreen(
              providerId: providerId,
              bookingId: bookingId,
            ),
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.providerVenueNavigation}/:providerId/:bookingId',
        name: 'providerVenueNavigation',
        pageBuilder: (context, state) {
          final providerId = state.pathParameters['providerId'] ?? '';
          final bookingId = state.pathParameters['bookingId'] ?? '';
          return _buildPageWithSlideTransition(
            context,
            state,
            ProviderVenueNavigationScreen(
              providerId: providerId,
              bookingId: bookingId,
            ),
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.providerPreEventChecklist}/:providerId/:bookingId',
        name: 'providerPreEventChecklist',
        pageBuilder: (context, state) {
          final providerId = state.pathParameters['providerId'] ?? '';
          final bookingId = state.pathParameters['bookingId'] ?? '';
          return _buildPageWithSlideTransition(
            context,
            state,
            ProviderPreEventChecklistScreen(
              providerId: providerId,
              bookingId: bookingId,
            ),
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.providerBookingStatus}/:providerId/:bookingId',
        name: 'providerBookingStatus',
        pageBuilder: (context, state) {
          final providerId = state.pathParameters['providerId'] ?? '';
          final bookingId = state.pathParameters['bookingId'] ?? '';
          return _buildPageWithSlideTransition(
            context,
            state,
            ProviderBookingStatusScreen(
              providerId: providerId,
              bookingId: bookingId,
            ),
          );
        },
      ),

      // ==================== Provider Authentication Routes ====================
      GoRoute(
        path: AppRoutes.providerLogin,
        name: 'providerLogin',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const ProviderLoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.providerRegistration,
        name: 'providerRegistration',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const ProviderRegistrationScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.providerBusinessProfile,
        name: 'providerBusinessProfile',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const ProviderBusinessProfileScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.providerPortfolioUpload,
        name: 'providerPortfolioUpload',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const ProviderPortfolioUploadScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.providerServiceAreas,
        name: 'providerServiceAreas',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const ProviderServiceAreasScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.providerDocumentUpload,
        name: 'providerDocumentUpload',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const ProviderDocumentUploadScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.providerAvailabilityCalendar,
        name: 'providerAvailabilityCalendar',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const ProviderAvailabilityCalendarScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.providerVerification,
        name: 'providerVerification',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const ProviderVerificationScreen(),
        ),
      ),

      // ==================== Admin Routes ====================
      GoRoute(
        path: AppRoutes.adminDashboard,
        name: 'adminDashboard',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const AdminDashboardScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.adminUserManagement,
        name: 'adminUserManagement',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const AdminUserManagementScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.adminBookingManagement,
        name: 'adminBookingManagement',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const AdminBookingManagementScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.adminProviderVerification,
        name: 'adminProviderVerification',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const AdminProviderVerificationScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.adminContentModeration,
        name: 'adminContentModeration',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const AdminContentModerationScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.adminAnalytics,
        name: 'adminAnalytics',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const AdminAnalyticsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.adminPaymentManagement,
        name: 'adminPaymentManagement',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const AdminPaymentManagementScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.adminSupportTickets,
        name: 'adminSupportTickets',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const AdminSupportTicketsScreen(),
        ),
      ),
    ],
    
    // Error handler
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.error?.toString() ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );

  // ==================== Page Transition Builders ====================

  static CustomTransitionPage _buildPageWithSlideTransition(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static CustomTransitionPage _buildPageWithFadeTransition(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

}

