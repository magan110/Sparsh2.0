import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF5F6FA);
    return SafeArea(
      child: Scaffold(
        backgroundColor: bgColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildHeader(),
              const SizedBox(height: 24),
              const CreditLimitScreen(),
              const SizedBox(height: 16),
              const PrimarySaleScreen(),
              const SizedBox(height: 16),
              const SecondarySaleScreen(),
              const SizedBox(height: 16),
              const MyNetworkScreen(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5F96F3), Color(0xFF1976D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 7),
            ),
          ],
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
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Welcome back!',
                    style: GoogleFonts.poppins(
                        fontSize: 16, color: Colors.white.withOpacity(0.82)),
                  ),
                ],
              ),
            ),
            Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.transparent,
                    child: Icon(Icons.person_rounded, size: 40, color: Colors.white),
                  ),
                ),
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    width: 13, height: 13,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.shade400,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- CREDIT LIMIT ---

class CreditLimitScreen extends StatelessWidget {
  const CreditLimitScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: "Credit Limit",
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Balance Limit", style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87)),
                const SizedBox(height: 6),
                Text(
                  "₹ 0",
                  style: GoogleFonts.poppins(
                      fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCreditInfoRow("Credit Limit", 0),
                _buildCreditInfoRow("Open Billing", 0),
                _buildCreditInfoRow("Open Order", 0),
              ],
            ),
          ),
        ],
      ),
    );
  }
  static Widget _buildCreditInfoRow(String title, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 14, color: Colors.blueGrey)),
          Text("₹ $value", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// --- PRIMARY SALE ---

class PrimarySaleScreen extends StatelessWidget {
  const PrimarySaleScreen({super.key});

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
    return SectionCard(
      title: "Primary Sale",
      child: Column(
        children: [
          SizedBox(
            height: 120,
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
                        style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600),
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
                    tooltipBgColor: Colors.black87,
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _products.map((prod) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: prod.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: prod.color.withOpacity(0.3)),
                ),
                child: Text(
                  prod.name.replaceAll('\n', ' '),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: prod.color,
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

// --- SECONDARY SALE ---

class SecondarySaleScreen extends StatelessWidget {
  const SecondarySaleScreen({super.key});

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
    return SectionCard(
      title: "Secondary Sale",
      icon: Icons.show_chart_rounded,
      iconColor: Colors.purple.shade400,
      child: Column(
        children: [
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 0.2,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
                  getDrawingVerticalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
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
                          fontSize: 10,
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
                    barWidth: 2.0,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5,
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _products.map((prod) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: prod.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: prod.color.withOpacity(0.3)),
                ),
                child: Text(
                  prod.name.replaceAll('\n', ' '),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: prod.color,
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

// --- MY NETWORK ---

class MyNetworkScreen extends StatelessWidget {
  const MyNetworkScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: "My Network",
      icon: Icons.groups_2_rounded,
      iconColor: Colors.teal,
      child: Column(
        children: [
          _InfoBox(
            label: "Total Retailer",
            value: "173",
            color: Colors.teal.shade400,
          ),
          const SizedBox(height: 14),
          _InfoBox(
            label: "Total Unique Billed",
            value: "0",
            color: Colors.deepOrange.shade400,
          ),
          const Divider(height: 32, thickness: 1.2, color: Color(0xFFF2F4F6)),
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Billing Details", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey.shade900)),
          ),
          const SizedBox(height: 12),
          ...[
            "Distemper", // Distemper FIRST
            "WCP",
            "VAP",
            "Primer",
            "Water Proofing",
            "WC", // WC LAST
          ].map((name) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: GoogleFonts.poppins(fontSize: 14)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    "0",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.teal.shade700),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// --- STYLED REUSABLE CARD ---

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData? icon;
  final Color? iconColor;
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 3),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.blueGrey.withOpacity(0.10),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null)
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: iconColor?.withOpacity(0.15) ?? Colors.blue.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(icon, size: 22, color: iconColor ?? Colors.blue),
                    ),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 19,
                      color: Colors.blueGrey.shade900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              child
            ],
          ),
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

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _InfoBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, color: color, size: 10),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500)),
          ),
          Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 19, color: color)),
        ],
      ),
    );
  }
}
