import 'package:flutter/material.dart';
import 'package:learning2/core/theme/app_theme.dart';
import 'package:learning2/core/utils/responsive_util.dart';
import 'package:learning2/presentation/widgets/advanced_3d_components.dart';
import 'package:learning2/presentation/animations/advanced_animations.dart';
import 'package:google_fonts/google_fonts.dart';

class MailScreen extends StatefulWidget {
  const MailScreen({super.key});

  @override
  State<MailScreen> createState() => _MailScreenState();
}

class _MailScreenState extends State<MailScreen> with TickerProviderStateMixin {
  final List<EmailMessage> _emails = [
    EmailMessage(
      id: '1',
      sender: 'John Doe',
      senderEmail: 'john.doe@company.com',
      subject: 'Project Update - Q4 Sales Report',
      preview: 'Hi team, I wanted to share the latest updates on our Q4 sales performance. The numbers look promising...',
      time: '2:30 PM',
      isRead: false,
      isImportant: true,
      hasAttachment: true,
      category: EmailCategory.work,
    ),
    EmailMessage(
      id: '2',
      sender: 'HR Department',
      senderEmail: 'hr@company.com',
      subject: 'New Employee Onboarding Schedule',
      preview: 'Please find attached the onboarding schedule for new employees starting next week. Review and confirm...',
      time: '1:15 PM',
      isRead: true,
      isImportant: false,
      hasAttachment: true,
      category: EmailCategory.work,
    ),
    EmailMessage(
      id: '3',
      sender: 'Marketing Team',
      senderEmail: 'marketing@company.com',
      subject: 'Campaign Performance Analytics',
      preview: 'The latest campaign has shown excellent results with a 15% increase in engagement. Here are the details...',
      time: '11:45 AM',
      isRead: false,
      isImportant: false,
      hasAttachment: false,
      category: EmailCategory.marketing,
    ),
    EmailMessage(
      id: '4',
      sender: 'IT Support',
      senderEmail: 'support@company.com',
      subject: 'System Maintenance Notice',
      preview: 'Scheduled maintenance will be performed on all servers this weekend. Please save your work and log out...',
      time: '10:20 AM',
      isRead: true,
      isImportant: true,
      hasAttachment: false,
      category: EmailCategory.system,
    ),
    EmailMessage(
      id: '5',
      sender: 'Finance Team',
      senderEmail: 'finance@company.com',
      subject: 'Monthly Budget Review',
      preview: 'The monthly budget review meeting is scheduled for Friday at 3 PM. Please prepare your departmental reports...',
      time: '9:00 AM',
      isRead: false,
      isImportant: false,
      hasAttachment: true,
      category: EmailCategory.finance,
    ),
  ];

  EmailCategory _selectedCategory = EmailCategory.all;
  String _searchQuery = '';
  EmailMessage? _selectedEmail;

  @override
  Widget build(BuildContext context) {
    ResponsiveUtil.init(context);
    
    return Scaffold(
      backgroundColor: SparshTheme.scaffoldBackground,
      appBar: const Advanced3DAppBar(
        title: Text(
          'Mail',
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
            if (screenType == ScreenType.desktop) {
              return _buildDesktopLayout();
            } else {
              return _buildMobileLayout();
            }
          },
        ),
      ),
      floatingActionButton: Advanced3DFloatingActionButton(
        onPressed: () {
          // Handle compose new email
        },
        child: const Icon(Icons.edit, color: Colors.white),
        gradient: SparshTheme.primaryGradient,
        enablePulse: true,
        enableGlow: true,
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Email list panel
        Expanded(
          flex: 2,
          child: _buildEmailList(),
        ),
        // Divider
        Container(
          width: 1,
          color: SparshTheme.borderGrey,
        ),
        // Email viewer panel
        Expanded(
          flex: 3,
          child: _selectedEmail != null
              ? _buildEmailViewer(_selectedEmail!)
              : _buildEmptyEmailViewer(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return _selectedEmail != null
        ? _buildEmailViewer(_selectedEmail!)
        : _buildEmailList();
  }

  Widget _buildEmailList() {
    final filteredEmails = _getFilteredEmails();
    
    return Column(
      children: [
        _buildSearchAndFilters(),
        Expanded(
          child: AdvancedStaggeredAnimation(
            duration: const Duration(milliseconds: 300),
            delay: const Duration(milliseconds: 100),
            children: [
              ...filteredEmails.map((email) => _buildEmailListItem(email)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Advanced3DCard(
      enableGlassMorphism: false,
      enableHover: false,
      enable3DTransform: false,
      elevation: 4,
      borderRadius: 16,
      backgroundColor: Colors.white,
      padding: ResponsiveUtil.scaledPadding(context, all: 16),
      margin: ResponsiveUtil.scaledPadding(context, all: 16),
      child: Column(
        children: [
          // Search bar
          AdvancedAnimatedContainer(
            duration: const Duration(milliseconds: 300),
            enableHover: true,
            enableScale: true,
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search emails...',
                prefixIcon: Advanced3DTransform(
                  enableAnimation: true,
                  rotationY: 0.1,
                  child: Icon(Icons.search, color: SparshTheme.primaryBlue),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: SparshTheme.borderGrey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: SparshTheme.borderGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: SparshTheme.primaryBlue, width: 2),
                ),
                filled: true,
                fillColor: SparshTheme.lightBlueBackground,
              ),
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                color: SparshTheme.textPrimary,
              ),
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaledHeight(context, 16)),
          // Category filters
          ResponsiveGrid(
            mobileColumns: 2,
            tabletColumns: 3,
            desktopColumns: 6,
            spacing: 8,
            runSpacing: 8,
            children: EmailCategory.values.map((category) {
              final isSelected = _selectedCategory == category;
              return AdvancedAnimatedContainer(
                duration: const Duration(milliseconds: 300),
                enableHover: true,
                enableScale: true,
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                padding: ResponsiveUtil.scaledPadding(context, horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? SparshTheme.primaryGradient
                      : null,
                  color: isSelected
                      ? null
                      : SparshTheme.borderLightGrey,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? SparshTheme.primaryBlue
                        : SparshTheme.borderGrey,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      size: ResponsiveUtil.getIconSize(context, 16),
                      color: isSelected ? Colors.white : SparshTheme.textSecondary,
                    ),
                    SizedBox(width: ResponsiveUtil.scaledWidth(context, 4)),
                    Text(
                      _getCategoryName(category),
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : SparshTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailListItem(EmailMessage email) {
    return Advanced3DListTile(
      leading: _buildEmailAvatar(email),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  email.sender,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtil.scaledFontSize(context, 16),
                    fontWeight: email.isRead ? FontWeight.w500 : FontWeight.w600,
                    color: SparshTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                email.time,
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                  color: SparshTheme.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaledHeight(context, 4)),
          Text(
            email.subject,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtil.scaledFontSize(context, 14),
              fontWeight: email.isRead ? FontWeight.w400 : FontWeight.w500,
              color: SparshTheme.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: ResponsiveUtil.scaledHeight(context, 2)),
          Text(
            email.preview,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtil.scaledFontSize(context, 12),
              color: SparshTheme.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (email.isImportant)
            Icon(
              Icons.star,
              color: SparshTheme.warningOrange,
              size: ResponsiveUtil.getIconSize(context, 16),
            ),
          if (email.hasAttachment)
            Icon(
              Icons.attach_file,
              color: SparshTheme.textSecondary,
              size: ResponsiveUtil.getIconSize(context, 16),
            ),
          if (!email.isRead)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: SparshTheme.primaryBlue,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      onTap: () {
        setState(() {
          _selectedEmail = email;
          // Mark as read
          email.isRead = true;
        });
      },
      enableHover: true,
      enable3DTransform: true,
      backgroundColor: email.isRead ? Colors.white : SparshTheme.lightBlueBackground,
    );
  }

  Widget _buildEmailAvatar(EmailMessage email) {
    return Advanced3DTransform(
      enableAnimation: true,
      rotationY: 0.1,
      child: Container(
        width: ResponsiveUtil.scaledSize(context, 48),
        height: ResponsiveUtil.scaledSize(context, 48),
        decoration: BoxDecoration(
          gradient: _getCategoryGradient(email.category),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            email.sender.substring(0, 2).toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtil.scaledFontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailViewer(EmailMessage email) {
    return Advanced3DCard(
      enableGlassMorphism: false,
      enableHover: false,
      enable3DTransform: false,
      elevation: 8,
      borderRadius: 16,
      backgroundColor: Colors.white,
      padding: ResponsiveUtil.scaledPadding(context, all: 24),
      margin: ResponsiveUtil.scaledPadding(context, all: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email header
          Row(
            children: [
              if (ResponsiveUtil.isMobile(context))
                AdvancedAnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  enableHover: true,
                  enableScale: true,
                  onTap: () {
                    setState(() {
                      _selectedEmail = null;
                    });
                  },
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: SparshTheme.borderLightGrey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: SparshTheme.textPrimary,
                    size: ResponsiveUtil.getIconSize(context, 20),
                  ),
                ),
              if (ResponsiveUtil.isMobile(context))
                SizedBox(width: ResponsiveUtil.scaledWidth(context, 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      email.subject,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtil.scaledFontSize(context, 20),
                        fontWeight: FontWeight.w600,
                        color: SparshTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtil.scaledHeight(context, 8)),
                    Row(
                      children: [
                        _buildEmailAvatar(email),
                        SizedBox(width: ResponsiveUtil.scaledWidth(context, 12)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                email.sender,
                                style: GoogleFonts.poppins(
                                  fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                                  fontWeight: FontWeight.w500,
                                  color: SparshTheme.textPrimary,
                                ),
                              ),
                              Text(
                                email.senderEmail,
                                style: GoogleFonts.poppins(
                                  fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                                  color: SparshTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          email.time,
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveUtil.scaledFontSize(context, 12),
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
          SizedBox(height: ResponsiveUtil.scaledHeight(context, 24)),
          Container(
            height: 1,
            color: SparshTheme.borderGrey,
          ),
          SizedBox(height: ResponsiveUtil.scaledHeight(context, 24)),
          // Email content
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                _getEmailContent(email),
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                  color: SparshTheme.textPrimary,
                  height: 1.6,
                ),
              ),
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaledHeight(context, 24)),
          // Action buttons
          Row(
            children: [
              _buildActionButton(
                icon: Icons.reply,
                label: 'Reply',
                onTap: () {
                  // Handle reply
                },
              ),
              SizedBox(width: ResponsiveUtil.scaledWidth(context, 12)),
              _buildActionButton(
                icon: Icons.reply_all,
                label: 'Reply All',
                onTap: () {
                  // Handle reply all
                },
              ),
              SizedBox(width: ResponsiveUtil.scaledWidth(context, 12)),
              _buildActionButton(
                icon: Icons.forward,
                label: 'Forward',
                onTap: () {
                  // Handle forward
                },
              ),
              const Spacer(),
              _buildActionButton(
                icon: Icons.delete,
                label: 'Delete',
                color: SparshTheme.errorRed,
                onTap: () {
                  // Handle delete
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyEmailViewer() {
    return Advanced3DCard(
      enableGlassMorphism: false,
      enableHover: false,
      enable3DTransform: false,
      elevation: 8,
      borderRadius: 16,
      backgroundColor: Colors.white,
      padding: ResponsiveUtil.scaledPadding(context, all: 24),
      margin: ResponsiveUtil.scaledPadding(context, all: 16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Advanced3DTransform(
              enableAnimation: true,
              rotationY: 0.1,
              child: Icon(
                Icons.mail_outline,
                size: ResponsiveUtil.getIconSize(context, 80),
                color: SparshTheme.textTertiary,
              ),
            ),
            SizedBox(height: ResponsiveUtil.scaledHeight(context, 16)),
            Text(
              'Select an email to view',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtil.scaledFontSize(context, 18),
                fontWeight: FontWeight.w500,
                color: SparshTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return AdvancedAnimatedContainer(
      duration: const Duration(milliseconds: 300),
      enableHover: true,
      enableScale: true,
      onTap: onTap,
      padding: ResponsiveUtil.scaledPadding(context, horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: (color ?? SparshTheme.primaryBlue).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (color ?? SparshTheme.primaryBlue).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: ResponsiveUtil.getIconSize(context, 16),
            color: color ?? SparshTheme.primaryBlue,
          ),
          SizedBox(width: ResponsiveUtil.scaledWidth(context, 4)),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtil.scaledFontSize(context, 12),
              fontWeight: FontWeight.w500,
              color: color ?? SparshTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  List<EmailMessage> _getFilteredEmails() {
    var filtered = _emails.where((email) {
      final matchesCategory = _selectedCategory == EmailCategory.all || email.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          email.sender.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          email.subject.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          email.preview.toLowerCase().contains(_searchQuery.toLowerCase());
      
      return matchesCategory && matchesSearch;
    }).toList();
    
    return filtered;
  }

  String _getCategoryName(EmailCategory category) {
    switch (category) {
      case EmailCategory.all:
        return 'All';
      case EmailCategory.work:
        return 'Work';
      case EmailCategory.marketing:
        return 'Marketing';
      case EmailCategory.system:
        return 'System';
      case EmailCategory.finance:
        return 'Finance';
    }
  }

  IconData _getCategoryIcon(EmailCategory category) {
    switch (category) {
      case EmailCategory.all:
        return Icons.all_inbox;
      case EmailCategory.work:
        return Icons.work;
      case EmailCategory.marketing:
        return Icons.campaign;
      case EmailCategory.system:
        return Icons.settings;
      case EmailCategory.finance:
        return Icons.monetization_on;
    }
  }

  LinearGradient _getCategoryGradient(EmailCategory category) {
    switch (category) {
      case EmailCategory.all:
        return SparshTheme.primaryGradient;
      case EmailCategory.work:
        return SparshTheme.blueAccentGradient;
      case EmailCategory.marketing:
        return SparshTheme.orangeGradient;
      case EmailCategory.system:
        return SparshTheme.greenGradient;
      case EmailCategory.finance:
        return SparshTheme.redGradient;
    }
  }

  String _getEmailContent(EmailMessage email) {
    // Mock email content
    return '''
Dear Team,

${email.preview}

This is an extended version of the email content that provides more details about the subject matter. The email contains comprehensive information that would be useful for the recipient to understand the full context of the message.

Key points covered in this email:
• Important updates and announcements
• Action items that need to be completed
• Timeline and deadlines for deliverables
• Contact information for follow-up questions

Please review this information carefully and let me know if you have any questions or concerns. I'm available to discuss any aspects of this email in more detail.

Best regards,
${email.sender}
${email.senderEmail}

---
This email is confidential and may contain proprietary information. If you are not the intended recipient, please notify the sender immediately and delete this email.
''';
  }
}

// Data models
class EmailMessage {
  final String id;
  final String sender;
  final String senderEmail;
  final String subject;
  final String preview;
  final String time;
  bool isRead;
  final bool isImportant;
  final bool hasAttachment;
  final EmailCategory category;

  EmailMessage({
    required this.id,
    required this.sender,
    required this.senderEmail,
    required this.subject,
    required this.preview,
    required this.time,
    required this.isRead,
    required this.isImportant,
    required this.hasAttachment,
    required this.category,
  });
}

enum EmailCategory {
  all,
  work,
  marketing,
  system,
  finance,
}
