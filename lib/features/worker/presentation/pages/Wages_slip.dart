import 'package:flutter/material.dart';
import 'package:learning2/core/components/advanced_3d/advanced_3d_components.dart';
import 'package:learning2/core/utils/responsive_design.dart';
import 'package:learning2/core/utils/form_validators/form_validators.dart';
import 'package:learning2/core/theme/app_theme.dart';

class WagesSlip extends StatefulWidget {
  const WagesSlip({super.key});

  @override
  State<WagesSlip> createState() => _WagesSlipState();
}

class _WagesSlipState extends State<WagesSlip> with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Sample wage slip data
  final Map<String, dynamic> _wageData = {
    'employeeId': 'EMP001',
    'employeeName': 'John Doe',
    'designation': 'Senior Worker',
    'department': 'Production',
    'month': 'December 2024',
    'basicSalary': 25000.0,
    'hra': 5000.0,
    'conveyance': 2000.0,
    'medicalAllowance': 1500.0,
    'bonus': 3000.0,
    'overtime': 2500.0,
    'pf': 2400.0,
    'esi': 750.0,
    'tax': 1200.0,
    'otherDeductions': 500.0,
    'workingDays': 26,
    'paidDays': 26,
    'presentDays': 24,
    'absentDays': 2,
  };

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

  double get _grossSalary {
    return _wageData['basicSalary'] + 
           _wageData['hra'] + 
           _wageData['conveyance'] + 
           _wageData['medicalAllowance'] + 
           _wageData['bonus'] + 
           _wageData['overtime'];
  }

  double get _totalDeductions {
    return _wageData['pf'] + 
           _wageData['esi'] + 
           _wageData['tax'] + 
           _wageData['otherDeductions'];
  }

  double get _netSalary {
    return _grossSalary - _totalDeductions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SparshTheme.scaffoldBackground,
      appBar: Advanced3DAppBar(
        title: 'Wages Slip',
        centerTitle: true,
        backgroundColor: SparshTheme.primaryBlue,
        elevation: 8,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // TODO: Implement download functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
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
                        backgroundColor: SparshTheme.primaryBlue,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 32,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Wages Slip',
                                        style: TextStyle(
                                          fontSize: ResponsiveTypography.headingLarge(context),
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'Salary Statement for ${_wageData['month']}',
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
                            const SizedBox(height: 16),
                            Container(
                              padding: ResponsiveSpacing.all(context, 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Employee ID',
                                        style: TextStyle(
                                          fontSize: ResponsiveTypography.bodyText2(context),
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Text(
                                        _wageData['employeeId'],
                                        style: TextStyle(
                                          fontSize: ResponsiveTypography.bodyText1(context),
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Net Salary',
                                        style: TextStyle(
                                          fontSize: ResponsiveTypography.bodyText2(context),
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Text(
                                        '₹${_netSalary.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: ResponsiveTypography.headingMedium(context),
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
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
                    ),
                    const SizedBox(height: 24),
                    
                    // Employee Details
                    Advanced3DCard(
                      padding: ResponsiveSpacing.all(context, 20),
                      backgroundColor: SparshTheme.cardBackground,
                      borderRadius: 20,
                      enableGlassMorphism: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Employee Details',
                            style: TextStyle(
                              fontSize: ResponsiveTypography.headingMedium(context),
                              fontWeight: FontWeight.bold,
                              color: SparshTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow('Employee Name', _wageData['employeeName']),
                          _buildDetailRow('Designation', _wageData['designation']),
                          _buildDetailRow('Department', _wageData['department']),
                          _buildDetailRow('Working Days', _wageData['workingDays'].toString()),
                          _buildDetailRow('Present Days', _wageData['presentDays'].toString()),
                          _buildDetailRow('Absent Days', _wageData['absentDays'].toString()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Earnings
                    Advanced3DCard(
                      padding: ResponsiveSpacing.all(context, 20),
                      backgroundColor: SparshTheme.cardBackground,
                      borderRadius: 20,
                      enableGlassMorphism: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Earnings',
                            style: TextStyle(
                              fontSize: ResponsiveTypography.headingMedium(context),
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildAmountRow('Basic Salary', _wageData['basicSalary']),
                          _buildAmountRow('HRA', _wageData['hra']),
                          _buildAmountRow('Conveyance', _wageData['conveyance']),
                          _buildAmountRow('Medical Allowance', _wageData['medicalAllowance']),
                          _buildAmountRow('Bonus', _wageData['bonus']),
                          _buildAmountRow('Overtime', _wageData['overtime']),
                          Divider(thickness: 2, color: Colors.green),
                          _buildAmountRow('Gross Salary', _grossSalary, isTotal: true, color: Colors.green),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Deductions
                    Advanced3DCard(
                      padding: ResponsiveSpacing.all(context, 20),
                      backgroundColor: SparshTheme.cardBackground,
                      borderRadius: 20,
                      enableGlassMorphism: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Deductions',
                            style: TextStyle(
                              fontSize: ResponsiveTypography.headingMedium(context),
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildAmountRow('Provident Fund', _wageData['pf']),
                          _buildAmountRow('ESI', _wageData['esi']),
                          _buildAmountRow('Tax', _wageData['tax']),
                          _buildAmountRow('Other Deductions', _wageData['otherDeductions']),
                          Divider(thickness: 2, color: Colors.red),
                          _buildAmountRow('Total Deductions', _totalDeductions, isTotal: true, color: Colors.red),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Net Salary
                    Advanced3DCard(
                      padding: ResponsiveSpacing.all(context, 20),
                      backgroundColor: SparshTheme.primaryBlue,
                      borderRadius: 20,
                      enableGlassMorphism: true,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Net Salary',
                            style: TextStyle(
                              fontSize: ResponsiveTypography.headingMedium(context),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '₹${_netSalary.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: ResponsiveTypography.headingLarge(context),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: Advanced3DButton(
                            onPressed: () {
                              // TODO: Implement download functionality
                            },
                            backgroundColor: SparshTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: ResponsiveSpacing.symmetric(context, horizontal: 24, vertical: 16),
                            borderRadius: 12,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.download, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Download',
                                  style: TextStyle(
                                    fontSize: ResponsiveTypography.bodyText1(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Advanced3DButton(
                            onPressed: () {
                              // TODO: Implement share functionality
                            },
                            backgroundColor: SparshTheme.cardBackground,
                            foregroundColor: SparshTheme.primaryBlue,
                            padding: ResponsiveSpacing.symmetric(context, horizontal: 24, vertical: 16),
                            borderRadius: 12,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.share, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Share',
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
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveTypography.bodyText1(context),
              color: SparshTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveTypography.bodyText1(context),
              fontWeight: FontWeight.w600,
              color: SparshTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount, {bool isTotal = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveTypography.bodyText1(context),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: color ?? SparshTheme.textSecondary,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: ResponsiveTypography.bodyText1(context),
              fontWeight: FontWeight.w600,
              color: color ?? SparshTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
