import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/provider_app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../../shared/widgets/custom_button.dart';

class ProviderDocumentUploadScreen extends StatefulWidget {
  const ProviderDocumentUploadScreen({super.key});

  @override
  State<ProviderDocumentUploadScreen> createState() => _ProviderDocumentUploadScreenState();
}

class _ProviderDocumentUploadScreenState extends State<ProviderDocumentUploadScreen> {
  final Map<String, String?> _documents = {
    'Aadhaar Card': null,
    'PAN Card': null,
    'Business License': null,
    'GST Certificate': null,
    'Bank Account Proof': null,
  };

  final _auth = FirebaseAuth.instance;
  final _firestoreService = FirestoreService();
  final _picker = ImagePicker();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProviderAppColors.background,
      appBar: AppBar(
        backgroundColor: ProviderAppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Document Upload',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload Required Documents',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please upload clear photos of your documents for verification',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            
            ..._documents.entries.map((entry) {
              return _buildDocumentCard(entry.key, entry.value);
            }).toList(),
            
            const SizedBox(height: 24),
            
            // Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ProviderAppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ProviderAppColors.info.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: ProviderAppColors.info),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'All documents will be verified by our team. This process usually takes 24-48 hours.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[300]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            CustomButton(
              text: 'Continue',
              isLoading: _isSaving,
              onPressed: _isSaving ? null : _handleContinue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard(String docName, String? filePath) {
    final hasFile = filePath != null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ProviderAppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasFile ? ProviderAppColors.success : Colors.grey[700]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: hasFile
                      ? ProviderAppColors.success.withValues(alpha: 0.1)
                      : ProviderAppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  hasFile ? Icons.check_circle : Icons.description,
                  color: hasFile ? ProviderAppColors.success : ProviderAppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      docName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasFile ? 'Uploaded' : 'Not uploaded',
                      style: TextStyle(
                        fontSize: 12,
                        color: hasFile ? ProviderAppColors.success : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (hasFile)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _documents[docName] = null;
                    });
                  },
                )
              else
                TextButton.icon(
                  onPressed: () => _uploadDocument(docName),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload'),
                  style: TextButton.styleFrom(
                    foregroundColor: ProviderAppColors.primary,
                  ),
                ),
            ],
          ),
          if (hasFile) ...[
            const SizedBox(height: 12),
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(filePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _uploadDocument(String docName) async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in as provider')),
      );
      return;
    }

    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    setState(() => _isSaving = true);

    try {
      final storage = FirebaseStorage.instance;
      final key = _slugFromDocName(docName);
      final ref = storage
          .ref()
          .child('providers')
          .child(user.uid)
          .child('documents')
          .child('$key.jpg');

      await ref.putData(await picked.readAsBytes());
      final url = await ref.getDownloadURL();

      // Save locally for preview
      setState(() {
        _documents[docName] = url;
      });

      // Save in provider metadata.documents map
      await _firestoreService.updateProvider(user.uid, {
        'metadata': {
          'documents': {
            key: url,
          },
        },
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$docName uploaded successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload $docName: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _handleContinue() {
    final allUploaded = _documents.values.every((path) => path != null);
    
    if (!allUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload all required documents')),
      );
      return;
    }

    context.push(AppRoutes.providerAvailabilityCalendar);
  }

  String _slugFromDocName(String name) {
    return name.toLowerCase().replaceAll(' ', '_').replaceAll(RegExp(r'[^a-z0-9_]+'), '');
  }
}

