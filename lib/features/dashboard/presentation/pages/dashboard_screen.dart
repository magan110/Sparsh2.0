import 'package:flutter/material.dart';
import 'package:learning2/core/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learning2/core/components/advanced_3d/advanced_3d_components.dart';
import 'package:learning2/core/utils/responsive_design.dart';
import 'package:learning2/core/utils/form_validators/form_validators.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
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
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: SparshTheme.scaffoldBackground,
        body: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: ResponsiveSpacing.large(context)),
                      _buildAdvanced3DHeader(),
                      SizedBox(height: ResponsiveSpacing.large(context)),
                      const Advanced3DCreditLimitScreen(),
                      SizedBox(height: ResponsiveSpacing.medium(context)),
                      const Advanced3DPrimarySaleScreen(),
                      SizedBox(height: ResponsiveSpacing.medium(context)),
                      const Advanced3DSecondarySaleScreen(),
                      SizedBox(height: ResponsiveSpacing.medium(context)),
                      const Advanced3DMyNetworkScreen(),
                      SizedBox(height: ResponsiveSpacing.xxLarge(context)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAdvanced3DHeader() {
    return Advanced3DCard(
      margin: ResponsiveSpacing.paddingHorizontalMedium(context),
      elevation: 12,
      borderRadius: 24,
      enableGlassMorphism: true,
      backgroundColor: SparshTheme.primaryBlue,
      shadowColor: SparshTheme.primaryBlue.withOpacity(0.3),
      child: Container(
        padding: ResponsiveSpacing.paddingLarge(context),
        decoration: BoxDecoration(
          gradient: SparshTheme.primaryGradient,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: ResponsiveTypography.headlineLarge(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: ResponsiveSpacing.small(context)),
                  Text(
                    'Welcome back! Here\'s your overview',
                    style: ResponsiveTypography.bodyMedium(context).copyWith(
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
            Advanced3DCard(
              elevation: 6,
              borderRadius: 50,
              backgroundColor: Colors.white.withOpacity(0.15),
              shadowColor: Colors.white.withOpacity(0.1),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    const CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        Icons.person_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: SparshTheme.successGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: SparshTheme.successGreen.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- ADVANCED 3D CREDIT LIMIT ---

class Advanced3DCreditLimitScreen extends StatelessWidget {
  const Advanced3DCreditLimitScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Advanced3DSectionCard(
      title: "Credit Limit",
      icon: Icons.account_balance_wallet_rounded,
      iconColor: SparshTheme.primaryBlue,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Balance Limit",
                  style: ResponsiveTypography.bodyLarge(context).copyWith(
                    color: SparshTheme.textSecondary,
                  ),
                ),
                SizedBox(height: ResponsiveSpacing.small(context)),
                Text(
                  "₹ 0",
                  style: ResponsiveTypography.headlineMedium(context).copyWith(
                    fontWeight: FontWeight.w700,
                    color: SparshTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: ResponsiveSpacing.medium(context)),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAdvanced3DCreditInfoRow(context, "Credit Limit", 0),
                _buildAdvanced3DCreditInfoRow(context, "Open Billing", 0),
                _buildAdvanced3DCreditInfoRow(context, "Open Order", 0),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  static Widget _buildAdvanced3DCreditInfoRow(
    BuildContext context, 
    String title, 
    int value
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveSpacing.small(context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: ResponsiveTypography.bodyMedium(context).copyWith(
              color: SparshTheme.textSecondary,
            ),
          ),
          Text(
            "₹ $value",
            style: ResponsiveTypography.bodyMedium(context).copyWith(
              fontWeight: FontWeight.w600,
              color: SparshTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// --- ADVANCED 3D PRIMARY SALE ---

class Advanced3DPrimarySaleScreen extends StatelessWidget {
  const Advanced3DPrimarySaleScreen({super.key});

  static const List<_ProductChartData> _products = [
    _ProductChartData('Distemper', 0.7, Colors.red), // Distemper FIRST
    _ProductChartData('WCP', 0.5, Colors.purple),
    _ProductChartData('VAP', 0.3, Colors.orange),
    _ProductChartData('Primer', 0.6, Colors.green),
    _ProductChartData('Water\nProofing', 0.2, Colors.teal),
    _ProductChartData('WC', 0.4, Colors.blue), // WC LAST
  ];

  @override
  Widget build(BuildContext context) {
    return Advanced3DSectionCard(
      title: "Primary Sale",
      icon: Icons.trending_up_rounded,
      iconColor: SparshTheme.successGreen,
      child: Column(
        children: [
          Advanced3DCard(
            elevation: 4,
            borderRadius: 16,
            backgroundColor: SparshTheme.lightBlueBackground,
            shadowColor: SparshTheme.primaryBlue.withOpacity(0.1),
            child: Container(
              height: 140,
              padding: ResponsiveSpacing.paddingMedium(context),
              child: ScatterChart(
                ScatterChartData(
                  minX: 0,
                  maxX: (_products.length - 1).toDouble(),
                  minY: 0.1,
                  maxY: 0.8,
                  scatterSpots: List.generate(_products.length, (i) {
                    final prod = _products[i];
                    return ScatterSpot(i.toDouble(), prod.value, color: prod.color, radius: 8);
                  }),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 0.1,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: SparshTheme.borderGrey.withOpacity(0.5),
                      strokeWidth: 1,
                    ),
                    getDrawingVerticalLine: (value) => FlLine(
                      color: SparshTheme.borderGrey.withOpacity(0.5),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 0.2,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) => Text(
                          value.toStringAsFixed(1),
                          style: ResponsiveTypography.bodySmall(context).copyWith(
                            color: SparshTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  scatterTouchData: ScatterTouchData(
                    enabled: true,
                    touchTooltipData: ScatterTouchTooltipData(
                      tooltipBgColor: SparshTheme.textPrimary,
                      getTooltipItems: (spot) {
                        final prod = _products[spot.x.toInt()];
                        return ScatterTooltipItem(
                          "${prod.name.replaceAll('\n', ' ')}: ${prod.value.toStringAsFixed(3)}",
                          textStyle: ResponsiveTypography.bodySmall(context).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: ResponsiveSpacing.medium(context)),
          Wrap(
            spacing: ResponsiveSpacing.small(context),
            runSpacing: ResponsiveSpacing.small(context),
            children: _products.map((prod) {
              return Advanced3DCard(
                elevation: 2,
                borderRadius: 16,
                backgroundColor: prod.color.withOpacity(0.1),
                shadowColor: prod.color.withOpacity(0.2),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveSpacing.small(context),
                    vertical: ResponsiveSpacing.xs(context),
                  ),
                  child: Text(
                    prod.name.replaceAll('\n', ' '),
                    style: ResponsiveTypography.bodySmall(context).copyWith(
                      fontWeight: FontWeight.w500,
                      color: prod.color,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// --- ADVANCED 3D SECONDARY SALE ---

class Advanced3DSecondarySaleScreen extends StatelessWidget {
  const Advanced3DSecondarySaleScreen({super.key});

  static const List<_ProductChartData> _products = [
    _ProductChartData('Distemper', 0.7, Colors.red), // Distemper FIRST
    _ProductChartData('WCP', 0.5, Colors.purple),
    _ProductChartData('VAP', 0.3, Colors.orange),
    _ProductChartData('Primer', 0.6, Colors.green),
    _ProductChartData('Water\nProofing', 0.2, Colors.teal),
    _ProductChartData('WC', 0.4, Colors.blue), // WC LAST
  ];

  @override
  Widget build(BuildContext context) {
    return Advanced3DSectionCard(
      title: "Secondary Sale",
      icon: Icons.show_chart_rounded,
      iconColor: Colors.purple.shade400,
      child: Column(
        children: [
          Advanced3DCard(
            elevation: 4,
            borderRadius: 16,
            backgroundColor: SparshTheme.lightPurpleBackground,
            shadowColor: Colors.purple.withOpacity(0.1),
            child: Container(
              height: 140,
              padding: ResponsiveSpacing.paddingMedium(context),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 0.2,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: SparshTheme.borderGrey.withOpacity(0.3),
                      strokeWidth: 1,
                    ),
                    getDrawingVerticalLine: (value) => FlLine(
                      color: SparshTheme.borderGrey.withOpacity(0.3),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 0.2,
                        getTitlesWidget: (value, meta) => Text(
                          value.toStringAsFixed(1),
                          style: ResponsiveTypography.bodySmall(context).copyWith(
                            color: Colors.purple.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        reservedSize: 32,
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (_products.length - 1).toDouble(),
                  minY: 0,
                  maxY: 1,
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(_products.length, (i) => FlSpot(i.toDouble(), _products[i].value)),
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.shade400.withOpacity(0.8),
                          Colors.purple.shade700,
                        ],
                      ),
                      barWidth: 3.0,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 6,
                            color: Colors.white,
                            strokeWidth: 2.5,
                            strokeColor: _products[spot.x.toInt()].color,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.shade200.withOpacity(0.4),
                            Colors.white.withOpacity(0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: ResponsiveSpacing.medium(context)),
          Wrap(
            spacing: ResponsiveSpacing.small(context),
            runSpacing: ResponsiveSpacing.small(context),
            children: _products.map((prod) {
              return Advanced3DCard(
                elevation: 2,
                borderRadius: 16,
                backgroundColor: prod.color.withOpacity(0.1),
                shadowColor: prod.color.withOpacity(0.2),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveSpacing.small(context),
                    vertical: ResponsiveSpacing.xs(context),
                  ),
                  child: Text(
                    prod.name.replaceAll('\n', ' '),
                    style: ResponsiveTypography.bodySmall(context).copyWith(
                      fontWeight: FontWeight.w500,
                      color: prod.color,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// --- ADVANCED 3D MY NETWORK ---

class Advanced3DMyNetworkScreen extends StatelessWidget {
  const Advanced3DMyNetworkScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Advanced3DSectionCard(
      title: "My Network",
      icon: Icons.groups_2_rounded,
      iconColor: SparshTheme.successGreen,
      child: Column(
        children: [
          Advanced3DInfoBox(
            label: "Total Retailer",
            value: "173",
            color: SparshTheme.successGreen,
            icon: Icons.store_rounded,
          ),
          SizedBox(height: ResponsiveSpacing.medium(context)),
          Advanced3DInfoBox(
            label: "Total Unique Billed",
            value: "0",
            color: SparshTheme.warningOrange,
            icon: Icons.receipt_long_rounded,
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: ResponsiveSpacing.large(context)),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  SparshTheme.borderGrey.withOpacity(0.1),
                  SparshTheme.borderGrey,
                  SparshTheme.borderGrey.withOpacity(0.1),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Billing Details",
              style: ResponsiveTypography.headlineSmall(context).copyWith(
                fontWeight: FontWeight.w600,
                color: SparshTheme.textPrimary,
              ),
            ),
          ),
          SizedBox(height: ResponsiveSpacing.medium(context)),
          ...[
            "Distemper", // Distemper FIRST
            "WCP",
            "VAP",
            "Primer",
            "Water Proofing",
            "WC", // WC LAST
          ].map((name) => Padding(
            padding: EdgeInsets.symmetric(vertical: ResponsiveSpacing.small(context)),
            child: Advanced3DCard(
              elevation: 2,
              borderRadius: 12,
              backgroundColor: SparshTheme.lightGreyBackground,
              shadowColor: SparshTheme.primaryBlue.withOpacity(0.05),
              child: Padding(
                padding: ResponsiveSpacing.paddingMedium(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: ResponsiveTypography.bodyMedium(context).copyWith(
                        color: SparshTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Advanced3DCard(
                      elevation: 1,
                      borderRadius: 20,
                      backgroundColor: SparshTheme.successLight,
                      shadowColor: SparshTheme.successGreen.withOpacity(0.1),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveSpacing.medium(context),
                          vertical: ResponsiveSpacing.xs(context),
                        ),
                        child: Text(
                          "0",
                          style: ResponsiveTypography.bodyMedium(context).copyWith(
                            fontWeight: FontWeight.w600,
                            color: SparshTheme.successGreen,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}

// --- ADVANCED 3D REUSABLE COMPONENTS ---

class Advanced3DSectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData? icon;
  final Color? iconColor;
  
  const Advanced3DSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Advanced3DCard(
      margin: ResponsiveSpacing.paddingHorizontalMedium(context),
      elevation: 8,
      borderRadius: 20,
      enableGlassMorphism: true,
      backgroundColor: SparshTheme.cardBackground,
      shadowColor: SparshTheme.primaryBlue.withOpacity(0.1),
      child: Padding(
        padding: ResponsiveSpacing.paddingLarge(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null)
                  Advanced3DCard(
                    margin: EdgeInsets.only(right: ResponsiveSpacing.medium(context)),
                    elevation: 4,
                    borderRadius: 50,
                    backgroundColor: (iconColor ?? SparshTheme.primaryBlue).withOpacity(0.1),
                    shadowColor: (iconColor ?? SparshTheme.primaryBlue).withOpacity(0.2),
                    child: Container(
                      padding: ResponsiveSpacing.paddingSmall(context),
                      child: Icon(
                        icon,
                        size: 24,
                        color: iconColor ?? SparshTheme.primaryBlue,
                      ),
                    ),
                  ),
                Text(
                  title,
                  style: ResponsiveTypography.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: SparshTheme.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveSpacing.medium(context)),
            child,
          ],
        ),
      ),
    );
  }
}

// --- DATA CLASSES AND UTILITIES ---

class ChartData {
  final String x;
  final double y;
  const ChartData(this.x, this.y);
}

class _ProductChartData {
  final String name;
  final double value;
  final Color color;
  const _ProductChartData(this.name, this.value, this.color);
}

class Advanced3DInfoBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData? icon;
  
  const Advanced3DInfoBox({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Advanced3DCard(
      elevation: 4,
      borderRadius: 16,
      backgroundColor: color.withOpacity(0.1),
      shadowColor: color.withOpacity(0.2),
      child: Padding(
        padding: ResponsiveSpacing.paddingMedium(context),
        child: Row(
          children: [
            if (icon != null) ...[
              Advanced3DCard(
                elevation: 2,
                borderRadius: 50,
                backgroundColor: color.withOpacity(0.2),
                shadowColor: color.withOpacity(0.1),
                child: Container(
                  padding: ResponsiveSpacing.paddingSmall(context),
                  child: Icon(icon, color: color, size: 20),
                ),
              ),
              SizedBox(width: ResponsiveSpacing.medium(context)),
            ] else ...[
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              SizedBox(width: ResponsiveSpacing.medium(context)),
            ],
            Expanded(
              child: Text(
                label,
                style: ResponsiveTypography.bodyLarge(context).copyWith(
                  fontWeight: FontWeight.w500,
                  color: SparshTheme.textPrimary,
                ),
              ),
            ),
            Text(
              value,
              style: ResponsiveTypography.headlineSmall(context).copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
