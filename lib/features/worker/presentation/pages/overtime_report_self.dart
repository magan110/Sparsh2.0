import 'package:flutter/material.dart';
import 'package:learning2/core/components/advanced_3d/advanced_3d_components.dart';
import 'package:learning2/core/utils/responsive_design.dart';
import 'package:learning2/core/utils/form_validators/form_validators.dart';
import 'package:learning2/core/theme/app_theme.dart';

class OvertimeReportSelf extends StatefulWidget {
  const OvertimeReportSelf({super.key});

  @override
  State<OvertimeReportSelf> createState() => _OvertimeReportSelfState();
}

class _OvertimeReportSelfState extends State<OvertimeReportSelf>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final List<OvertimeRecord> _overtimeRecords = [
    OvertimeRecord(
      date: DateTime.now().subtract(const Duration(days: 1)),
      regularHours: 8,
      overtimeHours: 2,
      totalHours: 10,
      status: 'Approved',
      approvedBy: 'Manager A',
    ),
    OvertimeRecord(
      date: DateTime.now().subtract(const Duration(days: 2)),
      regularHours: 8,
      overtimeHours: 1.5,
      totalHours: 9.5,
      status: 'Pending',
      approvedBy: '',
    ),
    OvertimeRecord(
      date: DateTime.now().subtract(const Duration(days: 3)),
      regularHours: 8,
      overtimeHours: 3,
      totalHours: 11,
      status: 'Approved',
      approvedBy: 'Manager B',
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
        title: 'Overtime Report',
        centerTitle: true,
        backgroundColor: SparshTheme.primaryBlue,
        elevation: 8,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Add new overtime record
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
                              Icons.access_time_filled,
                              size: 48,
                              color: SparshTheme.primaryBlue,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Overtime Report',
                              style: TextStyle(
                                fontSize: ResponsiveTypography.headingLarge(context),
                                fontWeight: FontWeight.bold,
                                color: SparshTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Track your overtime hours and approval status',
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
                    
                    // Summary Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'Total Overtime',
                            '${_getTotalOvertimeHours()}h',
                            Icons.schedule,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            'This Month',
                            '${_getMonthlyOvertimeHours()}h',
                            Icons.calendar_month,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Records List
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
                                'Recent Records',
                                style: TextStyle(
                                  fontSize: ResponsiveTypography.headingMedium(context),
                                  fontWeight: FontWeight.bold,
                                  color: SparshTheme.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              Advanced3DButton(
                                onPressed: () {
                                  // TODO: View all records
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
                            itemCount: _overtimeRecords.length,
                            itemBuilder: (context, index) {
                              final record = _overtimeRecords[index];
                              return _buildOvertimeRecord(record);
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
      floatingActionButton: Advanced3DButton(
        onPressed: () {
          // TODO: Add new overtime record
        },
        backgroundColor: SparshTheme.primaryBlue,
        foregroundColor: Colors.white,
        padding: ResponsiveSpacing.all(context, 16),
        borderRadius: 28,
        child: Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Advanced3DCard(
      backgroundColor: SparshTheme.cardBackground,
      borderRadius: 16,
      enableGlassMorphism: true,
      child: Padding(
        padding: ResponsiveSpacing.all(context, 16),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveTypography.bodyText2(context),
                color: SparshTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveTypography.headingMedium(context),
                fontWeight: FontWeight.bold,
                color: SparshTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOvertimeRecord(OvertimeRecord record) {
    Color statusColor = record.status == 'Approved' ? Colors.green : Colors.orange;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: ResponsiveSpacing.all(context, 16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${record.date.day}/${record.date.month}/${record.date.year}',
                style: TextStyle(
                  fontSize: ResponsiveTypography.bodyText1(context),
                  fontWeight: FontWeight.w600,
                  color: SparshTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: ResponsiveSpacing.symmetric(context, horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  record.status,
                  style: TextStyle(
                    fontSize: ResponsiveTypography.caption(context),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildTimeInfo('Regular', '${record.regularHours}h', Colors.blue),
              const SizedBox(width: 16),
              _buildTimeInfo('Overtime', '${record.overtimeHours}h', Colors.orange),
              const SizedBox(width: 16),
              _buildTimeInfo('Total', '${record.totalHours}h', Colors.green),
            ],
          ),
          if (record.approvedBy.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Approved by: ${record.approvedBy}',
              style: TextStyle(
                fontSize: ResponsiveTypography.bodyText2(context),
                color: SparshTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveTypography.caption(context),
            color: SparshTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: ResponsiveTypography.bodyText1(context),
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  double _getTotalOvertimeHours() {
    return _overtimeRecords.fold(0.0, (sum, record) => sum + record.overtimeHours);
  }

  double _getMonthlyOvertimeHours() {
    final now = DateTime.now();
    return _overtimeRecords
        .where((record) => record.date.month == now.month && record.date.year == now.year)
        .fold(0.0, (sum, record) => sum + record.overtimeHours);
  }
}

class OvertimeRecord {
  final DateTime date;
  final double regularHours;
  final double overtimeHours;
  final double totalHours;
  final String status;
  final String approvedBy;

  OvertimeRecord({
    required this.date,
    required this.regularHours,
    required this.overtimeHours,
    required this.totalHours,
    required this.status,
    required this.approvedBy,
  });
}
