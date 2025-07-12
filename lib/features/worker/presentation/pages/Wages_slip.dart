import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/components/advanced_3d_components.dart';
import '../../../../core/utils/responsive_util.dart';

class WagesSlip extends StatefulWidget {
  const WagesSlip({super.key});

  @override
  State<WagesSlip> createState() => _WagesSlipState();
}

class _WagesSlipState extends State<WagesSlip> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final String _employeeId = 'EMP001';
  final String _employeeName = 'John Doe';
  final String _department = 'Production';
  final String _designation = 'Senior Worker';
  final String _payPeriod = '${DateFormat('MMM yyyy').format(DateTime.now())}';
  
  // Dummy wages data
  final double _basicSalary = 25000.0;
  final double _allowances = 5000.0;
  final double _overtime = 2500.0;
  final double _bonus = 1500.0;
  final double _deductions = 3200.0;
  final double _tax = 1800.0;
  final double _netSalary = 29000.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
          'Wages Slip',
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
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality coming soon!')),
              );
            },
            icon: const Icon(Icons.share, color: Colors.white),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: ResponsiveUtil.scaledPadding(context, all: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderSection(),
              SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
              _buildEmployeeInfoSection(),
              SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
              _buildEarningsSection(),
              SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
              _buildDeductionsSection(),
              SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
              _buildNetSalarySection(),
              SizedBox(height: ResponsiveUtil.scaledSize(context, 24)),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Advanced3DCard(
      enableGlassMorphism: false,
      backgroundColor: SparshTheme.primaryBlue,
      child: Column(
        children: [
          Icon(
            Icons.receipt_long,
            size: ResponsiveUtil.scaledSize(context, 48),
            color: Colors.white,
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 8)),
          Text(
            'WAGES SLIP',
            style: SparshTypography.heading4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 4)),
          Text(
            'Pay Period: $_payPeriod',
            style: SparshTypography.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildEmployeeInfoSection() {
    return Advanced3DCard(
      enableGlassMorphism: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: SparshTheme.primaryBlue,
                size: ResponsiveUtil.scaledSize(context, 24),
              ),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 8)),
              Text(
                'Employee Information',
                style: SparshTypography.heading6.copyWith(
                  color: SparshTheme.primaryBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          _buildInfoRow('Employee ID', _employeeId),
          _buildInfoRow('Name', _employeeName),
          _buildInfoRow('Department', _department),
          _buildInfoRow('Designation', _designation),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideY(begin: 0.2);
  }

  Widget _buildEarningsSection() {
    return Advanced3DCard(
      enableGlassMorphism: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: SparshTheme.successGreen,
                size: ResponsiveUtil.scaledSize(context, 24),
              ),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 8)),
              Text(
                'Earnings',
                style: SparshTypography.heading6.copyWith(
                  color: SparshTheme.successGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          _buildAmountRow('Basic Salary', _basicSalary, SparshTheme.successGreen),
          _buildAmountRow('Allowances', _allowances, SparshTheme.successGreen),
          _buildAmountRow('Overtime', _overtime, SparshTheme.successGreen),
          _buildAmountRow('Bonus', _bonus, SparshTheme.successGreen),
          Divider(color: SparshTheme.borderGrey),
          _buildAmountRow(
            'Gross Salary',
            _basicSalary + _allowances + _overtime + _bonus,
            SparshTheme.successGreen,
            isTotal: true,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.2);
  }

  Widget _buildDeductionsSection() {
    return Advanced3DCard(
      enableGlassMorphism: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_down,
                color: SparshTheme.errorRed,
                size: ResponsiveUtil.scaledSize(context, 24),
              ),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 8)),
              Text(
                'Deductions',
                style: SparshTypography.heading6.copyWith(
                  color: SparshTheme.errorRed,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          _buildAmountRow('Deductions', _deductions, SparshTheme.errorRed),
          _buildAmountRow('Tax', _tax, SparshTheme.errorRed),
          Divider(color: SparshTheme.borderGrey),
          _buildAmountRow(
            'Total Deductions',
            _deductions + _tax,
            SparshTheme.errorRed,
            isTotal: true,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 0.2);
  }

  Widget _buildNetSalarySection() {
    return Advanced3DCard(
      enableGlassMorphism: false,
      backgroundColor: SparshTheme.primaryBlue.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: SparshTheme.primaryBlue,
                size: ResponsiveUtil.scaledSize(context, 24),
              ),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 8)),
              Text(
                'Net Salary',
                style: SparshTypography.heading6.copyWith(
                  color: SparshTheme.primaryBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          Container(
            padding: ResponsiveUtil.scaledPadding(context, all: 16),
            decoration: BoxDecoration(
              color: SparshTheme.primaryBlue,
              borderRadius: BorderRadius.circular(SparshBorderRadius.md),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Net Pay',
                  style: SparshTypography.heading5.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₹${_netSalary.toStringAsFixed(2)}',
                  style: SparshTypography.heading4.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement download functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Download functionality coming soon!')),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Download'),
            style: ElevatedButton.styleFrom(
              backgroundColor: SparshTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: ResponsiveUtil.scaledPadding(context, vertical: 16),
            ),
          ),
        ),
        SizedBox(width: ResponsiveUtil.scaledSize(context, 16)),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement email functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Email functionality coming soon!')),
              );
            },
            icon: const Icon(Icons.email),
            label: const Text('Email'),
            style: OutlinedButton.styleFrom(
              foregroundColor: SparshTheme.primaryBlue,
              side: BorderSide(color: SparshTheme.primaryBlue),
              padding: ResponsiveUtil.scaledPadding(context, vertical: 16),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms, delay: 500.ms).slideY(begin: 0.2);
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: ResponsiveUtil.scaledPadding(context, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: ResponsiveUtil.scaledSize(context, 100),
            child: Text(
              label,
              style: SparshTypography.bodyMedium.copyWith(
                color: SparshTheme.textSecondary,
              ),
            ),
          ),
          Text(
            ':',
            style: SparshTypography.bodyMedium.copyWith(
              color: SparshTheme.textSecondary,
            ),
          ),
          SizedBox(width: ResponsiveUtil.scaledSize(context, 8)),
          Expanded(
            child: Text(
              value,
              style: SparshTypography.bodyMedium.copyWith(
                color: SparshTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount, Color color, {bool isTotal = false}) {
    return Padding(
      padding: ResponsiveUtil.scaledPadding(context, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: (isTotal ? SparshTypography.bodyBold : SparshTypography.bodyMedium).copyWith(
              color: isTotal ? color : SparshTheme.textPrimary,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: (isTotal ? SparshTypography.bodyBold : SparshTypography.bodyMedium).copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
