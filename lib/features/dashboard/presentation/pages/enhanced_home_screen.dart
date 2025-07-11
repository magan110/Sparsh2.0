import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:learning2/features/dashboard/presentation/pages/notification_screen.dart';
import 'package:learning2/features/dashboard/presentation/pages/profile_screen.dart';
import 'package:learning2/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:learning2/features/dashboard/presentation/pages/schema.dart';
import 'package:learning2/features/dashboard/presentation/pages/token_scan.dart';
import 'package:learning2/features/dsr_entry/presentation/pages/dsr_entry.dart';
import 'package:learning2/features/dashboard/presentation/pages/accounts_statement_page.dart';
import 'package:learning2/features/dashboard/presentation/pages/activity_summary_page.dart';
import 'package:learning2/features/dashboard/presentation/pages/employee_dashboard_page.dart';
import 'package:learning2/features/dashboard/presentation/widgets/app_drawer.dart';
import 'package:learning2/routes/navigation_registry.dart';
import 'package:learning2/features/dashboard/presentation/pages/grc_lead_entry_page.dart';
import 'package:learning2/features/dashboard/presentation/pages/painter_kyc_tracking_page.dart';
import 'package:learning2/features/dashboard/presentation/pages/retailer_registration_page.dart';
import 'package:learning2/features/dashboard/presentation/pages/scheme_document_page.dart';
import 'package:learning2/features/dashboard/presentation/pages/universal_outlet_registration_page.dart';
import 'package:learning2/features/dashboard/presentation/pages/mail_screen.dart';
import 'package:learning2/core/constants/fonts.dart';
import 'package:learning2/core/theme/app_theme.dart';
import 'package:learning2/core/utils/responsive_util.dart';
import 'package:learning2/presentation/widgets/advanced_3d_components.dart';
import 'package:learning2/presentation/animations/advanced_animations.dart';
import 'package:learning2/presentation/providers/theme_provider.dart';
import 'package:learning2/presentation/providers/app_state_provider.dart';

class EnhancedHomeScreen extends ConsumerStatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  ConsumerState<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends ConsumerState<EnhancedHomeScreen> 
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _selectedIndex = 0;
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  
  late AnimationController _appBarController;
  late AnimationController _fabController;
  late AnimationController _bottomNavController;

  // List of searchable items (screens and reports) now comes from appRoutes
  List<_SearchItem> get _searchItems => appRoutes
      .map((route) => _SearchItem(route.title, route.type, route.builder))
      .toList();
  List<_SearchItem> _filteredSearchItems = [];

  // These are the four "root" screens for bottom navigation:
  final List<Widget> _screens = [
    const Enhanced3DHomeContent(),
    const Enhanced3DDashboardScreen(),
    const Enhanced3DMailScreen(),
    const Enhanced3DProfileScreen(),
  ];

  // The currently displayed screen:
  Widget _currentScreen = const Enhanced3DHomeContent();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _appBarController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _bottomNavController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Start entrance animations
    _startEntranceAnimations();
  }

  void _startEntranceAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _appBarController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    _bottomNavController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _fabController.forward();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _appBarController.dispose();
    _fabController.dispose();
    _bottomNavController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final mediaQuery = MediaQuery.of(context);
    
    // Update layout provider with new metrics
    ref.read(appLayoutProvider.notifier).updateScreenSize(mediaQuery.size);
    ref.read(appLayoutProvider.notifier).updateOrientation(mediaQuery.orientation);
    ref.read(appLayoutProvider.notifier).updateSafeAreaPadding(mediaQuery.padding);
    ref.read(appLayoutProvider.notifier).updateKeyboardHeight(mediaQuery.viewInsets.bottom);
  }

  /// Updates both the selected index and the displayed screen.
  void _updateCurrentScreen(int index, {Widget? screen}) {
    if (mounted) {
      setState(() {
        _selectedIndex = index;
        _currentScreen = screen ?? _screens[index];
      });
      
      // Track navigation
      ref.read(navigationProvider.notifier).setCurrentIndex(index);
      ref.read(analyticsProvider.notifier).trackScreenView('home_screen_$index');
      
      // Haptic feedback
      if (ref.read(animationPreferencesProvider).hapticFeedback) {
        HapticFeedback.selectionClick();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);
    final themeMode = ref.watch(themeProvider);
    final animationPrefs = ref.watch(animationPreferencesProvider);
    
    return ResponsiveBuilder(
      builder: (context, screenType) {
        return WillPopScope(
          onWillPop: () async {
            if (_selectedIndex != 0) {
              _updateCurrentScreen(0);
              return false;
            }
            return true;
          },
          child: Scaffold(
            backgroundColor: SparshTheme.scaffoldBackground,
            extendBodyBehindAppBar: true,
            appBar: _buildEnhanced3DAppBar(context, screenType),
            drawer: ResponsiveUtil.isMobile(context) ? const Enhanced3DAppDrawer() : null,
            body: Stack(
              children: [
                // Background with subtle gradient
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFF8FAFC),
                        Color(0xFFEFF6FF),
                      ],
                    ),
                  ),
                ),
                // Main content
                SafeArea(
                  child: _currentScreen,
                ),
                // Search overlay
                _buildEnhancedSearchOverlay(context),
              ],
            ),
            bottomNavigationBar: _buildAdvanced3DBottomNavBar(screenType),
            floatingActionButton: _buildAdvanced3DFloatingActionButton(),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          ),
        );
      },
    );
  }

  /// Builds the enhanced 3D AppBar with perspective and depth
  PreferredSizeWidget _buildEnhanced3DAppBar(BuildContext context, ScreenType screenType) {
    return Advanced3DAppBar(
      height: ResponsiveUtil.scaledHeight(context, 80),
      elevation: 12,
      enableGlassMorphism: true,
      enable3DTransform: true,
      perspective: 0.002,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          SparshTheme.primaryBlue,
          SparshTheme.primaryBlue.withOpacity(0.8),
          SparshTheme.primaryBlueAccent,
        ],
      ),
      title: AnimatedBuilder(
        animation: _appBarController,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * _appBarController.value),
            child: Opacity(
              opacity: _appBarController.value,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.white,
                    size: ResponsiveUtil.getIconSize(context, 28),
                  ),
                  SizedBox(width: ResponsiveUtil.getAdaptiveSpacing(context, 8)),
                  Text(
                    'SPARSH 2.0',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveUtil.scaledFontSize(context, 26),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      actions: [
        // Notification button with 3D effect
        Advanced3DCard(
          width: 48,
          height: 48,
          elevation: 6,
          enableGlassMorphism: true,
          backgroundColor: Colors.white.withOpacity(0.1),
          borderRadius: 24,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
          },
          child: Icon(
            Icons.notifications_none,
            size: ResponsiveUtil.getIconSize(context, 24),
            color: Colors.white,
          ),
        ),
        SizedBox(width: ResponsiveUtil.getAdaptiveSpacing(context, 8)),
        // Search button with advanced animations
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(
              scale: animation,
              child: RotationTransition(
                turns: animation,
                child: child,
              ),
            );
          },
          child: _isSearchVisible
              ? const SizedBox(width: 48, height: 48, key: ValueKey('empty'))
              : Advanced3DCard(
                  key: const ValueKey('search'),
                  width: 48,
                  height: 48,
                  elevation: 6,
                  enableGlassMorphism: true,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  borderRadius: 24,
                  onTap: () {
                    setState(() {
                      _isSearchVisible = true;
                    });
                    ref.read(analyticsProvider.notifier).trackUserAction('search_opened');
                  },
                  child: Icon(
                    Icons.search,
                    size: ResponsiveUtil.getIconSize(context, 24),
                    color: Colors.white,
                  ),
                ),
        ),
        SizedBox(width: ResponsiveUtil.getAdaptiveSpacing(context, 16)),
      ],
    );
  }

  /// Enhanced search overlay with 3D effects
  Widget _buildEnhancedSearchOverlay(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isSearchVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      child: Visibility(
        visible: _isSearchVisible,
        child: GlassMorphismContainer(
          width: double.infinity,
          height: double.infinity,
          blurStrength: 20,
          opacity: 0.95,
          color: Colors.white,
          child: SafeArea(
            child: Column(
              children: [
                // Search input with 3D styling
                Advanced3DCard(
                  margin: EdgeInsets.all(ResponsiveUtil.getAdaptiveSpacing(context, 16)),
                  elevation: 8,
                  enableGlassMorphism: true,
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: TextStyle(
                      fontSize: ResponsiveUtil.scaledFontSize(context, 16),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search for reports, screens, etc...',
                      hintStyle: TextStyle(
                        fontSize: ResponsiveUtil.scaledFontSize(context, 16),
                        color: Colors.grey[600],
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: ResponsiveUtil.getIconSize(context, 24),
                        color: SparshTheme.primaryBlue,
                      ),
                      suffixIcon: Advanced3DCard(
                        width: 40,
                        height: 40,
                        elevation: 4,
                        borderRadius: 20,
                        backgroundColor: Colors.red.withOpacity(0.1),
                        onTap: () {
                          setState(() {
                            _isSearchVisible = false;
                            _searchController.clear();
                            _filteredSearchItems = [];
                          });
                        },
                        child: Icon(
                          Icons.close,
                          size: ResponsiveUtil.getIconSize(context, 20),
                          color: Colors.red,
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtil.getAdaptiveSpacing(context, 16),
                        vertical: ResponsiveUtil.getAdaptiveSpacing(context, 16),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _filteredSearchItems = value.isEmpty
                            ? []
                            : _searchItems.where((item) =>
                                item.title.toLowerCase().contains(value.toLowerCase()) ||
                                item.type.toLowerCase().contains(value.toLowerCase())
                              ).toList();
                      });
                    },
                  ),
                ),
                // Search results with staggered animations
                if (_filteredSearchItems.isNotEmpty)
                  Expanded(
                    child: AdvancedStaggeredAnimation(
                      duration: const Duration(milliseconds: 300),
                      delay: const Duration(milliseconds: 50),
                      children: _filteredSearchItems.map((item) {
                        return Advanced3DListTile(
                          elevation: 4,
                          borderRadius: 12,
                          backgroundColor: Colors.white,
                          enableHover: true,
                          enable3DTransform: true,
                          title: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: ResponsiveUtil.scaledFontSize(context, 16),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            item.type,
                            style: TextStyle(
                              fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: ResponsiveUtil.getIconSize(context, 16),
                            color: SparshTheme.primaryBlue,
                          ),
                          onTap: () {
                            setState(() {
                              _isSearchVisible = false;
                              _searchController.clear();
                              _filteredSearchItems = [];
                            });
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (ctx) => item.builder(ctx)),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Advanced 3D Bottom Navigation Bar
  Widget _buildAdvanced3DBottomNavBar(ScreenType screenType) {
    final List<_NavItem> navItems = [
      _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
        colors: [Colors.blue.shade400, Colors.blue.shade700],
      ),
      _NavItem(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
        label: 'Dashboard',
        colors: [Colors.purple.shade300, Colors.purpleAccent],
      ),
      _NavItem(
        icon: Icons.schema_outlined,
        activeIcon: Icons.schema,
        label: 'Scheme',
        colors: [Colors.orange.shade300, Colors.deepOrange],
      ),
      _NavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile',
        colors: [Colors.teal.shade300, Colors.green.shade600],
      ),
    ];

    return AnimatedBuilder(
      animation: _bottomNavController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 100 * (1 - _bottomNavController.value)),
          child: Advanced3DCard(
            elevation: 20,
            enableGlassMorphism: true,
            backgroundColor: Colors.white.withOpacity(0.9),
            borderRadius: 0,
            enable3DTransform: true,
            perspective: 0.001,
            child: Container(
              height: ResponsiveUtil.scaledHeight(context, 80),
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtil.getAdaptiveSpacing(context, 16),
                vertical: ResponsiveUtil.getAdaptiveSpacing(context, 8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(navItems.length, (index) {
                  if (index == 2) {
                    return SizedBox(width: ResponsiveUtil.scaledWidth(context, 60));
                  }
                  
                  final item = navItems[index];
                  final isActive = _selectedIndex == index;
                  final adjustedIndex = index > 2 ? index - 1 : index;
                  
                  return Expanded(
                    child: AdvancedAnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      enableHover: true,
                      enableScale: true,
                      enableColorTransition: true,
                      onTap: () {
                        if (adjustedIndex == 2) {
                          _updateCurrentScreen(adjustedIndex, screen: const Schema());
                        } else if (adjustedIndex == 3) {
                          _updateCurrentScreen(adjustedIndex, screen: const ProfilePage());
                        } else {
                          _updateCurrentScreen(adjustedIndex);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtil.getAdaptiveSpacing(context, 8),
                          vertical: ResponsiveUtil.getAdaptiveSpacing(context, 8),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: isActive
                              ? LinearGradient(
                                  colors: item.colors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isActive ? item.activeIcon : item.icon,
                              color: isActive ? Colors.white : Colors.grey.shade600,
                              size: ResponsiveUtil.getIconSize(context, 24),
                            ),
                            SizedBox(height: ResponsiveUtil.getAdaptiveSpacing(context, 4)),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                color: isActive ? Colors.white : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Advanced 3D Floating Action Button
  Widget _buildAdvanced3DFloatingActionButton() {
    return AnimatedBuilder(
      animation: _fabController,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabController.value,
          child: Advanced3DFloatingActionButton(
            onPressed: () {
              _updateCurrentScreen(2, screen: const TokenScanPage());
            },
            size: ResponsiveUtil.scaledSize(context, 64),
            elevation: 12,
            enablePulse: true,
            enableGlow: true,
            gradient: LinearGradient(
              colors: [
                Colors.blueAccent.shade400,
                Colors.blueAccent.shade700,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Icon(
              Icons.qr_code_scanner,
              color: Colors.white,
              size: ResponsiveUtil.getIconSize(context, 32),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final List<Color> colors;

  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.colors,
  });
}

class _SearchItem {
  final String title;
  final String type;
  final Widget Function(BuildContext) builder;
  
  _SearchItem(this.title, this.type, this.builder);
}

// Enhanced 3D versions of existing screens
class Enhanced3DHomeContent extends StatelessWidget {
  const Enhanced3DHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeContent(); // Will be enhanced in next iteration
  }
}

class Enhanced3DDashboardScreen extends StatelessWidget {
  const Enhanced3DDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardScreen(); // Will be enhanced in next iteration
  }
}

class Enhanced3DMailScreen extends StatelessWidget {
  const Enhanced3DMailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MailScreen(); // Will be enhanced in next iteration
  }
}

class Enhanced3DProfileScreen extends StatelessWidget {
  const Enhanced3DProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfilePage(); // Will be enhanced in next iteration
  }
}

class Enhanced3DAppDrawer extends StatelessWidget {
  const Enhanced3DAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppDrawer(); // Will be enhanced in next iteration
  }
}