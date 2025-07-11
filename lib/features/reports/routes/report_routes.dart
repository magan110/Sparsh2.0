import 'package:flutter/material.dart';
import '../presentation/pages/analytics_dashboard_page.dart';
import '../presentation/pages/sales_report_page.dart';
import '../presentation/pages/performance_report_page.dart';
import '../presentation/pages/financial_report_page.dart';
import '../presentation/pages/user_analytics_page.dart';

class ReportRoutes {
  static const String analytics = '/reports/analytics';
  static const String sales = '/reports/sales';
  static const String performance = '/reports/performance';
  static const String financial = '/reports/financial';
  static const String userAnalytics = '/reports/user-analytics';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case analytics:
        return MaterialPageRoute(
          builder: (_) => const AnalyticsDashboardPage(),
        );
      case sales:
        return MaterialPageRoute(
          builder: (_) => const SalesReportPage(),
        );
      case performance:
        return MaterialPageRoute(
          builder: (_) => const PerformanceReportPage(),
        );
      case financial:
        return MaterialPageRoute(
          builder: (_) => const FinancialReportPage(),
        );
      case userAnalytics:
        return MaterialPageRoute(
          builder: (_) => const UserAnalyticsPage(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const AnalyticsDashboardPage(),
        );
    }
  }

  static List<ReportMenuItem> getReportMenuItems() {
    return [
      ReportMenuItem(
        title: 'Analytics Dashboard',
        subtitle: 'Comprehensive analytics with real-time metrics',
        icon: Icons.dashboard,
        route: analytics,
        color: Colors.blue,
      ),
      ReportMenuItem(
        title: 'Sales Report',
        subtitle: 'Advanced sales analytics with charts',
        icon: Icons.trending_up,
        route: sales,
        color: Colors.green,
      ),
      ReportMenuItem(
        title: 'Performance Report',
        subtitle: 'Team and department performance metrics',
        icon: Icons.speed,
        route: performance,
        color: Colors.orange,
      ),
      ReportMenuItem(
        title: 'Financial Report',
        subtitle: 'Financial data and budget analysis',
        icon: Icons.account_balance,
        route: financial,
        color: Colors.purple,
      ),
      ReportMenuItem(
        title: 'User Analytics',
        subtitle: 'User behavior and engagement insights',
        icon: Icons.people,
        route: userAnalytics,
        color: Colors.teal,
      ),
    ];
  }
}

class ReportMenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final Color color;

  ReportMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.color,
  });
}