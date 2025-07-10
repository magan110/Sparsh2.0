// import 'dart:async';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
//
// // This is the entry point for the background service
// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) async {
//   // This is needed for Flutter plugins to work in the background
//   DartPluginRegistrant.ensureInitialized();
//
//   // For Android, we need to handle the foreground service
//   if (service is AndroidServiceInstance) {
//     // Set initial notification info before setting as foreground service
//     service.setForegroundNotificationInfo(
//       title: 'SPARSH Location Service',
//       content: 'Initializing location tracking...',
//     );
//
//     // Always set as foreground service to ensure it keeps running when app is killed
//     service.setAsForegroundService();
//   }
//
//   // Handle stop service command
//   service.on('stop_service').listen((event) {
//     // Stop the service
//     service.stopSelf();
//   });
//
//   // Start a periodic timer to update the notification and get location
//   Timer.periodic(const Duration(minutes: 1), (timer) async {
//     // Check if the service is still running
//     if (service is AndroidServiceInstance) {
//       if (await service.isForegroundService()) {
//         // Get current location
//         try {
//           final position = await Geolocator.getCurrentPosition(
//             desiredAccuracy: LocationAccuracy.high,
//           );
//
//           // Update notification with current location
//           service.setForegroundNotificationInfo(
//             title: 'SPARSH Location Service',
//             content: 'Location: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
//           );
//
//           // Send data to UI if it's running
//           service.invoke('location_update', {
//             'latitude': position.latitude,
//             'longitude': position.longitude,
//             'timestamp': DateTime.now().toIso8601String(),
//           });
//
//           // Here you would send the location to your server
//           print('Background sync: ${position.latitude}, ${position.longitude}');
//         } catch (e) {
//           print('Error getting location in background service: $e');
//           // Update notification with error
//           service.setForegroundNotificationInfo(
//             title: 'SPARSH Location Service',
//             content: 'Error getting location: $e',
//           );
//         }
//       }
//     }
//
//     // For iOS, we don't have a foreground service, but we can still get location
//     else {
//       try {
//         final position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high,
//         );
//
//         // Send data to UI if it's running
//         service.invoke('location_update', {
//           'latitude': position.latitude,
//           'longitude': position.longitude,
//           'timestamp': DateTime.now().toIso8601String(),
//         });
//
//         // Here you would send the location to your server
//         print('Background sync iOS: ${position.latitude}, ${position.longitude}');
//       } catch (e) {
//         print('Error getting location in iOS background: $e');
//       }
//     }
//   });
// }
//
// // This is needed for iOS background execution
// @pragma('vm:entry-point')
// Future<bool> onIosBackground(ServiceInstance service) async {
//   WidgetsFlutterBinding.ensureInitialized();
//   DartPluginRegistrant.ensureInitialized();
//
//   // Get current location
//   try {
//     final position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//
//     // Here you would send the location to your server
//     print('iOS background: ${position.latitude}, ${position.longitude}');
//   } catch (e) {
//     print('Error getting location in iOS background: $e');
//   }
//
//   return true;
// }
