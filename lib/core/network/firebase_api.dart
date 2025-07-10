import 'package:firebase_messaging/firebase_messaging.dart';
// Temporarily commenting out flutter_local_notifications due to compatibility issues
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:learning2/features/dashboard/presentation/pages/notification_screen.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  // Temporarily commenting out flutter_local_notifications due to compatibility issues
  // final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  //     FlutterLocalNotificationsPlugin();

  // Add a field to store the notification provider
  NotificationProvider? _notificationProvider;

  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print("title : ${message.notification?.title}");
    print("Body : ${message.notification?.body}");
    print("data : ${message.data}");
  }

  void handleForegroundMessage(RemoteMessage message) {
    print("Foreground Message:");
    print("title : ${message.notification?.title}");
    print("Body : ${message.notification?.body}");
    print("data : ${message.data}");

    // Show local notification
    _showLocalNotification(message);

    // Add to notification provider if available
    if (_notificationProvider != null) {
      _notificationProvider!.addFirebaseNotification(
        message.notification?.title,
        message.notification?.body,
      );
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    // Temporarily commenting out flutter_local_notifications due to compatibility issues
    // final notification = message.notification;
    // final android = message.notification?.android;
    //
    // if (notification != null && android != null) {
    //   await _flutterLocalNotificationsPlugin.show(
    //     notification.hashCode,
    //     notification.title,
    //     notification.body,
    //     const NotificationDetails(
    //       android: AndroidNotificationDetails(
    //         'high_importance_channel',
    //         'High Importance Notifications',
    //         importance: Importance.max,
    //         priority: Priority.high,
    //       ),
    //     ),
    //     payload: message.data.toString(),
    //   );
    // }

    // Just log the notification for now
    print('Local notification would show: ${message.notification?.title}');
  }

  Future<void> _initLocalNotifications() async {
    // Temporarily commenting out flutter_local_notifications due to compatibility issues
    // const AndroidInitializationSettings initializationSettingsAndroid =
    //     AndroidInitializationSettings('@mipmap/ic_launcher');
    //
    // const InitializationSettings initializationSettings =
    //     InitializationSettings(android: initializationSettingsAndroid);
    //
    // await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Just log that we would initialize notifications
    print('Local notifications would be initialized');
  }

  Future<void> initNotification([
    NotificationProvider? notificationProvider,
  ]) async {
    // Store the notification provider if provided
    _notificationProvider = notificationProvider;

    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();
    print('Token: $fcmToken');

    await _initLocalNotifications();

    // Temporarily commenting out background message handler due to compatibility issues
    // FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen(handleForegroundMessage);
  }
}
