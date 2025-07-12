import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/components/advanced_3d_components.dart';
import '../../../../core/utils/responsive_util.dart';

class MailScreen extends StatefulWidget {
  const MailScreen({super.key});

  @override
  State<MailScreen> createState() => _MailScreenState();
}

class _MailScreenState extends State<MailScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final List<Mail> _mails = [
    Mail(
      id: '1',
      sender: 'HR Department',
      subject: 'Monthly Performance Review',
      body: 'Your performance review for this month has been scheduled. Please prepare your self-assessment.',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      priority: MailPriority.high,
    ),
    Mail(
      id: '2',
      sender: 'IT Support',
      subject: 'System Maintenance Notice',
      body: 'Scheduled maintenance will be performed on Sunday from 2 AM to 6 AM. Please save your work.',
      time: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
      priority: MailPriority.normal,
    ),
    Mail(
      id: '3',
      sender: 'Finance Team',
      subject: 'Expense Report Reminder',
      body: 'Please submit your expense reports for the current month by the end of this week.',
      time: DateTime.now().subtract(const Duration(days: 1)),
      isRead: false,
      priority: MailPriority.normal,
    ),
    Mail(
      id: '4',
      sender: 'Management',
      subject: 'New Policy Updates',
      body: 'Important policy updates have been released. Please review the attached documents.',
      time: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      priority: MailPriority.high,
    ),
    Mail(
      id: '5',
      sender: 'Training Department',
      subject: 'Upcoming Training Session',
      body: 'Register for the upcoming skill development training session scheduled for next week.',
      time: DateTime.now().subtract(const Duration(days: 3)),
      isRead: false,
      priority: MailPriority.low,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SparshTheme.scaffoldBackground,
      appBar: Advanced3DAppBar(
        title: Text(
          'Mail',
          style: SparshTypography.heading5.copyWith(color: Colors.white),
        ),
        backgroundColor: SparshTheme.primaryBlue,
        enableGlassMorphism: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Compose mail feature coming soon!')),
              );
            },
            icon: const Icon(Icons.edit, color: Colors.white),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildMailStats(),
            Expanded(
              child: _buildMailList(),
            ),
          ],
        ),
      ),
      floatingActionButton: Advanced3DFloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Compose mail feature coming soon!')),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: SparshTheme.primaryBlue,
      ),
    );
  }

  Widget _buildMailStats() {
    final unreadCount = _mails.where((mail) => !mail.isRead).length;
    final highPriorityCount = _mails.where((mail) => mail.priority == MailPriority.high).length;
    
    return Advanced3DCard(
      enableGlassMorphism: false,
      backgroundColor: SparshTheme.primaryBlue.withOpacity(0.1),
      margin: ResponsiveUtil.scaledPadding(context, all: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total Mails',
              '${_mails.length}',
              Icons.mail,
              SparshTheme.primaryBlue,
            ),
          ),
          Container(
            height: ResponsiveUtil.scaledSize(context, 40),
            width: 1,
            color: SparshTheme.borderGrey,
          ),
          Expanded(
            child: _buildStatItem(
              'Unread',
              '$unreadCount',
              Icons.mark_email_unread,
              SparshTheme.warningOrange,
            ),
          ),
          Container(
            height: ResponsiveUtil.scaledSize(context, 40),
            width: 1,
            color: SparshTheme.borderGrey,
          ),
          Expanded(
            child: _buildStatItem(
              'High Priority',
              '$highPriorityCount',
              Icons.priority_high,
              SparshTheme.errorRed,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: ResponsiveUtil.scaledSize(context, 24)),
        SizedBox(height: ResponsiveUtil.scaledSize(context, 8)),
        Text(
          value,
          style: SparshTypography.heading6.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: ResponsiveUtil.scaledSize(context, 4)),
        Text(
          label,
          style: SparshTypography.bodySmall.copyWith(
            color: SparshTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMailList() {
    return ListView.builder(
      padding: ResponsiveUtil.scaledPadding(context, horizontal: 16),
      itemCount: _mails.length,
      itemBuilder: (context, index) {
        final mail = _mails[index];
        return _buildMailItem(mail, index);
      },
    );
  }

  Widget _buildMailItem(Mail mail, int index) {
    return Advanced3DCard(
      enableGlassMorphism: false,
      backgroundColor: mail.isRead ? SparshTheme.cardBackground : SparshTheme.lightBlueBackground,
      margin: ResponsiveUtil.scaledPadding(context, vertical: 8),
      onTap: () {
        setState(() {
          mail.isRead = true;
        });
        _showMailDetails(mail);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: ResponsiveUtil.scaledSize(context, 4),
            height: ResponsiveUtil.scaledSize(context, 60),
            decoration: BoxDecoration(
              color: _getPriorityColor(mail.priority),
              borderRadius: BorderRadius.circular(SparshBorderRadius.xs),
            ),
          ),
          SizedBox(width: ResponsiveUtil.scaledSize(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (!mail.isRead)
                      Container(
                        width: ResponsiveUtil.scaledSize(context, 8),
                        height: ResponsiveUtil.scaledSize(context, 8),
                        margin: ResponsiveUtil.scaledPadding(context, right: 8),
                        decoration: BoxDecoration(
                          color: SparshTheme.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        mail.sender,
                        style: SparshTypography.bodyBold.copyWith(
                          color: SparshTheme.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      _formatTime(mail.time),
                      style: SparshTypography.bodySmall.copyWith(
                        color: SparshTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveUtil.scaledSize(context, 4)),
                Text(
                  mail.subject,
                  style: SparshTypography.bodyMedium.copyWith(
                    color: SparshTheme.textPrimary,
                    fontWeight: mail.isRead ? FontWeight.normal : FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: ResponsiveUtil.scaledSize(context, 4)),
                Text(
                  mail.body,
                  style: SparshTypography.bodySmall.copyWith(
                    color: SparshTheme.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: ResponsiveUtil.scaledSize(context, 8)),
          Icon(
            Icons.chevron_right,
            color: SparshTheme.textTertiary,
            size: ResponsiveUtil.scaledSize(context, 20),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: (index * 100).ms).slideX(begin: 0.2);
  }

  void _showMailDetails(Mail mail) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SparshBorderRadius.lg),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          padding: ResponsiveUtil.scaledPadding(context, all: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: ResponsiveUtil.scaledSize(context, 4),
                    height: ResponsiveUtil.scaledSize(context, 40),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(mail.priority),
                      borderRadius: BorderRadius.circular(SparshBorderRadius.xs),
                    ),
                  ),
                  SizedBox(width: ResponsiveUtil.scaledSize(context, 16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mail.sender,
                          style: SparshTypography.bodyBold.copyWith(
                            color: SparshTheme.textPrimary,
                          ),
                        ),
                        Text(
                          _formatTime(mail.time),
                          style: SparshTypography.bodySmall.copyWith(
                            color: SparshTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: SparshTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
              Text(
                mail.subject,
                style: SparshTypography.heading6.copyWith(
                  color: SparshTheme.textPrimary,
                ),
              ),
              SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    mail.body,
                    style: SparshTypography.bodyMedium.copyWith(
                      color: SparshTheme.textPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reply feature coming soon!')),
                        );
                      },
                      icon: const Icon(Icons.reply),
                      label: const Text('Reply'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SparshTheme.primaryBlue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveUtil.scaledSize(context, 16)),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Forward feature coming soon!')),
                        );
                      },
                      icon: const Icon(Icons.forward),
                      label: const Text('Forward'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: SparshTheme.primaryBlue,
                        side: BorderSide(color: SparshTheme.primaryBlue),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(MailPriority priority) {
    switch (priority) {
      case MailPriority.high:
        return SparshTheme.errorRed;
      case MailPriority.normal:
        return SparshTheme.primaryBlue;
      case MailPriority.low:
        return SparshTheme.successGreen;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class Mail {
  final String id;
  final String sender;
  final String subject;
  final String body;
  final DateTime time;
  bool isRead;
  final MailPriority priority;

  Mail({
    required this.id,
    required this.sender,
    required this.subject,
    required this.body,
    required this.time,
    required this.isRead,
    required this.priority,
  });
}

enum MailPriority { high, normal, low }
