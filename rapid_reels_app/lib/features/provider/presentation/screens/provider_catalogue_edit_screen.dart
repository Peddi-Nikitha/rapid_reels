import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/firebase/models/firebase_catalogue_event_model.dart';
import '../../../../core/firebase/models/firebase_provider_model.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../../shared/widgets/custom_button.dart';

class ProviderCatalogueEditScreen extends StatefulWidget {
  final String providerId;
  final String catalogueEventId;

  const ProviderCatalogueEditScreen({
    super.key,
    required this.providerId,
    required this.catalogueEventId,
  });

  bool get isNew => catalogueEventId == 'new';

  @override
  State<ProviderCatalogueEditScreen> createState() => _ProviderCatalogueEditScreenState();
}

class _ProviderCatalogueEditScreenState extends State<ProviderCatalogueEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirestoreService();
  final _picker = ImagePicker();

  final _title = TextEditingController();
  final _short = TextEditingController();
  final _long = TextEditingController();
  final _highlights = TextEditingController();
  final _tags = TextEditingController();
  final _heroUrl = TextEditingController();
  final _galleryUrls = TextEditingController();
  final _sortOrder = TextEditingController(text: '0');
  final _startingPrice = TextEditingController();
  final _durationLabel = TextEditingController();

  String _eventType = 'wedding';
  bool _isPublished = false;
  final Set<String> _selectedPackageIds = {};
  bool _loading = true;
  bool _saving = false;
  FirebaseProviderModel? _provider;
  /// Avoid re-applying "select first package" every time [_load] runs.
  bool _didApplyInitialPackagePick = false;

  static const _eventTypes = [
    'wedding',
    'birthday',
    'engagement',
    'corporate',
    'brand',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await _firestore.getProvider(widget.providerId);
    if (!mounted) return;
    setState(() {
      _provider = p;
    });

    if (!widget.isNew) {
      final existing = await _firestore.getCatalogueEvent(widget.providerId, widget.catalogueEventId);
      if (existing != null && mounted) {
        _title.text = existing.title;
        _short.text = existing.shortDescription;
        _long.text = existing.longDescription;
        _highlights.text = existing.highlights.join('\n');
        _tags.text = existing.tags.join(', ');
        _heroUrl.text = existing.heroImageUrl;
        _galleryUrls.text = existing.galleryImageUrls.join('\n');
        _sortOrder.text = existing.sortOrder.toString();
        _startingPrice.text = existing.startingPrice?.toString() ?? '';
        _durationLabel.text = existing.durationLabel ?? '';
        _eventType = existing.eventType;
        _isPublished = existing.isPublished;
        _selectedPackageIds.addAll(existing.packageIds);
      }
    } else if (!_didApplyInitialPackagePick && p != null) {
      final withIds = p.packages.where((x) => x.packageId.isNotEmpty).toList();
      if (withIds.isNotEmpty) {
        _selectedPackageIds.add(withIds.first.packageId);
        _didApplyInitialPackagePick = true;
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _title.dispose();
    _short.dispose();
    _long.dispose();
    _highlights.dispose();
    _tags.dispose();
    _heroUrl.dispose();
    _galleryUrls.dispose();
    _sortOrder.dispose();
    _startingPrice.dispose();
    _durationLabel.dispose();
    super.dispose();
  }

  Future<void> _uploadHero() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    setState(() => _saving = true);
    try {
      final name = 'hero_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance
          .ref()
          .child('providers')
          .child(widget.providerId)
          .child('catalogue')
          .child(name);
      await ref.putData(await picked.readAsBytes());
      final url = await ref.getDownloadURL();
      setState(() => _heroUrl.text = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List<PackageOffering> _validPackages() {
    return (_provider?.packages ?? []).where((p) => p.packageId.isNotEmpty).toList();
  }

  PackageOffering? _packageWithId(String id) {
    for (final p in _validPackages()) {
      if (p.packageId == id) return p;
    }
    return null;
  }

  Future<void> _showQuickAddStarterPackage() async {
    final nameController = TextEditingController(text: 'Standard package');
    final priceController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add a service package'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Catalogue entries must link to at least one pricing package. '
                'You can edit details later from your provider data.',
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Package name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (£)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Add package'),
          ),
        ],
      ),
    );
    final name = nameController.text.trim();
    final priceText = priceController.text.trim();
    nameController.dispose();
    priceController.dispose();

    if (ok != true || !mounted) return;

    final parsedPrice = double.tryParse(priceText);
    if (parsedPrice == null || parsedPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid package price (greater than 0).')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final fresh = await _firestore.getProvider(widget.providerId);
      if (!mounted || fresh == null) return;
      final newPkg = PackageOffering(
        packageId: const Uuid().v4(),
        name: name.isEmpty ? 'Standard package' : name,
        price: parsedPrice,
        duration: 240,
        reelsCount: 2,
        editingStyle: 'Cinematic',
        deliveryTime: 48,
        features: const ['1 event reel', 'Standard editing'],
      );
      final merged = [...fresh.packages.map((x) => x.toMap()), newPkg.toMap()];
      await _firestore.updateProvider(widget.providerId, {'packages': merged});
      if (!mounted) return;
      await _load();
      if (!mounted) return;
      setState(() {
        _selectedPackageIds.add(newPkg.packageId);
        _didApplyInitialPackagePick = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Package added and selected for this catalogue entry.'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not add package: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showEditPackagePriceDialog(PackageOffering pkg) async {
    final priceController =
        TextEditingController(text: pkg.price.toStringAsFixed(2));
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit price: ${pkg.name}'),
        content: TextField(
          controller: priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Price (£)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    final newPrice = double.tryParse(priceController.text.trim());
    priceController.dispose();

    if (ok != true || !mounted) return;
    if (newPrice == null || newPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid package price (greater than 0).')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final fresh = await _firestore.getProvider(widget.providerId);
      if (!mounted || fresh == null) return;
      final updatedPackages = fresh.packages.map((p) {
        if (p.packageId == pkg.packageId) {
          return PackageOffering(
            packageId: p.packageId,
            name: p.name,
            price: newPrice,
            duration: p.duration,
            reelsCount: p.reelsCount,
            editingStyle: p.editingStyle,
            deliveryTime: p.deliveryTime,
            highlightVideo: p.highlightVideo,
            liveReelStation: p.liveReelStation,
            features: p.features,
          );
        }
        return p;
      }).toList();
      await _firestore.updateProvider(
        widget.providerId,
        {'packages': updatedPackages.map((p) => p.toMap()).toList()},
      );
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Package price updated.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update package price: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _provider == null) return;
    final available = _validPackages();
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Add at least one service package first (use “Add starter package” above), '
            'then link it here.',
          ),
        ),
      );
      return;
    }
    if (_selectedPackageIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least one package using the dropdown above.'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    final now = DateTime.now();
    DateTime createdAt = now;
    if (!widget.isNew) {
      final ex = await _firestore.getCatalogueEvent(widget.providerId, widget.catalogueEventId);
      if (ex != null) createdAt = ex.createdAt;
    }
    final highlights = _highlights.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final gallery = _galleryUrls.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final tags = _tags.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final model = FirebaseCatalogueEventModel(
      catalogueEventId: widget.isNew ? '' : widget.catalogueEventId,
      providerId: widget.providerId,
      title: _title.text.trim(),
      shortDescription: _short.text.trim(),
      slug: null,
      eventType: _eventType,
      heroImageUrl: _heroUrl.text.trim(),
      galleryImageUrls: gallery,
      longDescription: _long.text.trim(),
      highlights: highlights,
      tags: tags,
      packageIds: _selectedPackageIds.toList(),
      isPublished: _isPublished,
      sortOrder: int.tryParse(_sortOrder.text.trim()) ?? 0,
      startingPrice: double.tryParse(_startingPrice.text.trim()),
      durationLabel: _durationLabel.text.trim().isEmpty ? null : _durationLabel.text.trim(),
      createdAt: createdAt,
      updatedAt: now,
    );

    try {
      await _firestore.upsertCatalogueEvent(widget.providerId, model);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved'), backgroundColor: AppColors.primary),
      );
      context.go('${AppRoutes.providerCatalogue}/${widget.providerId}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _buildLinkedPackagesSection() {
    final valid = _validPackages();
    final unlinked =
        valid.where((p) => !_selectedPackageIds.contains(p.packageId)).toList();

    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined, size: 22),
                const SizedBox(width: 8),
                const Text(
                  'Linked packages',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Text(
                  ' *',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Customers book this catalogue using your pricing packages. '
              'Pick at least one.',
              style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.35),
            ),
            const SizedBox(height: 6),
            Text(
              'Tip: tap Edit beside a package to change its price.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            if (valid.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'You have no service packages on your provider profile yet. '
                  'Add a starter package — it will be saved to your provider and '
                  'selected here automatically.',
                  style: TextStyle(height: 1.35),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _saving ? null : _showQuickAddStarterPackage,
                icon: const Icon(Icons.add),
                label: const Text('Add starter package'),
              ),
            ] else ...[
              if (unlinked.isNotEmpty)
                DropdownButtonFormField<String>(
                  key: ValueKey(unlinked.map((p) => p.packageId).join(',') + _selectedPackageIds.length.toString()),
                  isExpanded: true,
                  initialValue: null,
                  decoration: const InputDecoration(
                    labelText: 'Add package (dropdown)',
                    hintText: 'Choose a package to link',
                    border: OutlineInputBorder(),
                    helperText:
                        'Select each package customers can book for this catalogue entry.',
                  ),
                  items: unlinked
                      .map(
                        (p) => DropdownMenuItem<String>(
                          value: p.packageId,
                          child: Text(
                            '${p.name} — £${p.price.toStringAsFixed(2)}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: _saving
                      ? null
                      : (id) {
                          if (id == null) return;
                          setState(() => _selectedPackageIds.add(id));
                        },
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'All packages are linked. Remove a chip below to unlink one.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              const SizedBox(height: 12),
              const Text(
                'Selected for this entry',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              if (_selectedPackageIds.isEmpty)
                Text(
                  'Use the dropdown above to add packages.',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedPackageIds.map((id) {
                    final pkg = _packageWithId(id);
                    final label = pkg != null
                        ? '${pkg.name} (£${pkg.price.toStringAsFixed(2)})'
                        : id;
                    return InputChip(
                      label: Text(label),
                      onDeleted: _saving
                          ? null
                          : () => setState(() => _selectedPackageIds.remove(id)),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 12),
              const Divider(height: 24),
              Text(
                'Quick toggle',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
              const SizedBox(height: 4),
              ...valid.map((pkg) {
                final id = pkg.packageId;
                return Row(
                  children: [
                    Checkbox(
                      value: _selectedPackageIds.contains(id),
                      onChanged: _saving
                          ? null
                          : (checked) {
                              setState(() {
                                if (checked == true) {
                                  _selectedPackageIds.add(id);
                                } else {
                                  _selectedPackageIds.remove(id);
                                }
                              });
                            },
                    ),
                    Expanded(
                      child: Text('${pkg.name} — £${pkg.price.toStringAsFixed(2)}'),
                    ),
                    TextButton(
                      onPressed: _saving
                          ? null
                          : () => _showEditPackagePriceDialog(pkg),
                      child: const Text('Edit'),
                    ),
                  ],
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(widget.isNew ? 'New catalogue entry' : 'Edit entry'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _short,
              decoration: const InputDecoration(
                labelText: 'Short description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _eventType,
              decoration: const InputDecoration(
                labelText: 'Event type',
                border: OutlineInputBorder(),
              ),
              items: _eventTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _eventType = v ?? 'wedding'),
            ),
            const SizedBox(height: 16),
            _buildLinkedPackagesSection(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _long,
              decoration: const InputDecoration(
                labelText: 'Long description',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _highlights,
              decoration: const InputDecoration(
                labelText: 'Highlights (one per line)',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tags,
              decoration: const InputDecoration(
                labelText: 'Tags (comma-separated)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Hero image', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _heroUrl,
              decoration: const InputDecoration(
                hintText: 'URL or upload',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _saving ? null : _uploadHero,
              icon: const Icon(Icons.upload),
              label: const Text('Upload hero image'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _galleryUrls,
              decoration: const InputDecoration(
                labelText: 'Gallery image URLs (one per line)',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _sortOrder,
                    decoration: const InputDecoration(
                      labelText: 'Sort order',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _startingPrice,
                    decoration: const InputDecoration(
                      labelText: 'Starting price (£)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _durationLabel,
              decoration: const InputDecoration(
                labelText: 'Duration label (e.g. 3–4 hours)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Published'),
              subtitle: const Text('Visible to customers when it matches their event type'),
              value: _isPublished,
              onChanged: (v) => setState(() => _isPublished = v),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Save',
              isLoading: _saving,
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
