import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'seed_sample_providers.dart';

/// Simple debug-only screen to seed Firestore with sample providers + packages.
///
/// Navigate to this screen once (e.g. via a temporary route) and tap
/// the button to insert demo providers. Safe to run multiple times
/// because it uses `set(..., merge: true)` with fixed IDs.
class SeedDataScreen extends StatefulWidget {
  const SeedDataScreen({super.key});

  @override
  State<SeedDataScreen> createState() => _SeedDataScreenState();
}

class _SeedDataScreenState extends State<SeedDataScreen> {
  bool _isSeeding = false;
  String? _status;

  Future<void> _runSeed() async {
    if (_isSeeding) return;
    setState(() {
      _isSeeding = true;
      _status = null;
    });
    try {
      await seedSampleProviders();
      setState(() {
        _status = 'Seed data inserted successfully.';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to insert seed data: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSeeding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Seed Firestore Data'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Insert demo providers + packages into Firestore.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSeeding ? null : _runSeed,
                child: _isSeeding
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Run Seed Script'),
              ),
              if (_status != null) ...[
                const SizedBox(height: 16),
                Text(
                  _status!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _status!.startsWith('Failed')
                        ? AppColors.error
                        : AppColors.success,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

