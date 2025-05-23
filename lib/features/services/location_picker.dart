import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:logger/logger.dart';

class LocationPicker extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;

  const LocationPicker({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late GoogleMapController _mapController;
  late LatLng _currentPosition;
  final TextEditingController _searchController = TextEditingController();
  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    _currentPosition = LatLng(widget.initialLatitude, widget.initialLongitude);
    _checkAndRequestPermission();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkAndRequestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return; // Check if still mounted
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled.')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return; // Check if still mounted
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied.')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return; // Check if still mounted
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.')));
      return;
    }

    // Get current location if needed
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if (!mounted) return; // Check if still mounted before setState
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
    _mapController.animateCamera(CameraUpdate.newLatLng(_currentPosition));
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _currentPosition = position;
    });
    _fetchAddress(position.latitude, position.longitude);
  }

  Future<void> _fetchAddress(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        if (!mounted) return; // Check if still mounted before setState
        setState(() {
          _searchController.text = '${placemark.street ?? ''}, ${placemark.locality ?? ''}, ${placemark.country ?? ''}'.trim();
        });
      }
    } catch (e) {
      logger.d('Error fetching address: $e');
      if (!mounted) return; // Check if still mounted
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error fetching address')));
    }
  }

  Future<void> _searchLocation(String query) async {
    try {
      // Parse query as coordinates (e.g., "6.9271, 79.8612") or address
      if (query.contains(',')) {
        final coords = query.split(',').map((e) => e.trim()).toList();
        if (coords.length == 2) {
          final latitude = double.tryParse(coords[0]) ?? 0.0;
          final longitude = double.tryParse(coords[1]) ?? 0.0;
          if (latitude != 0.0 && longitude != 0.0) {
            if (!mounted) return; // Check if still mounted before setState
            setState(() {
              _currentPosition = LatLng(latitude, longitude);
            });
            _mapController.animateCamera(CameraUpdate.newLatLng(_currentPosition));
            await _fetchAddress(latitude, longitude);
            return;
          }
        }
      }

      // If not coordinates, treat as address
      final locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final location = locations.first;
        if (!mounted) return; // Check if still mounted before setState
        setState(() {
          _currentPosition = LatLng(location.latitude, location.longitude);
        });
        _mapController.animateCamera(CameraUpdate.newLatLng(_currentPosition));
        await _fetchAddress(location.latitude, location.longitude);
      } else {
        if (!mounted) return; // Check if still mounted
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location not found')));
      }
    } catch (e) {
      logger.d('Error searching location: $e');
      if (!mounted) return; // Check if still mounted
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error searching location')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Enter Location (e.g., Address or "Latitude, Longitude")',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchLocation(_searchController.text),
                ),
              ),
              onSubmitted: (value) => _searchLocation(value),
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                _mapController.animateCamera(CameraUpdate.newLatLng(_currentPosition));
              },
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 15.0,
              ),
              onTap: _onMapTap,
              markers: {
                Marker(
                  markerId: const MarkerId('selectedLocation'),
                  position: _currentPosition,
                  infoWindow: const InfoWindow(title: 'Selected Location'),
                ),
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                if (!mounted) return; // Check if still mounted before popping
                Navigator.pop(context, _currentPosition);
              },
              child: const Text('Select Location'),
            ),
          ),
        ],
      ),
    );
  }
}