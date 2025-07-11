import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/components/advanced_3d_components.dart';
import '../../../../core/components/advanced_animations.dart';
import '../../../../core/components/advanced_charts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_util.dart';

class SalesReportPage extends StatefulWidget {
  const SalesReportPage({Key? key}) : super(key: key);

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedPeriod = 'Monthly';
  final ScrollController _scrollController = ScrollController();

  // Sample sales data
  final List<ChartData> _salesTrendData = [
    ChartData(label: 'Week 1', y: 45000),
    ChartData(label: 'Week 2', y: 52000),
    ChartData(label: 'Week 3', y: 48000),
    ChartData(label: 'Week 4', y: 58000),
    ChartData(label: 'Week 5', y: 62000),
  ];

  final List<ChartData> _productCategoryData = [
    ChartData(label: 'Electronics', y: 35.5),
    ChartData(label: 'Clothing', y: 28.2),
    ChartData(label: 'Home & Garden', y: 18.7),
    ChartData(label: 'Books', y: 12.3),
    ChartData(label: 'Sports', y: 5.3),
  ];

  final List<ChartData> _regionWiseData = [
    ChartData(label: 'North', y: 125000),
    ChartData(label: 'South', y: 98000),
    ChartData(label: 'East', y: 87000),
    ChartData(label: 'West', y: 112000),
    ChartData(label: 'Central', y: 76000),
  ];

  final List<SalesItem> _salesItems = [
    SalesItem(
      id: 'SO-2024-001',
      customer: 'Acme Corp',
      amount: 25000,
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: 'Completed',
      product: 'Enterprise Software',
    ),
    SalesItem(
      id: 'SO-2024-002',
      customer: 'Tech Solutions',
      amount: 18500,
      date: DateTime.now().subtract(const Duration(days: 2)),
      status: 'Pending',
      product: 'Cloud Services',
    ),
    SalesItem(
      id: 'SO-2024-003',
      customer: 'Global Industries',
      amount: 42000,
      date: DateTime.now().subtract(const Duration(days: 3)),
      status: 'Completed',
      product: 'Consulting Services',
    ),
    // Add more items as needed
  ];

  @override
  void initState() {
    super.initState();
    _loadSalesData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSalesData() async {
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
          'Sales Report',
          style: TextStyle(
            fontSize: ResponsiveUtil.scaledFontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: SparshTheme.textPrimary,
          ),
        ),
        enableGlassMorphism: true,
        actions: [
          IconButton(
            icon: Icon(Icons.date_range, color: SparshTheme.primaryBlue),
            onPressed: _showDateRangePicker,
          ),
          IconButton(
            icon: Icon(Icons.download, color: SparshTheme.primaryBlue),
            onPressed: _exportReport,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: AdvancedLoadingAnimation(
                size: ResponsiveUtil.scaledSize(context, 60),
                color: SparshTheme.primaryBlue,
                text: 'Loading Sales Data...',
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadSalesData,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: ResponsiveUtil.scaledPadding(context, all: 16),
                  child: AdvancedStaggeredAnimation(
                    children: [
                      _buildDateRangeSelector(),
                      SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
                      _buildSalesSummary(),
                      SizedBox(height: ResponsiveUtil.scaledSize(context, 24)),
                      _buildSalesCharts(),
                      SizedBox(height: ResponsiveUtil.scaledSize(context, 24)),
                      _buildTopPerformers(),
                      SizedBox(height: ResponsiveUtil.scaledSize(context, 24)),
                      _buildSalesTable(),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: Advanced3DFloatingActionButton(
        onPressed: _showQuickActions,
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: SparshTheme.primaryBlue,
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
            'Report Period',
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 16),
              fontWeight: FontWeight.bold,
              color: SparshTheme.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 12)),
          Row(
            children: [
              Expanded(
                child: _buildDateSelector(
                  'From',
                  _startDate,
                  (date) => setState(() => _startDate = date),
                ),
              ),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 16)),
              Expanded(
                child: _buildDateSelector(
                  'To',
                  _endDate,
                  (date) => setState(() => _endDate = date),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          Wrap(
            spacing: ResponsiveUtil.scaledSize(context, 8),
            children: ['Weekly', 'Monthly', 'Quarterly', 'Yearly'].map((period) {
              return ChoiceChip(
                label: Text(period),
                selected: _selectedPeriod == period,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedPeriod = period);
                    _updateDateRangeForPeriod(period);
                  }
                },
                selectedColor: SparshTheme.primaryBlue.withOpacity(0.2),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(String label, DateTime date, Function(DateTime) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUtil.scaledFontSize(context, 14),
            color: SparshTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: ResponsiveUtil.scaledSize(context, 8)),
        GestureDetector(
          onTap: () => _selectDate(date, onChanged),
          child: Container(
            padding: ResponsiveUtil.scaledPadding(context, 
              horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: SparshTheme.borderGrey),
              borderRadius: BorderRadius.circular(
                ResponsiveUtil.scaledSize(context, 8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy').format(date),
                  style: TextStyle(
                    fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                    color: SparshTheme.textPrimary,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: ResponsiveUtil.scaledSize(context, 16),
                  color: SparshTheme.primaryBlue,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSalesSummary() {
    return ResponsiveGrid(
      mobileColumns: 2,
      tabletColumns: 3,
      desktopColumns: 4,
      children: [
        _buildSummaryCard(
          title: 'Total Sales',
          value: '₹4,85,342',
          change: '+15.2%',
          isPositive: true,
          icon: Icons.trending_up,
          color: SparshTheme.primaryBlue,
        ),
        _buildSummaryCard(
          title: 'Orders',
          value: '1,247',
          change: '+8.7%',
          isPositive: true,
          icon: Icons.shopping_cart,
          color: Colors.green,
        ),
        _buildSummaryCard(
          title: 'Avg. Order Value',
          value: '₹3,892',
          change: '+2.1%',
          isPositive: true,
          icon: Icons.attach_money,
          color: Colors.orange,
        ),
        _buildSummaryCard(
          title: 'Conversion Rate',
          value: '3.24%',
          change: '-0.8%',
          isPositive: false,
          icon: Icons.percent,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required IconData icon,
    required Color color,
  }) {
    return Advanced3DCard(
      enableGlassMorphism: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                size: ResponsiveUtil.scaledSize(context, 24),
                color: color,
              ),
              Container(
                padding: ResponsiveUtil.scaledPadding(context, 
                  horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtil.scaledSize(context, 12),
                  ),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 14),
              color: SparshTheme.textSecondary,
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 4)),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 20),
              fontWeight: FontWeight.bold,
              color: SparshTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesCharts() {
    return ResponsiveBuilder(
      builder: (context, screenType) {
        if (screenType == ScreenType.mobile) {
          return Column(
            children: [
              _buildSalesTrendChart(),
              SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
              _buildProductCategoryChart(),
              SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
              _buildRegionWiseChart(),
            ],
          );
        } else {
          return Column(
            children: [
              _buildSalesTrendChart(),
              SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
              Row(
                children: [
                  Expanded(child: _buildProductCategoryChart()),
                  SizedBox(width: ResponsiveUtil.scaledSize(context, 16)),
                  Expanded(child: _buildRegionWiseChart()),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildSalesTrendChart() {
    return Advanced3DChartContainer(
      title: 'Sales Trend',
      subtitle: 'Revenue over time',
      height: ResponsiveUtil.scaledSize(context, 300),
      chart: Advanced3DLineChart(
        data: _salesTrendData,
        enableAnimation: true,
        enableInteraction: true,
        show3DEffect: true,
        primaryColor: SparshTheme.primaryBlue,
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.fullscreen, color: SparshTheme.primaryBlue),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildProductCategoryChart() {
    return Advanced3DChartContainer(
      title: 'Product Categories',
      subtitle: 'Sales by category (%)',
      height: ResponsiveUtil.scaledSize(context, 300),
      chart: Advanced3DPieChart(
        data: _productCategoryData,
        enableAnimation: true,
        show3DEffect: true,
      ),
    );
  }

  Widget _buildRegionWiseChart() {
    return Advanced3DChartContainer(
      title: 'Regional Sales',
      subtitle: 'Sales by region',
      height: ResponsiveUtil.scaledSize(context, 300),
      chart: Advanced3DBarChart(
        data: _regionWiseData,
        enableAnimation: true,
        show3DEffect: true,
        primaryColor: Colors.green,
      ),
    );
  }

  Widget _buildTopPerformers() {
    return Advanced3DCard(
      enableGlassMorphism: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Performers',
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
                    _buildPerformerCard('Top Product', 'Enterprise Software', '₹2,45,000'),
                    _buildPerformerCard('Top Customer', 'Global Industries', '₹1,87,500'),
                    _buildPerformerCard('Top Region', 'North Region', '₹1,25,000'),
                  ],
                );
              } else {
                return Row(
                  children: [
                    Expanded(child: _buildPerformerCard('Top Product', 'Enterprise Software', '₹2,45,000')),
                    SizedBox(width: ResponsiveUtil.scaledSize(context, 16)),
                    Expanded(child: _buildPerformerCard('Top Customer', 'Global Industries', '₹1,87,500')),
                    SizedBox(width: ResponsiveUtil.scaledSize(context, 16)),
                    Expanded(child: _buildPerformerCard('Top Region', 'North Region', '₹1,25,000')),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPerformerCard(String title, String name, String value) {
    return Container(
      margin: ResponsiveUtil.scaledPadding(context, vertical: 4),
      padding: ResponsiveUtil.scaledPadding(context, all: 16),
      decoration: BoxDecoration(
        color: SparshTheme.lightBlueBackground,
        borderRadius: BorderRadius.circular(ResponsiveUtil.scaledSize(context, 12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 12),
              color: SparshTheme.textSecondary,
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 4)),
          Text(
            name,
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 14),
              fontWeight: FontWeight.bold,
              color: SparshTheme.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 4)),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 16),
              fontWeight: FontWeight.bold,
              color: SparshTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesTable() {
    return Advanced3DCard(
      enableGlassMorphism: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Sales',
                style: TextStyle(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: SparshTheme.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text('View All'),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          ResponsiveBuilder(
            builder: (context, screenType) {
              if (screenType == ScreenType.mobile) {
                return Column(
                  children: _salesItems.map((item) => _buildSalesItemCard(item)).toList(),
                );
              } else {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Order ID')),
                      DataColumn(label: Text('Customer')),
                      DataColumn(label: Text('Product')),
                      DataColumn(label: Text('Amount')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: _salesItems.map((item) => DataRow(
                      cells: [
                        DataCell(Text(item.id)),
                        DataCell(Text(item.customer)),
                        DataCell(Text(item.product)),
                        DataCell(Text('₹${item.amount.toStringAsFixed(0)}')),
                        DataCell(Text(DateFormat('dd/MM/yyyy').format(item.date))),
                        DataCell(_buildStatusChip(item.status)),
                      ],
                    )).toList(),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSalesItemCard(SalesItem item) {
    return Advanced3DListTile(
      leading: CircleAvatar(
        backgroundColor: SparshTheme.primaryBlue.withOpacity(0.1),
        child: Icon(
          Icons.shopping_bag,
          color: SparshTheme.primaryBlue,
        ),
      ),
      title: Text(
        item.customer,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: SparshTheme.textPrimary,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${item.id} • ${item.product}',
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 12),
              color: SparshTheme.textSecondary,
            ),
          ),
          Text(
            DateFormat('dd/MM/yyyy').format(item.date),
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 12),
              color: SparshTheme.textTertiary,
            ),
          ),
        ],
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '₹${item.amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 16),
              fontWeight: FontWeight.bold,
              color: SparshTheme.textPrimary,
            ),
          ),
          _buildStatusChip(item.status),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: ResponsiveUtil.scaledPadding(context, 
        horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ResponsiveUtil.scaledSize(context, 12)),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: ResponsiveUtil.scaledFontSize(context, 10),
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showDateRangePicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Date Range'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose the date range for your sales report'),
            // Add date range picker here
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadSalesData();
            },
            child: Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _exportReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Sales Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select export format:'),
            ListTile(
              leading: Icon(Icons.picture_as_pdf),
              title: Text('PDF'),
              onTap: () => _exportToPDF(),
            ),
            ListTile(
              leading: Icon(Icons.table_chart),
              title: Text('Excel'),
              onTap: () => _exportToExcel(),
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

  void _exportToPDF() {
    Navigator.pop(context);
    // Implement PDF export
  }

  void _exportToExcel() {
    Navigator.pop(context);
    // Implement Excel export
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: ResponsiveUtil.scaledPadding(context, all: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.add_shopping_cart),
              title: Text('New Sale'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.refresh),
              title: Text('Refresh Data'),
              onTap: () {
                Navigator.pop(context);
                _loadSalesData();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(DateTime currentDate, Function(DateTime) onChanged) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != currentDate) {
      onChanged(picked);
      _loadSalesData();
    }
  }

  void _updateDateRangeForPeriod(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'Weekly':
        _startDate = now.subtract(const Duration(days: 7));
        _endDate = now;
        break;
      case 'Monthly':
        _startDate = DateTime(now.year, now.month - 1, now.day);
        _endDate = now;
        break;
      case 'Quarterly':
        _startDate = DateTime(now.year, now.month - 3, now.day);
        _endDate = now;
        break;
      case 'Yearly':
        _startDate = DateTime(now.year - 1, now.month, now.day);
        _endDate = now;
        break;
    }
    _loadSalesData();
  }
}

class SalesItem {
  final String id;
  final String customer;
  final double amount;
  final DateTime date;
  final String status;
  final String product;

  SalesItem({
    required this.id,
    required this.customer,
    required this.amount,
    required this.date,
    required this.status,
    required this.product,
  });
}