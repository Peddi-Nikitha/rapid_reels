import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../admin/admin_route_cache.dart';
import 'router_refresh_notifier.dart';

// Auth screens
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/phone_login_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/unauthorized_screen.dart';
import '../../features/auth/presentation/screens/profile_setup_screen.dart';
import '../../features/auth/presentation/screens/city_selection_screen.dart';

// Booking screens
import '../../features/booking/presentation/screens/event_type_selection_screen.dart';
import '../../features/booking/presentation/screens/package_selection_screen.dart';
import '../../features/booking/presentation/screens/event_details_form_screen.dart';
import '../../features/booking/presentation/screens/venue_selection_screen.dart';
import '../../features/booking/presentation/screens/provider_selection_screen.dart';
import '../../features/booking/presentation/screens/provider_portfolio_screen.dart';
import '../../features/providers/presentation/screens/provider_details_screen.dart';
import '../../features/booking/presentation/screens/catalogue_selection_screen.dart';
import '../../features/booking/presentation/screens/provider_package_pick_screen.dart';
import '../../features/booking/data/models/service_provider_model.dart';
import '../../features/booking/presentation/screens/package_customization_screen.dart';
import '../../features/booking/presentation/screens/booking_summary_screen.dart';
import '../../features/booking/presentation/screens/payment_screen.dart';
import '../../features/booking/presentation/screens/payment_success_screen.dart';
import '../../features/booking/presentation/screens/payment_failure_screen.dart';
import '../../features/booking/presentation/screens/my_transactions_screen.dart';

// My Events screens
import '../../features/my_events/presentation/screens/dynamic_my_events_screen.dart';
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
import '../../features/profile/presentation/screens/my_tickets_screen.dart';
import '../../features/profile/presentation/screens/refund_cancellation_policy_screen.dart';

// Provider screens
import '../../features/provider/presentation/screens/provider_login_screen.dart';
import '../../features/provider/presentation/screens/provider_dashboard_screen.dart';
import '../../features/provider/presentation/screens/provider_bookings_screen.dart';
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
import '../../features/provider/presentation/screens/provider_my_reels_screen.dart';
import '../../features/provider/presentation/screens/provider_registration_screen.dart';
import '../../features/provider/presentation/screens/provider_business_profile_screen.dart';
import '../../features/provider/presentation/screens/provider_portfolio_upload_screen.dart';
import '../../features/provider/presentation/screens/provider_service_areas_screen.dart';
import '../../features/provider/presentation/screens/provider_document_upload_screen.dart';
import '../../features/provider/presentation/screens/provider_availability_calendar_screen.dart';
import '../../features/provider/presentation/screens/provider_verification_screen.dart';
import '../../features/provider/presentation/screens/provider_catalogue_list_screen.dart';
import '../../features/provider/presentation/screens/provider_catalogue_edit_screen.dart';
import '../../features/provider/presentation/screens/provider_portal_shell.dart';
import '../../features/provider/presentation/screens/provider_schedule_screen.dart';
import '../../features/provider/presentation/screens/provider_account_screen.dart';
import '../../core/theme/provider_app_theme.dart';

// Admin screens
import '../../features/admin/presentation/screens/admin_login_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_user_management_screen.dart';
import '../../features/admin/presentation/screens/admin_booking_management_screen.dart';
import '../../features/admin/presentation/screens/admin_provider_verification_screen.dart';
import '../../features/admin/presentation/screens/admin_content_moderation_screen.dart';
import '../../features/admin/presentation/screens/admin_analytics_screen.dart';
import '../../features/admin/presentation/screens/admin_payment_management_screen.dart';
import '../../features/admin/presentation/screens/admin_provider_earnings_screen.dart';
import '../../features/admin/presentation/screens/admin_offers_management_screen.dart';
import '../../features/admin/presentation/screens/admin_reviews_moderation_screen.dart';

// Main scaffold
import '../../shared/widgets/main_scaffold.dart';

// Constants
import '../constants/app_routes.dart';
import '../firebase/models/firebase_reel_model.dart';

Widget _providerThemed(Widget child) => ProviderAppTheme.wrap(child);

bool _isProtectedAdminRoute(String location) {
  return location.startsWith('/admin-') && location != AppRoutes.adminLogin;
}

Future<String?> _adminGuardRedirect(
  BuildContext context,
  GoRouterState state,
) async {
  final loc = state.matchedLocation;
  if (!_isProtectedAdminRoute(loc)) return null;
  if (loc == AppRoutes.adminLogin || loc == AppRoutes.unauthorized) return null;

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return AppRoutes.adminLogin;

  try {
    final isAdmin = await AdminRouteCache.isCurrentUserAdmin();
    if (!isAdmin) return AppRoutes.unauthorized;
  } catch (_) {
    return AppRoutes.unauthorized;
  }
  return null;
}

/// Web-safe: `state.extra` may be `LinkedMap<dynamic, dynamic>`, not `Map<String, dynamic>`.
Map<String, dynamic> _extraMap(Object? extra) {
  if (extra == null) return <String, dynamic>{};
  if (extra is Map<String, dynamic>) return extra;
  return Map<String, dynamic>.from(extra as Map);
}

/// Nested maps from `extra` (e.g. `bookingData`) may also be `LinkedMap` on web.
Map<String, dynamic> _nestedStringMap(Object? value) {
  if (value == null) return <String, dynamic>{};
  if (value is Map<String, dynamic>) return value;
  return Map<String, dynamic>.from(value as Map);
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: appRouterAuthRefresh,
    redirect: _adminGuardRedirect,
    routes: [
      // ==================== Auth Routes ====================
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (context, state) =>
            _buildPageWithFadeTransition(context, state, const SplashScreen()),
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
          final extra = _extraMap(state.extra);
          return _buildPageWithSlideTransition(
            context,
            state,
            OTPVerificationScreen(
              verificationId: extra['verificationId'] as String? ?? '',
              phoneNumber: extra['phoneNumber'] as String? ?? '',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.unauthorized,
        name: 'unauthorized',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const UnauthorizedScreen(),
        ),
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
        builder: (context, state) {
          final initialTab = state.extra is int ? state.extra as int : 0;
          return MainScaffold(initialTabIndex: initialTab);
        },
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
          final extra = _extraMap(state.extra);
          return _buildPageWithSlideTransition(
            context,
            state,
            PackageSelectionScreen(
              eventType: extra['eventType'] as String? ?? 'wedding',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.eventDetails,
        name: 'eventDetails',
        pageBuilder: (context, state) {
          final extra = _extraMap(state.extra);
          return _buildPageWithSlideTransition(
            context,
            state,
            EventDetailsFormScreen(
              eventType: extra['eventType'] as String? ?? 'wedding',
              packageId: extra['packageId'] as String? ?? 'pkg_gold',
              package: extra['package'] as Map<String, dynamic>?,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.venueSelection,
        name: 'venueSelection',
        pageBuilder: (context, state) {
          final extra = _extraMap(state.extra);
          return _buildPageWithSlideTransition(
            context,
            state,
            VenueSelectionScreen(bookingData: extra),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.providerSelection,
        name: 'providerSelection',
        pageBuilder: (context, state) {
          final extra = _extraMap(state.extra);
          return _buildPageWithSlideTransition(
            context,
            state,
            ProviderSelectionScreen(bookingData: extra),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.providerPortfolio,
        name: 'providerPortfolio',
        pageBuilder: (context, state) {
          final extra = _extraMap(state.extra);
          final provider = extra['provider'] as ServiceProvider?;
          if (provider == null) {
            return _buildPageWithSlideTransition(
              context,
              state,
              const Scaffold(body: Center(child: Text('Provider not found'))),
            );
          }
          return _buildPageWithSlideTransition(
            context,
            state,
            ProviderPortfolioScreen(
              provider: provider,
              bookingData: _nestedStringMap(extra['bookingData']),
            ),
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.providerDetails}/:providerId',
        name: 'providerDetails',
        pageBuilder: (context, state) {
          final extra = _extraMap(state.extra);
          final providerId = state.pathParameters['providerId'] ?? '';
          final bookingRaw = extra['bookingData'];
          final bookingData = bookingRaw != null
              ? _nestedStringMap(bookingRaw)
              : null;
          return _buildPageWithSlideTransition(
            context,
            state,
            ProviderDetailsScreen(
              providerId: providerId,
              bookingData: bookingData,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.catalogueSelection,
        name: 'catalogueSelection',
        pageBuilder: (context, state) {
          final extra = _extraMap(state.extra);
          final provider = extra['provider'] as ServiceProvider?;
          if (provider == null) {
            return _buildPageWithSlideTransition(
              context,
              state,
              const Scaffold(
                body: Center(child: Text('Missing booking context')),
              ),
            );
          }
          final bookingData = _nestedStringMap(extra['bookingData']);
          return _buildPageWithSlideTransition(
            context,
            state,
            CatalogueSelectionScreen(
              provider: provider,
              bookingData: bookingData,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.providerPackagePick,
        name: 'providerPackagePick',
        pageBuilder: (context, state) {
          final extra = _extraMap(state.extra);
          final provider = extra['provider'] as ServiceProvider?;
          if (provider == null) {
            return _buildPageWithSlideTransition(
              context,
              state,
              const Scaffold(
                body: Center(child: Text('Missing booking context')),
              ),
            );
          }
          final bookingData = _nestedStringMap(extra['bookingData']);
          return _buildPageWithSlideTransition(
            context,
            state,
            ProviderPackagePickScreen(
              provider: provider,
              bookingData: bookingData,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.packageCustomization,
        name: 'packageCustomization',
        pageBuilder: (context, state) {
          final extra = _extraMap(state.extra);
          return _buildPageWithSlideTransition(
            context,
            state,
            PackageCustomizationScreen(bookingData: extra),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.bookingSummary,
        name: 'bookingSummary',
        pageBuilder: (context, state) {
          final extra = _extraMap(state.extra);
          return _buildPageWithSlideTransition(
            context,
            state,
            BookingSummaryScreen(bookingData: extra),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.payment,
        name: 'payment',
        pageBuilder: (context, state) {
          final extra = _extraMap(state.extra);
          final booking = extra['booking'];
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
              isAdvancePayment: _parseBool(extra['isAdvancePayment'], true),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.paymentSuccess,
        name: 'paymentSuccess',
        pageBuilder: (context, state) {
          final extra = _extraMap(state.extra);
          return _buildPageWithSlideTransition(
            context,
            state,
            PaymentSuccessScreen(
              bookingId: extra['bookingId']?.toString() ?? '',
              paymentId: extra['paymentId']?.toString() ?? '',
              amount: (extra['amount'] as num?)?.toDouble() ?? 0,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.paymentFailure,
        name: 'paymentFailure',
        pageBuilder: (context, state) {
          final extra = _extraMap(state.extra);
          return _buildPageWithSlideTransition(
            context,
            state,
            PaymentFailureScreen(
              message: extra['message']?.toString() ?? 'Payment failed',
              bookingData: _nestedStringMap(extra['bookingData']),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.myTransactions,
        name: 'myTransactions',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const MyTransactionsScreen(),
        ),
      ),

      // ==================== My Events Routes ====================
      GoRoute(
        path: AppRoutes.myEvents,
        name: 'myEvents',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const DynamicMyEventsScreen(),
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
          final extra = _extraMap(state.extra);
          List<FirebaseReelModel> reels = [];
          if (extra['reels'] != null) {
            reels = (extra['reels'] as List).cast<FirebaseReelModel>();
          } else if (extra['reel'] != null) {
            reels = [extra['reel'] as FirebaseReelModel];
          }
          final reelIdFromExtra = extra['reelId'] as String?;
          final resolvedReelId =
              reelIdFromExtra ?? (reels.isNotEmpty ? reels.first.reelId : '');
          return _buildPageWithFadeTransition(
            context,
            state,
            ReelPlayerScreen(
              reelId: resolvedReelId,
              reels: reels,
              initialIndex: _parseInt(
                extra['initialIndex'],
                0,
              ).clamp(0, reels.isEmpty ? 0 : reels.length - 1),
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
        pageBuilder: (context, state) =>
            _buildPageWithSlideTransition(context, state, const WalletScreen()),
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
        pageBuilder: (context, state) =>
            _buildPageWithFadeTransition(context, state, const ProfileScreen()),
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
        pageBuilder: (context, state) =>
            _buildPageWithSlideTransition(context, state, SavedVenuesScreen()),
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
      GoRoute(
        path: AppRoutes.myTickets,
        name: 'myTickets',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const MyTicketsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.refundCancellationPolicy,
        name: 'refundCancellationPolicy',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const RefundCancellationPolicyScreen(),
        ),
      ),

      // ==================== Provider App Routes ====================
      GoRoute(
        path: '${AppRoutes.providerDashboard}/:providerId',
        redirect: (context, state) {
          final id = state.pathParameters['providerId'];
          if (id == null || id.isEmpty) return null;
          return '${AppRoutes.providerPortal}/$id/home';
        },
      ),
      GoRoute(
        path: '${AppRoutes.providerBookings}/:providerId',
        redirect: (context, state) {
          final id = state.pathParameters['providerId'];
          if (id == null || id.isEmpty) return null;
          return '${AppRoutes.providerPortal}/$id/bookings';
        },
      ),
      GoRoute(
        path: '${AppRoutes.providerPortal}/:providerId',
        redirect: (context, state) {
          final segs = state.uri.pathSegments;
          if (segs.length == 2 && segs[0] == 'provider-portal') {
            return '${AppRoutes.providerPortal}/${segs[1]}/home';
          }
          return null;
        },
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              final id = state.pathParameters['providerId'] ?? '';
              return ProviderAppTheme.wrap(
                ProviderPortalShell(
                  providerId: id,
                  navigationShell: navigationShell,
                ),
              );
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'home',
                    name: 'providerPortalHome',
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['providerId'] ?? '';
                      return NoTransitionPage<void>(
                        key: state.pageKey,
                        child: ProviderDashboardScreen(providerId: id),
                      );
                    },
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'schedule',
                    name: 'providerPortalSchedule',
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['providerId'] ?? '';
                      return NoTransitionPage<void>(
                        key: state.pageKey,
                        child: ProviderScheduleScreen(providerId: id),
                      );
                    },
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'bookings',
                    name: 'providerPortalBookings',
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['providerId'] ?? '';
                      return NoTransitionPage<void>(
                        key: state.pageKey,
                        child: ProviderBookingsScreen(providerId: id),
                      );
                    },
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'earnings',
                    name: 'providerPortalEarnings',
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['providerId'] ?? '';
                      return NoTransitionPage<void>(
                        key: state.pageKey,
                        child: ProviderEarningsScreen(providerId: id),
                      );
                    },
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'account',
                    name: 'providerPortalAccount',
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['providerId'] ?? '';
                      return NoTransitionPage<void>(
                        key: state.pageKey,
                        child: ProviderAccountScreen(providerId: id),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.liveEventMode,
        name: 'liveEventMode',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context,
          state,
          _providerThemed(const LiveEventModeScreen()),
        ),
      ),
      GoRoute(
        path: AppRoutes.reelEditor,
        name: 'reelEditor',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          _providerThemed(const ReelEditorScreen()),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.providerEarnings}/:providerId',
        redirect: (context, state) {
          final id = state.pathParameters['providerId'];
          if (id == null || id.isEmpty) return null;
          return '${AppRoutes.providerPortal}/$id/earnings';
        },
      ),
      GoRoute(
        path: AppRoutes.uploadFootage,
        name: 'uploadFootage',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          _providerThemed(const UploadFootageScreen()),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.providerMyReels}/:providerId',
        name: 'providerMyReels',
        pageBuilder: (context, state) {
          final providerId = state.pathParameters['providerId'] ?? '';
          return _buildPageWithSlideTransition(
            context,
            state,
            _providerThemed(ProviderMyReelsScreen(providerId: providerId)),
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.providerCatalogue}/:providerId',
        name: 'providerCatalogue',
        pageBuilder: (context, state) {
          final providerId = state.pathParameters['providerId'] ?? '';
          return _buildPageWithSlideTransition(
            context,
            state,
            _providerThemed(ProviderCatalogueListScreen(providerId: providerId)),
          );
        },
      ),
      GoRoute(
        path:
            '${AppRoutes.providerCatalogueEdit}/:providerId/:catalogueEventId',
        name: 'providerCatalogueEdit',
        pageBuilder: (context, state) {
          final providerId = state.pathParameters['providerId'] ?? '';
          final catalogueEventId =
              state.pathParameters['catalogueEventId'] ?? 'new';
          return _buildPageWithSlideTransition(
            context,
            state,
            _providerThemed(
              ProviderCatalogueEditScreen(
                providerId: providerId,
                catalogueEventId: catalogueEventId,
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.providerBookingCalendar}/:providerId',
        name: 'providerBookingCalendar',
        pageBuilder: (context, state) {
          final providerId = state.pathParameters['providerId'] ?? '';
          return _buildPageWithSlideTransition(
            context,
            state,
            _providerThemed(
              ProviderBookingCalendarScreen(providerId: providerId),
            ),
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
            _providerThemed(
              ProviderBookingTimelineScreen(
                providerId: providerId,
                bookingId: bookingId,
              ),
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
            _providerThemed(
              ProviderCustomerContactScreen(
                providerId: providerId,
                bookingId: bookingId,
              ),
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
            _providerThemed(
              ProviderVenueNavigationScreen(
                providerId: providerId,
                bookingId: bookingId,
              ),
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
            _providerThemed(
              ProviderPreEventChecklistScreen(
                providerId: providerId,
                bookingId: bookingId,
              ),
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
            _providerThemed(
              ProviderBookingStatusScreen(
                providerId: providerId,
                bookingId: bookingId,
              ),
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
          _providerThemed(const ProviderLoginScreen()),
        ),
      ),
      GoRoute(
        path: AppRoutes.providerRegistration,
        name: 'providerRegistration',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          _providerThemed(const ProviderRegistrationScreen()),
        ),
      ),
      GoRoute(
        path: AppRoutes.providerBusinessProfile,
        name: 'providerBusinessProfile',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          _providerThemed(const ProviderBusinessProfileScreen()),
        ),
      ),
      GoRoute(
        path: AppRoutes.providerPortfolioUpload,
        name: 'providerPortfolioUpload',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          _providerThemed(const ProviderPortfolioUploadScreen()),
        ),
      ),
      GoRoute(
        path: AppRoutes.providerServiceAreas,
        name: 'providerServiceAreas',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          _providerThemed(const ProviderServiceAreasScreen()),
        ),
      ),
      GoRoute(
        path: AppRoutes.providerDocumentUpload,
        name: 'providerDocumentUpload',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          _providerThemed(const ProviderDocumentUploadScreen()),
        ),
      ),
      GoRoute(
        path: AppRoutes.providerAvailabilityCalendar,
        name: 'providerAvailabilityCalendar',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          _providerThemed(const ProviderAvailabilityCalendarScreen()),
        ),
      ),
      GoRoute(
        path: AppRoutes.providerVerification,
        name: 'providerVerification',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          _providerThemed(const ProviderVerificationScreen()),
        ),
      ),

      // ==================== Admin Routes ====================
      GoRoute(
        path: AppRoutes.adminLogin,
        name: 'adminLogin',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const AdminLoginScreen(),
        ),
      ),
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
        path: AppRoutes.adminOffersManagement,
        name: 'adminOffersManagement',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const AdminOffersManagementScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.adminReviewsModeration,
        name: 'adminReviewsModeration',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const AdminReviewsModerationScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.adminProviderEarnings,
        name: 'adminProviderEarnings',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const AdminProviderEarningsScreen(),
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

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  static int _parseInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static bool _parseBool(dynamic value, bool defaultValue) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return defaultValue;
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
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
