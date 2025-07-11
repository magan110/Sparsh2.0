import 'package:flutter/material.dart';
import 'package:learning2/core/theme/app_theme.dart';
import 'package:learning2/core/utils/responsive_util.dart';
import 'package:learning2/presentation/widgets/advanced_3d_components.dart';
import 'package:learning2/presentation/animations/advanced_animations.dart';
import 'package:google_fonts/google_fonts.dart';

// Scheme Type Enum
enum SchemeType { primary, secondary }

// Scheme Status Enum
enum SchemeStatus { active, inactive, pending, completed }

// Scheme Model
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

  // Convert to Map
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

  // Create from Map
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

  // Sample data
  static List<Scheme> getSampleData() {
    return [
      Scheme(
        schemeNo: '12345',
        sparshSchemeNo: 'SS123',
        schemeName: 'Summer Promotion 2024',
        type: SchemeType.primary,
        schemeValue: 1000.0,
        adjustmentAmount: 100.0,
        cnDnValue: 50.0,
        postingDate: DateTime(2024, 1, 15),
        cnDnDocumentNo: 'CN123',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 3, 31),
        description: 'Summer season promotion for all products',
        additionalDetails: {
          'targetProducts': ['WC', 'WCP', 'VAP'],
          'minimumPurchase': 500.0,
        },
      ),
      Scheme(
        schemeNo: '67890',
        sparshSchemeNo: 'SS456',
        schemeName: 'Dealer Incentive Program',
        type: SchemeType.secondary,
        schemeValue: 2000.0,
        adjustmentAmount: 200.0,
        cnDnValue: 100.0,
        postingDate: DateTime(2024, 2, 20),
        cnDnDocumentNo: 'DN456',
        startDate: DateTime(2024, 2, 1),
        endDate: DateTime(2024, 4, 30),
        description: 'Special incentives for top performing dealers',
        additionalDetails: {
          'targetDealers': ['D001', 'D002', 'D003'],
          'performanceThreshold': 10000.0,
        },
      ),
      Scheme(
        schemeNo: '24680',
        sparshSchemeNo: 'SS789',
        schemeName: 'Volume Discount Scheme',
        type: SchemeType.primary,
        schemeValue: 1500.0,
        adjustmentAmount: 150.0,
        cnDnValue: 75.0,
        postingDate: DateTime(2024, 3, 25),
        cnDnDocumentNo: 'CN789',
        startDate: DateTime(2024, 3, 1),
        endDate: DateTime(2024, 5, 31),
        description: 'Volume-based discount for bulk purchases',
        additionalDetails: {
          'volumeThreshold': 1000.0,
          'discountPercentage': 5.0,
        },
      ),
      Scheme(
        schemeNo: '13579',
        sparshSchemeNo: 'SS012',
        schemeName: 'Loyalty Rewards Program',
        type: SchemeType.secondary,
        schemeValue: 2500.0,
        adjustmentAmount: 250.0,
        cnDnValue: 125.0,
        postingDate: DateTime(2024, 4, 30),
        cnDnDocumentNo: 'DN012',
        startDate: DateTime(2024, 4, 1),
        endDate: DateTime(2024, 6, 30),
        description: 'Rewards program for loyal customers',
        additionalDetails: {
          'loyaltyPoints': 1000,
          'rewardTier': 'Gold',
        },
      ),
      Scheme(
        schemeNo: '98765',
        sparshSchemeNo: 'SS345',
        schemeName: 'New Product Launch',
        type: SchemeType.primary,
        schemeValue: 3000.0,
        adjustmentAmount: 300.0,
        cnDnValue: 150.0,
        postingDate: DateTime(2024, 5, 5),
        cnDnDocumentNo: 'CN345',
        startDate: DateTime(2024, 5, 1),
        endDate: DateTime(2024, 7, 31),
        description: 'Promotional scheme for new product launch',
        additionalDetails: {
          'newProducts': ['NP001', 'NP002'],
          'launchBonus': 500.0,
        },
      ),
    ];
  }
}

class Schema extends StatefulWidget {
  const Schema({super.key});

  @override
  State<Schema> createState() => _SchemaState();
}

class _SchemaState extends State<Schema> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _cnDnController = TextEditingController();
  
  List<Scheme> _schemes = [];
  List<Scheme> _filteredSchemes = [];
  String _selectedType = 'Scheme Period Date';
  DateTime? _startDate;
  DateTime? _endDate;
  SchemeType? _selectedSchemeType;
  SchemeStatus? _selectedStatus;
  String _searchQuery = '';

  final List<String> _types = ['Scheme Period Date', 'Account Ledger wise Date'];

  @override
  void initState() {
    super.initState();
    _schemes = Scheme.getSampleData();
    _filteredSchemes = _schemes;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cnDnController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterSchemes();
    });
  }

  void _filterSchemes() {
    _filteredSchemes = _schemes.where((scheme) {
      final matchesSearch = _searchQuery.isEmpty ||
          scheme.schemeName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          scheme.schemeNo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          scheme.sparshSchemeNo.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesType = _selectedSchemeType == null || scheme.type == _selectedSchemeType;
      final matchesStatus = _selectedStatus == null || scheme.status == _selectedStatus;
      
      final matchesDateRange = (_startDate == null || scheme.startDate.isAfter(_startDate!)) &&
          (_endDate == null || scheme.endDate.isBefore(_endDate!));
      
      return matchesSearch && matchesType && matchesStatus && matchesDateRange;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtil.init(context);
    
    return Scaffold(
      backgroundColor: SparshTheme.scaffoldBackground,
      appBar: const Advanced3DAppBar(
        title: Text(
          'Scheme Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        enableGlassMorphism: true,
        enable3DTransform: true,
        gradient: SparshTheme.appBarGradient,
      ),
      body: SafeArea(
        child: ResponsiveBuilder(
          builder: (context, screenType) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: ResponsiveUtil.scaledPadding(context, all: 20),
              child: AdvancedStaggeredAnimation(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 100),
                children: [
                  _buildFiltersCard(),
                  SizedBox(height: ResponsiveUtil.scaledHeight(context, 24)),
                  _buildSearchCard(),
                  SizedBox(height: ResponsiveUtil.scaledHeight(context, 24)),
                  _buildSchemesGrid(),
                  SizedBox(height: ResponsiveUtil.scaledHeight(context, 32)),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: Advanced3DFloatingActionButton(
        onPressed: () {
          _showAddSchemeDialog();
        },
        child: const Icon(Icons.add, color: Colors.white),
        gradient: SparshTheme.primaryGradient,
        enablePulse: true,
        enableGlow: true,
      ),
    );
  }

  Widget _buildFiltersCard() {
    return Advanced3DCard(
      enableGlassMorphism: false,
      enableHover: true,
      enable3DTransform: true,
      elevation: 8,
      borderRadius: 20,
      backgroundColor: Colors.white,
      padding: ResponsiveUtil.scaledPadding(context, all: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Advanced3DTransform(
                enableAnimation: true,
                rotationY: 0.05,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: SparshTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.filter_alt_outlined,
                    size: ResponsiveUtil.getIconSize(context, 24),
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUtil.scaledWidth(context, 16)),
              Text(
                'Filters',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 20),
                  fontWeight: FontWeight.w600,
                  color: SparshTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaledHeight(context, 24)),
          ResponsiveBuilder(
            builder: (context, screenType) {
              if (screenType == ScreenType.mobile) {
                return Column(
                  children: [
                    _buildTypeDropdown(),
                    SizedBox(height: ResponsiveUtil.scaledHeight(context, 16)),
                    _buildDateRangeSelector(),
                    SizedBox(height: ResponsiveUtil.scaledHeight(context, 16)),
                    _buildCnDnField(),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildTypeDropdown()),
                        SizedBox(width: ResponsiveUtil.scaledWidth(context, 16)),
                        Expanded(child: _buildSchemeTypeFilter()),
                      ],
                    ),
                    SizedBox(height: ResponsiveUtil.scaledHeight(context, 16)),
                    _buildDateRangeSelector(),
                    SizedBox(height: ResponsiveUtil.scaledHeight(context, 16)),
                    _buildCnDnField(),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtil.scaledFontSize(context, 14),
            fontWeight: FontWeight.w500,
            color: SparshTheme.textPrimary,
          ),
        ),
        SizedBox(height: ResponsiveUtil.scaledHeight(context, 8)),
        AdvancedAnimatedContainer(
          duration: const Duration(milliseconds: 300),
          enableHover: true,
          enableScale: true,
          child: DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: SparshTheme.borderGrey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: SparshTheme.borderGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: SparshTheme.primaryBlue, width: 2),
              ),
              filled: true,
              fillColor: SparshTheme.lightBlueBackground,
            ),
            items: _types.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(
                  type,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                    color: SparshTheme.textPrimary,
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedType = newValue!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSchemeTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scheme Type',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtil.scaledFontSize(context, 14),
            fontWeight: FontWeight.w500,
            color: SparshTheme.textPrimary,
          ),
        ),
        SizedBox(height: ResponsiveUtil.scaledHeight(context, 8)),
        AdvancedAnimatedContainer(
          duration: const Duration(milliseconds: 300),
          enableHover: true,
          enableScale: true,
          child: DropdownButtonFormField<SchemeType?>(
            value: _selectedSchemeType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: SparshTheme.borderGrey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: SparshTheme.borderGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: SparshTheme.primaryBlue, width: 2),
              ),
              filled: true,
              fillColor: SparshTheme.lightBlueBackground,
            ),
            items: [
              DropdownMenuItem<SchemeType?>(
                value: null,
                child: Text(
                  'All Types',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                    color: SparshTheme.textPrimary,
                  ),
                ),
              ),
              ...SchemeType.values.map((SchemeType type) {
                return DropdownMenuItem<SchemeType?>(
                  value: type,
                  child: Text(
                    type.name.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                      color: SparshTheme.textPrimary,
                    ),
                  ),
                );
              }).toList(),
            ],
            onChanged: (SchemeType? newValue) {
              setState(() {
                _selectedSchemeType = newValue;
                _filterSchemes();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeSelector() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Start Date',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                  fontWeight: FontWeight.w500,
                  color: SparshTheme.textPrimary,
                ),
              ),
              SizedBox(height: ResponsiveUtil.scaledHeight(context, 8)),
              AdvancedAnimatedContainer(
                duration: const Duration(milliseconds: 300),
                enableHover: true,
                enableScale: true,
                onTap: () => _selectStartDate(),
                child: Container(
                  padding: ResponsiveUtil.scaledPadding(context, all: 16),
                  decoration: BoxDecoration(
                    color: SparshTheme.lightBlueBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: SparshTheme.borderGrey),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: ResponsiveUtil.getIconSize(context, 16),
                        color: SparshTheme.primaryBlue,
                      ),
                      SizedBox(width: ResponsiveUtil.scaledWidth(context, 8)),
                      Text(
                        _startDate != null
                            ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                            : 'Select Date',
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                          color: SparshTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: ResponsiveUtil.scaledWidth(context, 16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'End Date',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                  fontWeight: FontWeight.w500,
                  color: SparshTheme.textPrimary,
                ),
              ),
              SizedBox(height: ResponsiveUtil.scaledHeight(context, 8)),
              AdvancedAnimatedContainer(
                duration: const Duration(milliseconds: 300),
                enableHover: true,
                enableScale: true,
                onTap: () => _selectEndDate(),
                child: Container(
                  padding: ResponsiveUtil.scaledPadding(context, all: 16),
                  decoration: BoxDecoration(
                    color: SparshTheme.lightBlueBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: SparshTheme.borderGrey),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: ResponsiveUtil.getIconSize(context, 16),
                        color: SparshTheme.primaryBlue,
                      ),
                      SizedBox(width: ResponsiveUtil.scaledWidth(context, 8)),
                      Text(
                        _endDate != null
                            ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                            : 'Select Date',
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                          color: SparshTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCnDnField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CN / DN No.',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtil.scaledFontSize(context, 14),
            fontWeight: FontWeight.w500,
            color: SparshTheme.textPrimary,
          ),
        ),
        SizedBox(height: ResponsiveUtil.scaledHeight(context, 8)),
        Row(
          children: [
            Expanded(
              child: AdvancedAnimatedContainer(
                duration: const Duration(milliseconds: 300),
                enableHover: true,
                enableScale: true,
                child: TextField(
                  controller: _cnDnController,
                  decoration: InputDecoration(
                    hintText: 'Enter CN/DN Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: SparshTheme.borderGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: SparshTheme.borderGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: SparshTheme.primaryBlue, width: 2),
                    ),
                    filled: true,
                    fillColor: SparshTheme.lightBlueBackground,
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                    color: SparshTheme.textPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(width: ResponsiveUtil.scaledWidth(context, 12)),
            AdvancedAnimatedContainer(
              duration: const Duration(milliseconds: 300),
              enableHover: true,
              enableScale: true,
              onTap: () {
                // Handle search
              },
              padding: ResponsiveUtil.scaledPadding(context, all: 16),
              decoration: BoxDecoration(
                gradient: SparshTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.white,
                    size: ResponsiveUtil.getIconSize(context, 20),
                  ),
                  SizedBox(width: ResponsiveUtil.scaledWidth(context, 8)),
                  Text(
                    'Go',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchCard() {
    return Advanced3DCard(
      enableGlassMorphism: false,
      enableHover: true,
      enable3DTransform: true,
      elevation: 8,
      borderRadius: 20,
      backgroundColor: Colors.white,
      padding: ResponsiveUtil.scaledPadding(context, all: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Advanced3DTransform(
                enableAnimation: true,
                rotationY: 0.05,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: SparshTheme.blueAccentGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.search,
                    size: ResponsiveUtil.getIconSize(context, 24),
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUtil.scaledWidth(context, 16)),
              Text(
                'Search Schemes',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 20),
                  fontWeight: FontWeight.w600,
                  color: SparshTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaledHeight(context, 16)),
          AdvancedAnimatedContainer(
            duration: const Duration(milliseconds: 300),
            enableHover: true,
            enableScale: true,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by scheme name, number, or Sparsh number...',
                prefixIcon: Advanced3DTransform(
                  enableAnimation: true,
                  rotationY: 0.1,
                  child: Icon(Icons.search, color: SparshTheme.primaryBlue),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: SparshTheme.borderGrey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: SparshTheme.borderGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: SparshTheme.primaryBlue, width: 2),
                ),
                filled: true,
                fillColor: SparshTheme.lightBlueBackground,
              ),
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                color: SparshTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchemesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Advanced3DTransform(
              enableAnimation: true,
              rotationY: 0.05,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: SparshTheme.greenGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.list_alt,
                  size: ResponsiveUtil.getIconSize(context, 24),
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: ResponsiveUtil.scaledWidth(context, 16)),
            Text(
              'Schemes (${_filteredSchemes.length})',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtil.scaledFontSize(context, 20),
                fontWeight: FontWeight.w600,
                color: SparshTheme.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveUtil.scaledHeight(context, 16)),
        if (_filteredSchemes.isEmpty)
          _buildEmptyState()
        else
          ResponsiveGrid(
            mobileColumns: 1,
            tabletColumns: 2,
            desktopColumns: 3,
            spacing: 16,
            runSpacing: 16,
            children: _filteredSchemes.map((scheme) => _buildSchemeCard(scheme)).toList(),
          ),
      ],
    );
  }

  Widget _buildSchemeCard(Scheme scheme) {
    return Advanced3DCard(
      enableGlassMorphism: false,
      enableHover: true,
      enable3DTransform: true,
      elevation: 8,
      borderRadius: 20,
      backgroundColor: Colors.white,
      padding: ResponsiveUtil.scaledPadding(context, all: 20),
      onTap: () => _showSchemeDetails(scheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Advanced3DTransform(
                enableAnimation: true,
                rotationY: 0.1,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: scheme.type == SchemeType.primary
                        ? SparshTheme.primaryGradient
                        : SparshTheme.orangeGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    scheme.type.name.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveUtil.scaledFontSize(context, 10),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              _buildStatusIndicator(scheme.status),
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaledHeight(context, 16)),
          Text(
            scheme.schemeName,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtil.scaledFontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: SparshTheme.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: ResponsiveUtil.scaledHeight(context, 8)),
          Text(
            'Scheme No: ${scheme.schemeNo}',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtil.scaledFontSize(context, 12),
              color: SparshTheme.textSecondary,
            ),
          ),
          Text(
            'Sparsh No: ${scheme.sparshSchemeNo}',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtil.scaledFontSize(context, 12),
              color: SparshTheme.textSecondary,
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaledHeight(context, 12)),
          Container(
            height: 1,
            color: SparshTheme.borderGrey,
          ),
          SizedBox(height: ResponsiveUtil.scaledHeight(context, 12)),
          Row(
            children: [
              Icon(
                Icons.monetization_on,
                size: ResponsiveUtil.getIconSize(context, 16),
                color: SparshTheme.successGreen,
              ),
              SizedBox(width: ResponsiveUtil.scaledWidth(context, 4)),
              Text(
                '₹${scheme.schemeValue.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 18),
                  fontWeight: FontWeight.w600,
                  color: SparshTheme.successGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaledHeight(context, 8)),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: ResponsiveUtil.getIconSize(context, 14),
                color: SparshTheme.textSecondary,
              ),
              SizedBox(width: ResponsiveUtil.scaledWidth(context, 4)),
              Text(
                '${scheme.startDate.day}/${scheme.startDate.month}/${scheme.startDate.year} - ${scheme.endDate.day}/${scheme.endDate.month}/${scheme.endDate.year}',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                  color: SparshTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(SchemeStatus status) {
    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case SchemeStatus.active:
        statusColor = SparshTheme.successGreen;
        statusIcon = Icons.check_circle;
        break;
      case SchemeStatus.inactive:
        statusColor = SparshTheme.textSecondary;
        statusIcon = Icons.pause_circle;
        break;
      case SchemeStatus.pending:
        statusColor = SparshTheme.warningOrange;
        statusIcon = Icons.pending;
        break;
      case SchemeStatus.completed:
        statusColor = SparshTheme.primaryBlue;
        statusIcon = Icons.done_all;
        break;
    }
    
    return Advanced3DTransform(
      enableAnimation: true,
      rotationY: 0.1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              statusIcon,
              size: ResponsiveUtil.getIconSize(context, 12),
              color: statusColor,
            ),
            SizedBox(width: ResponsiveUtil.scaledWidth(context, 4)),
            Text(
              status.name.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtil.scaledFontSize(context, 10),
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Advanced3DCard(
      enableGlassMorphism: false,
      enableHover: false,
      enable3DTransform: false,
      elevation: 8,
      borderRadius: 20,
      backgroundColor: Colors.white,
      padding: ResponsiveUtil.scaledPadding(context, all: 40),
      child: Center(
        child: Column(
          children: [
            Advanced3DTransform(
              enableAnimation: true,
              rotationY: 0.1,
              child: Icon(
                Icons.search_off,
                size: ResponsiveUtil.getIconSize(context, 80),
                color: SparshTheme.textTertiary,
              ),
            ),
            SizedBox(height: ResponsiveUtil.scaledHeight(context, 16)),
            Text(
              'No schemes found',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtil.scaledFontSize(context, 18),
                fontWeight: FontWeight.w500,
                color: SparshTheme.textSecondary,
              ),
            ),
            SizedBox(height: ResponsiveUtil.scaledHeight(context, 8)),
            Text(
              'Try adjusting your search criteria or filters',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                color: SparshTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: SparshTheme.primaryBlue,
              onPrimary: Colors.white,
              onSurface: SparshTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        _filterSchemes();
      });
    }
  }

  void _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: SparshTheme.primaryBlue,
              onPrimary: Colors.white,
              onSurface: SparshTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
        _filterSchemes();
      });
    }
  }

  void _showSchemeDetails(Scheme scheme) {
    showDialog(
      context: context,
      builder: (context) => _buildSchemeDetailsDialog(scheme),
    );
  }

  Widget _buildSchemeDetailsDialog(Scheme scheme) {
    return Advanced3DTransform(
      enableAnimation: true,
      perspective: 0.003,
      rotationY: 0.05,
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Advanced3DTransform(
              enableAnimation: true,
              rotationY: 0.1,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: scheme.type == SchemeType.primary
                      ? SparshTheme.primaryGradient
                      : SparshTheme.orangeGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info,
                  color: Colors.white,
                  size: ResponsiveUtil.getIconSize(context, 20),
                ),
              ),
            ),
            SizedBox(width: ResponsiveUtil.scaledWidth(context, 12)),
            Expanded(
              child: Text(
                scheme.schemeName,
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 18),
                  fontWeight: FontWeight.w600,
                  color: SparshTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Scheme No:', scheme.schemeNo),
              _buildDetailRow('Sparsh No:', scheme.sparshSchemeNo),
              _buildDetailRow('Type:', scheme.type.name.toUpperCase()),
              _buildDetailRow('Value:', '₹${scheme.schemeValue.toStringAsFixed(2)}'),
              _buildDetailRow('Adjustment:', '₹${scheme.adjustmentAmount.toStringAsFixed(2)}'),
              _buildDetailRow('CN/DN Value:', '₹${scheme.cnDnValue.toStringAsFixed(2)}'),
              _buildDetailRow('CN/DN Doc:', scheme.cnDnDocumentNo),
              _buildDetailRow('Start Date:', '${scheme.startDate.day}/${scheme.startDate.month}/${scheme.startDate.year}'),
              _buildDetailRow('End Date:', '${scheme.endDate.day}/${scheme.endDate.month}/${scheme.endDate.year}'),
              _buildDetailRow('Status:', scheme.status.name.toUpperCase()),
              if (scheme.description.isNotEmpty) ...[
                SizedBox(height: ResponsiveUtil.scaledHeight(context, 16)),
                Text(
                  'Description:',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                    fontWeight: FontWeight.w600,
                    color: SparshTheme.textPrimary,
                  ),
                ),
                SizedBox(height: ResponsiveUtil.scaledHeight(context, 8)),
                Text(
                  scheme.description,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                    color: SparshTheme.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          AdvancedAnimatedContainer(
            duration: const Duration(milliseconds: 300),
            enableHover: true,
            enableScale: true,
            onTap: () => Navigator.of(context).pop(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: SparshTheme.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUtil.scaledHeight(context, 8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: ResponsiveUtil.scaledWidth(context, 100),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                fontWeight: FontWeight.w500,
                color: SparshTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                fontWeight: FontWeight.w600,
                color: SparshTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSchemeDialog() {
    showDialog(
      context: context,
      builder: (context) => Advanced3DTransform(
        enableAnimation: true,
        perspective: 0.003,
        rotationY: 0.05,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Advanced3DTransform(
                enableAnimation: true,
                rotationY: 0.1,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: SparshTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: ResponsiveUtil.getIconSize(context, 20),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUtil.scaledWidth(context, 12)),
              Text(
                'Add New Scheme',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 18),
                  fontWeight: FontWeight.w600,
                  color: SparshTheme.textPrimary,
                ),
              ),
            ],
          ),
          content: Text(
            'Add new scheme functionality will be implemented here.',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtil.scaledFontSize(context, 14),
              color: SparshTheme.textSecondary,
            ),
          ),
          actions: [
            AdvancedAnimatedContainer(
              duration: const Duration(milliseconds: 300),
              enableHover: true,
              enableScale: true,
              onTap: () => Navigator.of(context).pop(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: SparshTheme.borderGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                  fontWeight: FontWeight.w500,
                  color: SparshTheme.textSecondary,
                ),
              ),
            ),
            SizedBox(width: ResponsiveUtil.scaledWidth(context, 8)),
            AdvancedAnimatedContainer(
              duration: const Duration(milliseconds: 300),
              enableHover: true,
              enableScale: true,
              onTap: () => Navigator.of(context).pop(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: SparshTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Add',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}