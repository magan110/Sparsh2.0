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

class _AccountsStatementPageState extends State<AccountsStatementPage>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Controllers for date fields
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // Dropdown selections
  String? _selectedPurchaserType;
  String? _selectedAreaCode;

  // Controller for "Code" field
  final TextEditingController _codeController = TextEditingController();

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
    _setupAnimations();
    // Initialize date fields as empty (or you can default them to today)
    _startDateController.text = '';
    _endDateController.text = '';
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
    _codeController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SparshTheme.scaffoldBackground,
      appBar: Advanced3DAppBar(
        title: 'Accounts Statement',
        centerTitle: true,
        backgroundColor: SparshTheme.primaryBlue,
        elevation: 8,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: ResponsiveSpacing.all(context, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                    Icons.account_balance_outlined,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Accounts Statement',
                                          style: TextStyle(
                                            fontSize: ResponsiveTypography.headingLarge(context),
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'Generate comprehensive account statements',
                                          style: TextStyle(
                                            fontSize: ResponsiveTypography.bodyText1(context),
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: ResponsiveSpacing.all(context, 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.security,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: ResponsiveSpacing.all(context, 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'All data is confidential and secure',
                                        style: TextStyle(
                                          fontSize: ResponsiveTypography.bodyText2(context),
                                          color: Colors.white,
                                        ),
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
                      
                      // Form Card
                      Advanced3DCard(
                        padding: ResponsiveSpacing.all(context, 20),
                        backgroundColor: SparshTheme.cardBackground,
                        borderRadius: 20,
                        enableGlassMorphism: true,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            bool isMobile = constraints.maxWidth < 600;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Statement Parameters',
                                  style: TextStyle(
                                    fontSize: ResponsiveTypography.headingMedium(context),
                                    fontWeight: FontWeight.bold,
                                    color: SparshTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                isMobile
                                    ? _buildMobileLayout()
                                    : _buildTabletDesktopLayout(),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Layout for mobile (stack all fields vertically)
  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Start Date
        _buildFieldLabel('Start Date:', false),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickDate(context, _startDateController),
          child: AbsorbPointer(
            child: Advanced3DTextField(
              controller: _startDateController,
              hintText: 'DD/MM/YYYY',
              suffixIcon: Icon(Icons.calendar_today, color: SparshTheme.primaryBlue),
              borderRadius: 12,
              backgroundColor: SparshTheme.cardBackground,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // End Date
        _buildFieldLabel('End Date:', false),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickDate(context, _endDateController),
          child: AbsorbPointer(
            child: Advanced3DTextField(
              controller: _endDateController,
              hintText: 'DD/MM/YYYY',
              suffixIcon: Icon(Icons.calendar_today, color: SparshTheme.primaryBlue),
              borderRadius: 12,
              backgroundColor: SparshTheme.cardBackground,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Purchaser Type *
        _buildFieldLabel('Purchaser Type', true),
        const SizedBox(height: 8),
        Advanced3DCard(
          backgroundColor: SparshTheme.cardBackground,
          borderRadius: 12,
          child: Padding(
            padding: ResponsiveSpacing.all(context, 4),
            child: DropdownButtonFormField<String>(
              value: _selectedPurchaserType ?? _purchaserTypes.first,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: ResponsiveSpacing.all(context, 12),
              ),
              style: TextStyle(
                color: SparshTheme.textPrimary,
                fontSize: ResponsiveTypography.bodyText1(context),
              ),
              items: _purchaserTypes.map((p) {
                return DropdownMenuItem(
                  value: p,
                  child: Text(p),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPurchaserType = value;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Area Code *
        _buildFieldLabel('Area Code', true),
        const SizedBox(height: 8),
        Advanced3DCard(
          backgroundColor: SparshTheme.cardBackground,
          borderRadius: 12,
          child: Padding(
            padding: ResponsiveSpacing.all(context, 4),
            child: DropdownButtonFormField<String>(
              value: _selectedAreaCode ?? _areaCodes.first,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: ResponsiveSpacing.all(context, 12),
              ),
              style: TextStyle(
                color: SparshTheme.textPrimary,
                fontSize: ResponsiveTypography.bodyText1(context),
              ),
              items: _areaCodes.map((a) {
                return DropdownMenuItem(
                  value: a,
                  child: Text(a),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAreaCode = value;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Code *
        _buildFieldLabel('Code', true),
        const SizedBox(height: 8),
        Advanced3DTextField(
          controller: _codeController,
          hintText: 'Enter Code',
          borderRadius: 12,
          backgroundColor: SparshTheme.cardBackground,
        ),
        const SizedBox(height: 24),

        // Go button
        Align(
          alignment: Alignment.centerRight,
          child: Advanced3DButton(
            onPressed: () {
              // TODO: Implement "Go" logic
              debugPrint('--- GO PRESSED ---');
              debugPrint('Start Date: ${_startDateController.text}');
              debugPrint('End Date: ${_endDateController.text}');
              debugPrint('Purchaser Type: $_selectedPurchaserType');
              debugPrint('Area Code: $_selectedAreaCode');
              debugPrint('Code: ${_codeController.text}');
            },
            backgroundColor: SparshTheme.primaryBlue,
            foregroundColor: Colors.white,
            padding: ResponsiveSpacing.symmetric(context, horizontal: 24, vertical: 12),
            borderRadius: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Generate Statement',
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
    );
  }

  /// Layout for tablet/desktop (fields arranged in two rows)
  Widget _buildTabletDesktopLayout() {
    return Column(
      children: [
        Row(
          children: [
            // Start Date (flex: 2)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Start Date:', false),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _pickDate(context, _startDateController),
                    child: AbsorbPointer(
                      child: Advanced3DTextField(
                        controller: _startDateController,
                        hintText: 'DD/MM/YYYY',
                        suffixIcon: Icon(Icons.calendar_today, color: SparshTheme.primaryBlue),
                        borderRadius: 12,
                        backgroundColor: SparshTheme.cardBackground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // End Date (flex: 2)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('End Date:', false),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _pickDate(context, _endDateController),
                    child: AbsorbPointer(
                      child: Advanced3DTextField(
                        controller: _endDateController,
                        hintText: 'DD/MM/YYYY',
                        suffixIcon: Icon(Icons.calendar_today, color: SparshTheme.primaryBlue),
                        borderRadius: 12,
                        backgroundColor: SparshTheme.cardBackground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Purchaser Type * (flex: 2)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Purchaser Type', true),
                  const SizedBox(height: 8),
                  Advanced3DCard(
                    backgroundColor: SparshTheme.cardBackground,
                    borderRadius: 12,
                    child: Padding(
                      padding: ResponsiveSpacing.all(context, 4),
                      child: DropdownButtonFormField<String>(
                        value: _selectedPurchaserType ?? _purchaserTypes.first,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: ResponsiveSpacing.all(context, 12),
                        ),
                        style: TextStyle(
                          color: SparshTheme.textPrimary,
                          fontSize: ResponsiveTypography.bodyText1(context),
                        ),
                        items: _purchaserTypes.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Text(p),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPurchaserType = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            // Area Code * (flex: 2)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Area Code', true),
                  const SizedBox(height: 8),
                  Advanced3DCard(
                    backgroundColor: SparshTheme.cardBackground,
                    borderRadius: 12,
                    child: Padding(
                      padding: ResponsiveSpacing.all(context, 4),
                      child: DropdownButtonFormField<String>(
                        value: _selectedAreaCode ?? _areaCodes.first,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: ResponsiveSpacing.all(context, 12),
                        ),
                        style: TextStyle(
                          color: SparshTheme.textPrimary,
                          fontSize: ResponsiveTypography.bodyText1(context),
                        ),
                        items: _areaCodes.map((a) {
                          return DropdownMenuItem(
                            value: a,
                            child: Text(a),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAreaCode = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Code * (flex: 2)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Code', true),
                  const SizedBox(height: 8),
                  Advanced3DTextField(
                    controller: _codeController,
                    hintText: 'Enter Code',
                    borderRadius: 12,
                    backgroundColor: SparshTheme.cardBackground,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Go Button (fixed width)
            SizedBox(
              width: 140,
              child: Advanced3DButton(
                onPressed: () {
                  // TODO: Implement "Go" logic
                  debugPrint('--- GO PRESSED ---');
                  debugPrint('Start Date: ${_startDateController.text}');
                  debugPrint('End Date: ${_endDateController.text}');
                  debugPrint('Purchaser Type: $_selectedPurchaserType');
                  debugPrint('Area Code: $_selectedAreaCode');
                  debugPrint('Code: ${_codeController.text}');
                },
                backgroundColor: SparshTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: ResponsiveSpacing.symmetric(context, horizontal: 16, vertical: 12),
                borderRadius: 12,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search, size: 20),
                    const SizedBox(height: 4),
                    Text(
                      'Generate',
                      style: TextStyle(
                        fontSize: ResponsiveTypography.bodyText2(context),
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
    );
  }

  /// Helper method to build field labels
  Widget _buildFieldLabel(String label, bool isRequired) {
    return RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: ResponsiveTypography.bodyText1(context),
          fontWeight: FontWeight.w600,
          color: SparshTheme.textPrimary,
        ),
        children: [
          if (isRequired)
            TextSpan(
              text: ' *',
              style: TextStyle(
                color: Colors.red,
                fontSize: ResponsiveTypography.bodyText1(context),
              ),
            ),
        ],
      ),
    );
  }

}
