import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:learning2/core/theme/app_theme.dart';

/// Theme manager with animated transitions
class ThemeManager extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
  
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

/// Enhanced Dark Theme
class SparshDarkTheme {
  // Dark Mode Colors
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF334155);
  static const Color primaryDark = Color(0xFF3B82F6);
  static const Color secondaryDark = Color(0xFF8B5CF6);
  
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textTertiaryDark = Color(0xFF94A3B8);
  
  static const Color borderDark = Color(0xFF475569);
  static const Color borderLightDark = Color(0xFF334155);
  
  // Dark Gradients
  static const LinearGradient primaryGradientDark = LinearGradient(
    colors: [primaryDark, Color(0xFF1D4ED8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient appBarGradientDark = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF334155)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradientDark = LinearGradient(
    colors: [surfaceDark, cardDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      useMaterial3: true,
      primaryColor: primaryDark,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: ColorScheme.dark(
        primary: primaryDark,
        secondary: secondaryDark,
        surface: surfaceDark,
        background: backgroundDark,
        brightness: Brightness.dark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryDark,
        onBackground: textPrimaryDark,
        error: SparshTheme.errorRed,
        onError: Colors.white,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: Colors.white, size: 24),
      ),
      
      // Card Theme
      cardTheme: const CardThemeData(
        elevation: 4,
        shadowColor: Color(0x40000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        color: surfaceDark,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryDark, width: 2),
        ),
        filled: true,
        fillColor: surfaceDark,
        hintStyle: const TextStyle(
          color: textTertiaryDark,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          color: textSecondaryDark,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          color: primaryDark,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: primaryDark.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryDark,
        unselectedItemColor: textTertiaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Drawer Theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: surfaceDark,
        elevation: 16,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: borderDark,
        thickness: 1,
      ),
    );
  }
}

/// Animated Theme Switcher Widget
class AnimatedThemeSwitch extends StatefulWidget {
  final ThemeManager themeManager;
  final double size;
  final Duration animationDuration;
  
  const AnimatedThemeSwitch({
    super.key,
    required this.themeManager,
    this.size = 50,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedThemeSwitch> createState() => _AnimatedThemeSwitchState();
}

class _AnimatedThemeSwitchState extends State<AnimatedThemeSwitch>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.elasticOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
    
    _rotationController.forward().then((_) {
      _rotationController.reset();
    });
    
    widget.themeManager.toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.themeManager,
      builder: (context, child) {
        final isDark = widget.themeManager.isDarkMode;
        
        return GestureDetector(
          onTap: _toggleTheme,
          child: AnimatedBuilder(
            animation: Listenable.merge([_rotationAnimation, _scaleAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value * 6.28,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? SparshDarkTheme.primaryGradientDark
                          : SparshTheme.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? SparshDarkTheme.primaryDark : SparshTheme.primaryBlue)
                              .withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      isDark ? Icons.light_mode : Icons.dark_mode,
                      color: Colors.white,
                      size: widget.size * 0.6,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Theme-aware animated container
class ThemeAwareContainer extends StatelessWidget {
  final Widget child;
  final ThemeManager themeManager;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Duration animationDuration;
  
  const ThemeAwareContainer({
    super.key,
    required this.child,
    required this.themeManager,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeManager,
      builder: (context, child) {
        final isDark = themeManager.isDarkMode;
        
        return AnimatedContainer(
          duration: animationDuration,
          curve: Curves.easeInOut,
          padding: padding,
          margin: margin,
          decoration: BoxDecoration(
            gradient: isDark
                ? SparshDarkTheme.cardGradientDark
                : SparshTheme.cardGradient,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isDark ? SparshDarkTheme.borderDark : SparshTheme.borderGrey,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: this.child,
        );
      },
    );
  }
}

/// Animated theme transition overlay
class ThemeTransitionOverlay extends StatefulWidget {
  final Widget child;
  final ThemeManager themeManager;
  
  const ThemeTransitionOverlay({
    super.key,
    required this.child,
    required this.themeManager,
  });

  @override
  State<ThemeTransitionOverlay> createState() => _ThemeTransitionOverlayState();
}

class _ThemeTransitionOverlayState extends State<ThemeTransitionOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showOverlay = false;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    widget.themeManager.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    widget.themeManager.removeListener(_onThemeChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {
      _showOverlay = true;
    });
    
    _controller.forward().then((_) {
      _controller.reverse().then((_) {
        setState(() {
          _showOverlay = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showOverlay)
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: _animation.value * 2,
                      colors: [
                        widget.themeManager.isDarkMode
                            ? SparshDarkTheme.backgroundDark
                            : SparshTheme.scaffoldBackground,
                        widget.themeManager.isDarkMode
                            ? SparshDarkTheme.backgroundDark.withValues(alpha: 0)
                            : SparshTheme.scaffoldBackground.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

/// Theme-aware text widget with smooth color transitions
class AnimatedThemeText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final ThemeManager themeManager;
  final Duration animationDuration;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  
  const AnimatedThemeText(
    this.text, {
    super.key,
    this.style,
    required this.themeManager,
    this.animationDuration = const Duration(milliseconds: 300),
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeManager,
      builder: (context, child) {
        final isDark = themeManager.isDarkMode;
        final textColor = isDark 
            ? SparshDarkTheme.textPrimaryDark 
            : SparshTheme.textPrimary;
        
        return AnimatedDefaultTextStyle(
          duration: animationDuration,
          curve: Curves.easeInOut,
          style: (style ?? SparshTypography.body).copyWith(color: textColor),
          child: Text(
            text,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
          ),
        );
      },
    );
  }
}

/// App wrapper with theme management
class ThemeAwareApp extends StatelessWidget {
  final Widget child;
  final ThemeManager themeManager;
  
  const ThemeAwareApp({
    super.key,
    required this.child,
    required this.themeManager,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeManager,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SPARSH',
          theme: SparshTheme.lightTheme,
          darkTheme: SparshDarkTheme.darkTheme,
          themeMode: themeManager.themeMode,
          home: ThemeTransitionOverlay(
            themeManager: themeManager,
            child: this.child,
          ),
        );
      },
    );
  }
}