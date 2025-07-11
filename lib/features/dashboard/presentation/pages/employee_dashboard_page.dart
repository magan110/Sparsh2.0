// File: lib/employee_dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:learning2/core/components/advanced_3d/advanced_3d_components.dart';
import 'package:learning2/core/utils/responsive_design.dart';
import 'package:learning2/core/utils/form_validators/form_validators.dart';
import 'package:learning2/core/theme/app_theme.dart';

/// EmployeeDashboardPage
/// – Full‐screen blue gradient background
/// – Transparent AppBar with back arrow, title, Home/Log Out
/// – Top card: Start Date, End Date, Go button, “As on DD/MM/YYYY at HH:MM:SS”
/// – “Visit/Calling Report” card: donut chart + four metric items
/// – “Avg Working Hours in Market” placeholder card
/// – Three “Retailer Tally Billing Status” cards (each with donut + table)
///
/// On mobile (width < 600), cards stack vertically. On tablet/desktop (width >= 600),
/// the three billing‐status cards sit side‐by‐side.
class EmployeeDashboardPage extends StatefulWidget {
  const EmployeeDashboardPage({super.key});

  @override
  State<EmployeeDashboardPage> createState() => _EmployeeDashboardPageState();
}

class _EmployeeDashboardPageState extends State<EmployeeDashboardPage>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Controllers for Start/End date fields
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // Date formatter (“dd/MM/yyyy”)
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    // Default Start Date → two days ago (example)
    DateTime now = DateTime.now();
    DateTime twoDaysAgo = now.subtract(const Duration(days: 2));
    _startDateController.text = _dateFormatter.format(twoDaysAgo);

    // Default End Date → today
    _endDateController.text = _dateFormatter.format(now);
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
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  /// Opens a DatePicker and updates the given controller
  Future<void> _pickDate(
      BuildContext context, TextEditingController controller) async {
    DateTime initialDate;
    try {
      initialDate = _dateFormatter.parse(controller.text);
    } catch (_) {
      initialDate = DateTime.now();
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = _dateFormatter.format(picked);
      });
    }
  }

  /// Returns “As on DD/MM/YYYY at HH:MM:SS” for the current moment
  String _formattedTimestamp() {
    DateTime now = DateTime.now();
    String datePart = _dateFormatter.format(now);
    String timePart = DateFormat('HH:mm:ss').format(now);
    return 'As on $datePart at $timePart';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Full-screen blue gradient background
      decoration: const BoxDecoration(
        color: Colors.blue,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          // Transparent AppBar
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: LayoutBuilder(
            builder: (context, constraints) {
              // Make title responsive for mobile screens
              bool isMobile = MediaQuery.of(context).size.width < 600;
              return Text(
                isMobile ? 'Employee Dashboard' : 'Employee DashBoard – Confidential',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 16 : 18,
                ),
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isMobile = constraints.maxWidth < 600;

                // Top “date + go + timestamp” card
                Widget dateCard = Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.98),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 20 : 16,
                    horizontal: isMobile ? 20 : 16,
                  ),
                  child: isMobile ? _buildDateMobile() : _buildDateDesktop(),
                );

                // “Visit/Calling Report” card
                Widget visitReportCard = _buildVisitReportCard(isMobile);

                // “Avg Working Hours in Market” placeholder card
                Widget avgWorkingCard = _buildAvgWorkingHoursCard();

                // Three “Retailer Tally Billing Status” cards
                Widget billingCards = isMobile
                    ? Column(
                  children: [
                    _buildBillingStatusCard(
                        'Retailer Tally Billing Status (White Cement)',
                        isMobile: isMobile,
                        unbilledCount: 118,
                        billedCount: 0,
                        unbilledCurrMonth: 118,
                        less1Month: 118,
                        less3Month: 118,
                        less6Month: 118,
                        neverBilled: 25),
                    const SizedBox(height: 16),
                    _buildBillingStatusCard(
                        'Retailer Tally Billing Status (Wall Care Putty)',
                        isMobile: isMobile,
                        unbilledCount: 118,
                        billedCount: 0,
                        unbilledCurrMonth: 118,
                        less1Month: 118,
                        less3Month: 118,
                        less6Month: 118,
                        neverBilled: 21),
                    const SizedBox(height: 16),
                    _buildBillingStatusCard(
                        'Retailer Tally Billing Status (VAP)',
                        isMobile: isMobile,
                        unbilledCount: 118,
                        billedCount: 0,
                        unbilledCurrMonth: 118,
                        less1Month: 118,
                        less3Month: 118,
                        less6Month: 118,
                        neverBilled: 55),
                  ],
                )
                    : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildBillingStatusCard(
                          'Retailer Tally Billing Status (White Cement)',
                          isMobile: isMobile,
                          unbilledCount: 118,
                          billedCount: 0,
                          unbilledCurrMonth: 118,
                          less1Month: 118,
                          less3Month: 118,
                          less6Month: 118,
                          neverBilled: 25),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildBillingStatusCard(
                          'Retailer Tally Billing Status (Wall Care Putty)',
                          isMobile: isMobile,
                          unbilledCount: 118,
                          billedCount: 0,
                          unbilledCurrMonth: 118,
                          less1Month: 118,
                          less3Month: 118,
                          less6Month: 118,
                          neverBilled: 21),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildBillingStatusCard(
                          'Retailer Tally Billing Status (VAP)',
                          isMobile: isMobile,
                          unbilledCount: 118,
                          billedCount: 0,
                          unbilledCurrMonth: 118,
                          less1Month: 118,
                          less3Month: 118,
                          less6Month: 118,
                          neverBilled: 55),
                    ),
                  ],
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    dateCard,
                    const SizedBox(height: 24),
                    visitReportCard,
                    const SizedBox(height: 24),
                    avgWorkingCard,
                    const SizedBox(height: 24),
                    billingCards,
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Mobile layout for Start/End date + Go + timestamp
  Widget _buildDateMobile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Start Date
        const Text('Start Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickDate(context, _startDateController),
          child: AbsorbPointer(
            child: TextField(
              controller: _startDateController,
              decoration: _inputDecoration(
                hintText: 'DD/MM/YYYY',
                suffixIcon: const Icon(Icons.calendar_today, size: 24),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // End Date
        const Text('End Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickDate(context, _endDateController),
          child: AbsorbPointer(
            child: TextField(
              controller: _endDateController,
              decoration: _inputDecoration(
                hintText: 'DD/MM/YYYY',
                suffixIcon: const Icon(Icons.calendar_today, size: 24),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Go button (full width on mobile)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // TODO: Implement Go logic
              debugPrint('--- GO PRESSED (Mobile) ---');
              debugPrint('Start Date: ${_startDateController.text}');
              debugPrint('End Date: ${_endDateController.text}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Go',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Timestamp
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            _formattedTimestamp(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  /// Desktop/tablet layout for Start/End date + Go + timestamp
  Widget _buildDateDesktop() {
    return Row(
      children: [
        // Start Date (flex: 3)
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Start Date', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => _pickDate(context, _startDateController),
                child: AbsorbPointer(
                  child: TextField(
                    controller: _startDateController,
                    decoration: _inputDecoration(
                      hintText: 'DD/MM/YYYY',
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // End Date + Go (flex: 3)
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('End Date', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickDate(context, _endDateController),
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _endDateController,
                          decoration: _inputDecoration(
                            hintText: 'DD/MM/YYYY',
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement Go logic
                      debugPrint('--- GO PRESSED (Desktop) ---');
                      debugPrint('Start Date: ${_startDateController.text}');
                      debugPrint('End Date: ${_endDateController.text}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(80, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Go', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Timestamp (flex: 3)
        Expanded(
          flex: 3,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              _formattedTimestamp(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// “Visit/Calling Report” card with a donut chart and summary metrics
  Widget _buildVisitReportCard(bool isMobile) {
    // Sample data: Pending Retailer = 118, Unique Retailer Visit = 0
    final data = [
      ChartSegment('Pending Retailer', 118, Colors.blue),
      ChartSegment('Unique Retailer Visit', 0, Colors.red),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 20 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visit/Calling Report',
            style: TextStyle(
              fontSize: isMobile ? 22 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: isMobile ? 20 : 16),
          // Chart and legend layout
          isMobile
              ? Column(
            children: [
              // Chart on top for mobile
              SizedBox(
                height: 220,
                child: SimpleDonutChartFL(seriesData: data),
              ),
              const SizedBox(height: 16),
              // Legend below chart for mobile
              Column(
                children: [
                  _buildLegendRow(Colors.blue, 'Pending Retailer', 118),
                  const SizedBox(height: 12),
                  _buildLegendRow(Colors.red, 'Unique Retailer Visit', 0),
                ],
              ),
            ],
          )
              : Row(
            children: [
              // Donut chart
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 200,
                  child: SimpleDonutChartFL(seriesData: data),
                ),
              ),
              const SizedBox(width: 16),
              // Legend and counts
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendRow(Colors.blue, 'Pending Retailer', 118),
                    const SizedBox(height: 8),
                    _buildLegendRow(Colors.red, 'Unique Retailer Visit', 0),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 28 : 24),
          // Metrics below chart - use Wrap for mobile to prevent overflow
          isMobile
              ? Wrap(
            spacing: 16,
            runSpacing: 20,
            children: [
              _buildMetricItem('Total Mapped Retailer', '118', isMobile),
              _buildMetricItem('Total Unique Visited Retailer', '0', isMobile),
              _buildMetricItem('Visited Unique Mapped Retailer', '0', isMobile),
              _buildMetricItem('Pending Retailer Visit', '118', isMobile),
            ],
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMetricItem('Total Mapped Retailer', '118', isMobile),
              _buildMetricItem('Total Unique Visited Retailer', '0', isMobile),
              _buildMetricItem('Visited Unique Mapped Retailer', '0', isMobile),
              _buildMetricItem('Pending Retailer Visit', '118', isMobile),
            ],
          ),
        ],
      ),
    );
  }

  /// “Avg Working Hours in Market” card (empty placeholder)
  Widget _buildAvgWorkingHoursCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Avg Working Hours in Market',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'No data available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// A single “Retailer Tally Billing Status” card, with:
  /// - A donut chart showing Unbilled <1 Month and Billed <1 Month
  /// - A table listing counts: No. of Retailers, Billed in Curr Month, Unbilled in Curr Month,
  ///   and breakdown of unbilled by <1 month, <3 month, <6 month, Never Billed
  Widget _buildBillingStatusCard(
      String title, {
        required bool isMobile,
        required int unbilledCount,
        required int billedCount,
        required int unbilledCurrMonth,
        required int less1Month,
        required int less3Month,
        required int less6Month,
        required int neverBilled,
      }) {
    final data = [
      ChartSegment('Unbilled < 1 Month', unbilledCount, Colors.blue),
      ChartSegment('Billed < 1 Month', billedCount, Colors.red),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 20 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isMobile ? 20 : 16),
          // Chart + legend - responsive layout
          isMobile
              ? Column(
            children: [
              // Chart on top for mobile
              SizedBox(
                height: 200,
                child: SimpleDonutChartFL(seriesData: data),
              ),
              const SizedBox(height: 16),
              // Legend below chart for mobile
              Column(
                children: [
                  _buildLegendRow(Colors.blue, 'Unbilled < 1 Month', unbilledCount),
                  const SizedBox(height: 12),
                  _buildLegendRow(Colors.red, 'Billed < 1 Month', billedCount),
                ],
              ),
            ],
          )
              : Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 180,
                  child: SimpleDonutChartFL(seriesData: data),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendRow(Colors.blue, 'Unbilled < 1 Month', unbilledCount),
                    const SizedBox(height: 8),
                    _buildLegendRow(Colors.red, 'Billed < 1 Month', billedCount),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 20 : 16),
          // Data table
          Table(
            border: TableBorder(
              horizontalInside: BorderSide(color: Colors.grey.shade300),
              verticalInside: BorderSide(color: Colors.grey.shade300),
            ),
            columnWidths: isMobile
                ? const {
              0: FlexColumnWidth(2.5),
              1: FlexColumnWidth(1),
            }
                : const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(1),
            },
            children: [
              _buildTableRow('No. of Retailers (mapped to employee)', unbilledCount.toString(), isMobile),
              _buildTableRow('Billed in Curr Month', billedCount.toString(), isMobile),
              _buildTableRow('Unbilled in Curr Month', unbilledCurrMonth.toString(), isMobile),
              _buildTableRow('Unbilled', 'Count', isMobile), // header row
              _buildTableRow('  < 1 month', less1Month.toString(), isMobile),
              _buildTableRow('  < 3 month', less3Month.toString(), isMobile),
              _buildTableRow('  < 6 month', less6Month.toString(), isMobile),
              _buildTableRow('Never Billed', neverBilled.toString(), isMobile),
            ],
          ),
        ],
      ),
    );
  }

  /// Helper: build a single table row with two cells
  TableRow _buildTableRow(String label, String value, bool isMobile) {
    return TableRow(children: [
      Padding(
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 12.0 : 8.0,
          horizontal: isMobile ? 8.0 : 4.0,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 16 : 14,
            color: Colors.black87,
            fontWeight: isMobile ? FontWeight.w500 : FontWeight.normal,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Padding(
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 12.0 : 8.0,
          horizontal: isMobile ? 8.0 : 4.0,
        ),
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isMobile ? 16 : 14,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ]);
  }

  /// Helper: build a legend row with a colored dot, label, and count
  Widget _buildLegendRow(Color color, String label, int count) {
    // Calculate percentage if total > 0
    int total = 118; // hardcoded as in screenshot; replace if dynamic
    String percent = total > 0 ? ' (${((count / total) * 100).round()}%)' : '';
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
        Text(
          '$count$percent',
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }

  /// Helper: build a metric column containing a blue label and a bold value below
  Widget _buildMetricItem(String label, String value, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 8),
      decoration: isMobile
          ? BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 16 : 14,
              color: Colors.blue,
              fontWeight: isMobile ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isMobile ? 8 : 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  /// Common InputDecoration for all text fields
  InputDecoration _inputDecoration(
      {String? hintText, Widget? suffixIcon, bool enabled = true}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade200,
      enabled: enabled,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }
}

/// A simple data class for a single slice of the donut chart
class ChartSegment {
  final String label;
  final int value;
  final Color color;

  ChartSegment(this.label, this.value, this.color);
}

/// A reusable widget that draws a donut (ring) chart using FL Chart
class SimpleDonutChartFL extends StatelessWidget {
  final List<ChartSegment> seriesData;

  const SimpleDonutChartFL({super.key, required this.seriesData});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: seriesData.map((seg) {
          return PieChartSectionData(
            color: seg.color,
            value: seg.value.toDouble(),
            radius: 60,
            title: seg.value > 0 ? '${seg.value}' : '',
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            titlePositionPercentageOffset: 0.6,
          );
        }).toList(),

        // Make it a ring (donut) by specifying a non-zero "centerSpaceRadius"
        centerSpaceRadius: 40,
        sectionsSpace: 2,
        startDegreeOffset: -90,
      ),
      swapAnimationDuration: const Duration(milliseconds: 500),
      swapAnimationCurve: Curves.easeInOut,
    );
  }
}
