// import 'dart:async';
// import 'package:flutter/material.dart';
// // import 'package:geolocator/geolocator.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// // import '../services/location_service.dart';
// // import '../services/background_service.dart';
//
// class LiveLocationScreen extends StatefulWidget {
//   const LiveLocationScreen({super.key});
//
//   @override
//   State<LiveLocationScreen> createState() => _LiveLocationScreenState();
// }
//
// class _LiveLocationScreenState extends State<LiveLocationScreen> {
//   // Position? _currentPosition;
//   String _errorMessage = '';
//   bool _isLoading = true;
//   bool _isTracking = false;
//   bool _isRefreshing = false;
//   bool _isBackgroundServiceRunning = false;
//   String _lastApiPostStatus = '';
//   DateTime? _lastApiPostTime;
//   DateTime? _lastRefreshTime;
//   bool _isOnline = true;
//   int _unsyncedCount = 0;
//   int _totalStoredCount = 0;
//   DateTime? _lastSyncAttempt;
//   bool _isSyncing = false;
//   int _lastSyncedCount = 0;
//   bool _isBackgroundServiceEnabled = false; // Track background service state
//   // StreamSubscription<Position>? _locationSubscription;
//   // StreamSubscription<Map<String, dynamic>>? _syncStatusSubscription;
//   // final LocationService _locationService = LocationService();
//   // final BackgroundLocationService _backgroundService = BackgroundLocationService();
//
//   @override
//   void initState() {
//     super.initState();
//     // _getCurrentLocation();
//     // _initializeBackgroundService();
//     // _loadSyncStatus();
//
//     // // Listen to location stream
//     // _locationSubscription = _locationService.locationStream.listen((position) {
//     //   setState(() {
//     //     _currentPosition = position;
//     //     _isLoading = false;
//
//     //     // Update last refresh time when location is updated via stream
//     //     if (_isRefreshing) {
//     //       _lastRefreshTime = DateTime.now();
//     //     }
//     //   });
//     // });
//
//     // // Listen to sync status updates
//     // _syncStatusSubscription = _locationService.syncStatusStream.listen((
//     //   status,
//     // ) {
//     //   setState(() {
//     //     _isOnline = status['is_online'] ?? true;
//     //     _unsyncedCount = status['unsynced_count'] ?? 0;
//     //     _totalStoredCount = status['total_count'] ?? 0;
//     //     _isSyncing = status['is_syncing'] ?? false;
//     //     _lastSyncedCount = status['synced_count'] ?? 0;
//     //     _lastSyncAttempt =
//     //         status['last_sync_attempt'] != null
//     //             ? DateTime.parse(status['last_sync_attempt'])
//     //             : null;
//     //   });
//     // });
//   }
//
//   // Load initial sync status
//   Future<void> _loadSyncStatus() async {
//     // try {
//     //   final prefs = await SharedPreferences.getInstance();
//     //   setState(() {
//     //     _isOnline = prefs.getBool('is_online') ?? true;
//     //     _unsyncedCount = prefs.getInt('unsynced_location_count') ?? 0;
//     //     _totalStoredCount = prefs.getInt('total_location_count') ?? 0;
//     //     _lastSyncedCount = prefs.getInt('last_synced_count') ?? 0;
//
//     //     // Check if a sync is in progress
//     //     final syncStartTimeStr = prefs.getString('sync_start_time');
//     //     final lastSyncTimeStr = prefs.getString('last_sync_time');
//
//     //     if (syncStartTimeStr != null && lastSyncTimeStr != null) {
//     //       // If sync_start_time is more recent than last_sync_time, a sync is in progress
//     //       final syncStartTime = DateTime.parse(syncStartTimeStr);
//     //       final lastSyncTime = DateTime.parse(lastSyncTimeStr);
//     //       _isSyncing = syncStartTime.isAfter(lastSyncTime);
//     //     } else {
//     //       _isSyncing = false;
//     //     }
//
//     //     final lastSyncStr = prefs.getString('last_sync_attempt');
//     //     _lastSyncAttempt =
//     //         lastSyncStr != null ? DateTime.parse(lastSyncStr) : null;
//     //   });
//     // } catch (e) {
//     //   print('Error loading sync status: $e');
//     // }
//   }
//
//   Future<void> _initializeBackgroundService() async {
//     // // Initialize the background service but don't auto-start it
//     // await _backgroundService.initializeService(autoStart: false);
//
//     // // Check if the service is already running
//     // final isRunning = await _backgroundService.isRunning;
//
//     // // Update UI to reflect the actual state of the background service
//     // setState(() {
//     //   _isBackgroundServiceRunning = isRunning;
//     //   _isBackgroundServiceEnabled = isRunning;
//     // });
//
//     // // Listen for location updates from the background service
//     // _backgroundService.locationStream.listen((position) {
//     //   setState(() {
//     //     _currentPosition = position;
//     //     _lastRefreshTime = DateTime.now();
//     //   });
//     // });
//   }
//
//   Future<void> _toggleBackgroundService() async {
//     // try {
//     //   if (_isBackgroundServiceRunning) {
//     //     // Stop the background service
//     //     final result = await _backgroundService.stopService();
//     //     if (result) {
//     //       setState(() {
//     //         _isBackgroundServiceRunning = false;
//     //         _isBackgroundServiceEnabled = false;
//     //       });
//
//     //       // Save the state to SharedPreferences
//     //       final prefs = await SharedPreferences.getInstance();
//     //       await prefs.setBool('background_service_enabled', false);
//
//     //       _showSnackBar('Background location service stopped');
//     //     } else {
//     //       _showSnackBar('Failed to stop background service');
//     //     }
//     //   } else {
//     //     // Request location permissions first
//     //     LocationPermission permission = await Geolocator.checkPermission();
//     //     if (permission == LocationPermission.denied) {
//     //       permission = await Geolocator.requestPermission();
//     //       if (permission == LocationPermission.denied) {
//     //         _showSnackBar('Location permissions are denied');
//     //         return;
//     //       }
//     //     }
//
//     //     if (permission == LocationPermission.deniedForever) {
//     //       _showSnackBar(
//     //         'Location permissions are permanently denied, please enable in settings',
//     //       );
//     //       return;
//     //     }
//
//     //     // For background location, we need the 'always' permission on Android
//     //     if (permission != LocationPermission.always) {
//     //       _showSnackBar(
//     //         'Background location permission is required for the service to work when the app is closed. ' +
//     //         'Please grant "Allow all the time" permission in the next dialog.',
//     //       );
//
//     //       // Try to request background permission
//     //       permission = await Geolocator.requestPermission();
//     //       if (permission != LocationPermission.always) {
//     //         _showSnackBar(
//     //           'Background location permission not granted. The service may not work properly when the app is closed.',
//     //         );
//     //         // We'll still try to start the service, but warn the user
//     //       }
//     //     }
//
//     //     // Start the background service
//     //     final result = await _backgroundService.startService();
//     //     if (result) {
//     //       setState(() {
//     //         _isBackgroundServiceRunning = true;
//     //         _isBackgroundServiceEnabled = true;
//     //       });
//
//     //       // Save the state to SharedPreferences
//     //       final prefs = await SharedPreferences.getInstance();
//     //       await prefs.setBool('background_service_enabled', true);
//
//     //       _showSnackBar(
//     //         'Background location service started. Location will be posted every 1 minute even when app is closed.',
//     //       );
//     //     } else {
//     //       _showSnackBar('Failed to start background service');
//     //     }
//     //   }
//     // } catch (e) {
//     //   _showSnackBar('Error: $e');
//     //   print('Error toggling background service: $e');
//     // }
//   }
//
//   @override
//   void dispose() {
//     // Cancel subscriptions to prevent memory leaks
//     _locationSubscription?.cancel();
//     _syncStatusSubscription?.cancel();
//
//     // Dispose the location service but don't stop the background service
//     // This ensures the background service continues running even when the app is closed
//     _locationService.dispose();
//
//     super.dispose();
//   }
//
//   void _toggleLocationTracking() {
//     setState(() {
//       _isTracking = !_isTracking;
//     });
//
//     if (_isTracking) {
//       // Start tracking with 1-minute interval
//       _locationService.startLocationTracking(
//         interval: const Duration(minutes: 1),
//       );
//       _showSnackBar(
//         'Location tracking started. Data will be sent every 1 minute.',
//       );
//     } else {
//       // Stop tracking if refreshing is also off
//       if (!_isRefreshing) {
//         _locationService.stopLocationTracking();
//       } else {
//         // If refreshing is on, switch to refresh-only mode
//         _locationService.startLocationRefreshing(
//           interval: const Duration(minutes: 1),
//         );
//       }
//       _showSnackBar('API posting stopped.');
//     }
//   }
//
//   void _toggleLocationRefreshing() {
//     setState(() {
//       _isRefreshing = !_isRefreshing;
//       _lastRefreshTime = _isRefreshing ? DateTime.now() : null;
//     });
//
//     if (_isRefreshing) {
//       if (_isTracking) {
//         // If tracking is already on, it's already refreshing too
//         _showSnackBar('Location is already being refreshed every 1 minute.');
//       } else {
//         // Start refresh-only mode
//         _locationService.startLocationRefreshing(
//           interval: const Duration(minutes: 1),
//         );
//         _showSnackBar(
//           'Location refreshing started. Will update every 1 minute.',
//         );
//       }
//     } else {
//       // If tracking is on, keep the timer running for API posts
//       if (_isTracking) {
//         _locationService.startLocationTracking(
//           interval: const Duration(minutes: 1),
//         );
//       } else {
//         // Both tracking and refreshing are off, stop everything
//         _locationService.stopLocationTracking();
//         _showSnackBar('Location refreshing stopped.');
//       }
//     }
//   }
//
//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
//     );
//   }
//
//   Future<void> _getCurrentLocation() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });
//
//     try {
//       final position = await _locationService.getCurrentLocation();
//       setState(() {
//         _currentPosition = position;
//         _isLoading = false;
//
//         // Update last refresh time when manually refreshed
//         _lastRefreshTime = DateTime.now();
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//         _isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _postLocationManually() async {
//     if (_currentPosition == null) {
//       _showSnackBar('No location data available to post');
//       return;
//     }
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       final result = await _locationService.postLocationToApi(
//         _currentPosition!,
//       );
//
//       String statusMessage;
//       if (result['success']) {
//         statusMessage = 'Successfully posted to Birla White API';
//         // Add response details if available
//         if (result['body'] != null && result['body'].toString().isNotEmpty) {
//           statusMessage += '\nResponse: ${result['body']}';
//         }
//       } else if (result.containsKey('skipped') && result['skipped'] == true) {
//         statusMessage = 'Skipped: Less than 1 minute since last post';
//       } else {
//         statusMessage = 'Failed to post: ';
//         if (result['error'] != null) {
//           statusMessage += result['error'];
//         } else if (result['statusCode'] != null) {
//           statusMessage += 'Status ${result['statusCode']}';
//           if (result['body'] != null) {
//             statusMessage += ' - ${result['body']}';
//           }
//         } else {
//           statusMessage += 'Unknown error';
//         }
//       }
//
//       setState(() {
//         _isLoading = false;
//         _lastApiPostStatus = statusMessage;
//         _lastApiPostTime = DateTime.now();
//       });
//
//       if (result.containsKey('skipped') && result['skipped'] == true) {
//         _showSnackBar('Skipped: Less than 1 minute since last post');
//       } else {
//         _showSnackBar(
//           result['success']
//               ? 'Location data posted successfully'
//               : 'Failed to post location data',
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _lastApiPostStatus = 'Error: $e';
//         _lastApiPostTime = DateTime.now();
//       });
//
//       _showSnackBar('Failed to post location data: $e');
//     }
//   }
//
//   /// Log current location data to the console for debugging
//   void _logLocationData() {
//     if (_currentPosition == null) {
//       _showSnackBar('No location data available to log');
//       return;
//     }
//
//     // Get accuracy in meters with 2 decimal places
//     String accuracyMeters = _currentPosition!.accuracy.toStringAsFixed(2);
//
//     // Print location data to console
//     print('\n===== CURRENT LOCATION DATA =====');
//     print('Timestamp: ${DateTime.now().toString()}');
//     print('Latitude: ${_currentPosition!.latitude}');
//     print('Longitude: ${_currentPosition!.longitude}');
//     print('Accuracy: ${_currentPosition!.accuracy} meters');
//     print('Altitude: ${_currentPosition!.altitude} meters');
//     print('Speed: ${_currentPosition!.speed} m/s');
//     print('Heading: ${_currentPosition!.heading}°');
//     print('API URL that would be called:');
//     print(
//       'https://qa.birlawhite.com/BirlaWhite/NoSec/geoLoc.jsp?latiLong=${_currentPosition!.latitude}&longTitu=${_currentPosition!.longitude}&accuracy=$accuracyMeters',
//     );
//     print('==================================\n');
//
//     _showSnackBar('Location data logged to console');
//   }
//
//   /// Manually sync offline data
//   Future<void> _syncOfflineData() async {
//     // Set syncing state
//     setState(() {
//       _isLoading = true;
//       _isSyncing = true;
//     });
//
//     try {
//       // Store sync start time
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('sync_start_time', DateTime.now().toString());
//
//       // Perform the sync
//       final result = await _locationService.syncOfflineData();
//
//       // Store sync result
//       await prefs.setString(
//         'last_sync_result',
//         result['success'] ? 'success' : 'failed',
//       );
//       await prefs.setInt('last_synced_count', result['synced_count'] ?? 0);
//       await prefs.setString('last_sync_time', DateTime.now().toString());
//
//       // Update UI state
//       setState(() {
//         _isLoading = false;
//         _isSyncing = false;
//         _lastSyncedCount = result['synced_count'] ?? 0;
//         // The sync status subscription will update the other fields
//       });
//
//       if (result['success']) {
//         _showSnackBar('Data synced successfully');
//       } else {
//         _showSnackBar('Failed to sync data');
//       }
//     } catch (e) {
//       // Reset syncing state
//       setState(() {
//         _isLoading = false;
//         _isSyncing = false;
//       });
//       _showSnackBar('Error syncing data: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Live Location'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//         elevation: 4,
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 20),
//               _buildLocationIcon(),
//               const SizedBox(height: 20),
//               _buildLocationInfo(),
//               const SizedBox(height: 20),
//               _buildTrackingControls(),
//               const SizedBox(height: 20),
//               _buildBackgroundServiceCard(),
//               const SizedBox(height: 20),
//               _buildOfflineSyncCard(),
//               const SizedBox(height: 20),
//               _buildApiStatus(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLocationIcon() {
//     return Container(
//       width: 100,
//       height: 100,
//       decoration: BoxDecoration(
//         color: Colors.blue.withAlpha(25),
//         shape: BoxShape.circle,
//       ),
//       child: const Icon(Icons.location_on, color: Colors.blue, size: 60),
//     );
//   }
//
//   Widget _buildLocationInfo() {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     if (_errorMessage.isNotEmpty) {
//       return Column(
//         children: [
//           const Icon(Icons.error_outline, color: Colors.red, size: 48),
//           const SizedBox(height: 16),
//           Text(
//             'Error: $_errorMessage',
//             style: const TextStyle(color: Colors.red),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       );
//     }
//
//     if (_currentPosition == null) {
//       return const Text(
//         'Location data not available',
//         style: TextStyle(fontSize: 18),
//       );
//     }
//
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           children: [
//             const Text(
//               'Current Location',
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             _buildCoordinateRow(
//               'Latitude',
//               _currentPosition!.latitude.toStringAsFixed(6),
//             ),
//             const Divider(height: 30),
//             _buildCoordinateRow(
//               'Longitude',
//               _currentPosition!.longitude.toStringAsFixed(6),
//             ),
//             const Divider(height: 30),
//             _buildCoordinateRow(
//               'Accuracy',
//               '${_currentPosition!.accuracy.toStringAsFixed(2)} meters',
//             ),
//             const Divider(height: 30),
//             _buildCoordinateRow(
//               'Altitude',
//               '${_currentPosition!.altitude.toStringAsFixed(2)} meters',
//             ),
//             const Divider(height: 30),
//             _buildCoordinateRow(
//               'Last Updated',
//               DateTime.now().toString().substring(0, 19),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCoordinateRow(String label, String value) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//         ),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Colors.blue,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTrackingControls() {
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton.icon(
//               onPressed: _getCurrentLocation,
//               icon: const Icon(Icons.refresh),
//               label: const Text('Refresh Now'),
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 12,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 16),
//             ElevatedButton.icon(
//               onPressed: _postLocationManually,
//               icon: const Icon(Icons.upload),
//               label: const Text('Post to API'),
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 12,
//                 ),
//                 backgroundColor: Colors.green,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 10),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton.icon(
//               onPressed: _logLocationData,
//               icon: const Icon(Icons.code),
//               label: const Text('Log Data to Console'),
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 12,
//                 ),
//                 backgroundColor: Colors.purple,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         Card(
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 const Text(
//                   'Automatic Location Refreshing',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 const Text(
//                   'When enabled, your location will be refreshed every 1 minute',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 14),
//                 ),
//                 const SizedBox(height: 16),
//                 Switch.adaptive(
//                   value: _isRefreshing,
//                   activeColor: Colors.blue,
//                   onChanged: (value) => _toggleLocationRefreshing(),
//                 ),
//                 Text(
//                   _isRefreshing
//                       ? 'Auto-Refresh Enabled'
//                       : 'Auto-Refresh Disabled',
//                   style: TextStyle(
//                     color: _isRefreshing ? Colors.blue : Colors.grey,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 if (_lastRefreshTime != null) ...[
//                   const SizedBox(height: 4),
//                   Text(
//                     'Last refresh: ${_lastRefreshTime.toString().substring(0, 19)}',
//                     style: const TextStyle(fontSize: 12, color: Colors.grey),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//         Card(
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 const Text(
//                   'Automatic API Posting',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 const Text(
//                   'When enabled, your location with accuracy (in meters) will be sent to Birla White server every 1 minute',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 14),
//                 ),
//                 const SizedBox(height: 16),
//                 Switch.adaptive(
//                   value: _isTracking,
//                   activeColor: Colors.green,
//                   onChanged: (value) => _toggleLocationTracking(),
//                 ),
//                 Text(
//                   _isTracking ? 'API Posting Enabled' : 'API Posting Disabled',
//                   style: TextStyle(
//                     color: _isTracking ? Colors.green : Colors.grey,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildOfflineSyncCard() {
//     return Card(
//       elevation: 4,
//       color:
//           _isSyncing
//               ? Colors.blue.shade50
//               : !_isOnline
//               ? Colors.orange.shade50
//               : null,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(
//           color:
//               _isSyncing
//                   ? Colors.blue
//                   : !_isOnline
//                   ? Colors.orange
//                   : Colors.grey.shade300,
//           width: _isSyncing ? 2 : 1,
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   _isSyncing
//                       ? Icons.sync
//                       : _isOnline
//                       ? Icons.cloud_done
//                       : Icons.cloud_off,
//                   color:
//                       _isSyncing
//                           ? Colors.blue
//                           : _isOnline
//                           ? Colors.green
//                           : Colors.orange,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   _isSyncing ? 'Syncing Data...' : 'Offline Data Storage',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: _isSyncing ? Colors.blue : null,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             // Show normal status
//             Text(
//               _isOnline
//                   ? _isBackgroundServiceEnabled
//                       ? 'Device is online. Location data is being sent to the server every 1 minute.'
//                       : 'Device is online.'
//                   : _isBackgroundServiceEnabled
//                   ? 'Device is offline. Background service will store location data every 1 minute and sync when online.'
//                   : 'Device is offline. Location data is being stored every 1 minute.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: _isOnline ? Colors.green : Colors.orange,
//               ),
//             ),
//
//             // Show a subtle indicator if syncing is happening
//             if (_isSyncing) ...[
//               const SizedBox(height: 8),
//               SizedBox(
//                 height: 2,
//                 child: LinearProgressIndicator(
//                   backgroundColor: Colors.transparent,
//                   valueColor: AlwaysStoppedAnimation<Color>(
//                     Colors.blue.withAlpha(128),
//                   ),
//                 ),
//               ),
//             ],
//             const SizedBox(height: 16),
//             // Show connection status only
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   _isOnline ? Icons.cloud_done : Icons.cloud_off,
//                   size: 16,
//                   color: _isOnline ? Colors.green : Colors.orange,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   _isOnline ? 'Connected' : 'Offline',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: _isOnline ? Colors.green : Colors.orange,
//                   ),
//                 ),
//               ],
//             ),
//             // Only show a simple sync button when online
//             if (_isOnline) ...[
//               const SizedBox(height: 16),
//               TextButton.icon(
//                 onPressed: _syncOfflineData,
//                 icon: const Icon(Icons.sync, size: 16),
//                 label: const Text('Sync data', style: TextStyle(fontSize: 12)),
//                 style: TextButton.styleFrom(
//                   foregroundColor: Colors.blue,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 4,
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBackgroundServiceCard() {
//     return Card(
//       elevation: 4,
//       color: _isBackgroundServiceRunning ? Colors.purple.shade50 : null,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(
//           color:
//               _isBackgroundServiceRunning
//                   ? Colors.purple
//                   : Colors.grey.shade300,
//           width: 1,
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.location_on,
//                   color:
//                       _isBackgroundServiceRunning ? Colors.purple : Colors.grey,
//                 ),
//                 const SizedBox(width: 8),
//                 const Text(
//                   'Background Location Service',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             const Text(
//               'When enabled, location data will be posted to the server every 1 minute even when the app is completely closed',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 14),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'This feature uses a persistent foreground service that will show a notification',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
//             ),
//             const SizedBox(height: 16),
//             Switch.adaptive(
//               value: _isBackgroundServiceRunning,
//               activeColor: Colors.purple,
//               onChanged: (value) => _toggleBackgroundService(),
//             ),
//             Text(
//               _isBackgroundServiceRunning
//                   ? 'Background Service Enabled'
//                   : 'Background Service Disabled',
//               style: TextStyle(
//                 color:
//                     _isBackgroundServiceRunning ? Colors.purple : Colors.grey,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Note: This will continue to use battery and data even when the app is closed',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey.shade700,
//                 fontStyle: FontStyle.italic,
//               ),
//             ),
//             if (_isBackgroundServiceRunning) ...[
//               const SizedBox(height: 12),
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.purple.withAlpha(20),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Text(
//                   'Location data will continue to be sent even if you force-close the app',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.purple,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildApiStatus() {
//     if (_lastApiPostStatus.isEmpty) {
//       return const SizedBox.shrink();
//     }
//
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             const Text(
//               'API Status',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color:
//                     _lastApiPostStatus.contains('Success')
//                         ? Colors.green.withAlpha(20)
//                         : Colors.red.withAlpha(20),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 _lastApiPostStatus,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color:
//                       _lastApiPostStatus.contains('Success')
//                           ? Colors.green.shade800
//                           : Colors.red.shade800,
//                 ),
//               ),
//             ),
//             if (_lastApiPostTime != null) ...[
//               const SizedBox(height: 4),
//               Text(
//                 'Last updated: ${_lastApiPostTime.toString().substring(0, 19)}',
//                 style: const TextStyle(fontSize: 12, color: Colors.grey),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
