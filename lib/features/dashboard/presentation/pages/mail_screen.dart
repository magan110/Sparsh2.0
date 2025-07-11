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

class _MailScreenState extends State<MailScreen>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  List<MailItem> _mailItems = [
    MailItem(
      sender: "Admin",
      subject: "Welcome to Sparsh 2.0",
      preview: "Thank you for using our application...",
      time: "2 hours ago",
      isUnread: true,
    ),
    MailItem(
      sender: "HR Department",
      subject: "Policy Update",
      preview: "Please review the updated company policies...",
      time: "1 day ago",
      isUnread: false,
    ),
    MailItem(
      sender: "IT Support",
      subject: "System Maintenance",
      preview: "Scheduled maintenance on Sunday...",
      time: "2 days ago",
      isUnread: false,
    ),
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
        title: 'Mail',
        centerTitle: true,
        backgroundColor: SparshTheme.primaryBlue,
        elevation: 8,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Implement more options
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
                              Icons.mail_outline,
                              size: 48,
                              color: SparshTheme.primaryBlue,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Mail Center',
                              style: TextStyle(
                                fontSize: ResponsiveTypography.headingLarge(context),
                                fontWeight: FontWeight.bold,
                                color: SparshTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Manage your messages and communications',
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
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: Advanced3DButton(
                            onPressed: () {
                              // TODO: Implement compose functionality
                            },
                            backgroundColor: SparshTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: ResponsiveSpacing.symmetric(
                              context, 
                              horizontal: 16, 
                              vertical: 12
                            ),
                            borderRadius: 12,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.edit, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Compose',
                                  style: TextStyle(
                                    fontSize: ResponsiveTypography.bodyText1(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Advanced3DButton(
                            onPressed: () {
                              // TODO: Implement refresh functionality
                            },
                            backgroundColor: SparshTheme.cardBackground,
                            foregroundColor: SparshTheme.primaryBlue,
                            padding: ResponsiveSpacing.symmetric(
                              context, 
                              horizontal: 16, 
                              vertical: 12
                            ),
                            borderRadius: 12,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.refresh, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Refresh',
                                  style: TextStyle(
                                    fontSize: ResponsiveTypography.bodyText1(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Mail List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _mailItems.length,
                      itemBuilder: (context, index) {
                        final mail = _mailItems[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Advanced3DCard(
                            onTap: () {
                              // TODO: Navigate to mail detail
                            },
                            backgroundColor: mail.isUnread 
                                ? SparshTheme.cardBackground 
                                : SparshTheme.scaffoldBackground,
                            borderRadius: 16,
                            enableGlassMorphism: true,
                            child: Padding(
                              padding: ResponsiveSpacing.all(context, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: SparshTheme.primaryBlue.withOpacity(0.1),
                                        child: Text(
                                          mail.sender[0].toUpperCase(),
                                          style: TextStyle(
                                            color: SparshTheme.primaryBlue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              mail.sender,
                                              style: TextStyle(
                                                fontSize: ResponsiveTypography.bodyText1(context),
                                                fontWeight: mail.isUnread 
                                                    ? FontWeight.bold 
                                                    : FontWeight.w600,
                                                color: SparshTheme.textPrimary,
                                              ),
                                            ),
                                            Text(
                                              mail.time,
                                              style: TextStyle(
                                                fontSize: ResponsiveTypography.caption(context),
                                                color: SparshTheme.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (mail.isUnread)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: SparshTheme.primaryBlue,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    mail.subject,
                                    style: TextStyle(
                                      fontSize: ResponsiveTypography.bodyText1(context),
                                      fontWeight: mail.isUnread 
                                          ? FontWeight.bold 
                                          : FontWeight.w600,
                                      color: SparshTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    mail.preview,
                                    style: TextStyle(
                                      fontSize: ResponsiveTypography.bodyText2(context),
                                      color: SparshTheme.textSecondary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
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

class MailItem {
  final String sender;
  final String subject;
  final String preview;
  final String time;
  final bool isUnread;

  MailItem({
    required this.sender,
    required this.subject,
    required this.preview,
    required this.time,
    required this.isUnread,
  });
}
