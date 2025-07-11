import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:learning2/core/theme/app_theme.dart';
import 'package:learning2/core/animations/animation_library.dart';
import 'package:learning2/core/animations/advanced_ui_components.dart';
import 'package:learning2/features/dashboard/presentation/pages/home_screen.dart';

/// Stunning onboarding flow with 3D animations
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _backgroundController;
  late AnimationController _progressController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _progressAnimation;
  
  int _currentPage = 0;
  final int _totalPages = 4;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: "Welcome to SPARSH",
      subtitle: "Your Digital Workplace Companion",
      description: "Experience seamless workflow management with beautiful, intuitive design that makes work feel effortless.",
      illustration: "assets/image1.png",
      gradient: SparshTheme.primaryGradient,
      particleColor: SparshTheme.primaryBlue,
    ),
    OnboardingPage(
      title: "Smart Dashboard",
      subtitle: "All Your Tools in One Place",
      description: "Access all your workplace tools, reports, and insights through a modern, animated dashboard designed for productivity.",
      illustration: "assets/image2.png",
      gradient: const LinearGradient(
        colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      particleColor: const Color(0xFF8B5CF6),
    ),
    OnboardingPage(
      title: "Real-time Analytics",
      subtitle: "Data That Drives Decisions",
      description: "Visualize your performance with beautiful charts and real-time analytics that help you make informed decisions.",
      illustration: "assets/image3.png",
      gradient: const LinearGradient(
        colors: [Color(0xFF10B981), Color(0xFF34D399)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      particleColor: const Color(0xFF10B981),
    ),
    OnboardingPage(
      title: "Get Started",
      subtitle: "Begin Your Journey",
      description: "Ready to transform your workplace experience? Let's dive into the future of digital productivity together.",
      illustration: "assets/image4.png",
      gradient: const LinearGradient(
        colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      particleColor: const Color(0xFFF59E0B),
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _pageController = PageController();
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    
    _backgroundController.repeat();
    _updateProgress();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _backgroundController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    _progressController.animateTo((_currentPage + 1) / _totalPages);
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _currentPage++;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
      _updateProgress();
    } else {
      _navigateToHome();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
      _updateProgress();
    }
  }

  void _navigateToHome() {
    OnboardingManager.completeOnboarding();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionDuration: const Duration(milliseconds: 800),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            )),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return AnimatedGradientBackground(
                colors: _pages[_currentPage].gradient.colors,
                enableParticles: true,
                child: Container(),
              );
            },
          ),
          
          // Glass morphism overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.transparent),
            ),
          ),
          
          // Main content
          Column(
            children: [
              // Skip button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Progress indicator
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 100,
                            height: 6,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: _progressAnimation.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      // Skip button
                      GestureDetector(
                        onTap: _navigateToHome,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white.withValues(alpha: 0.2),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                    _updateProgress();
                  },
                  itemCount: _totalPages,
                  itemBuilder: (context, index) {
                    return OnboardingPageWidget(
                      page: _pages[index],
                      isActive: index == _currentPage,
                    );
                  },
                ),
              ),
              
              // Navigation buttons
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Previous button
                      if (_currentPage > 0)
                        Floating3DButton(
                          size: 50,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          onPressed: _previousPage,
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      
                      const Spacer(),
                      
                      // Page indicators
                      Row(
                        children: List.generate(_totalPages, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: index == _currentPage ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: index == _currentPage
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.4),
                            ),
                          );
                        }),
                      ),
                      
                      const Spacer(),
                      
                      // Next button
                      Floating3DButton(
                        size: 50,
                        backgroundColor: Colors.white,
                        onPressed: _nextPage,
                        child: Icon(
                          _currentPage == _totalPages - 1 
                              ? Icons.check 
                              : Icons.arrow_forward,
                          color: _pages[_currentPage].gradient.colors.first,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Individual onboarding page widget
class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;
  final bool isActive;
  
  const OnboardingPageWidget({
    super.key,
    required this.page,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration with 3D effect
          Container(
            width: 300,
            height: 300,
            margin: const EdgeInsets.only(bottom: 40),
            child: FlipCard(
              front: _buildIllustration(),
              back: _buildAlternateIllustration(),
              isFlipped: false,
            ),
          )
              .animate()
              .fadeIn(duration: 800.ms, delay: 300.ms)
              .scale(begin: const Offset(0.8, 0.8), delay: 300.ms, duration: 800.ms)
              .shimmer(delay: 1000.ms, duration: 2000.ms),
          
          // Title
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 500.ms)
              .slideY(begin: 0.3, delay: 500.ms, duration: 600.ms),
          
          const SizedBox(height: 16),
          
          // Subtitle
          Text(
            page.subtitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 700.ms)
              .slideY(begin: 0.3, delay: 700.ms, duration: 600.ms),
          
          const SizedBox(height: 24),
          
          // Description
          Text(
            page.description,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 900.ms)
              .slideY(begin: 0.3, delay: 900.ms, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          page.illustration,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: page.gradient,
              ),
              child: Icon(
                Icons.star,
                size: 100,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAlternateIllustration() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: page.gradient,
        boxShadow: [
          BoxShadow(
            color: page.particleColor.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 5,
          ),
        ],
      ),
      child: Icon(
        Icons.touch_app,
        size: 100,
        color: Colors.white,
      ),
    );
  }
}

/// Onboarding page data model
class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final String illustration;
  final LinearGradient gradient;
  final Color particleColor;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.illustration,
    required this.gradient,
    required this.particleColor,
  });
}

/// Check if it's the first app launch
class OnboardingManager {
  static const String _keyFirstLaunch = 'first_launch';
  
  static bool _isFirstLaunch = true;
  
  static bool get isFirstLaunch => _isFirstLaunch;
  
  static void completeOnboarding() {
    _isFirstLaunch = false;
    // In a real app, you would save this to SharedPreferences
    // SharedPreferences.getInstance().then((prefs) {
    //   prefs.setBool(_keyFirstLaunch, false);
    // });
  }
  
  static void checkFirstLaunch() {
    // In a real app, you would load this from SharedPreferences
    // SharedPreferences.getInstance().then((prefs) {
    //   _isFirstLaunch = prefs.getBool(_keyFirstLaunch) ?? true;
    // });
  }
}