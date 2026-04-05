import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/firebase/models/firebase_provider_model.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../../shared/widgets/custom_button.dart';

/// Weekly day keys aligned with [FirebaseProviderModel.availability].
const _orderedDayKeys = [
  ('Monday', 'monday'),
  ('Tuesday', 'tuesday'),
  ('Wednesday', 'wednesday'),
  ('Thursday', 'thursday'),
  ('Friday', 'friday'),
  ('Saturday', 'saturday'),
  ('Sunday', 'sunday'),
];

class ProviderAvailabilityCalendarScreen extends StatefulWidget {
  const ProviderAvailabilityCalendarScreen({super.key});

  @override
  State<ProviderAvailabilityCalendarScreen> createState() =>
      _ProviderAvailabilityCalendarScreenState();
}

class _ProviderAvailabilityCalendarScreenState
    extends State<ProviderAvailabilityCalendarScreen> {
  final _firestore = FirestoreService();
  bool _loading = true;
  bool _saving = false;
  String? _error;

  /// `key`: monday…sunday → `{ isOpen, startTime, endTime }`
  final Map<String, Map<String, dynamic>> _weeklySchedule = {};

  final Set<DateTime> _blockedDates = {};

  @override
  void initState() {
    super.initState();
    for (final (_, key) in _orderedDayKeys) {
      _weeklySchedule[key] = {
        'isOpen': true,
        'startTime': '09:00',
        'endTime': '18:00',
      };
    }
    _loadFromFirestore();
  }

  Future<void> _loadFromFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _loading = false;
        _error = 'Sign in required';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final p = await _firestore.getProvider(uid);
      if (!mounted) return;
      if (p == null) {
        setState(() {
          _loading = false;
          _error = 'Provider profile not found';
        });
        return;
      }
      for (final (_, key) in _orderedDayKeys) {
        final day = p.availability[key];
        final isOpen = day?.isOpen ?? true;
        final slot = day != null && day.slots.isNotEmpty
            ? day.slots.first
            : null;
        _weeklySchedule[key] = {
          'isOpen': isOpen,
          'startTime': slot?.startTime ?? '09:00',
          'endTime': slot?.endTime ?? '18:00',
        };
      }
      _blockedDates.clear();
      for (final b in p.blockedDates) {
        _blockedDates.add(DateTime(b.date.year, b.date.month, b.date.day));
      }
      if (mounted) {
        setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = '$e';
        });
      }
    }
  }

  Map<String, DayAvailability> _scheduleToFirestore() {
    final out = <String, DayAvailability>{};
    for (final entry in _weeklySchedule.entries) {
      final open = entry.value['isOpen'] == true;
      final start = entry.value['startTime'] as String? ?? '09:00';
      final end = entry.value['endTime'] as String? ?? '18:00';
      out[entry.key] = DayAvailability(
        isOpen: open,
        slots: open
            ? [
                TimeSlot(
                  startTime: start,
                  endTime: end,
                  slotDuration: 60,
                ),
              ]
            : const [],
      );
    }
    return out;
  }

  Future<void> _saveToFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _saving = true);
    try {
      final blocked = _blockedDates
          .map(
            (d) => BlockedDate(
              date: DateTime(d.year, d.month, d.day),
              reason: 'unavailable',
            ).toMap(),
          )
          .toList();
      await _firestore.updateProvider(uid, {
        'availability': _scheduleToFirestore().map((k, v) => MapEntry(k, v.toMap())),
        'blockedDates': blocked,
      });
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Availability saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Availability Calendar',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, textAlign: TextAlign.center))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Set Your Availability',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose closed weekdays and block specific dates. Customers can book one event per day.',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Weekly Schedule',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (final (label, key) in _orderedDayKeys)
                        _buildDaySchedule(label, key, _weeklySchedule[key]!),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Blocked Dates',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _showDatePicker,
                            icon: const Icon(Icons.add),
                            label: const Text('Block Date'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_blockedDates.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 48, color: Colors.grey[600]),
                                const SizedBox(height: 12),
                                Text(
                                  'No blocked dates',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _blockedDates.map((date) {
                            return Chip(
                              label: Text(
                                '${date.day}/${date.month}/${date.year}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              onDeleted: () {
                                setState(() => _blockedDates.remove(date));
                              },
                              deleteIcon: const Icon(Icons.close, size: 18),
                              backgroundColor:
                                  Colors.red.withValues(alpha: 0.2),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 32),
                      CustomButton(
                        text: _saving ? 'Saving...' : 'Save availability',
                        onPressed: _saving ? () {} : _saveToFirestore,
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Complete Setup',
                        onPressed: _saving
                            ? () {}
                            : () async {
                                await _saveToFirestore();
                                if (!context.mounted) return;
                                _showCompleteDialog();
                              },
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDaySchedule(
      String label, String key, Map<String, dynamic> schedule) {
    final isOpen = schedule['isOpen'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(
            value: isOpen,
            onChanged: (value) {
              setState(() {
                schedule['isOpen'] = value;
              });
            },
            activeThumbColor: AppColors.primary,
          ),
          if (isOpen) ...[
            const SizedBox(width: 16),
            InkWell(
              onTap: () => _editTimes(key),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${schedule['startTime']} - ${schedule['endTime']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _editTimes(String dayKey) async {
    final schedule = _weeklySchedule[dayKey]!;
    final startParts = (schedule['startTime'] as String).split(':');
    final endParts = (schedule['endTime'] as String).split(':');
    TimeOfDay start = TimeOfDay(
        hour: int.tryParse(startParts[0]) ?? 9,
        minute: int.tryParse(startParts[1]) ?? 0);
    TimeOfDay end = TimeOfDay(
        hour: int.tryParse(endParts[0]) ?? 18,
        minute: int.tryParse(endParts[1]) ?? 0);

    final pickedStart = await showTimePicker(
      context: context,
      initialTime: start,
    );
    if (pickedStart == null || !mounted) return;
    final pickedEnd = await showTimePicker(
      context: context,
      initialTime: end,
    );
    if (pickedEnd == null || !mounted) return;

    String fmt(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    setState(() {
      schedule['startTime'] = fmt(pickedStart);
      schedule['endTime'] = fmt(pickedEnd);
    });
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
              surface: AppColors.surface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _blockedDates.add(DateTime(picked.year, picked.month, picked.day));
      });
    }
  }

  void _showCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Registration Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 64, color: AppColors.success),
            const SizedBox(height: 16),
            const Text(
              'Your provider account has been created successfully.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your account is pending verification. You will receive a notification once verified.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.providerVerification);
            },
            child: const Text('View Status'),
          ),
        ],
      ),
    );
  }
}
