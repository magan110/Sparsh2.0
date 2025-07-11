// File: lib/activity_summary_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:learning2/core/components/advanced_3d/advanced_3d_components.dart';
import 'package:learning2/core/utils/responsive_design.dart';
import 'package:learning2/core/utils/form_validators/form_validators.dart';
import 'package:learning2/core/theme/app_theme.dart';

class ActivitySummaryPage extends StatefulWidget {
  const ActivitySummaryPage({super.key});

  @override
  State<ActivitySummaryPage> createState() => _ActivitySummaryPageState();
}

class _ActivitySummaryPageState extends State<ActivitySummaryPage> with TickerProviderStateMixin {
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
  ];

  // Currently selected report type
  String? _selectedReportType;

  // Controllers for start/end date
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // Date formatter "dd/MM/yyyy"
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

  // Animation controllers
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Default to first report type
    _selectedReportType = reportTypes.first;

    // Default end date → today
    DateTime now = DateTime.now();
    _endDateController.text = _dateFormatter.format(now);

    // Leave startDate blank
    _startDateController.text = '';
    
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
    _startDateController.dispose();
    _endDateController.dispose();
    _animController.dispose();
    super.dispose();
  }

  /// Date picker helper
  Future<void> _pickDate(BuildContext context, TextEditingController controller) async {
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

  Widget _buildReportTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Report Type',
          style: ResponsiveTypography.titleMedium(context).copyWith(
            color: SparshTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ResponsiveSpacing.medium(context)),
        DropdownSearch<String>(
          items: reportTypes,
          selectedItem: _selectedReportType,
          onChanged: (String? newValue) {
            setState(() {
              _selectedReportType = newValue;
            });
          },
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              labelText: 'Select Report Type',
              labelStyle: ResponsiveTypography.bodyMedium(context).copyWith(
                color: SparshTheme.textSecondary,
              ),
              filled: true,
              fillColor: SparshTheme.lightBlueBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: SparshTheme.borderGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: SparshTheme.primaryBlue, width: 2),
              ),
            ),
          ),
          popupProps: PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: 'Search report type...',
                prefixIcon: Icon(Icons.search, color: SparshTheme.primaryBlue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: ResponsiveTypography.titleMedium(context).copyWith(
            color: SparshTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ResponsiveSpacing.medium(context)),
        
        ResponsiveBuilder(
          mobile: Column(
            children: [
              _buildDateField(
                controller: _startDateController,
                labelText: 'Start Date',
                hintText: 'Select start date',
              ),
              SizedBox(height: ResponsiveSpacing.medium(context)),
              _buildDateField(
                controller: _endDateController,
                labelText: 'End Date',
                hintText: 'Select end date',
              ),
            ],
          ),
          tablet: Row(
            children: [
              Expanded(
                child: _buildDateField(
                  controller: _startDateController,
                  labelText: 'Start Date',
                  hintText: 'Select start date',
                ),
              ),
              SizedBox(width: ResponsiveSpacing.medium(context)),
              Expanded(
                child: _buildDateField(
                  controller: _endDateController,
                  labelText: 'End Date',
                  hintText: 'Select end date',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
  }) {
    return GestureDetector(
      onTap: () => _pickDate(context, controller),
      child: Advanced3DTextFormField(
        controller: controller,
        labelText: labelText,
        hintText: hintText,
        readOnly: true,
        suffixIcon: Icon(
          Icons.calendar_today,
          color: SparshTheme.primaryBlue,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a date';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Advanced3DButton(
      text: 'Generate Summary',
      onPressed: () {
        _generateReport();
      },
      backgroundColor: SparshTheme.primaryBlue,
      textColor: Colors.white,
      borderRadius: 12,
      elevation: 8,
      enableGlassMorphism: true,
      icon: Icons.summarize,
    );
  }

  void _generateReport() {
    if (_selectedReportType == null) {
      _showErrorDialog('Please select a report type');
      return;
    }

    if (_startDateController.text.isEmpty || _endDateController.text.isEmpty) {
      _showErrorDialog('Please select both start and end dates');
      return;
    }

    // TODO: Implement actual report generation
    _showSuccessDialog();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text('Generating ${_selectedReportType} report from ${_startDateController.text} to ${_endDateController.text}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SparshTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Activity Summary',
          style: ResponsiveTypography.titleLarge(context).copyWith(
            color: SparshTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: SparshTheme.cardBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: SparshTheme.primaryBlue),
      ),
      body: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: SingleChildScrollView(
                padding: ResponsiveSpacing.paddingMedium(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Card
                    Advanced3DCard(
                      padding: ResponsiveSpacing.paddingLarge(context),
                      backgroundColor: SparshTheme.cardBackground,
                      borderRadius: 20,
                      enableGlassMorphism: true,
                      child: Row(
                        children: [
                          Container(
                            padding: ResponsiveSpacing.paddingSmall(context),
                            decoration: BoxDecoration(
                              color: SparshTheme.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.summarize,
                              color: SparshTheme.primaryBlue,
                              size: ResponsiveUtil.scaledSize(context, 24),
                            ),
                          ),
                          SizedBox(width: ResponsiveSpacing.medium(context)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Activity Summary',
                                  style: ResponsiveTypography.headlineSmall(context).copyWith(
                                    color: SparshTheme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Generate detailed activity reports',
                                  style: ResponsiveTypography.bodyMedium(context).copyWith(
                                    color: SparshTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: ResponsiveSpacing.large(context)),
                    
                    // Form Card
                    Advanced3DCard(
                      padding: ResponsiveSpacing.paddingLarge(context),
                      backgroundColor: SparshTheme.cardBackground,
                      borderRadius: 20,
                      enableGlassMorphism: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Generate Report',
                            style: ResponsiveTypography.titleLarge(context).copyWith(
                              color: SparshTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: ResponsiveSpacing.large(context)),
                          
                          // Report Type Section
                          _buildReportTypeSection(),
                          SizedBox(height: ResponsiveSpacing.large(context)),
                          
                          // Date Range Section
                          _buildDateRangeSection(),
                          SizedBox(height: ResponsiveSpacing.large(context)),
                          
                          // Generate Button
                          _buildGenerateButton(),
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
}