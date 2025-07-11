import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/components/advanced_3d_components.dart';
import '../../../../core/components/advanced_animations.dart';
import '../../../../core/components/advanced_charts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_util.dart';

class AnalyticsDashboardPage extends StatefulWidget {
  const AnalyticsDashboardPage({Key? key}) : super(key: key);

  @override
  State<AnalyticsDashboardPage> createState() => _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState extends State<AnalyticsDashboardPage>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  late AnimationController _refreshController;
  final ScrollController _scrollController = ScrollController();

  // Sample data - in a real app, this would come from your data source
  final List<ChartData> _salesData = [
    ChartData(label: 'Jan', y: 15000),
    ChartData(label: 'Feb', y: 18000),
    ChartData(label: 'Mar', y: 22000),
    ChartData(label: 'Apr', y: 19000),
    ChartData(label: 'May', y: 25000),
    ChartData(label: 'Jun', y: 28000),
  ];

  final List<ChartData> _userAnalyticsData = [
    ChartData(label: 'Desktop', y: 45.2),
    ChartData(label: 'Mobile', y: 38.7),
    ChartData(label: 'Tablet', y: 16.1),
  ];

  final List<ChartData> _performanceData = [
    ChartData(label: 'Q1', y: 85.5),
    ChartData(label: 'Q2', y: 92.3),
    ChartData(label: 'Q3', y: 78.9),
    ChartData(label: 'Q4', y: 94.1),
  ];

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _loadData();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    _refreshController.forward();
    await _loadData();
    _refreshController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SparshTheme.scaffoldBackground,
      appBar: Advanced3DAppBar(
        title: Text(
          'Analytics Dashboard',
          style: TextStyle(
            fontSize: ResponsiveUtil.scaledFontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: SparshTheme.textPrimary,
          ),
        ),
        enableGlassMorphism: true,
        actions: [
          IconButton(
            icon: AnimatedBuilder(
              animation: _refreshController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _refreshController.value * 2 * 3.14159,
                  child: Icon(
                    Icons.refresh,
                    color: SparshTheme.primaryBlue,
                  ),
                );
              },
            ),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: Icon(
              Icons.filter_alt_outlined,
              color: SparshTheme.primaryBlue,
            ),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: AdvancedLoadingAnimation(
                size: ResponsiveUtil.scaledSize(context, 60),
                color: SparshTheme.primaryBlue,
                text: 'Loading Analytics...',
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: ResponsiveUtil.scaledPadding(context, all: 16),
                  child: AdvancedStaggeredAnimation(
                    children: [
                      _buildMetricsOverview(),
                      SizedBox(height: ResponsiveUtil.scaledSize(context, 24)),
                      _buildChartsSection(),
                      SizedBox(height: ResponsiveUtil.scaledSize(context, 24)),
                      _buildRealtimeMetrics(),
                      SizedBox(height: ResponsiveUtil.scaledSize(context, 24)),
                      _buildDetailedAnalytics(),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: Advanced3DFloatingActionButton(
        onPressed: () => _showExportDialog(),
        child: Icon(Icons.download, color: Colors.white),
        backgroundColor: SparshTheme.primaryBlue,
      ),
    );
  }

  Widget _buildMetricsOverview() {
    return ResponsiveBuilder(
      builder: (context, screenType) {
        int crossAxisCount = screenType == ScreenType.mobile
            ? 2
            : screenType == ScreenType.tablet
                ? 3
                : 4;
        
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: ResponsiveUtil.scaledSize(context, 16),
          crossAxisSpacing: ResponsiveUtil.scaledSize(context, 16),
          childAspectRatio: 1.2,
          children: [
            _buildMetricCard(
              title: 'Total Revenue',
              value: '₹1,24,567',
              change: '+12.5%',
              isPositive: true,
              icon: Icons.attach_money,
              delay: 0,
            ),
            _buildMetricCard(
              title: 'Active Users',
              value: '8,942',
              change: '+8.3%',
              isPositive: true,
              icon: Icons.people,
              delay: 100,
            ),
            _buildMetricCard(
              title: 'Conversion Rate',
              value: '3.24%',
              change: '-2.1%',
              isPositive: false,
              icon: Icons.trending_up,
              delay: 200,
            ),
            _buildMetricCard(
              title: 'Avg. Session',
              value: '4:32',
              change: '+5.7%',
              isPositive: true,
              icon: Icons.timer,
              delay: 300,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required IconData icon,
    required int delay,
  }) {
    return AdvancedAnimatedContainer(
      duration: Duration(milliseconds: 300 + delay),
      enableSlideAnimation: true,
      slideOffset: const Offset(0, 0.5),
      child: Advanced3DCard(
        enableGlassMorphism: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: ResponsiveUtil.scaledSize(context, 32),
              color: SparshTheme.primaryBlue,
            ),
            SizedBox(height: ResponsiveUtil.scaledSize(context, 8)),
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                color: SparshTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtil.scaledSize(context, 4)),
            Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveUtil.scaledFontSize(context, 18),
                color: SparshTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ResponsiveUtil.scaledSize(context, 4)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: ResponsiveUtil.scaledSize(context, 16),
                  color: isPositive ? Colors.green : Colors.red,
                ),
                SizedBox(width: ResponsiveUtil.scaledSize(context, 4)),
                Text(
                  change,
                  style: TextStyle(
                    fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection() {
    return ResponsiveBuilder(
      builder: (context, screenType) {
        if (screenType == ScreenType.mobile) {
          return Column(
            children: [
              _buildSalesChart(),
              SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
              _buildUserAnalyticsChart(),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildSalesChart(),
              ),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 16)),
              Expanded(
                flex: 1,
                child: _buildUserAnalyticsChart(),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildSalesChart() {
    return Advanced3DChartContainer(
      title: 'Sales Trends',
      subtitle: 'Monthly Revenue (₹)',
      height: ResponsiveUtil.scaledSize(context, 350),
      chart: Advanced3DLineChart(
        data: _salesData,
        enableAnimation: true,
        enableInteraction: true,
        show3DEffect: true,
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.fullscreen, color: SparshTheme.primaryBlue),
          onPressed: () => _showFullscreenChart('Sales Trends', _salesData),
        ),
      ],
    );
  }

  Widget _buildUserAnalyticsChart() {
    return Advanced3DChartContainer(
      title: 'User Analytics',
      subtitle: 'Device Distribution',
      height: ResponsiveUtil.scaledSize(context, 350),
      chart: Advanced3DPieChart(
        data: _userAnalyticsData,
        enableAnimation: true,
        show3DEffect: true,
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.fullscreen, color: SparshTheme.primaryBlue),
          onPressed: () => _showFullscreenChart('User Analytics', _userAnalyticsData),
        ),
      ],
    );
  }

  Widget _buildRealtimeMetrics() {
    return Advanced3DCard(
      enableGlassMorphism: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Real-time Metrics',
                    style: TextStyle(
                      fontSize: ResponsiveUtil.scaledFontSize(context, 18),
                      fontWeight: FontWeight.bold,
                      color: SparshTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Updated: ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                    style: TextStyle(
                      fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                      color: SparshTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: ResponsiveUtil.scaledPadding(context, 
                  horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtil.scaledSize(context, 16),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: ResponsiveUtil.scaledSize(context, 8),
                      height: ResponsiveUtil.scaledSize(context, 8),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: ResponsiveUtil.scaledSize(context, 8)),
                    Text(
                      'Live',
                      style: TextStyle(
                        fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          _buildRealtimeMetricItem('Active Sessions', '142', '+5'),
          _buildRealtimeMetricItem('Page Views', '1,847', '+23'),
          _buildRealtimeMetricItem('Online Users', '89', '+2'),
          _buildRealtimeMetricItem('Bounce Rate', '32.4%', '-1.2%'),
        ],
      ),
    );
  }

  Widget _buildRealtimeMetricItem(String title, String value, String change) {
    return Padding(
      padding: ResponsiveUtil.scaledPadding(context, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 14),
              color: SparshTheme.textSecondary,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 16),
                  fontWeight: FontWeight.bold,
                  color: SparshTheme.textPrimary,
                ),
              ),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 8)),
              Text(
                change,
                style: TextStyle(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                  color: change.startsWith('+') ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedAnalytics() {
    return Advanced3DCard(
      enableGlassMorphism: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Overview',
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: SparshTheme.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          Advanced3DBarChart(
            data: _performanceData,
            enableAnimation: true,
            show3DEffect: true,
            height: ResponsiveUtil.scaledSize(context, 200),
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          _buildPerformanceMetrics(),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Column(
      children: [
        _buildProgressItem('Load Time', 2.3, 5.0, 'seconds'),
        _buildProgressItem('Performance Score', 89, 100, 'points'),
        _buildProgressItem('SEO Score', 95, 100, 'points'),
        _buildProgressItem('Accessibility', 78, 100, 'points'),
      ],
    );
  }

  Widget _buildProgressItem(String title, double current, double max, String unit) {
    return Padding(
      padding: ResponsiveUtil.scaledPadding(context, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                  color: SparshTheme.textSecondary,
                ),
              ),
              Text(
                '$current $unit',
                style: TextStyle(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                  fontWeight: FontWeight.bold,
                  color: SparshTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 8)),
          AdvancedProgressIndicator(
            progress: current / max,
            height: ResponsiveUtil.scaledSize(context, 6),
            progressColor: SparshTheme.primaryBlue,
            backgroundColor: SparshTheme.borderGrey,
            showPercentage: false,
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter Analytics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select date range and metrics to filter'),
            // Add filter options here
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
              // Apply filters
            },
            child: Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Analytics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose export format:'),
            // Add export options here
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
              // Export data
            },
            child: Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showFullscreenChart(String title, List<ChartData> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: SparshTheme.cardBackground,
          ),
          body: Padding(
            padding: ResponsiveUtil.scaledPadding(context, all: 16),
            child: Advanced3DLineChart(
              data: data,
              enableAnimation: true,
              enableInteraction: true,
              show3DEffect: true,
            ),
          ),
        ),
      ),
    );
  }
}