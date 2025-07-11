import 'package:flutter/material.dart';
import 'package:learning2/features/dashboard/presentation/pages/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:learning2/core/constants/fonts.dart';
import 'package:learning2/core/theme/app_theme.dart';
import 'package:learning2/core/components/advanced_3d/advanced_3d_components.dart';
import 'package:learning2/core/utils/responsive_design.dart';
import 'package:learning2/core/utils/form_validators/form_validators.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => NotificationProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPARSH Notifications',
      theme: SparshTheme.lightTheme,
      home: const NotificationScreen(),
    );
  }
}

class NotificationProvider extends ChangeNotifier {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      icon: Icons.check,
      message: 'Your order #12345 has been confirmed and is being processed.',
      status: 'Completed',
      statusColor: Colors.green,
      iconColor: Colors.green[800]!,
      iconBgColor: Colors.green[100]!,
      date: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    NotificationItem(
      icon: Icons.currency_rupee,
      message: 'Payment of ₹1,500 has been processed successfully.',
      status: 'Completed',
      statusColor: Colors.green,
      iconColor: Colors.green[800]!,
      iconBgColor: Colors.green[100]!,
      date: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationItem(
      icon: Icons.discount,
      message: 'Special 20% discount on all electronics. Limited time offer!',
      status: 'Cancelled',
      statusColor: Colors.red,
      iconColor: Colors.red[800]!,
      iconBgColor: Colors.red[100]!,
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NotificationItem(
      icon: Icons.local_shipping,
      message: 'Your package is out for delivery.',
      status: 'In Progress',
      statusColor: Colors.blue,
      iconColor: Colors.blue[800]!,
      iconBgColor: Colors.blue[100]!,
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
    NotificationItem(
      icon: Icons.person,
      message: 'Your profile has been successfully updated.',
      status: 'In Progress',
      statusColor: Colors.blue,
      iconColor: Colors.blue[800]!,
      iconBgColor: Colors.blue[100]!,
      date: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  List<NotificationItem> get notifications => _notifications;

  void addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void addFirebaseNotification(String? title, String? body) {
    if (title != null && body != null) {
      final notification = NotificationItem(
        icon: Icons.notifications,
        message: '$title: $body',
        status: 'New',
        statusColor: Colors.blue,
        iconColor: Colors.blue[800]!,
        iconBgColor: Colors.blue[100]!,
        date: DateTime.now(),
      );
      addNotification(notification);
    }
  }
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with TickerProviderStateMixin {
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
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final notifications = notificationProvider.notifications;

    return Scaffold(
      backgroundColor: SparshTheme.scaffoldBackground,
      appBar: Advanced3DAppBar(
        title: 'Notifications',
        centerTitle: true,
        backgroundColor: SparshTheme.primaryBlue,
        elevation: 8,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: () {
              // TODO: Mark all as read
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: More options
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
              child: notifications.isEmpty
                  ? _buildEmptyState()
                  : _buildNotificationsList(notifications),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Transform.scale(
        scale: _scaleAnimation.value,
        child: Advanced3DCard(
          padding: ResponsiveSpacing.all(context, 32),
          backgroundColor: SparshTheme.cardBackground,
          borderRadius: 20,
          enableGlassMorphism: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notifications_none,
                size: 64,
                color: SparshTheme.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'No notifications yet',
                style: TextStyle(
                  fontSize: ResponsiveTypography.headingMedium(context),
                  fontWeight: FontWeight.w600,
                  color: SparshTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'When you receive notifications, they\'ll appear here',
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
    );
  }

  Widget _buildNotificationsList(List<NotificationItem> notifications) {
    return SingleChildScrollView(
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
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    size: 32,
                    color: SparshTheme.primaryBlue,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: ResponsiveTypography.headingMedium(context),
                            fontWeight: FontWeight.bold,
                            color: SparshTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${notifications.length} ${notifications.length == 1 ? 'notification' : 'notifications'}',
                          style: TextStyle(
                            fontSize: ResponsiveTypography.bodyText1(context),
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
          const SizedBox(height: 24),
          
          // Notifications List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: NotificationCard(item: notifications[index]),
              );
            },
          ),
        ],
      ),
    );
  }
}

class NotificationItem {
  final IconData icon;
  final String message;
  final String status;
  final Color statusColor;
  final Color iconColor;
  final Color iconBgColor;
  final DateTime date;

  NotificationItem({
    required this.icon,
    required this.message,
    required this.status,
    required this.statusColor,
    required this.iconColor,
    required this.iconBgColor,
    required this.date,
  });
}

class NotificationCard extends StatelessWidget {
  final NotificationItem item;

  const NotificationCard({super.key, required this.item});

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Advanced3DCard(
      onTap: () {
        // TODO: Handle notification tap
      },
      borderRadius: 16,
      backgroundColor: SparshTheme.cardBackground,
      enableGlassMorphism: true,
      child: Padding(
        padding: ResponsiveSpacing.all(context, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.iconBgColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: item.iconColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(item.icon, color: item.iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.message,
                    style: TextStyle(
                      fontSize: ResponsiveTypography.bodyText1(context),
                      fontWeight: FontWeight.w500,
                      color: SparshTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: item.statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.status,
                          style: TextStyle(
                            fontSize: ResponsiveTypography.caption(context),
                            fontWeight: FontWeight.w600,
                            color: item.statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatDate(item.date),
                        style: TextStyle(
                          fontSize: ResponsiveTypography.caption(context),
                          color: SparshTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
