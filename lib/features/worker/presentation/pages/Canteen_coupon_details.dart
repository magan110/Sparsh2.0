import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/components/advanced_3d_components.dart';
import '../../../../core/utils/responsive_util.dart';

class CanteenCouponDetails extends StatefulWidget {
  const CanteenCouponDetails({super.key});

  @override
  State<CanteenCouponDetails> createState() => _CanteenCouponDetailsState();
}

class _CanteenCouponDetailsState extends State<CanteenCouponDetails> 
    with TickerProviderStateMixin {
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  String couponType = 'Select';
  String userType = 'Personnel';
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final ScrollController _horizontalHeaderScrollController = ScrollController();
  final ScrollController _horizontalBodyScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final List<Map<String, dynamic>> _dummyData = [];
  final TextEditingController _searchController = TextEditingController();

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
    
    _generateDummyData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _horizontalHeaderScrollController.addListener(_syncHeaderScroll);
      _horizontalBodyScrollController.addListener(_syncBodyScroll);
    });
    _animationController.forward();
  }

  void _syncHeaderScroll() {
    if (_horizontalHeaderScrollController.offset != _horizontalBodyScrollController.offset) {
      _horizontalBodyScrollController.jumpTo(_horizontalHeaderScrollController.offset);
    }
  }

  void _syncBodyScroll() {
    if (_horizontalBodyScrollController.offset != _horizontalHeaderScrollController.offset) {
      _horizontalHeaderScrollController.jumpTo(_horizontalBodyScrollController.offset);
    }
  }

  void _generateDummyData() {
    final departments = ['HR', 'Finance', 'IT', 'Operations', 'Marketing'];
    final names = [
      'John Doe',
      'Jane Smith',
      'Robert Johnson',
      'Emily Davis',
      'Michael Wilson'
    ];

    for (int i = 0; i < 50; i++) {
      _dummyData.add({
        'fNo': 'F${1000 + i}',
        'docDate': DateFormat('dd/MM/yyyy').format(DateTime.now().subtract(Duration(days: i))),
        'scannedBy': 'Scanner ${i + 1}',
        'empCode': 'EMP${100 + i}',
        'empName': names[i % names.length],
        'deptCode': 'DEPT${i % 5 + 1}',
        'deptName': departments[i % departments.length],
        'food': i % 2 == 0 ? 'Yes' : 'No',
        'tea': i % 3 == 0 ? 'Yes' : 'No',
        'namkeen': i % 4 == 0 ? 'Yes' : 'No',
        'packed': i % 5 == 0 ? 'Yes' : 'No',
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _horizontalHeaderScrollController.dispose();
    _horizontalBodyScrollController.dispose();
    _verticalScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? fromDate : toDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final columnWidths = [90.0, 130.0, 130.0, 130.0, 160.0, 135.0, 160.0, 85.0, 85.0, 95.0, 115.0];
    final totalWidth = columnWidths.reduce((sum, width) => sum + width);

    return Scaffold(
      backgroundColor: SparshTheme.scaffoldBackground,
      appBar: Advanced3DAppBar(
        title: Text(
          'Canteen Coupon Detail',
          style: SparshTypography.heading5.copyWith(color: Colors.white),
        ),
        backgroundColor: SparshTheme.primaryBlue,
        enableGlassMorphism: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: ResponsiveUtil.scaledPadding(context, all: 16),
          child: Column(
            children: [
              _buildFilterSection(),
              SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
              _buildStatusCard(),
              SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
              _buildSearchSection(),
              SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
              _buildDataTable(columnWidths, totalWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Advanced3DCard(
      enableGlassMorphism: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color: SparshTheme.primaryBlue,
                size: ResponsiveUtil.scaledSize(context, 24),
              ),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 8)),
              Text(
                'Filter Options',
                style: SparshTypography.heading6.copyWith(
                  color: SparshTheme.primaryBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  context,
                  'From Date',
                  fromDate,
                  true,
                ),
              ),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 16)),
              Expanded(
                child: _buildDateField(
                  context,
                  'To Date',
                  toDate,
                  false,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  'Official/Personnel',
                  userType,
                  ['Official', 'Personnel'],
                  (value) => setState(() => userType = value!),
                ),
              ),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 16)),
              Expanded(
                child: _buildDropdownField(
                  'Coupon Type',
                  couponType,
                  ['Select', 'Food', 'Tea', 'Namkeen'],
                  (value) => setState(() => couponType = value!),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildStatusCard() {
    return Advanced3DCard(
      enableGlassMorphism: false,
      backgroundColor: SparshTheme.primaryBlue.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: SparshTheme.primaryBlue,
                size: ResponsiveUtil.scaledSize(context, 24),
              ),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 8)),
              Text(
                'Status Information',
                style: SparshTypography.heading6.copyWith(
                  color: SparshTheme.primaryBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          Row(
            children: [
              Expanded(
                child: _buildStatusItem(
                  'Total Records',
                  '${_dummyData.length}',
                  SparshTheme.primaryBlue,
                ),
              ),
              Expanded(
                child: _buildStatusItem(
                  'Food Coupons',
                  '${_dummyData.where((e) => e['food'] == 'Yes').length}',
                  SparshTheme.successGreen,
                ),
              ),
              Expanded(
                child: _buildStatusItem(
                  'Tea Coupons',
                  '${_dummyData.where((e) => e['tea'] == 'Yes').length}',
                  SparshTheme.warningOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideY(begin: 0.2);
  }

  Widget _buildSearchSection() {
    return Advanced3DCard(
      enableGlassMorphism: false,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Search records...',
          hintText: 'Enter employee name or code',
          prefixIcon: Icon(Icons.search, color: SparshTheme.primaryBlue),
          labelStyle: SparshTypography.bodyMedium.copyWith(
            color: SparshTheme.textSecondary,
          ),
          hintStyle: SparshTypography.bodyMedium.copyWith(
            color: SparshTheme.textTertiary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SparshBorderRadius.md),
            borderSide: BorderSide(color: SparshTheme.borderGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SparshBorderRadius.md),
            borderSide: BorderSide(color: SparshTheme.primaryBlue, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SparshBorderRadius.md),
            borderSide: BorderSide(color: SparshTheme.borderGrey),
          ),
          filled: true,
          fillColor: SparshTheme.cardBackground,
          contentPadding: ResponsiveUtil.scaledPadding(context, all: 16),
        ),
        style: SparshTypography.bodyMedium,
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.2);
  }

  Widget _buildDataTable(List<double> columnWidths, double totalWidth) {
    return Expanded(
      child: Advanced3DCard(
        enableGlassMorphism: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.table_chart,
                  color: SparshTheme.primaryBlue,
                  size: ResponsiveUtil.scaledSize(context, 24),
                ),
                SizedBox(width: ResponsiveUtil.scaledSize(context, 8)),
                Text(
                  'Coupon Records',
                  style: SparshTypography.heading6.copyWith(
                    color: SparshTheme.primaryBlue,
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: SparshTheme.borderGrey),
                  borderRadius: BorderRadius.circular(SparshBorderRadius.md),
                ),
                child: Column(
                  children: [
                    _buildTableHeader(columnWidths, totalWidth),
                    Expanded(
                      child: _buildTableBody(columnWidths, totalWidth),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 0.2),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Container(
      padding: ResponsiveUtil.scaledPadding(context, all: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(SparshBorderRadius.md),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: SparshTypography.heading5.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 4)),
          Text(
            label,
            style: SparshTypography.bodySmall.copyWith(
              color: SparshTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
    String label,
    DateTime date,
    bool isFromDate,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: SparshTheme.cardBackground,
        borderRadius: BorderRadius.circular(SparshBorderRadius.md),
        boxShadow: SparshShadows.sm,
      ),
      child: InkWell(
        onTap: () => _selectDate(context, isFromDate),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: SparshTypography.bodyMedium.copyWith(
              color: SparshTheme.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SparshBorderRadius.md),
              borderSide: BorderSide(color: SparshTheme.borderGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SparshBorderRadius.md),
              borderSide: BorderSide(color: SparshTheme.borderGrey),
            ),
            filled: true,
            fillColor: SparshTheme.cardBackground,
            contentPadding: ResponsiveUtil.scaledPadding(context, all: 16),
          ),
          child: Text(
            DateFormat('dd/MM/yyyy').format(date),
            style: SparshTypography.bodyMedium,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: SparshTheme.cardBackground,
        borderRadius: BorderRadius.circular(SparshBorderRadius.md),
        boxShadow: SparshShadows.sm,
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: SparshTypography.bodyMedium.copyWith(
            color: SparshTheme.textSecondary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SparshBorderRadius.md),
            borderSide: BorderSide(color: SparshTheme.borderGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SparshBorderRadius.md),
            borderSide: BorderSide(color: SparshTheme.primaryBlue, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SparshBorderRadius.md),
            borderSide: BorderSide(color: SparshTheme.borderGrey),
          ),
          filled: true,
          fillColor: SparshTheme.cardBackground,
          contentPadding: ResponsiveUtil.scaledPadding(context, all: 16),
        ),
        value: value,
        style: SparshTypography.bodyMedium,
        dropdownColor: SparshTheme.cardBackground,
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, style: SparshTypography.bodyMedium),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTableHeader(List<double> columnWidths, double totalWidth) {
    final headers = [
      'S.No',
      'Doc Date',
      'Scanned By',
      'Emp Code',
      'Employee Name',
      'Dept Code',
      'Department Name',
      'Food',
      'Tea',
      'Namkeen',
      'Packed'
    ];

    return Container(
      decoration: BoxDecoration(
        color: SparshTheme.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(SparshBorderRadius.md),
          topRight: Radius.circular(SparshBorderRadius.md),
        ),
      ),
      padding: ResponsiveUtil.scaledPadding(context, vertical: 12),
      child: SingleChildScrollView(
        controller: _horizontalHeaderScrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: headers.asMap().entries.map((entry) {
            final index = entry.key;
            final header = entry.value;
            return Container(
              width: columnWidths[index],
              alignment: Alignment.center,
              child: Text(
                header,
                style: SparshTypography.labelLarge.copyWith(
                  color: SparshTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTableBody(List<double> columnWidths, double totalWidth) {
    return Scrollbar(
      controller: _verticalScrollController,
      child: SingleChildScrollView(
        controller: _verticalScrollController,
        child: SingleChildScrollView(
          controller: _horizontalBodyScrollController,
          scrollDirection: Axis.horizontal,
          child: Column(
            children: _dummyData.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              final isEven = index % 2 == 0;
              
              return Container(
                decoration: BoxDecoration(
                  color: isEven ? SparshTheme.cardBackground : SparshTheme.scaffoldBackground,
                  border: Border(
                    bottom: BorderSide(
                      color: SparshTheme.borderGrey,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    _buildTableCell('${index + 1}', columnWidths[0]),
                    _buildTableCell(data['docDate'], columnWidths[1]),
                    _buildTableCell(data['scannedBy'], columnWidths[2]),
                    _buildTableCell(data['empCode'], columnWidths[3]),
                    _buildTableCell(data['empName'], columnWidths[4]),
                    _buildTableCell(data['deptCode'], columnWidths[5]),
                    _buildTableCell(data['deptName'], columnWidths[6]),
                    _buildTableCell(data['food'], columnWidths[7]),
                    _buildTableCell(data['tea'], columnWidths[8]),
                    _buildTableCell(data['namkeen'], columnWidths[9]),
                    _buildTableCell(data['packed'], columnWidths[10]),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, double width) {
    return Container(
      width: width,
      padding: ResponsiveUtil.scaledPadding(context, all: 12),
      alignment: Alignment.center,
      child: Text(
        text,
        style: SparshTypography.bodyMedium,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}