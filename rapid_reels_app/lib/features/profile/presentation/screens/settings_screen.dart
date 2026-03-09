import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = true;
  bool _marketingEmails = false;
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          _buildSection(
            title: 'NOTIFICATIONS',
            children: [
              SwitchListTile(
                title: const Text('Enable Notifications'),
                subtitle: const Text('Receive all notifications'),
                value: _notificationsEnabled,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Booking updates and reminders'),
                value: _pushNotifications,
                activeColor: AppColors.primary,
                onChanged: _notificationsEnabled
                    ? (value) => setState(() => _pushNotifications = value)
                    : null,
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Email Notifications'),
                subtitle: const Text('Booking confirmations via email'),
                value: _emailNotifications,
                activeColor: AppColors.primary,
                onChanged: _notificationsEnabled
                    ? (value) => setState(() => _emailNotifications = value)
                    : null,
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('SMS Notifications'),
                subtitle: const Text('Event reminders via SMS'),
                value: _smsNotifications,
                activeColor: AppColors.primary,
                onChanged: _notificationsEnabled
                    ? (value) => setState(() => _smsNotifications = value)
                    : null,
              ),
            ],
          ),
          _buildSection(
            title: 'PRIVACY',
            children: [
              ListTile(
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Privacy Policy')),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Terms of Service')),
                  );
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Marketing Communications'),
                subtitle: const Text('Offers and promotions'),
                value: _marketingEmails,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  setState(() => _marketingEmails = value);
                },
              ),
            ],
          ),
          _buildSection(
            title: 'APP PREFERENCES',
            children: [
              ListTile(
                title: const Text('Language'),
                subtitle: Text(_language),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showLanguageDialog,
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Clear Cache'),
                subtitle: const Text('Free up storage space'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _clearCache,
              ),
            ],
          ),
          _buildSection(
            title: 'DATA',
            children: [
              ListTile(
                title: const Text('Download My Data'),
                subtitle: const Text('Request a copy of your data'),
                trailing: const Icon(Icons.download),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data download request submitted'),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text(
                  'Delete Account',
                  style: TextStyle(color: Colors.red),
                ),
                subtitle: const Text('Permanently delete your account'),
                trailing: const Icon(Icons.delete, color: Colors.red),
                onTap: _showDeleteAccountDialog,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
          ...children,
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: _language,
              activeColor: AppColors.primary,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('हिंदी (Hindi)'),
              value: 'Hindi',
              groupValue: _language,
              activeColor: AppColors.primary,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('தமிழ் (Tamil)'),
              value: 'Tamil',
              groupValue: _language,
              activeColor: AppColors.primary,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached data. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion request submitted'),
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

