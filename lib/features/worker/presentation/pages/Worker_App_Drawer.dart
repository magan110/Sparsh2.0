import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learning2/features/authentication/presentation/pages/login_screen.dart';
import 'package:learning2/core/constants/fonts.dart';
import 'package:learning2/core/components/advanced_3d/advanced_3d_components.dart';
import 'package:learning2/core/utils/responsive_design.dart';
import 'package:learning2/core/utils/form_validators/form_validators.dart';
import 'package:learning2/core/theme/app_theme.dart';

class WorkerAppDrawer extends StatefulWidget {
  const WorkerAppDrawer({super.key});

  @override
  State<WorkerAppDrawer> createState() => _WorkerAppDrawerState();
}

class _WorkerAppDrawerState extends State<WorkerAppDrawer> 
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // Selected category
  String _selectedCategory = 'Accounts';

  // List of categories
  final List<String> _categories = [
    'Accounts',
    'HR&Admin',
    'General',
    'Personnel',
    'Employee',
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

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
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Container(
            color: SparshTheme.scaffoldBackground,
            child: Column(
              children: [
                // Drawer header with Advanced 3D styling
                Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Advanced3DCard(
                      width: double.infinity,
                      height: 200,
                      borderRadius: 0,
                      enableGlassMorphism: true,
                      backgroundColor: SparshTheme.primaryBlue,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              'assets/logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.business,
                                  size: 40,
                                  color: Colors.white,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Birla White',
                            style: TextStyle(
                              fontSize: ResponsiveTypography.headingMedium(context),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Worker Dashboard',
                            style: TextStyle(
                              fontSize: ResponsiveTypography.bodyText1(context),
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Categories list
                Expanded(
                  child: ListView.builder(
                    padding: ResponsiveSpacing.all(context, 8),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Advanced3DCard(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          backgroundColor: isSelected 
                              ? SparshTheme.primaryBlue.withOpacity(0.1)
                              : SparshTheme.cardBackground,
                          borderRadius: 12,
                          enableGlassMorphism: true,
                          child: Padding(
                            padding: ResponsiveSpacing.all(context, 16),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? SparshTheme.primaryBlue
                                        : SparshTheme.primaryBlue.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getCategoryIcon(category),
                                    color: isSelected ? Colors.white : SparshTheme.primaryBlue,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      fontSize: ResponsiveTypography.bodyText1(context),
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected 
                                          ? SparshTheme.primaryBlue 
                                          : SparshTheme.textPrimary,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: SparshTheme.primaryBlue,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Logout option
                Padding(
                  padding: ResponsiveSpacing.all(context, 8),
                  child: Advanced3DCard(
                    onTap: _logout,
                    backgroundColor: Colors.red.withOpacity(0.1),
                    borderRadius: 12,
                    enableGlassMorphism: true,
                    child: Padding(
                      padding: ResponsiveSpacing.all(context, 16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.logout,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: ResponsiveTypography.bodyText1(context),
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Accounts':
        return Icons.account_balance;
      case 'HR&Admin':
        return Icons.admin_panel_settings;
      case 'General':
        return Icons.info;
      case 'Personnel':
        return Icons.people;
      case 'Employee':
        return Icons.person;
      default:
        return Icons.category;
    }
  }
}
