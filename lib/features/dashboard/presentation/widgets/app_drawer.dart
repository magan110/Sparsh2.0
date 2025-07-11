import 'package:flutter/material.dart';
import 'package:learning2/features/dashboard/data/sources/day_wise_summary.dart';
import 'package:learning2/features/dashboard/data/sources/account_statement.dart';
import 'package:learning2/features/dashboard/data/sources/day_summary.dart';
import 'package:learning2/core/constants/fonts.dart';
import 'package:learning2/core/theme/app_theme.dart';

// Define a callback type for when a drawer item is tapped
typedef DrawerItemTapCallback = void Function(String title, String? route);

// Custom Navigation Drawer Widget
class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  // State variables for drawer item expansion
  bool _isTransactionExpanded = false;
  bool _isReportsExpanded = false;
  bool _isMastersExpanded = false;
  bool _isMiscellaneousExpanded = false;
  // State variables for nested expansion within Transactions
  bool _isFinancialAccountsExpanded = false;
  bool _isDepotOrderExpanded = false;
  bool _isRetailerExpanded = false; // Note: This is for Transactions Retailer
  bool _isSalesForceExpanded = false;
  bool _isMissionUdaanExpanded = false;
  // State variables for nested expansion within Reports
  bool _isSAPReportsExpanded = false;
  bool _isGeneralReportsExpanded = false;
  bool _isMISReportsExpanded = false;
  bool _isSalesReportsExpanded = false;
  bool _isSchemeDiscountExpanded = false;
  bool _isReportsRetailerExpanded = false;
  bool _isChartReportsExpanded = false;
  bool _isMobileReportsExpanded = false;
  bool _isSecondarySaleExpanded = false;
  bool _isSchemeDetailsExpanded = false;
  // State variables for nested expansion within Masters
  bool _isCustomerExpanded = false; // State variable for Customer expansion
  bool _isMiscMasterExpanded =
      false; // State variable for Misc Master expansion
  bool _isCreditNoteExpanded =
      false; // State variable for Credit Note expansion

  // State variable to track the selected drawer item (for highlighting)
  String? _selectedDrawerItem;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: SparshTheme.cardBackground,
      // Use a ListView for scrollability if the content exceeds screen height
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Enhanced Drawer Header
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: SparshTheme.drawerHeaderGradient,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.asset(
                      'assets/image27.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading drawer header image: $error');
                        return Icon(
                          Icons.business,
                          size: 48,
                          color: SparshTheme.primaryBlue,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Birla White',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        color: Colors.black38,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Build the main drawer items
          _buildDrawerItem('Transactions', Icons.swap_horiz),
          Divider(height: 1, color: Colors.grey[300]), // Add a divider
          _buildDrawerItem('Reports', Icons.assessment),
          Divider(height: 1, color: Colors.grey[300]), // Add a divider
          _buildDrawerItem('Masters', Icons.folder),
          Divider(height: 1, color: Colors.grey[300]), // Add a divider
          _buildDrawerItem('Miscellaneous', Icons.widgets),
          Divider(height: 1, color: Colors.grey[300]), // Add a divider
          // Add other top-level drawer items here
        ],
      ),
    );
  }

  // Helper to build individual drawer list items
  Widget _buildDrawerItem(String title, IconData icon) {
    bool isExpanded = false;
    IconData trailingIcon = Icons.arrow_drop_down;

    // Determine expansion state and trailing icon based on title
    if (title == "Transactions") {
      isExpanded = _isTransactionExpanded;
      trailingIcon = isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down;
    } else if (title == "Reports") {
      isExpanded = _isReportsExpanded;
      trailingIcon = isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down;
    } else if (title == "Masters") {
      isExpanded = _isMastersExpanded;
      trailingIcon = isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down;
    } else if (title == "Miscellaneous") {
      isExpanded = _isMiscellaneousExpanded;
      trailingIcon = isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down;
    } else {
      // For non-expandable items, use a right arrow
      trailingIcon = Icons.arrow_right;
    }

    // Determine if the item is selected (only for non-expandable items)
    bool isSelected = title == _selectedDrawerItem && !isExpanded;

    return Column(
      children: [
        // Use a Material widget for ripple effect and shape
        Material(
          color:
              isSelected
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.transparent, // Highlight color
          child: InkWell(
            onTap: () {
              setState(() {
                // Toggle the expansion state for expandable items
                if (title == "Transactions") {
                  _isTransactionExpanded = !_isTransactionExpanded;
                  // Close nested items when Transactions collapses
                  if (!_isTransactionExpanded) {
                    _isFinancialAccountsExpanded = false;
                    _isDepotOrderExpanded = false;
                    _isRetailerExpanded = false;
                    _isSalesForceExpanded = false;
                    _isMissionUdaanExpanded = false;
                  }
                  // Close other main sections when this one expands
                  if (_isTransactionExpanded) {
                    _isReportsExpanded = false;
                    _isMastersExpanded = false;
                    _isMiscellaneousExpanded = false;
                  }
                  _selectedDrawerItem =
                      null; // Deselect main item when expanded
                } else if (title == "Reports") {
                  _isReportsExpanded = !_isReportsExpanded;
                  if (!_isReportsExpanded) {
                    _isSAPReportsExpanded =
                        false; // Close nested when parent collapses
                    _isGeneralReportsExpanded =
                        false; // Close nested when parent collapses
                    _isMISReportsExpanded =
                        false; // Close nested when parent collapses
                    _isSalesReportsExpanded =
                        false; // Close nested when parent collapses
                    _isSchemeDiscountExpanded =
                        false; // Close nested when parent collapses
                    _isReportsRetailerExpanded =
                        false; // Close nested when parent collapses
                    _isChartReportsExpanded =
                        false; // Close nested when parent collapses
                    _isMobileReportsExpanded =
                        false; // Close nested when parent collapses
                    _isSecondarySaleExpanded =
                        false; // Close Secondary Sale when parent collapses
                    _isSchemeDetailsExpanded =
                        false; // Close nested when parent collapses
                  }
                  if (_isReportsExpanded) {
                    _isTransactionExpanded = false;
                    _isMastersExpanded = false;
                    _isMiscellaneousExpanded = false;
                  }
                  _selectedDrawerItem = null;
                } else if (title == "Masters") {
                  _isMastersExpanded = !_isMastersExpanded;
                  if (!_isMastersExpanded) {
                    _isCustomerExpanded =
                        false; // Close nested when parent collapses
                    _isMiscMasterExpanded =
                        false; // Close nested when parent collapses
                    _isCreditNoteExpanded =
                        false; // Close nested when parent collapses
                  }
                  if (_isMastersExpanded) {
                    _isTransactionExpanded = false;
                    _isReportsExpanded = false;
                    _isMiscellaneousExpanded = false;
                  }
                  _selectedDrawerItem = null;
                } else if (title == "Miscellaneous") {
                  _isMiscellaneousExpanded = !_isMiscellaneousExpanded;
                  if (_isMiscellaneousExpanded) {
                    _isTransactionExpanded = false;
                    _isReportsExpanded = false;
                    _isMastersExpanded = false;
                  }
                  _selectedDrawerItem = null;
                } else {
                  // For non-expandable items
                  _isTransactionExpanded = false; // Close all main sections
                  _isReportsExpanded = false;
                  _isMastersExpanded = false;
                  _isMiscellaneousExpanded = false;
                  _isFinancialAccountsExpanded =
                      false; // Close all nested sections
                  _isDepotOrderExpanded = false;
                  _isRetailerExpanded = false;
                  _isSalesForceExpanded = false;
                  _isMissionUdaanExpanded = false;
                  _isSAPReportsExpanded =
                      false; // Close nested when another item is selected
                  _isGeneralReportsExpanded =
                      false; // Close nested when another item is selected
                  _isMISReportsExpanded =
                      false; // Close nested when another item is selected
                  _isSalesReportsExpanded =
                      false; // Close nested when another item is selected
                  _isSchemeDiscountExpanded =
                      false; // Close nested when another item is selected
                  _isReportsRetailerExpanded =
                      false; // Close nested when another item is selected
                  _isChartReportsExpanded =
                      false; // Close nested when another item is selected
                  _isMobileReportsExpanded =
                      false; // Close nested when another item is selected
                  _isSecondarySaleExpanded =
                      false; // Close nested when another item is selected
                  _isSchemeDetailsExpanded =
                      false; // Close nested when another item is selected
                  _isCustomerExpanded =
                      false; // Close nested when another item is selected
                  _isMiscMasterExpanded =
                      false; // Close nested when another item is selected
                  _isCreditNoteExpanded =
                      false; // Close nested when another item is selected

                  _selectedDrawerItem = title; // Select the non-expandable item
                  // TODO: Implement navigation for non-expandable items here or use a callback
                  print('$title tapped');
                  Navigator.pop(context); // Close the drawer
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 14.0,
              ), // Increased vertical padding
              child: Row(
                children: [
                  Icon(
                    icon,
                    color:
                        isSelected || isExpanded
                            ? Colors.blue
                            : Colors.blueGrey[700],
                  ), // Icon color changes
                  const SizedBox(width: 16), // Spacing between icon and text
                  Expanded(
                    // Use Expanded to prevent text overflow
                    child: Text(
                      title,
                      style: (isSelected || isExpanded)
                        ? Fonts.bodyBold.copyWith(color: Colors.blue, fontSize: 16)
                        : Fonts.body.copyWith(color: Colors.black87, fontSize: 16),
                    ),
                  ),
                  // Only show trailing icon for expandable items
                  if (title == "Transactions" ||
                      title == "Reports" ||
                      title == "Masters" ||
                      title == "Miscellaneous")
                    Icon(
                      trailingIcon,
                      size: 20, // Slightly larger icon
                      color:
                          isSelected || isExpanded
                              ? Colors.blue
                              : Colors.grey[600], // Arrow color changes
                    ),
                  // Show a right arrow for non-expandable items
                  if (!(title == "Transactions" ||
                      title == "Reports" ||
                      title == "Masters" ||
                      title == "Miscellaneous"))
                    Icon(
                      Icons.arrow_right,
                      size: 20,
                      color: Colors.grey[600],
                    ), // Slightly larger icon
                ],
              ),
            ),
          ),
        ),
        // Build sub-items if the main item is expanded
        if (isExpanded) ...[
          Padding(
            padding: const EdgeInsets.only(
              left: 24.0,
            ), // Increased indent for sub-items
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildSubDrawerItems(title),
            ),
          ),
        ],
      ],
    );
  }

  // Helper to build sub-items based on the main drawer item
  List<Widget> _buildSubDrawerItems(String parentTitle) {
    List<Widget> subItemsWidgets = [];

    if (parentTitle == "Transactions") {
      // Define transaction sub-items
      final List<Map<String, String>> transactionSubItems = [
        {'label': 'Financial Accounts', 'route': 'financial_accounts'},
        {'label': 'Depot Order', 'route': 'depot_order'},
        {'label': 'Retailer', 'route': 'retailer'},
        {'label': 'Sales Force', 'route': 'sales_force'},
        {'label': 'Mission Udaan', 'route': 'mission_udaan'},
      ];

      for (var item in transactionSubItems) {
        if (item['label'] == 'Financial Accounts') {
          // Special handling for Financial Accounts to make it expandable
          subItemsWidgets.add(
            Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _isFinancialAccountsExpanded =
                          !_isFinancialAccountsExpanded;
                      // Close other nested items within Transactions when this one expands
                      if (_isFinancialAccountsExpanded) {
                        _isDepotOrderExpanded = false;
                        _isRetailerExpanded = false;
                        _isSalesForceExpanded = false;
                        _isMissionUdaanExpanded = false;
                      }
                      _selectedDrawerItem =
                          null; // Deselect parent when expanded
                    });
                    print(
                      '${item['label']} tapped. Expand: $_isFinancialAccountsExpanded',
                    );
                    // No navigation on expansion, navigation happens on sub-sub-item tap
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['label']!,
                            style: _isFinancialAccountsExpanded
                              ? Fonts.bodyBold.copyWith(color: Colors.blue, fontSize: 14)
                              : Fonts.body.copyWith(color: Colors.black87, fontSize: 14),
                          ),
                        ),
                        Icon(
                          _isFinancialAccountsExpanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          size: 18, // Slightly larger icon
                          color:
                              _isFinancialAccountsExpanded
                                  ? Colors.blue
                                  : Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isFinancialAccountsExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                    ), // Further indent for sub-sub-items
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          _buildFinancialAccountsSubItems(), // Build the nested items
                    ),
                  ),
                ],
              ],
            ),
          );
        } else if (item['label'] == 'Depot Order') {
          // Special handling for Depot Order
          subItemsWidgets.add(
            Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _isDepotOrderExpanded = !_isDepotOrderExpanded;
                      if (_isDepotOrderExpanded) {
                        _isFinancialAccountsExpanded = false;
                        _isRetailerExpanded = false;
                        _isSalesForceExpanded = false;
                        _isMissionUdaanExpanded = false;
                      }
                      _selectedDrawerItem = null;
                    });
                    print(
                      '${item['label']} tapped. Expand: $_isDepotOrderExpanded',
                    );
                    // No navigation on expansion, navigation happens on sub-sub-item tap
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['label']!,
                            style: _isDepotOrderExpanded
                              ? Fonts.bodyBold.copyWith(color: Colors.blue, fontSize: 14)
                              : Fonts.body.copyWith(color: Colors.black87, fontSize: 14),
                          ),
                        ),
                        Icon(
                          _isDepotOrderExpanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          size: 18, // Slightly larger icon
                          color:
                              _isDepotOrderExpanded
                                  ? Colors.blue
                                  : Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isDepotOrderExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                    ), // Further indent for sub-sub-items
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          _buildDepotOrderSubItems(), // Build the nested items for Depot Order
                    ),
                  ),
                ],
              ],
            ),
          );
        } else if (item['label'] == 'Retailer') {
          // Special handling for Retailer (Transactions)
          subItemsWidgets.add(
            Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _isRetailerExpanded = !_isRetailerExpanded;
                      if (_isRetailerExpanded) {
                        _isFinancialAccountsExpanded = false;
                        _isDepotOrderExpanded = false;
                        _isSalesForceExpanded = false;
                        _isMissionUdaanExpanded = false;
                      }
                      _selectedDrawerItem = null;
                    });
                    print(
                      '${item['label']} tapped. Expand: $_isRetailerExpanded',
                    );
                    // No navigation on expansion, navigation happens on sub-sub-item tap
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['label']!,
                            style: _isRetailerExpanded
                              ? Fonts.bodyBold.copyWith(color: Colors.blue, fontSize: 14)
                              : Fonts.body.copyWith(color: Colors.black87, fontSize: 14),
                          ),
                        ),
                        Icon(
                          _isRetailerExpanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          size: 18, // Slightly larger icon
                          color:
                              _isRetailerExpanded
                                  ? Colors.blue
                                  : Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isRetailerExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                    ), // Further indent for sub-sub-items
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          _buildRetailerSubItems(), // Build the items for Retailer
                    ),
                  ),
                ],
              ],
            ),
          );
        } else if (item['label'] == 'Sales Force') {
          // Special handling for Sales Force
          subItemsWidgets.add(
            Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _isSalesForceExpanded = !_isSalesForceExpanded;
                      if (_isSalesForceExpanded) {
                        _isFinancialAccountsExpanded = false;
                        _isDepotOrderExpanded = false;
                        _isRetailerExpanded = false;
                        _isMissionUdaanExpanded = false;
                      }
                      _selectedDrawerItem = null;
                    });
                    print(
                      '${item['label']} tapped. Expand: $_isSalesForceExpanded',
                    );
                    // No navigation on expansion, navigation happens on sub-sub-item tap
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['label']!,
                            style: _isSalesForceExpanded
                              ? Fonts.bodyBold.copyWith(color: Colors.blue, fontSize: 14)
                              : Fonts.body.copyWith(color: Colors.black87, fontSize: 14),
                          ),
                        ),
                        Icon(
                          _isSalesForceExpanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          size: 18, // Slightly larger icon
                          color:
                              _isSalesForceExpanded
                                  ? Colors.blue
                                  : Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isSalesForceExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                    ), // Further indent for sub-sub-items
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          _buildSalesForceSubItems(), // Build the items for Sales Force
                    ),
                  ),
                ],
              ],
            ),
          );
        } else if (item['label'] == 'Mission Udaan') {
          // Special handling for Mission Udaan
          subItemsWidgets.add(
            Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _isMissionUdaanExpanded = !_isMissionUdaanExpanded;
                      if (_isMissionUdaanExpanded) {
                        _isFinancialAccountsExpanded = false;
                        _isDepotOrderExpanded = false;
                        _isRetailerExpanded = false;
                        _isSalesForceExpanded = false;
                      }
                      _selectedDrawerItem = null;
                    });
                    print(
                      '${item['label']} tapped. Expand: $_isMissionUdaanExpanded',
                    );
                    // No navigation on expansion, navigation happens on sub-sub-item tap
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['label']!,
                            style: _isMissionUdaanExpanded
                              ? Fonts.bodyBold.copyWith(color: Colors.blue, fontSize: 14)
                              : Fonts.body.copyWith(color: Colors.black87, fontSize: 14),
                          ),
                        ),
                        Icon(
                          _isMissionUdaanExpanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          size: 18, // Slightly larger icon
                          color:
                              _isMissionUdaanExpanded
                                  ? Colors.blue
                                  : Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isMissionUdaanExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                    ), // Further indent for sub-sub-items
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          _buildMissionUdaanSubItems(), // Build the items for Mission Udaan
                    ),
                  ),
                ],
              ],
            ),
          );
        } else {
          // Normal sub-item (shouldn't happen with the current transactionSubItems list)
          subItemsWidgets.add(
            InkWell(
              onTap: () {
                // TODO: Implement navigation logic for sub-items
                print('${item['label']} tapped. Navigate to ${item['route']}');
                // Close the drawer after tapping a sub-item
                Navigator.pop(context);
                // Add your navigation logic here (e.g., Navigator.push)
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ), // Adjust padding for sub-items
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: Colors.blueGrey[300],
                    ), // Added a small leading icon
                    const SizedBox(width: 12), // Spacing after the icon
                    Expanded(
                      // Use Expanded for sub-item text
                      child: Text(
                        item['label']!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_right,
                      size: 18,
                      color: Colors.grey[600],
                    ), // Slightly larger icon
                  ],
                ),
              ),
            ),
          );
        }
      }
    } else if (parentTitle == "Reports") {
      // Define report sub-items
      final List<Map<String, String>> reportSubItems = [
        {'label': 'SAP Reports', 'route': 'sap_reports'},
        {'label': 'General Reports', 'route': 'general_reports'},
        {'label': 'MIS Reports', 'route': 'mis_reports'},
        {'label': 'Sales Reports', 'route': 'sales_reports'},
        {'label': 'Scheme/Discount', 'route': 'scheme_discount'},
        {
          'label': 'Retailer',
          'route': 'reports_retailer',
        }, // Differentiate from Transactions Retailer
        {'label': 'Chart Reports', 'route': 'chart_reports'},
        {'label': 'Mobile Reports', 'route': 'mobile_reports'},
        {'label': 'Secondary Sale', 'route': 'secondary_sale'},
        {'label': 'Scheme Details', 'route': 'scheme_details'},
      ];
      for (var item in reportSubItems) {
        if (item['label'] == 'SAP Reports') {
          // Special handling for SAP Reports to make it expandable
          subItemsWidgets.add(
            Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _isSAPReportsExpanded = !_isSAPReportsExpanded;
                      // Close other nested items within Reports when this one expands
                      if (_isSAPReportsExpanded) {
                        _isGeneralReportsExpanded =
                            false; // Close General Reports when SAP Reports expands
                        _isMISReportsExpanded =
                            false; // Close MIS Reports when MIS Reports expands
                        _isSalesReportsExpanded =
                            false; // Close Sales Reports when SAP Reports expands
                        _isSchemeDiscountExpanded =
                            false; // Close Scheme/Discount when SAP Reports expands
                        _isReportsRetailerExpanded =
                            false; // Close Reports Retailer when SAP Reports expands
                        _isChartReportsExpanded =
                            false; // Close Chart Reports when SAP Reports expands
                        _isMobileReportsExpanded =
                            false; // Close Mobile Reports when Mobile Reports expands
                        _isSecondarySaleExpanded =
                            false; // Close Secondary Sale when SAP Reports expands
                        _isSchemeDetailsExpanded =
                            false; // Close Scheme Details when SAP Reports expands
                      }
                      _selectedDrawerItem = null;
                    });
                    print(
                      '${item['label']} tapped. Expand: $_isSAPReportsExpanded',
                    );
                    // No navigation on expansion
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['label']!,
                            style: _isSAPReportsExpanded
                              ? Fonts.bodyBold.copyWith(color: Colors.blue, fontSize: 14)
                              : Fonts.body.copyWith(color: Colors.black87, fontSize: 14),
                          ),
                        ),
                        Icon(
                          _isSAPReportsExpanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          size: 18, // Slightly larger icon
                          color:
                              _isSAPReportsExpanded
                                  ? Colors.blue
                                  : Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isSAPReportsExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                    ), // Further indent for sub-sub-items
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          _buildSAPReportsSubItems(), // Build the nested items for SAP Reports
                    ),
                  ),
                ],
              ],
            ),
          );
        } else if (item['label'] == 'General Reports') {
          // Special handling for General Reports
          subItemsWidgets.add(
            Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _isGeneralReportsExpanded = !_isGeneralReportsExpanded;
                      // Close other nested items within Reports when this one expands
                      if (_isGeneralReportsExpanded) {
                        _isSAPReportsExpanded =
                            false; // Close SAP Reports when General Reports expands
                        _isMISReportsExpanded =
                            false; // Close MIS Reports when MIS Reports expands
                        _isSalesReportsExpanded =
                            false; // Close Sales Reports when General Reports expands
                        _isSchemeDiscountExpanded =
                            false; // Close Scheme/Discount when General Reports expands
                        _isReportsRetailerExpanded =
                            false; // Close Reports Retailer when General Reports expands
                        _isChartReportsExpanded =
                            false; // Close Chart Reports when General Reports expands
                        _isMobileReportsExpanded =
                            false; // Close Mobile Reports when General Reports expands
                        _isSecondarySaleExpanded =
                            false; // Close Secondary Sale when General Reports expands
                        _isSchemeDetailsExpanded =
                            false; // Close Scheme Details when General Reports expands
                      }
                      _selectedDrawerItem = null;
                    });
                    print(
                      '${item['label']} tapped. Expand: $_isGeneralReportsExpanded',
                    );
                    // No navigation on expansion
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['label']!,
                            style: _isGeneralReportsExpanded
                              ? Fonts.bodyBold.copyWith(color: Colors.blue, fontSize: 14)
                              : Fonts.body.copyWith(color: Colors.black87, fontSize: 14),
                          ),
                        ),
                        Icon(
                          _isGeneralReportsExpanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          size: 18, // Slightly larger icon
                          color:
                              _isGeneralReportsExpanded
                                  ? Colors.blue
                                  : Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isGeneralReportsExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                    ), // Further indent for sub-sub-items
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          _buildGeneralReportsSubItems(), // Build the nested items for General Reports
                    ),
                  ),
                ],
              ],
            ),
          );
        } else if (item['label'] == 'MIS Reports') {
          // Special handling for MIS Reports
          subItemsWidgets.add(
            Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _isMISReportsExpanded = !_isMISReportsExpanded;
                      // Close other nested items within Reports when this one expands
                      if (_isMISReportsExpanded) {
                        _isSAPReportsExpanded =
                            false; // Close SAP Reports when MIS Reports expands
                        _isGeneralReportsExpanded =
                            false; // Close General Reports when MIS Reports expands
                        _isSalesReportsExpanded =
                            false; // Close Sales Reports when MIS Reports expands
                        _isSchemeDiscountExpanded =
                            false; // Close Scheme/Discount when MIS Reports expands
                        _isReportsRetailerExpanded =
                            false; // Close Reports Retailer when MIS Reports expands
                        _isChartReportsExpanded =
                            false; // Close Chart Reports when MIS Reports expands
                        _isMobileReportsExpanded =
                            false; // Close Mobile Reports when MIS Reports expands
                        _isSecondarySaleExpanded =
                            false; // Close Secondary Sale when MIS Reports expands
                        _isSchemeDetailsExpanded =
                            false; // Close Scheme Details when MIS Reports expands
                      }
                      _selectedDrawerItem = null;
                    });
                    print(
                      '${item['label']} tapped. Expand: $_isMISReportsExpanded',
                    );
                    // No navigation on expansion
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['label']!,
                            style: _isMISReportsExpanded
                              ? Fonts.bodyBold.copyWith(color: Colors.blue, fontSize: 14)
                              : Fonts.body.copyWith(color: Colors.black87, fontSize: 14),
                          ),
                        ),
                        Icon(
                          _isMISReportsExpanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          size: 18, // Slightly larger icon
                          color:
                              _isMISReportsExpanded
                                  ? Colors.blue
                                  : Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isMISReportsExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                    ), // Further indent for sub-sub-items
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          _buildMISReportsSubItems(), // Build the nested items for MIS Reports
                    ),
                  ),
                ],
              ],
            ),
          );
        } else if (item['label'] == 'Sales Reports') {
          // Special handling for Sales Reports
          subItemsWidgets.add(
            Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _isSalesReportsExpanded = !_isSalesReportsExpanded;
                      // Close other nested items within Reports when this one expands
                      if (_isSalesReportsExpanded) {
                        _isSAPReportsExpanded =
                            false; // Close SAP Reports when Sales Reports expands
                        _isGeneralReportsExpanded =
                            false; // Close General Reports when Sales Reports expands
                        _isMISReportsExpanded =
                            false; // Close MIS Reports when MIS Reports expands
                        _isSchemeDiscountExpanded =
                            false; // Close Scheme/Discount when Sales Reports expands
                        _isReportsRetailerExpanded =
                            false; // Close Reports Retailer when Sales Reports expands
                        _isChartReportsExpanded =
                            false; // Close Chart Reports when Sales Reports expands
                        _isMobileReportsExpanded =
                            false; // Close Mobile Reports when Sales Reports expands
                        _isSecondarySaleExpanded =
                            false; // Close Secondary Sale when Sales Reports expands
                        _isSchemeDetailsExpanded =
                            false; // Close Scheme Details when Sales Reports expands
                      }
                      _selectedDrawerItem = null;
                    });
                    print(
                      '${item['label']} tapped. Expand: $_isSalesReportsExpanded',
                    );
                    // No navigation on expansion
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['label']!,
                            style: _isSalesReportsExpanded
                              ? Fonts.bodyBold.copyWith(color: Colors.blue, fontSize: 14)
                              : Fonts.body.copyWith(color: Colors.black87, fontSize: 14),
                          ),
                        ),
                        Icon(
                          _isSalesReportsExpanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          size: 18, // Slightly larger icon
                          color:
                              _isSalesReportsExpanded
                                  ? Colors.blue
                                  : Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isSalesReportsExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                    ), // Further indent for sub-sub-items
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          _buildSalesReportsSubItems(), // Build the nested items for Sales Reports
                    ),
                  ),
                ],
              ],
            ),
          );
        } else if (item['label'] == 'Scheme/Discount') {
          // Special handling for Scheme/Discount
          subItemsWidgets.add(
            Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _isSchemeDiscountExpanded = !_isSchemeDiscountExpanded;
                      // Close other nested items within Reports when this one expands
                      if (_isSchemeDiscountExpanded) {
                        _isSAPReportsExpanded =
                            false; // Close SAP Reports when Scheme/Discount expands
                        _isGeneralReportsExpanded =
                            false; // Close General Reports when Scheme/Discount expands
                        _isMISReportsExpanded =
                            false; // Close MIS Reports when MIS Reports expands
                        _isSalesReportsExpanded =
                            false; // Close Sales Reports when Sales Reports expands
                        _isReportsRetailerExpanded =
                            false; // Close Reports Retailer when Scheme/Discount expands
                        _isChartReportsExpanded =
                            false; // Close Chart Reports when Chart Reports expands
                        _isMobileReportsExpanded =
                            false; // Close Mobile Reports when Mobile Reports expands
                        _isSecondarySaleExpanded =
                            false; // Close Secondary Sale when Scheme/Discount expands
                        _isSchemeDetailsExpanded =
                            false; // Close Scheme Details when Scheme/Discount expands
                      }
                      _selectedDrawerItem = null;
                    });
                    print(
                      '${item['label']} tapped. Expand: $_isSchemeDiscountExpanded',
                    );
                    // No navigation on expansion
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['label']!,
                            style: _isSchemeDiscountExpanded
                              ? Fonts.bodyBold.copyWith(color: Colors.blue, fontSize: 14)
                              : Fonts.body.copyWith(color: Colors.black87, fontSize: 14),
                          ),
                        ),
                        Icon(
                          _isSchemeDiscountExpanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          size: 18, // Slightly larger icon
                          color:
                              _isSchemeDiscountExpanded
                                  ? Colors.blue
                                  : Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isSchemeDiscountExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                    ), // Further indent for sub-sub-items
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          _buildSchemeDiscountSubItems(), // Build the nested items for Scheme/Discount
                    ),
                  ),
                ],
              ],
            ),
          );
        } else if (item['label'] == 'Retailer') {
          // Special handling for Retailer (Reports)
          subItemsWidgets.add(
            Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _isReportsRetailerExpanded = !_isReportsRetailerExpanded;
                      // Close other nested items within Reports when this one expands
                      if (_isReportsRetailerExpanded) {
                        _isSAPReportsExpanded =
                            false; // Close SAP Reports when Reports Retailer expands
                        _isGeneralReportsExpanded =
                            false; // Close General Reports when Reports Retailer expands
                        _isMISReportsExpanded =
                            false; // Close MIS Reports when Reports Retailer expands
                        _isSalesReportsExpanded =
                            false; // Close Sales Reports when Reports Retailer expands
                        _isSchemeDiscountExpanded =
                            false; // Close Scheme/Discount when Reports Retailer expands
                        _isChartReportsExpanded =
                            false; // Close Chart Reports when Reports Retailer expands
                        _isMobileReportsExpanded =
                            false; // Close Mobile Reports when Mobile Reports expands
                        _isSecondarySaleExpanded =
                            false; // Close Secondary Sale when Reports Retailer expands
                        _isSchemeDetailsExpanded =
                            false; // Close Scheme Details when Reports Retailer expands
                      }
                      _selectedDrawerItem = null;
                    });
                    print(
                      '${item['label']} tapped. Expand: $_isReportsRetailerExpanded',
                    );
                    // No navigation on expansion
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['label']!,
                            style: _isReportsRetailerExpanded
                              ? Fonts.bodyBold.copyWith(color: Colors.blue, fontSize: 14)
                              : Fonts.body.copyWith(color: Colors.black87, fontSize: 14),
                          ),
                        ),
                        Icon(
                          _isReportsRetailerExpanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          size: 18, // Slightly larger icon
                          color:
                              _isReportsRetailerExpanded
                                  ? Colors.blue
                                  : Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isReportsRetailerExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                    ), // Further indent for sub-sub-items
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          _buildReportsRetailerSubItems(), // Build the nested items for Reports Retailer
                    ),
                  ),
                ],
              ],
            ),
          );
        } else if (item['label'] == 'Chart Reports') {
          // Special handling for Chart Reports
          subItemsWidgets.add(
            Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _isChartReportsExpanded = !_isChartReportsExpanded;
                      // Close other nested items within Reports when this one expands
                      if (_isChartReportsExpanded) {
                        _isSAPReportsExpanded =
                            false; // Close SAP Reports when Chart Reports expands
                        _isGeneralReportsExpanded =
                            false; // Close General Reports when Chart Reports expands
                        _isMISReportsExpanded =
                            false; // Close MIS Reports when MIS Reports expands
                        _isSalesReportsExpanded =
                            false; // Close Sales Reports when Chart Reports expands
                        _isSchemeDiscountExpanded =
                            false; // Close Scheme/Discount when Chart Reports expands
                        _isReportsRetailerExpanded =
                            false; // Close Reports Retailer when Chart Reports expands
                        _isMobileReportsExpanded =
                            false; // Close Mobile Reports when Chart Reports expands
                        _isSecondarySaleExpanded =
                            false; // Close Secondary Sale when Chart Reports expands
                        _isSchemeDetailsExpanded =
                            false; // Close Scheme Details when Chart Reports expands
                      }
                      _selectedDrawerItem = null;
                    });
                    print(
                      '${item['label']} tapped. Expand: $_isChartReportsExpanded',
                    );
                    // No navigation on expansion
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['label']!,
                            style: _isChartReportsExpanded
                              ? Fonts.bodyBold.copyWith(color: Colors.blue, fontSize: 14)
                              : Fonts.body.copyWith(color: Colors.black87, fontSize: 14),
                          ),
                        ),
                        Icon(
                          _isChartReportsExpanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          size: 18, // Slightly larger icon
                          color:
                              _isChartReportsExpanded
                                  ? Colors.blue
                                  : Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isChartReportsExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                    ), // Further indent for sub-sub-items
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          _buildChartReportsSubItems(), // Build the nested items for Chart Reports
                    ),
                  ),
                ],
              ],
            ),
          );
        } else if (item['label'] == 'Mobile Reports') {
          // Special handling for Mobile Reports
          subItemsWidgets.add(
            Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _isMobileReportsExpanded = !_isMobileReportsExpanded;
                      // Close other nested items within Reports when this one expands
                      if (_isMobileReportsExpanded) {
                        _isSAPReportsExpanded =
                            false; // Close SAP Reports when Mobile Reports expands
                        _isGeneralReportsExpanded =
                            false; // Close General Reports when Mobile Reports expands
                        _isMISReportsExpanded =
                            false; // Close MIS Reports when MIS Reports expands
                        _isSalesReportsExpanded =
                            false; // Close Sales Reports when Sales Reports expands
                        _isSchemeDiscountExpanded =
                            false; // Close Scheme/Discount when Mobile Reports expands
                        _isReportsRetailerExpanded =
                            false; // Close Reports Retailer when Mobile Reports expands
                        _isChartReportsExpanded =
                            false; // Close Chart Reports when Mobile Reports expands
                        _isSecondarySaleExpanded =
                            false; // Close Secondary Sale when Mobile Reports expands
                        _isSchemeDetailsExpanded =
                            false; // Close Scheme Details when Mobile Reports expands
                      }
                      _selectedDrawerItem = null;
                    });
                    print(
                      '${item['label']} tapped. Expand: $_isMobileReportsExpanded',
                    );
                    // No navigation on expansion
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['label']!,
                            style: _isMobileReportsExpanded
                              ? Fonts.bodyBold.copyWith(color: Colors.blue, fontSize: 14)
                              : Fonts.body.copyWith(color: Colors.black87, fontSize: 14),
                          ),
                        ),
                        Icon(
                          _isMobileReportsExpanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          size: 18, // Slightly larger icon
                          color:
                              _isMobileReportsExpanded
                                  ? Colors.blue
                                  : Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isMobileReportsExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                    ), // Further indent for sub-sub-items
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          _buildMobileReportsSubItems(), // Build the nested items for Mobile Reports
                    ),
                  ),
                ],
              ],
            ),
          );
        } else if (item['label'] == 'Secondary Sale') {
          // Special handling for Secondary Sale
          subItemsWidgets.add(
            Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _isSecondarySaleExpanded = !_isSecondarySaleExpanded;
                      // Close other nested items within Reports when this one expands
                      if (_isSecondarySaleExpanded) {
                        _isSAPReportsExpanded =
                            false; // Close SAP Reports when Secondary Sale expands
                        _isGeneralReportsExpanded =
                            false; // Close General Reports when Secondary Sale expands
                        _isMISReportsExpanded =
                            false; // Close MIS Reports when MIS Reports expands
                        _isSalesReportsExpanded =
                            false; // Close Sales Reports when Secondary Sale expands
                        _isSchemeDiscountExpanded =
                            false; // Close Scheme/Discount when Secondary Sale expands
                        _isReportsRetailerExpanded =
                            false; // Close Reports Retailer when Secondary Sale expands
                        _isChartReportsExpanded =
                            false; // Close Chart Reports when Secondary Sale expands
                        _isMobileReportsExpanded =
                            false; // Close Mobile Reports when Secondary Sale expands
                        _isSchemeDetailsExpanded =
                            false; // Close Scheme Details when Secondary Sale expands
                      }
                      _selectedDrawerItem = null;
                    });
                    print(
                      '${item['label']} tapped. Expand: $_isSecondarySaleExpanded',
                    );
                    // No navigation on expansion
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['label']!,
                            style: _isSecondarySaleExpanded
                              ? Fonts.bodyBold.copyWith(color: Colors.blue, fontSize: 14)
                              : Fonts.body.copyWith(color: Colors.black87, fontSize: 14),
                          ),
                        ),
                        Icon(
                          _isSecondarySaleExpanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          size: 18, // Slightly larger icon
                          color:
                              _isSecondarySaleExpanded
                                  ? Colors.blue
                                  : Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isSecondarySaleExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                    ), // Further indent for sub-sub-items
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          _buildSecondarySaleSubItems(), // Build the nested items for Secondary Sale
                    ),
                  ),
                ],
              ],
            ),
          );
        } else if (item['label'] == 'Scheme Details') {
          // Special handling for Scheme Details
          subItemsWidgets.add(
            Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _isSchemeDetailsExpanded = !_isSchemeDetailsExpanded;
                      // Close other nested items within Reports when this one expands
                      if (_isSchemeDetailsExpanded) {
                        _isSAPReportsExpanded =
                            false; // Close SAP Reports when Scheme Details expands
                        _isGeneralReportsExpanded =
                            false; // Close General Reports when Scheme Details expands
                        _isMISReportsExpanded =
                            false; // Close MIS Reports when MIS Reports expands
                        _isSalesReportsExpanded =
                            false; // Close Sales Reports when Sales Reports expands
                        _isSchemeDiscountExpanded =
                            false; // Close Scheme/Discount when Scheme Details expands
                        _isReportsRetailerExpanded =
                            false; // Close Reports Retailer when Scheme Details expands
                        _isChartReportsExpanded =
                            false; // Close Chart Reports when Scheme Details expands
                        _isMobileReportsExpanded =
                            false; // Close Mobile Reports when Scheme Details expands
                        _isSecondarySaleExpanded =
                            false; // Close Secondary Sale when Scheme Details expands
                      }
                      _selectedDrawerItem = null;
                    });
                    print(
                      '${item['label']} tapped. Expand: $_isSchemeDetailsExpanded',
                    );
                    // No navigation on expansion
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['label']!,
                            style: _isSchemeDetailsExpanded
                              ? Fonts.bodyBold.copyWith(color: Colors.blue, fontSize: 14)
                              : Fonts.body.copyWith(color: Colors.black87, fontSize: 14),
                          ),
                        ),
                        Icon(
                          _isSchemeDetailsExpanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          size: 18, // Slightly larger icon
                          color:
                              _isSchemeDetailsExpanded
                                  ? Colors.blue
                                  : Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isSchemeDetailsExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                    ), // Further indent for sub-sub-items
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          _buildSchemeDetailsSubItems(), // Build the nested items for Scheme Details
                    ),
                  ),
                ],
              ],
            ),
          );
        } else {
          // Normal report sub-item
          subItemsWidgets.add(
            InkWell(
              onTap: () {
                // TODO: Implement navigation logic for sub-items
                print('${item['label']} tapped. Navigate to ${item['route']}');
                // Close the drawer after tapping a sub-item
                Navigator.pop(context);
                // Add your navigation logic here (e.g., Navigator.push)
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ), // Adjust padding for sub-items
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: Colors.blueGrey[300],
                    ), // Added a small leading icon
                    const SizedBox(width: 12), // Spacing after the icon
                    Expanded(
                      // Use Expanded for sub-item text
                      child: Text(
                        item['label']!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_right,
                      size: 18,
                      color: Colors.grey[600],
                    ), // Slightly larger icon
                  ],
                ),
              ),
            ),
          );
        }
      }
    } else if (parentTitle == "Masters") {
      final List<Map<String, String>> masterSubItems = [
        {'label': 'Customer', 'route': 'customer_master'},
        {'label': 'Misc Master', 'route': 'misc_master'},
        {'label': 'Credit Note', 'route': 'credit_note_master'},
      ];
      for (var item in masterSubItems) {
        if (item['label'] == 'Customer') {
          // Special handling for Customer to make it expandable
          subItemsWidgets.add(
            Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _isCustomerExpanded = !_isCustomerExpanded;
                      // Close other nested items within Masters when this one expands
                      if (_isCustomerExpanded) {
                        _isMiscMasterExpanded =
                            false; // Close Misc Master when Customer expands
                        _isCreditNoteExpanded =
                            false; // Close Credit Note when Customer expands
                      }
                      _selectedDrawerItem =
                          null; // Deselect parent when expanded
                    });
                    print(
                      '${item['label']} tapped. Expand: $_isCustomerExpanded',
                    );
                    // No navigation on expansion
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['label']!,
                            style: _isCustomerExpanded
                              ? Fonts.bodyBold.copyWith(color: Colors.blue, fontSize: 14)
                              : Fonts.body.copyWith(color: Colors.black87, fontSize: 14),
                          ),
                        ),
                        Icon(
                          _isCustomerExpanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          size: 18, // Slightly larger icon
                          color:
                              _isCustomerExpanded
                                  ? Colors.blue
                                  : Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isCustomerExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                    ), // Further indent for sub-sub-items
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          _buildCustomerSubItems(), // Build the nested items for Customer
                    ),
                  ),
                ],
              ],
            ),
          );
        } else if (item['label'] == 'Misc Master') {
          // Special handling for Misc Master
          subItemsWidgets.add(
            Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _isMiscMasterExpanded = !_isMiscMasterExpanded;
                      // Close other nested items within Masters when this one expands
                      if (_isMiscMasterExpanded) {
                        _isCustomerExpanded =
                            false; // Close Customer when Misc Master expands
                        _isCreditNoteExpanded =
                            false; // Close Credit Note when Misc Master expands
                      }
                      _selectedDrawerItem = null;
                    });
                    print(
                      '${item['label']} tapped. Expand: $_isMiscMasterExpanded',
                    );
                    // No navigation on expansion
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['label']!,
                            style: _isMiscMasterExpanded
                              ? Fonts.bodyBold.copyWith(color: Colors.blue, fontSize: 14)
                              : Fonts.body.copyWith(color: Colors.black87, fontSize: 14),
                          ),
                        ),
                        Icon(
                          _isMiscMasterExpanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          size: 18, // Slightly larger icon
                          color:
                              _isMiscMasterExpanded
                                  ? Colors.blue
                                  : Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isMiscMasterExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                    ), // Further indent for sub-sub-items
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          _buildMiscMasterSubItems(), // Build the nested items for Misc Master
                    ),
                  ),
                ],
              ],
            ),
          );
        } else if (item['label'] == 'Credit Note') {
          // Special handling for Credit Note
          subItemsWidgets.add(
            Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _isCreditNoteExpanded = !_isCreditNoteExpanded;
                      // Close other nested items within Masters when this one expands
                      if (_isCreditNoteExpanded) {
                        _isCustomerExpanded =
                            false; // Close Customer when Credit Note expands
                        _isMiscMasterExpanded =
                            false; // Close Misc Master when Credit Note expands
                      }
                      _selectedDrawerItem = null;
                    });
                    print(
                      '${item['label']} tapped. Expand: $_isCreditNoteExpanded',
                    );
                    // No navigation on expansion
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['label']!,
                            style: _isCreditNoteExpanded
                              ? Fonts.bodyBold.copyWith(color: Colors.blue, fontSize: 14)
                              : Fonts.body.copyWith(color: Colors.black87, fontSize: 14),
                          ),
                        ),
                        Icon(
                          _isCreditNoteExpanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          size: 18, // Slightly larger icon
                          color:
                              _isCreditNoteExpanded
                                  ? Colors.blue
                                  : Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isCreditNoteExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                    ), // Further indent for sub-sub-items
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          _buildCreditNoteSubItems(), // Build the nested items for Credit Note
                    ),
                  ),
                ],
              ],
            ),
          );
        } else {
          // Normal master sub-item
          subItemsWidgets.add(
            InkWell(
              onTap: () {
                // TODO: Implement navigation logic for sub-items
                print('${item['label']} tapped. Navigate to ${item['route']}');
                // Close the drawer after tapping a sub-item
                Navigator.pop(context);
                // Add your navigation logic here (e.g., Navigator.push)
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ), // Adjust padding for sub-items
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: Colors.blueGrey[300],
                    ), // Added a small leading icon
                    const SizedBox(width: 12), // Spacing after the icon
                    Expanded(
                      // Use Expanded for sub-item text
                      child: Text(
                        item['label']!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_right,
                      size: 18,
                      color: Colors.grey[600],
                    ), // Slightly larger icon
                  ],
                ),
              ),
            ),
          );
        }
      }
    } else if (parentTitle == "Miscellaneous") {
      // Add Miscellaneous sub-items
      final List<Map<String, String>> miscellaneousSubItems = [
        {'label': 'Change Password', 'route': 'change_password'},
        {'label': 'Software Download', 'route': 'software_download'},
        {'label': 'Photo Gallery', 'route': 'photo_gallery'},
        {'label': 'SMS Query Code Help', 'route': 'sms_query_help'},
      ];
      subItemsWidgets =
          miscellaneousSubItems.map((item) {
            return InkWell(
              onTap: () {
                // TODO: Implement navigation logic for sub-items
                print('${item['label']} tapped. Navigate to ${item['route']}');
                // Close the drawer after tapping a sub-item
                Navigator.pop(context);
                // Add your navigation logic here (e.g., Navigator.push)
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ), // Adjust padding for sub-items
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: Colors.blueGrey[300],
                    ), // Added a small leading icon
                    const SizedBox(width: 12), // Spacing after the icon
                    Expanded(
                      // Use Expanded for sub-item text
                      child: Text(
                        item['label']!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_right,
                      size: 18,
                      color: Colors.grey[600],
                    ), // Slightly larger icon
                  ],
                ),
              ),
            );
          }).toList();
    }

    return subItemsWidgets;
  }

  // Helper to build the nested items under Financial Accounts
  List<Widget> _buildFinancialAccountsSubItems() {
    final List<Map<String, String>> financialAccountsSubItems = [
      {'label': 'Token Scan', 'route': 'token_scan'},
      {'label': 'Balance Confirmation', 'route': 'balance_confirmation'},
      {'label': 'Invoice Acknowledgement', 'route': 'invoice_acknowledgement'},
      {
        'label': 'Ever White Coupon Generation - Print',
        'route': 'coupon_generation',
      },
      {'label': '194Q Detail Entry', 'route': '194q_detail_entry'},
      {'label': 'Token Scan Details', 'route': 'token_scan_details'},
      {'label': 'Token Scan Report', 'route': 'token_scan_report'},
      {'label': 'Token Scan New', 'route': 'token_scan_new'},
    ];

    return financialAccountsSubItems.map((item) {
      return InkWell(
        onTap: () {
          // TODO: Implement navigation logic for sub-sub-items
          print('${item['label']} tapped. Navigate to ${item['route']}');
          // Close the drawer after tapping a sub-sub-item
          Navigator.pop(context);
          // Add your navigation logic here (e.g., Navigator.push)
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ), // Adjust padding for sub-sub-items
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 6,
                color: Colors.blueGrey[200],
              ), // Added a smaller leading icon
              const SizedBox(width: 10), // Spacing after the icon
              Expanded(
                // Use Expanded for sub-sub-item text
                child: Text(
                  item['label']!,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ), // Slightly smaller and lighter text
              ),
              Icon(
                Icons.arrow_right,
                size: 16,
                color: Colors.grey[500],
              ), // Slightly smaller icon
            ],
          ),
        ),
      );
    }).toList();
  }

  // Helper to build the nested items under Depot Order
  List<Widget> _buildDepotOrderSubItems() {
    final List<Map<String, String>> depotOrderSubItems = [
      {'label': 'Secondary Sale capture', 'route': 'secondary_sale_capture'},
      {'label': 'Order Update', 'route': 'order_update'},
      {'label': 'Order Entry', 'route': 'order_entry'},
    ];

    return depotOrderSubItems.map((item) {
      return InkWell(
        onTap: () {
          // TODO: Implement navigation logic for sub-sub-items
          print('${item['label']} tapped. Navigate to ${item['route']}');
          // Close the drawer after tapping a sub-sub-item
          Navigator.pop(context);
          // Add your navigation logic here (e.g., Navigator.push)
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ), // Adjust padding for sub-sub-items
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 6,
                color: Colors.blueGrey[200],
              ), // Added a smaller leading icon
              const SizedBox(width: 10), // Spacing after the icon
              Expanded(
                // Use Expanded for sub-sub-item text
                child: Text(
                  item['label']!,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ), // Slightly smaller and lighter text
              ),
              Icon(
                Icons.arrow_right,
                size: 16,
                color: Colors.grey[500],
              ), // Slightly smaller icon
            ],
          ),
        ),
      );
    }).toList();
  }

  // Helper to build the nested items under Retailer (Transactions)
  List<Widget> _buildRetailerSubItems() {
    final List<Map<String, String>> retailerSubItems = [
      {
        'label': 'Rural Retailer Entry / Update',
        'route': 'rural_retailer_entry_update',
      },
      {'label': 'Retailer Registration', 'route': 'retailer_registration'},
    ];

    return retailerSubItems.map((item) {
      return InkWell(
        onTap: () {
          // TODO: Implement navigation logic for sub-sub-items
          print('${item['label']} tapped. Navigate to ${item['route']}');
          // Close the drawer after tapping a sub-sub-item
          Navigator.pop(context);
          // Add your navigation logic here (e.e., Navigator.push)
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ), // Adjust padding for sub-sub-items
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 6,
                color: Colors.blueGrey[200],
              ), // Added a smaller leading icon
              const SizedBox(width: 10), // Spacing after the icon
              Expanded(
                // Use Expanded for sub-sub-item text
                child: Text(
                  item['label']!,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ), // Slightly smaller and lighter text
              ),
              Icon(
                Icons.arrow_right,
                size: 16,
                color: Colors.grey[500],
              ), // Slightly smaller icon
            ],
          ),
        ),
      );
    }).toList();
  }

  // Helper to build the nested items under Sales Force
  List<Widget> _buildSalesForceSubItems() {
    final List<Map<String, String>> salesForceSubItems = [
      {
        'label': 'Notification Sent Details',
        'route': 'notification_sent_details',
      },
      {'label': 'User Rating', 'route': 'user_rating'},
    ];

    return salesForceSubItems.map((item) {
      return InkWell(
        onTap: () {
          // TODO: Implement navigation logic for sub-sub-items
          print('${item['label']} tapped. Navigate to ${item['route']}');
          // Close the drawer after tapping a sub-sub-item
          Navigator.pop(context);
          // Add your navigation logic here (e.g., Navigator.push)
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ), // Adjust padding for sub-sub-items
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 6,
                color: Colors.blueGrey[200],
              ), // Added a smaller leading icon
              const SizedBox(width: 10), // Spacing after the icon
              Expanded(
                // Use Expanded for sub-sub-item text
                child: Text(
                  item['label']!,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ), // Slightly smaller and lighter text
              ),
              Icon(
                Icons.arrow_right,
                size: 16,
                color: Colors.grey[500],
              ), // Slightly smaller icon
            ],
          ),
        ),
      );
    }).toList();
  }

  // Helper to build the nested items under Mission Udaan
  List<Widget> _buildMissionUdaanSubItems() {
    final List<Map<String, String>> missionUdaanSubItems = [
      {
        'label': 'Invoice Cancellation in Bulk',
        'route': 'invoice_cancellation_bulk',
      },
      {
        'label': 'Secondary Sales Invoice Entry',
        'route': 'secondary_sales_invoice_entry',
      },
    ];

    return missionUdaanSubItems.map((item) {
      return InkWell(
        onTap: () {
          // TODO: Implement navigation logic for sub-sub-items
          print('${item['label']} tapped. Navigate to ${item['route']}');
          // Close the drawer after tapping a sub-sub-item
          Navigator.pop(context);
          // Add your navigation logic here (e.g., Navigator.push)
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ), // Adjust padding for sub-sub-items
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 6,
                color: Colors.blueGrey[200],
              ), // Added a smaller leading icon
              const SizedBox(width: 10), // Spacing after the icon
              Expanded(
                // Use Expanded for sub-sub-item text
                child: Text(
                  item['label']!,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ), // Slightly smaller and lighter text
              ),
              Icon(
                Icons.arrow_right,
                size: 16,
                color: Colors.grey[500],
              ), // Slightly smaller icon
            ],
          ),
        ),
      );
    }).toList();
  }

  // Helper to build the nested items under SAP Reports
  List<Widget> _buildSAPReportsSubItems() {
    final List<Map<String, String>> sapReportsSubItems = [
      {'label': 'Day Summary', 'route': 'day_summary'},
      {'label': 'Day Wise Details', 'route': 'day_wise_details'},
      {
        'label': 'Day Summary Qty / Value Wise',
        'route': 'day_summary_qty_value_wise',
      },
      {'label': 'Sales - Purchaser - wise', 'route': 'sales_purchaser_wise'},
      {'label': 'Packing - wise', 'route': 'packing_wise'},
      {'label': 'Year on Year Comparison', 'route': 'year_on_year_comparison'},
    ];

    return sapReportsSubItems.map((item) {
      return InkWell(
        onTap: () {
          //  Implement navigation logic for sub-sub-items
          print('${item['label']} tapped. Navigate to ${item['route']}');
          //  Close the drawer after tapping a sub-sub-item
          Navigator.pop(context);
          // Add your navigation logic here (e.g., Navigator.push)
          if (item['route'] == 'day_summary') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DaySummary(),
              ), // Assuming Schema is the name of your widget/screen
            );
          }
          if (item['route'] == 'day_wise_details') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DayWiseSummary()),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ), // Adjust padding for sub-sub-items
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 6,
                color: Colors.blueGrey[200],
              ), // Added a smaller leading icon
              const SizedBox(width: 10), // Spacing after the icon
              Expanded(
                // Use Expanded for sub-sub-item text
                child: Text(
                  item['label']!,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ), // Slightly smaller and lighter text
              ),
              Icon(
                Icons.arrow_right,
                size: 16,
                color: Colors.grey[500],
              ), // Slightly smaller icon
            ],
          ),
        ),
      );
    }).toList();
  }

  // Helper to build the nested items under General Reports
  List<Widget> _buildGeneralReportsSubItems() {
    final List<Map<String, String>> generalReportsSubItems = [
      {'label': 'Pending Freight Report', 'route': 'pending_freight_report'},
      {'label': 'Accounts Statement', 'route': 'accounts_statement'},
      {'label': 'Contact US', 'route': 'contact_us'},
      {'label': 'Information Document', 'route': 'information_document'},
    ];

    return generalReportsSubItems.map((item) {
      return InkWell(
        onTap: () {
          // TODO: Implement navigation logic for sub-sub-items
          print('${item['label']} tapped. Navigate to ${item['route']}');
          // Close the drawer after tapping a sub-sub-item
          Navigator.pop(context);
          // Add your navigation logic here (e.g., Navigator.push)
          if (item['route'] == 'accounts_statement') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AccountStatement()),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ), // Adjust padding for sub-sub-items
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 6,
                color: Colors.blueGrey[200],
              ), // Added a smaller leading icon
              const SizedBox(width: 10), // Spacing after the icon
              Expanded(
                // Use Expanded for sub-sub-item text
                child: Text(
                  item['label']!,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ), // Slightly smaller and lighter text
              ),
              Icon(
                Icons.arrow_right,
                size: 16,
                color: Colors.grey[500],
              ), // Slightly smaller icon
            ],
          ),
        ),
      );
    }).toList();
  }

  // Helper to build the nested items under MIS Reports
  List<Widget> _buildMISReportsSubItems() {
    final List<Map<String, String>> misReportsSubItems = [
      {
        'label': 'Purchaser Ageing Report (SAP)',
        'route': 'purchaser_ageing_report_sap',
      },
    ];

    return misReportsSubItems.map((item) {
      return InkWell(
        onTap: () {
          // TODO: Implement navigation logic for sub-sub-items
          print('${item['label']} tapped. Navigate to ${item['route']}');
          // Close the drawer after tapping a sub-sub-item
          Navigator.pop(context);
          // Add your navigation logic here (e.g., Navigator.push)
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ), // Adjust padding for sub-sub-items
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 6,
                color: Colors.blueGrey[200],
              ), // Added a smaller leading icon
              const SizedBox(width: 10), // Spacing after the icon
              Expanded(
                // Use Expanded for sub-sub-item text
                child: Text(
                  item['label']!,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ), // Slightly smaller and lighter text
              ),
              Icon(
                Icons.arrow_right,
                size: 16,
                color: Colors.grey[500],
              ), // Slightly smaller icon
            ],
          ),
        ),
      );
    }).toList();
  }

  // Helper to build the nested items under Sales Reports
  List<Widget> _buildSalesReportsSubItems() {
    final List<Map<String, String>> salesReportsSubItems = [
      {'label': 'Product Catg-wise Sales', 'route': 'product_catg_wise_sales'},
      {
        'label': 'Sales Growth Overview YTD / MTD',
        'route': 'sales_growth_overview',
      },
    ];

    return salesReportsSubItems.map((item) {
      return InkWell(
        onTap: () {
          // TODO: Implement navigation logic for sub-sub-items
          print('${item['label']} tapped. Navigate to ${item['route']}');
          // Close the drawer after tapping a sub-sub-item
          Navigator.pop(context);
          // Add your navigation logic here (e.g., Navigator.push)
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ), // Adjust padding for sub-sub-items
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 6,
                color: Colors.blueGrey[200],
              ), // Added a smaller leading icon
              const SizedBox(width: 10), // Spacing after the icon
              Expanded(
                // Use Expanded for sub-sub-item text
                child: Text(
                  item['label']!,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ), // Slightly smaller and lighter text
              ),
              Icon(
                Icons.arrow_right,
                size: 16,
                color: Colors.grey[500],
              ), // Slightly smaller icon
            ],
          ),
        ),
      );
    }).toList();
  }

  // Helper to build the nested items under Scheme/Discount
  List<Widget> _buildSchemeDiscountSubItems() {
    final List<Map<String, String>> schemeDiscountSubItems = [
      {
        'label': 'Purchaser & Retailer Disbursement Details',
        'route': 'purchaser_retailer_disbursement_details',
      },
      {'label': 'RPL Outlet Tracker', 'route': 'rpl_outlet_tracker'},
      {
        'label': 'Scheme Disbursement View',
        'route': 'scheme_disbursement_view',
      },
    ];

    return schemeDiscountSubItems.map((item) {
      return InkWell(
        onTap: () {
          // TODO: Implement navigation logic for sub-sub-items
          print('${item['label']} tapped. Navigate to ${item['route']}');
          // Close the drawer after tapping a sub-sub-item
          Navigator.pop(context);
          // Add your navigation logic here (e.g., Navigator.push)
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ), // Adjust padding for sub-sub-items
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 6,
                color: Colors.blueGrey[200],
              ), // Added a smaller leading icon
              const SizedBox(width: 10), // Spacing after the icon
              Expanded(
                // Use Expanded for sub-sub-item text
                child: Text(
                  item['label']!,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ), // Slightly smaller and lighter text
              ),
              Icon(
                Icons.arrow_right,
                size: 16,
                color: Colors.grey[500],
              ), // Slightly smaller icon
            ],
          ),
        ),
      );
    }).toList();
  }

  // Helper to build the nested items under Reports Retailer
  List<Widget> _buildReportsRetailerSubItems() {
    final List<Map<String, String>> reportsRetailerSubItems = [
      {'label': 'Retailer Report', 'route': 'retailer_report'},
      {'label': 'Retailer KYC Details', 'route': 'retailer_kyc_details'},
    ];

    return reportsRetailerSubItems.map((item) {
      return InkWell(
        onTap: () {
          // TODO: Implement navigation logic for sub-sub-items
          print('${item['label']} tapped. Navigate to ${item['route']}');
          // Close the drawer after tapping a sub-sub-item
          Navigator.pop(context);
          // Add your navigation logic here (e.g., Navigator.push)
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ), // Adjust padding for sub-sub-items
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 6,
                color: Colors.blueGrey[200],
              ), // Added a smaller leading icon
              const SizedBox(width: 10), // Spacing after the icon
              Expanded(
                // Use Expanded for sub-sub-item text
                child: Text(
                  item['label']!,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ), // Slightly smaller and lighter text
              ),
              Icon(
                Icons.arrow_right,
                size: 16,
                color: Colors.grey[500],
              ), // Slightly smaller icon
            ],
          ),
        ),
      );
    }).toList();
  }

  // Helper to build the nested items under Chart Reports
  List<Widget> _buildChartReportsSubItems() {
    final List<Map<String, String>> chartReportsSubItems = [
      {'label': 'Sales Overview', 'route': 'sales_overview_chart'},
    ];

    return chartReportsSubItems.map((item) {
      return InkWell(
        onTap: () {
          // TODO: Implement navigation logic for sub-sub-items
          print('${item['label']} tapped. Navigate to ${item['route']}');
          // Close the drawer after tapping a sub-sub-item
          Navigator.pop(context);
          // Add your navigation logic here (e.g., Navigator.push)
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ), // Adjust padding for sub-sub-items
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 6,
                color: Colors.blueGrey[200],
              ), // Added a smaller leading icon
              const SizedBox(width: 10), // Spacing after the icon
              Expanded(
                // Use Expanded for sub-sub-item text
                child: Text(
                  item['label']!,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ), // Slightly smaller and lighter text
              ),
              Icon(
                Icons.arrow_right,
                size: 16,
                color: Colors.grey[500],
              ), // Slightly smaller icon
            ],
          ),
        ),
      );
    }).toList();
  }

  // Helper to build the nested items under Mobile Reports
  List<Widget> _buildMobileReportsSubItems() {
    final List<Map<String, String>> mobileReportsSubItems = [
      {'label': 'Purchaser 360', 'route': 'purchaser_360_mobile'},
    ];

    return mobileReportsSubItems.map((item) {
      return InkWell(
        onTap: () {
          // TODO: Implement navigation logic for sub-sub-items
          print('${item['label']} tapped. Navigate to ${item['route']}');
          // Close the drawer after tapping a sub-sub-item
          Navigator.pop(context);
          // Add your navigation logic here (e.g., Navigator.push)
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ), // Adjust padding for sub-sub-items
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 6,
                color: Colors.blueGrey[200],
              ), // Added a smaller leading icon
              const SizedBox(width: 10), // Spacing after the icon
              Expanded(
                // Use Expanded for sub-sub-item text
                child: Text(
                  item['label']!,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ), // Slightly smaller and lighter text
              ),
              Icon(
                Icons.arrow_right,
                size: 16,
                color: Colors.grey[500],
              ), // Slightly smaller icon
            ],
          ),
        ),
      );
    }).toList();
  }

  // Helper to build the nested items under Secondary Sale
  List<Widget> _buildSecondarySaleSubItems() {
    final List<Map<String, String>> secondarySaleSubItems = [
      {
        'label': 'Stock & Rollout Data (Tally)',
        'route': 'stock_rollout_data_tally',
      },
      // {'label': 'Secondary Sale (Tally)', 'route': 'secondary_sale_tally'}, // Excluding this as it seems redundant
      {'label': 'Stock Data Tally', 'route': 'stock_data_tally'},
      {'label': 'Retailers Sales Report', 'route': 'retailers_sales_report'},
      {
        'label': 'Retailer Target Vs Actual',
        'route': 'retailer_target_vs_actual',
      },
      {'label': 'My Network', 'route': 'my_network'},
      {
        'label': 'Tally Data Customer Wise',
        'route': 'tally_data_customer_wise',
      },
    ];

    return secondarySaleSubItems.map((item) {
      return InkWell(
        onTap: () {
          // TODO: Implement navigation logic for sub-sub-items
          print('${item['label']} tapped. Navigate to ${item['route']}');
          // Close the drawer after tapping a sub-sub-item
          Navigator.pop(context);
          // Add your navigation logic here (e.g., Navigator.push)
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ), // Adjust padding for sub-sub-items
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 6,
                color: Colors.blueGrey[200],
              ), // Added a smaller leading icon
              const SizedBox(width: 10), // Spacing after the icon
              Expanded(
                // Use Expanded for sub-sub-item text
                child: Text(
                  item['label']!,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ), // Slightly smaller and lighter text
              ),
              Icon(
                Icons.arrow_right,
                size: 16,
                color: Colors.grey[500],
              ), // Slightly smaller icon
            ],
          ),
        ),
      );
    }).toList();
  }

  // Helper to build the nested items under Scheme Details
  List<Widget> _buildSchemeDetailsSubItems() {
    final List<Map<String, String>> schemeDetailsSubItems = [
      {'label': 'Schemes Summary', 'route': 'schemes_summary'},
    ];

    return schemeDetailsSubItems.map((item) {
      return InkWell(
        onTap: () {
          // TODO: Implement navigation logic for sub-sub-items
          print('${item['label']} tapped. Navigate to ${item['route']}');
          // Close the drawer after tapping a sub-sub-item
          Navigator.pop(context);
          // Add your navigation logic here (e.g., Navigator.push)
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ), // Adjust padding for sub-sub-items
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 6,
                color: Colors.blueGrey[200],
              ), // Added a smaller leading icon
              const SizedBox(width: 10), // Spacing after the icon
              Expanded(
                // Use Expanded for sub-sub-item text
                child: Text(
                  item['label']!,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ), // Slightly smaller and lighter text
              ),
              Icon(
                Icons.arrow_right,
                size: 16,
                color: Colors.grey[500],
              ), // Slightly smaller icon
            ],
          ),
        ),
      );
    }).toList();
  }

  // Helper to build the nested items under Customer (Masters)
  List<Widget> _buildCustomerSubItems() {
    final List<Map<String, String>> customerSubItems = [
      {'label': 'Purchaser Profile', 'route': 'purchaser_profile'},
      {'label': 'TAN No Update', 'route': 'tan_no_update'},
      {'label': 'SAP Invoice printing', 'route': 'sap_invoice_printing'},
    ];

    return customerSubItems.map((item) {
      return InkWell(
        onTap: () {
          // TODO: Implement navigation logic for sub-sub-items
          print('${item['label']} tapped. Navigate to ${item['route']}');
          // Close the drawer after tapping a sub-sub-item
          Navigator.pop(context);
          // Add your navigation logic here (e.g., Navigator.push)
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ), // Adjust padding for sub-sub-items
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 6,
                color: Colors.blueGrey[200],
              ), // Added a smaller leading icon
              const SizedBox(width: 10), // Spacing after the icon
              Expanded(
                // Use Expanded for sub-sub-item text
                child: Text(
                  item['label']!,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ), // Slightly smaller and lighter text
              ),
              Icon(
                Icons.arrow_right,
                size: 16,
                color: Colors.grey[500],
              ), // Slightly smaller icon
            ],
          ),
        ),
      );
    }).toList();
  }

  // Helper to build the nested items under Misc Master
  List<Widget> _buildMiscMasterSubItems() {
    final List<Map<String, String>> miscMasterSubItems = [
      {'label': 'Pin Code Master', 'route': 'pin_code_master'},
      {'label': 'Profile Photo', 'route': 'profile_photo'},
    ];

    return miscMasterSubItems.map((item) {
      return InkWell(
        onTap: () {
          // TODO: Implement navigation logic for sub-sub-items
          print('${item['label']} tapped. Navigate to ${item['route']}');
          // Close the drawer after tapping a sub-sub-item
          Navigator.pop(context);
          // Add your navigation logic here (e.g., Navigator.push)
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ), // Adjust padding for sub-sub-items
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 6,
                color: Colors.blueGrey[200],
              ), // Added a smaller leading icon
              const SizedBox(width: 10), // Spacing after the icon
              Expanded(
                // Use Expanded for sub-sub-item text
                child: Text(
                  item['label']!,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ), // Slightly smaller and lighter text
              ),
              Icon(
                Icons.arrow_right,
                size: 16,
                color: Colors.grey[500],
              ), // Slightly smaller icon
            ],
          ),
        ),
      );
    }).toList();
  }

  // Helper to build the nested items under Credit Note
  List<Widget> _buildCreditNoteSubItems() {
    final List<Map<String, String>> creditNoteSubItems = [
      {'label': 'Guarantor Orc Entry', 'route': 'guarantor_orc_entry'},
      {'label': 'Guarantor ORC view', 'route': 'guarantor_orc_view'},
    ];

    return creditNoteSubItems.map((item) {
      return InkWell(
        onTap: () {
          // TODO: Implement navigation logic for sub-sub-items
          print('${item['label']} tapped. Navigate to ${item['route']}');
          // Close the drawer after tapping a sub-sub-item
          Navigator.pop(context);
          // Add your navigation logic here (e.g., Navigator.push)
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ), // Adjust padding for sub-sub-items
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 6,
                color: Colors.blueGrey[200],
              ), // Added a smaller leading icon
              const SizedBox(width: 10), // Spacing after the icon
              Expanded(
                // Use Expanded for sub-sub-item text
                child: Text(
                  item['label']!,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ), // Slightly smaller and lighter text
              ),
              Icon(
                Icons.arrow_right,
                size: 16,
                color: Colors.grey[500],
              ), // Slightly smaller icon
            ],
          ),
        ),
      );
    }).toList();
  }
}
