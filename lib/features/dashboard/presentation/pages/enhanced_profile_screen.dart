import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:learning2/core/theme/app_theme.dart';
import 'package:learning2/core/theme/theme_manager.dart';
import 'package:learning2/core/animations/animation_library.dart';
import 'package:learning2/core/animations/advanced_ui_components.dart';
import 'package:learning2/core/animations/form_components.dart';
import 'package:learning2/features/dashboard/presentation/pages/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnhancedProfilePage extends StatefulWidget {
  final ThemeManager? themeManager;
  
  const EnhancedProfilePage({super.key, this.themeManager});

  @override
  State<EnhancedProfilePage> createState() => _EnhancedProfilePageState();
}

class _EnhancedProfilePageState extends State<EnhancedProfilePage>
    with TickerProviderStateMixin {
  late AnimationController _avatarController;
  late AnimationController _cardController;
  late Animation<double> _avatarRotation;
  late Animation<double> _avatarScale;
  
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  String _selectedGender = 'Male';
  String _selectedReport = 'Sales Report';
  
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _reportOptions = [
    'Sales Report',
    'Analytics Report',
    'Performance Report',
    'Financial Report'
  ];

  @override
  void initState() {
    super.initState();
    
    _avatarController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _avatarRotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _avatarController, curve: Curves.linear),
    );
    
    _avatarScale = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _avatarController, curve: Curves.easeInOut),
    );
    
    _avatarController.repeat(reverse: true);
    _cardController.forward();
    
    // Initialize with sample data
    _usernameController.text = 'John Doe';
    _emailController.text = 'john.doe@company.com';
    _phoneController.text = '+91 9876543210';
    _addressController.text = '123 Business District, City';
  }

  @override
  void dispose() {
    _avatarController.dispose();
    _cardController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SparshTheme.scaffoldBackground,
      body: AnimatedGradientBackground(
        colors: [
          SparshTheme.scaffoldBackground,
          SparshTheme.lightBlueBackground,
          SparshTheme.lightPurpleBackground,
        ],
        enableParticles: true,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildEnhancedHeader()
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .slideY(begin: -0.3, duration: 800.ms),
                const SizedBox(height: 32),
                StaggeredListView(
                  children: [
                    _buildAccountInfoSection(),
                    const SizedBox(height: 24),
                    _buildDashboardReportSection(),
                    const SizedBox(height: 24),
                    _buildPersonalInfoSection(),
                    const SizedBox(height: 24),
                    _buildSettingsSection(),
                    const SizedBox(height: 32),
                    _buildActionButtons(),
                    const SizedBox(height: 32),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 3D Avatar with rotation and hover effects
          AnimatedBuilder(
            animation: Listenable.merge([_avatarRotation, _avatarScale]),
            builder: (context, child) {
              return Transform.scale(
                scale: _avatarScale.value,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(_avatarRotation.value * 2 * 3.14159),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          SparshTheme.primaryBlue.withValues(alpha: 0.1),
                          SparshTheme.primaryBlue.withValues(alpha: 0.3),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: SparshTheme.primaryBlue.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                          spreadRadius: 5,
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.8),
                          blurRadius: 15,
                          offset: const Offset(-5, -5),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              SparshTheme.primaryBlue,
                              SparshTheme.primaryBlueAccent,
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          
          // User Info with Glass Morphism
          GlassMorphismContainer(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'John Doe',
                  style: SparshTypography.heading4.copyWith(
                    color: SparshTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Senior Sales Manager',
                  style: SparshTypography.body.copyWith(
                    color: SparshTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatChip('Projects', '24', Icons.work_outline),
                    _buildStatChip('Tasks', '156', Icons.task_alt),
                    _buildStatChip('Teams', '8', Icons.group_outlined),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SparshTheme.primaryBlue.withValues(alpha: 0.1),
            SparshTheme.primaryBlue.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SparshTheme.primaryBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: SparshTheme.primaryBlue,
              ),
              const SizedBox(width: 4),
              Text(
                value,
                style: SparshTypography.labelLarge.copyWith(
                  color: SparshTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: SparshTypography.bodySmall.copyWith(
              color: SparshTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: FloatingPanel(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_circle,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Information',
                        style: SparshTypography.heading5,
                      ),
                      Text(
                        'Manage your account details',
                        style: SparshTypography.bodySmall.copyWith(
                          color: SparshTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AnimatedFormField(
              label: 'Username',
              controller: _usernameController,
              prefixIcon: const Icon(Icons.person_outline),
              validator: (value) => value?.isEmpty ?? true ? 'Username is required' : null,
            ),
            const SizedBox(height: 16),
            AnimatedFormField(
              label: 'Email Address',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined),
              validator: (value) => value?.isEmpty ?? true ? 'Email is required' : null,
            ),
            const SizedBox(height: 16),
            AnimatedFormField(
              label: 'Phone Number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone_outlined),
              validator: (value) => value?.isEmpty ?? true ? 'Phone number is required' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardReportSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: FloatingPanel(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade400, Colors.orange.shade600],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.dashboard,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard Settings',
                        style: SparshTypography.heading5,
                      ),
                      Text(
                        'Configure your dashboard preferences',
                        style: SparshTypography.bodySmall.copyWith(
                          color: SparshTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AnimatedSearchDropdown<String>(
              label: 'Default Report',
              items: _reportOptions,
              itemAsString: (item) => item,
              selectedItem: _selectedReport,
              onChanged: (value) {
                setState(() {
                  _selectedReport = value ?? _reportOptions.first;
                });
              },
              prefixIcon: const Icon(Icons.assessment_outlined),
            ),
            const SizedBox(height: 16),
            AnimatedSwitch(
              value: true,
              onChanged: (value) {},
              label: 'Enable Notifications',
              activeColor: SparshTheme.primaryBlue,
            ),
            const SizedBox(height: 16),
            AnimatedSwitch(
              value: false,
              onChanged: (value) {},
              label: 'Auto-refresh Dashboard',
              activeColor: SparshTheme.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: FloatingPanel(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal Information',
                        style: SparshTypography.heading5,
                      ),
                      Text(
                        'Update your personal details',
                        style: SparshTypography.bodySmall.copyWith(
                          color: SparshTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AnimatedSearchDropdown<String>(
              label: 'Gender',
              items: _genderOptions,
              itemAsString: (item) => item,
              selectedItem: _selectedGender,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value ?? _genderOptions.first;
                });
              },
              prefixIcon: const Icon(Icons.person_outline),
            ),
            const SizedBox(height: 16),
            AnimatedFormField(
              label: 'Address',
              controller: _addressController,
              maxLines: 3,
              prefixIcon: const Icon(Icons.location_on_outlined),
              validator: (value) => value?.isEmpty ?? true ? 'Address is required' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: FloatingPanel(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade400, Colors.purple.shade600],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'App Settings',
                        style: SparshTypography.heading5,
                      ),
                      Text(
                        'Customize your app experience',
                        style: SparshTypography.bodySmall.copyWith(
                          color: SparshTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (widget.themeManager != null) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Dark Mode',
                      style: SparshTypography.body,
                    ),
                  ),
                  AnimatedThemeSwitch(
                    themeManager: widget.themeManager!,
                    size: 40,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            AnimatedCheckbox(
              value: true,
              onChanged: (value) {},
              label: 'Push Notifications',
              activeColor: SparshTheme.primaryBlue,
            ),
            const SizedBox(height: 16),
            AnimatedCheckbox(
              value: false,
              onChanged: (value) {},
              label: 'Email Notifications',
              activeColor: SparshTheme.primaryBlue,
            ),
            const SizedBox(height: 16),
            AnimatedCheckbox(
              value: true,
              onChanged: (value) {},
              label: 'Analytics Tracking',
              activeColor: SparshTheme.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Save Button
          SizedBox(
            width: double.infinity,
            child: FloatingPanel(
              padding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              enableHover: false,
              child: Container(
                decoration: BoxDecoration(
                  gradient: SparshTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Save profile logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully!'),
                        backgroundColor: SparshTheme.successGreen,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Save Changes',
                        style: SparshTypography.button,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Logout Button
          SizedBox(
            width: double.infinity,
            child: FloatingPanel(
              padding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              enableHover: false,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [SparshTheme.errorRed, SparshTheme.errorRed.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton(
                  onPressed: () => _showLogoutDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: SparshTypography.button,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: SparshTheme.errorRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.logout,
                color: SparshTheme.errorRed,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Logout',
              style: SparshTypography.heading5,
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: SparshTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: SparshTypography.labelLarge.copyWith(
                color: SparshTheme.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SparshTheme.errorRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _performLogout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SplashScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during logout: $e'),
            backgroundColor: SparshTheme.errorRed,
          ),
        );
      }
    }
  }
}