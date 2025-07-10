// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// // This is a temporary stub implementation of the background service
// // The actual implementation has been disabled due to compatibility issues
// class BackgroundLocationService {
//   static final BackgroundLocationService _instance =
//       BackgroundLocationService._internal();
//
//   factory BackgroundLocationService() {
//     return _instance;
//   }
//
//   BackgroundLocationService._internal();
//
//   bool _isRunning = false;
//   bool _isInitialized = false;
//   bool _autoSyncEnabled = true;
//   Position? _lastPosition;
//   DateTime? _lastSyncTime;
//
//   bool get isRunning => _isRunning;
//   bool get isInitialized => _isInitialized;
//
//   // Stub implementation of the background service
//   Future<void> initializeService({bool autoStart = false}) async {
//     if (_isInitialized) return;
//
//     // Get shared preferences instance
//     final prefs = await SharedPreferences.getInstance();
//
//     // Check if auto-sync is enabled (default to true)
//     _autoSyncEnabled = prefs.getBool('auto_sync_enabled') ?? true;
//
//     print('Background service would be initialized here');
//     _isInitialized = true;
//
//     // If auto-start is enabled, start the service
//     if (autoStart) {
//       await startService();
//     }
//   }
//
//   // Start the background service
//   Future<bool> startService() async {
//     if (!_isInitialized) {
//       await initializeService();
//     }
//
//     print('Background service would start here');
//     _isRunning = true;
//     return true;
//   }
//
//   // Stop the background service
//   Future<bool> stopService() async {
//     if (!_isInitialized) return false;
//
//     print('Background service would stop here');
//     _isRunning = false;
//     return true;
//   }
//
//   // Toggle auto-sync
//   Future<bool> setAutoSync(bool enabled) async {
//     if (!_isInitialized) return false;
//
//     _autoSyncEnabled = enabled;
//
//     // Save the setting to shared preferences
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('auto_sync_enabled', enabled);
//
//     print('Auto-sync would be set to $enabled here');
//     return true;
//   }
//
//   // Force a sync
//   Future<bool> forceSync() async {
//     if (!_isInitialized) return false;
//
//     print('Force sync would happen here');
//     return true;
//   }
//
//   // Get the last known position
//   Position? getLastPosition() {
//     return _lastPosition;
//   }
//
//   // Get the last sync time
//   DateTime? getLastSyncTime() {
//     return _lastSyncTime;
//   }
//
//   // Check if auto-sync is enabled
//   bool isAutoSyncEnabled() {
//     return _autoSyncEnabled;
//   }
// }
