import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/components/advanced_3d_components.dart';
import '../../../../core/components/advanced_animations.dart';
import '../../../../core/components/advanced_charts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_util.dart';

class UserAnalyticsPage extends StatefulWidget {
  const UserAnalyticsPage({Key? key}) : super(key: key);

  @override
  State<UserAnalyticsPage> createState() => _UserAnalyticsPageState();
}

class _UserAnalyticsPageState extends State<UserAnalyticsPage>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  String _selectedTimeRange = '7 days';
  String _selectedSegment = 'All Users';
  final ScrollController _scrollController = ScrollController();

  // User analytics data
  final List<UserMetric> _userMetrics = [
    UserMetric(
      name: 'Total Users',
      current: 12847,
      previous: 11932,
      unit: '',
      category: 'Users',
    ),
    UserMetric(
      name: 'Active Users',
      current: 8945,
      previous: 8124,
      unit: '',
      category: 'Active',
    ),
    UserMetric(
      name: 'Session Duration',
      current: 284.5,
      previous: 267.2,
      unit: 'sec',
      category: 'Engagement',
    ),
    UserMetric(
      name: 'Bounce Rate',
      current: 32.4,
      previous: 35.8,
      unit: '%',
      category: 'Engagement',
    ),
  ];

  final List<ChartData> _userGrowthData = [
    ChartData(label: 'Week 1', y: 1250),
    ChartData(label: 'Week 2', y: 1420),
    ChartData(label: 'Week 3', y: 1380),
    ChartData(label: 'Week 4', y: 1650),
    ChartData(label: 'Week 5', y: 1890),
  ];

  final List<ChartData> _deviceDistribution = [
    ChartData(label: 'Mobile', y: 52.3),
    ChartData(label: 'Desktop', y: 32.1),
    ChartData(label: 'Tablet', y: 15.6),
  ];

  final List<ChartData> _userBehaviorData = [
    ChartData(label: 'Page Views', y: 45200),
    ChartData(label: 'Sessions', y: 28400),
    ChartData(label: 'Clicks', y: 18900),
    ChartData(label: 'Conversions', y: 1250),
  ];

  final List<UserSegment> _userSegments = [
    UserSegment(
      name: 'New Users',
      count: 3245,
      percentage: 25.2,
      color: Colors.green,
    ),
    UserSegment(
      name: 'Returning Users',
      count: 7580,
      percentage: 59.0,
      color: Colors.blue,
    ),
    UserSegment(
      name: 'Power Users',
      count: 2022,
      percentage: 15.8,
      color: Colors.purple,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserAnalytics();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserAnalytics() async {
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
          'User Analytics',
          style: TextStyle(
            fontSize: ResponsiveUtil.scaledFontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: SparshTheme.textPrimary,
          ),
        ),
        enableGlassMorphism: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: SparshTheme.primaryBlue),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: Icon(Icons.share, color: SparshTheme.primaryBlue),
            onPressed: _shareReport,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: AdvancedLoadingAnimation(
                size: ResponsiveUtil.scaledSize(context, 60),
                color: SparshTheme.primaryBlue,
                text: 'Loading User Analytics...',
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadUserAnalytics,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: ResponsiveUtil.scaledPadding(context, all: 16),
                  child: AdvancedStaggeredAnimation(
                    children: [
                      _buildAnalyticsControls(),
                      SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
                      _buildUserMetrics(),
                      SizedBox(height: ResponsiveUtil.scaledSize(context, 24)),
                      _buildUserGrowthChart(),
                      SizedBox(height: ResponsiveUtil.scaledSize(context, 24)),
                      _buildDeviceAndBehaviorCharts(),
                      SizedBox(height: ResponsiveUtil.scaledSize(context, 24)),
                      _buildUserSegmentation(),
                      SizedBox(height: ResponsiveUtil.scaledSize(context, 24)),
                      _buildUserJourney(),
                      SizedBox(height: ResponsiveUtil.scaledSize(context, 24)),
                      _buildRealTimeActivity(),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: Advanced3DFloatingActionButton(
        onPressed: _showUserActions,
        child: Icon(Icons.people, color: Colors.white),
        backgroundColor: SparshTheme.primaryBlue,
      ),
    );
  }

  Widget _buildAnalyticsControls() {
    return Advanced3DCard(
      enableGlassMorphism: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics Settings',
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
                      'Time Range',
                      style: TextStyle(
                        fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                        color: SparshTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtil.scaledSize(context, 8)),
                    Wrap(
                      spacing: ResponsiveUtil.scaledSize(context, 8),
                      children: ['7 days', '30 days', '90 days', '1 year']
                          .map((range) => ChoiceChip(
                                label: Text(range),
                                selected: _selectedTimeRange == range,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _selectedTimeRange = range);
                                    _loadUserAnalytics();
                                  }
                                },
                                selectedColor: SparshTheme.primaryBlue.withOpacity(0.2),
                              ))
                          .toList(),
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
                      'User Segment',
                      style: TextStyle(
                        fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                        color: SparshTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtil.scaledSize(context, 8)),
                    DropdownButtonFormField<String>(
                      value: _selectedSegment,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtil.scaledSize(context, 8),
                          ),
                        ),
                        contentPadding: ResponsiveUtil.scaledPadding(
                          context, horizontal: 12, vertical: 8),
                      ),
                      items: ['All Users', 'New Users', 'Returning Users', 'Power Users']
                          .map((segment) => DropdownMenuItem(
                                value: segment,
                                child: Text(segment),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedSegment = value!);
                        _loadUserAnalytics();
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

  Widget _buildUserMetrics() {
    return ResponsiveGrid(
      mobileColumns: 2,
      tabletColumns: 3,
      desktopColumns: 4,
      children: _userMetrics.map((metric) => _buildMetricCard(metric)).toList(),
    );
  }

  Widget _buildMetricCard(UserMetric metric) {
    final change = metric.current - metric.previous;
    final changePercent = ((change / metric.previous) * 100);
    final isPositive = change > 0;
    final isGoodChange = (metric.category == 'Engagement' && metric.name == 'Bounce Rate') 
        ? !isPositive 
        : isPositive;
    
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
                _getUserMetricIcon(metric.category),
                size: ResponsiveUtil.scaledSize(context, 20),
                color: SparshTheme.primaryBlue,
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          Text(
            metric.unit == 'sec' 
                ? '${(metric.current / 60).toStringAsFixed(1)}m'
                : '${NumberFormat('#,###').format(metric.current.toInt())}${metric.unit}',
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 20),
              fontWeight: FontWeight.bold,
              color: SparshTheme.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 8)),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                size: ResponsiveUtil.scaledSize(context, 16),
                color: isGoodChange ? Colors.green : Colors.red,
              ),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 4)),
              Text(
                '${changePercent.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                  color: isGoodChange ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserGrowthChart() {
    return Advanced3DChartContainer(
      title: 'User Growth Trend',
      subtitle: 'New user acquisitions over time',
      height: ResponsiveUtil.scaledSize(context, 300),
      chart: Advanced3DLineChart(
        data: _userGrowthData,
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

  Widget _buildDeviceAndBehaviorCharts() {
    return ResponsiveBuilder(
      builder: (context, screenType) {
        if (screenType == ScreenType.mobile) {
          return Column(
            children: [
              _buildDeviceDistributionChart(),
              SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
              _buildUserBehaviorChart(),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(child: _buildDeviceDistributionChart()),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 16)),
              Expanded(child: _buildUserBehaviorChart()),
            ],
          );
        }
      },
    );
  }

  Widget _buildDeviceDistributionChart() {
    return Advanced3DChartContainer(
      title: 'Device Distribution',
      subtitle: 'User device preferences',
      height: ResponsiveUtil.scaledSize(context, 300),
      chart: Advanced3DPieChart(
        data: _deviceDistribution,
        enableAnimation: true,
        show3DEffect: true,
      ),
    );
  }

  Widget _buildUserBehaviorChart() {
    return Advanced3DChartContainer(
      title: 'User Behavior',
      subtitle: 'User interaction metrics',
      height: ResponsiveUtil.scaledSize(context, 300),
      chart: Advanced3DBarChart(
        data: _userBehaviorData,
        enableAnimation: true,
        show3DEffect: true,
        primaryColor: Colors.purple,
      ),
    );
  }

  Widget _buildUserSegmentation() {
    return Advanced3DCard(
      enableGlassMorphism: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Segmentation',
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: SparshTheme.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          ..._userSegments.map((segment) => _buildSegmentCard(segment)),
        ],
      ),
    );
  }

  Widget _buildSegmentCard(UserSegment segment) {
    return Container(
      margin: ResponsiveUtil.scaledPadding(context, vertical: 8),
      padding: ResponsiveUtil.scaledPadding(context, all: 16),
      decoration: BoxDecoration(
        color: segment.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ResponsiveUtil.scaledSize(context, 12)),
        border: Border.all(
          color: segment.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: ResponsiveUtil.scaledSize(context, 40),
            height: ResponsiveUtil.scaledSize(context, 40),
            decoration: BoxDecoration(
              color: segment.color,
              borderRadius: BorderRadius.circular(ResponsiveUtil.scaledSize(context, 20)),
            ),
            child: Icon(
              _getSegmentIcon(segment.name),
              color: Colors.white,
              size: ResponsiveUtil.scaledSize(context, 20),
            ),
          ),
          SizedBox(width: ResponsiveUtil.scaledSize(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  segment.name,
                  style: TextStyle(
                    fontSize: ResponsiveUtil.scaledFontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    color: SparshTheme.textPrimary,
                  ),
                ),
                SizedBox(height: ResponsiveUtil.scaledSize(context, 4)),
                Text(
                  '${NumberFormat('#,###').format(segment.count)} users',
                  style: TextStyle(
                    fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                    color: SparshTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${segment.percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: segment.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserJourney() {
    return Advanced3DCard(
      enableGlassMorphism: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Journey Flow',
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: SparshTheme.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          _buildJourneyStep('Landing Page', '12,847 users', 100.0, true),
          _buildJourneyStep('Product View', '8,945 users', 69.6, false),
          _buildJourneyStep('Add to Cart', '3,452 users', 26.9, false),
          _buildJourneyStep('Checkout', '1,834 users', 14.3, false),
          _buildJourneyStep('Purchase', '1,247 users', 9.7, false),
        ],
      ),
    );
  }

  Widget _buildJourneyStep(String step, String users, double percentage, bool isFirst) {
    return Container(
      margin: ResponsiveUtil.scaledPadding(context, vertical: 4),
      child: Row(
        children: [
          Container(
            width: ResponsiveUtil.scaledSize(context, 12),
            height: ResponsiveUtil.scaledSize(context, 12),
            decoration: BoxDecoration(
              color: SparshTheme.primaryBlue,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: ResponsiveUtil.scaledSize(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step,
                  style: TextStyle(
                    fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                    fontWeight: FontWeight.w600,
                    color: SparshTheme.textPrimary,
                  ),
                ),
                SizedBox(height: ResponsiveUtil.scaledSize(context, 4)),
                Row(
                  children: [
                    Text(
                      users,
                      style: TextStyle(
                        fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                        color: SparshTheme.textSecondary,
                      ),
                    ),
                    SizedBox(width: ResponsiveUtil.scaledSize(context, 16)),
                    Container(
                      width: ResponsiveUtil.scaledSize(context, 60),
                      height: ResponsiveUtil.scaledSize(context, 4),
                      decoration: BoxDecoration(
                        color: SparshTheme.borderGrey,
                        borderRadius: BorderRadius.circular(ResponsiveUtil.scaledSize(context, 2)),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: percentage / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            color: SparshTheme.primaryBlue,
                            borderRadius: BorderRadius.circular(ResponsiveUtil.scaledSize(context, 2)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: ResponsiveUtil.scaledSize(context, 8)),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                        color: SparshTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealTimeActivity() {
    return Advanced3DCard(
      enableGlassMorphism: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Real-Time Activity',
                style: TextStyle(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: SparshTheme.textPrimary,
                ),
              ),
              Container(
                padding: ResponsiveUtil.scaledPadding(context, 
                  horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ResponsiveUtil.scaledSize(context, 16)),
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
          _buildActivityItem('Active Users', '247', Colors.green),
          _buildActivityItem('Page Views/min', '1,429', Colors.blue),
          _buildActivityItem('New Sessions', '89', Colors.orange),
          _buildActivityItem('Conversions', '12', Colors.purple),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String value, Color color) {
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
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 16),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getUserMetricIcon(String category) {
    switch (category) {
      case 'Users':
        return Icons.people;
      case 'Active':
        return Icons.person_add;
      case 'Engagement':
        return Icons.timeline;
      default:
        return Icons.analytics;
    }
  }

  IconData _getSegmentIcon(String segmentName) {
    switch (segmentName) {
      case 'New Users':
        return Icons.person_add;
      case 'Returning Users':
        return Icons.replay;
      case 'Power Users':
        return Icons.star;
      default:
        return Icons.person;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Analytics Filters'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Customize your user analytics view'),
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
              _loadUserAnalytics();
            },
            child: Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _shareReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Share Analytics Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Share this report with your team'),
            // Add sharing options here
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Share'),
          ),
        ],
      ),
    );
  }

  void _showUserActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: ResponsiveUtil.scaledPadding(context, all: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.segment),
              title: Text('Create Segment'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.campaign),
              title: Text('User Campaign'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.refresh),
              title: Text('Refresh Data'),
              onTap: () {
                Navigator.pop(context);
                _loadUserAnalytics();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class UserMetric {
  final String name;
  final double current;
  final double previous;
  final String unit;
  final String category;

  UserMetric({
    required this.name,
    required this.current,
    required this.previous,
    required this.unit,
    required this.category,
  });
}

class UserSegment {
  final String name;
  final int count;
  final double percentage;
  final Color color;

  UserSegment({
    required this.name,
    required this.count,
    required this.percentage,
    required this.color,
  });
}