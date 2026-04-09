import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/provider_app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/custom_button.dart';

class ProviderServiceAreasScreen extends StatefulWidget {
  const ProviderServiceAreasScreen({super.key});

  @override
  State<ProviderServiceAreasScreen> createState() => _ProviderServiceAreasScreenState();
}

class _ProviderServiceAreasScreenState extends State<ProviderServiceAreasScreen> {
  final List<String> _availableCities = [
    'London',
    'Manchester',
    'Birmingham',
    'Leeds',
    'Liverpool',
    'Bristol',
    'Glasgow',
    'Edinburgh',
    'Newcastle',
    'Cardiff',
    'Belfast',
    'Nottingham',
  ];

  static const Map<String, LatLng> _ukCityCoordinates = {
    'London': LatLng(51.5072, -0.1276),
    'Manchester': LatLng(53.4808, -2.2426),
    'Birmingham': LatLng(52.4862, -1.8904),
    'Leeds': LatLng(53.8008, -1.5491),
    'Liverpool': LatLng(53.4084, -2.9916),
    'Bristol': LatLng(51.4545, -2.5879),
    'Glasgow': LatLng(55.8642, -4.2518),
    'Edinburgh': LatLng(55.9533, -3.1883),
    'Newcastle': LatLng(54.9783, -1.6178),
    'Cardiff': LatLng(51.4816, -3.1791),
    'Belfast': LatLng(54.5973, -5.9301),
    'Nottingham': LatLng(52.9548, -1.1581),
  };
  
  final Set<String> _selectedCities = {};
  double _serviceRadius = 50.0;
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

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
          'Service Areas',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configure Service Areas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select cities where you provide services',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            
            // Service Radius
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ProviderAppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Service Radius',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${_serviceRadius.toInt()} km',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ProviderAppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: _serviceRadius,
                    min: 10,
                    max: 100,
                    divisions: 18,
                    activeColor: ProviderAppColors.primary,
                    onChanged: (value) {
                      setState(() => _serviceRadius = value);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('10 km', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      Text('100 km', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // City Selection
            const Text(
              'Select Cities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableCities.map((city) {
                final isSelected = _selectedCities.contains(city);
                return FilterChip(
                  label: Text(city),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCities.add(city);
                      } else {
                        _selectedCities.remove(city);
                      }
                    });
                    _focusMap(city, selected);
                  },
                  selectedColor: ProviderAppColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: ProviderAppColors.primary,
                  avatar: isSelected
                      ? const Icon(Icons.check_circle, size: 18, color: ProviderAppColors.primary)
                      : null,
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            
            // Map Preview (Placeholder)
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: ProviderAppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(54.5, -2.5),
                      zoom: 5.2,
                    ),
                    mapType: MapType.normal,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    compassEnabled: false,
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    markers: _buildCityMarkers(),
                    circles: _buildServiceCircles(),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _selectedCities.isEmpty
                            ? 'Map Preview: Select cities to highlight your service areas'
                            : 'Map Preview: ${_selectedCities.length} city(s) selected',
                        style: const TextStyle(fontSize: 12, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            CustomButton(
              text: 'Continue',
              onPressed: _handleContinue,
            ),
          ],
        ),
      ),
    );
  }

  void _handleContinue() {
    if (_selectedCities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one city')),
      );
      return;
    }

    context.push(AppRoutes.providerDocumentUpload);
  }

  Set<Marker> _buildCityMarkers() {
    final targets = _selectedCities.isEmpty ? _availableCities : _selectedCities.toList();

    return targets
        .where(_ukCityCoordinates.containsKey)
        .map((city) {
          final isSelected = _selectedCities.contains(city);
          return Marker(
            markerId: MarkerId(city),
            position: _ukCityCoordinates[city]!,
            infoWindow: InfoWindow(title: city),
            icon: isSelected
                ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)
                : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
          );
        })
        .toSet();
  }

  Set<Circle> _buildServiceCircles() {
    return _selectedCities
        .where(_ukCityCoordinates.containsKey)
        .map((city) {
          return Circle(
            circleId: CircleId('service_$city'),
            center: _ukCityCoordinates[city]!,
            radius: _serviceRadius * 1000,
            fillColor: ProviderAppColors.primary.withValues(alpha: 0.12),
            strokeColor: ProviderAppColors.primary.withValues(alpha: 0.8),
            strokeWidth: 2,
          );
        })
        .toSet();
  }

  Future<void> _focusMap(String city, bool selected) async {
    final controller = _mapController;
    final target = _ukCityCoordinates[city];
    if (!selected || controller == null || target == null) return;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 8.0),
      ),
    );
  }
}

