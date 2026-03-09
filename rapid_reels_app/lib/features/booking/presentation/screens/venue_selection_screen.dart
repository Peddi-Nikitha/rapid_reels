import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../../core/mock/mock_venues.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';

class VenueSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  const VenueSelectionScreen({
    super.key,
    required this.bookingData,
  });

  @override
  State<VenueSelectionScreen> createState() => _VenueSelectionScreenState();
}

class _VenueSelectionScreenState extends State<VenueSelectionScreen> {
  final _mockData = MockDataService();
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _manualVenueNameController = TextEditingController();
  final TextEditingController _manualVenueAddressController = TextEditingController();
  
  // Map state
  LatLng _currentLocation = const LatLng(18.1023, 78.8514); // Default: Siddipet
  LatLng? _manualVenueLocation; // Location for manual venue entry
  Set<Marker> _markers = {};
  Venue? _selectedVenue;
  List<Venue> _nearbyVenues = [];
  bool _isLoadingLocation = false;
  bool _showMapView = true; // Show map by default
  bool _mapInitialized = false;
  String? _mapError;
  bool _isMapLoading = true;
  bool _showManualEntry = false; // Toggle for manual entry section

  @override
  void initState() {
    super.initState();
    _loadNearbyVenues();
    // Get location in background, don't block UI
    _getCurrentLocation();
    
    // Set timeout for map initialization
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _isMapLoading && _showMapView) {
        setState(() {
          _isMapLoading = false;
          _mapError = 'Map is taking too long to load. Please check your Google Maps API key in AndroidManifest.xml';
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _manualVenueNameController.dispose();
    _manualVenueAddressController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    
    setState(() => _isLoadingLocation = true);
    
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() => _isLoadingLocation = false);
        }
        return;
      }

      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() => _isLoadingLocation = false);
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() => _isLoadingLocation = false);
        }
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 5),
      );

      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _isLoadingLocation = false;
        });

        _loadNearbyVenues();
        if (_mapController != null && _mapInitialized) {
          _moveCameraToLocation(_currentLocation);
        }
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
      // Use default location - already loaded in initState
    }
  }

  void _loadNearbyVenues() {
    final venues = _mockData.getNearbyVenues(
      _currentLocation.latitude,
      _currentLocation.longitude,
      radiusKm: 15.0,
    );

    setState(() {
      _nearbyVenues = venues;
      // Show manual entry if no venues found
      if (venues.isEmpty) {
        _showManualEntry = true;
      }
    });

    _updateMarkers();
  }

  void _updateMarkers() {
    final markers = <Marker>{};

    // Add current location marker
    markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: _currentLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Your Location'),
      ),
    );

    // Add venue markers
    for (var venue in _nearbyVenues) {
      final isSelected = _selectedVenue?.venueId == venue.venueId;
      markers.add(
        Marker(
          markerId: MarkerId(venue.venueId),
          position: LatLng(venue.latitude, venue.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isSelected ? BitmapDescriptor.hueRed : BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(
            title: venue.name,
            snippet: venue.address,
          ),
          onTap: () {
            setState(() {
              _selectedVenue = venue;
              // Clear manual entry when venue is selected
              _manualVenueNameController.clear();
              _manualVenueAddressController.clear();
              _manualVenueLocation = null;
              _showManualEntry = false;
            });
            _updateMarkers();
            _moveCameraToLocation(LatLng(venue.latitude, venue.longitude));
          },
        ),
      );
    }
    
    // Add manual location marker if set
    if (_manualVenueLocation != null && _selectedVenue == null) {
      markers.add(
        Marker(
          markerId: const MarkerId('manual_location'),
          position: _manualVenueLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: const InfoWindow(title: 'Selected Location'),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  void _moveCameraToLocation(LatLng location) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(location, 14.0),
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    try {
      _mapController = controller;
      _mapInitialized = true;
      _mapError = null;
      
      if (mounted) {
        setState(() {
          _isMapLoading = false;
        });
      }
      
      // Wait a bit for map to fully initialize
      await Future.delayed(const Duration(milliseconds: 500));
      _moveCameraToLocation(_currentLocation);
    } catch (e) {
      debugPrint('Error initializing map: $e');
      if (mounted) {
        setState(() {
          _mapError = 'Failed to load map. Please check your Google Maps API key configuration.';
          _isMapLoading = false;
        });
      }
    }
  }

  void _onMapTap(LatLng location) {
    // When user taps on map, clear selection and set manual location
    setState(() {
      _selectedVenue = null;
      _manualVenueLocation = location;
      _showManualEntry = true;
    });
    _updateMarkers();
  }
  

  void _selectVenue(Venue venue) {
    setState(() {
      _selectedVenue = venue;
      // Clear manual entry when venue is selected
      _manualVenueNameController.clear();
      _manualVenueAddressController.clear();
      _manualVenueLocation = null;
      _showManualEntry = false;
    });
    _updateMarkers();
    _moveCameraToLocation(LatLng(venue.latitude, venue.longitude));
    
    // Scroll to show map
    if (!_showMapView) {
      setState(() {
        _showMapView = true;
      });
    }
  }

  void _continueWithVenue() {
    final updatedData = Map<String, dynamic>.from(widget.bookingData);
    
    // If a venue is selected from map/list, use it
    if (_selectedVenue != null) {
      updatedData['venueName'] = _selectedVenue!.name;
      updatedData['venueAddress'] = _selectedVenue!.address;
      updatedData['venueCity'] = _selectedVenue!.city;
      updatedData['venuePincode'] = _selectedVenue!.pincode;
      updatedData['venueLatitude'] = _selectedVenue!.latitude;
      updatedData['venueLongitude'] = _selectedVenue!.longitude;
    } 
    // Otherwise, use manual entry
    else {
      final manualName = _manualVenueNameController.text.trim();
      final manualAddress = _manualVenueAddressController.text.trim();
      
      // Use manual entry if provided, otherwise use current location
      if (manualName.isNotEmpty || manualAddress.isNotEmpty) {
        updatedData['venueName'] = manualName.isNotEmpty ? manualName : 'Custom Venue';
        updatedData['venueAddress'] = manualAddress.isNotEmpty ? manualAddress : 'Custom Location';
        updatedData['venueCity'] = '';
        updatedData['venuePincode'] = '';
        // Use manual location if set, otherwise use current map center
        final location = _manualVenueLocation ?? _currentLocation;
        updatedData['venueLatitude'] = location.latitude;
        updatedData['venueLongitude'] = location.longitude;
      } else {
        // If no manual entry and no venue selected, use current location with default name
        updatedData['venueName'] = 'Custom Venue';
        updatedData['venueAddress'] = 'Custom Location';
        updatedData['venueCity'] = '';
        updatedData['venuePincode'] = '';
        final location = _manualVenueLocation ?? _currentLocation;
        updatedData['venueLatitude'] = location.latitude;
        updatedData['venueLongitude'] = location.longitude;
      }
    }

    context.push(AppRoutes.providerSelection, extra: updatedData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Select Venue'),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search venues...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      // Filter venues based on search
                      setState(() {
                        if (value.isEmpty) {
                          _loadNearbyVenues();
                        } else {
                          final allVenues = _mockData.getNearbyVenues(
                            _currentLocation.latitude,
                            _currentLocation.longitude,
                            radiusKm: 15.0,
                          );
                          _nearbyVenues = allVenues
                              .where((venue) =>
                                  venue.name.toLowerCase().contains(value.toLowerCase()) ||
                                  venue.address.toLowerCase().contains(value.toLowerCase()))
                              .toList();
                          _updateMarkers();
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Toggle Map/List View
                IconButton(
                  icon: Icon(_showMapView ? Icons.list : Icons.map),
                  tooltip: _showMapView ? 'Show List' : 'Show Map',
                  onPressed: () {
                    setState(() {
                      _showMapView = !_showMapView;
                      if (_showMapView && !_mapInitialized) {
                        _isMapLoading = true;
                      }
                    });
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(width: 8),
                // Location Button
                IconButton(
                  icon: _isLoadingLocation
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.my_location),
                  onPressed: _getCurrentLocation,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),

          // Manual Entry Section (shown when no venues found or when toggled)
          if (_nearbyVenues.isEmpty || _showManualEntry)
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Manual Venue Entry',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (_nearbyVenues.isNotEmpty)
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _showManualEntry = !_showManualEntry;
                            });
                          },
                          icon: Icon(
                            _showManualEntry ? Icons.expand_less : Icons.expand_more,
                          ),
                          label: Text(_showManualEntry ? 'Hide' : 'Show'),
                        ),
                    ],
                  ),
                  if (_showManualEntry || _nearbyVenues.isEmpty) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _manualVenueNameController,
                      decoration: InputDecoration(
                        hintText: 'Enter venue name',
                        prefixIcon: const Icon(Icons.business),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          // Clear selected venue when manual entry is used
                          if (value.isNotEmpty) {
                            _selectedVenue = null;
                            _updateMarkers();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _manualVenueAddressController,
                      decoration: InputDecoration(
                        hintText: 'Enter venue address',
                        prefixIcon: const Icon(Icons.location_on),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: 2,
                      onChanged: (value) {
                        setState(() {
                          // Clear selected venue when manual entry is used
                          if (value.isNotEmpty) {
                            _selectedVenue = null;
                            _updateMarkers();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tip: Tap on the map to set the exact location',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // Map or List View
          Expanded(
            child: _showMapView
                ? _buildMapView()
                : _buildVenueList(),
          ),

          // Nearby Venues List (if map view)
          if (_showMapView && _nearbyVenues.isNotEmpty)
            Container(
              height: 200,
              color: AppColors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Nearby Venues',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${_nearbyVenues.length} found',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _nearbyVenues.length,
                      itemBuilder: (context, index) {
                        final venue = _nearbyVenues[index];
                        return _buildVenueCard(venue);
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Continue Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: CustomButton(
                text: _selectedVenue != null
                    ? 'Continue with ${_selectedVenue!.name}'
                    : (_manualVenueNameController.text.isNotEmpty || _manualVenueAddressController.text.isNotEmpty)
                        ? 'Continue with Custom Venue'
                        : 'Select Venue',
                onPressed: _continueWithVenue,
                icon: Icons.arrow_forward,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueInfoCard(Venue venue) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Venue Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: venue.imageUrl != null
                  ? Image.network(
                      venue.imageUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: AppColors.surface,
                          child: const Icon(Icons.business, size: 40),
                        );
                      },
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: AppColors.surface,
                      child: const Icon(Icons.business, size: 40),
                    ),
            ),
            const SizedBox(width: 12),
            // Venue Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    venue.address,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (venue.rating != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${venue.rating}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (venue.reviewCount != null)
                          Text(
                            ' (${venue.reviewCount})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _selectedVenue = null;
                });
                _updateMarkers();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueCard(Venue venue) {
    final isSelected = _selectedVenue?.venueId == venue.venueId;
    
    return GestureDetector(
      onTap: () => _selectVenue(venue),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.cardBackground.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Venue Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: venue.imageUrl != null
                  ? Image.network(
                      venue.imageUrl!,
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          color: AppColors.surface,
                          child: const Icon(Icons.business, size: 40),
                        );
                      },
                    )
                  : Container(
                      height: 120,
                      color: AppColors.surface,
                      child: const Icon(Icons.business, size: 40),
                    ),
            ),
            // Venue Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    venue.address,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (venue.rating != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${venue.rating}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (venue.reviewCount != null)
                          Text(
                            ' (${venue.reviewCount})',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    // Show error message if map failed to initialize
    if (_mapError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.map_outlined,
                size: 64,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                _mapError!,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'To enable maps, add your Google Maps API key in AndroidManifest.xml',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showMapView = false;
                  });
                },
                icon: const Icon(Icons.list),
                label: const Text('Switch to List View'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show loading indicator while map initializes
    if (_isMapLoading) {
      return Stack(
        children: [
          // Placeholder background
          Container(
            color: AppColors.surface,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading map...',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Try to show map in background
          GoogleMap(
            key: const ValueKey('google_map'),
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 13.0,
            ),
            markers: _markers,
            onTap: _onMapTap,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            zoomControlsEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: false,
          ),
        ],
      );
    }

    // Show Google Map
    return Stack(
      children: [
        GoogleMap(
          key: const ValueKey('google_map'),
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _currentLocation,
            zoom: 13.0,
          ),
          markers: _markers,
          onTap: _onMapTap,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          mapType: MapType.normal,
          zoomControlsEnabled: true,
          compassEnabled: true,
          mapToolbarEnabled: false,
          // Add error handling
          onCameraMoveStarted: () {
            debugPrint('Camera move started');
          },
          onCameraIdle: () {
            debugPrint('Camera idle');
          },
        ),
        // Selected Venue Info Card
        if (_selectedVenue != null)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildVenueInfoCard(_selectedVenue!),
          ),
        // Loading overlay (if still loading)
        if (_isMapLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildVenueList() {
    if (_nearbyVenues.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                size: 64,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                'No venues found nearby',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Use the manual entry form above to enter your venue details',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _nearbyVenues.length,
      itemBuilder: (context, index) {
        final venue = _nearbyVenues[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: _buildVenueListCard(venue),
        );
      },
    );
  }

  Widget _buildVenueListCard(Venue venue) {
    final isSelected = _selectedVenue?.venueId == venue.venueId;
    
    return GestureDetector(
      onTap: () => _selectVenue(venue),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.cardBackground.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Venue Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
              child: venue.imageUrl != null
                  ? Image.network(
                      venue.imageUrl!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 120,
                          height: 120,
                          color: AppColors.background,
                          child: const Icon(Icons.business, size: 40),
                        );
                      },
                    )
                  : Container(
                      width: 120,
                      height: 120,
                      color: AppColors.background,
                      child: const Icon(Icons.business, size: 40),
                    ),
            ),
            // Venue Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venue.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      venue.address,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (venue.rating != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${venue.rating}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (venue.reviewCount != null)
                            Text(
                              ' (${venue.reviewCount} reviews)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ],
                    if (venue.capacity != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.people, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            'Capacity: ${venue.capacity}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.check_circle, color: AppColors.primary),
              ),
          ],
        ),
      ),
    );
  }
}
