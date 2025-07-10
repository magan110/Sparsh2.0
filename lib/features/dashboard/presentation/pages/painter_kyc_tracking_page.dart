// File: lib/report_filter_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A fully responsive screen that matches the provided screenshot:
/// - Blue gradient background
/// - White, rounded "filter card" at top
/// - Searchable Report Type dropdown
/// - Start Date / End Date fields with date pickers
/// - "Go" button (blue)
/// - "As on DD/MM/YYYY at HH:MM:SS" timestamp on the right
class PainterKycTrackingPage extends StatefulWidget {
  const PainterKycTrackingPage({super.key});

  @override
  State<PainterKycTrackingPage> createState() => _PainterKycTrackingPageState();
}

class _PainterKycTrackingPageState extends State<PainterKycTrackingPage> {
  // List of report types shown in your screenshot
  final List<String> _reportTypes = [
    'Zone Wise',
    'Logical State Wise',
    'Area Wise',
    'Employee Wise',
    'Incentive Employee Wise',
    'Incentive Employee Wise Dashboard',
    'Incentive Zonal Casc',
    'Incentive Area Casc',
    // Add more items here if needed
  ];

  // Currently selected report type
  String? _selectedReportType;

  // Controllers to hold the date strings (dd/MM/yyyy)
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // DateFormat for "dd/MM/yyyy"
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();

    // Default selected type → "Incentive Employee Wise Dashboard" if it exists
    if (_reportTypes.contains('Incentive Employee Wise Dashboard')) {
      _selectedReportType = 'Incentive Employee Wise Dashboard';
    } else {
      _selectedReportType = _reportTypes.first;
    }

    // Default Start Date → (today – 7 days), End Date → today
    DateTime now = DateTime.now();
    DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));
    _startDateController.text = _dateFormatter.format(sevenDaysAgo);
    _endDateController.text = _dateFormatter.format(now);
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  /// Opens a DatePicker and updates the given controller
  Future<void> _pickDate(
      BuildContext context,
      TextEditingController controller,
      ) async {
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

  /// Returns "As on DD/MM/YYYY at HH:MM:SS" for the current moment
  String _formattedTimestamp() {
    DateTime now = DateTime.now();
    String datePart = _dateFormatter.format(now);
    String timePart = DateFormat('HH:mm:ss').format(now);
    return 'As on $datePart at $timePart';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We don't use an AppBar here because the screenshot didn't show one—
      // the card floats on a gradient background.
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1976D2), // Deep blue
              Color(0xFF42A5F5), // Lighter blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // If width < 600, stack fields vertically.
                bool isMobile = constraints.maxWidth < 600;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top bar with back button and title
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                          onPressed: () => Navigator.of(context).pop(),
                          tooltip: 'Back',
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Painter KYC Tracking',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // To keep the title centered, add a dummy icon with opacity 0
                        const Opacity(
                          opacity: 0,
                          child: IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // The white rounded "filter card"
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.98),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 24,
                      ),
                      child: isMobile
                          ? _buildMobileLayout()
                          : _buildTabletDesktopLayout(),
                    ),

                    // The rest of the page (just a placeholder in this example)
                    Expanded(
                      child: Center(
                        child: Text(
                          'Your content goes here',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: isMobile ? 18 : 28,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// On a narrow screen, stack all fields vertically (full width).
  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1) Report Type (searchable dropdown)
        _buildReportTypeDropdown(),
        const SizedBox(height: 12),

        // 2) Start Date
        _buildDateField(
          label: 'Start Date',
          controller: _startDateController,
        ),
        const SizedBox(height: 12),

        // 3) End Date
        _buildDateField(
          label: 'End Date',
          controller: _endDateController,
        ),
        const SizedBox(height: 12),

        // 4) Go button (full-width)
        ElevatedButton(
          onPressed: () {
            // TODO: wire up your "Go" logic
            final sel = _selectedReportType ?? '(none)';
            final sd = _startDateController.text;
            final ed = _endDateController.text;
            debugPrint('Go pressed → report: $sel, start: $sd, end: $ed');
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: const Color(0xFF1976D2),
            elevation: 6,
            shadowColor: Colors.blueAccent.withOpacity(0.3),
          ),
          child: const Text(
            'Go',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
        const SizedBox(height: 12),

        // 5) Timestamp (aligned right)
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            _formattedTimestamp(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  /// On a wider screen, lay out in a single row with spacing.
  Widget _buildTabletDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1) Report Type (takes 2 flex units)
        Expanded(flex: 2, child: _buildReportTypeDropdown()),
        const SizedBox(width: 12),

        // 2) Start Date (1 flex)
        Expanded(
          flex: 1,
          child: _buildDateField(
            label: 'Start Date',
            controller: _startDateController,
          ),
        ),
        const SizedBox(width: 12),

        // 3) End Date (1 flex)
        Expanded(
          flex: 1,
          child: _buildDateField(
            label: 'End Date',
            controller: _endDateController,
          ),
        ),
        const SizedBox(width: 12),

        // 4) Go button (fixed width)
        SizedBox(
          width: 80,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              final sel = _selectedReportType ?? '(none)';
              final sd = _startDateController.text;
              final ed = _endDateController.text;
              debugPrint('Go pressed → report: $sel, start: $sd, end: $ed');
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: const Color(0xFF1976D2),
              elevation: 6,
              shadowColor: Colors.blueAccent.withOpacity(0.3),
            ),
            child: const Text(
              'Go',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // 5) Timestamp (takes 2 flex units)
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              _formattedTimestamp(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// A searchable "Report Type" dropdown using dropdown_search package.
  Widget _buildReportTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Report Type',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _selectedReportType,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF1976D2), width: 1.2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF1976D2), width: 1.2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          items: _reportTypes.map((String type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(
                type,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedReportType = value;
            });
          },
        ),
      ],
    );
  }

  /// A date field that opens a date picker when tapped.
  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _pickDate(context, controller),
          child: AbsorbPointer(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF1976D2), width: 1.2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF1976D2), width: 1.2),
                ),
                suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF1976D2)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
