import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../theme/app_theme.dart';
import '../utils/responsive_util.dart';
import 'advanced_3d_components.dart';

/// Advanced 3D Chart Container with Glass Morphism
class Advanced3DChartContainer extends StatelessWidget {
  final Widget chart;
  final String title;
  final String? subtitle;
  final double? width;
  final double? height;
  final bool enableGlassMorphism;
  final bool enable3DEffect;
  final EdgeInsetsGeometry? padding;
  final List<Widget>? actions;

  const Advanced3DChartContainer({
    Key? key,
    required this.chart,
    required this.title,
    this.subtitle,
    this.width,
    this.height,
    this.enableGlassMorphism = true,
    this.enable3DEffect = true,
    this.padding,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Advanced3DCard(
      width: width,
      height: height,
      enableGlassMorphism: enableGlassMorphism,
      enable3DTransform: enable3DEffect,
      padding: padding ?? ResponsiveUtil.scaledPadding(context, all: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: ResponsiveUtil.scaledFontSize(context, 18),
                        fontWeight: FontWeight.bold,
                        color: SparshTheme.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: ResponsiveUtil.scaledSize(context, 4)),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                          color: SparshTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (actions != null) ...actions!,
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          Expanded(child: chart),
        ],
      ),
    );
  }
}

/// Advanced 3D Line Chart
class Advanced3DLineChart extends StatefulWidget {
  final List<ChartData> data;
  final String? title;
  final Color? primaryColor;
  final Color? secondaryColor;
  final bool enableAnimation;
  final bool enableInteraction;
  final bool show3DEffect;
  final double? height;

  const Advanced3DLineChart({
    Key? key,
    required this.data,
    this.title,
    this.primaryColor,
    this.secondaryColor,
    this.enableAnimation = true,
    this.enableInteraction = true,
    this.show3DEffect = true,
    this.height,
  }) : super(key: key);

  @override
  State<Advanced3DLineChart> createState() => _Advanced3DLineChartState();
}

class _Advanced3DLineChartState extends State<Advanced3DLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _touchedIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.enableAnimation) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? ResponsiveUtil.scaledSize(context, 300),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: widget.show3DEffect
                ? Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(0.1)
                  ..rotateY(0.05)
                : Matrix4.identity(),
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: widget.data.length.toDouble() - 1,
                minY: 0,
                maxY: widget.data.map((e) => e.y).reduce(math.max) * 1.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: widget.data.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        entry.value.y * _animation.value,
                      );
                    }).toList(),
                    isCurved: true,
                    color: widget.primaryColor ?? SparshTheme.primaryBlue,
                    barWidth: ResponsiveUtil.scaledSize(context, 4),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          (widget.primaryColor ?? SparshTheme.primaryBlue)
                              .withOpacity(0.3),
                          (widget.primaryColor ?? SparshTheme.primaryBlue)
                              .withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: _touchedIndex == index ? 8 : 4,
                          color: widget.primaryColor ?? SparshTheme.primaryBlue,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: ResponsiveUtil.scaledSize(context, 40),
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                            color: SparshTheme.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: ResponsiveUtil.scaledSize(context, 30),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < widget.data.length) {
                          return Text(
                            widget.data[index].label,
                            style: TextStyle(
                              fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                              color: SparshTheme.textSecondary,
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: SparshTheme.borderGrey.withOpacity(0.5),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  enabled: widget.enableInteraction,
                  touchCallback: (event, response) {
                    if (event is FlTapUpEvent && response?.lineBarSpots != null) {
                      setState(() {
                        _touchedIndex = response!.lineBarSpots!.first.spotIndex;
                      });
                    }
                  },
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: SparshTheme.cardBackground.withOpacity(0.9),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${widget.data[spot.spotIndex].label}\n${spot.y.toStringAsFixed(1)}',
                          TextStyle(
                            color: SparshTheme.textPrimary,
                            fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Advanced 3D Bar Chart
class Advanced3DBarChart extends StatefulWidget {
  final List<ChartData> data;
  final String? title;
  final Color? primaryColor;
  final bool enableAnimation;
  final bool show3DEffect;
  final double? height;

  const Advanced3DBarChart({
    Key? key,
    required this.data,
    this.title,
    this.primaryColor,
    this.enableAnimation = true,
    this.show3DEffect = true,
    this.height,
  }) : super(key: key);

  @override
  State<Advanced3DBarChart> createState() => _Advanced3DBarChartState();
}

class _Advanced3DBarChartState extends State<Advanced3DBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.enableAnimation) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? ResponsiveUtil.scaledSize(context, 300),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: widget.show3DEffect
                ? Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(0.1)
                  ..rotateY(0.05)
                : Matrix4.identity(),
            child: BarChart(
              BarChartData(
                maxY: widget.data.map((e) => e.y).reduce(math.max) * 1.2,
                barGroups: widget.data.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.y * _animation.value,
                        color: widget.primaryColor ?? SparshTheme.primaryBlue,
                        width: ResponsiveUtil.scaledSize(context, 20),
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtil.scaledSize(context, 4),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            widget.primaryColor ?? SparshTheme.primaryBlue,
                            (widget.primaryColor ?? SparshTheme.primaryBlue)
                                .withOpacity(0.7),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: ResponsiveUtil.scaledSize(context, 40),
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                            color: SparshTheme.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: ResponsiveUtil.scaledSize(context, 30),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < widget.data.length) {
                          return Text(
                            widget.data[index].label,
                            style: TextStyle(
                              fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                              color: SparshTheme.textSecondary,
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: SparshTheme.borderGrey.withOpacity(0.5),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Advanced 3D Pie Chart
class Advanced3DPieChart extends StatefulWidget {
  final List<ChartData> data;
  final String? title;
  final bool enableAnimation;
  final bool show3DEffect;
  final double? height;

  const Advanced3DPieChart({
    Key? key,
    required this.data,
    this.title,
    this.enableAnimation = true,
    this.show3DEffect = true,
    this.height,
  }) : super(key: key);

  @override
  State<Advanced3DPieChart> createState() => _Advanced3DPieChartState();
}

class _Advanced3DPieChartState extends State<Advanced3DPieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _touchedIndex;

  final List<Color> _colors = [
    SparshTheme.primaryBlue,
    Colors.orange,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.enableAnimation) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? ResponsiveUtil.scaledSize(context, 300),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: widget.show3DEffect
                ? Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(0.1)
                  ..rotateY(0.05)
                : Matrix4.identity(),
            child: PieChart(
              PieChartData(
                sections: widget.data.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  final isSelected = _touchedIndex == index;
                  
                  return PieChartSectionData(
                    value: data.y * _animation.value,
                    title: '${data.label}\n${data.y.toStringAsFixed(1)}',
                    color: _colors[index % _colors.length],
                    radius: isSelected
                        ? ResponsiveUtil.scaledSize(context, 110)
                        : ResponsiveUtil.scaledSize(context, 100),
                    titleStyle: TextStyle(
                      fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    gradient: LinearGradient(
                      colors: [
                        _colors[index % _colors.length],
                        _colors[index % _colors.length].withOpacity(0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  );
                }).toList(),
                centerSpaceRadius: ResponsiveUtil.scaledSize(context, 40),
                sectionsSpace: 2,
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    if (event is FlTapUpEvent && response?.touchedSection != null) {
                      setState(() {
                        _touchedIndex = response!.touchedSection!.touchedSectionIndex;
                      });
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Advanced 3D Gauge Chart
class Advanced3DGaugeChart extends StatefulWidget {
  final double value;
  final double maxValue;
  final String title;
  final String? subtitle;
  final Color? primaryColor;
  final Color? backgroundColor;
  final bool enableAnimation;
  final bool show3DEffect;
  final double? height;

  const Advanced3DGaugeChart({
    Key? key,
    required this.value,
    required this.maxValue,
    required this.title,
    this.subtitle,
    this.primaryColor,
    this.backgroundColor,
    this.enableAnimation = true,
    this.show3DEffect = true,
    this.height,
  }) : super(key: key);

  @override
  State<Advanced3DGaugeChart> createState() => _Advanced3DGaugeChartState();
}

class _Advanced3DGaugeChartState extends State<Advanced3DGaugeChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.enableAnimation) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? ResponsiveUtil.scaledSize(context, 300),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: widget.show3DEffect
                ? Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(0.1)
                  ..rotateY(0.05)
                : Matrix4.identity(),
            child: SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: widget.maxValue,
                  ranges: <GaugeRange>[
                    GaugeRange(
                      startValue: 0,
                      endValue: widget.maxValue,
                      color: widget.backgroundColor ?? SparshTheme.borderGrey,
                      startWidth: ResponsiveUtil.scaledSize(context, 10),
                      endWidth: ResponsiveUtil.scaledSize(context, 10),
                    ),
                  ],
                  pointers: <GaugePointer>[
                    RangePointer(
                      value: widget.value * _animation.value,
                      width: ResponsiveUtil.scaledSize(context, 10),
                      gradient: SweepGradient(
                        colors: [
                          widget.primaryColor ?? SparshTheme.primaryBlue,
                          (widget.primaryColor ?? SparshTheme.primaryBlue)
                              .withOpacity(0.7),
                        ],
                        stops: const [0.25, 0.75],
                      ),
                    ),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: ResponsiveUtil.scaledFontSize(context, 16),
                              fontWeight: FontWeight.bold,
                              color: SparshTheme.textPrimary,
                            ),
                          ),
                          Text(
                            '${(widget.value * _animation.value).toInt()}/${widget.maxValue.toInt()}',
                            style: TextStyle(
                              fontSize: ResponsiveUtil.scaledFontSize(context, 14),
                              color: SparshTheme.textSecondary,
                            ),
                          ),
                          if (widget.subtitle != null)
                            Text(
                              widget.subtitle!,
                              style: TextStyle(
                                fontSize: ResponsiveUtil.scaledFontSize(context, 12),
                                color: SparshTheme.textTertiary,
                              ),
                            ),
                        ],
                      ),
                      angle: 90,
                      positionFactor: 0.5,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Chart Data Model
class ChartData {
  final String label;
  final double y;
  final Color? color;

  ChartData({
    required this.label,
    required this.y,
    this.color,
  });
}

/// Multi-series Chart Data Model
class MultiSeriesChartData {
  final String label;
  final List<double> values;
  final List<Color>? colors;

  MultiSeriesChartData({
    required this.label,
    required this.values,
    this.colors,
  });
}