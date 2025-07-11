import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/components/advanced_3d_components.dart';
import '../../../../core/components/advanced_animations.dart';
import '../../../../core/components/advanced_charts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_util.dart';

class FinancialReportPage extends StatefulWidget {
  const FinancialReportPage({Key? key}) : super(key: key);

  @override
  State<FinancialReportPage> createState() => _FinancialReportPageState();
}

class _FinancialReportPageState extends State<FinancialReportPage>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  String _selectedPeriod = 'Monthly';
  String _selectedView = 'Summary';
  final ScrollController _scrollController = ScrollController();

  // Financial data
  final List<FinancialMetric> _keyMetrics = [
    FinancialMetric(
      name: 'Total Revenue',
      current: 2450000,
      previous: 2180000,
      unit: '₹',
      category: 'Revenue',
    ),
    FinancialMetric(
      name: 'Net Profit',
      current: 485000,
      previous: 420000,
      unit: '₹',
      category: 'Profit',
    ),
    FinancialMetric(
      name: 'Total Expenses',
      current: 1965000,
      previous: 1760000,
      unit: '₹',
      category: 'Expenses',
    ),
    FinancialMetric(
      name: 'Cash Flow',
      current: 520000,
      previous: 380000,
      unit: '₹',
      category: 'Cash Flow',
    ),
  ];

  final List<ChartData> _revenueData = [
    ChartData(label: 'Q1', y: 2100000),
    ChartData(label: 'Q2', y: 2350000),
    ChartData(label: 'Q3', y: 2180000),
    ChartData(label: 'Q4', y: 2450000),
  ];

  final List<ChartData> _expenseBreakdown = [
    ChartData(label: 'Operational', y: 45.2),
    ChartData(label: 'Marketing', y: 18.7),
    ChartData(label: 'Technology', y: 15.3),
    ChartData(label: 'Personnel', y: 12.8),
    ChartData(label: 'Other', y: 8.0),
  ];

  final List<ChartData> _profitMargins = [
    ChartData(label: 'Jan', y: 18.5),
    ChartData(label: 'Feb', y: 19.2),
    ChartData(label: 'Mar', y: 17.8),
    ChartData(label: 'Apr', y: 20.1),
    ChartData(label: 'May', y: 19.7),
    ChartData(label: 'Jun', y: 21.3),
  ];

  final List<FinancialTransaction> _recentTransactions = [
    FinancialTransaction(
      id: 'TXN-001',
      description: 'Client Payment - Acme Corp',
      amount: 150000,
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: 'Income',
      category: 'Revenue',
    ),
    FinancialTransaction(
      id: 'TXN-002',
      description: 'Office Rent Payment',
      amount: -25000,
      date: DateTime.now().subtract(const Duration(days: 2)),
      type: 'Expense',
      category: 'Operational',
    ),
    FinancialTransaction(
      id: 'TXN-003',
      description: 'Marketing Campaign',
      amount: -15000,
      date: DateTime.now().subtract(const Duration(days: 3)),
      type: 'Expense',
      category: 'Marketing',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadFinancialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFinancialData() async {
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
          'Financial Report',
          style: TextStyle(
            fontSize: ResponsiveUtil.scaledFontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: SparshTheme.textPrimary,
          ),
        ),
        enableGlassMorphism: true,
        actions: [
          IconButton(
            icon: Icon(Icons.calculate, color: SparshTheme.primaryBlue),
            onPressed: _showFinancialCalculator,
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
                text: 'Loading Financial Data...',
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadFinancialData,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: ResponsiveUtil.scaledPadding(context, all: 16),
                  child: AdvancedStaggeredAnimation(
                    children: [
                      _buildViewSelector(),
                      SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
                      _buildFinancialSummary(),
                      SizedBox(height: ResponsiveUtil.scaledSize(context, 24)),
                      _buildFinancialCharts(),
                      SizedBox(height: ResponsiveUtil.scaledSize(context, 24)),
                      _buildBudgetVsActual(),
                      SizedBox(height: ResponsiveUtil.scaledSize(context, 24)),
                      _buildRecentTransactions(),
                      SizedBox(height: ResponsiveUtil.scaledSize(context, 24)),
                      _buildFinancialRatios(),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: Advanced3DFloatingActionButton(
        onPressed: _showFinancialActions,
        child: Icon(Icons.account_balance, color: Colors.white),
        backgroundColor: SparshTheme.primaryBlue,
      ),
    );
  }

  Widget _buildViewSelector() {
    return Advanced3DCard(
      enableGlassMorphism: true,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Financial View',
                  style: TextStyle(
                    fontSize: ResponsiveUtil.scaledFontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    color: SparshTheme.textPrimary,
                  ),
                ),
                SizedBox(height: ResponsiveUtil.scaledSize(context, 8)),
                Wrap(
                  spacing: ResponsiveUtil.scaledSize(context, 8),
                  children: ['Summary', 'P&L', 'Cash Flow', 'Balance Sheet']
                      .map((view) => ChoiceChip(
                            label: Text(view),
                            selected: _selectedView == view,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedView = view);
                                _loadFinancialData();
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Period',
                style: TextStyle(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                  color: SparshTheme.textSecondary,
                ),
              ),
              SizedBox(height: ResponsiveUtil.scaledSize(context, 8)),
              DropdownButton<String>(
                value: _selectedPeriod,
                items: ['Monthly', 'Quarterly', 'Yearly']
                    .map((period) => DropdownMenuItem(
                          value: period,
                          child: Text(period),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedPeriod = value!);
                  _loadFinancialData();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary() {
    return ResponsiveGrid(
      mobileColumns: 2,
      tabletColumns: 3,
      desktopColumns: 4,
      children: _keyMetrics.map((metric) => _buildFinancialCard(metric)).toList(),
    );
  }

  Widget _buildFinancialCard(FinancialMetric metric) {
    final change = metric.current - metric.previous;
    final changePercent = ((change / metric.previous) * 100);
    final isPositive = change > 0;
    
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
                _getFinancialIcon(metric.category),
                size: ResponsiveUtil.scaledSize(context, 20),
                color: SparshTheme.primaryBlue,
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          Text(
            '${metric.unit}${NumberFormat('#,##,###').format(metric.current)}',
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
                color: isPositive ? Colors.green : Colors.red,
              ),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 4)),
              Text(
                '${isPositive ? '+' : ''}${NumberFormat('#,##,###').format(change)}',
                style: TextStyle(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                  color: isPositive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 4)),
          Text(
            '${changePercent.toStringAsFixed(1)}% from last period',
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 10),
              color: SparshTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCharts() {
    return ResponsiveBuilder(
      builder: (context, screenType) {
        if (screenType == ScreenType.mobile) {
          return Column(
            children: [
              _buildRevenueChart(),
              SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
              _buildExpenseBreakdownChart(),
              SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
              _buildProfitMarginsChart(),
            ],
          );
        } else {
          return Column(
            children: [
              _buildRevenueChart(),
              SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
              Row(
                children: [
                  Expanded(child: _buildExpenseBreakdownChart()),
                  SizedBox(width: ResponsiveUtil.scaledSize(context, 16)),
                  Expanded(child: _buildProfitMarginsChart()),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildRevenueChart() {
    return Advanced3DChartContainer(
      title: 'Revenue Trend',
      subtitle: 'Quarterly revenue performance',
      height: ResponsiveUtil.scaledSize(context, 300),
      chart: Advanced3DLineChart(
        data: _revenueData,
        enableAnimation: true,
        enableInteraction: true,
        show3DEffect: true,
        primaryColor: Colors.green,
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.fullscreen, color: SparshTheme.primaryBlue),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildExpenseBreakdownChart() {
    return Advanced3DChartContainer(
      title: 'Expense Breakdown',
      subtitle: 'Distribution of expenses (%)',
      height: ResponsiveUtil.scaledSize(context, 300),
      chart: Advanced3DPieChart(
        data: _expenseBreakdown,
        enableAnimation: true,
        show3DEffect: true,
      ),
    );
  }

  Widget _buildProfitMarginsChart() {
    return Advanced3DChartContainer(
      title: 'Profit Margins',
      subtitle: 'Monthly profit margin trends',
      height: ResponsiveUtil.scaledSize(context, 300),
      chart: Advanced3DBarChart(
        data: _profitMargins,
        enableAnimation: true,
        show3DEffect: true,
        primaryColor: Colors.orange,
      ),
    );
  }

  Widget _buildBudgetVsActual() {
    return Advanced3DCard(
      enableGlassMorphism: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget vs Actual',
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: SparshTheme.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          _buildBudgetItem('Revenue', 2500000, 2450000),
          _buildBudgetItem('Expenses', 1800000, 1965000),
          _buildBudgetItem('Profit', 700000, 485000),
          _buildBudgetItem('Marketing', 180000, 185000),
        ],
      ),
    );
  }

  Widget _buildBudgetItem(String category, double budget, double actual) {
    final variance = actual - budget;
    final variancePercent = ((variance / budget) * 100);
    final isOverBudget = actual > budget;
    
    return Padding(
      padding: ResponsiveUtil.scaledPadding(context, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: TextStyle(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                  fontWeight: FontWeight.w600,
                  color: SparshTheme.textPrimary,
                ),
              ),
              Row(
                children: [
                  Text(
                    '₹${NumberFormat('#,##,###').format(actual)}',
                    style: TextStyle(
                      fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                      fontWeight: FontWeight.bold,
                      color: SparshTheme.textPrimary,
                    ),
                  ),
                  SizedBox(width: ResponsiveUtil.scaledSize(context, 8)),
                  Container(
                    padding: ResponsiveUtil.scaledPadding(context, 
                      horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isOverBudget ? Colors.red : Colors.green).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtil.scaledSize(context, 8),
                      ),
                    ),
                    child: Text(
                      '${isOverBudget ? '+' : ''}${variancePercent.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: ResponsiveUtil.scaledFontSize(context, 10),
                        color: isOverBudget ? Colors.red : Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 8)),
          Row(
            children: [
              Text(
                'Budget: ₹${NumberFormat('#,##,###').format(budget)}',
                style: TextStyle(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                  color: SparshTheme.textSecondary,
                ),
              ),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 16)),
              Text(
                'Variance: ₹${NumberFormat('#,##,###').format(variance.abs())}',
                style: TextStyle(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                  color: isOverBudget ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 8)),
          AdvancedProgressIndicator(
            progress: actual / budget,
            progressColor: isOverBudget ? Colors.red : Colors.green,
            backgroundColor: SparshTheme.borderGrey,
            showPercentage: false,
            height: ResponsiveUtil.scaledSize(context, 4),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Advanced3DCard(
      enableGlassMorphism: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
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
          ..._recentTransactions.map((transaction) => _buildTransactionItem(transaction)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(FinancialTransaction transaction) {
    final isIncome = transaction.amount > 0;
    
    return Advanced3DListTile(
      leading: CircleAvatar(
        backgroundColor: (isIncome ? Colors.green : Colors.red).withOpacity(0.1),
        child: Icon(
          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
          color: isIncome ? Colors.green : Colors.red,
        ),
      ),
      title: Text(
        transaction.description,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: SparshTheme.textPrimary,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${transaction.id} • ${transaction.category}',
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 12),
              color: SparshTheme.textSecondary,
            ),
          ),
          Text(
            DateFormat('dd MMM yyyy').format(transaction.date),
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 10),
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
            '₹${NumberFormat('#,##,###').format(transaction.amount.abs())}',
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 16),
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
          Container(
            padding: ResponsiveUtil.scaledPadding(context, 
              horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: (isIncome ? Colors.green : Colors.red).withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                ResponsiveUtil.scaledSize(context, 8),
              ),
            ),
            child: Text(
              transaction.type,
              style: TextStyle(
                fontSize: ResponsiveUtil.scaledFontSize(context, 10),
                color: isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRatios() {
    return Advanced3DCard(
      enableGlassMorphism: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Ratios',
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: SparshTheme.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          ResponsiveGrid(
            mobileColumns: 2,
            tabletColumns: 3,
            desktopColumns: 4,
            children: [
              _buildRatioCard('ROI', '19.8%', Colors.green),
              _buildRatioCard('Debt to Equity', '0.65', Colors.orange),
              _buildRatioCard('Current Ratio', '2.3', Colors.blue),
              _buildRatioCard('Quick Ratio', '1.8', Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatioCard(String title, String value, Color color) {
    return Container(
      padding: ResponsiveUtil.scaledPadding(context, all: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
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
            value,
            style: TextStyle(
              fontSize: ResponsiveUtil.scaledFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFinancialIcon(String category) {
    switch (category) {
      case 'Revenue':
        return Icons.trending_up;
      case 'Profit':
        return Icons.account_balance;
      case 'Expenses':
        return Icons.trending_down;
      case 'Cash Flow':
        return Icons.attach_money;
      default:
        return Icons.account_balance_wallet;
    }
  }

  void _showFinancialCalculator() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Financial Calculator'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose a calculation:'),
            ListTile(
              leading: Icon(Icons.percent),
              title: Text('ROI Calculator'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.trending_up),
              title: Text('Growth Rate'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.calculate),
              title: Text('Break-even Analysis'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _exportReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Financial Report'),
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

  void _showFinancialActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: ResponsiveUtil.scaledPadding(context, all: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Add Transaction'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.budget),
              title: Text('Budget Planning'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.refresh),
              title: Text('Refresh Data'),
              onTap: () {
                Navigator.pop(context);
                _loadFinancialData();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class FinancialMetric {
  final String name;
  final double current;
  final double previous;
  final String unit;
  final String category;

  FinancialMetric({
    required this.name,
    required this.current,
    required this.previous,
    required this.unit,
    required this.category,
  });
}

class FinancialTransaction {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String type;
  final String category;

  FinancialTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
  });
}