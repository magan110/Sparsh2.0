import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

/// Main app state provider
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(AppState()) {
    _initialize();
  }

  late Connectivity _connectivity;
  late DeviceInfoPlugin _deviceInfo;

  Future<void> _initialize() async {
    _connectivity = Connectivity();
    _deviceInfo = DeviceInfoPlugin();
    
    // Initialize connectivity monitoring
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      updateConnectivity(result);
    });

    // Load initial state
    await _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load connectivity state
    final connectivityResult = await _connectivity.checkConnectivity();
    
    // Load device info
    final deviceInfo = await _getDeviceInfo();
    
    // Load user preferences
    final isFirstLaunch = prefs.getBool('is_first_launch') ?? true;
    final userId = prefs.getString('user_id');
    
    state = state.copyWith(
      connectivity: connectivityResult,
      deviceInfo: deviceInfo,
      isFirstLaunch: isFirstLaunch,
      userId: userId,
      isInitialized: true,
    );
  }

  Future<DeviceInfo> _getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return DeviceInfo(
          platform: 'Android',
          model: androidInfo.model,
          version: androidInfo.version.release,
          isPhysicalDevice: androidInfo.isPhysicalDevice,
          identifier: androidInfo.id,
        );
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return DeviceInfo(
          platform: 'iOS',
          model: iosInfo.model,
          version: iosInfo.systemVersion,
          isPhysicalDevice: iosInfo.isPhysicalDevice,
          identifier: iosInfo.identifierForVendor ?? 'unknown',
        );
      }
    } catch (e) {
      debugPrint('Error getting device info: $e');
    }
    
    return DeviceInfo(
      platform: 'Unknown',
      model: 'Unknown',
      version: 'Unknown',
      isPhysicalDevice: true,
      identifier: 'unknown',
    );
  }

  void initialize() {
    if (!state.isInitialized) {
      _initialize();
    }
  }

  void updateConnectivity(ConnectivityResult result) {
    state = state.copyWith(connectivity: result);
  }

  void updateAppLifecycleState(AppLifecycleState lifecycleState) {
    state = state.copyWith(appLifecycleState: lifecycleState);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void setFirstLaunch(bool isFirstLaunch) async {
    state = state.copyWith(isFirstLaunch: isFirstLaunch);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_launch', isFirstLaunch);
  }

  void setUserId(String? userId) async {
    state = state.copyWith(userId: userId);
    final prefs = await SharedPreferences.getInstance();
    if (userId != null) {
      await prefs.setString('user_id', userId);
    } else {
      await prefs.remove('user_id');
    }
  }

  void updateUserPreferences(Map<String, dynamic> preferences) {
    state = state.copyWith(userPreferences: preferences);
  }

  void setUserPreference(String key, dynamic value) {
    final newPreferences = Map<String, dynamic>.from(state.userPreferences);
    newPreferences[key] = value;
    state = state.copyWith(userPreferences: newPreferences);
  }

  void removeUserPreference(String key) {
    final newPreferences = Map<String, dynamic>.from(state.userPreferences);
    newPreferences.remove(key);
    state = state.copyWith(userPreferences: newPreferences);
  }

  void addNotification(AppNotification notification) {
    final newNotifications = List<AppNotification>.from(state.notifications);
    newNotifications.add(notification);
    state = state.copyWith(notifications: newNotifications);
  }

  void removeNotification(String notificationId) {
    final newNotifications = state.notifications
        .where((notification) => notification.id != notificationId)
        .toList();
    state = state.copyWith(notifications: newNotifications);
  }

  void clearNotifications() {
    state = state.copyWith(notifications: []);
  }

  void markNotificationAsRead(String notificationId) {
    final newNotifications = state.notifications.map((notification) {
      if (notification.id == notificationId) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();
    state = state.copyWith(notifications: newNotifications);
  }

  void updateLocation(double latitude, double longitude) {
    state = state.copyWith(
      currentLatitude: latitude,
      currentLongitude: longitude,
    );
  }

  void updateBatteryLevel(int batteryLevel) {
    state = state.copyWith(batteryLevel: batteryLevel);
  }

  void updateNetworkType(String networkType) {
    state = state.copyWith(networkType: networkType);
  }

  void setOfflineMode(bool isOffline) {
    state = state.copyWith(isOfflineMode: isOffline);
  }

  void incrementAppUsageTime() {
    state = state.copyWith(appUsageTime: state.appUsageTime + 1);
  }

  void logUserAction(String action) {
    final newActions = List<String>.from(state.userActions);
    newActions.add('${DateTime.now().toIso8601String()}: $action');
    
    // Keep only last 100 actions
    if (newActions.length > 100) {
      newActions.removeRange(0, newActions.length - 100);
    }
    
    state = state.copyWith(userActions: newActions);
  }

  void updatePerformanceMetrics(Map<String, double> metrics) {
    state = state.copyWith(performanceMetrics: metrics);
  }

  void addPerformanceMetric(String key, double value) {
    final newMetrics = Map<String, double>.from(state.performanceMetrics);
    newMetrics[key] = value;
    state = state.copyWith(performanceMetrics: newMetrics);
  }

  void resetAppState() {
    state = AppState();
  }
}

class AppState {
  final bool isInitialized;
  final bool isLoading;
  final String? error;
  final bool isFirstLaunch;
  final String? userId;
  final ConnectivityResult connectivity;
  final DeviceInfo deviceInfo;
  final AppLifecycleState appLifecycleState;
  final Map<String, dynamic> userPreferences;
  final List<AppNotification> notifications;
  final double? currentLatitude;
  final double? currentLongitude;
  final int batteryLevel;
  final String networkType;
  final bool isOfflineMode;
  final int appUsageTime;
  final List<String> userActions;
  final Map<String, double> performanceMetrics;

  AppState({
    this.isInitialized = false,
    this.isLoading = false,
    this.error,
    this.isFirstLaunch = true,
    this.userId,
    this.connectivity = ConnectivityResult.none,
    this.deviceInfo = const DeviceInfo(),
    this.appLifecycleState = AppLifecycleState.resumed,
    this.userPreferences = const {},
    this.notifications = const [],
    this.currentLatitude,
    this.currentLongitude,
    this.batteryLevel = 100,
    this.networkType = 'unknown',
    this.isOfflineMode = false,
    this.appUsageTime = 0,
    this.userActions = const [],
    this.performanceMetrics = const {},
  });

  AppState copyWith({
    bool? isInitialized,
    bool? isLoading,
    String? error,
    bool? isFirstLaunch,
    String? userId,
    ConnectivityResult? connectivity,
    DeviceInfo? deviceInfo,
    AppLifecycleState? appLifecycleState,
    Map<String, dynamic>? userPreferences,
    List<AppNotification>? notifications,
    double? currentLatitude,
    double? currentLongitude,
    int? batteryLevel,
    String? networkType,
    bool? isOfflineMode,
    int? appUsageTime,
    List<String>? userActions,
    Map<String, double>? performanceMetrics,
  }) {
    return AppState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      userId: userId ?? this.userId,
      connectivity: connectivity ?? this.connectivity,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      appLifecycleState: appLifecycleState ?? this.appLifecycleState,
      userPreferences: userPreferences ?? this.userPreferences,
      notifications: notifications ?? this.notifications,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      networkType: networkType ?? this.networkType,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
      appUsageTime: appUsageTime ?? this.appUsageTime,
      userActions: userActions ?? this.userActions,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
    );
  }

  bool get isConnected => connectivity != ConnectivityResult.none;
  bool get hasError => error != null;
  bool get hasNotifications => notifications.isNotEmpty;
  int get unreadNotificationCount => notifications.where((n) => !n.isRead).length;
  bool get isLocationAvailable => currentLatitude != null && currentLongitude != null;
}

class DeviceInfo {
  final String platform;
  final String model;
  final String version;
  final bool isPhysicalDevice;
  final String identifier;

  const DeviceInfo({
    this.platform = 'Unknown',
    this.model = 'Unknown',
    this.version = 'Unknown',
    this.isPhysicalDevice = true,
    this.identifier = 'unknown',
  });

  DeviceInfo copyWith({
    String? platform,
    String? model,
    String? version,
    bool? isPhysicalDevice,
    String? identifier,
  }) {
    return DeviceInfo(
      platform: platform ?? this.platform,
      model: model ?? this.model,
      version: version ?? this.version,
      isPhysicalDevice: isPhysicalDevice ?? this.isPhysicalDevice,
      identifier: identifier ?? this.identifier,
    );
  }
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String type;
  final Map<String, dynamic> data;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.type = 'general',
    this.data = const {},
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    bool? isRead,
    String? type,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      data: data ?? this.data,
    );
  }
}

/// Analytics provider for tracking user interactions
final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier();
});

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier() : super(AnalyticsState());

  void trackEvent(String eventName, {Map<String, dynamic>? parameters}) {
    final event = AnalyticsEvent(
      name: eventName,
      timestamp: DateTime.now(),
      parameters: parameters ?? {},
    );
    
    final newEvents = List<AnalyticsEvent>.from(state.events);
    newEvents.add(event);
    
    // Keep only last 1000 events
    if (newEvents.length > 1000) {
      newEvents.removeRange(0, newEvents.length - 1000);
    }
    
    state = state.copyWith(events: newEvents);
  }

  void trackScreenView(String screenName) {
    trackEvent('screen_view', parameters: {'screen_name': screenName});
  }

  void trackUserAction(String action, {Map<String, dynamic>? parameters}) {
    trackEvent('user_action', parameters: {
      'action': action,
      ...?parameters,
    });
  }

  void trackError(String error, {String? stackTrace}) {
    trackEvent('error', parameters: {
      'error': error,
      'stack_trace': stackTrace,
    });
  }

  void trackPerformance(String metric, double value) {
    trackEvent('performance', parameters: {
      'metric': metric,
      'value': value,
    });
  }

  void clearEvents() {
    state = state.copyWith(events: []);
  }

  void updateSessionInfo(String sessionId, Duration sessionDuration) {
    state = state.copyWith(
      currentSessionId: sessionId,
      sessionDuration: sessionDuration,
    );
  }
}

class AnalyticsState {
  final List<AnalyticsEvent> events;
  final String? currentSessionId;
  final Duration sessionDuration;

  AnalyticsState({
    this.events = const [],
    this.currentSessionId,
    this.sessionDuration = Duration.zero,
  });

  AnalyticsState copyWith({
    List<AnalyticsEvent>? events,
    String? currentSessionId,
    Duration? sessionDuration,
  }) {
    return AnalyticsState(
      events: events ?? this.events,
      currentSessionId: currentSessionId ?? this.currentSessionId,
      sessionDuration: sessionDuration ?? this.sessionDuration,
    );
  }
}

class AnalyticsEvent {
  final String name;
  final DateTime timestamp;
  final Map<String, dynamic> parameters;

  AnalyticsEvent({
    required this.name,
    required this.timestamp,
    required this.parameters,
  });
}

/// Feature flag provider for A/B testing and feature toggles
final featureFlagProvider = StateNotifierProvider<FeatureFlagNotifier, FeatureFlagState>((ref) {
  return FeatureFlagNotifier();
});

class FeatureFlagNotifier extends StateNotifier<FeatureFlagState> {
  FeatureFlagNotifier() : super(FeatureFlagState()) {
    _loadFeatureFlags();
  }

  Future<void> _loadFeatureFlags() async {
    final prefs = await SharedPreferences.getInstance();
    final flags = <String, bool>{};
    
    // Load stored feature flags
    for (final key in prefs.getKeys()) {
      if (key.startsWith('feature_flag_')) {
        final flagName = key.substring('feature_flag_'.length);
        flags[flagName] = prefs.getBool(key) ?? false;
      }
    }
    
    state = state.copyWith(flags: flags);
  }

  Future<void> setFeatureFlag(String flagName, bool enabled) async {
    final newFlags = Map<String, bool>.from(state.flags);
    newFlags[flagName] = enabled;
    state = state.copyWith(flags: newFlags);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('feature_flag_$flagName', enabled);
  }

  bool isFeatureEnabled(String flagName) {
    return state.flags[flagName] ?? false;
  }

  void enableFeature(String flagName) {
    setFeatureFlag(flagName, true);
  }

  void disableFeature(String flagName) {
    setFeatureFlag(flagName, false);
  }

  void toggleFeature(String flagName) {
    final currentValue = isFeatureEnabled(flagName);
    setFeatureFlag(flagName, !currentValue);
  }
}

class FeatureFlagState {
  final Map<String, bool> flags;

  FeatureFlagState({
    this.flags = const {},
  });

  FeatureFlagState copyWith({
    Map<String, bool>? flags,
  }) {
    return FeatureFlagState(
      flags: flags ?? this.flags,
    );
  }
}