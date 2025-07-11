import 'package:flutter/material.dart';
import 'package:learning2/core/components/advanced_3d/advanced_3d_components.dart';
import 'package:learning2/core/utils/responsive_design.dart';
import 'package:learning2/core/utils/form_validators/form_validators.dart';
import 'package:learning2/core/theme/app_theme.dart';

class TelephoneDirectory extends StatefulWidget {
  const TelephoneDirectory({super.key});

  @override
  State<TelephoneDirectory> createState() => _TelephoneDirectoryState();
}

class _TelephoneDirectoryState extends State<TelephoneDirectory>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final List<Contact> _contacts = [
    Contact(name: 'HR Department', phone: '+91 98765 43210', department: 'Human Resources'),
    Contact(name: 'IT Support', phone: '+91 98765 43211', department: 'Information Technology'),
    Contact(name: 'Admin Office', phone: '+91 98765 43212', department: 'Administration'),
    Contact(name: 'Security Desk', phone: '+91 98765 43213', department: 'Security'),
    Contact(name: 'Reception', phone: '+91 98765 43214', department: 'Front Desk'),
    Contact(name: 'Manager Office', phone: '+91 98765 43215', department: 'Management'),
  ];

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

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
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
      appBar: Advanced3DAppBar(
        title: 'Telephone Directory',
        centerTitle: true,
        backgroundColor: SparshTheme.primaryBlue,
        elevation: 8,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: SingleChildScrollView(
                padding: ResponsiveSpacing.all(context, 16),
                child: Column(
                  children: [
                    // Header Card
                    Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Advanced3DCard(
                        width: ResponsiveUtil.getScreenWidth(context),
                        padding: ResponsiveSpacing.all(context, 20),
                        borderRadius: 20,
                        enableGlassMorphism: true,
                        backgroundColor: SparshTheme.cardBackground,
                        child: Column(
                          children: [
                            Icon(
                              Icons.contact_phone_outlined,
                              size: 48,
                              color: SparshTheme.primaryBlue,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Telephone Directory',
                              style: TextStyle(
                                fontSize: ResponsiveTypography.headingLarge(context),
                                fontWeight: FontWeight.bold,
                                color: SparshTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Important contact numbers and departments',
                              style: TextStyle(
                                fontSize: ResponsiveTypography.bodyText1(context),
                                color: SparshTheme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Contacts List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _contacts.length,
                      itemBuilder: (context, index) {
                        final contact = _contacts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Advanced3DCard(
                            onTap: () {
                              // TODO: Implement call functionality
                            },
                            backgroundColor: SparshTheme.cardBackground,
                            borderRadius: 16,
                            enableGlassMorphism: true,
                            child: Padding(
                              padding: ResponsiveSpacing.all(context, 16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: SparshTheme.primaryBlue.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.phone,
                                      color: SparshTheme.primaryBlue,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          contact.name,
                                          style: TextStyle(
                                            fontSize: ResponsiveTypography.bodyText1(context),
                                            fontWeight: FontWeight.bold,
                                            color: SparshTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          contact.department,
                                          style: TextStyle(
                                            fontSize: ResponsiveTypography.bodyText2(context),
                                            color: SparshTheme.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          contact.phone,
                                          style: TextStyle(
                                            fontSize: ResponsiveTypography.bodyText1(context),
                                            fontWeight: FontWeight.w600,
                                            color: SparshTheme.primaryBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Advanced3DButton(
                                    onPressed: () {
                                      // TODO: Implement call functionality
                                    },
                                    backgroundColor: SparshTheme.primaryBlue,
                                    foregroundColor: Colors.white,
                                    padding: ResponsiveSpacing.all(context, 12),
                                    borderRadius: 8,
                                    child: Icon(Icons.call, size: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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

class Contact {
  final String name;
  final String phone;
  final String department;

  Contact({
    required this.name,
    required this.phone,
    required this.department,
  });
}
