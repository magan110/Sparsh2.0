import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:learning2/features/dashboard/presentation/pages/All_Tokens.dart';
import '../../../../core/components/advanced_3d_components.dart';
import '../../../../core/components/advanced_animations.dart';
import '../../../../core/components/advanced_charts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_util.dart';

class TokenReportScreen extends StatefulWidget {
  final String activeTab;
  const TokenReportScreen({super.key, this.activeTab = 'Report'});

  @override
  _TokenReportScreenState createState() => _TokenReportScreenState();
}

class _TokenReportScreenState extends State<TokenReportScreen>
    with TickerProviderStateMixin {
  DateTime? startDate;
  DateTime? endDate;
  bool _isLoading = false;
  late AnimationController _animationController;

  // Sample token data for charts
  final List<ChartData> _tokenScanData = [
    ChartData(label: 'Week 1', y: 245),
    ChartData(label: 'Week 2', y: 320),
    ChartData(label: 'Week 3', y: 185),
    ChartData(label: 'Week 4', y: 410),
  ];

  final List<ChartData> _categoryData = [
    ChartData(label: 'Electronics', y: 35.2),
    ChartData(label: 'Clothing', y: 28.5),
    ChartData(label: 'Books', y: 18.3),
    ChartData(label: 'Home', y: 18.0),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime initialDate =
        isStartDate ? startDate ?? DateTime.now() : endDate ?? DateTime.now();
    DateTime firstDate = DateTime(2020);
    DateTime lastDate = DateTime(2030);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: SparshTheme.primaryBlue,
              onPrimary: Colors.white,
              surface: SparshTheme.cardBackground,
              onSurface: SparshTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> _loadTokenData() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SparshTheme.scaffoldBackground,
      appBar: Advanced3DAppBar(
        title: Text(
          'Token Report',
          style: TextStyle(
            fontSize: ResponsiveUtil.scaledFontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: SparshTheme.textPrimary,
          ),
        ),
        enableGlassMorphism: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: SparshTheme.primaryBlue,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.download,
              color: SparshTheme.primaryBlue,
            ),
            onPressed: _exportReport,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: AdvancedLoadingAnimation(
                size: ResponsiveUtil.scaledSize(context, 60),
                color: SparshTheme.primaryBlue,
                text: 'Loading Token Data...',
              ),
            )
          : Column(
              children: [
                _buildTopNav(context, widget.activeTab),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadTokenData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: ResponsiveUtil.scaledPadding(context, all: 16),
                        child: AdvancedStaggeredAnimation(
                          children: [
                            _buildReportHeader(),
                            SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
                            _buildDateRangeSelector(),
                            SizedBox(height: ResponsiveUtil.scaledSize(context, 24)),
                            _buildTokenAnalytics(),
                            SizedBox(height: ResponsiveUtil.scaledSize(context, 24)),
                            _buildCategorySection(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: Advanced3DFloatingActionButton(
        onPressed: _showTokenActions,
        child: Icon(Icons.qr_code_scanner, color: Colors.white),
        backgroundColor: SparshTheme.primaryBlue,
      ),
    );
  }

  Widget _buildReportHeader() {
    return Advanced3DCard(
      enableGlassMorphism: true,
      child: Column(
        children: [
          Icon(
            Icons.security,
            size: ResponsiveUtil.scaledSize(context, 48),
            color: SparshTheme.primaryBlue,
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          Text(
            "Token Scan Details",
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 20),
              fontWeight: FontWeight.bold,
              color: SparshTheme.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 8)),
          Container(
            padding: ResponsiveUtil.scaledPadding(context, 
              horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                ResponsiveUtil.scaledSize(context, 16),
              ),
            ),
            child: Text(
              "CONFIDENTIAL",
              style: TextStyle(
                fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Advanced3DCard(
      enableGlassMorphism: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Date Range",
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: SparshTheme.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          ResponsiveBuilder(
            builder: (context, screenType) {
              if (screenType == ScreenType.mobile) {
                return Column(
                  children: [
                    _buildDateField("Start Date", startDate, true),
                    SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
                    _buildDateField("End Date", endDate, false),
                  ],
                );
              } else {
                return Row(
                  children: [
                    Expanded(child: _buildDateField("Start Date", startDate, true)),
                    SizedBox(width: ResponsiveUtil.scaledSize(context, 16)),
                    Expanded(child: _buildDateField("End Date", endDate, false)),
                  ],
                );
              }
            },
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (startDate != null && endDate != null) {
                      _loadTokenData();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Please select both start and end date",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SparshTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtil.scaledSize(context, 12),
                      ),
                    ),
                    padding: ResponsiveUtil.scaledPadding(context, 
                      horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    "Check Now",
                    style: TextStyle(
                      fontSize: ResponsiveUtil.scaledFontSize(context, 16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 16)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "From: ${startDate != null ? DateFormat("dd/MM/yyyy").format(startDate!) : '--/--/----'}",
                    style: TextStyle(
                      fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                      color: SparshTheme.textSecondary,
                    ),
                  ),
                  Text(
                    "To: ${endDate != null ? DateFormat("dd/MM/yyyy").format(endDate!) : '--/--/----'}",
                    style: TextStyle(
                      fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                      color: SparshTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? date, bool isStartDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUtil.scaledFontSize(context, 14),
            fontWeight: FontWeight.w600,
            color: SparshTheme.textPrimary,
          ),
        ),
        SizedBox(height: ResponsiveUtil.scaledSize(context, 8)),
        GestureDetector(
          onTap: () => _selectDate(context, isStartDate),
          child: Container(
            padding: ResponsiveUtil.scaledPadding(context, 
              horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: SparshTheme.cardBackground,
              border: Border.all(color: SparshTheme.borderGrey),
              borderRadius: BorderRadius.circular(
                ResponsiveUtil.scaledSize(context, 12),
              ),
              boxShadow: [
                BoxShadow(
                  color: SparshTheme.primaryBlue.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null
                      ? DateFormat("dd/MM/yyyy").format(date)
                      : "Select Date",
                  style: TextStyle(
                    fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                    color: date != null 
                        ? SparshTheme.textPrimary 
                        : SparshTheme.textSecondary,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: ResponsiveUtil.scaledSize(context, 20),
                  color: SparshTheme.primaryBlue,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTokenAnalytics() {
    return ResponsiveBuilder(
      builder: (context, screenType) {
        if (screenType == ScreenType.mobile) {
          return Column(
            children: [
              _buildTokenScanChart(),
              SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
              _buildCategoryChart(),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(child: _buildTokenScanChart()),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 16)),
              Expanded(child: _buildCategoryChart()),
            ],
          );
        }
      },
    );
  }

  Widget _buildTokenScanChart() {
    return Advanced3DChartContainer(
      title: 'Token Scan Trends',
      subtitle: 'Weekly scan activity',
      height: ResponsiveUtil.scaledSize(context, 300),
      chart: Advanced3DLineChart(
        data: _tokenScanData,
        enableAnimation: true,
        enableInteraction: true,
        show3DEffect: true,
        primaryColor: SparshTheme.primaryBlue,
      ),
    );
  }

  Widget _buildCategoryChart() {
    return Advanced3DChartContainer(
      title: 'Category Distribution',
      subtitle: 'Token scans by category',
      height: ResponsiveUtil.scaledSize(context, 300),
      chart: Advanced3DPieChart(
        data: _categoryData,
        enableAnimation: true,
        show3DEffect: true,
      ),
    );
  }

  Widget _buildCategorySection() {
    return Advanced3DCard(
      enableGlassMorphism: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: ResponsiveUtil.scaledPadding(context, all: 16),
            decoration: BoxDecoration(
              color: SparshTheme.primaryBlue,
              borderRadius: BorderRadius.circular(
                ResponsiveUtil.scaledSize(context, 12),
              ),
            ),
            child: Text(
              "Categories",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveUtil.scaledFontSize(context, 18),
              ),
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          Container(
            height: ResponsiveUtil.scaledSize(context, 200),
            decoration: BoxDecoration(
              border: Border.all(color: SparshTheme.borderGrey),
              borderRadius: BorderRadius.circular(
                ResponsiveUtil.scaledSize(context, 12),
              ),
            ),
            child: ListView.separated(
              padding: ResponsiveUtil.scaledPadding(context, all: 8),
              itemCount: _categoryData.length,
              separatorBuilder: (context, index) => Divider(
                color: SparshTheme.borderGrey,
                thickness: 1,
              ),
              itemBuilder: (context, index) {
                final category = _categoryData[index];
                return Advanced3DListTile(
                  leading: CircleAvatar(
                    backgroundColor: SparshTheme.primaryBlue.withOpacity(0.1),
                    child: Icon(
                      _getCategoryIcon(category.label),
                      color: SparshTheme.primaryBlue,
                    ),
                  ),
                  title: Text(
                    category.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: SparshTheme.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    "${category.y.toStringAsFixed(1)}% of total scans",
                    style: TextStyle(
                      color: SparshTheme.textSecondary,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: SparshTheme.textTertiary,
                  ),
                  onTap: () {
                    // Navigate to category details
                  },
                );
              },
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: SparshTheme.textSecondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtil.scaledSize(context, 12),
                  ),
                ),
                padding: ResponsiveUtil.scaledPadding(context, 
                  horizontal: 24, vertical: 12),
              ),
              child: Text(
                "Close",
                style: TextStyle(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNav(BuildContext context, String activeTab) {
    return Container(
      margin: ResponsiveUtil.scaledPadding(context, all: 8),
      decoration: BoxDecoration(
        color: SparshTheme.cardBackground,
        borderRadius: BorderRadius.circular(ResponsiveUtil.scaledSize(context, 12)),
        boxShadow: [
          BoxShadow(
            color: SparshTheme.primaryBlue.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            context,
            'Report',
            activeTab == 'Report',
            const TokenReportScreen(activeTab: 'Report'),
          ),
          _navItem(
            context,
            'All Tokens',
            activeTab == 'All Tokens',
            const AllTokens(),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    String label,
    bool isActive,
    Widget targetPage,
  ) {
    return GestureDetector(
      onTap: () {
        if (!isActive) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => targetPage),
          );
        }
      },
      child: Container(
        padding: ResponsiveUtil.scaledPadding(context, 
          horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? SparshTheme.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(ResponsiveUtil.scaledSize(context, 10)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : SparshTheme.textPrimary,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: ResponsiveUtil.scaledFontSize(context, 16),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return Icons.electrical_services;
      case 'clothing':
        return Icons.checkroom;
      case 'books':
        return Icons.book;
      case 'home':
        return Icons.home;
      default:
        return Icons.category;
    }
  }

  void _exportReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Token Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select export format:'),
            ListTile(
              leading: Icon(Icons.picture_as_pdf),
              title: Text('PDF'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.table_chart),
              title: Text('Excel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showTokenActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: ResponsiveUtil.scaledPadding(context, all: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.qr_code_scanner),
              title: Text('Scan New Token'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.refresh),
              title: Text('Refresh Data'),
              onTap: () {
                Navigator.pop(context);
                _loadTokenData();
              },
            ),
            ListTile(
              leading: Icon(Icons.analytics),
              title: Text('Advanced Analytics'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
