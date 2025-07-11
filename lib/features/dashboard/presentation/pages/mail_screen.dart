import 'package:flutter/material.dart';
import 'package:learning2/core/components/advanced_3d/advanced_3d_components.dart';
import 'package:learning2/core/utils/responsive_design.dart';
import 'package:learning2/core/utils/form_validators/form_validators.dart';
import 'package:learning2/core/theme/app_theme.dart';

class MailScreen extends StatefulWidget {
  const MailScreen({super.key});

  @override
  State<MailScreen> createState() => _MailScreenState();
}

class _MailScreenState extends State<MailScreen> with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SparshTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          'Mail',
          style: TextStyle(
            color: SparshTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: SparshTheme.cardBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: SparshTheme.primaryBlue),
      ),
      body: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: SingleChildScrollView(
                padding: ResponsiveSpacing.paddingMedium(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    Advanced3DCard(
                      padding: ResponsiveSpacing.paddingLarge(context),
                      backgroundColor: SparshTheme.cardBackground,
                      borderRadius: 20,
                      enableGlassMorphism: true,
                      child: Row(
                        children: [
                          Container(
                            padding: ResponsiveSpacing.paddingSmall(context),
                            decoration: BoxDecoration(
                              color: SparshTheme.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.mail_outline,
                              color: SparshTheme.primaryBlue,
                              size: ResponsiveUtil.scaledSize(context, 24),
                            ),
                          ),
                          SizedBox(width: ResponsiveSpacing.medium(context)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mail Center',
                                style: ResponsiveTypography.headlineSmall(context).copyWith(
                                  color: SparshTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Manage your communications',
                                style: ResponsiveTypography.bodyMedium(context).copyWith(
                                  color: SparshTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: ResponsiveSpacing.large(context)),
                    
                    // Coming Soon Card
                    Advanced3DCard(
                      padding: ResponsiveSpacing.paddingXLarge(context),
                      backgroundColor: SparshTheme.cardBackground,
                      borderRadius: 20,
                      enableGlassMorphism: true,
                      child: Column(
                        children: [
                          Container(
                            padding: ResponsiveSpacing.paddingLarge(context),
                            decoration: BoxDecoration(
                              color: SparshTheme.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.construction,
                              color: SparshTheme.primaryBlue,
                              size: ResponsiveUtil.scaledSize(context, 48),
                            ),
                          ),
                          SizedBox(height: ResponsiveSpacing.medium(context)),
                          Text(
                            'Coming Soon',
                            style: ResponsiveTypography.headlineMedium(context).copyWith(
                              color: SparshTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: ResponsiveSpacing.small(context)),
                          Text(
                            'Mail functionality is under development.\nWe\'re working hard to bring you the best mail experience.',
                            textAlign: TextAlign.center,
                            style: ResponsiveTypography.bodyLarge(context).copyWith(
                              color: SparshTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
