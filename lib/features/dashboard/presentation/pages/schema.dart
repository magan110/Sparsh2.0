import 'package:flutter/material.dart';
import 'package:learning2/data/models/SearchableDropdown.dart';
import 'package:learning2/data/models/DatePickerTextField.dart';
import 'package:learning2/data/models/SearchField.dart';
import 'package:learning2/core/constants/fonts.dart';
import 'package:learning2/core/components/advanced_3d/advanced_3d_components.dart';
import 'package:learning2/core/utils/responsive_design.dart';
import 'package:learning2/core/utils/form_validators/form_validators.dart';
import 'package:learning2/core/theme/app_theme.dart';

// Keep the existing Scheme related classes and enums
enum SchemeType { primary, secondary }
enum SchemeStatus { active, inactive, pending, completed }

class Scheme {
  final String schemeNo;
  final String sparshSchemeNo;
  final String schemeName;
  final SchemeType type;
  final double schemeValue;
  final double adjustmentAmount;
  final double cnDnValue;
  final DateTime postingDate;
  final String cnDnDocumentNo;
  final SchemeStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final String description;
  final Map<String, dynamic> additionalDetails;

  Scheme({
    required this.schemeNo,
    required this.sparshSchemeNo,
    required this.schemeName,
    required this.type,
    required this.schemeValue,
    required this.adjustmentAmount,
    required this.cnDnValue,
    required this.postingDate,
    required this.cnDnDocumentNo,
    this.status = SchemeStatus.active,
    required this.startDate,
    required this.endDate,
    this.description = '',
    this.additionalDetails = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'schemeNo': schemeNo,
      'sparshSchemeNo': sparshSchemeNo,
      'schemeName': schemeName,
      'type': type.toString(),
      'schemeValue': schemeValue,
      'adjustmentAmount': adjustmentAmount,
      'cnDnValue': cnDnValue,
      'postingDate': postingDate.toIso8601String(),
      'cnDnDocumentNo': cnDnDocumentNo,
      'status': status.toString(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'description': description,
      'additionalDetails': additionalDetails,
    };
  }

  factory Scheme.fromMap(Map<String, dynamic> map) {
    return Scheme(
      schemeNo: map['schemeNo'] ?? '',
      sparshSchemeNo: map['sparshSchemeNo'] ?? '',
      schemeName: map['schemeName'] ?? '',
      type: SchemeType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => SchemeType.primary,
      ),
      schemeValue: (map['schemeValue'] ?? 0.0).toDouble(),
      adjustmentAmount: (map['adjustmentAmount'] ?? 0.0).toDouble(),
      cnDnValue: (map['cnDnValue'] ?? 0.0).toDouble(),
      postingDate: DateTime.parse(
        map['postingDate'] ?? DateTime.now().toIso8601String(),
      ),
      cnDnDocumentNo: map['cnDnDocumentNo'] ?? '',
      status: SchemeStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => SchemeStatus.active,
      ),
      startDate: DateTime.parse(
        map['startDate'] ?? DateTime.now().toIso8601String(),
      ),
      endDate: DateTime.parse(
        map['endDate'] ?? DateTime.now().toIso8601String(),
      ),
      description: map['description'] ?? '',
      additionalDetails: map['additionalDetails'] ?? {},
    );
  }

  static List<Scheme> sampleSchemes = [
    Scheme(
      schemeNo: 'SCH001',
      sparshSchemeNo: 'SPARSH001',
      schemeName: 'Holiday Discount Scheme',
      type: SchemeType.primary,
      schemeValue: 10000.0,
      adjustmentAmount: 500.0,
      cnDnValue: 200.0,
      postingDate: DateTime(2023, 12, 1),
      cnDnDocumentNo: 'DOC001',
      status: SchemeStatus.active,
      startDate: DateTime(2023, 12, 1),
      endDate: DateTime(2023, 12, 31),
      description: 'Special discount for holiday season',
    ),
    Scheme(
      schemeNo: 'SCH002',
      sparshSchemeNo: 'SPARSH002',
      schemeName: 'New Year Promotion',
      type: SchemeType.secondary,
      schemeValue: 15000.0,
      adjustmentAmount: 750.0,
      cnDnValue: 300.0,
      postingDate: DateTime(2024, 1, 1),
      cnDnDocumentNo: 'DOC002',
      status: SchemeStatus.pending,
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2024, 1, 31),
      description: 'New Year special promotion',
    ),
  ];
}

class Schema extends StatefulWidget {
  const Schema({super.key});

  @override
  State<Schema> createState() => _SchemaState();
}

class _SchemaState extends State<Schema> with TickerProviderStateMixin {
  final TextEditingController controller = TextEditingController();
  final List<String> types = ['Scheme Period Date', 'Account Ledger wise Date'];
  
  // Animation controllers
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
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
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SparshTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Scheme Details',
          style: ResponsiveTypography.titleLarge(context).copyWith(
            color: SparshTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: SparshTheme.cardBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: SparshTheme.primaryBlue),
        centerTitle: true,
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
                              Icons.schema_outlined,
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
                                  'Scheme Management',
                                  style: ResponsiveTypography.headlineSmall(context).copyWith(
                                    color: SparshTheme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Manage and track scheme details',
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
                    
                    // Search and Filter Card
                    Advanced3DCard(
                      padding: ResponsiveSpacing.paddingLarge(context),
                      backgroundColor: SparshTheme.cardBackground,
                      borderRadius: 16,
                      enableGlassMorphism: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Search & Filter',
                            style: ResponsiveTypography.titleMedium(context).copyWith(
                              color: SparshTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: ResponsiveSpacing.medium(context)),
                          
                          // Search Field
                          SearchField(
                            controller: controller,
                            hintText: 'Search schemes...',
                            onChanged: (value) {
                              // Handle search logic
                            },
                          ),
                          
                          SizedBox(height: ResponsiveSpacing.medium(context)),
                          
                          // Filter Options
                          SearchableDropdown(
                            items: types,
                            labelText: 'Filter by Type',
                            onChanged: (value) {
                              // Handle filter logic
                            },
                          ),
                          
                          SizedBox(height: ResponsiveSpacing.medium(context)),
                          
                          // Date Range
                          Row(
                            children: [
                              Expanded(
                                child: DatePickerTextField(
                                  labelText: 'Start Date',
                                ),
                              ),
                              SizedBox(width: ResponsiveSpacing.medium(context)),
                              Expanded(
                                child: DatePickerTextField(
                                  labelText: 'End Date',
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: ResponsiveSpacing.medium(context)),
                          
                          // Search Button
                          Advanced3DButton(
                            text: 'Search',
                            onPressed: () {
                              // Handle search action
                            },
                            backgroundColor: SparshTheme.primaryBlue,
                            textColor: Colors.white,
                            borderRadius: 12,
                            elevation: 8,
                            enableGlassMorphism: true,
                            icon: Icons.search,
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: ResponsiveSpacing.large(context)),
                    
                    // Schemes Table Card
                    Advanced3DCard(
                      padding: ResponsiveSpacing.paddingLarge(context),
                      backgroundColor: SparshTheme.cardBackground,
                      borderRadius: 16,
                      enableGlassMorphism: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scheme Details',
                            style: ResponsiveTypography.titleMedium(context).copyWith(
                              color: SparshTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: ResponsiveSpacing.medium(context)),
                          
                          // Sample schemes list
                          ...Scheme.sampleSchemes.map((scheme) => Container(
                            margin: EdgeInsets.only(bottom: ResponsiveSpacing.medium(context)),
                            padding: ResponsiveSpacing.paddingMedium(context),
                            decoration: BoxDecoration(
                              color: SparshTheme.lightBlueBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: SparshTheme.borderGrey),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      scheme.schemeName,
                                      style: ResponsiveTypography.bodyLarge(context).copyWith(
                                        color: SparshTheme.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: ResponsiveSpacing.small(context),
                                        vertical: ResponsiveSpacing.small(context) / 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: scheme.status == SchemeStatus.active
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        scheme.status.toString().split('.').last,
                                        style: ResponsiveTypography.bodySmall(context).copyWith(
                                          color: scheme.status == SchemeStatus.active
                                              ? Colors.green
                                              : Colors.orange,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: ResponsiveSpacing.small(context)),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Scheme No: ${scheme.schemeNo}',
                                        style: ResponsiveTypography.bodySmall(context).copyWith(
                                          color: SparshTheme.textSecondary,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Value: ₹${scheme.schemeValue.toStringAsFixed(2)}',
                                        style: ResponsiveTypography.bodySmall(context).copyWith(
                                          color: SparshTheme.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )).toList(),
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