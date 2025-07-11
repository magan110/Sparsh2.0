import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning2/features/dashboard/presentation/pages/enhanced_home_screen.dart';
import 'package:learning2/data/network/firebase_api.dart';
import 'package:learning2/features/dashboard/presentation/pages/notification_screen.dart';
import 'package:learning2/core/theme/app_theme.dart';
import 'package:learning2/core/utils/responsive_util.dart';
import 'package:learning2/presentation/providers/theme_provider.dart';
import 'package:learning2/presentation/providers/app_state_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();

  // Set system UI overlay style for immersive experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Enable edge-to-edge experience
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Create the notification provider
  final notificationProvider = NotificationProvider();

  // Initialize Firebase API with the notification provider
  await FirebaseApi().initNotification(notificationProvider);

  runApp(
    ProviderScope(
      child: MyApp(notificationProvider: notificationProvider),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  final NotificationProvider notificationProvider;
  
  const MyApp({
    super.key,
    required this.notificationProvider,
  });

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize app state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appStateProvider.notifier).initialize();
    });
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ref.read(appStateProvider.notifier).updateAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final appState = ref.watch(appStateProvider);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SPARSH 2.0',
      
      // Enhanced Material 3 Theme Configuration
      theme: SparshTheme.lightTheme,
      darkTheme: SparshTheme.darkTheme,
      themeMode: themeMode,
      
      // High-quality rendering
      builder: (context, child) {
        return ResponsiveWrapper(
          child: child ?? const SizedBox(),
        );
      },
      
      // Enhanced navigation
      home: const EnhancedHomeScreen(),
      
      // Performance optimizations
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
        },
      ),
    );
  }
}

/// Responsive wrapper for better layout management
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  
  const ResponsiveWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize responsive utility
    ResponsiveUtil.init(context);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Set responsive constraints
        return ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 0,
            maxWidth: constraints.maxWidth,
            minHeight: 0,
            maxHeight: constraints.maxHeight,
          ),
          child: child,
        );
      },
    );
  }
}
