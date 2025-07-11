import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:learning2/features/dashboard/presentation/pages/home_screen.dart';
import 'package:learning2/data/network/firebase_api.dart';
import 'package:learning2/features/dashboard/presentation/pages/notification_screen.dart';
import 'package:learning2/core/theme/app_theme.dart';
import 'package:learning2/core/theme/theme_manager.dart';
import 'package:learning2/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Create the notification provider
  final notificationProvider = NotificationProvider();

  // Initialize Firebase API with the notification provider
  await FirebaseApi().initNotification(notificationProvider);

  // Initialize theme manager
  final themeManager = ThemeManager();

  // Check onboarding status
  OnboardingManager.checkFirstLaunch();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: notificationProvider),
        ChangeNotifierProvider.value(value: themeManager),
      ],
      child: MyApp(themeManager: themeManager),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ThemeManager themeManager;
  
  const MyApp({super.key, required this.themeManager});

  @override
  Widget build(BuildContext context) {
    return ThemeAwareApp(
      themeManager: themeManager,
      child: OnboardingManager.isFirstLaunch 
          ? const OnboardingScreen()
          : const HomeScreen(),
    );
  }
}
