import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:learning2/features/staff/presentation/pages/staff_attendence.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:learning2/features/worker/presentation/pages/Canteen_coupon_details.dart';
import 'package:learning2/features/worker/presentation/pages/Food_court.dart';
import 'package:learning2/features/worker/presentation/pages/Holiday_house_lock.dart';
import 'package:learning2/features/worker/presentation/pages/Movie_booking.dart';
import 'package:learning2/features/worker/presentation/pages/Movie_booking_details.dart';
import 'package:learning2/features/worker/presentation/pages/Telephone_Directory.dart';
import 'package:learning2/features/authentication/presentation/pages/login_screen.dart';
import 'package:learning2/features/dashboard/presentation/pages/notification_screen.dart';
import 'package:learning2/features/dashboard/presentation/pages/profile_screen.dart';
import 'package:learning2/features/dashboard/presentation/pages/schema.dart';
import 'package:learning2/features/dashboard/presentation/pages/token_scan.dart';
import 'employee_details.dart';
import 'employee_master.dart';
import 'first_aid.dart';
import 'package:learning2/core/constants/fonts.dart';
import 'package:learning2/core/theme/app_theme.dart';

class StaffHomeScreen extends StatefulWidget {
  const StaffHomeScreen({super.key});

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  int _selectedIndex = 0;
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  final List<Widget> _screens = [
    const HomeContent(),
  ];

  // Store the current screen.  Important for keeping bottom nav.
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
      // Wrap your Scaffold with WillPopScope
      onWillPop: () async {
        // Handle back button press here
        if (_selectedIndex != 0) {
          //check if bottom navigation is selected
          _updateCurrentScreen(0); // Go back to the home screen
          return false; // Prevent default back button behavior (closing the app)
        }
        return true; // Allow closing the app from the home screen
      },
      child: Scaffold(
        backgroundColor: SparshTheme.lightBlueBackground,
        appBar: _buildAppBar(),
        drawer: const StaffAppDrawer(),
        body: Stack(
          children: [
            // Use _currentScreen here.
            _currentScreen,
            _buildSearchInput(context),
          ],
        ),
      ),
    );
  }

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
            print('Notifications tapped');
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
                            style: Fonts.smallBold.copyWith(color: Colors.white),
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
      {'image': 'assets/firstaid.png', 'label': 'First Aid Personnel \nPresent'},
      {'image': 'assets/employeemaster.png', 'label': 'Employee Master'},
      {'image': 'assets/employeedetails.png', 'label': 'Employee Details'},
      {'image': 'assets/staffattendance.png', 'label': 'Staff Attendance'},
      {'image': 'assets/shiftoffdays.png', 'label': 'Shift Off \nDays'},
      {'image': 'assets/dayend.png', 'label': 'Day End'},
      {'image': 'assets/absentreport.png', 'label': 'Absent Report'},
      {'image': 'assets/leaveapproval.png', 'label': 'Leave Approval'},
      {'image': 'assets/leavecancel.png', 'label': 'Leave Cancel'},
      {'image': 'assets/leaveentry.png', 'label': 'Leave Entry'},
      {'image': 'assets/leavedownload.png', 'label': 'Leave Download'},
      {'image': 'assets/attendanceupdate.png', 'label': 'Attendance Update'},
      {'image': 'assets/attendancesummary.png', 'label': 'Attendance Summary'},
      {'image': 'assets/attendancemismatch.png', 'label': 'Attendance Mismatch'},
      {'image': 'assets/attendancenotmarked.png', 'label': 'Attendance Not Marked'},
      {'image': 'assets/trainingfeedback.png', 'label': 'Training Feedback'},
      {'image': 'assets/houselock.png', 'label': 'Holiday house \nLock Security'},
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
              if (item['label'] == 'Movie \nBooking') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MovieBooking(),
                  ),
                );
              }
              else if (item['label'] == 'First Aid Personnel \nPresent') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FirstAid(),
                  ),
                );
              }
              else if (item['label'] == 'Employee Master') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmployeeMaster(),
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
              else if (item['label'] == 'Employee Details') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmployeeDetails(),
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
              else if (item['label'] == 'Staff Attendance') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StaffAttendence(),
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
                  style: Fonts.body.copyWith(fontWeight: FontWeight.w500, color: Colors.black87),
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

class StaffAppDrawer extends StatefulWidget {
  const StaffAppDrawer({super.key});

  @override
  State<StaffAppDrawer> createState() => _StaffAppDrawerState();
}

class _StaffAppDrawerState extends State<StaffAppDrawer> {
  // Selected category
  String _selectedCategory = 'Accounts';

  // List of categories
  final List<String> _categories = [
    'Accounts',
    'Stores',
    'Marketing',
    'HR&Admn',
    'Plant',
    'CMC',
    'General',
    'Admin',
    'Personnel',
    'Employee',
    'DSS',
    'Legal',
    'Safety',
    'Master',
  ];

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAdminLoggedIn', false);
    await prefs.setBool('isLoggedIn', false);

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Drawer header with Birla White
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blueAccent, // A slightly more vibrant blue
                gradient: LinearGradient(
                  // Add a subtle gradient
                  colors: [Colors.blueAccent, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  // Add a shadow for depth
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Error handling for image loading is good
                  SizedBox(
                    width: 700,
                    child: Image.asset(
                      'assets/logo.png', // Ensure this asset exists in pubspec.yaml
                      height: 97,
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading drawer header image: $error');
                        return const Icon(
                          Icons.business,
                          size: 60,
                          color: Colors.white,
                        ); // Placeholder icon
                      },
                    ),
                  ),
                  const SizedBox(height: 12), // Increased spacing
                  const Text(
                    'Birla White',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18, // Slightly larger font size
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2, // Added letter spacing
                    ),
                  ),
                ],
              ),
            ),

            // Categories list
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;

                  return Container(
                    color: isSelected ? Colors.lightBlue : Colors.white,
                    child: ListTile(
                      title: Text(
                        category,
                        style: isSelected ? Fonts.bodyBold : Fonts.body,
                      ),
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            // Logout option
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}


class _DeptText extends StatelessWidget {
  final String label;
  const _DeptText(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
        letterSpacing: 0.2,
      ),
    );
  }
}
