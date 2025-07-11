import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Enhanced responsive utilities for pixel-perfect UI across devices
class ResponsiveUtil {
  static double _screenWidth = 0;
  static double _screenHeight = 0;
  static const double _designWidth = 375; // Base design width
  static const double _designHeight = 812; // Base design height
  
  // Breakpoints for different screen sizes
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1920;

  static void init(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
  }

  /// Get screen type based on width
  static ScreenType getScreenType(BuildContext context) {
    if (_screenWidth == 0) init(context);
    
    if (_screenWidth < mobileBreakpoint) {
      return ScreenType.mobile;
    } else if (_screenWidth < tabletBreakpoint) {
      return ScreenType.tablet;
    } else if (_screenWidth < largeDesktopBreakpoint) {
      return ScreenType.desktop;
    } else {
      return ScreenType.largeDesktop;
    }
  }

  /// Advanced responsive scaling with minimum and maximum constraints
  static double scaledSize(BuildContext context, double size, {double? min, double? max}) {
    if (_screenWidth == 0) init(context);
    
    double scaled = (size * _screenWidth) / _designWidth;
    
    if (min != null && scaled < min) return min;
    if (max != null && scaled > max) return max;
    
    return scaled;
  }

  /// Smart font scaling that prevents text from becoming too small or large
  static double scaledFontSize(BuildContext context, double fontSize, {double? min, double? max}) {
    if (_screenWidth == 0) init(context);
    
    double scaled = (fontSize * _screenWidth) / _designWidth;
    
    // Apply smart constraints based on screen type
    ScreenType screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        min ??= fontSize * 0.8;
        max ??= fontSize * 1.2;
        break;
      case ScreenType.tablet:
        min ??= fontSize * 0.9;
        max ??= fontSize * 1.1;
        break;
      case ScreenType.desktop:
      case ScreenType.largeDesktop:
        min ??= fontSize * 0.95;
        max ??= fontSize * 1.05;
        break;
    }
    
    return math.max(min!, math.min(max!, scaled));
  }

  /// Get responsive icon size based on screen type
  static double getIconSize(BuildContext context, double size) {
    if (_screenWidth == 0) init(context);
    
    ScreenType screenType = getScreenType(context);
    double multiplier = switch (screenType) {
      ScreenType.mobile => 1.0,
      ScreenType.tablet => 1.1,
      ScreenType.desktop => 1.2,
      ScreenType.largeDesktop => 1.3,
    };
    
    return size * multiplier;
  }

  /// Get screen dimensions
  static double getScreenWidth(BuildContext context) {
    if (_screenWidth == 0) init(context);
    return _screenWidth;
  }

  static double getScreenHeight(BuildContext context) {
    if (_screenHeight == 0) init(context);
    return _screenHeight;
  }

  /// Device type checkers
  static bool isMobile(BuildContext context) {
    if (_screenWidth == 0) init(context);
    return _screenWidth < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    if (_screenWidth == 0) init(context);
    return _screenWidth >= mobileBreakpoint && _screenWidth < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    if (_screenWidth == 0) init(context);
    return _screenWidth >= tabletBreakpoint;
  }

  static bool isLargeDesktop(BuildContext context) {
    if (_screenWidth == 0) init(context);
    return _screenWidth >= largeDesktopBreakpoint;
  }

  /// Advanced responsive padding with screen-aware constraints
  static EdgeInsets scaledPadding(
    BuildContext context, {
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    if (_screenWidth == 0) init(context);

    ScreenType screenType = getScreenType(context);
    double multiplier = switch (screenType) {
      ScreenType.mobile => 1.0,
      ScreenType.tablet => 1.2,
      ScreenType.desktop => 1.4,
      ScreenType.largeDesktop => 1.6,
    };

    if (all != null) {
      double scaledAll = (all * _screenWidth) / _designWidth * multiplier;
      return EdgeInsets.all(scaledAll);
    }

    double scaledLeft = left != null ? (left * _screenWidth) / _designWidth * multiplier : 0;
    double scaledTop = top != null ? (top * _screenHeight) / _designHeight * multiplier : 0;
    double scaledRight = right != null ? (right * _screenWidth) / _designWidth * multiplier : 0;
    double scaledBottom = bottom != null ? (bottom * _screenHeight) / _designHeight * multiplier : 0;

    if (horizontal != null) {
      double scaledHorizontal = (horizontal * _screenWidth) / _designWidth * multiplier;
      return EdgeInsets.symmetric(horizontal: scaledHorizontal, vertical: scaledTop);
    }

    if (vertical != null) {
      double scaledVertical = (vertical * _screenHeight) / _designHeight * multiplier;
      return EdgeInsets.symmetric(vertical: scaledVertical, horizontal: scaledLeft);
    }

    return EdgeInsets.only(
      left: scaledLeft,
      top: scaledTop,
      right: scaledRight,
      bottom: scaledBottom,
    );
  }

  /// Advanced responsive height with constraints
  static double scaledHeight(BuildContext context, double height, {double? min, double? max}) {
    if (_screenHeight == 0) init(context);
    
    double scaled = (height * _screenHeight) / _designHeight;
    
    if (min != null && scaled < min) return min;
    if (max != null && scaled > max) return max;
    
    return scaled;
  }

  /// Advanced responsive width with constraints
  static double scaledWidth(BuildContext context, double width, {double? min, double? max}) {
    if (_screenWidth == 0) init(context);
    
    double scaled = (width * _screenWidth) / _designWidth;
    
    if (min != null && scaled < min) return min;
    if (max != null && scaled > max) return max;
    
    return scaled;
  }

  /// Get adaptive columns based on screen width
  static int getAdaptiveColumns(BuildContext context, {int? mobile, int? tablet, int? desktop}) {
    ScreenType screenType = getScreenType(context);
    return switch (screenType) {
      ScreenType.mobile => mobile ?? 1,
      ScreenType.tablet => tablet ?? 2,
      ScreenType.desktop => desktop ?? 3,
      ScreenType.largeDesktop => desktop ?? 4,
    };
  }

  /// Get adaptive aspect ratio based on screen type
  static double getAdaptiveAspectRatio(BuildContext context, {double? mobile, double? tablet, double? desktop}) {
    ScreenType screenType = getScreenType(context);
    return switch (screenType) {
      ScreenType.mobile => mobile ?? 1.0,
      ScreenType.tablet => tablet ?? 1.2,
      ScreenType.desktop => desktop ?? 1.5,
      ScreenType.largeDesktop => desktop ?? 1.8,
    };
  }

  /// Get adaptive spacing based on screen type
  static double getAdaptiveSpacing(BuildContext context, double baseSpacing) {
    ScreenType screenType = getScreenType(context);
    double multiplier = switch (screenType) {
      ScreenType.mobile => 1.0,
      ScreenType.tablet => 1.2,
      ScreenType.desktop => 1.4,
      ScreenType.largeDesktop => 1.6,
    };
    
    return baseSpacing * multiplier;
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get available screen space excluding safe areas
  static Size getAvailableScreenSize(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    EdgeInsets padding = mediaQuery.padding;
    
    return Size(
      mediaQuery.size.width - padding.left - padding.right,
      mediaQuery.size.height - padding.top - padding.bottom,
    );
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Get device pixel ratio
  static double getDevicePixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  /// Get text scale factor
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor;
  }

  /// Get brightness (light/dark mode)
  static Brightness getBrightness(BuildContext context) {
    return MediaQuery.of(context).platformBrightness;
  }

  /// Check if device is in dark mode
  static bool isDarkMode(BuildContext context) {
    return getBrightness(context) == Brightness.dark;
  }

  /// Get adaptive border radius
  static BorderRadius getAdaptiveBorderRadius(BuildContext context, double baseRadius) {
    ScreenType screenType = getScreenType(context);
    double multiplier = switch (screenType) {
      ScreenType.mobile => 1.0,
      ScreenType.tablet => 1.1,
      ScreenType.desktop => 1.2,
      ScreenType.largeDesktop => 1.3,
    };
    
    return BorderRadius.circular(baseRadius * multiplier);
  }

  /// Get adaptive elevation
  static double getAdaptiveElevation(BuildContext context, double baseElevation) {
    ScreenType screenType = getScreenType(context);
    double multiplier = switch (screenType) {
      ScreenType.mobile => 1.0,
      ScreenType.tablet => 1.1,
      ScreenType.desktop => 1.2,
      ScreenType.largeDesktop => 1.3,
    };
    
    return baseElevation * multiplier;
  }

  /// Get adaptive margin
  static EdgeInsets getAdaptiveMargin(BuildContext context, double baseMargin) {
    ScreenType screenType = getScreenType(context);
    double multiplier = switch (screenType) {
      ScreenType.mobile => 1.0,
      ScreenType.tablet => 1.2,
      ScreenType.desktop => 1.4,
      ScreenType.largeDesktop => 1.6,
    };
    
    return EdgeInsets.all(baseMargin * multiplier);
  }

  /// Get responsive widget based on screen type
  static Widget responsive(
    BuildContext context, {
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
    Widget? largeDesktop,
  }) {
    ScreenType screenType = getScreenType(context);
    return switch (screenType) {
      ScreenType.mobile => mobile,
      ScreenType.tablet => tablet ?? mobile,
      ScreenType.desktop => desktop ?? tablet ?? mobile,
      ScreenType.largeDesktop => largeDesktop ?? desktop ?? tablet ?? mobile,
    };
  }

  /// Get responsive value based on screen type
  static T responsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    ScreenType screenType = getScreenType(context);
    return switch (screenType) {
      ScreenType.mobile => mobile,
      ScreenType.tablet => tablet ?? mobile,
      ScreenType.desktop => desktop ?? tablet ?? mobile,
      ScreenType.largeDesktop => largeDesktop ?? desktop ?? tablet ?? mobile,
    };
  }
}

/// Screen type enumeration
enum ScreenType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Responsive widget builder
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenType screenType) builder;
  
  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        ScreenType screenType = ResponsiveUtil.getScreenType(context);
        return builder(context, screenType);
      },
    );
  }
}

/// Responsive grid widget
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double spacing;
  final double runSpacing;
  final double? childAspectRatio;
  
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenType) {
        int columns = ResponsiveUtil.getAdaptiveColumns(
          context,
          mobile: mobileColumns,
          tablet: tabletColumns,
          desktop: desktopColumns,
        );
        
        double aspectRatio = childAspectRatio ?? 
          ResponsiveUtil.getAdaptiveAspectRatio(context);
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: aspectRatio,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}
