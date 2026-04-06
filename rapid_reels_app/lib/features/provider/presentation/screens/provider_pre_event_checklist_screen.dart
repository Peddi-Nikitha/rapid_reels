import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/provider_app_colors.dart';
import '../../../../shared/widgets/provider/provider_gradient_button.dart';
import '../../../../core/firebase/models/firebase_booking_model.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../booking/data/adapters/booking_firebase_mappers.dart';

class ProviderPreEventChecklistScreen extends StatefulWidget {
  final String bookingId;
  final String providerId;

  const ProviderPreEventChecklistScreen({
    super.key,
    required this.bookingId,
    required this.providerId,
  });

  @override
  State<ProviderPreEventChecklistScreen> createState() =>
      _ProviderPreEventChecklistScreenState();
}

class _ProviderPreEventChecklistScreenState
    extends State<ProviderPreEventChecklistScreen> {
  final _firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseBookingModel?>(
      future: _firestore.getBooking(widget.bookingId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: ProviderAppColors.background,
            appBar: AppBar(
              backgroundColor: ProviderAppColors.background,
              elevation: 0,
              title: const Text(
                'Pre-Event Checklist',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return Scaffold(
            backgroundColor: ProviderAppColors.background,
            appBar: AppBar(
              backgroundColor: ProviderAppColors.background,
              title: const Text('Pre-Event Checklist'),
            ),
            body: Center(child: Text('${snap.error}')),
          );
        }
        final raw = snap.data;
        if (raw == null || raw.providerId != widget.providerId) {
          return Scaffold(
            backgroundColor: ProviderAppColors.background,
            appBar: AppBar(
              backgroundColor: ProviderAppColors.background,
              title: const Text('Pre-Event Checklist'),
            ),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Booking not found or you do not have access.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return _PreEventChecklistLoadedView(
          raw: raw,
          firestore: _firestore,
        );
      },
    );
  }
}

class _PreEventChecklistLoadedView extends StatefulWidget {
  const _PreEventChecklistLoadedView({
    required this.raw,
    required this.firestore,
  });

  final FirebaseBookingModel raw;
  final FirestoreService firestore;

  @override
  State<_PreEventChecklistLoadedView> createState() =>
      _PreEventChecklistLoadedViewState();
}

class _PreEventChecklistLoadedViewState extends State<_PreEventChecklistLoadedView> {
  static const _kKeys = [
    'Equipment checked (camera, batteries, memory cards)',
    'Backup equipment ready',
    'Venue location confirmed',
    'Customer contact verified',
    'Event schedule reviewed',
    'Backup plan prepared',
    'Transportation arranged',
    'Assistant/team briefed (if applicable)',
    'Editing software ready',
    'Storage space available',
  ];

  late Map<String, bool> _checklistItems;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _checklistItems = {for (final k in _kKeys) k: false};
    final saved = widget.raw.metadata?['providerPreEventChecklist'];
    if (saved is Map) {
      for (final k in _kKeys) {
        final v = saved[k];
        if (v == true) _checklistItems[k] = true;
      }
    }
  }

  Future<void> _persistChecklist() async {
    setState(() => _saving = true);
    try {
      final meta = Map<String, dynamic>.from(widget.raw.metadata ?? {});
      meta['providerPreEventChecklist'] =
          Map<String, bool>.from(_checklistItems);
      await widget.firestore.updateBooking(widget.raw.bookingId, {
        'metadata': meta,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Checklist saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _markReady() async {
    setState(() => _saving = true);
    try {
      final meta = Map<String, dynamic>.from(widget.raw.metadata ?? {});
      meta['providerPreEventChecklist'] =
          Map<String, bool>.from(_checklistItems);
      meta['providerMarkedReadyAt'] = Timestamp.now();
      await widget.firestore.updateBooking(widget.raw.bookingId, {
        'metadata': meta,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Marked as ready (saved on booking)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking =
        BookingFirebaseMappers.toEventBooking(widget.raw);
    final completedCount = _checklistItems.values.where((v) => v).length;
    final totalCount = _checklistItems.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Scaffold(
      backgroundColor: ProviderAppColors.background,
      appBar: AppBar(
        backgroundColor: ProviderAppColors.surface,
        elevation: 0,
        title: const Text(
          'Pre-Event Checklist',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ProviderAppColors.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.eventName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(booking.eventDate),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        booking.eventTime,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ProviderAppColors.primary.withValues(alpha: 0.1),
                    ProviderAppColors.primary.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: ProviderAppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Checklist Progress',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$completedCount / $totalCount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ProviderAppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor:
                        AlwaysStoppedAnimation<Color>(ProviderAppColors.primary),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(progress * 100).toInt()}% Complete',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Checklist Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._checklistItems.entries.map((entry) {
              return _buildChecklistItem(
                label: entry.key,
                isChecked: entry.value,
                onChanged: _saving
                    ? null
                    : (value) {
                        setState(() {
                          _checklistItems[entry.key] = value ?? false;
                        });
                      },
              );
            }),
            const SizedBox(height: 24),
            if (completedCount == totalCount)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 24),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'All items completed! You are ready for the event.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            ProviderGradientButton(
              onPressed: _saving ? null : _persistChecklist,
              loading: _saving,
              label: _saving ? 'Saving…' : 'Save Checklist',
            ),
            const SizedBox(height: 12),
            if (completedCount == totalCount)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _saving
                      ? null
                      : () {
                          showDialog<void>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Mark as Ready?'),
                              content: const Text(
                                'Save readiness on this booking? You can change checklist items later.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                ProviderSuccessButton(
                                  fullWidth: false,
                                  minHeight: 40,
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _markReady();
                                  },
                                  label: 'Mark Ready',
                                ),
                              ],
                            ),
                          );
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Mark as Ready for Event'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem({
    required String label,
    required bool isChecked,
    required ValueChanged<bool?>? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ProviderAppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isChecked
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.grey[300]!,
          width: isChecked ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isChecked,
            onChanged: onChanged,
            activeColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
                decoration: isChecked ? TextDecoration.lineThrough : null,
                color: isChecked ? Colors.grey[600] : Colors.black,
              ),
            ),
          ),
          if (isChecked)
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }
}
