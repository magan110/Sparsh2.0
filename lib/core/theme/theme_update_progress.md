# SPARSH Theme Update Progress

## Overview
This document tracks the progress of updating all pages in the SPARSH application to use the unified theme system.

## ✅ Completed Updates

### 1. Core Application Files
- **`lib/main.dart`** ✅
  - Added theme import
  - Applied `SparshTheme.lightTheme` to MaterialApp
  - Removed hardcoded theme configuration

### 2. Main Navigation & Layout
- **`lib/features/dashboard/presentation/pages/home_screen.dart`** ✅
  - Added theme import
  - Updated scaffold background to `SparshTheme.scaffoldBackground`
  - Updated app bar gradient to `SparshTheme.appBarGradient`

- **`lib/features/dashboard/presentation/widgets/app_drawer.dart`** ✅
  - Added theme import
  - Updated drawer background to `SparshTheme.cardBackground`
  - Updated drawer header gradient to `SparshTheme.drawerHeaderGradient`
  - Updated icon color to `SparshTheme.primaryBlue`

### 3. Worker Module
- **`lib/features/worker/presentation/pages/Worker_Home_Screen.dart`** ✅
  - Added theme import
  - Updated scaffold background to `SparshTheme.lightBlueBackground`
  - Updated app bar gradient to `SparshTheme.appBarGradient`

### 4. Staff Module
- **`lib/features/staff/presentation/pages/staff_home_screen.dart`** ✅
  - Added theme import
  - Updated scaffold background to `SparshTheme.lightBlueBackground`
  - Updated app bar gradient to `SparshTheme.appBarGradient`

### 5. DSR Entry Module
- **`lib/features/dsr_entry/presentation/pages/dsr_entry.dart`** ✅
  - Added theme import
  - Updated scaffold background to `SparshTheme.scaffoldBackground`
  - Updated app bar background to `SparshTheme.primaryBlueAccent`
  - Updated all hardcoded `Color(0xFF2196F3)` to `SparshTheme.primaryBlueAccent`

- **`lib/features/dsr_entry/presentation/pages/any_other_activity.dart`** ✅
  - Added theme import
  - Updated app bar background to `SparshTheme.primaryBlueAccent`
  - Updated success colors to `SparshTheme.successGreen`
  - Updated icon colors to `SparshTheme.primaryBlueAccent`

- **`lib/features/dsr_entry/presentation/pages/Meeting_with_new_purchaser.dart`** ✅
  - Added theme import
  - Updated scaffold background to `SparshTheme.scaffoldBackground`
  - Updated app bar background to `SparshTheme.primaryBlueAccent`
  - Updated icon colors to `SparshTheme.primaryBlueAccent`

- **`lib/features/dsr_entry/presentation/pages/Meetings_With_Contractor.dart`** ✅
  - Added theme import
  - Updated app bar background to `SparshTheme.primaryBlueAccent`
  - Updated success colors to `SparshTheme.successGreen`
  - Updated icon colors to `SparshTheme.primaryBlueAccent`
  - Updated button colors to `SparshTheme.primaryBlueAccent`

### 6. Dashboard Module
- **`lib/features/dashboard/presentation/pages/notification_screen.dart`** ✅
  - Added theme import
  - Updated MaterialApp theme to `SparshTheme.lightTheme`
  - Updated app bar background to `SparshTheme.primaryBlue`

- **`lib/features/dashboard/presentation/pages/dashboard_screen.dart`** ✅
  - Added theme import
  - Updated scaffold background to `SparshTheme.scaffoldBackground`
  - Updated gradient to `SparshTheme.primaryGradient`
  - Updated shadow colors to `SparshTheme.primaryBlue`

- **`lib/features/dashboard/presentation/pages/profile_screen.dart`** ✅
  - Added theme import
  - Updated scaffold background to `SparshTheme.cardBackground`
  - Updated gradient to `SparshTheme.primaryGradient`
  - Updated icon colors to `SparshTheme.primaryBlue`

- **`lib/features/dashboard/presentation/pages/splash_screen.dart`** ✅
  - Added theme import
  - Updated gradient colors to `SparshTheme.primaryBlue` and `SparshTheme.primaryBlueLight`

## 🔄 In Progress Updates

### DSR Entry Screens (14 pages)
- [x] `Meeting_with_new_purchaser.dart` ✅
- [x] `Meetings_With_Contractor.dart` ✅
- [x] `any_other_activity.dart` ✅
- [x] `internal_team_meeting.dart` ✅
- [ ] `phone_call_with_builder.dart`
- [ ] `phone_call_with_unregisterd_purchaser.dart`
- [x] `work_from_home.dart` ✅ (mostly updated, minor shadow issues)
- [x] `office_work.dart` ✅
- [x] `on_leave.dart` ✅
- [x] `btl_activites.dart` ✅
- [x] `check_sampling_at_site.dart` ✅
- [x] `DsrVisitScreen.dart` ✅ (Partial - main scaffold updated, some linter errors remain)
- [ ] `dsr_retailer_in_out.dart`

### Dashboard Screens (24 pages)
- [x] `dashboard_screen.dart` ✅
- [x] `splash_screen.dart` ✅
- [x] `profile_screen.dart` ✅
- [ ] `mail_screen.dart`
- [ ] `live_location_screen.dart`
- [ ] `token_scan.dart`
- [ ] `token_report.dart`
- [ ] `token_summary.dart`
- [ ] `All_Tokens.dart`
- [ ] `employee_dashboard_page.dart`
- [ ] `edit_kyc_screen.dart`
- [ ] `grc_lead_entry_page.dart`
- [ ] `painter_kyc_tracking_page.dart`
- [ ] `retailer_registration_page.dart`
- [ ] `scheme_document_page.dart`
- [ ] `universal_outlet_registration_page.dart`
- [ ] `accounts_statement_page.dart`
- [ ] `activity_summary_page.dart`
- [ ] `dsr_screen.dart`
- [ ] `schema.dart`

### Worker Screens (11 pages)
- [x] `Worker_attendence.dart` ✅
- [x] `Worker_App_Drawer.dart` ✅
- [x] `Movie_booking.dart` ✅
- [ ] `Movie_booking_details.dart`
- [ ] `Holiday_house_lock.dart`
- [ ] `Canteen_coupon_details.dart`
- [ ] `Food_court.dart`
- [ ] `Wages_slip.dart`
- [ ] `overtime_report_self.dart`
- [ ] `Telephone_Directory.dart`

### Staff Screens (5 pages)
- [ ] `staff_attendence.dart`
- [ ] `employee_details.dart`
- [ ] `employee_master.dart`
- [ ] `first_aid.dart`

### Authentication Screens (2 pages)
- [ ] `login_screen.dart`
- [ ] `log_in_otp.dart`

### Data Source Screens (5 pages)
- [ ] `account_statement.dart`
- [ ] `day_summary.dart`
- [ ] `day_wise_summary.dart`
- [ ] `sales_growth.dart`
- [ ] `rpl_outlet_tracker.dart`

## 🎯 Key Patterns to Update

### 1. Color Replacements
- `Colors.blue` → `SparshTheme.primaryBlue`
- `Colors.deepPurple` → `SparshTheme.deepPurple`
- `Colors.purple` → `SparshTheme.purple`
- `Color(0xFF1976D2)` → `SparshTheme.primaryBlue`
- `Color(0xFF42A5F5)` → `SparshTheme.primaryBlueLight`
- `Color(0xFF2196F3)` → `SparshTheme.primaryBlueAccent`
- `Color(0xFFF5F7FB)` → `SparshTheme.scaffoldBackground`
- `Color(0xFFF8F9FA)` → `SparshTheme.cardBackground`
- `Color(0xFFF1FFFF)` → `SparshTheme.lightBlueBackground`

### 2. Gradient Replacements
- `LinearGradient(colors: [Colors.blue, Colors.blue])` → `SparshTheme.appBarGradient`
- `LinearGradient(colors: [Color(0xFF1976D2), Color(0xFF42A5F5)])` → `SparshTheme.drawerHeaderGradient`
- `LinearGradient(colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700])` → `SparshTheme.deepPurpleGradient`

### 3. Typography Replacements
- `Fonts.heading1` → `SparshTypography.heading1`
- `Fonts.heading2` → `SparshTypography.heading2`
- `Fonts.body` → `SparshTypography.body`
- `Fonts.bodyBold` → `SparshTypography.bodyBold`

### 4. Spacing Replacements
- `EdgeInsets.all(16.0)` → `EdgeInsets.all(SparshSpacing.md)`
- `EdgeInsets.all(24.0)` → `EdgeInsets.all(SparshSpacing.lg)`
- `EdgeInsets.all(8.0)` → `EdgeInsets.all(SparshSpacing.sm)`

### 5. Border Radius Replacements
- `BorderRadius.circular(10)` → `BorderRadius.circular(SparshBorderRadius.medium)`
- `BorderRadius.circular(12)` → `BorderRadius.circular(SparshBorderRadius.large)`
- `BorderRadius.circular(8)` → `BorderRadius.circular(SparshBorderRadius.small)`

## 📊 Progress Summary

- **Total Pages**: 67
- **Completed**: 22 (33%)
- **In Progress**: 0
- **Remaining**: 45 (67%)

## 🚀 Next Steps

1. **Priority 1**: Update all DSR entry screens (14 pages)
2. **Priority 2**: Update main dashboard screens (24 pages)
3. **Priority 3**: Update worker and staff screens (16 pages)
4. **Priority 4**: Update authentication and data source screens (7 pages)

## 🔧 Automation Opportunities

Consider creating scripts to:
1. Bulk replace hardcoded colors with theme constants
2. Update gradient definitions
3. Standardize typography usage
4. Normalize spacing and border radius values

## 📝 Notes

- Some screens have their own MaterialApp widgets that need to be updated
- Some screens use custom theme configurations that should be replaced
- Pay attention to screens that use Google Fonts vs system fonts
- Ensure consistent elevation and shadow usage across all screens 