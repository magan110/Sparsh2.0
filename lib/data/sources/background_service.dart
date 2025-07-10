// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class BackgroundLocationService {
//   static const String _channelName = 'com.example.learning2/location_service';
//   static const MethodChannel _channel = MethodChannel(_channelName);
//
//   bool _isInitialized = false;
//   final StreamController<Position> _locationStreamController = StreamController<Position>.broadcast();
//   Timer? _locationUpdateTimer;
//
//   // Stream to listen for location updates
//   Stream<Position> get locationStream => _locationStreamController.stream;
//
//   // Initialize the background service
//   Future<void> initializeService({bool autoStart = false}) async {
//     if (_isInitialized) return;
//
//     // NEVER auto-start the service, regardless of the parameter
//     // This ensures the user must manually start the service each time
//
//     // Start polling for location updates from the native service
//     _startLocationPolling();
//
//     _isInitialized = true;
//
//     // Reset the saved preference to ensure it's always manual
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('background_service_enabled', false);
//   }
//
//   // Start polling for location updates
//   void _startLocationPolling() {
//     // Cancel any existing timer
//     _locationUpdateTimer?.cancel();
//
//     // Poll for location updates every 10 seconds when the app is in foreground
//     _locationUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
//       try {
//         final Map<dynamic, dynamic>? locationData = await _channel.invokeMethod('getLastLocation');
//
//         if (locationData != null) {
//           final position = Position(
//             latitude: locationData['latitude'] as double,
//             longitude: locationData['longitude'] as double,
//             timestamp: DateTime.fromMillisecondsSinceEpoch(locationData['timestamp'] as int),
//             accuracy: 0.0,
//             altitude: 0.0,
//             heading: 0.0,
//             speed: 0.0,
//             speedAccuracy: 0.0,
//             altitudeAccuracy: 0.0,
//             headingAccuracy: 0.0,
//           );
//
//           // Add to stream
//           _locationStreamController.add(position);
//         }
//       } catch (e) {
//         print('Error polling location: $e');
//       }
//     });
//   }
//
//   // Check if the service is running
//   Future<bool> get isRunning async => await isServiceRunning();
//
//   // Check if the native service is running
//   Future<bool> isServiceRunning() async {
//     try {
//       // Always check the actual service status, not the saved preference
//       final bool isRunning = await _channel.invokeMethod('isServiceRunning') ?? false;
//
//       // If we're checking and the service is not running, ensure the preference is reset
//       if (!isRunning) {
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setBool('background_service_enabled', false);
//       }
//
//       return isRunning;
//     } catch (e) {
//       print('Error checking if service is running: $e');
//       // If there's an error, assume it's not running and reset preference
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('background_service_enabled', false);
//       return false;
//     }
//   }
//
//   // Start the background service
//   Future<bool> startService() async {
//     if (!_isInitialized) {
//       await initializeService();
//     }
//
//     // Check if location services are enabled
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       print('Location services are disabled');
//       return false;
//     }
//
//     // Check location permissions
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         print('Location permissions are denied');
//         return false;
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       print('Location permissions are permanently denied');
//       return false;
//     }
//
//     // For background location, we need the 'always' permission on Android
//     if (permission != LocationPermission.always) {
//       print('Background location permission not granted, requesting...');
//       // Try to request background permission
//       try {
//         permission = await Geolocator.requestPermission();
//         if (permission != LocationPermission.always) {
//           print('Background location permission not granted');
//           // We'll still try to start the service, but warn the user
//         }
//       } catch (e) {
//         print('Error requesting background location permission: $e');
//       }
//     }
//
//     try {
//       // Start the native service
//       await _channel.invokeMethod('startLocationService');
//
//       // Save the state to SharedPreferences - this is only for the current session
//       // It will be reset when the app is restarted
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('background_service_enabled', true);
//
//       return true;
//     } catch (e) {
//       print('Error starting background service: $e');
//       // On error, ensure preference is reset
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('background_service_enabled', false);
//       return false;
//     }
//   }
//
//   // Stop the background service
//   Future<bool> stopService() async {
//     if (!_isInitialized) return false;
//
//     try {
//       // Stop the native service
//       await _channel.invokeMethod('stopLocationService');
//
//       // Always reset the preference to ensure it's manual
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('background_service_enabled', false);
//
//       return true;
//     } catch (e) {
//       print('Error stopping background service: $e');
//       // Even on error, reset the preference
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('background_service_enabled', false);
//       return false;
//     }
//   }
//
//   // Dispose resources
//   void dispose() {
//     _locationUpdateTimer?.cancel();
//     _locationStreamController.close();
//   }
// }
//
