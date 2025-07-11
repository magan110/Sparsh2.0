import 'dart:async';
import 'package:flutter/material.dart';
import 'package:learning2/core/theme/app_theme.dart';
import 'package:learning2/features/authentication/presentation/pages/login_screen.dart';
import 'home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _showLogin = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _animationController.forward();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    const splashDuration = Duration(seconds: 3);

    print('SplashScreen: isLoggedIn = $isLoggedIn');

    if (isLoggedIn) {
      Future.delayed(splashDuration, () {
        if (mounted) {
          print('SplashScreen: Navigating to HomeScreen');
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const HomeScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        }
      });
    } else {
      // Instead of navigating away, show the login screen with animation
      Future.delayed(splashDuration, () {
        if (mounted) {
          setState(() {
            _showLogin = true;
          });
        }
      });
    }
  }

  void _handleSwipeUp() {
    print('SplashScreen: _handleSwipeUp called');
    setState(() {
      _showLogin = true;
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Container buildImageContainer(double width, double height, Image image) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(10), child: image),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      body: Stack(
        children: [
          // Background Images
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  buildImageContainer(
                    width,
                    height * 0.2,
                    Image.asset('assets/image11.png', fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildImageContainer(
                        width * 0.4,
                        height * 0.2,
                        Image.asset('assets/image12.png', fit: BoxFit.cover),
                      ),
                      buildImageContainer(
                        width * 0.5,
                        height * 0.2,
                        Image.asset('assets/image13.png', fit: BoxFit.cover),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildImageContainer(
                        width * 0.5,
                        height * 0.2,
                        Image.asset('assets/image14.png', fit: BoxFit.contain),
                      ),
                      buildImageContainer(
                        width * 0.5,
                        height * 0.2,
                        Image.asset('assets/image15.png', fit: BoxFit.contain),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildImageContainer(
                        width * 0.4,
                        height * 0.2,
                        Image.asset('assets/image16.png', fit: BoxFit.contain),
                      ),
                      buildImageContainer(
                        width * 0.5,
                        height * 0.2,
                        Image.asset('assets/image17.png', fit: BoxFit.contain),
                      ),
                    ],
                  ),
                  buildImageContainer(
                    width * 0.9,
                    height * 0.2,
                    Image.asset('assets/image18.png', fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    SparshTheme.primaryBlue.withOpacity(0.85),
                    SparshTheme.primaryBlueLight.withOpacity(0.85),
                    Colors.cyan.shade400.withOpacity(0.85),
                  ],
                ),
              ),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo animation
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.rotate(
                        angle: _rotateAnimation.value * 3.14159,
                        child: Container(
                          width: 250,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Image.asset(
                            'assets/logo.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),

                // Title animations
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Column(
                        children: [
                          const Text(
                            'Welcome to',
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.white70,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ShaderMask(
                            shaderCallback:
                                (bounds) => LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.white.withOpacity(0.8),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ).createShader(bounds),
                            child: const Text(
                              'SPARSH',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Footer
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    children: [
                      const Text(
                        'Developed By',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Birla White IT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.favorite,
                            color: Colors.red.shade400,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Login screen slide up animation
          if (_showLogin)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height:
                  MediaQuery.of(context).size.height *
                  0.9, // Take up 90% of screen height
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: LoginScreen(),
                  ),
                ),
              ),
            ),

          // Swipe up indicator when login is not showing
          if (!_showLogin)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: GestureDetector(
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity! < 0) {
                    setState(() {
                      _showLogin = true;
                    });
                  }
                },
                child: const Column(
                  children: [
                    Icon(
                      Icons.keyboard_arrow_up,
                      color: Colors.white,
                      size: 36,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Swipe up to login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
