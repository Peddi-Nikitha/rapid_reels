import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/provider_app_colors.dart';
import '../../../../shared/widgets/provider/provider_gradient_button.dart';
import '../../../../core/firebase/models/firebase_booking_model.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../booking/data/adapters/booking_firebase_mappers.dart';
import '../../../booking/data/models/event_booking_model.dart';

class ProviderBookingStatusScreen extends StatefulWidget {
  final String bookingId;
  final String providerId;

  const ProviderBookingStatusScreen({
    super.key,
    required this.bookingId,
    required this.providerId,
  });

  @override
  State<ProviderBookingStatusScreen> createState() =>
      _ProviderBookingStatusScreenState();
}

class _ProviderBookingStatusScreenState
    extends State<ProviderBookingStatusScreen> {
  final TextEditingController _notesController = TextEditingController();
  final _firestore = FirestoreService();
  String? _selectedNewStatus;
  int _reloadKey = 0;
  bool _saving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  List<String> _getAvailableStatuses(String currentStatus) {
    switch (currentStatus.toLowerCase()) {
      case 'pending':
        return ['confirmed', 'cancelled'];
      case 'confirmed':
        return ['ongoing', 'cancelled'];
      case 'ongoing':
        return ['completed'];
      case 'completed':
        return [];
      case 'cancelled':
        return [];
      default:
        return [];
    }
  }

  Future<FirebaseBookingModel?> _loadBooking() =>
      _firestore.getBooking(widget.bookingId);

  List<Map<String, dynamic>> _historyFromMetadata(
    FirebaseBookingModel? raw,
  ) {
    if (raw?.metadata == null) return [];
    final h = raw!.metadata!['providerStatusHistory'];
    if (h is! List) return [];
    final out = <Map<String, dynamic>>[];
    for (final e in h) {
      if (e is Map<String, dynamic>) {
        out.add(Map<String, dynamic>.from(e));
      } else if (e is Map) {
        out.add(Map<String, dynamic>.from(e));
      }
    }
    return out;
  }

  DateTime? _timestampFrom(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    return null;
  }

  Future<void> _updateStatus(
    FirebaseBookingModel raw,
    EventBooking booking,
  ) async {
    if (_selectedNewStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a new status')),
      );
      return;
    }
    final newStatus = _selectedNewStatus!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Status Change'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to change the status?'),
            const SizedBox(height: 12),
            Text(
              'From: ${booking.status.toUpperCase()}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'To: ${newStatus.toUpperCase()}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getStatusColor(newStatus),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ProviderGradientButton(
            onPressed: () => Navigator.pop(context, true),
            label: 'Confirm',
            fullWidth: false,
            minHeight: 44,
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);
    try {
      if (raw.providerId != widget.providerId) {
        throw Exception('Not allowed');
      }
      final meta = Map<String, dynamic>.from(raw.metadata ?? {});
      final history = <Map<String, dynamic>>[];
      final existing = meta['providerStatusHistory'];
      if (existing is List) {
        for (final e in existing) {
          if (e is Map<String, dynamic>) {
            history.add(Map<String, dynamic>.from(e));
          } else if (e is Map) {
            history.add(Map<String, dynamic>.from(e));
          }
        }
      }
      history.add({
        'from': raw.status,
        'to': newStatus,
        'notes': _notesController.text.trim(),
        'at': Timestamp.now(),
      });
      meta['providerStatusHistory'] = history;

      final updates = <String, dynamic>{
        'status': newStatus,
        'metadata': meta,
      };
      if (newStatus == 'confirmed') {
        updates['eventStatus.bookingConfirmed'] = Timestamp.now();
      }
      if (newStatus == 'ongoing') {
        updates['eventStatus.eventStarted'] = Timestamp.now();
      }
      if (newStatus == 'completed') {
        updates['completedAt'] = Timestamp.now();
        updates['eventStatus.eventCompleted'] = Timestamp.now();
      }
      if (newStatus == 'cancelled') {
        updates['cancelledAt'] = Timestamp.now();
      }

      await _firestore.updateBooking(widget.bookingId, updates);

      if (!mounted) return;
      setState(() {
        _selectedNewStatus = null;
        _notesController.clear();
        _reloadKey++;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status updated'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseBookingModel?>(
      key: ValueKey(_reloadKey),
      future: _loadBooking(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: ProviderAppColors.background,
            appBar: AppBar(
              backgroundColor: ProviderAppColors.background,
              elevation: 0,
              title: const Text(
                'Update Booking Status',
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
              title: const Text('Update Booking Status'),
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
              title: const Text('Update Booking Status'),
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

        final booking = BookingFirebaseMappers.toEventBooking(raw);
        final availableStatuses = _getAvailableStatuses(booking.status);
        final history = _historyFromMetadata(raw);

        return Scaffold(
          backgroundColor: ProviderAppColors.background,
          appBar: AppBar(
            backgroundColor: ProviderAppColors.background,
            elevation: 0,
            title: const Text(
              'Update Booking Status',
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
                    gradient: LinearGradient(
                      colors: [
                        _getStatusColor(booking.status)
                            .withValues(alpha: 0.2),
                        _getStatusColor(booking.status)
                            .withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getStatusColor(booking.status),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        booking.eventName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getStatusColor(booking.status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          booking.status.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Booking ID: ${booking.eventId}',
                        style: TextStyle(
                          fontSize: 12,
                          color: ProviderAppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (availableStatuses.isNotEmpty) ...[
                  const Text(
                    'Update Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ProviderAppColors.card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select New Status',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...availableStatuses.map((status) {
                          return RadioListTile<String>(
                            title: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(status),
                                  ),
                                ),
                              ],
                            ),
                            value: status,
                            groupValue: _selectedNewStatus,
                            onChanged: _saving
                                ? null
                                : (value) {
                                    setState(() {
                                      _selectedNewStatus = value;
                                    });
                                  },
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Notes (Optional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ProviderAppColors.card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _notesController,
                      maxLines: 3,
                      enabled: !_saving,
                      decoration: InputDecoration(
                        hintText: 'Add notes about this status change...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: ProviderAppColors.textMuted),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ProviderGradientButton(
                    onPressed: _saving
                        ? null
                        : () => _updateStatus(raw, booking),
                    loading: _saving,
                    label: _saving ? 'Updating…' : 'Update Status',
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: ProviderAppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ProviderAppColors.outline),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: ProviderAppColors.textTertiary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No status updates available. This booking is ${booking.status}.',
                            style: TextStyle(
                              fontSize: 14,
                              color: ProviderAppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                const Text(
                  'Status History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (history.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ProviderAppColors.card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'No status changes yet',
                        style: TextStyle(
                          fontSize: 14,
                          color: ProviderAppColors.textTertiary,
                        ),
                      ),
                    ),
                  )
                else
                  ...history.reversed.map((h) {
                    return _buildStatusHistoryItem(h);
                  }),
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ProviderAppColors.card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getStatusColor(booking.status)
                              .withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.flag,
                          color: _getStatusColor(booking.status),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current: ${booking.status.toUpperCase()}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Created: ${_formatDateTime(booking.createdAt)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: ProviderAppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusHistoryItem(Map<String, dynamic> history) {
    final to = history['to']?.toString() ?? '';
    final from = history['from']?.toString() ?? '';
    final ts = _timestampFrom(history['at']);
    final notes = history['notes']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ProviderAppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(to).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getStatusColor(to).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.swap_horiz,
                  color: _getStatusColor(to),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          from.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: ProviderAppColors.textTertiary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 16, color: ProviderAppColors.textMuted),
                        const SizedBox(width: 8),
                        Text(
                          to.toUpperCase(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(to),
                          ),
                        ),
                      ],
                    ),
                    if (ts != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatDateTime(ts),
                        style: TextStyle(
                          fontSize: 12,
                          color: ProviderAppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ProviderAppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, size: 16, color: ProviderAppColors.textTertiary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notes,
                      style: TextStyle(
                        fontSize: 12,
                        color: ProviderAppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'ongoing':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]}, ${dateTime.year} at '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
