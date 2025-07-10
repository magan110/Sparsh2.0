// import 'dart:async';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'connectivity_service.dart';
// import 'location_database.dart';
//
// class LocationService {
//   // Stream controller for location updates
//   final _locationStreamController = StreamController<Position>.broadcast();
//
//   // Stream getter
//   Stream<Position> get locationStream => _locationStreamController.stream;
//
//   // Timer for periodic location updates
//   Timer? _locationUpdateTimer;
//
//   // Timer for syncing offline data
//   Timer? _syncTimer;
//
//   // Services
//   final ConnectivityService _connectivityService = ConnectivityService();
//   final LocationDatabase _locationDatabase = LocationDatabase();
//
//   // Flag to control automatic syncing - enabled by default
//   bool _autoSyncEnabled = true;
//
//   // Stream controller for sync status
//   final _syncStatusController =
//       StreamController<Map<String, dynamic>>.broadcast();
//
//   // Stream getter for sync status
//   Stream<Map<String, dynamic>> get syncStatusStream =>
//       _syncStatusController.stream;
//
//   // Constructor
//   LocationService() {
//     // Listen for connectivity changes
//     _connectivityService.connectionStatus.listen(_handleConnectivityChange);
//
//     // Load auto-sync setting and initialize it if not set
//     _initializeAutoSyncSetting();
//   }
//
//   // Initialize auto-sync setting
//   Future<void> _initializeAutoSyncSetting() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//
//       // Check if the setting exists
//       if (!prefs.containsKey('auto_sync_enabled')) {
//         // If not, set it to true by default
//         await prefs.setBool('auto_sync_enabled', true);
//       }
//
//       // Now load the setting (will be true by default)
//       await _loadAutoSyncSetting();
//     } catch (e) {
//       print('Error initializing auto-sync setting: $e');
//       // Ensure we still load the setting even if initialization fails
//       await _loadAutoSyncSetting();
//     }
//   }
//
//   // Load auto-sync setting from shared preferences
//   Future<void> _loadAutoSyncSetting() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       _autoSyncEnabled = prefs.getBool('auto_sync_enabled') ?? true;
//
//       // Start sync timer if auto-sync is enabled
//       if (_autoSyncEnabled) {
//         _startSyncTimer();
//       }
//     } catch (e) {
//       print('Error loading auto-sync setting: $e');
//     }
//   }
//
//   // Enable auto-sync
//   Future<void> enableAutoSync() async {
//     _autoSyncEnabled = true;
//
//     // Save setting
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('auto_sync_enabled', true);
//
//     // Start sync timer
//     _startSyncTimer();
//
//     // Update sync status
//     await _updateSyncStatus();
//   }
//
//   // Disable auto-sync
//   Future<void> disableAutoSync() async {
//     _autoSyncEnabled = false;
//
//     // Save setting
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('auto_sync_enabled', false);
//
//     // Cancel sync timer
//     _syncTimer?.cancel();
//     _syncTimer = null;
//
//     // Update sync status
//     await _updateSyncStatus();
//   }
//
//   // Get auto-sync status
//   bool get isAutoSyncEnabled => _autoSyncEnabled;
//
//   // Handle connectivity changes
//   void _handleConnectivityChange(bool isConnected) async {
//     if (isConnected) {
//       print('Internet connection restored.');
//
//       // Force auto-sync to be enabled
//       _autoSyncEnabled = true;
//
//       // Save the setting to ensure it persists
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('auto_sync_enabled', true);
//
//       print('Auto-sync is enabled. Syncing offline data...');
//
//       // Get the count of unsynced data
//       final unsyncedCount = await _locationDatabase.getUnsyncedCount();
//
//       if (unsyncedCount > 0) {
//         // Store the sync start time
//         await prefs.setString('sync_start_time', DateTime.now().toString());
//
//         // Notify listeners that sync is starting
//         _syncStatusController.add({
//           'is_online': true,
//           'unsynced_count': unsyncedCount,
//           'is_syncing': true,
//           'sync_start_time': DateTime.now().toString(),
//           'auto_sync_enabled': true, // Always true
//         });
//
//         // Perform the sync
//         final result = await syncOfflineData();
//
//         // Store the sync result
//         await prefs.setString(
//           'last_sync_result',
//           result['success'] ? 'success' : 'failed',
//         );
//         await prefs.setInt('last_synced_count', result['synced_count'] ?? 0);
//         await prefs.setString('last_sync_time', DateTime.now().toString());
//
//         // Log the result
//         print('Sync completed: ${result['success'] ? 'Success' : 'Failed'}');
//       } else {
//         print('No offline data to sync');
//       }
//     } else {
//       print('Internet connection lost. Location data will be stored locally.');
//     }
//
//     // Update sync status
//     await _updateSyncStatus();
//   }
//
//   // Start timer for periodic sync attempts
//   void _startSyncTimer() {
//     // Cancel any existing timer
//     _syncTimer?.cancel();
//
//     // Force auto-sync to be enabled
//     _autoSyncEnabled = true;
//
//     // Save the setting to ensure it persists
//     SharedPreferences.getInstance().then((prefs) {
//       prefs.setBool('auto_sync_enabled', true);
//     });
//
//     print('Starting periodic sync timer (auto-sync always enabled)');
//
//     // Check every 1 minute for unsynced data
//     _syncTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
//       // Force auto-sync to always be enabled
//       _autoSyncEnabled = true;
//
//       // Only attempt sync if we're online
//       if (await _connectivityService.checkConnectivity()) {
//         // Check if there's any unsynced data
//         final unsyncedCount = await _locationDatabase.getUnsyncedCount();
//
//         if (unsyncedCount > 0) {
//           print(
//             'Found $unsyncedCount unsynced records during periodic check. Syncing now...',
//           );
//
//           // Notify listeners that sync is starting
//           _syncStatusController.add({
//             'is_online': true,
//             'unsynced_count': unsyncedCount,
//             'is_syncing': true,
//             'sync_start_time': DateTime.now().toString(),
//             'auto_sync_enabled': _autoSyncEnabled,
//           });
//
//           // Perform the sync
//           final result = await syncOfflineData();
//
//           // Store the sync result
//           final prefs = await SharedPreferences.getInstance();
//           await prefs.setString(
//             'last_sync_result',
//             result['success'] ? 'success' : 'failed',
//           );
//           await prefs.setInt('last_synced_count', result['synced_count'] ?? 0);
//           await prefs.setString('last_sync_time', DateTime.now().toString());
//
//           // Log the result
//           print('Periodic sync completed');
//         }
//       }
//
//       // Always update the sync status
//       await _updateSyncStatus();
//     });
//   }
//
//   /// Start periodic location tracking and API posting
//   void startLocationTracking({
//     Duration interval = const Duration(minutes: 5),
//     bool postToApi = true,
//   }) {
//     // Cancel any existing timer
//     _locationUpdateTimer?.cancel();
//
//     // Start a new timer that gets location and optionally posts to API
//     _locationUpdateTimer = Timer.periodic(interval, (_) async {
//       print('===== LOCATION UPDATE TIMER FIRED =====');
//       print('Time: ${DateTime.now().toString()}');
//       print('Post to API: $postToApi');
//
//       // Check if we should post based on the last post time
//       if (postToApi) {
//         final prefs = await SharedPreferences.getInstance();
//         final lastPostTimeStr = prefs.getString('last_api_post_time');
//
//         if (lastPostTimeStr != null) {
//           final lastPostTime = DateTime.parse(lastPostTimeStr);
//           final currentTime = DateTime.now();
//           final difference = currentTime.difference(lastPostTime);
//
//           // If it's been less than 55 seconds since the last post, skip this update
//           // (Using 55 seconds instead of 60 to account for slight timer variations)
//           if (difference.inSeconds < 55) {
//             print(
//               'UI timer skipping update: Less than 1 minute since last post (${difference.inSeconds} seconds)',
//             );
//             return; // Skip this timer tick entirely
//           }
//         }
//       }
//
//       try {
//         print('Getting current location...');
//         final position = await getCurrentLocation();
//
//         if (position != null) {
//           print('Location obtained:');
//           print('  Latitude: ${position.latitude}');
//           print('  Longitude: ${position.longitude}');
//           print('  Accuracy: ${position.accuracy} meters');
//
//           // Add to stream
//           _locationStreamController.add(position);
//           print('Location added to stream');
//
//           // Post to API if requested
//           if (postToApi) {
//             print('Posting to API...');
//             await postLocationToApi(position);
//           } else {
//             print('Skipping API post (not enabled)');
//           }
//         }
//       } catch (e) {
//         print('Error in location tracking: $e');
//       }
//
//       print('======================================');
//     });
//   }
//
//   /// Start location refreshing only (no API posting)
//   void startLocationRefreshing({
//     Duration interval = const Duration(minutes: 5),
//   }) {
//     startLocationTracking(interval: interval, postToApi: false);
//   }
//
//   /// Stop location tracking
//   void stopLocationTracking() {
//     _locationUpdateTimer?.cancel();
//     _locationUpdateTimer = null;
//   }
//
//   /// Dispose resources
//   void dispose() {
//     // Only stop the UI-related timers and close stream controllers
//     // We don't want to affect the background service
//
//     // Stop the location update timer for the UI
//     _locationUpdateTimer?.cancel();
//     _locationUpdateTimer = null;
//
//     // Don't cancel the sync timer as it might be used by the background service
//     // _syncTimer?.cancel();
//
//     // Close stream controllers
//     _locationStreamController.close();
//     _syncStatusController.close();
//   }
//
//   /// Update sync status and notify listeners
//   Future<void> _updateSyncStatus() async {
//     try {
//       final unsyncedCount = await _locationDatabase.getUnsyncedCount();
//       final totalCount = await _locationDatabase.getTotalCount();
//
//       final status = {
//         'unsynced_count': unsyncedCount,
//         'total_count': totalCount,
//         'is_online': _connectivityService.isConnected,
//         'last_sync_attempt': DateTime.now().toString(),
//         'auto_sync_enabled': _autoSyncEnabled,
//         'is_syncing': false, // Reset syncing status
//       };
//
//       // Store in shared preferences
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setInt('unsynced_location_count', unsyncedCount);
//       await prefs.setInt('total_location_count', totalCount);
//       await prefs.setBool('is_online', _connectivityService.isConnected);
//       await prefs.setBool('auto_sync_enabled', _autoSyncEnabled);
//       await prefs.setString('last_sync_attempt', DateTime.now().toString());
//
//       // Notify listeners
//       _syncStatusController.add(status);
//     } catch (e) {
//       print('Error updating sync status: $e');
//     }
//   }
//
//   /// Sync offline data with the API
//   Future<Map<String, dynamic>> syncOfflineData() async {
//     if (!_connectivityService.isConnected) {
//       return {
//         'success': false,
//         'message': 'No internet connection',
//         'synced_count': 0,
//       };
//     }
//
//     try {
//       // Get all locations (all are unsynced since we delete after syncing)
//       final unsyncedLocations = await _locationDatabase.getUnsyncedLocations();
//
//       if (unsyncedLocations.isEmpty) {
//         return {
//           'success': true,
//           'message': 'No data to sync',
//           'synced_count': 0,
//         };
//       }
//
//       // All locations in the database are unsynced (we delete after syncing)
//
//       int syncedCount = 0;
//
//       // Process each location
//       for (final locationData in unsyncedLocations) {
//         // Create a Position object from the stored data
//         final position = Position(
//           latitude: locationData['latitude'],
//           longitude: locationData['longitude'],
//           timestamp: DateTime.parse(locationData['timestamp']),
//           accuracy: locationData['accuracy'],
//           altitude: 0,
//           heading: 0,
//           speed: 0,
//           speedAccuracy: 0,
//           altitudeAccuracy: 0,
//           headingAccuracy: 0,
//         );
//
//         // Post to API
//         final result = await postLocationToApi(position);
//
//         if (result['success']) {
//           // Delete the record from the database since it's been successfully synced
//           await _locationDatabase.deleteLocation(locationData['id']);
//           syncedCount++;
//
//           // Print sync information
//           print('\n===== SYNCED LOCATION DATA FROM DATABASE TO API =====');
//           print('Time: ${DateTime.now().toString()}');
//           print('Database ID: ${locationData['id']}');
//           print('Latitude: ${locationData['latitude']}');
//           print('Longitude: ${locationData['longitude']}');
//           print('Accuracy: ${locationData['accuracy']} meters');
//           print('Original Timestamp: ${locationData['timestamp']}');
//           print('Action: DELETED FROM DATABASE after successful sync');
//           print('====================================================');
//         } else {
//           // If we fail to sync, stop trying for now
//           // We'll try again later
//           print('\n===== FAILED TO SYNC LOCATION DATA =====');
//           print('Database ID: ${locationData['id']}');
//           print('Reason: API post failed');
//           print('Action: Keeping in database for later sync');
//           print('========================================');
//           break;
//         }
//       }
//
//       // If we're online and all data was synced successfully, delete any remaining data
//       // This ensures we don't keep unnecessary data in the database
//       if (_connectivityService.isConnected && syncedCount > 0) {
//         try {
//           // Check if there's any data left
//           final remainingCount = await _locationDatabase.getUnsyncedCount();
//           if (remainingCount > 0) {
//             print('\n===== CLEANING UP DATABASE =====');
//             print('Time: ${DateTime.now().toString()}');
//             print('Remaining Records: $remainingCount');
//             print('Action: DELETING ALL REMAINING RECORDS');
//             print('Reason: Online and sync completed successfully');
//             print('===================================');
//             await _locationDatabase.deleteAllLocations();
//           }
//         } catch (e) {
//           print('Error cleaning up database: $e');
//         }
//       }
//
//       // Update sync status
//       await _updateSyncStatus();
//
//       return {
//         'success': true,
//         'message': 'Synced $syncedCount locations',
//         'synced_count': syncedCount,
//       };
//     } catch (e) {
//       print('Error syncing offline data: $e');
//       return {'success': false, 'message': 'Error: $e', 'synced_count': 0};
//     }
//   }
//
//   /// Get the current location of the device.
//   ///
//   /// Returns a [Position] object containing latitude and longitude,
//   /// or null if location services are disabled or permissions are denied.
//   Future<Position?> getCurrentLocation() async {
//     // Check if location services are enabled
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       // Location services are disabled
//       return Future.error('Location services are disabled.');
//     }
//
//     // Check location permissions
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       // Request permission
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         // Permissions are denied
//         return Future.error('Location permissions are denied.');
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       // Permissions are permanently denied
//       return Future.error(
//         'Location permissions are permanently denied, we cannot request permissions.',
//       );
//     }
//
//     // Permissions are granted, get the current position
//     return await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//   }
//
//   /// Post location data to API
//   ///
//   /// Takes a [Position] object and sends the latitude and longitude to the API
//   /// If offline, stores the data locally to be sent later
//   Future<Map<String, dynamic>> postLocationToApi(Position position) async {
//     // Check if we should post based on the last post time (enforce 1-minute interval)
//     final prefs = await SharedPreferences.getInstance();
//     final lastPostTimeStr = prefs.getString('last_api_post_time');
//
//     if (lastPostTimeStr != null) {
//       final lastPostTime = DateTime.parse(lastPostTimeStr);
//       final currentTime = DateTime.now();
//       final difference = currentTime.difference(lastPostTime);
//
//       // If it's been less than 1 minute since the last post, skip this post
//       if (difference.inSeconds < 60) {
//         print(
//           'Skipping API post: Less than 1 minute since last post (${difference.inSeconds} seconds)',
//         );
//         return {
//           'success': false,
//           'message': 'Skipped: Less than 1 minute since last post',
//           'skipped': true,
//         };
//       }
//     }
//
//     // Check if we're online
//     final isOnline = await _connectivityService.checkConnectivity();
//
//     if (isOnline) {
//       // When online, don't store data locally - just post directly to API
//       // No local database storage needed when online
//       print('Device is online. Posting directly to API without local storage.');
//     } else {
//       // If offline, check if we should store this data point
//       // We only store data every 1 minute when offline
//       try {
//         // Get the last stored location timestamp
//         final lastLocation = await _locationDatabase.getLastLocation();
//
//         if (lastLocation != null) {
//           final lastTimestamp = DateTime.parse(lastLocation['timestamp']);
//           final currentTime = DateTime.now();
//           final difference = currentTime.difference(lastTimestamp);
//
//           // Only store if it's been at least 1 minute since the last stored location
//           if (difference.inMinutes >= 1) {
//             final id = await _locationDatabase.insertLocation(position);
//             print('\n===== STORING LOCATION DATA IN DATABASE =====');
//             print('Time: ${DateTime.now().toString()}');
//             print('Database ID: $id');
//             print('Latitude: ${position.latitude}');
//             print('Longitude: ${position.longitude}');
//             print('Accuracy: ${position.accuracy} meters');
//             print('Connection Status: OFFLINE');
//             print('Storage: STORED IN DATABASE (offline mode)');
//             print('Reason: Device is offline, storing for later sync');
//             print('Interval: 1-minute interval between stored points');
//             print('============================================');
//           } else {
//             print(
//               'Offline mode: Skipping location storage (less than 1 minute since last store)',
//             );
//             // Return early without storing
//             return {
//               'success': false,
//               'offline': true,
//               'message':
//                   'Device is offline. Data point skipped (< 1 min interval).',
//             };
//           }
//         } else {
//           // If there's no previous location, store this one
//           final id = await _locationDatabase.insertLocation(position);
//           print('\n===== STORING FIRST LOCATION DATA IN DATABASE =====');
//           print('Time: ${DateTime.now().toString()}');
//           print('Database ID: $id');
//           print('Latitude: ${position.latitude}');
//           print('Longitude: ${position.longitude}');
//           print('Accuracy: ${position.accuracy} meters');
//           print('Connection Status: OFFLINE');
//           print('Storage: STORED IN DATABASE (offline mode)');
//           print('Reason: First location point, no previous data');
//           print('================================================');
//         }
//       } catch (e) {
//         print('Error handling offline storage: $e');
//       }
//
//       print('Device is offline. Location data stored locally for later sync.');
//       await _updateSyncStatus();
//       return {
//         'success': false,
//         'offline': true,
//         'message': 'Device is offline. Data stored locally.',
//       };
//     }
//
//     // Using the provided API endpoint
//     final url = Uri.parse(
//       'https://qa.birlawhite.com/BirlaWhite/NoSec/geoLoc.jsp',
//     );
//
//     try {
//       // Create query parameters with accuracy in meters
//       final queryParams = {
//         'latiLong': position.latitude.toString(),
//         'longTitu': position.longitude.toString(),
//         'accuracy': position.accuracy.toStringAsFixed(
//           2,
//         ), // Accuracy in meters with 2 decimal places
//       };
//
//       // Print the data being posted to the API
//       print('\n===== POSTING LOCATION DATA TO API =====');
//       print('Time: ${DateTime.now().toString()}');
//       print('API Endpoint: ${url.toString()}');
//       print('Parameters:');
//       queryParams.forEach((key, value) => print('  $key: $value'));
//       print('Connection Status: ONLINE');
//       print('Storage: NOT STORED IN DATABASE (online mode)');
//       print('========================================');
//
//       // Using query parameters as specified in the API URL
//       final response = await http.get(
//         url.replace(queryParameters: queryParams),
//       );
//
//       // Print the API response
//       print('===== API RESPONSE =====');
//       print('Status Code: ${response.statusCode}');
//       print('Response Body: ${response.body}');
//       print('========================');
//
//       if (response.statusCode == 200) {
//         // Save the current time as the last post time
//         await prefs.setString('last_api_post_time', DateTime.now().toString());
//
//         // Force auto-sync to be enabled
//         _autoSyncEnabled = true;
//         await prefs.setBool('auto_sync_enabled', true);
//
//         // Always try to sync any pending offline data
//         if (await _locationDatabase.getUnsyncedCount() > 1) {
//           // Only try to sync if we have more than the current record
//           syncOfflineData();
//         }
//
//         return {'success': true, 'body': response.body};
//       } else {
//         return {
//           'success': false,
//           'body': response.body,
//           'statusCode': response.statusCode,
//         };
//       }
//     } catch (e) {
//       // Print error information
//       print('===== API ERROR =====');
//       print('Error: $e');
//       print('=====================');
//
//       return {'success': false, 'error': e.toString()};
//     }
//   }
// }
