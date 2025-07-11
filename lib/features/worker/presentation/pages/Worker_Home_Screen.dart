import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:learning2/features/worker/presentation/pages/Worker_App_Drawer.dart';
import 'dart:async';
import 'package:learning2/features/dashboard/presentation/pages/notification_screen.dart';
import 'package:learning2/features/dashboard/presentation/pages/profile_screen.dart';
import 'package:learning2/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:learning2/features/dashboard/presentation/pages/schema.dart';
import 'package:learning2/features/dashboard/presentation/pages/token_scan.dart';
import 'package:learning2/features/dashboard/presentation/pages/mail_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:learning2/features/worker/presentation/pages/Canteen_coupon_details.dart';
import 'package:learning2/features/worker/presentation/pages/Food_court.dart';
import 'package:learning2/features/worker/presentation/pages/Holiday_house_lock.dart';
import 'package:learning2/features/worker/presentation/pages/Movie_booking.dart';
import 'package:learning2/features/worker/presentation/pages/Movie_booking_details.dart';
import 'package:learning2/features/worker/presentation/pages/Telephone_Directory.dart';
import 'package:learning2/features/worker/presentation/pages/Wages_slip.dart';
import 'package:learning2/features/worker/presentation/pages/Worker_attendence.dart';
import 'package:learning2/features/worker/presentation/pages/overtime_report_self.dart';
import 'package:learning2/core/constants/fonts.dart';
import 'package:learning2/core/theme/app_theme.dart';
import 'package:learning2/core/components/advanced_3d/advanced_3d_components.dart';
import 'package:learning2/core/utils/responsive_design.dart';
import 'package:learning2/core/utils/form_validators/form_validators.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  
  // Animation controllers
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  
  final List<Widget> _screens = [
    const Advanced3DWorkerHomeContent(),
    const DashboardScreen(),
    const MailScreen(),
    const ProfilePage(),
  ];

  // Store the current screen.  Important for keeping bottom nav.
  Widget _currentScreen = const Advanced3DWorkerHomeContent();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Method to update the current screen.  Crucial for bottom nav persistence.
  void _updateCurrentScreen(int index, {Widget? screen}) {
    if (mounted) {
      //Check if the widget is still mounted.
      setState(() {
        _selectedIndex = index;
        _currentScreen =
            screen ?? _screens[index]; // Use provided screen or default
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        appBar: _buildAdvanced3DAppBar(),
        drawer: const WorkerAppDrawer(),
        body: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Stack(
                  children: [
                    _currentScreen,
                    _buildAdvanced3DSearchInput(context),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAdvanced3DAppBar() {
    return Advanced3DAppBar(
      title: 'SPARSH WORKER',
      centerTitle: true,
      leading: Builder(
        builder: (context) => Advanced3DButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          style: Advanced3DButtonStyle.icon,
          icon: Icons.menu,
          iconColor: Colors.white,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
      ),
      actions: [
        Advanced3DButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
          },
          style: Advanced3DButtonStyle.icon,
          icon: Icons.notifications_none,
          iconColor: Colors.white,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: _isSearchVisible
              ? const SizedBox(width: 48, height: 48)
              : Advanced3DButton(
                  key: const ValueKey('search_icon'),
                  onPressed: () {
                    setState(() {
                      _isSearchVisible = true;
                    });
                  },
                  style: Advanced3DButtonStyle.icon,
                  icon: Icons.search,
                  iconColor: Colors.white,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
        ),
      ],
    );
  }

  Widget _buildAdvanced3DSearchInput(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isSearchVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Visibility(
        visible: _isSearchVisible,
        child: Advanced3DCard(
          margin: ResponsiveSpacing.paddingMedium(context),
          elevation: 8,
          borderRadius: 20,
          enableGlassMorphism: true,
          backgroundColor: SparshTheme.cardBackground,
          shadowColor: SparshTheme.primaryBlue.withOpacity(0.1),
          child: Advanced3DTextField(
            controller: _searchController,
            hintText: 'Search worker services...',
            prefixIcon: Icons.search,
            suffixIcon: Icons.close,
            onSuffixIconPressed: () {
              setState(() {
                _isSearchVisible = false;
                _searchController.clear();
              });
            },
            onSubmitted: (value) {
              setState(() {
                _isSearchVisible = false;
                _searchController.clear();
              });
            },
          ),
        ),
      ),
    );
  }
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
                  hintText: 'Search for reports, orders, etc...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _isSearchVisible = false;
                        _searchController.clear();
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onSubmitted: (value) {
                  print('Searching for: $value');
                  setState(() {
                    _isSearchVisible = false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumBottomBar() {
    final List<Map<String, dynamic>> navItems = [
      {
        'icon': Icons.home_outlined,
        'activeIcon': Icons.home,
        'label': 'Home',
        'color': Colors.deepPurple.shade700,
        'gradient': LinearGradient(
          colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      },
      {
        'icon': Icons.dashboard_outlined,
        'activeIcon': Icons.dashboard,
        'label': 'Dashboard',
        'color': Colors.purple,
        'gradient': LinearGradient(
          colors: [Colors.purple.shade300, Colors.purple],
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
        // Enhanced glass morphism background with parallax effect
        ClipPath(
          clipper: BottomNavClipper(),
          child: Container(
            height: 95,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFF3E5F5).withOpacity(0.8), // Light purple
                  const Color(0xFFE1BEE7).withOpacity(0.8), // Lighter purple
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: 2,
                  offset: const Offset(0, -5),
                ),
              ],
              border: Border(
                top: BorderSide(
                  color: Colors.purple.withOpacity(0.6),
                  width: 1.5,
                ),
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(navItems.length, (index) {
                  if (index == 2) return const SizedBox(width: 70);

                  final item = navItems[index];
                  final isActive = _selectedIndex == index;
                  final color = item['color'] as Color;
                  final gradient = item['gradient'] as Gradient;

                  return GestureDetector(
                    onTap: () {
                      if (index == 3) {
                        _updateCurrentScreen(index, screen: const Schema());
                      } else if (index == 4) {
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
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
                            isActive ? Colors.white : Colors.grey.shade600,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['label'],
                            style: Fonts.smallBold.copyWith(
                              color:
                              isActive
                                  ? Colors.white
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),

        // Floating Scanner Button with pulse animation
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
                    Colors.deepPurple.shade400,
                    Colors.deepPurple.shade700,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.2),
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
              color: Colors.white.withOpacity(0.3),
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

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentIndex = 0;
  String _lastVisitDate = '';
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

    // Update and load the last visit date
    _updateLastVisitDate();
  }

  // Method to update the last visit date
  Future<void> _updateLastVisitDate() async {
    final prefs = await SharedPreferences.getInstance();

    // Get the previous visit date (if any)
    final previousVisit = prefs.getString('lastVisitDate') ?? '';

    // Get the current date and time
    final now = DateTime.now();
    final formattedDate = '${_formatDate(now)} ${_formatTime(now)}';

    // Store the current date as the last visit date
    await prefs.setString('lastVisitDate', formattedDate);

    // Update the state with the previous visit date
    if (mounted) {
      setState(() {
        _lastVisitDate = previousVisit.isNotEmpty ? previousVisit : formattedDate;
      });
    }
  }

  // Helper method to format date
  String _formatDate(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  // Helper method to format time
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
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
            _sectionTitle("Quick Menu"),
            const SizedBox(height: 10),
            _quickMenu(screenHeight, screenWidth),
            const SizedBox(height: 20),
            _sectionTitle("Information"),
            const SizedBox(height: 10),
            _informationSection(),
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
        style: Fonts.bodyBold.copyWith(color: Colors.black87),
      ),
    );
  }

  Widget _quickMenu(double screenHeight, double screenWidth) {
    final List<Map<String, String>> quickMenuItems = [
      {'image': 'assets/overtime.png', 'label': 'Overtime Report \nself'},
      {'image': 'assets/houselock.png', 'label': 'Holiday house \nLock Security'},
      {'image': 'assets/wagesslip.png', 'label': 'Wages Slip'},
      {'image': 'assets/workerattendence.png', 'label': 'Worker Attendence'},
      {'image': 'assets/telephonedirectory.png', 'label': 'Telephone Directory'},
      {'image': 'assets/moviebooking.png', 'label': 'Movie \nBooking'},
      {'image': 'assets/moviebookingdetails.png', 'label': 'Movie Booking \nDetails'},
      {'image': 'assets/foodcourt.png', 'label': 'Food Court'},
      {'image': 'assets/canteen.png', 'label': 'Canteen Coupon \nDetails'},
    ];
    final double itemWidth = screenWidth / 4;

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        color: Colors.white,
      ),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 15.0,
          mainAxisSpacing: 15.0,
          childAspectRatio: 1.0,
        ),
        itemCount: quickMenuItems.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final item = quickMenuItems[index];
          return GestureDetector(
            onTap: () {
              print("${item['label']} tapped");
              if (item['label'] == 'Overtime Report \nself') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OvertimeReportSelf(),
                  ),
                );
              }
              else if (item['label'] == 'Movie \nBooking') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MovieBooking(),
                  ),
                );
              }
              else if (item['label'] == 'Movie Booking \nDetails') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MovieBookingDetails(),
                  ),
                );
              }
              else if (item['label'] == 'Food Court') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FoodCourt(),
                  ),
                );
              }
              else if (item['label'] == 'Canteen Coupon \nDetails') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CanteenCouponDetails(),
                  ),
                );
              }
              else if (item['label'] == 'Wages Slip') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WagesSlip(),
                  ),
                );
              }
              else if (item['label'] == 'Worker Attendence') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WorkerAttendence(),
                  ),
                );
              }
              else if (item['label'] == 'Telephone Directory') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TelephoneDirectory(),
                  ),
                );
              }
              else if (item['label'] == 'Holiday house \nLock Security') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HolidayHouseLock(),
                  ),
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

  Widget _buildQuickMenuItem(String imagePath, String label, double itemWidth) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          imagePath,
          width: itemWidth * 0.6,
          height: itemWidth * 0.6,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Fonts.body.copyWith(color: Colors.black),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _informationSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Last Visit Date - using the dynamic value from SharedPreferences
          _buildInfoItem(
            icon: Icons.access_time,
            title: 'Last Visit Date',
            date: _lastVisitDate.isNotEmpty ? _lastVisitDate : 'First visit',
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 16),

          // Password Changed On
          _buildInfoItem(
            icon: Icons.lock_outline,
            title: 'Your Password Changed On',
            date: '07 Mar 2025 13:58:00',
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 16),

          // Change Password Before
          _buildInfoItem(
            icon: Icons.warning_amber_rounded,
            title: 'change Password before',
            date: '05 Jun 2025 13:58:00',
            backgroundColor: const Color(0xFFE8F5E9), // Light green background
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String date,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Fonts.body.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: Fonts.body.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


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

