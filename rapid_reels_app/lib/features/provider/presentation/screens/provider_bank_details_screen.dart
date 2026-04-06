import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/firebase/models/firebase_provider_model.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../../core/theme/provider_app_colors.dart';
import '../../../../core/utils/sensitive_data_mask.dart';
import '../../../../shared/widgets/provider/provider_gradient_button.dart';

/// View / edit payout bank details on `providers/{providerId}`.
class ProviderBankDetailsScreen extends StatefulWidget {
  const ProviderBankDetailsScreen({super.key, required this.providerId});

  final String providerId;

  @override
  State<ProviderBankDetailsScreen> createState() =>
      _ProviderBankDetailsScreenState();
}

class _ProviderBankDetailsScreenState extends State<ProviderBankDetailsScreen> {
  final _firestore = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bankName;
  late TextEditingController _accountHolder;
  late TextEditingController _accountNumber;
  late TextEditingController _accountNumberConfirm;
  late TextEditingController _ifsc;
  late TextEditingController _upi;
  late TextEditingController _country;
  bool _loading = true;
  bool _saving = false;
  String? _error;
  /// Stored payout account digits (never shown in full after load unless editing).
  String _savedAccountDigits = '';
  bool _editingAccountNumber = false;

  @override
  void initState() {
    super.initState();
    _bankName = TextEditingController();
    _accountHolder = TextEditingController();
    _accountNumber = TextEditingController();
    _accountNumberConfirm = TextEditingController();
    _ifsc = TextEditingController();
    _upi = TextEditingController();
    _country = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null || uid != widget.providerId) {
        setState(() {
          _loading = false;
          _error = 'You can only edit your own payout details when signed in.';
        });
        return;
      }
      final p = await _firestore.getProvider(widget.providerId);
      if (!mounted) return;
      if (p == null) {
        setState(() {
          _loading = false;
          _error = 'Provider profile not found';
        });
        return;
      }
      final b = p.bankDetails;
      _bankName.text = b?.bankName ?? '';
      _accountHolder.text = b?.accountHolderName ?? '';
      _savedAccountDigits = (b?.accountNumber ?? '').trim();
      _accountNumber.text = '';
      _accountNumberConfirm.text = '';
      _editingAccountNumber = _savedAccountDigits.isEmpty;
      _ifsc.text = b?.ifscCode ?? '';
      _upi.text = b?.upiId ?? '';
      _country.text = b?.countryCode ?? '';
      setState(() => _loading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = '$e';
        });
      }
    }
  }

  @override
  void dispose() {
    _bankName.dispose();
    _accountHolder.dispose();
    _accountNumber.dispose();
    _accountNumberConfirm.dispose();
    _ifsc.dispose();
    _upi.dispose();
    _country.dispose();
    super.dispose();
  }

  String _accountNumberToSave() {
    if (_savedAccountDigits.isNotEmpty && !_editingAccountNumber) {
      return _savedAccountDigits;
    }
    return _accountNumber.text.trim();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid != widget.providerId) return;

    setState(() => _saving = true);
    try {
      final acct = _accountNumberToSave();
      final bank = BankDetails(
        accountNumber: acct,
        ifscCode: _ifsc.text.trim(),
        accountHolderName: _accountHolder.text.trim(),
        upiId: _upi.text.trim(),
        bankName: _bankName.text.trim(),
        countryCode: _country.text.trim(),
      );
      await _firestore.updateProvider(widget.providerId, {
        'bankDetails': bank.toMap(),
      });
      if (mounted) {
        setState(() {
          _savedAccountDigits = acct.trim();
          _editingAccountNumber = _savedAccountDigits.isEmpty;
          _accountNumber.clear();
          _accountNumberConfirm.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payout details saved')),
        );
        context.pop();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank & payout'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_error!, textAlign: TextAlign.center),
                ))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Funds are paid out according to your contract. '
                          'Keep these details accurate.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: ProviderAppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _bankName,
                          decoration: const InputDecoration(
                            labelText: 'Bank name (optional)',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _accountHolder,
                          decoration: const InputDecoration(
                            labelText: 'Account holder name',
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        if (_savedAccountDigits.isNotEmpty &&
                            !_editingAccountNumber) ...[
                          InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Account number',
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    SensitiveDataMask.accountNumberLast4(
                                      _savedAccountDigits,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => setState(() {
                                    _editingAccountNumber = true;
                                    _accountNumber.text = '';
                                    _accountNumberConfirm.text = '';
                                  }),
                                  child: const Text('Change'),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          TextFormField(
                            controller: _accountNumber,
                            decoration: InputDecoration(
                              labelText: _savedAccountDigits.isEmpty
                                  ? 'Account number'
                                  : 'New account number',
                            ),
                            keyboardType: TextInputType.number,
                            obscureText: false,
                            validator: (v) {
                              final t = v?.trim() ?? '';
                              if (t.isEmpty) return 'Required';
                              return null;
                            },
                          ),
                          if (_editingAccountNumber ||
                              _savedAccountDigits.isEmpty) ...[
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _accountNumberConfirm,
                              decoration: const InputDecoration(
                                labelText: 'Confirm account number',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                final a = _accountNumber.text.trim();
                                final c = v?.trim() ?? '';
                                if (c.isEmpty) return 'Confirm your account number';
                                if (a != c) return 'Account numbers do not match';
                                return null;
                              },
                            ),
                          ],
                        ],
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _ifsc,
                          decoration: const InputDecoration(
                            labelText: 'IFSC / Sort code',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _upi,
                          decoration: const InputDecoration(
                            labelText: 'UPI ID (optional)',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _country,
                          decoration: const InputDecoration(
                            labelText: 'Country code (optional, e.g. IN, GB)',
                          ),
                        ),
                        const SizedBox(height: 28),
                        ProviderGradientButton(
                          onPressed: _saving ? null : _save,
                          loading: _saving,
                          label: _saving ? 'Saving…' : 'Save',
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
