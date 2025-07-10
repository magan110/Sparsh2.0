import 'package:flutter/material.dart';
// Import all your screens here
import 'package:learning2/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:learning2/features/dashboard/presentation/pages/profile_screen.dart';
import 'package:learning2/features/dashboard/presentation/pages/mail_screen.dart';
import 'package:learning2/features/dsr_entry/presentation/pages/dsr_entry.dart';
import 'package:learning2/features/dashboard/presentation/pages/accounts_statement_page.dart';
import 'package:learning2/features/dashboard/presentation/pages/activity_summary_page.dart';
import 'package:learning2/features/dashboard/presentation/pages/employee_dashboard_page.dart';
import 'package:learning2/features/dashboard/presentation/pages/grc_lead_entry_page.dart';
import 'package:learning2/features/dashboard/presentation/pages/painter_kyc_tracking_page.dart';
import 'package:learning2/features/dashboard/presentation/pages/retailer_registration_page.dart';
import 'package:learning2/features/dashboard/presentation/pages/scheme_document_page.dart';
import 'package:learning2/features/dashboard/presentation/pages/universal_outlet_registration_page.dart';
import 'package:learning2/features/dashboard/presentation/pages/token_scan.dart';
// import 'package:learning2/features/dashboard/presentation/pages/live_location_screen.dart'; // Uncomment if available

class AppRoute {
  final String title;
  final String type;
  final Widget Function(BuildContext) builder;
  const AppRoute(this.title, this.type, this.builder);
}

final List<AppRoute> appRoutes = [
  AppRoute('Dashboard', 'Screen', (context) => const DashboardScreen()),
  AppRoute('Profile', 'Screen', (context) => const ProfilePage()),
  AppRoute('Mail', 'Screen', (context) => const MailScreen()),
  AppRoute('DSR Entry', 'Screen', (context) => const DsrEntry()),
  AppRoute('Accounts Statement', 'Report', (context) => const AccountsStatementPage()),
  AppRoute('Activity Summary', 'Report', (context) => const ActivitySummaryPage()),
  AppRoute('Employee Dashboard', 'Screen', (context) => const EmployeeDashboardPage()),
  AppRoute('GRC Lead Entry', 'Screen', (context) => const GrcLeadEntryPage()),
  AppRoute('Painter KYC Tracking', 'Screen', (context) => const PainterKycTrackingPage()),
  AppRoute('Retailer Registration', 'Screen', (context) => const RetailerRegistrationPage()),
  AppRoute('Scheme Document', 'Screen', (context) => const SchemeDocumentPage()),
  AppRoute('Universal Outlet Registration', 'Screen', (context) => const UniversalOutletRegistrationPage()),
  AppRoute('Token Scan', 'Screen', (context) => const TokenScanPage()),
  // AppRoute('Live Location', 'Screen', (context) => LiveLocationScreen()), // Uncomment if available
  // Add more screens/reports here as needed
]; 