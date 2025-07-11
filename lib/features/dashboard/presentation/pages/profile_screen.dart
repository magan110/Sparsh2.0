import 'package:flutter/material.dart';
import 'package:learning2/core/theme/app_theme.dart';
import 'package:learning2/core/utils/responsive_util.dart';
import 'package:learning2/presentation/widgets/advanced_3d_components.dart';
import 'package:learning2/presentation/animations/advanced_animations.dart';
import 'package:learning2/features/dashboard/presentation/pages/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  late List<Widget> _profileSections;
  
  @override
  void initState() {
    super.initState();
    _profileSections = [
      _buildAccountInfoSection(),
      _buildDashboardReportSection(),
      _buildPersonalInfoSection(),
      _buildLogoutSection(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtil.init(context);
    
    return Scaffold(
      backgroundColor: SparshTheme.scaffoldBackground,
      appBar: const Advanced3DAppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        enableGlassMorphism: true,
        enable3DTransform: true,
        gradient: SparshTheme.appBarGradient,
      ),
      body: SafeArea(
        child: ResponsiveBuilder(
          builder: (context, screenType) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  SizedBox(height: ResponsiveUtil.scaledHeight(context, 32)),
                  Padding(
                    padding: ResponsiveUtil.scaledPadding(context, horizontal: 16),
                    child: AdvancedStaggeredAnimation(
                      duration: const Duration(milliseconds: 400),
                      delay: const Duration(milliseconds: 150),
                      children: _profileSections.map((section) => Padding(
                        padding: EdgeInsets.only(
                          bottom: ResponsiveUtil.scaledHeight(context, 24),
                        ),
                        child: section,
                      )).toList(),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtil.scaledHeight(context, 32)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return GlassMorphismContainer(
      width: double.infinity,
      borderRadius: 0,
      blurStrength: 15,
      opacity: 0.1,
      color: SparshTheme.primaryBlue,
      child: Container(
        decoration: const BoxDecoration(
          gradient: SparshTheme.primaryGradient,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: Padding(
          padding: ResponsiveUtil.scaledPadding(context, all: 40),
          child: Column(
            children: [
              _buildProfileAvatar(),
              SizedBox(height: ResponsiveUtil.scaledHeight(context, 20)),
              _buildProfileInfo(),
              SizedBox(height: ResponsiveUtil.scaledHeight(context, 24)),
              _buildProfileStats(),
              SizedBox(height: ResponsiveUtil.scaledHeight(context, 20)),
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Advanced3DTransform(
      enableAnimation: true,
      rotationY: 0.1,
      perspective: 0.003,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: ResponsiveUtil.scaledSize(context, 120),
            height: ResponsiveUtil.scaledSize(context, 120),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF64B5F6),
                  Color(0xFF1976D2),
                ],
              ),
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              size: 60,
              color: Colors.white,
            ),
          ),
          Positioned(
            bottom: 5,
            right: 5,
            child: Advanced3DTransform(
              enableAnimation: true,
              rotationZ: 0.2,
              child: AdvancedAnimatedContainer(
                duration: const Duration(milliseconds: 300),
                enableHover: true,
                enableScale: true,
                onTap: () {
                  // Handle camera tap
                },
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: SparshTheme.primaryBlue,
                  size: ResponsiveUtil.getIconSize(context, 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      children: [
        Text(
          'Magan',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtil.scaledFontSize(context, 28),
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: ResponsiveUtil.scaledHeight(context, 8)),
        Advanced3DTransform(
          enableAnimation: true,
          scaleX: 1.02,
          scaleY: 1.02,
          child: Container(
            padding: ResponsiveUtil.scaledPadding(context, horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            ),
            child: Text(
              'ID S2948',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: ResponsiveUtil.scaledFontSize(context, 16),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        SizedBox(height: ResponsiveUtil.scaledHeight(context, 8)),
        Text(
          'IT Department',
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.9),
            fontSize: ResponsiveUtil.scaledFontSize(context, 16),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileStats() {
    return ResponsiveBuilder(
      builder: (context, screenType) {
        if (screenType == ScreenType.mobile) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard(
                    icon: Icons.work_outline,
                    value: '5',
                    label: 'Projects',
                  ),
                  _buildStatCard(
                    icon: Icons.star_outline,
                    value: '4.8',
                    label: 'Rating',
                  ),
                ],
              ),
              SizedBox(height: ResponsiveUtil.scaledHeight(context, 12)),
              _buildStatCard(
                icon: Icons.calendar_today_outlined,
                value: '2',
                label: 'Years',
              ),
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard(
                icon: Icons.work_outline,
                value: '5',
                label: 'Projects',
              ),
              _buildStatCard(
                icon: Icons.star_outline,
                value: '4.8',
                label: 'Rating',
              ),
              _buildStatCard(
                icon: Icons.calendar_today_outlined,
                value: '2',
                label: 'Years',
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildQuickActions() {
    return ResponsiveBuilder(
      builder: (context, screenType) {
        return Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _buildQuickAction(icon: Icons.edit_outlined, label: 'Edit'),
            _buildQuickAction(icon: Icons.settings_outlined, label: 'Settings'),
            _buildQuickAction(icon: Icons.notifications_outlined, label: 'Alerts'),
          ],
        );
      },
    );
  }

  Widget _buildAccountInfoSection() {
    return Advanced3DCard(
      enableGlassMorphism: false,
      enableHover: true,
      enable3DTransform: true,
      elevation: 8,
      borderRadius: 20,
      backgroundColor: Colors.white,
      padding: ResponsiveUtil.scaledPadding(context, all: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Account Info'),
          SizedBox(height: ResponsiveUtil.scaledHeight(context, 20)),
          _buildTextField('Username*', Icons.person_outline),
          _buildTextField('Email Address*', Icons.email_outlined),
          _buildTextField('Phone Number*', Icons.phone_outlined),
        ],
      ),
    );
  }

  Widget _buildDashboardReportSection() {
    return Advanced3DCard(
      enableGlassMorphism: false,
      enableHover: true,
      enable3DTransform: true,
      elevation: 8,
      borderRadius: 20,
      backgroundColor: Colors.white,
      padding: ResponsiveUtil.scaledPadding(context, all: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Dashboard Report'),
          SizedBox(height: ResponsiveUtil.scaledHeight(context, 20)),
          _buildDropdownField('Select Report*', Icons.assessment_outlined),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Advanced3DCard(
      enableGlassMorphism: false,
      enableHover: true,
      enable3DTransform: true,
      elevation: 8,
      borderRadius: 20,
      backgroundColor: Colors.white,
      padding: ResponsiveUtil.scaledPadding(context, all: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Personal Info'),
          SizedBox(height: ResponsiveUtil.scaledHeight(context, 20)),
          _buildDropdownField('Gender*', Icons.person_outline),
          _buildTextField('Address*', Icons.location_on_outlined),
        ],
      ),
    );
  }

  Widget _buildLogoutSection() {
    return Advanced3DCard(
      enableGlassMorphism: false,
      enableHover: true,
      enable3DTransform: true,
      elevation: 8,
      borderRadius: 20,
      backgroundColor: Colors.white,
      padding: ResponsiveUtil.scaledPadding(context, all: 24),
      child: _buildLogoutButton(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Advanced3DTransform(
          enableAnimation: true,
          rotationY: 0.05,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: SparshTheme.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getSectionIcon(title),
              size: ResponsiveUtil.getIconSize(context, 20),
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(width: ResponsiveUtil.scaledWidth(context, 12)),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtil.scaledFontSize(context, 18),
            fontWeight: FontWeight.bold,
            color: SparshTheme.primaryBlue,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  IconData _getSectionIcon(String title) {
    switch (title) {
      case 'Account Info':
        return Icons.account_circle_outlined;
      case 'Dashboard Report':
        return Icons.assessment_outlined;
      case 'Personal Info':
        return Icons.person_outline;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildTextField(String label, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUtil.scaledHeight(context, 16)),
      child: AdvancedAnimatedContainer(
        duration: const Duration(milliseconds: 300),
        enableHover: true,
        enableScale: true,
        child: TextField(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Advanced3DTransform(
              enableAnimation: true,
              rotationY: 0.1,
              child: Icon(icon, color: SparshTheme.primaryBlue),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: SparshTheme.borderGrey, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: SparshTheme.borderGrey, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: SparshTheme.primaryBlue, width: 2),
            ),
            filled: true,
            fillColor: SparshTheme.lightBlueBackground,
            contentPadding: ResponsiveUtil.scaledPadding(context, all: 16),
            labelStyle: GoogleFonts.poppins(
              fontSize: ResponsiveUtil.scaledFontSize(context, 14),
              color: SparshTheme.textSecondary,
            ),
            floatingLabelStyle: GoogleFonts.poppins(
              fontSize: ResponsiveUtil.scaledFontSize(context, 14),
              color: SparshTheme.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtil.scaledFontSize(context, 14),
            color: SparshTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, IconData icon) {
    List<DropdownMenuItem<String>> items = [];

    if (label == 'Gender*') {
      items = const [
        DropdownMenuItem(value: 'Male', child: Text('Male')),
        DropdownMenuItem(value: 'Female', child: Text('Female')),
        DropdownMenuItem(value: 'Other', child: Text('Other')),
      ];
    } else if (label == 'Select Report*') {
      items = const [
        DropdownMenuItem(value: 'Sales Summary', child: Text('Sales Summary')),
        DropdownMenuItem(value: 'DSR VIST', child: Text('DSR VIST')),
        DropdownMenuItem(value: 'Token Scan', child: Text('Token Scan')),
      ];
    }

    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUtil.scaledHeight(context, 16)),
      child: AdvancedAnimatedContainer(
        duration: const Duration(milliseconds: 300),
        enableHover: true,
        enableScale: true,
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Advanced3DTransform(
              enableAnimation: true,
              rotationY: 0.1,
              child: Icon(icon, color: SparshTheme.primaryBlue),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: SparshTheme.borderGrey, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: SparshTheme.borderGrey, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: SparshTheme.primaryBlue, width: 2),
            ),
            filled: true,
            fillColor: SparshTheme.lightBlueBackground,
            contentPadding: ResponsiveUtil.scaledPadding(context, all: 16),
            labelStyle: GoogleFonts.poppins(
              fontSize: ResponsiveUtil.scaledFontSize(context, 14),
              color: SparshTheme.textSecondary,
            ),
            floatingLabelStyle: GoogleFonts.poppins(
              fontSize: ResponsiveUtil.scaledFontSize(context, 14),
              color: SparshTheme.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          items: items,
          onChanged: (value) {},
          icon: Advanced3DTransform(
            enableAnimation: true,
            rotationZ: 0.1,
            child: Icon(Icons.arrow_drop_down, color: SparshTheme.primaryBlue),
          ),
          dropdownColor: Colors.white,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtil.scaledFontSize(context, 14),
            color: SparshTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return AdvancedAnimatedContainer(
      duration: const Duration(milliseconds: 300),
      enableHover: true,
      enableScale: true,
      onTap: () => _handleLogout(),
      width: double.infinity,
      padding: ResponsiveUtil.scaledPadding(context, vertical: 16),
      decoration: BoxDecoration(
        gradient: SparshTheme.redGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: SparshTheme.errorRed.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Advanced3DTransform(
            enableAnimation: true,
            rotationZ: 0.1,
            child: Icon(
              Icons.logout,
              color: Colors.white,
              size: ResponsiveUtil.getIconSize(context, 20),
            ),
          ),
          SizedBox(width: ResponsiveUtil.scaledWidth(context, 8)),
          Text(
            'Logout',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtil.scaledFontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogout() async {
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (context) => Advanced3DTransform(
        enableAnimation: true,
        perspective: 0.003,
        rotationY: 0.05,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          elevation: 20,
          title: Row(
            children: [
              Advanced3DTransform(
                enableAnimation: true,
                rotationY: 0.1,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: SparshTheme.redGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: GoogleFonts.poppins(
                  color: SparshTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.poppins(
              color: SparshTheme.textSecondary,
            ),
          ),
          actions: [
            AdvancedAnimatedContainer(
              duration: const Duration(milliseconds: 300),
              enableHover: true,
              enableScale: true,
              onTap: () => Navigator.of(context).pop(false),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: SparshTheme.borderGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: SparshTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            AdvancedAnimatedContainer(
              duration: const Duration(milliseconds: 300),
              enableHover: true,
              enableScale: true,
              onTap: () => Navigator.of(context).pop(true),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: SparshTheme.redGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmLogout == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SplashScreen()),
        );
      }
    }
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return AdvancedAnimatedContainer(
      duration: const Duration(milliseconds: 300),
      enableHover: true,
      enableScale: true,
      width: ResponsiveUtil.scaledWidth(context, 90),
      padding: ResponsiveUtil.scaledPadding(context, horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Advanced3DTransform(
            enableAnimation: true,
            rotationY: 0.1,
            child: Icon(
              icon,
              color: Colors.white,
              size: ResponsiveUtil.getIconSize(context, 24),
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaledHeight(context, 8)),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: ResponsiveUtil.scaledFontSize(context, 18),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaledHeight(context, 4)),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.9),
              fontSize: ResponsiveUtil.scaledFontSize(context, 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({required IconData icon, required String label}) {
    return AdvancedAnimatedContainer(
      duration: const Duration(milliseconds: 300),
      enableHover: true,
      enableScale: true,
      onTap: () {
        // Handle quick action
      },
      padding: ResponsiveUtil.scaledPadding(context, horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Advanced3DTransform(
            enableAnimation: true,
            rotationY: 0.1,
            child: Icon(
              icon,
              color: Colors.white,
              size: ResponsiveUtil.getIconSize(context, 16),
            ),
          ),
          SizedBox(width: ResponsiveUtil.scaledWidth(context, 6)),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: ResponsiveUtil.scaledFontSize(context, 12),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
