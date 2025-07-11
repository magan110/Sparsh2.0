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

class _NotificationScreenState extends State<NotificationScreen> with TickerProviderStateMixin {
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
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final notifications = notificationProvider.notifications;

    return Scaffold(
      backgroundColor: SparshTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: ResponsiveTypography.titleLarge(context).copyWith(
            color: SparshTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: SparshTheme.cardBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: SparshTheme.primaryBlue),
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
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
      child: Advanced3DCard(
        margin: ResponsiveSpacing.paddingLarge(context),
        padding: ResponsiveSpacing.paddingXLarge(context),
        backgroundColor: SparshTheme.cardBackground,
        borderRadius: 20,
        enableGlassMorphism: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: ResponsiveSpacing.paddingLarge(context),
              decoration: BoxDecoration(
                color: SparshTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.notifications_none,
                color: SparshTheme.primaryBlue,
                size: ResponsiveUtil.scaledSize(context, 48),
              ),
            ),
            SizedBox(height: ResponsiveSpacing.medium(context)),
            Text(
              'No Notifications',
              style: ResponsiveTypography.headlineSmall(context).copyWith(
                color: SparshTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ResponsiveSpacing.small(context)),
            Text(
              'You\'re all caught up! No new notifications yet.',
              textAlign: TextAlign.center,
              style: ResponsiveTypography.bodyMedium(context).copyWith(
                color: SparshTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationItem> notifications) {
    return ListView.builder(
      padding: ResponsiveSpacing.paddingMedium(context),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            final delay = index * 0.1;
            final animationValue = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: _animController,
                curve: Interval(
                  delay,
                  (delay + 0.5).clamp(0.0, 1.0),
                  curve: Curves.easeOutCubic,
                ),
              ),
            );
            
            return FadeTransition(
              opacity: animationValue,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - animationValue.value)),
                child: NotificationCard(item: notifications[index]),
              ),
            );
          },
        );
      },
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
      margin: EdgeInsets.only(bottom: ResponsiveSpacing.medium(context)),
      padding: ResponsiveSpacing.paddingLarge(context),
      backgroundColor: SparshTheme.cardBackground,
      borderRadius: 16,
      enableGlassMorphism: true,
      enableHoverEffect: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: ResponsiveUtil.scaledSize(context, 48),
            height: ResponsiveUtil.scaledSize(context, 48),
            decoration: BoxDecoration(
              color: item.iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              color: item.iconColor,
              size: ResponsiveUtil.scaledSize(context, 24),
            ),
          ),
          SizedBox(width: ResponsiveSpacing.medium(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.message,
                  style: ResponsiveTypography.bodyLarge(context).copyWith(
                    color: SparshTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: ResponsiveSpacing.small(context)),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveSpacing.small(context),
                        vertical: ResponsiveSpacing.small(context) / 2,
                      ),
                      decoration: BoxDecoration(
                        color: item.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: item.statusColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        item.status,
                        style: ResponsiveTypography.bodySmall(context).copyWith(
                          color: item.statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: ResponsiveSpacing.small(context)),
                    Text(
                      _formatDate(item.date),
                      style: ResponsiveTypography.bodySmall(context).copyWith(
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
    );
  }
}
