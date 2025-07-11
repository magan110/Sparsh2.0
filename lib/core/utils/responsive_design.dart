import 'package:flutter/material.dart';
import '../responsive_util.dart';

/// Responsive grid layout for form fields and components
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? crossAxisCount;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final double? childAspectRatio;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ResponsiveGrid({
    Key? key,
    required this.children,
    this.crossAxisCount,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.childAspectRatio,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int responsiveCrossAxisCount = crossAxisCount ?? _getResponsiveCrossAxisCount(context);
    
    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding ?? ResponsiveUtil.scaledPadding(context, all: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: responsiveCrossAxisCount,
        crossAxisSpacing: crossAxisSpacing ?? ResponsiveUtil.scaledSize(context, 16),
        mainAxisSpacing: mainAxisSpacing ?? ResponsiveUtil.scaledSize(context, 16),
        childAspectRatio: childAspectRatio ?? 1.0,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }

  int _getResponsiveCrossAxisCount(BuildContext context) {
    if (ResponsiveUtil.isDesktop(context)) {
      return 3;
    } else if (ResponsiveUtil.isTablet(context)) {
      return 2;
    } else {
      return 1;
    }
  }
}

/// Responsive builder widget for different screen sizes
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? watch;

  const ResponsiveBuilder({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.watch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = ResponsiveUtil.getScreenWidth(context);
    
    if (screenWidth < 300 && watch != null) {
      return watch!;
    } else if (screenWidth < 600) {
      return mobile;
    } else if (screenWidth < 1200) {
      return tablet ?? mobile;
    } else {
      return desktop ?? tablet ?? mobile;
    }
  }
}

/// Responsive form wrapper that adapts to screen size
class ResponsiveFormWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? maxWidth;
  final bool centerContent;

  const ResponsiveFormWrapper({
    Key? key,
    required this.child,
    this.padding,
    this.maxWidth,
    this.centerContent = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double responsiveMaxWidth = maxWidth ?? _getResponsiveMaxWidth(context);
    
    return Container(
      width: double.infinity,
      padding: padding ?? ResponsiveUtil.scaledPadding(context, all: 16),
      child: centerContent
          ? Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: responsiveMaxWidth),
                child: child,
              ),
            )
          : Container(
              constraints: BoxConstraints(maxWidth: responsiveMaxWidth),
              child: child,
            ),
    );
  }

  double _getResponsiveMaxWidth(BuildContext context) {
    if (ResponsiveUtil.isDesktop(context)) {
      return 800;
    } else if (ResponsiveUtil.isTablet(context)) {
      return 600;
    } else {
      return double.infinity;
    }
  }
}

/// Responsive spacing utility
class ResponsiveSpacing {
  static double small(BuildContext context) => ResponsiveUtil.scaledSize(context, 8);
  static double medium(BuildContext context) => ResponsiveUtil.scaledSize(context, 16);
  static double large(BuildContext context) => ResponsiveUtil.scaledSize(context, 24);
  static double xLarge(BuildContext context) => ResponsiveUtil.scaledSize(context, 32);
  static double xxLarge(BuildContext context) => ResponsiveUtil.scaledSize(context, 48);
  
  static EdgeInsets paddingSmall(BuildContext context) => ResponsiveUtil.scaledPadding(context, all: 8);
  static EdgeInsets paddingMedium(BuildContext context) => ResponsiveUtil.scaledPadding(context, all: 16);
  static EdgeInsets paddingLarge(BuildContext context) => ResponsiveUtil.scaledPadding(context, all: 24);
  static EdgeInsets paddingXLarge(BuildContext context) => ResponsiveUtil.scaledPadding(context, all: 32);
  
  static EdgeInsets paddingHorizontalSmall(BuildContext context) => ResponsiveUtil.scaledPadding(context, horizontal: 8);
  static EdgeInsets paddingHorizontalMedium(BuildContext context) => ResponsiveUtil.scaledPadding(context, horizontal: 16);
  static EdgeInsets paddingHorizontalLarge(BuildContext context) => ResponsiveUtil.scaledPadding(context, horizontal: 24);
  
  static EdgeInsets paddingVerticalSmall(BuildContext context) => ResponsiveUtil.scaledPadding(context, vertical: 8);
  static EdgeInsets paddingVerticalMedium(BuildContext context) => ResponsiveUtil.scaledPadding(context, vertical: 16);
  static EdgeInsets paddingVerticalLarge(BuildContext context) => ResponsiveUtil.scaledPadding(context, vertical: 24);
}

/// Responsive typography utility
class ResponsiveTypography {
  static TextStyle displayLarge(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtil.scaledFontSize(context, 57),
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
  );
  
  static TextStyle displayMedium(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtil.scaledFontSize(context, 45),
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );
  
  static TextStyle displaySmall(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtil.scaledFontSize(context, 36),
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );
  
  static TextStyle headlineLarge(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtil.scaledFontSize(context, 32),
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );
  
  static TextStyle headlineMedium(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtil.scaledFontSize(context, 28),
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );
  
  static TextStyle headlineSmall(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtil.scaledFontSize(context, 24),
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );
  
  static TextStyle titleLarge(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtil.scaledFontSize(context, 22),
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );
  
  static TextStyle titleMedium(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtil.scaledFontSize(context, 16),
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );
  
  static TextStyle titleSmall(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtil.scaledFontSize(context, 14),
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );
  
  static TextStyle bodyLarge(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtil.scaledFontSize(context, 16),
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );
  
  static TextStyle bodyMedium(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtil.scaledFontSize(context, 14),
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );
  
  static TextStyle bodySmall(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtil.scaledFontSize(context, 12),
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );
  
  static TextStyle labelLarge(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtil.scaledFontSize(context, 14),
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );
  
  static TextStyle labelMedium(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtil.scaledFontSize(context, 12),
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
  
  static TextStyle labelSmall(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtil.scaledFontSize(context, 11),
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
}