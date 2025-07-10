import 'package:flutter/material.dart';

class ResponsiveUtil {
  static double _screenWidth = 0;
  static double _screenHeight = 0;
  static const double _designWidth = 375; // Base design width
  static const double _designHeight = 812; // Base design height

  static void init(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
  }

  static double scaledSize(BuildContext context, double size) {
    if (_screenWidth == 0) {
      init(context);
    }
    return (size * _screenWidth) / _designWidth;
  }

  static double scaledFontSize(BuildContext context, double fontSize) {
    if (_screenWidth == 0) {
      init(context);
    }
    return (fontSize * _screenWidth) / _designWidth;
  }

  static double getIconSize(BuildContext context, double size) {
    if (_screenWidth == 0) {
      init(context);
    }
    return (size * _screenWidth) / _designWidth;
  }

  static double getScreenWidth(BuildContext context) {
    if (_screenWidth == 0) {
      init(context);
    }
    return _screenWidth;
  }

  static double getScreenHeight(BuildContext context) {
    if (_screenHeight == 0) {
      init(context);
    }
    return _screenHeight;
  }

  static bool isMobile(BuildContext context) {
    if (_screenWidth == 0) {
      init(context);
    }
    return _screenWidth < 600;
  }

  static bool isTablet(BuildContext context) {
    if (_screenWidth == 0) {
      init(context);
    }
    return _screenWidth >= 600 && _screenWidth < 1200;
  }

  static bool isDesktop(BuildContext context) {
    if (_screenWidth == 0) {
      init(context);
    }
    return _screenWidth >= 1200;
  }

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
    if (_screenWidth == 0) {
      init(context);
    }

    if (all != null) {
      double scaledAll = (all * _screenWidth) / _designWidth;
      return EdgeInsets.all(scaledAll);
    }

    double scaledLeft = left != null ? (left * _screenWidth) / _designWidth : 0;
    double scaledTop = top != null ? (top * _screenHeight) / _designHeight : 0;
    double scaledRight = right != null ? (right * _screenWidth) / _designWidth : 0;
    double scaledBottom = bottom != null ? (bottom * _screenHeight) / _designHeight : 0;

    if (horizontal != null) {
      double scaledHorizontal = (horizontal * _screenWidth) / _designWidth;
      return EdgeInsets.symmetric(horizontal: scaledHorizontal);
    }

    if (vertical != null) {
      double scaledVertical = (vertical * _screenHeight) / _designHeight;
      return EdgeInsets.symmetric(vertical: scaledVertical);
    }

    return EdgeInsets.only(
      left: scaledLeft,
      top: scaledTop,
      right: scaledRight,
      bottom: scaledBottom,
    );
  }

  static double scaledHeight(BuildContext context, double height) {
    if (_screenHeight == 0) {
      init(context);
    }
    return (height * _screenHeight) / _designHeight;
  }

  static double scaledWidth(BuildContext context, double width) {
    if (_screenWidth == 0) {
      init(context);
    }
    return (width * _screenWidth) / _designWidth;
  }
}
