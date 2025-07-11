// File: lib/screens/home_screen.dart

import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:learning2/features/dashboard/presentation/pages/notification_screen.dart';
import 'package:learning2/features/dashboard/presentation/pages/profile_screen.dart';
import 'package:learning2/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:learning2/features/dashboard/presentation/pages/schema.dart';
import 'package:learning2/features/dashboard/presentation/pages/token_scan.dart';
import 'package:learning2/features/dsr_entry/presentation/pages/dsr_entry.dart';
import 'accounts_statement_page.dart';
import 'activity_summary_page.dart';
import 'package:learning2/features/dashboard/presentation/pages/employee_dashboard_page.dart';
import 'package:learning2/features/dashboard/presentation/widgets/app_drawer.dart';
import 'package:learning2/routes/navigation_registry.dart';
import 'grc_lead_entry_page.dart';
import 'painter_kyc_tracking_page.dart';
import 'retailer_registration_page.dart';
import 'scheme_document_page.dart';
import 'universal_outlet_registration_page.dart';
import 'mail_screen.dart';
import 'package:learning2/core/constants/fonts.dart';
import 'package:learning2/core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();

  // List of searchable items (screens and reports) now comes from appRoutes
  List<_SearchItem> get _searchItems => appRoutes
      .map((route) => _SearchItem(route.title, route.type, route.builder))
      .toList();
  List<_SearchItem> _filteredSearchItems = [];

  // These are the four "root" screens for bottom navigation:
  final List<Widget> _screens = [
    const HomeContent(),
    const DashboardScreen(),
    const MailScreen(),
    const ProfilePage(),
  ];

  // The currently displayed screen:
  Widget _currentScreen = const HomeContent();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Updates both the selected index and the displayed screen.
  void _updateCurrentScreen(int index, {Widget? screen}) {
    if (mounted) {
      setState(() {
        _selectedIndex = index;
        _currentScreen = screen ?? _screens[index];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Intercept Android "back" button:
      onWillPop: () async {
        if (_selectedIndex != 0) {
          // If we're not on Home, send back to Home.
          _updateCurrentScreen(0);
          return false;
        }
        return true; // Let the system handle "back" when already on Home.
      },
      child: Scaffold(
        backgroundColor: SparshTheme.scaffoldBackground,
        appBar: _buildAppBar(),
        drawer: const AppDrawer(),
        body: Stack(
          children: [
            // The currently active screen (HomeContent / Dashboard / Mail / Profile):
            _currentScreen,
            // The search-overlay (if _isSearchVisible):
            _buildSearchInput(context),
          ],
        ),
        bottomNavigationBar: _buildPremiumBottomBar(),
      ),
    );
  }

  /// Builds the gradient AppBar with a search-icon and notifications-icon.
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 4,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: SparshTheme.appBarGradient,
        ),
      ),
      title: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star, color: Colors.white, size: 28),
          SizedBox(width: 8),
          Text(
            'SPARSH',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none,
            size: 28,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
          },
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child:
              _isSearchVisible
                  ? const SizedBox(width: 48, height: 48)
                  : IconButton(
                    key: const ValueKey('search_icon'),
                    icon: const Icon(
                      Icons.search,
                      size: 28,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isSearchVisible = true;
                      });
                    },
                  ),
        ),
      ],
    );
  }

  /// The sliding search bar that appears on top of everything else.
  Widget _buildSearchInput(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isSearchVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Visibility(
        visible: _isSearchVisible,
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for reports, screens, etc...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _isSearchVisible = false;
                        _searchController.clear();
                        _filteredSearchItems = [];
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
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
                onSubmitted: (value) {
                  setState(() {
                    _isSearchVisible = false;
                    _searchController.clear();
                    _filteredSearchItems = [];
                  });
                },
              ),
              if (_filteredSearchItems.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredSearchItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredSearchItems[index];
                      return ListTile(
                        title: Text(item.title),
                        subtitle: Text(item.type),
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
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bottom navigation bar with a center "floating QR scanner" button.
  Widget _buildPremiumBottomBar() {
    final List<Map<String, dynamic>> navItems = [
      {
        'icon': Icons.home_outlined,
        'activeIcon': Icons.home,
        'label': 'Home',
        'color': Colors.blue.shade700,
        'gradient': LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade700],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      },
      {
        'icon': Icons.dashboard_outlined,
        'activeIcon': Icons.dashboard,
        'label': 'Dashboard',
        'color': Colors.purpleAccent,
        'gradient': LinearGradient(
          colors: [Colors.purple.shade300, Colors.purpleAccent],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      },
      {
        'icon': Icons.qr_code_scanner,
        'activeIcon': Icons.qr_code_scanner,
        'label': 'Scan',
        'color': Colors.blueAccent,
        'gradient': LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlue.shade600],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      },
      {
        'icon': Icons.schema_outlined,
        'activeIcon': Icons.schema,
        'label': 'Scheme',
        'color': Colors.orange,
        'gradient': LinearGradient(
          colors: [Colors.orange.shade300, Colors.deepOrange],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      },
      {
        'icon': Icons.person_outline,
        'activeIcon': Icons.person,
        'label': 'Profile',
        'color': Colors.green,
        'gradient': LinearGradient(
          colors: [Colors.teal.shade300, Colors.green.shade600],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      },
    ];

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Glass-morphism background behind the bottom bar
        ClipPath(
          clipper: BottomNavClipper(),
          child: Container(
            height: 95,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFEAF6FF).withValues(alpha: 0.8),
                  const Color(0xFFD6ECFF).withValues(alpha: 0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 30,
                  spreadRadius: 2,
                  offset: const Offset(0, -5),
                ),
              ],
              border: Border(
                top: BorderSide(
                  color: Colors.blue.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(navItems.length, (index) {
                  // Skip index 2 so we can leave a gap for the floating button
                  if (index == 2) return const SizedBox(width: 50);

                  final item = navItems[index];
                  final isActive = _selectedIndex == index;
                  final color = item['color'] as Color;
                  final gradient = item['gradient'] as Gradient;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (index == 3) {
                          // "Scheme" tab: directly open Schema() screen
                          _updateCurrentScreen(index, screen: const Schema());
                        } else if (index == 4) {
                          // "Profile" tab:
                          _updateCurrentScreen(
                            index,
                            screen: const ProfilePage(),
                          );
                        } else {
                          _updateCurrentScreen(index);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: isActive ? gradient : null,
                          boxShadow:
                              isActive
                                  ? [
                                    BoxShadow(
                                      color: color.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isActive ? item['activeIcon'] : item['icon'],
                              color:
                                  isActive
                                      ? Colors.white
                                      : Colors.grey.shade600,
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['label'],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight:
                                    isActive
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                color:
                                    isActive
                                        ? Colors.white
                                        : Colors.grey.shade700,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
        ),

        // Floating "Scanner" button in the center with shimmer/pulse animation:
        Positioned(
          bottom: 30,
          child: GestureDetector(
            onTap: () {
              _updateCurrentScreen(2, screen: const TokenScanPage());
            },
            child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blueAccent.shade400,
                        Colors.blueAccent.shade700,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withValues(alpha: 0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 5),
                      ),
                      BoxShadow(
                        color: Colors.blueAccent.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: Offset.zero,
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 28,
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(
                  delay: 1000.ms,
                  duration: 1800.ms,
                  color: Colors.white.withValues(alpha: 0.3),
                )
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.1, 1.1),
                  duration: 1000.ms,
                  curve: Curves.easeInOut,
                )
                .then()
                .scale(
                  begin: const Offset(1.1, 1.1),
                  end: const Offset(1, 1),
                  duration: 1000.ms,
                  curve: Curves.easeInOut,
                ),
          ),
        ),
      ],
    );
  }
}

/// Custom clipper to "cut out" the notch for the floating button.
class BottomNavClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double notchRadius = 30;
    final double centerX = size.width / 2;
    const double notchWidth = notchRadius * 2 + 30;

    final path =
        Path()
          ..lineTo(centerX - notchWidth / 2, 0)
          ..quadraticBezierTo(
            centerX - notchRadius - 15,
            0,
            centerX - notchRadius,
            25,
          )
          ..arcToPoint(
            Offset(centerX + notchRadius, 25),
            radius: const Radius.circular(notchRadius),
            clockwise: false,
          )
          ..quadraticBezierTo(
            centerX + notchRadius + 15,
            0,
            centerX + notchWidth / 2,
            0,
          )
          ..lineTo(size.width, 0)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// The "Home" tab's main content, including banners, "Mostly Used Apps," horizontal menu, and Quick Menu.
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentIndex = 0;

  /// Banner images (replace with your own assets if needed):
  final List<String> _bannerImagePaths = [
    'assets/image1.png',
    'assets/image21.jpg',
    'assets/image22.jpg',
    'assets/image23.jpg',
    'assets/image24.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (_bannerImagePaths.length > 1) {
      _startAutoScroll();
    }
    _pageController.addListener(() {
      if (_pageController.position.isScrollingNotifier.value == false) {
        _restartAutoScroll();
      }
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_pageController.hasClients) {
        timer.cancel();
        return;
      }
      double itemWidth = MediaQuery.of(context).size.width;
      double spacing = 10;
      double fullItemWidth = itemWidth + spacing;
      double maxScroll = _pageController.position.maxScrollExtent;
      double nextPosition = _currentIndex * fullItemWidth;

      if (nextPosition > maxScroll - itemWidth / 2) {
        _currentIndex = 0;
        nextPosition = 0;
      } else {
        _currentIndex++;
      }

      _pageController.animateTo(
        nextPosition,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  void _restartAutoScroll() {
    _autoScrollTimer?.cancel();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _bannerImagePaths.length > 1) {
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.removeListener(_restartAutoScroll);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildBanner(),
            const SizedBox(height: 20),
            _sectionTitle("Mostly Used Apps"),
            const SizedBox(height: 10),
            _mostlyUsedApps(screenWidth, screenHeight),
            const SizedBox(height: 20),
            const HorizontalMenu(),
            const SizedBox(height: 20),
            _sectionTitle("Quick Menu"),
            const SizedBox(height: 10),
            _quickMenu(screenHeight, screenWidth),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: Fonts.bodyBold,
      ),
    );
  }

  /// Three-column Quick Menu with 14 items (icons + labels).
  Widget _quickMenu(double screenHeight, double screenWidth) {
    final List<Map<String, String>> quickMenuItems = [
      {
        'image': 'assets/painter_kyc_tracking.png',
        'label': 'Painter KYC\nTracking',
      },
      {
        'image': 'assets/painter_kyc_registration.png',
        'label': 'Painter KYC\nRegistration',
      },
      {
        'image': 'assets/universal_outlets_registration.png',
        'label': 'Universal Outlets\nRegistration',
      },
      {
        'image': 'assets/retailer_registration.png',
        'label': 'Retailer\nRegistration',
      },
      {
        'image': 'assets/accounts_statement.png',
        'label': 'Accounts\nStatement',
      },
      {
        'image': 'assets/information_document.png',
        'label': 'Information\nDocument',
      },
      {
        'image': 'assets/rpl_outlet_tracker.png',
        'label': 'RPL Outlet\nTracker',
      },
      {'image': 'assets/scheme_document.png', 'label': 'Scheme\nDocument'},
      {'image': 'assets/activity_summary.png', 'label': 'Activity\nSummary'},
      {'image': 'assets/purchaser_360.png', 'label': 'Purchaser\n360'},
      {
        'image': 'assets/employee_dashboard.png',
        'label': 'Employee\nDashBoard',
      },
      {'image': 'assets/grc_lead_entry.png', 'label': 'GRC\nLead Entry'},
      {'image': 'assets/employee_dashboard.png', 'label': 'RPL 6\nEnrolment'},
    ];

    // Three columns to match your screenshot. Adjust to 4 if you'd prefer a 4-column layout.
    final double itemWidth = screenWidth / 3;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        color: Colors.white,
      ),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // ← 3 columns for Quick Menu
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 0.85, // Adjusted to accommodate button-style items
        ),
        itemCount: quickMenuItems.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final item = quickMenuItems[index];
          return InkWell(
            onTap: () {
              if (item['label']!.contains('Painter KYC\nTracking')) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PainterKycTrackingPage(),
                  ),
                );
              } else if (item['label']!.contains(
                'Universal Outlets\nRegistration',
              )) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UniversalOutletRegistrationPage(),
                  ),
                );
              } else if (item['label']!.contains('Retailer\nRegistration')) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RetailerRegistrationPage(),
                  ),
                );
              } else if (item['label']!.contains('Accounts\nStatement')) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AccountsStatementPage(),
                  ),
                );
              } else if (item['label']!.contains('Scheme\nDocument')) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SchemeDocumentPage()),
                );
              } else if (item['label']!.contains('Activity\nSummary')) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ActivitySummaryPage(),
                  ),
                );
              } else if (item['label']!.contains('Employee\nDashBoard')) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EmployeeDashboardPage(),
                  ),
                );
              } else if (item['label']!.contains('GRC\nLead Entry')) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GrcLeadEntryPage()),
                );
              }
            },
            child: _buildQuickMenuItem(
              item['image']!,
              item['label']!,
              itemWidth,
            ),
          );
        },
      ),
    );
  }

  /// Helper to draw each Quick Menu icon + label.
  Widget _buildQuickMenuItem(String imagePath, String label, double itemWidth) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            width: 56,
            height: 56,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: Colors.white,
            ),
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Fonts.small,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// "Mostly Used Apps" row (unchanged from before):
  Widget _mostlyUsedApps(double screenWidth, double screenHeight) {
    final List<Map<String, String>> mostlyUsedItems = [
      {'image': 'assets/image33.png', 'label': 'DSR', 'route': 'dsr'},
      {
        'image': 'assets/image34.png',
        'label': 'Staff\nAttendance',
        'route': 'attendance',
      },
      {
        'image': 'assets/image35.png',
        'label': 'DSR\nException',
        'route': 'dsr_exception',
      },
      {
        'image': 'assets/image36.png',
        'label': 'Token Scan',
        'route': 'scanner',
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            mostlyUsedItems.map((item) {
              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (item['route'] == 'dsr') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DsrEntry(),
                        ),
                      );
                    } else if (item['route'] == 'scanner') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TokenScanPage(),
                        ),
                      );
                    }
                  },
                  child: _buildMostlyUsedAppItem(
                    item['image']!,
                    item['label']!,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildMostlyUsedAppItem(String imagePath, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            width: 56,
            height: 56,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: Colors.white,
            ),
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: Fonts.small,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Banner widget (unchanged):
  Widget _buildBanner() {
    return SizedBox(
      height: 160,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _bannerImagePaths.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    _bannerImagePaths[index],
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
          if (_bannerImagePaths.length > 1)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_bannerImagePaths.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _currentIndex == index ? 16 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color:
                          _currentIndex == index
                              ? Colors.blue
                              : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

/// A simple horizontal menu bar above the Quick Menu (unchanged).
class HorizontalMenu extends StatefulWidget {
  const HorizontalMenu({super.key});

  @override
  State<HorizontalMenu> createState() => _HorizontalMenuState();
}

class _HorizontalMenuState extends State<HorizontalMenu> {
  String selected = "Quick Menu";

  final List<String> menuItems = [
    "Quick Menu",
    "Document",
    "Registration",
    "Entertainment",
    "Painter",
    "Attendance",
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final label = menuItems[index];
          final isSelected = selected == label;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: isSelected ? Colors.blue : Colors.white,
                foregroundColor: isSelected ? Colors.white : Colors.blue,
                side: BorderSide(
                  color: isSelected ? Colors.blue : Colors.grey.shade400,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onPressed: () {
                setState(() {
                  selected = label;
                });
              },
              child: Text(
                label,
                style: Fonts.body,
              ),
            ),
          );
        },
      ),
    );
  }
}

// Helper class for search items
class _SearchItem {
  final String title;
  final String type;
  final Widget Function(BuildContext) builder;
  _SearchItem(this.title, this.type, this.builder);
}
