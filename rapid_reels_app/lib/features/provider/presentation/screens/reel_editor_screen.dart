import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ReelEditorScreen extends StatefulWidget {
  const ReelEditorScreen({super.key});

  @override
  State<ReelEditorScreen> createState() => _ReelEditorScreenState();
}

class _ReelEditorScreenState extends State<ReelEditorScreen> {
  String _selectedFilter = 'None';
  String _selectedTransition = 'Fade';
  String _selectedMusic = 'None';
  bool _isProcessing = false;
  bool _showDeliveryQueue = false;
  final List<Map<String, dynamic>> _deliveryQueue = [
    {'id': '1', 'event': 'Wedding - Amit & Sneha', 'status': 'pending', 'progress': 0.0},
    {'id': '2', 'event': 'Birthday Party', 'status': 'processing', 'progress': 0.6},
    {'id': '3', 'event': 'Engagement', 'status': 'ready', 'progress': 1.0},
  ];

  final List<String> _filters = ['None', 'Cinematic', 'Vintage', 'Bright', 'Warm', 'Cool'];
  final List<String> _transitions = ['Fade', 'Dissolve', 'Zoom', 'Slide', 'Spin'];
  final List<String> _musicTracks = ['None', 'Romantic', 'Energetic', 'Emotional', 'Celebration'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Reel Editor', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.queue),
            onPressed: () {
              setState(() => _showDeliveryQueue = !_showDeliveryQueue);
            },
            tooltip: 'Delivery Queue',
          ),
          if (!_isProcessing)
            TextButton(
              onPressed: _processReel,
              child: const Text('Export'),
            ),
        ],
      ),
      body: _showDeliveryQueue ? _buildDeliveryQueue() : _buildEditor(),
    );
  }

  Widget _buildEditor() {
    return Column(
      children: [
        // Video Preview
        Container(
            height: 300,
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_outline, size: 80, color: Colors.grey[700]),
                  const SizedBox(height: 16),
                  Text('Video Preview', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ),
          
          // Timeline
          Container(
            height: 80,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: List.generate(10, (index) {
                return Container(
                  width: (MediaQuery.of(context).size.width - 32) / 10,
                  height: 60,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Editing Tools
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSection('Filters', _filters, _selectedFilter, (value) {
                  setState(() => _selectedFilter = value);
                }),
                const SizedBox(height: 16),
                _buildSection('Transitions', _transitions, _selectedTransition, (value) {
                  setState(() => _selectedTransition = value);
                }),
                const SizedBox(height: 16),
                _buildSection('Music', _musicTracks, _selectedMusic, (value) {
                  setState(() => _selectedMusic = value);
                }),
                const SizedBox(height: 24),
                // AI Suggestions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: Colors.white),
                          const SizedBox(width: 8),
                          const Text(
                            'AI Suggestions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '• Try "Cinematic" filter for emotional moments\n• Add "Zoom" transition for bride entry\n• Use "Romantic" music for couple shots',
                        style: TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Process Button
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
        ],
    );
  }

  Widget _buildDeliveryQueue() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Delivery Queue',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage your reel deliveries',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        ..._deliveryQueue.map((item) => _buildQueueItem(item)).toList(),
      ],
    );
  }

  Widget _buildQueueItem(Map<String, dynamic> item) {
    final status = item['status'] as String;
    final progress = item['progress'] as double;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['event'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(status),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (status == 'ready')
                ElevatedButton(
                  onPressed: () {
                    _showQualityCheck(item);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Review'),
                ),
            ],
          ),
          if (status == 'processing') ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[800],
              color: AppColors.primary,
            ),
            const SizedBox(height: 4),
            Text(
              '${(progress * 100).toInt()}% complete',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  void _showQualityCheck(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Quality Control Check'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQualityItem('Video Quality', true),
            _buildQualityItem('Audio Sync', true),
            _buildQualityItem('Color Grading', true),
            _buildQualityItem('Transitions', true),
            _buildQualityItem('Music', true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Needs Revision'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reel approved and ready for delivery!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Approve & Deliver'),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityItem(String item, bool passed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.cancel,
            color: passed ? AppColors.success : AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(item, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ready':
        return AppColors.success;
      case 'processing':
        return AppColors.warning;
      default:
        return Colors.grey;
    }
  }

  Widget _buildSection(String title, List<String> options, String selected, Function(String) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = option == selected;
              return GestureDetector(
                onTap: () => onSelect(option),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _processReel() {
    setState(() => _isProcessing = true);
    Future.delayed(const Duration(seconds: 3), () {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reel exported successfully!')),
      );
      Navigator.pop(context);
    });
  }
}

