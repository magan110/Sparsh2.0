import 'package:flutter/material.dart';
import 'package:learning2/core/theme/app_theme.dart';
import 'package:learning2/features/dashboard/presentation/pages/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learning2/core/components/advanced_3d/advanced_3d_components.dart';
import 'package:learning2/core/utils/responsive_design.dart';
import 'package:learning2/core/utils/form_validators/form_validators.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );
    
    _slideAnimation = Tween<double>(begin: 80.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );
    
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SparshTheme.scaffoldBackground,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: ResponsiveSpacing.large(context),
                    ),
                    child: Column(
                      children: [
                        _buildAdvanced3DProfileHeader(),
                        SizedBox(height: ResponsiveSpacing.xxLarge(context)),
                        Padding(
                          padding: ResponsiveSpacing.paddingHorizontalMedium(context),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildAdvanced3DSectionTitle('Account Info'),
                              SizedBox(height: ResponsiveSpacing.medium(context)),
                              _buildAdvanced3DInfoCard([
                                _buildAdvanced3DTextField('Username*', Icons.person_outline),
                                _buildAdvanced3DTextField('Email Address*', Icons.email_outlined),
                                _buildAdvanced3DTextField('Phone Number*', Icons.phone_outlined),
                              ]),
                              SizedBox(height: ResponsiveSpacing.large(context)),
                              _buildAdvanced3DSectionTitle('Dashboard Report'),
                              SizedBox(height: ResponsiveSpacing.medium(context)),
                              _buildAdvanced3DInfoCard([
                                _buildAdvanced3DDropdownField('Select Report*', Icons.assessment_outlined),
                              ]),
                              SizedBox(height: ResponsiveSpacing.large(context)),
                              _buildAdvanced3DSectionTitle('Personal Info'),
                              SizedBox(height: ResponsiveSpacing.medium(context)),
                              _buildAdvanced3DInfoCard([
                                _buildAdvanced3DDropdownField('Gender*', Icons.person_outline),
                                _buildAdvanced3DTextField('Address*', Icons.location_on_outlined),
                              ]),
                              SizedBox(height: ResponsiveSpacing.xxLarge(context)),
                              _buildAdvanced3DLogoutButton(context),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAdvanced3DProfileHeader() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Advanced3DCard(
        elevation: 16,
        borderRadius: 32,
        enableGlassMorphism: true,
        backgroundColor: SparshTheme.primaryBlue,
        shadowColor: SparshTheme.primaryBlue.withOpacity(0.4),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: SparshTheme.primaryGradient,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: ResponsiveSpacing.xxLarge(context),
              horizontal: ResponsiveSpacing.large(context),
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Advanced3DCard(
                      elevation: 12,
                      borderRadius: 60,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      shadowColor: Colors.black.withOpacity(0.3),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 3,
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 52,
                          backgroundImage: AssetImage('assets/avatar.png'),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 8,
                      child: Advanced3DButton(
                        onPressed: () {
                          // Handle camera action
                        },
                        style: Advanced3DButtonStyle.floating,
                        backgroundColor: Colors.white,
                        shadowColor: SparshTheme.primaryBlue.withOpacity(0.3),
                        borderRadius: 50,
                        child: const Icon(
                          Icons.camera_alt,
                          color: SparshTheme.primaryBlue,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveSpacing.medium(context)),
                Text(
                  'Magan',
                  style: ResponsiveTypography.headlineLarge(context).copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: ResponsiveSpacing.small(context)),
                Advanced3DCard(
                  elevation: 4,
                  borderRadius: 20,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  shadowColor: Colors.white.withOpacity(0.1),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveSpacing.medium(context),
                      vertical: ResponsiveSpacing.small(context),
                    ),
                    child: Text(
                      'ID S2948',
                      style: ResponsiveTypography.bodyMedium(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveSpacing.small(context)),
                Text(
                  'IT Department',
                  style: ResponsiveTypography.bodyMedium(context).copyWith(
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: ResponsiveSpacing.large(context)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAdvanced3DStatCard(
                      icon: Icons.work_outline,
                      value: '5',
                      label: 'Projects',
                    ),
                    _buildAdvanced3DStatCard(
                      icon: Icons.star_outline,
                      value: '4.8',
                      label: 'Rating',
                    ),
                    _buildAdvanced3DStatCard(
                      icon: Icons.calendar_today_outlined,
                      value: '2',
                      label: 'Years',
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveSpacing.medium(context)),
                Wrap(
                  spacing: ResponsiveSpacing.medium(context),
                  runSpacing: ResponsiveSpacing.small(context),
                  alignment: WrapAlignment.center,
                  children: [
                    _buildAdvanced3DQuickAction(
                      icon: Icons.edit_outlined,
                      label: 'Edit',
                      onPressed: () {
                        // Handle edit action
                      },
                    ),
                    _buildAdvanced3DQuickAction(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      onPressed: () {
                        // Handle settings action
                      },
                    ),
                    _buildAdvanced3DQuickAction(
                      icon: Icons.notifications_outlined,
                      label: 'Alerts',
                      onPressed: () {
                        // Handle alerts action
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdvanced3DSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: ResponsiveSpacing.xs(context)),
      child: Text(
        title,
        style: ResponsiveTypography.headlineSmall(context).copyWith(
          fontWeight: FontWeight.w600,
          color: SparshTheme.primaryBlue,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildAdvanced3DInfoCard(List<Widget> children) {
    return Advanced3DCard(
      elevation: 8,
      borderRadius: 20,
      enableGlassMorphism: true,
      backgroundColor: SparshTheme.cardBackground,
      shadowColor: SparshTheme.primaryBlue.withOpacity(0.1),
      child: Padding(
        padding: ResponsiveSpacing.paddingLarge(context),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildAdvanced3DTextField(String label, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveSpacing.medium(context)),
      child: Advanced3DTextField(
        labelText: label,
        prefixIcon: icon,
        validator: (value) {
          if (label.contains('Email')) {
            return FormValidators.validateEmail(value);
          } else if (label.contains('Phone')) {
            return FormValidators.validatePhoneNumber(value);
          } else {
            return FormValidators.validateRequired(value, fieldName: label);
          }
        },
      ),
    );
  }

  Widget _buildAdvanced3DDropdownField(String label, IconData icon) {
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
      padding: EdgeInsets.only(bottom: ResponsiveSpacing.medium(context)),
      child: Advanced3DCard(
        elevation: 2,
        borderRadius: 16,
        backgroundColor: SparshTheme.lightBlueBackground,
        shadowColor: SparshTheme.primaryBlue.withOpacity(0.1),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: SparshTheme.primaryBlue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: SparshTheme.primaryBlue, width: 2),
            ),
            filled: true,
            fillColor: Colors.transparent,
            labelStyle: ResponsiveTypography.bodyMedium(context).copyWith(
              color: SparshTheme.textSecondary,
            ),
          ),
          items: items,
          onChanged: (value) {},
          icon: Icon(Icons.arrow_drop_down, color: SparshTheme.primaryBlue),
          dropdownColor: SparshTheme.cardBackground,
          style: ResponsiveTypography.bodyMedium(context).copyWith(
            color: SparshTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildAdvanced3DLogoutButton(BuildContext context) {
    return Advanced3DButton(
      onPressed: () => _handleLogout(context),
      style: Advanced3DButtonStyle.elevated,
      backgroundColor: SparshTheme.primaryBlue,
      shadowColor: SparshTheme.primaryBlue.withOpacity(0.3),
      borderRadius: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.logout, color: Colors.white),
          SizedBox(width: ResponsiveSpacing.small(context)),
          Text(
            'Logout',
            style: ResponsiveTypography.bodyLarge(context).copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvanced3DStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Advanced3DCard(
      elevation: 6,
      borderRadius: 16,
      backgroundColor: Colors.white.withOpacity(0.15),
      shadowColor: Colors.white.withOpacity(0.1),
      child: Container(
        width: 100,
        padding: ResponsiveSpacing.paddingMedium(context),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            SizedBox(height: ResponsiveSpacing.small(context)),
            Text(
              value,
              style: ResponsiveTypography.headlineSmall(context).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: ResponsiveSpacing.xs(context)),
            Text(
              label,
              style: ResponsiveTypography.bodySmall(context).copyWith(
                color: Colors.white.withOpacity(0.85),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvanced3DQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Advanced3DButton(
      onPressed: onPressed,
      style: Advanced3DButtonStyle.outlined,
      backgroundColor: Colors.white.withOpacity(0.1),
      borderColor: Colors.white.withOpacity(0.3),
      shadowColor: Colors.white.withOpacity(0.1),
      borderRadius: 20,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          SizedBox(width: ResponsiveSpacing.xs(context)),
          Text(
            label,
            style: ResponsiveTypography.bodySmall(context).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (context) => Advanced3DCard(
        elevation: 16,
        borderRadius: 20,
        backgroundColor: SparshTheme.cardBackground,
        shadowColor: SparshTheme.primaryBlue.withOpacity(0.2),
        child: AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Logout',
            style: ResponsiveTypography.headlineSmall(context).copyWith(
              color: SparshTheme.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: ResponsiveTypography.bodyMedium(context).copyWith(
              color: SparshTheme.textSecondary,
            ),
          ),
          actions: [
            Advanced3DButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: Advanced3DButtonStyle.outlined,
              backgroundColor: Colors.transparent,
              borderColor: SparshTheme.borderGrey,
              child: Text(
                'Cancel',
                style: ResponsiveTypography.bodyMedium(context).copyWith(
                  color: SparshTheme.textSecondary,
                ),
              ),
            ),
            Advanced3DButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: Advanced3DButtonStyle.elevated,
              backgroundColor: SparshTheme.primaryBlue,
              shadowColor: SparshTheme.primaryBlue.withOpacity(0.3),
              child: Text(
                'Logout',
                style: ResponsiveTypography.bodyMedium(context).copyWith(
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
}
