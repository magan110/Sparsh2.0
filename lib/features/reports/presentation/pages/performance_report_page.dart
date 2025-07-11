import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/components/advanced_3d_components.dart';
import '../../../../core/components/advanced_animations.dart';
import '../../../../core/components/advanced_charts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_util.dart';

class PerformanceReportPage extends StatefulWidget {
  const PerformanceReportPage({Key? key}) : super(key: key);

  @override
  State<PerformanceReportPage> createState() => _PerformanceReportPageState();
}

class _PerformanceReportPageState extends State<PerformanceReportPage>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  String _selectedPeriod = 'Monthly';
  String _selectedDepartment = 'All';
  final ScrollController _scrollController = ScrollController();
  
  // Performance metrics data
  final List<PerformanceMetric> _kpiMetrics = [
    PerformanceMetric(
      name: 'Overall Performance',
      current: 87.5,
      target: 90.0,
      trend: 5.2,
      unit: '%',
      category: 'Overall',
    ),
    PerformanceMetric(
      name: 'Productivity Index',
      current: 94.2,
      target: 95.0,
      trend: 2.8,
      unit: '%',
      category: 'Productivity',
    ),
    PerformanceMetric(
      name: 'Quality Score',
      current: 91.8,
      target: 92.0,
      trend: 1.5,
      unit: '%',
      category: 'Quality',
    ),
    PerformanceMetric(
      name: 'Customer Satisfaction',
      current: 4.6,
      target: 4.8,
      trend: 0.3,
      unit: '/5',
      category: 'Customer',
    ),
  ];

  final List<ChartData> _performanceTrendData = [
    ChartData(label: 'Jan', y: 82.5),
    ChartData(label: 'Feb', y: 85.2),
    ChartData(label: 'Mar', y: 87.8),
    ChartData(label: 'Apr', y: 84.1),
    ChartData(label: 'May', y: 89.3),
    ChartData(label: 'Jun', y: 91.7),
  ];

  final List<ChartData> _departmentPerformance = [
    ChartData(label: 'Sales', y: 92.3),
    ChartData(label: 'Marketing', y: 88.7),
    ChartData(label: 'Support', y: 94.1),
    ChartData(label: 'Engineering', y: 89.5),
    ChartData(label: 'HR', y: 85.9),
  ];

  final List<ChartData> _teamProductivity = [
    ChartData(label: 'Team A', y: 95.2),
    ChartData(label: 'Team B', y: 87.8),
    ChartData(label: 'Team C', y: 91.4),
    ChartData(label: 'Team D', y: 88.6),
    ChartData(label: 'Team E', y: 93.1),
  ];

  final List<PerformanceEmployee> _topPerformers = [
    PerformanceEmployee(
      name: 'John Smith',
      department: 'Sales',
      score: 96.5,
      tasks: 45,
      achievements: 12,
    ),
    PerformanceEmployee(
      name: 'Sarah Johnson',
      department: 'Marketing',
      score: 94.8,
      tasks: 38,
      achievements: 10,
    ),
    PerformanceEmployee(
      name: 'Mike Chen',
      department: 'Engineering',
      score: 93.2,
      tasks: 52,
      achievements: 8,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadPerformanceData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPerformanceData() async {
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
          'Performance Report',
          style: TextStyle(
            fontSize: ResponsiveUtil.scaledFontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: SparshTheme.textPrimary,
          ),
        ),
        enableGlassMorphism: true,
        actions: [
          IconButton(
            icon: Icon(Icons.tune, color: SparshTheme.primaryBlue),
            onPressed: _showFilterDialog,
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
                text: 'Loading Performance Data...',
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadPerformanceData,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: ResponsiveUtil.scaledPadding(context, all: 16),
                  child: AdvancedStaggeredAnimation(
                    children: [
                      _buildFilterControls(),
                      SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
                      _buildKPIOverview(),
                      SizedBox(height: ResponsiveUtil.scaledSize(context, 24)),
                      _buildPerformanceCharts(),
                      SizedBox(height: ResponsiveUtil.scaledSize(context, 24)),
                      _buildDetailedMetrics(),
                      SizedBox(height: ResponsiveUtil.scaledSize(context, 24)),
                      _buildTopPerformers(),
                      SizedBox(height: ResponsiveUtil.scaledSize(context, 24)),
                      _buildPerformanceInsights(),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: Advanced3DFloatingActionButton(
        onPressed: _showPerformanceActions,
        child: Icon(Icons.analytics, color: Colors.white),
        backgroundColor: SparshTheme.primaryBlue,
      ),
    );
  }

  Widget _buildFilterControls() {
    return Advanced3DCard(
      enableGlassMorphism: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Filters',
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 16),
              fontWeight: FontWeight.bold,
              color: SparshTheme.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Period',
                      style: TextStyle(
                        fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                        color: SparshTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtil.scaledSize(context, 8)),
                    DropdownButtonFormField<String>(
                      value: _selectedPeriod,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtil.scaledSize(context, 8),
                          ),
                        ),
                        contentPadding: ResponsiveUtil.scaledPadding(
                          context, horizontal: 12, vertical: 8),
                      ),
                      items: ['Daily', 'Weekly', 'Monthly', 'Quarterly', 'Yearly']
                          .map((period) => DropdownMenuItem(
                                value: period,
                                child: Text(period),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPeriod = value!;
                        });
                        _loadPerformanceData();
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Department',
                      style: TextStyle(
                        fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                        color: SparshTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtil.scaledSize(context, 8)),
                    DropdownButtonFormField<String>(
                      value: _selectedDepartment,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtil.scaledSize(context, 8),
                          ),
                        ),
                        contentPadding: ResponsiveUtil.scaledPadding(
                          context, horizontal: 12, vertical: 8),
                      ),
                      items: ['All', 'Sales', 'Marketing', 'Support', 'Engineering', 'HR']
                          .map((dept) => DropdownMenuItem(
                                value: dept,
                                child: Text(dept),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDepartment = value!;
                        });
                        _loadPerformanceData();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKPIOverview() {
    return ResponsiveGrid(
      mobileColumns: 1,
      tabletColumns: 2,
      desktopColumns: 4,
      children: _kpiMetrics.map((metric) => _buildKPICard(metric)).toList(),
    );
  }

  Widget _buildKPICard(PerformanceMetric metric) {
    final progress = metric.current / metric.target;
    final isOnTarget = metric.current >= metric.target;
    
    return Advanced3DCard(
      enableGlassMorphism: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                metric.name,
                style: TextStyle(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                  fontWeight: FontWeight.w600,
                  color: SparshTheme.textPrimary,
                ),
              ),
              Icon(
                _getMetricIcon(metric.category),
                size: ResponsiveUtil.scaledSize(context, 20),
                color: SparshTheme.primaryBlue,
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          Text(
            '${metric.current.toStringAsFixed(1)}${metric.unit}',
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 24),
              fontWeight: FontWeight.bold,
              color: SparshTheme.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 4)),
          Text(
            'Target: ${metric.target.toStringAsFixed(1)}${metric.unit}',
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 12),
              color: SparshTheme.textSecondary,
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 12)),
          AdvancedProgressIndicator(
            progress: progress > 1.0 ? 1.0 : progress,
            progressColor: isOnTarget ? Colors.green : Colors.orange,
            backgroundColor: SparshTheme.borderGrey,
            showPercentage: false,
            height: ResponsiveUtil.scaledSize(context, 6),
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 8)),
          Row(
            children: [
              Icon(
                metric.trend >= 0 ? Icons.trending_up : Icons.trending_down,
                size: ResponsiveUtil.scaledSize(context, 16),
                color: metric.trend >= 0 ? Colors.green : Colors.red,
              ),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 4)),
              Text(
                '${metric.trend >= 0 ? '+' : ''}${metric.trend.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                  color: metric.trend >= 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCharts() {
    return ResponsiveBuilder(
      builder: (context, screenType) {
        if (screenType == ScreenType.mobile) {
          return Column(
            children: [
              _buildPerformanceTrendChart(),
              SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
              _buildDepartmentPerformanceChart(),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildPerformanceTrendChart(),
              ),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 16)),
              Expanded(
                flex: 1,
                child: _buildDepartmentPerformanceChart(),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildPerformanceTrendChart() {
    return Advanced3DChartContainer(
      title: 'Performance Trend',
      subtitle: 'Monthly performance over time',
      height: ResponsiveUtil.scaledSize(context, 300),
      chart: Advanced3DLineChart(
        data: _performanceTrendData,
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

  Widget _buildDepartmentPerformanceChart() {
    return Advanced3DChartContainer(
      title: 'Department Performance',
      subtitle: 'Performance by department',
      height: ResponsiveUtil.scaledSize(context, 300),
      chart: Advanced3DBarChart(
        data: _departmentPerformance,
        enableAnimation: true,
        show3DEffect: true,
        primaryColor: Colors.green,
      ),
    );
  }

  Widget _buildDetailedMetrics() {
    return Advanced3DCard(
      enableGlassMorphism: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Team Productivity',
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: SparshTheme.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          Advanced3DGaugeChart(
            value: 89.5,
            maxValue: 100,
            title: 'Overall Team Score',
            subtitle: 'Based on combined metrics',
            primaryColor: SparshTheme.primaryBlue,
            height: ResponsiveUtil.scaledSize(context, 200),
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 24)),
          Advanced3DBarChart(
            data: _teamProductivity,
            enableAnimation: true,
            show3DEffect: true,
            primaryColor: Colors.purple,
            height: ResponsiveUtil.scaledSize(context, 200),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformers() {
    return Advanced3DCard(
      enableGlassMorphism: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Performers',
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
          ...._topPerformers.map((employee) => _buildEmployeeCard(employee)),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(PerformanceEmployee employee) {
    return Advanced3DListTile(
      leading: CircleAvatar(
        backgroundColor: SparshTheme.primaryBlue.withOpacity(0.1),
        child: Text(
          employee.name.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: SparshTheme.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        employee.name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: SparshTheme.textPrimary,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            employee.department,
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 12),
              color: SparshTheme.textSecondary,
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 4)),
          Row(
            children: [
              Icon(
                Icons.task_alt,
                size: ResponsiveUtil.scaledSize(context, 12),
                color: SparshTheme.textTertiary,
              ),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 4)),
              Text(
                '${employee.tasks} tasks',
                style: TextStyle(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 10),
                  color: SparshTheme.textTertiary,
                ),
              ),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 12)),
              Icon(
                Icons.star,
                size: ResponsiveUtil.scaledSize(context, 12),
                color: Colors.amber,
              ),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 4)),
              Text(
                '${employee.achievements} achievements',
                style: TextStyle(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 10),
                  color: SparshTheme.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${employee.score.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: SparshTheme.primaryBlue,
            ),
          ),
          Container(
            padding: ResponsiveUtil.scaledPadding(context, 
              horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                ResponsiveUtil.scaledSize(context, 8),
              ),
            ),
            child: Text(
              'Excellent',
              style: TextStyle(
                fontSize: ResponsiveUtil.scaledFontSize(context, 10),
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceInsights() {
    return Advanced3DCard(
      enableGlassMorphism: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Insights',
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: SparshTheme.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          _buildInsightItem(
            icon: Icons.trending_up,
            title: 'Productivity Improvement',
            description: 'Team productivity has increased by 12% this quarter',
            color: Colors.green,
          ),
          _buildInsightItem(
            icon: Icons.warning,
            title: 'Attention Needed',
            description: 'Customer satisfaction score is below target',
            color: Colors.orange,
          ),
          _buildInsightItem(
            icon: Icons.star,
            title: 'Top Achievement',
            description: 'Sales team exceeded their quarterly goal by 15%',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Padding(
      padding: ResponsiveUtil.scaledPadding(context, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: ResponsiveUtil.scaledPadding(context, all: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                ResponsiveUtil.scaledSize(context, 8),
              ),
            ),
            child: Icon(
              icon,
              size: ResponsiveUtil.scaledSize(context, 20),
              color: color,
            ),
          ),
          SizedBox(width: ResponsiveUtil.scaledSize(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                    fontWeight: FontWeight.w600,
                    color: SparshTheme.textPrimary,
                  ),
                ),
                SizedBox(height: ResponsiveUtil.scaledSize(context, 4)),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                    color: SparshTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMetricIcon(String category) {
    switch (category) {
      case 'Overall':
        return Icons.dashboard;
      case 'Productivity':
        return Icons.speed;
      case 'Quality':
        return Icons.verified;
      case 'Customer':
        return Icons.sentiment_satisfied;
      default:
        return Icons.analytics;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Performance Filters'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select filters to customize your performance report'),
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
              _loadPerformanceData();
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
        title: Text('Export Performance Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select export format:'),
            ListTile(
              leading: Icon(Icons.picture_as_pdf),
              title: Text('PDF Report'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.table_chart),
              title: Text('Excel Spreadsheet'),
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

  void _showPerformanceActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: ResponsiveUtil.scaledPadding(context, all: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.assessment),
              title: Text('Performance Review'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Team Comparison'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.refresh),
              title: Text('Refresh Data'),
              onTap: () {
                Navigator.pop(context);
                _loadPerformanceData();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PerformanceMetric {
  final String name;
  final double current;
  final double target;
  final double trend;
  final String unit;
  final String category;

  PerformanceMetric({
    required this.name,
    required this.current,
    required this.target,
    required this.trend,
    required this.unit,
    required this.category,
  });
}

class PerformanceEmployee {
  final String name;
  final String department;
  final double score;
  final int tasks;
  final int achievements;

  PerformanceEmployee({
    required this.name,
    required this.department,
    required this.score,
    required this.tasks,
    required this.achievements,
  });
}