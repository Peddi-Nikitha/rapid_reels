import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';

class UploadFootageScreen extends StatefulWidget {
  const UploadFootageScreen({super.key});

  @override
  State<UploadFootageScreen> createState() => _UploadFootageScreenState();
}

class _UploadFootageScreenState extends State<UploadFootageScreen> {
  final List<Map<String, dynamic>> _selectedFiles = [];
  final List<Map<String, dynamic>> _uploadQueue = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  bool _enableCompression = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Upload Footage', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          if (_uploadQueue.isNotEmpty)
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.queue),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${_uploadQueue.length}',
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: _showUploadQueue,
            ),
        ],
      ),
      body: Column(
        children: [
          // Upload Area
          if (_selectedFiles.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(Icons.cloud_upload, size: 64, color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Upload Event Footage', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Supports MP4, MOV files up to 5GB', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _enableCompression,
                          onChanged: (value) {
                            setState(() => _enableCompression = value ?? true);
                          },
                          activeColor: AppColors.primary,
                        ),
                        Text('Compress videos before upload', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Select Files',
                      onPressed: _selectFiles,
                      isFullWidth: false,
                      width: 200,
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _selectedFiles.length,
                itemBuilder: (context, index) {
                  final file = _selectedFiles[index];
                  return _buildFileCard(file, index);
                },
              ),
            ),
          
          // Upload Progress
          if (_isUploading) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: _uploadProgress,
                    backgroundColor: Colors.grey[300],
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Uploading... ${(_uploadProgress * 100).toInt()}%',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
          
          // Action Buttons
          if (_selectedFiles.isNotEmpty && !_isUploading)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearAll,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Clear All'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      text: 'Upload ${_selectedFiles.length} ${_selectedFiles.length == 1 ? 'File' : 'Files'}',
                      onPressed: _uploadFiles,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFileCard(Map<String, dynamic> file, int index) {
    final status = file['status'] as String? ?? 'pending';
    final progress = file['progress'] as double? ?? 0.0;
    final hasError = status == 'failed';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: hasError ? Border.all(color: Colors.red, width: 1) : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: status == 'uploading'
                      ? CircularProgressIndicator(value: progress, strokeWidth: 2)
                      : Icon(
                          hasError ? Icons.error : Icons.videocam,
                          color: hasError ? Colors.red : AppColors.primary,
                          size: 32,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file['name'] as String,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${file['size']} MB • ${file['duration']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    if (status == 'uploading')
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(fontSize: 12, color: AppColors.primary),
                      ),
                    if (hasError)
                      Text(
                        'Upload failed. Tap to retry',
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                  ],
                ),
              ),
              if (hasError)
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.primary),
                  onPressed: () => _retryUpload(index),
                ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => _removeFile(index),
              ),
            ],
          ),
          if (status == 'uploading')
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[800],
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }

  void _selectFiles() {
    setState(() {
      final newFiles = [
        {'name': 'wedding_ceremony.mp4', 'size': 235.5, 'duration': '05:32', 'status': 'pending'},
        {'name': 'bride_entry.mp4', 'size': 98.3, 'duration': '02:15', 'status': 'pending'},
        {'name': 'varmala_ceremony.mp4', 'size': 156.7, 'duration': '03:48', 'status': 'pending'},
      ];
      _selectedFiles.addAll(newFiles);
      _uploadQueue.addAll(newFiles);
    });
  }

  void _removeFile(int index) {
    setState(() => _selectedFiles.removeAt(index));
  }

  void _clearAll() {
    setState(() => _selectedFiles.clear());
  }

  void _uploadFiles() {
    if (_enableCompression) {
      // Simulate compression
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compressing videos...')),
      );
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      for (var file in _selectedFiles) {
        if (file['status'] == 'pending') {
          file['status'] = 'uploading';
          file['progress'] = 0.0;
        }
      }
    });

    // Simulate upload progress
    Future.delayed(const Duration(milliseconds: 100), _simulateUpload);
  }

  void _simulateUpload() {
    if (_uploadProgress < 1.0) {
      setState(() {
        _uploadProgress += 0.02;
        for (var file in _selectedFiles) {
          if (file['status'] == 'uploading') {
            file['progress'] = _uploadProgress;
          }
        }
      });
      Future.delayed(const Duration(milliseconds: 100), _simulateUpload);
    } else {
      setState(() {
        _isUploading = false;
        for (var file in _selectedFiles) {
          file['status'] = 'completed';
          file['progress'] = 1.0;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Footage uploaded successfully!')),
      );
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
  }

  void _retryUpload(int index) {
    setState(() {
      _selectedFiles[index]['status'] = 'uploading';
      _selectedFiles[index]['progress'] = 0.0;
    });
    _uploadFiles();
  }

  void _showUploadQueue() {
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
              'Upload Queue',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._uploadQueue.map((item) => ListTile(
              leading: Icon(
                item['status'] == 'completed' ? Icons.check_circle : Icons.pending,
                color: item['status'] == 'completed' ? AppColors.success : Colors.grey,
              ),
              title: Text(item['name'] as String),
              subtitle: Text('${item['size']} MB'),
              trailing: item['status'] == 'failed'
                  ? IconButton(
                      icon: const Icon(Icons.refresh, color: AppColors.primary),
                      onPressed: () {},
                    )
                  : null,
            )).toList(),
          ],
        ),
      ),
    );
  }
}

