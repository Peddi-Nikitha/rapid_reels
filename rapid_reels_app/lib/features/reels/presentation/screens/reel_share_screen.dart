import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

class ReelShareScreen extends StatelessWidget {
  final String reelId;

  const ReelShareScreen({
    super.key,
    required this.reelId,
  });

  @override
  Widget build(BuildContext context) {
    final mockData = MockDataService();
    final reel = mockData.getReelById(reelId);

    if (reel == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Share Reel'),
        body: const Center(child: Text('Reel not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Share Reel'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reel Preview
            Container(
              height: 400,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: reel.thumbnailUrl,
                      height: 400,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            Text(
              reel.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            
            // Share Options
            const Text(
              'Share to',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Social Media Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildShareOption(
                  context,
                  Icons.camera_alt,
                  'Instagram\nReels',
                  AppColors.warning,
                  () => _shareToInstagram(context, 'reels'),
                ),
                _buildShareOption(
                  context,
                  Icons.auto_stories,
                  'Instagram\nStory',
                  AppColors.engagement,
                  () => _shareToInstagram(context, 'story'),
                ),
                _buildShareOption(
                  context,
                  Icons.chat,
                  'WhatsApp',
                  const Color(0xFF25D366),
                  () => _shareToWhatsApp(context),
                ),
                _buildShareOption(
                  context,
                  Icons.chat_bubble,
                  'WhatsApp\nStatus',
                  const Color(0xFF25D366),
                  () => _shareToWhatsApp(context),
                ),
                _buildShareOption(
                  context,
                  Icons.facebook,
                  'Facebook',
                  const Color(0xFF1877F2),
                  () => _shareToFacebook(context),
                ),
                _buildShareOption(
                  context,
                  Icons.music_note,
                  'TikTok',
                  AppColors.textPrimary,
                  () => _shareToTikTok(context),
                ),
                _buildShareOption(
                  context,
                  Icons.message,
                  'Messages',
                  AppColors.info,
                  () => _shareToMessages(context),
                ),
                _buildShareOption(
                  context,
                  Icons.more_horiz,
                  'More',
                  AppColors.textSecondary,
                  () => _shareMore(context),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Link Sharing
            const Text(
              'Or share via link',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'https://rapidreels.app/r/${reel.reelId}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _copyLink(context, reel.reelId),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.copy, size: 18, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            'Copy',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // QR Code
            GestureDetector(
              onTap: () => _showQRCode(context, reel),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.qr_code, color: AppColors.primary, size: 28),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Generate QR Code',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Easy sharing with QR code',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 16),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Download Options
            const Text(
              'Download Options',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildDownloadButton(
                    context,
                    'HD (1080p)',
                    '${reel.fileSize.toStringAsFixed(1)} MB',
                    () => _downloadReel(context, 'HD'),
                  ),
                ),
                const SizedBox(width: 12),
                if (reel.resolution == '4K')
                  Expanded(
                    child: _buildDownloadButton(
                      context,
                      '4K',
                      '${(reel.fileSize * 2).toStringAsFixed(1)} MB',
                      () => _downloadReel(context, '4K'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(
    BuildContext context,
    String quality,
    String size,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Icon(Icons.download, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              quality,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              size,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareToInstagram(BuildContext context, String type) {
    _showShareMessage(context, 'Opening Instagram $type...');
  }

  void _shareToWhatsApp(BuildContext context) {
    _showShareMessage(context, 'Opening WhatsApp...');
  }

  void _shareToFacebook(BuildContext context) {
    _showShareMessage(context, 'Opening Facebook...');
  }

  void _shareToTikTok(BuildContext context) {
    _showShareMessage(context, 'Opening TikTok...');
  }

  void _shareToMessages(BuildContext context) {
    _showShareMessage(context, 'Opening Messages...');
  }

  void _shareMore(BuildContext context) {
    _showShareMessage(context, 'Opening share options...');
  }

  void _copyLink(BuildContext context, String reelId) {
    Clipboard.setData(ClipboardData(text: 'https://rapidreels.app/r/$reelId'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied to clipboard'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _downloadReel(BuildContext context, String quality) {
    _showShareMessage(context, 'Downloading in $quality quality...');
  }

  void _showQRCode(BuildContext context, dynamic reel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('QR Code', style: TextStyle(color: AppColors.textPrimary)),
        content: Container(
          width: 250,
          height: 250,
          color: Colors.white,
          child: const Center(
            child: Icon(Icons.qr_code_2, size: 200, color: Colors.black),
          ),
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

  void _showShareMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

