import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../lib/data/services/location_service.dart';
import 'package:learning2/core/constants/fonts.dart';

class LiveLocationWidget extends StatefulWidget {
  const LiveLocationWidget({super.key});

  @override
  State<LiveLocationWidget> createState() => _LiveLocationWidgetState();
}

class _LiveLocationWidgetState extends State<LiveLocationWidget> {
  Position? _currentPosition;
  Timer? _timer;
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    // Update location every 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    final position = await _locationService.getCurrentLocation();
    setState(() {
      _currentPosition = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Live Location',
                style: Fonts.bodyBold,
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (_currentPosition != null)
            Text(
              'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}\n'
              'Long: ${_currentPosition!.longitude.toStringAsFixed(6)}',
              style: Fonts.small,
            )
          else
            const Text(
              'Fetching location...',
              style: Fonts.italic,
            ),
        ],
      ),
    );
  }
}