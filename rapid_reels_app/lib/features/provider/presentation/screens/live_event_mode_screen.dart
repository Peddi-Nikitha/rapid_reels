import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class LiveEventModeScreen extends StatefulWidget {
  const LiveEventModeScreen({super.key});

  @override
  State<LiveEventModeScreen> createState() => _LiveEventModeScreenState();
}

class _LiveEventModeScreenState extends State<LiveEventModeScreen> {
  bool _isRecording = false;
  int _recordingDuration = 0;
  final List<String> _capturedClips = [];
  final Map<String, bool> _shotChecklist = {
    'Bride Entry': false,
    'Groom Entry': false,
    'Varmala Ceremony': false,
    'Ring Exchange': false,
    'Couple Shots': false,
    'Family Photos': false,
    'Reception': false,
  };
  double _coverageProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  if (_isRecording)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.fiber_manual_record, color: Colors.white, size: 12),
                          const SizedBox(width: 6),
                          Text(
                            _formatDuration(_recordingDuration),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.flash_off, color: Colors.white),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.checklist, color: Colors.white),
                    onPressed: _showShotChecklist,
                  ),
                ],
              ),
            ),
            
            // Coverage Progress
            if (_isRecording)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Coverage Progress',
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                        Text(
                          '${(_coverageProgress * 100).toInt()}%',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: _coverageProgress,
                      backgroundColor: Colors.grey[800],
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            
            // Camera View
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.videocam, size: 80, color: Colors.grey[700]),
                      const SizedBox(height: 16),
                      Text(
                        'Camera Preview',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Controls
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Captured Clips
                  if (_capturedClips.isNotEmpty) ...[
                    Container(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _capturedClips.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Record Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 32),
                        onPressed: () {},
                      ),
                      GestureDetector(
                        onTap: _toggleRecording,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Center(
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: _isRecording ? Colors.red : Colors.white,
                                shape: _isRecording ? BoxShape.rectangle : BoxShape.circle,
                                borderRadius: _isRecording ? BorderRadius.circular(8) : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green, size: 32),
                        onPressed: _capturedClips.isNotEmpty ? _finishSession : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (!_isRecording) {
        _capturedClips.add('Clip ${_capturedClips.length + 1}');
        _recordingDuration = 0;
      }
    });
  }

  void _finishSession() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Finish Session'),
        content: Text('${_capturedClips.length} clips captured. Ready to upload?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Clips uploaded successfully!')),
              );
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _showShotChecklist() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shot Checklist',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._shotChecklist.entries.map((entry) {
              return CheckboxListTile(
                title: Text(entry.key),
                value: entry.value,
                onChanged: (value) {
                  setState(() {
                    _shotChecklist[entry.key] = value ?? false;
                    _updateCoverageProgress();
                  });
                },
                activeColor: AppColors.primary,
              );
            }).toList(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateCoverageProgress() {
    final completed = _shotChecklist.values.where((v) => v).length;
    setState(() {
      _coverageProgress = completed / _shotChecklist.length;
    });
  }
}

