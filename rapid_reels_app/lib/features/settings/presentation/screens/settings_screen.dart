import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';

/// Comprehensive Settings Screen
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _pushNotifications = true;
  bool _darkMode = true;
  bool _autoPlayVideos = true;
  bool _dataSaver = false;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'INR (₹)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Account Section
          _buildSectionHeader('Account'),
          _buildMenuCard([
            _buildMenuItem(
              'Profile Information',
              Icons.person_outline,
              AppColors.primary,
              () {},
            ),
            _buildMenuItem(
              'Change Password',
              Icons.lock_outline,
              Colors.orange,
              () {},
            ),
            _buildMenuItem(
              'Privacy Settings',
              Icons.privacy_tip_outlined,
              Colors.purple,
              () {},
            ),
            _buildMenuItem(
              'Linked Accounts',
              Icons.link,
              Colors.blue,
              () {},
            ),
          ]),

          const SizedBox(height: 24),

          // Notifications Section
          _buildSectionHeader('Notifications'),
          _buildMenuCard([
            _buildSwitchTile(
              'Enable Notifications',
              Icons.notifications_outlined,
              AppColors.primary,
              _notificationsEnabled,
              (value) => setState(() => _notificationsEnabled = value),
            ),
            _buildSwitchTile(
              'Email Notifications',
              Icons.email_outlined,
              Colors.blue,
              _emailNotifications,
              (value) => setState(() => _emailNotifications = value),
            ),
            _buildSwitchTile(
              'SMS Notifications',
              Icons.sms_outlined,
              Colors.green,
              _smsNotifications,
              (value) => setState(() => _smsNotifications = value),
            ),
            _buildSwitchTile(
              'Push Notifications',
              Icons.notifications_active_outlined,
              Colors.orange,
              _pushNotifications,
              (value) => setState(() => _pushNotifications = value),
            ),
          ]),

          const SizedBox(height: 24),

          // Appearance Section
          _buildSectionHeader('Appearance'),
          _buildMenuCard([
            _buildSwitchTile(
              'Dark Mode',
              Icons.dark_mode_outlined,
              Colors.indigo,
              _darkMode,
              (value) => setState(() => _darkMode = value),
            ),
            _buildMenuItem(
              'Language',
              Icons.language,
              Colors.teal,
              () {
                _showLanguageDialog();
              },
              trailing: _selectedLanguage,
            ),
            _buildMenuItem(
              'Currency',
              Icons.currency_rupee,
              Colors.amber,
              () {
                _showCurrencyDialog();
              },
              trailing: _selectedCurrency,
            ),
          ]),

          const SizedBox(height: 24),

          // App Preferences Section
          _buildSectionHeader('App Preferences'),
          _buildMenuCard([
            _buildSwitchTile(
              'Auto-play Videos',
              Icons.play_circle_outline,
              Colors.red,
              _autoPlayVideos,
              (value) => setState(() => _autoPlayVideos = value),
            ),
            _buildSwitchTile(
              'Data Saver Mode',
              Icons.data_saver_on,
              Colors.green,
              _dataSaver,
              (value) => setState(() => _dataSaver = value),
            ),
            _buildMenuItem(
              'Download Quality',
              Icons.high_quality,
              Colors.purple,
              () {
                _showQualityDialog();
              },
              trailing: 'High',
            ),
            _buildMenuItem(
              'Cache Settings',
              Icons.storage,
              Colors.orange,
              () {
                _showCacheDialog();
              },
            ),
          ]),

          const SizedBox(height: 24),

          // Payment & Billing Section
          _buildSectionHeader('Payment & Billing'),
          _buildMenuCard([
            _buildMenuItem(
              'Payment Methods',
              Icons.credit_card,
              Colors.blue,
              () {},
            ),
            _buildMenuItem(
              'Billing History',
              Icons.receipt_long,
              Colors.green,
              () {},
            ),
            _buildMenuItem(
              'Auto-pay Settings',
              Icons.autorenew,
              Colors.purple,
              () {},
            ),
          ]),

          const SizedBox(height: 24),

          // Security Section
          _buildSectionHeader('Security'),
          _buildMenuCard([
            _buildMenuItem(
              'Two-Factor Authentication',
              Icons.security,
              Colors.green,
              () {},
              trailing: 'Enabled',
            ),
            _buildMenuItem(
              'Biometric Login',
              Icons.fingerprint,
              Colors.blue,
              () {},
            ),
            _buildMenuItem(
              'Active Sessions',
              Icons.devices,
              Colors.orange,
              () {},
            ),
            _buildMenuItem(
              'Login History',
              Icons.history,
              Colors.purple,
              () {},
            ),
          ]),

          const SizedBox(height: 24),

          // Support & Legal Section
          _buildSectionHeader('Support & Legal'),
          _buildMenuCard([
            _buildMenuItem(
              'Help Center',
              Icons.help_outline,
              Colors.blue,
              () {},
            ),
            _buildMenuItem(
              'Contact Support',
              Icons.support_agent,
              Colors.green,
              () {},
            ),
            _buildMenuItem(
              'Terms of Service',
              Icons.description,
              Colors.grey,
              () {},
            ),
            _buildMenuItem(
              'Privacy Policy',
              Icons.policy,
              Colors.grey,
              () {},
            ),
            _buildMenuItem(
              'Licenses',
              Icons.copyright,
              Colors.grey,
              () {},
            ),
          ]),

          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader('About'),
          _buildMenuCard([
            _buildMenuItem(
              'App Version',
              Icons.info_outline,
              AppColors.primary,
              () {},
              trailing: '1.0.0',
            ),
            _buildMenuItem(
              'Check for Updates',
              Icons.system_update,
              Colors.blue,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('You\'re up to date!')),
                );
              },
            ),
            _buildMenuItem(
              'Rate Us',
              Icons.star_outline,
              Colors.amber,
              () {},
            ),
            _buildMenuItem(
              'Share App',
              Icons.share,
              Colors.green,
              () {},
            ),
          ]),

          const SizedBox(height: 24),

          // Danger Zone
          _buildSectionHeader('Danger Zone'),
          _buildMenuCard([
            _buildMenuItem(
              'Clear Cache',
              Icons.cleaning_services,
              Colors.orange,
              () {
                _showClearCacheDialog();
              },
            ),
            _buildMenuItem(
              'Delete Account',
              Icons.delete_forever,
              Colors.red,
              () {
                _showDeleteAccountDialog();
              },
            ),
          ]),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildMenuItem(
    String title,
    IconData icon,
    Color iconColor,
    VoidCallback onTap, {
    String? trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(
              trailing,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
            size: 20,
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    String title,
    IconData icon,
    Color iconColor,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption('English'),
              _buildLanguageOption('हिंदी (Hindi)'),
              _buildLanguageOption('తెలుగు (Telugu)'),
              _buildLanguageOption('தமிழ் (Tamil)'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String language) {
    return RadioListTile<String>(
      title: Text(language),
      value: language,
      groupValue: _selectedLanguage,
      activeColor: AppColors.primary,
      onChanged: (value) {
        setState(() => _selectedLanguage = value!);
        Navigator.pop(context);
      },
    );
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Select Currency'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCurrencyOption('INR (₹)'),
              _buildCurrencyOption('USD (\$)'),
              _buildCurrencyOption('EUR (€)'),
              _buildCurrencyOption('GBP (£)'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrencyOption(String currency) {
    return RadioListTile<String>(
      title: Text(currency),
      value: currency,
      groupValue: _selectedCurrency,
      activeColor: AppColors.primary,
      onChanged: (value) {
        setState(() => _selectedCurrency = value!);
        Navigator.pop(context);
      },
    );
  }

  void _showQualityDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Download Quality',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text('Low (360p)'),
                subtitle: const Text('Saves data'),
                trailing: const Icon(Icons.check, color: Colors.transparent),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                title: const Text('Medium (720p)'),
                subtitle: const Text('Balanced'),
                trailing: const Icon(Icons.check, color: Colors.transparent),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                title: const Text('High (1080p)'),
                subtitle: const Text('Best quality'),
                trailing: Icon(Icons.check, color: AppColors.primary),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCacheDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Cache Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cache Size: 245 MB',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cache helps load content faster but uses storage space.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache cleared!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear Cache'),
            ),
          ],
        );
      },
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Clear Cache'),
          content: const Text(
            'This will clear 245 MB of cached data. The app may take longer to load content temporarily.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cache cleared successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Delete Account'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete your account?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              Text(
                'This action cannot be undone. All your data including:',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 8),
              Text('• Event bookings', style: TextStyle(fontSize: 14)),
              Text('• Reels and media', style: TextStyle(fontSize: 14)),
              Text('• Wallet balance', style: TextStyle(fontSize: 14)),
              Text('• Transaction history', style: TextStyle(fontSize: 14)),
              SizedBox(height: 8),
              Text(
                'will be permanently deleted.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account deletion cancelled'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete Account'),
            ),
          ],
        );
      },
    );
  }
}

