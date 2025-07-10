// File: lib/activity_summary_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';

class ActivitySummaryPage extends StatefulWidget {
  const ActivitySummaryPage({super.key});

  @override
  State<ActivitySummaryPage> createState() => _ActivitySummaryPageState();
}

class _ActivitySummaryPageState extends State<ActivitySummaryPage> {
  // List of report types for the searchable dropdown
  final List<String> reportTypes = [
    'Zone Wise',
    'Logical State Wise',
    'Area Wise',
    'Employee Wise - Area Wise',
    'State Wise',
    'Employee Wise Total - Summary',
    'Employee wise - Sampling & Collection',
    'Incentive Employee Wise Dashboard',
    // ... add more as needed
  ];

  // Currently selected report type
  String? _selectedReportType;

  // Controllers for start/end date
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // Date formatter “dd/MM/yyyy”
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();

    // Default to first report type (or null if you prefer)
    _selectedReportType = reportTypes.first;

    // Default end date → today
    DateTime now = DateTime.now();
    _endDateController.text = _dateFormatter.format(now);

    // Leave startDate blank or set a default:
    _startDateController.text = '';
  }

  @override
  void dispose() {
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
          // Transparent AppBar so gradient appears behind it
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Activity Summary – Confidential',
            style: TextStyle(color: Colors.white),
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

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // The white rounded “filter card”
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.98),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      child: isMobile
                          ? _buildMobileLayout()
                          : _buildTabletDesktopLayout(),
                    ),
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

  /// Build the vertical (mobile) layout
  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Report Type
        const Text('Report Type', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 6),
        DropdownSearch<String>(
          items: reportTypes,
          selectedItem: _selectedReportType,
          onChanged: (value) {
            setState(() {
              _selectedReportType = value;
            });
          },
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          dropdownBuilder: (context, selectedItem) {
            return Text(
              selectedItem ?? '',
              overflow: TextOverflow.ellipsis,
            );
          },
          popupProps: PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: "Search...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Start Date
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
        const SizedBox(height: 16),

        // End Date
        const Text('End Date', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 6),
        GestureDetector(
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
        const SizedBox(height: 16),

        // Go button + Timestamp
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                // TODO: implement Go logic
                debugPrint('--- GO PRESSED ---');
                debugPrint('Report Type: $_selectedReportType');
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
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _formattedTimestamp(),
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build the horizontal (tablet/desktop) layout
  Widget _buildTabletDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1) Report Type (flex: 3)
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Report Type', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 6),
              DropdownSearch<String>(
                items: reportTypes,
                selectedItem: _selectedReportType,
                onChanged: (value) {
                  setState(() {
                    _selectedReportType = value;
                  });
                },
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                dropdownBuilder: (context, selectedItem) {
                  return Text(
                    selectedItem ?? '',
                    overflow: TextOverflow.ellipsis,
                  );
                },
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      hintText: "Search...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // 2) Start Date (flex: 2)
        Expanded(
          flex: 2,
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

        // 3) End Date (flex: 2)
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('End Date', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 6),
              GestureDetector(
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
            ],
          ),
        ),
        const SizedBox(width: 16),

        // 4) Go Button (fixed width)
        ElevatedButton(
          onPressed: () {
            // TODO: implement Go logic
            debugPrint('--- GO PRESSED ---');
            debugPrint('Report Type: $_selectedReportType');
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
        const SizedBox(width: 16),

        // 5) Timestamp (flex: 3)
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

  /// Common InputDecoration for all text fields
  InputDecoration _inputDecoration(
      {String? hintText, Widget? suffixIcon, bool enabled = true}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade200,
      enabled: enabled,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
