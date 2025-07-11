import 'package:flutter/material.dart';
import 'package:learning2/core/components/advanced_3d/advanced_3d_components.dart';
import 'package:learning2/core/utils/responsive_design.dart';
import 'package:learning2/core/utils/form_validators/form_validators.dart';
import 'package:learning2/core/theme/app_theme.dart';

class WorkerAttendence extends StatefulWidget {
  const WorkerAttendence({super.key});

  @override
  State<WorkerAttendence> createState() => _WorkerAttendenceState();
}

class _WorkerAttendenceState extends State<WorkerAttendence>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _isCheckedIn = false;
  String _currentStatus = 'Checked Out';
  String _checkInTime = '--:--';
  String _checkOutTime = '--:--';
  String _totalHours = '0h 0m';

  List<AttendanceRecord> _attendanceHistory = [
    AttendanceRecord(
      date: DateTime.now().subtract(const Duration(days: 1)),
      checkIn: '09:00 AM',
      checkOut: '05:30 PM',
      totalHours: '8h 30m',
      status: 'Present',
    ),
    AttendanceRecord(
      date: DateTime.now().subtract(const Duration(days: 2)),
      checkIn: '09:15 AM',
      checkOut: '05:45 PM',
      totalHours: '8h 30m',
      status: 'Present',
    ),
    AttendanceRecord(
      date: DateTime.now().subtract(const Duration(days: 3)),
      checkIn: '--:--',
      checkOut: '--:--',
      totalHours: '0h 0m',
      status: 'Absent',
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

  void _toggleAttendance() {
    setState(() {
      _isCheckedIn = !_isCheckedIn;
      final now = DateTime.now();
      final timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      
      if (_isCheckedIn) {
        _currentStatus = 'Checked In';
        _checkInTime = timeString;
        _checkOutTime = '--:--';
        _totalHours = '0h 0m';
      } else {
        _currentStatus = 'Checked Out';
        _checkOutTime = timeString;
        // Calculate total hours (simplified)
        _totalHours = '8h 30m';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SparshTheme.scaffoldBackground,
      appBar: Advanced3DAppBar(
        title: 'Worker Attendance',
        centerTitle: true,
        backgroundColor: SparshTheme.primaryBlue,
        elevation: 8,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: Show full history
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
                        backgroundColor: _isCheckedIn ? Colors.green : SparshTheme.primaryBlue,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _isCheckedIn ? Icons.schedule : Icons.access_time,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _currentStatus,
                                        style: TextStyle(
                                          fontSize: ResponsiveTypography.headingLarge(context),
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        _isCheckedIn ? 'You are currently at work' : 'Ready to check in?',
                                        style: TextStyle(
                                          fontSize: ResponsiveTypography.bodyText1(context),
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Advanced3DButton(
                              onPressed: _toggleAttendance,
                              backgroundColor: Colors.white,
                              foregroundColor: _isCheckedIn ? Colors.green : SparshTheme.primaryBlue,
                              padding: ResponsiveSpacing.symmetric(context, horizontal: 32, vertical: 16),
                              borderRadius: 12,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isCheckedIn ? Icons.logout : Icons.login,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _isCheckedIn ? 'Check Out' : 'Check In',
                                    style: TextStyle(
                                      fontSize: ResponsiveTypography.bodyText1(context),
                                      fontWeight: FontWeight.bold,
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
                    
                    // Today's Summary
                    Advanced3DCard(
                      padding: ResponsiveSpacing.all(context, 20),
                      backgroundColor: SparshTheme.cardBackground,
                      borderRadius: 20,
                      enableGlassMorphism: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today\'s Summary',
                            style: TextStyle(
                              fontSize: ResponsiveTypography.headingMedium(context),
                              fontWeight: FontWeight.bold,
                              color: SparshTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildSummaryItem('Check In', _checkInTime, Icons.login, Colors.green),
                              const SizedBox(width: 16),
                              _buildSummaryItem('Check Out', _checkOutTime, Icons.logout, Colors.red),
                              const SizedBox(width: 16),
                              _buildSummaryItem('Total Hours', _totalHours, Icons.timer, SparshTheme.primaryBlue),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Attendance History
                    Advanced3DCard(
                      padding: ResponsiveSpacing.all(context, 20),
                      backgroundColor: SparshTheme.cardBackground,
                      borderRadius: 20,
                      enableGlassMorphism: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Recent Attendance',
                                style: TextStyle(
                                  fontSize: ResponsiveTypography.headingMedium(context),
                                  fontWeight: FontWeight.bold,
                                  color: SparshTheme.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              Advanced3DButton(
                                onPressed: () {
                                  // TODO: Show full history
                                },
                                backgroundColor: SparshTheme.primaryBlue.withOpacity(0.1),
                                foregroundColor: SparshTheme.primaryBlue,
                                padding: ResponsiveSpacing.symmetric(context, horizontal: 12, vertical: 6),
                                borderRadius: 8,
                                child: Text(
                                  'View All',
                                  style: TextStyle(
                                    fontSize: ResponsiveTypography.bodyText2(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _attendanceHistory.length,
                            itemBuilder: (context, index) {
                              final record = _attendanceHistory[index];
                              return _buildAttendanceRecord(record);
                            },
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

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: ResponsiveSpacing.all(context, 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveTypography.bodyText2(context),
                color: SparshTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveTypography.bodyText1(context),
                fontWeight: FontWeight.bold,
                color: SparshTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceRecord(AttendanceRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: ResponsiveSpacing.all(context, 16),
      decoration: BoxDecoration(
        color: record.status == 'Present' 
            ? Colors.green.withOpacity(0.1) 
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: record.status == 'Present' ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${record.date.day}/${record.date.month}/${record.date.year}',
                  style: TextStyle(
                    fontSize: ResponsiveTypography.bodyText1(context),
                    fontWeight: FontWeight.w600,
                    color: SparshTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${record.checkIn} - ${record.checkOut}',
                  style: TextStyle(
                    fontSize: ResponsiveTypography.bodyText2(context),
                    color: SparshTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                record.status,
                style: TextStyle(
                  fontSize: ResponsiveTypography.bodyText2(context),
                  fontWeight: FontWeight.w600,
                  color: record.status == 'Present' ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                record.totalHours,
                style: TextStyle(
                  fontSize: ResponsiveTypography.bodyText2(context),
                  color: SparshTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AttendanceRecord {
  final DateTime date;
  final String checkIn;
  final String checkOut;
  final String totalHours;
  final String status;

  AttendanceRecord({
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.totalHours,
    required this.status,
  });
}
