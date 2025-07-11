import 'package:flutter/material.dart';
import 'package:learning2/core/theme/app_theme.dart';
import 'package:learning2/core/utils/responsive_util.dart';
import 'package:learning2/presentation/widgets/advanced_3d_components.dart';
import 'package:learning2/presentation/animations/advanced_animations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  late List<Widget> _dashboardWidgets;
  
  @override
  void initState() {
    super.initState();
    _dashboardWidgets = [
      _buildHeader(),
      const CreditLimitScreen(),
      const PrimarySaleScreen(),
      const SecondarySaleScreen(),
      const MyNetworkScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtil.init(context);
    
    return Scaffold(
      backgroundColor: SparshTheme.scaffoldBackground,
      appBar: const Advanced3DAppBar(
        title: Text(
          'Dashboard',
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
              child: Padding(
                padding: ResponsiveUtil.scaledPadding(context, all: 16),
                child: AdvancedStaggeredAnimation(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 100),
                  children: [
                    SizedBox(height: ResponsiveUtil.scaledHeight(context, 16)),
                    ..._dashboardWidgets.map((widget) => Padding(
                      padding: EdgeInsets.only(
                        bottom: ResponsiveUtil.scaledHeight(context, 20),
                      ),
                      child: widget,
                    )).toList(),
                    SizedBox(height: ResponsiveUtil.scaledHeight(context, 30)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: Advanced3DFloatingActionButton(
        onPressed: () {
          // Add refresh functionality
        },
        child: const Icon(Icons.refresh, color: Colors.white),
        gradient: SparshTheme.primaryGradient,
        enablePulse: true,
        enableGlow: true,
      ),
    );
  }

  Widget _buildHeader() {
    return Advanced3DCard(
      enableGlassMorphism: true,
      enableHover: true,
      enable3DTransform: true,
      elevation: 12,
      borderRadius: 24,
      gradient: SparshTheme.primaryGradient,
      padding: ResponsiveUtil.scaledPadding(context, all: 24),
      margin: ResponsiveUtil.scaledPadding(context, horizontal: 4),
      child: ResponsiveBuilder(
        builder: (context, screenType) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtil.scaledFontSize(context, 24),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: ResponsiveUtil.scaledHeight(context, 8)),
                    Text(
                      'Welcome back! Your performance at a glance.',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtil.scaledFontSize(context, 16),
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: ResponsiveUtil.scaledWidth(context, 16)),
              Advanced3DTransform(
                enableAnimation: true,
                rotationY: 0.1,
                perspective: 0.002,
                child: Container(
                  width: ResponsiveUtil.scaledSize(context, 72),
                  height: ResponsiveUtil.scaledSize(context, 72),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF64B5F6),
                        Color(0xFF1976D2),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.person_rounded,
                          size: ResponsiveUtil.getIconSize(context, 32),
                          color: Colors.white,
                        ),
                      ),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.shade400,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// --- CREDIT LIMIT ---

class CreditLimitScreen extends StatelessWidget {
  const CreditLimitScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Advanced3DCard(
      enableGlassMorphism: false,
      enableHover: true,
      enable3DTransform: true,
      elevation: 8,
      borderRadius: 20,
      backgroundColor: Colors.white,
      padding: ResponsiveUtil.scaledPadding(context, all: 24),
      margin: ResponsiveUtil.scaledPadding(context, horizontal: 4),
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
                    Icons.account_balance_wallet_rounded,
                    size: ResponsiveUtil.getIconSize(context, 24),
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUtil.scaledWidth(context, 16)),
              Text(
                "Credit Limit",
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceSection(context),
                    SizedBox(height: ResponsiveUtil.scaledHeight(context, 24)),
                    _buildCreditDetailsSection(context),
                  ],
                );
              } else {
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildBalanceSection(context),
                    ),
                    SizedBox(width: ResponsiveUtil.scaledWidth(context, 24)),
                    Expanded(
                      flex: 3,
                      child: _buildCreditDetailsSection(context),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildBalanceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Balance Limit",
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtil.scaledFontSize(context, 15),
            color: SparshTheme.textSecondary,
          ),
        ),
        SizedBox(height: ResponsiveUtil.scaledHeight(context, 8)),
        Advanced3DTransform(
          enableAnimation: true,
          scaleX: 1.02,
          scaleY: 1.02,
          child: Text(
            "₹ 0",
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtil.scaledFontSize(context, 32),
              fontWeight: FontWeight.bold,
              color: SparshTheme.primaryBlue,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildCreditDetailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCreditInfoRow(context, "Credit Limit", 0),
        _buildCreditInfoRow(context, "Open Billing", 0),
        _buildCreditInfoRow(context, "Open Order", 0),
      ],
    );
  }
  
  Widget _buildCreditInfoRow(BuildContext context, String title, int value) {
    return AdvancedAnimatedContainer(
      duration: const Duration(milliseconds: 300),
      enableHover: true,
      enableScale: true,
      padding: ResponsiveUtil.scaledPadding(context, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtil.scaledFontSize(context, 14),
              color: SparshTheme.textSecondary,
            ),
          ),
          Text(
            "₹ $value",
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtil.scaledFontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: SparshTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// --- PRIMARY SALE ---

class PrimarySaleScreen extends StatelessWidget {
  const PrimarySaleScreen({super.key});

  static const List<_ProductChartData> _products = [
    _ProductChartData('Distemper', 0.7, Colors.red),
    _ProductChartData('WCP', 0.5, Colors.purple),
    _ProductChartData('VAP', 0.3, Colors.orange),
    _ProductChartData('Primer', 0.6, Colors.green),
    _ProductChartData('Water\nProofing', 0.2, Colors.teal),
    _ProductChartData('WC', 0.4, Colors.blue),
  ];

  @override
  Widget build(BuildContext context) {
    return Advanced3DCard(
      enableGlassMorphism: false,
      enableHover: true,
      enable3DTransform: true,
      elevation: 8,
      borderRadius: 20,
      backgroundColor: Colors.white,
      padding: ResponsiveUtil.scaledPadding(context, all: 24),
      margin: ResponsiveUtil.scaledPadding(context, horizontal: 4),
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
                    gradient: SparshTheme.orangeGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.trending_up_rounded,
                    size: ResponsiveUtil.getIconSize(context, 24),
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUtil.scaledWidth(context, 16)),
              Text(
                "Primary Sale",
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 20),
                  fontWeight: FontWeight.w600,
                  color: SparshTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaledHeight(context, 24)),
          GlassMorphismContainer(
            borderRadius: 16,
            blurStrength: 5,
            opacity: 0.05,
            child: SizedBox(
              height: ResponsiveUtil.scaledHeight(context, 140),
              child: ScatterChart(
                ScatterChartData(
                  minX: 0,
                  maxX: (_products.length - 1).toDouble(),
                  minY: 0.1,
                  maxY: 0.8,
                  scatterSpots: List.generate(_products.length, (i) {
                    final prod = _products[i];
                    return ScatterSpot(i.toDouble(), prod.value, color: prod.color, radius: 6);
                  }),
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 0.1,
                    verticalInterval: 1,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 0.1,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) => Text(
                          value.toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveUtil.scaledFontSize(context, 10),
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
                          textStyle: GoogleFonts.poppins(
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
          SizedBox(height: ResponsiveUtil.scaledHeight(context, 16)),
          ResponsiveGrid(
            mobileColumns: 2,
            tabletColumns: 3,
            desktopColumns: 6,
            spacing: 8,
            runSpacing: 8,
            children: _products.map((prod) {
              return AdvancedAnimatedContainer(
                duration: const Duration(milliseconds: 300),
                enableHover: true,
                enableScale: true,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: prod.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: prod.color.withOpacity(0.3)),
                ),
                child: Text(
                  prod.name.replaceAll('\n', ' '),
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtil.scaledFontSize(context, 11),
                    fontWeight: FontWeight.w500,
                    color: prod.color,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// --- SECONDARY SALE ---

class SecondarySaleScreen extends StatelessWidget {
  const SecondarySaleScreen({super.key});

  static const List<_ProductChartData> _products = [
    _ProductChartData('Distemper', 0.7, Colors.red),
    _ProductChartData('WCP', 0.5, Colors.purple),
    _ProductChartData('VAP', 0.3, Colors.orange),
    _ProductChartData('Primer', 0.6, Colors.green),
    _ProductChartData('Water\nProofing', 0.2, Colors.teal),
    _ProductChartData('WC', 0.4, Colors.blue),
  ];

  @override
  Widget build(BuildContext context) {
    return Advanced3DCard(
      enableGlassMorphism: false,
      enableHover: true,
      enable3DTransform: true,
      elevation: 8,
      borderRadius: 20,
      backgroundColor: Colors.white,
      padding: ResponsiveUtil.scaledPadding(context, all: 24),
      margin: ResponsiveUtil.scaledPadding(context, horizontal: 4),
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
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.purple.shade400,
                        Colors.purple.shade700,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.show_chart_rounded,
                    size: ResponsiveUtil.getIconSize(context, 24),
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUtil.scaledWidth(context, 16)),
              Text(
                "Secondary Sale",
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtil.scaledFontSize(context, 20),
                  fontWeight: FontWeight.w600,
                  color: SparshTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaledHeight(context, 24)),
          GlassMorphismContainer(
            borderRadius: 16,
            blurStrength: 5,
            opacity: 0.05,
            child: SizedBox(
              height: ResponsiveUtil.scaledHeight(context, 140),
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
                          style: GoogleFonts.poppins(
                            color: Colors.purple.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveUtil.scaledFontSize(context, 10),
                          ),
                        ),
                        reservedSize: 30,
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
                          Colors.purple.shade400.withOpacity(0.7),
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
                            strokeWidth: 2.0,
                            strokeColor: _products[spot.x.toInt()].color,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.shade200.withOpacity(0.5),
                            Colors.white.withOpacity(0.01),
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
          SizedBox(height: ResponsiveUtil.scaledHeight(context, 16)),
          ResponsiveGrid(
            mobileColumns: 2,
            tabletColumns: 3,
            desktopColumns: 6,
            spacing: 8,
            runSpacing: 8,
            children: _products.map((prod) {
              return AdvancedAnimatedContainer(
                duration: const Duration(milliseconds: 300),
                enableHover: true,
                enableScale: true,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: prod.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: prod.color.withOpacity(0.3)),
                ),
                child: Text(
                  prod.name.replaceAll('\n', ' '),
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtil.scaledFontSize(context, 11),
                    fontWeight: FontWeight.w500,
                    color: prod.color,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// --- MY NETWORK ---

class MyNetworkScreen extends StatelessWidget {
  const MyNetworkScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Advanced3DCard(
      enableGlassMorphism: false,
      enableHover: true,
      enable3DTransform: true,
      elevation: 8,
      borderRadius: 20,
      backgroundColor: Colors.white,
      padding: ResponsiveUtil.scaledPadding(context, all: 24),
      margin: ResponsiveUtil.scaledPadding(context, horizontal: 4),
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
                    gradient: SparshTheme.greenGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.groups_2_rounded,
                    size: ResponsiveUtil.getIconSize(context, 24),
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUtil.scaledWidth(context, 16)),
              Text(
                "My Network",
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
                    _buildInfoBox(
                      context,
                      "Total Retailer",
                      "173",
                      SparshTheme.successGreen,
                      Icons.store_outlined,
                    ),
                    SizedBox(height: ResponsiveUtil.scaledHeight(context, 16)),
                    _buildInfoBox(
                      context,
                      "Total Unique Billed",
                      "0",
                      SparshTheme.warningOrange,
                      Icons.receipt_long_outlined,
                    ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    Expanded(
                      child: _buildInfoBox(
                        context,
                        "Total Retailer",
                        "173",
                        SparshTheme.successGreen,
                        Icons.store_outlined,
                      ),
                    ),
                    SizedBox(width: ResponsiveUtil.scaledWidth(context, 16)),
                    Expanded(
                      child: _buildInfoBox(
                        context,
                        "Total Unique Billed",
                        "0",
                        SparshTheme.warningOrange,
                        Icons.receipt_long_outlined,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          SizedBox(height: ResponsiveUtil.scaledHeight(context, 24)),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  SparshTheme.borderGrey.withOpacity(0.3),
                  SparshTheme.borderGrey,
                  SparshTheme.borderGrey.withOpacity(0.3),
                ],
              ),
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaledHeight(context, 24)),
          Text(
            "Billing Details",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtil.scaledFontSize(context, 18),
              color: SparshTheme.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaledHeight(context, 16)),
          ...[
            "Distemper",
            "WCP",
            "VAP",
            "Primer",
            "Water Proofing",
            "WC",
          ].map((name) => _buildBillingDetailItem(context, name, "0")),
        ],
      ),
    );
  }
  
  Widget _buildInfoBox(BuildContext context, String label, String value, Color color, IconData icon) {
    return AdvancedAnimatedContainer(
      duration: const Duration(milliseconds: 300),
      enableHover: true,
      enableScale: true,
      padding: ResponsiveUtil.scaledPadding(context, all: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Advanced3DTransform(
            enableAnimation: true,
            rotationY: 0.1,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: ResponsiveUtil.getIconSize(context, 20),
              ),
            ),
          ),
          SizedBox(width: ResponsiveUtil.scaledWidth(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                    fontWeight: FontWeight.w500,
                    color: SparshTheme.textSecondary,
                  ),
                ),
                SizedBox(height: ResponsiveUtil.scaledHeight(context, 4)),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveUtil.scaledFontSize(context, 20),
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBillingDetailItem(BuildContext context, String name, String value) {
    return AdvancedAnimatedContainer(
      duration: const Duration(milliseconds: 300),
      enableHover: true,
      enableScale: true,
      padding: ResponsiveUtil.scaledPadding(context, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtil.scaledFontSize(context, 14),
              color: SparshTheme.textPrimary,
            ),
          ),
          Advanced3DTransform(
            enableAnimation: true,
            scaleX: 1.05,
            scaleY: 1.05,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    SparshTheme.successGreen.withOpacity(0.1),
                    SparshTheme.successGreen.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: SparshTheme.successGreen.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                value,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                  color: SparshTheme.successGreen,
                ),
              ),
            ),
          ),
        ],
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
