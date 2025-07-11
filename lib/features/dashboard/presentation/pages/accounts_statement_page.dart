// File: lib/accounts_statement_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:learning2/core/components/advanced_3d/advanced_3d_components.dart';
import 'package:learning2/core/utils/responsive_design.dart';
import 'package:learning2/core/utils/form_validators/form_validators.dart';
import 'package:learning2/core/theme/app_theme.dart';

class AccountsStatementPage extends StatefulWidget {
  const AccountsStatementPage({super.key});

  @override
  State<AccountsStatementPage> createState() => _AccountsStatementPageState();
}

class _AccountsStatementPageState extends State<AccountsStatementPage> with TickerProviderStateMixin {
  // Controllers for date fields
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // Dropdown selections
  String? _selectedPurchaserType;
  String? _selectedAreaCode;

  // Controller for "Code" field
  final TextEditingController _codeController = TextEditingController();

  // Animation controllers
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // Sample items (replace with real data)
  final List<String> _purchaserTypes = [
    'Select',
    'Retailer',
    'Distributor',
    'Wholesaler'
  ];
  final List<String> _areaCodes = ['Select', 'Area 1', 'Area 2', 'Area 3'];

  // DateFormat for "dd/MM/yyyy"
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    // Initialize date fields as empty (or you can default them to today)
    _startDateController.text = '';
    _endDateController.text = '';
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
    _codeController.dispose();
    _animController.dispose();
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
                hintText: 'dd/MM/yyyy',
              ),
              SizedBox(height: ResponsiveSpacing.medium(context)),
              _buildDateField(
                controller: _endDateController,
                labelText: 'End Date',
                hintText: 'dd/MM/yyyy',
              ),
            ],
          ),
          tablet: Row(
            children: [
              Expanded(
                child: _buildDateField(
                  controller: _startDateController,
                  labelText: 'Start Date',
                  hintText: 'dd/MM/yyyy',
                ),
              ),
              SizedBox(width: ResponsiveSpacing.medium(context)),
              Expanded(
                child: _buildDateField(
                  controller: _endDateController,
                  labelText: 'End Date',
                  hintText: 'dd/MM/yyyy',
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

  Widget _buildFiltersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filters',
          style: ResponsiveTypography.titleMedium(context).copyWith(
            color: SparshTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ResponsiveSpacing.medium(context)),
        
        ResponsiveBuilder(
          mobile: Column(
            children: [
              _buildDropdownField(
                value: _selectedPurchaserType,
                items: _purchaserTypes,
                labelText: 'Purchaser Type',
                onChanged: (value) {
                  setState(() {
                    _selectedPurchaserType = value;
                  });
                },
              ),
              SizedBox(height: ResponsiveSpacing.medium(context)),
              _buildDropdownField(
                value: _selectedAreaCode,
                items: _areaCodes,
                labelText: 'Area Code',
                onChanged: (value) {
                  setState(() {
                    _selectedAreaCode = value;
                  });
                },
              ),
              SizedBox(height: ResponsiveSpacing.medium(context)),
              Advanced3DTextFormField(
                controller: _codeController,
                labelText: 'Code',
                hintText: 'Enter code',
                validator: FormValidators.required,
              ),
            ],
          ),
          tablet: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      value: _selectedPurchaserType,
                      items: _purchaserTypes,
                      labelText: 'Purchaser Type',
                      onChanged: (value) {
                        setState(() {
                          _selectedPurchaserType = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: ResponsiveSpacing.medium(context)),
                  Expanded(
                    child: _buildDropdownField(
                      value: _selectedAreaCode,
                      items: _areaCodes,
                      labelText: 'Area Code',
                      onChanged: (value) {
                        setState(() {
                          _selectedAreaCode = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveSpacing.medium(context)),
              Advanced3DTextFormField(
                controller: _codeController,
                labelText: 'Code',
                hintText: 'Enter code',
                validator: FormValidators.required,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required String labelText,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
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
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value == 'Select') {
          return 'Please select an option';
        }
        return null;
      },
    );
  }

  Widget _buildGenerateButton() {
    return Advanced3DButton(
      text: 'Generate Report',
      onPressed: () {
        // Add report generation logic here
        _showSuccessDialog();
      },
      backgroundColor: SparshTheme.primaryBlue,
      textColor: Colors.white,
      borderRadius: 12,
      elevation: 8,
      enableGlassMorphism: true,
      icon: Icons.assessment,
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Report generation initiated successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
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
          'Accounts Statement',
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
                              Icons.account_balance_outlined,
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
                                  'Accounts Statement',
                                  style: ResponsiveTypography.headlineSmall(context).copyWith(
                                    color: SparshTheme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Generate comprehensive financial reports',
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
                          
                          // Date Range Section
                          _buildDateRangeSection(),
                          SizedBox(height: ResponsiveSpacing.large(context)),
                          
                          // Filters Section
                          _buildFiltersSection(),
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