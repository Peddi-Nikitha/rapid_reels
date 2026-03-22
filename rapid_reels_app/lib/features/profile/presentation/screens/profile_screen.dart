import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/firebase_storage_image.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current logged-in user from Firebase Auth
    final currentUser = ref.watch(currentUserProvider);
    
    // If no user is logged in, show loading or redirect to login
    if (currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Get user profile from Firestore using StreamProvider (persistent state)
    final userId = currentUser.uid;
    debugPrint('Profile Screen - Current User ID: $userId');
    debugPrint('Profile Screen - Current User Email: ${currentUser.email}');
    debugPrint('Profile Screen - Current User Phone: ${currentUser.phoneNumber}');
    
    final userProfileAsync = ref.watch(userProfileProvider(userId));
    final userBookingsCount = ref.watch(userBookingsCountProvider(userId));
    final userReelsCount = ref.watch(userReelsCountProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: userProfileAsync.when(
        data: (userProfile) {
          // Debug: Print user profile data
          if (userProfile != null) {
            debugPrint('Profile Screen - User Profile Data:');
            debugPrint('  fullName: ${userProfile.fullName}');
            debugPrint('  email: ${userProfile.email}');
            debugPrint('  phoneNumber: ${userProfile.phoneNumber}');
            debugPrint('  totalEventsBooked: ${userProfile.totalEventsBooked}');
            debugPrint('  totalReelsReceived: ${userProfile.totalReelsReceived}');
            debugPrint('  walletBalance: ${userProfile.walletBalance}');
          } else {
            debugPrint('Profile Screen - User Profile is NULL');
          }
          
          // Use Firebase Auth user info as fallback if Firestore profile doesn't exist
          // Priority: Firestore fullName > Firebase Auth displayName > email username > phone > 'User'
          String displayName = 'User';
          if (userProfile != null && userProfile.fullName.trim().isNotEmpty) {
            displayName = userProfile.fullName;
          } else if (currentUser.displayName != null && currentUser.displayName!.trim().isNotEmpty) {
            displayName = currentUser.displayName!;
          } else if (currentUser.email != null) {
            displayName = currentUser.email!.split('@').first;
          } else if (currentUser.phoneNumber != null) {
            displayName = currentUser.phoneNumber!;
          }
          
          final email = userProfile?.email ?? currentUser.email;
          final phoneNumber = userProfile?.phoneNumber ?? currentUser.phoneNumber;
          final profileImageRaw = userProfile?.profileImage ?? currentUser.photoURL;
          final profileImageUrl = _resolveProfileImageUrl(profileImageRaw);
          
          // Get initials for profile picture
          String getInitials(String name) {
            if (name.isEmpty) return 'U';
            final parts = name.trim().split(' ');
            if (parts.length >= 2) {
              return (parts[0][0] + parts[1][0]).toUpperCase();
            }
            return name.substring(0, 1).toUpperCase();
          }
          
          final initials = getInitials(displayName);

          // Live stats:
          // - Events count from bookings collection (real-time stream)
          // - Reels count from reels collection (real-time stream)
          final stats = {
            'totalBookings': userBookingsCount.maybeWhen(
              data: (count) => count,
              orElse: () => userProfile?.totalEventsBooked ?? 0,
            ),
            'totalReels': userReelsCount.maybeWhen(
              data: (count) => count,
              orElse: () => userProfile?.totalReelsReceived ?? 0,
            ),
            'walletBalance': userProfile?.walletBalance ?? 0.0,
          };

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  color: AppColors.surface,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          _ProfileAvatar(
                            imageUrl: profileImageUrl,
                            initials: initials,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => context.push(AppRoutes.editProfile),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Display name - should show "test" from Firestore
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.editProfile),
                        child: Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Profile source label removed
                      const SizedBox(height: 4),
                      Text(
                        email ?? phoneNumber ?? 'N/A',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.editProfile),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Stats Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Events',
                          value: '${stats['totalBookings']}',
                          icon: Icons.event,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Reels',
                          value: '${stats['totalReels']}',
                          icon: Icons.video_library,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Menu Items
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildMenuSection(
                        title: 'Account',
                        items: [
                          _buildMenuItem(
                            icon: Icons.edit,
                            title: 'Edit Profile',
                            subtitle: 'Update your personal information',
                            onTap: () => context.push(AppRoutes.editProfile),
                          ),
                          _buildMenuItem(
                            icon: Icons.location_on,
                            title: 'My Venues',
                            subtitle: 'Manage saved venues and addresses',
                            onTap: () => context.push(AppRoutes.savedVenues),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildMenuSection(
                        title: 'App',
                        items: [
                          _buildMenuItem(
                            icon: Icons.settings,
                            title: 'Settings',
                            subtitle: 'App preferences and configurations',
                            onTap: () => context.push(AppRoutes.settings),
                          ),
                          _buildMenuItem(
                            icon: Icons.help,
                            title: 'Help & Support',
                            subtitle: 'Get help or contact us',
                            onTap: () => context.push(AppRoutes.support),
                          ),
                          _buildMenuItem(
                            icon: Icons.info,
                            title: 'About',
                            subtitle: 'Version 1.0.0',
                            onTap: () => _showAboutDialog(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildMenuSection(
                        title: 'Account Actions',
                        items: [
                          _buildMenuItem(
                            icon: Icons.logout,
                            title: 'Logout',
                            subtitle: 'Sign out from your account',
                            onTap: () => _showLogoutDialog(context, ref),
                            textColor: Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) {
          debugPrint('Profile Screen - Error loading profile: $error');
          debugPrint('Profile Screen - Stack trace: $stack');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading profile',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    error.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Refresh the profile
                    ref.invalidate(userProfileProvider(userId));
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                letterSpacing: 1,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.primary),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('About Rapid Reels'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('India\'s fastest event videography service'),
            SizedBox(height: 8),
            Text('© 2026 Rapid Reels'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Sign out using auth notifier
              final authNotifier = ref.read(authNotifierProvider.notifier);
              await authNotifier.signOut(ref);
              // Navigate to login page
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

/// Firestore sometimes stores `""`; invalid strings break [NetworkImage] without fallback.
String? _resolveProfileImageUrl(String? raw) {
  if (raw == null) return null;
  final s = raw.trim();
  if (s.isEmpty) return null;
  final uri = Uri.tryParse(s);
  if (uri == null || !uri.hasScheme) return null;
  if (uri.scheme != 'http' && uri.scheme != 'https') return null;
  return s;
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.imageUrl,
    required this.initials,
  });

  final String? imageUrl;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    final hasUrl = url != null && url.isNotEmpty;

    final placeholder = Container(
      color: AppColors.primary.withValues(alpha: 0.2),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );

    final errorWidget = _profileInitialsCircle(initials);

    Widget imageChild;
    if (!hasUrl) {
      imageChild = errorWidget;
    } else {
      final u = url;
      if (kIsWeb && isFirebaseStorageDownloadUrl(u)) {
        // Flutter web: raw Image.network hits CORS on Storage; SDK download works.
        imageChild = FirebaseStorageImage(
          url: u,
          fit: BoxFit.cover,
          width: 100,
          height: 100,
          placeholder: placeholder,
          errorWidget: errorWidget,
        );
      } else {
        imageChild = CachedNetworkImage(
        imageUrl: u,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
        memCacheWidth: 200,
        memCacheHeight: 200,
        fadeInDuration: const Duration(milliseconds: 150),
        placeholder: (_, __) => placeholder,
        errorWidget: (_, __, ___) => errorWidget,
      );
      }
    }

    return SizedBox(
      width: 100,
      height: 100,
      child: ClipOval(child: imageChild),
    );
  }
}

Widget _profileInitialsCircle(String initials) {
  return Container(
    width: 100,
    height: 100,
    color: AppColors.primary.withValues(alpha: 0.2),
    alignment: Alignment.center,
    child: Text(
      initials,
      style: const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    ),
  );
}

