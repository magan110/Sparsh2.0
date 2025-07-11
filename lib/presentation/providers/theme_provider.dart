import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme provider for managing light/dark mode
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  static const String _themeKey = 'theme_mode';

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_themeKey) ?? 'light';
    
    switch (themeName) {
      case 'light':
        state = ThemeMode.light;
        break;
      case 'dark':
        state = ThemeMode.dark;
        break;
      case 'system':
        state = ThemeMode.system;
        break;
    }
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    state = themeMode;
    final prefs = await SharedPreferences.getInstance();
    
    String themeName = switch (themeMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    
    await prefs.setString(_themeKey, themeName);
  }

  void toggleTheme() {
    if (state == ThemeMode.light) {
      setTheme(ThemeMode.dark);
    } else {
      setTheme(ThemeMode.light);
    }
  }
}

/// Dynamic color provider for Material 3
final dynamicColorProvider = StateNotifierProvider<DynamicColorNotifier, Color?>((ref) {
  return DynamicColorNotifier();
});

class DynamicColorNotifier extends StateNotifier<Color?> {
  DynamicColorNotifier() : super(null);

  void setDynamicColor(Color color) {
    state = color;
  }

  void clearDynamicColor() {
    state = null;
  }
}

/// Responsive breakpoint provider
final responsiveBreakpointProvider = StateNotifierProvider<ResponsiveBreakpointNotifier, ResponsiveBreakpoint>((ref) {
  return ResponsiveBreakpointNotifier();
});

class ResponsiveBreakpointNotifier extends StateNotifier<ResponsiveBreakpoint> {
  ResponsiveBreakpointNotifier() : super(ResponsiveBreakpoint.mobile);

  void updateBreakpoint(double width) {
    final newBreakpoint = _getBreakpointFromWidth(width);
    if (newBreakpoint != state) {
      state = newBreakpoint;
    }
  }

  ResponsiveBreakpoint _getBreakpointFromWidth(double width) {
    if (width < 600) {
      return ResponsiveBreakpoint.mobile;
    } else if (width < 900) {
      return ResponsiveBreakpoint.tablet;
    } else if (width < 1200) {
      return ResponsiveBreakpoint.desktop;
    } else {
      return ResponsiveBreakpoint.largeDesktop;
    }
  }
}

enum ResponsiveBreakpoint {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Animation preferences provider
final animationPreferencesProvider = StateNotifierProvider<AnimationPreferencesNotifier, AnimationPreferences>((ref) {
  return AnimationPreferencesNotifier();
});

class AnimationPreferencesNotifier extends StateNotifier<AnimationPreferences> {
  AnimationPreferencesNotifier() : super(AnimationPreferences()) {
    _loadPreferences();
  }

  static const String _animationsEnabledKey = 'animations_enabled';
  static const String _hapticFeedbackKey = 'haptic_feedback';
  static const String _animationSpeedKey = 'animation_speed';

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    state = AnimationPreferences(
      animationsEnabled: prefs.getBool(_animationsEnabledKey) ?? true,
      hapticFeedback: prefs.getBool(_hapticFeedbackKey) ?? true,
      animationSpeed: prefs.getDouble(_animationSpeedKey) ?? 1.0,
    );
  }

  Future<void> setAnimationsEnabled(bool enabled) async {
    state = state.copyWith(animationsEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_animationsEnabledKey, enabled);
  }

  Future<void> setHapticFeedback(bool enabled) async {
    state = state.copyWith(hapticFeedback: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticFeedbackKey, enabled);
  }

  Future<void> setAnimationSpeed(double speed) async {
    state = state.copyWith(animationSpeed: speed);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_animationSpeedKey, speed);
  }
}

class AnimationPreferences {
  final bool animationsEnabled;
  final bool hapticFeedback;
  final double animationSpeed;

  AnimationPreferences({
    this.animationsEnabled = true,
    this.hapticFeedback = true,
    this.animationSpeed = 1.0,
  });

  AnimationPreferences copyWith({
    bool? animationsEnabled,
    bool? hapticFeedback,
    double? animationSpeed,
  }) {
    return AnimationPreferences(
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      animationSpeed: animationSpeed ?? this.animationSpeed,
    );
  }
}

/// App layout provider for managing layout state
final appLayoutProvider = StateNotifierProvider<AppLayoutNotifier, AppLayoutState>((ref) {
  return AppLayoutNotifier();
});

class AppLayoutNotifier extends StateNotifier<AppLayoutState> {
  AppLayoutNotifier() : super(AppLayoutState());

  void updateScreenSize(Size size) {
    state = state.copyWith(screenSize: size);
  }

  void updateOrientation(Orientation orientation) {
    state = state.copyWith(orientation: orientation);
  }

  void updateSafeAreaPadding(EdgeInsets padding) {
    state = state.copyWith(safeAreaPadding: padding);
  }

  void updateKeyboardHeight(double height) {
    state = state.copyWith(keyboardHeight: height);
  }

  void toggleSidebar() {
    state = state.copyWith(isSidebarOpen: !state.isSidebarOpen);
  }

  void setSidebarOpen(bool isOpen) {
    state = state.copyWith(isSidebarOpen: isOpen);
  }
}

class AppLayoutState {
  final Size screenSize;
  final Orientation orientation;
  final EdgeInsets safeAreaPadding;
  final double keyboardHeight;
  final bool isSidebarOpen;

  AppLayoutState({
    this.screenSize = Size.zero,
    this.orientation = Orientation.portrait,
    this.safeAreaPadding = EdgeInsets.zero,
    this.keyboardHeight = 0.0,
    this.isSidebarOpen = false,
  });

  AppLayoutState copyWith({
    Size? screenSize,
    Orientation? orientation,
    EdgeInsets? safeAreaPadding,
    double? keyboardHeight,
    bool? isSidebarOpen,
  }) {
    return AppLayoutState(
      screenSize: screenSize ?? this.screenSize,
      orientation: orientation ?? this.orientation,
      safeAreaPadding: safeAreaPadding ?? this.safeAreaPadding,
      keyboardHeight: keyboardHeight ?? this.keyboardHeight,
      isSidebarOpen: isSidebarOpen ?? this.isSidebarOpen,
    );
  }
}

/// Navigation state provider
final navigationProvider = StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  return NavigationNotifier();
});

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(NavigationState());

  void setCurrentIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }

  void setCurrentRoute(String route) {
    state = state.copyWith(currentRoute: route);
  }

  void addToHistory(String route) {
    final newHistory = List<String>.from(state.history);
    newHistory.add(route);
    state = state.copyWith(history: newHistory);
  }

  void clearHistory() {
    state = state.copyWith(history: []);
  }

  bool canGoBack() {
    return state.history.isNotEmpty;
  }

  void goBack() {
    if (canGoBack()) {
      final newHistory = List<String>.from(state.history);
      final previousRoute = newHistory.removeLast();
      state = state.copyWith(
        history: newHistory,
        currentRoute: previousRoute,
      );
    }
  }
}

class NavigationState {
  final int currentIndex;
  final String currentRoute;
  final List<String> history;

  NavigationState({
    this.currentIndex = 0,
    this.currentRoute = '/',
    this.history = const [],
  });

  NavigationState copyWith({
    int? currentIndex,
    String? currentRoute,
    List<String>? history,
  }) {
    return NavigationState(
      currentIndex: currentIndex ?? this.currentIndex,
      currentRoute: currentRoute ?? this.currentRoute,
      history: history ?? this.history,
    );
  }
}

/// Performance monitoring provider
final performanceProvider = StateNotifierProvider<PerformanceNotifier, PerformanceState>((ref) {
  return PerformanceNotifier();
});

class PerformanceNotifier extends StateNotifier<PerformanceState> {
  PerformanceNotifier() : super(PerformanceState());

  void updateFrameRate(double frameRate) {
    state = state.copyWith(frameRate: frameRate);
  }

  void updateMemoryUsage(double memoryUsage) {
    state = state.copyWith(memoryUsage: memoryUsage);
  }

  void updateCpuUsage(double cpuUsage) {
    state = state.copyWith(cpuUsage: cpuUsage);
  }

  void incrementFrameCount() {
    state = state.copyWith(frameCount: state.frameCount + 1);
  }

  void addPerformanceMetric(String name, double value) {
    final newMetrics = Map<String, double>.from(state.performanceMetrics);
    newMetrics[name] = value;
    state = state.copyWith(performanceMetrics: newMetrics);
  }
}

class PerformanceState {
  final double frameRate;
  final double memoryUsage;
  final double cpuUsage;
  final int frameCount;
  final Map<String, double> performanceMetrics;

  PerformanceState({
    this.frameRate = 0.0,
    this.memoryUsage = 0.0,
    this.cpuUsage = 0.0,
    this.frameCount = 0,
    this.performanceMetrics = const {},
  });

  PerformanceState copyWith({
    double? frameRate,
    double? memoryUsage,
    double? cpuUsage,
    int? frameCount,
    Map<String, double>? performanceMetrics,
  }) {
    return PerformanceState(
      frameRate: frameRate ?? this.frameRate,
      memoryUsage: memoryUsage ?? this.memoryUsage,
      cpuUsage: cpuUsage ?? this.cpuUsage,
      frameCount: frameCount ?? this.frameCount,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
    );
  }
}