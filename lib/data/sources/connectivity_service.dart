// import 'dart:async';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class ConnectivityService {
//   static final ConnectivityService _instance = ConnectivityService._internal();
//   final Connectivity _connectivity = Connectivity();
//
//   // Stream controller for connectivity status
//   final StreamController<bool> _connectionStatusController =
//       StreamController<bool>.broadcast();
//
//   // Stream of connectivity status (true = connected, false = disconnected)
//   Stream<bool> get connectionStatus => _connectionStatusController.stream;
//
//   // Current connectivity status
//   bool _isConnected = false;
//   bool get isConnected => _isConnected;
//
//   factory ConnectivityService() {
//     return _instance;
//   }
//
//   ConnectivityService._internal() {
//     // Initialize connectivity monitoring
//     _initConnectivity();
//
//     // Listen for connectivity changes
//     _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
//   }
//
//   // Initialize connectivity status
//   Future<void> _initConnectivity() async {
//     try {
//       List<ConnectivityResult> results =
//           await _connectivity.checkConnectivity();
//       _updateConnectionStatus(results);
//     } catch (e) {
//       print('Connectivity initialization error: $e');
//       _isConnected = false;
//       _connectionStatusController.add(false);
//     }
//   }
//
//   // Update connection status based on connectivity results
//   void _updateConnectionStatus(List<ConnectivityResult> results) {
//     bool wasConnected = _isConnected;
//
//     // If any result is not 'none', then we have connectivity
//     _isConnected = results.any((result) => result != ConnectivityResult.none);
//
//     // Only add to stream if there's a change in status
//     if (wasConnected != _isConnected) {
//       _connectionStatusController.add(_isConnected);
//       print('Connection status changed: $_isConnected');
//
//       // Store the connectivity status in shared preferences for persistence
//       _saveConnectivityStatus();
//     }
//   }
//
//   // Save connectivity status to shared preferences
//   Future<void> _saveConnectivityStatus() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('is_online', _isConnected);
//       await prefs.setString(
//         'last_connectivity_change',
//         DateTime.now().toIso8601String(),
//       );
//     } catch (e) {
//       print('Error saving connectivity status: $e');
//     }
//   }
//
//   // Check current connectivity status
//   Future<bool> checkConnectivity() async {
//     try {
//       List<ConnectivityResult> results =
//           await _connectivity.checkConnectivity();
//       _updateConnectionStatus(results);
//       return _isConnected;
//     } catch (e) {
//       print('Error checking connectivity: $e');
//       return false;
//     }
//   }
//
//   // Dispose resources
//   void dispose() {
//     _connectionStatusController.close();
//   }
// }
