import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for Clipboard
import 'package:intl/intl.dart';
import 'dart:math'; // Import for min function

// You will need to add packages for file generation and download, e.g.:
// import 'package:csv/csv.dart'; // For CSV generation
// import 'package:excel/excel.dart'; // For Excel generation
// import 'package:pdf/pdf.dart'; // For PDF generation
// import 'package:pdf/widgets.dart' as pw; // For PDF widgets
// import 'package:path_provider/path_provider.dart'; // For getting directory paths
// import 'package:open_filex/open_filex.dart'; // For opening downloaded files (mobile/desktop)
// import 'dart:html' as html; // For web downloads

class DaySummary extends StatefulWidget {
  const DaySummary({super.key});

  @override
  State<DaySummary> createState() => _DaySummaryState();
}

class _DaySummaryState extends State<DaySummary> {
  // Controllers for date text fields
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // Variables to store selected dates
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  // Controller for the search field
  final TextEditingController _searchController = TextEditingController();

  // Placeholder data for the table (full dataset)
  final List<Map<String, dynamic>> _fullSummaryData = [
    // Example data rows - added new fields
    {
      'purchaserCode': 'PC001',
      'name': 'John Doe',
      'product': 'Product A',
      'qty': 10,
      'basicValue': 100.00,
      'billValue': 110.00,
      'excise': 5.00,
      'salesTax': 5.00,
      'transitIns': 2.00,
      'freight': 3.00,
      'servcTax': 1.00, // Added Service Tax
      'cessOnServcTax': 0.10, // Added Cess on Service Tax
      'totalValue': 0.00, // Will be calculated
    },
    {
      'purchaserCode': 'PC002',
      'name': 'Jane Smith',
      'product': 'Product B',
      'qty': 15,
      'basicValue': 150.00,
      'billValue': 165.00,
      'excise': 7.50,
      'salesTax': 7.50,
      'transitIns': 3.00,
      'freight': 4.00,
      'servcTax': 1.50,
      'cessOnServcTax': 0.15,
      'totalValue': 0.00,
    },
    {
      'purchaserCode': 'PC003',
      'name': 'Peter Jones',
      'product': 'Product C',
      'qty': 20,
      'basicValue': 200.00,
      'billValue': 220.00,
      'excise': 10.00,
      'salesTax': 10.00,
      'transitIns': 4.00,
      'freight': 5.00,
      'servcTax': 2.00,
      'cessOnServcTax': 0.20,
      'totalValue': 0.00,
    },
    {
      'purchaserCode': 'PC004',
      'name': 'Mary Brown',
      'product': 'Product A',
      'qty': 5,
      'basicValue': 50.00,
      'billValue': 55.00,
      'excise': 2.50,
      'salesTax': 2.50,
      'transitIns': 1.00,
      'freight': 1.50,
      'servcTax': 0.50,
      'cessOnServcTax': 0.05,
      'totalValue': 0.00,
    },
    {
      'purchaserCode': 'PC005',
      'name': 'David Green',
      'product': 'Product B',
      'qty': 30,
      'basicValue': 300.00,
      'billValue': 330.00,
      'excise': 15.00,
      'salesTax': 15.00,
      'transitIns': 6.00,
      'freight': 7.00,
      'servcTax': 3.00,
      'cessOnServcTax': 0.30,
      'totalValue': 0.00,
    },
    {
      'purchaserCode': 'PC006',
      'name': 'Lisa White',
      'product': 'Product C',
      'qty': 25,
      'basicValue': 250.00,
      'billValue': 275.00,
      'excise': 12.50,
      'salesTax': 12.50,
      'transitIns': 5.00,
      'freight': 6.00,
      'servcTax': 2.50,
      'cessOnServcTax': 0.25,
      'totalValue': 0.00,
    },
    {
      'purchaserCode': 'PC007',
      'name': 'Chris Black',
      'product': 'Product A',
      'qty': 12,
      'basicValue': 120.00,
      'billValue': 132.00,
      'excise': 6.00,
      'salesTax': 6.00,
      'transitIns': 2.40,
      'freight': 3.60,
      'servcTax': 1.20,
      'cessOnServcTax': 0.12,
      'totalValue': 0.00,
    },
    {
      'purchaserCode': 'PC008',
      'name': 'Sarah Blue',
      'product': 'Product B',
      'qty': 18,
      'basicValue': 180.00,
      'billValue': 198.00,
      'excise': 9.00,
      'salesTax': 9.00,
      'transitIns': 3.60,
      'freight': 4.80,
      'servcTax': 1.80,
      'cessOnServcTax': 0.18,
      'totalValue': 0.00,
    },
    {
      'purchaserCode': 'PC009',
      'name': 'Mike Red',
      'product': 'Product C',
      'qty': 22,
      'basicValue': 220.00,
      'billValue': 242.00,
      'excise': 11.00,
      'salesTax': 11.00,
      'transitIns': 4.40,
      'freight': 5.50,
      'servcTax': 2.20,
      'cessOnServcTax': 0.22,
      'totalValue': 0.00,
    },
    {
      'purchaserCode': 'PC010',
      'name': 'Anna Yellow',
      'product': 'Product A',
      'qty': 8,
      'basicValue': 80.00,
      'billValue': 88.00,
      'excise': 4.00,
      'salesTax': 4.00,
      'transitIns': 1.60,
      'freight': 2.40,
      'servcTax': 0.80,
      'cessOnServcTax': 0.08,
      'totalValue': 0.00,
    },
    {
      'purchaserCode': 'PC011',
      'name': 'Tom Orange',
      'product': 'Product B',
      'qty': 28,
      'basicValue': 280.00,
      'billValue': 308.00,
      'excise': 14.00,
      'salesTax': 14.00,
      'transitIns': 5.60,
      'freight': 6.40,
      'servcTax': 2.80,
      'cessOnServcTax': 0.28,
      'totalValue': 0.00,
    },
    {
      'purchaserCode': 'PC012',
      'name': 'Lily Purple',
      'product': 'Product C',
      'qty': 17,
      'basicValue': 170.00,
      'billValue': 187.00,
      'excise': 8.50,
      'salesTax': 8.50,
      'transitIns': 3.40,
      'freight': 4.25,
      'servcTax': 1.70,
      'cessOnServcTax': 0.17,
      'totalValue': 0.00,
    },
  ];

  // Data currently displayed in the table (filtered subset of _fullSummaryData)
  List<Map<String, dynamic>> _displayedSummaryData = [];

  // Placeholder for total values - added new fields
  Map<String, dynamic> _totalData = {
    'purchaserCode': 'Total', // Label for the total row
    'name': '', // Empty for total row
    'product': '', // Empty for total row
    'qty': 0,
    'basicValue': 0.00,
    'billValue': 0.00,
    'excise': 0.00,
    'salesTax': 0.00,
    'transitIns': 0.00,
    'freight': 0.00,
    'servcTax': 0.00, // Added Service Tax total
    'cessOnServcTax': 0.00, // Added Cess on Service Tax total
    'totalValue': 0.00, // Will be calculated
  };

  // List of available row counts for the dropdown - Added 'All' represented by a large number
  final List<int> _availableRowCounts = [
    2,
    10,
    25,
    50,
    99999,
  ]; // 99999 represents 'All'

  // Currently selected row count
  int _selectedRowCount = 10; // Default to 10 rows

  // Define a primary color for consistent theming
  final Color _primaryColor = Colors.blueAccent;

  @override
  void initState() {
    super.initState();
    // Set initial dates to the current date when the screen loads
    final now = DateTime.now();
    _selectedStartDate = now;
    _selectedEndDate = now;
    _startDateController.text = DateFormat('yyyy-MM-dd').format(now);
    _endDateController.text = DateFormat('yyyy-MM-dd').format(now);

    // Initialize displayed data and calculate totals
    _filterAndCalculateTotals();

    // Add listener to search controller to filter data in real-time
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed
    _startDateController.dispose();
    _endDateController.dispose();
    _searchController.removeListener(_onSearchChanged); // Remove listener
    _searchController.dispose();
    super.dispose();
  }

  // Listener for search text changes
  void _onSearchChanged() {
    setState(() {
      _filterAndCalculateTotals(); // Filter and recalculate when search term changes
    });
  }

  // Method to filter data based on selected row count and calculate totals
  void _filterAndCalculateTotals() {
    // Apply search filter first (if any)
    List<Map<String, dynamic>> filteredBySearch =
        _fullSummaryData.where((data) {
          final searchTerm = _searchController.text.toLowerCase();
          if (searchTerm.isEmpty) {
            return true; // No search term, include all
          }
          // Check if any string value in the map contains the search term
          // Ensure values are not null before calling toString()
          return data.values.any(
            (value) =>
                value != null &&
                value.toString().toLowerCase().contains(searchTerm),
          );
        }).toList();

    // Apply row count limit to the search-filtered data
    if (_selectedRowCount == 99999) {
      // Check if 'All' is selected
      _displayedSummaryData = filteredBySearch; // Show all filtered data
    } else {
      // Use min to ensure we don't try to take more items than available
      _displayedSummaryData =
          filteredBySearch
              .take(min(_selectedRowCount, filteredBySearch.length))
              .toList();
    }

    // Reset totals
    _totalData = {
      'purchaserCode': 'Total',
      'name': '',
      'product': '',
      'qty': 0,
      'basicValue': 0.00,
      'billValue': 0.00,
      'excise': 0.00,
      'salesTax': 0.00,
      'transitIns': 0.00,
      'freight': 0.00,
      'servcTax': 0.00,
      'cessOnServcTax': 0.00,
      'totalValue': 0.00,
    };

    // Loop through displayed data to calculate totals
    for (var row in _displayedSummaryData) {
      _totalData['qty'] += row['qty'] ?? 0; // Use ?? 0 for null safety
      _totalData['basicValue'] += row['basicValue'] ?? 0.0;
      _totalData['billValue'] += row['billValue'] ?? 0.0;
      _totalData['excise'] += row['excise'] ?? 0.0;
      _totalData['salesTax'] += row['salesTax'] ?? 0.0;
      _totalData['transitIns'] += row['transitIns'] ?? 0.0;
      _totalData['freight'] += row['freight'] ?? 0.0;
      _totalData['servcTax'] += row['servcTax'] ?? 0.0;
      _totalData['cessOnServcTax'] += row['cessOnServcTax'] ?? 0.0;

      // Calculate Total Value for each row (assuming sum of relevant columns)
      // Ensure null safety during calculation
      row['totalValue'] =
          (row['billValue'] ?? 0.0) +
          (row['excise'] ?? 0.0) +
          (row['salesTax'] ?? 0.0) +
          (row['transitIns'] ?? 0.0) +
          (row['freight'] ?? 0.0) +
          (row['servcTax'] ?? 0.0) +
          (row['cessOnServcTax'] ?? 0.0);

      _totalData['totalValue'] +=
          row['totalValue']; // Add row total to overall total
    }
  }

  // --- Button Action Handlers ---

  // Handle Copy button click
  void _copyTableData() {
    // Format the displayed data as a string (e.g., tab-separated values)
    StringBuffer dataString = StringBuffer();

    // Add headers
    dataString.writeln(
      'Purchaser Code\tName\tProduct\tQty\tBasic Value\tBill Value\tExcise\tSales Tax\tTransit Ins.\tFreight\tServc.Tax\tCess on Servc Tax\tTotal Value',
    );

    // Add data rows
    for (var row in _displayedSummaryData) {
      dataString.writeln(
        '${row['purchaserCode'] ?? ''}\t${row['name'] ?? ''}\t${row['product'] ?? ''}\t${row['qty'] ?? 0}\t${(row['basicValue'] ?? 0.0).toStringAsFixed(2)}\t${(row['billValue'] ?? 0.0).toStringAsFixed(2)}\t${(row['excise'] ?? 0.0).toStringAsFixed(2)}\t${(row['salesTax'] ?? 0.0).toStringAsFixed(2)}\t${(row['transitIns'] ?? 0.0).toStringAsFixed(2)}\t${(row['freight'] ?? 0.0).toStringAsFixed(2)}\t${(row['servcTax'] ?? 0.0).toStringAsFixed(2)}\t${(row['cessOnServcTax'] ?? 0.0).toStringAsFixed(2)}\t${(row['totalValue'] ?? 0.0).toStringAsFixed(2)}',
      );
    }

    // Add total row
    dataString.writeln(
      '${_totalData['purchaserCode'] ?? ''}\t${_totalData['name'] ?? ''}\t${_totalData['product'] ?? ''}\t${_totalData['qty'] ?? 0}\t${(_totalData['basicValue'] ?? 0.0).toStringAsFixed(2)}\t${(_totalData['billValue'] ?? 0.0).toStringAsFixed(2)}\t${(_totalData['excise'] ?? 0.0).toStringAsFixed(2)}\t${(_totalData['salesTax'] ?? 0.0).toStringAsFixed(2)}\t${(_totalData['transitIns'] ?? 0.0).toStringAsFixed(2)}\t${(_totalData['freight'] ?? 0.0).toStringAsFixed(2)}\t${(_totalData['servcTax'] ?? 0.0).toStringAsFixed(2)}\t${(_totalData['cessOnServcTax'] ?? 0.0).toStringAsFixed(2)}\t${(_totalData['totalValue'] ?? 0.0).toStringAsFixed(2)}',
    );

    // Copy the string to the clipboard
    Clipboard.setData(ClipboardData(text: dataString.toString())).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Table data copied to clipboard')),
      );
    });
  }

  // Handle CSV download button click
  void _downloadCsv() {
    // TODO: Implement CSV file generation and download logic here.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CSV download functionality not yet implemented'),
      ),
    );
  }

  // Handle Excel download button click
  void _downloadExcel() {
    // TODO: Implement Excel file generation and download logic here.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Excel download functionality not yet implemented'),
      ),
    );
  }

  // Handle PDF download button click
  void _downloadPdf() {
    // TODO: Implement PDF file generation and download logic here.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF download functionality not yet implemented'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            // TODO: Implement back button functionality
            Navigator.of(context).pop(); // Example: go back using Navigator
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ), // White icon color
        ),
        title: const Text(
          'Day Summary',
          style: TextStyle(color: Colors.white), // White title color
        ),
        backgroundColor: _primaryColor, // Use the primary color
        elevation: 4.0, // Add a subtle shadow
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Increased overall padding
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Range Selection
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align items at the top
                children: [
                  Expanded(
                    // Allow start date to take available space
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Start Date'),
                        const SizedBox(height: 8),
                        _buildDateField(
                          _startDateController,
                          _pickStartDate,
                          'Select Start Date',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16), // Spacing between date fields
                  Expanded(
                    // Allow end date to take available space
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('End Date'),
                        const SizedBox(height: 8),
                        _buildDateField(
                          _endDateController,
                          _pickEndDate,
                          'Select End Date',
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24), // Increased spacing before buttons
              // Action Buttons
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly, // Distribute buttons evenly
                children: [
                  _buildActionButton(
                    icon: Icons.copy,
                    text: 'Copy',
                    color: Colors.teal,
                    onPressed: _copyTableData,
                  ), // Call copy handler, changed color
                  _buildActionButton(
                    icon: Icons.download,
                    text: 'CSV',
                    color: Colors.orange,
                    onPressed: _downloadCsv,
                  ), // Changed color
                  _buildActionButton(
                    icon: Icons.download,
                    text: 'Excel',
                    color: Colors.green,
                    onPressed: _downloadExcel,
                  ), // Changed color
                  _buildActionButton(
                    icon: Icons.download,
                    text: 'PDF',
                    color: Colors.redAccent,
                    onPressed: _downloadPdf,
                  ), // Changed color
                ],
              ),
              const SizedBox(height: 24), // Spacing after buttons
              // Search Field and Row Count Dropdown
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.end, // Align items at the bottom
                children: [
                  Expanded(
                    // Allow search field to take available space
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Search'),
                        const SizedBox(height: 8),
                        _buildSearchField(),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ), // Spacing between search and dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Rows per page'),
                      const SizedBox(height: 8),
                      _buildRowCountDropdown(),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20), // Spacing after search/dropdown row
              // Table Section
              _buildLabel('Summary Data'),
              const SizedBox(height: 10),
              _buildSummaryDataTable(), // Display the data table
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build a label
  Widget _buildLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 14, // Slightly smaller font for labels
      fontWeight: FontWeight.bold, // Bold labels
      color: Colors.black87,
    ),
  );

  // Helper method to build a date field
  Widget _buildDateField(
    TextEditingController controller,
    VoidCallback onTap,
    String hintText,
  ) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey[500],
          fontSize: 14, // Consistent font size
        ),
        suffixIcon: Icon(
          Icons.calendar_today,
          color: _primaryColor,
        ), // Use primary color for icon
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // More rounded corners
          borderSide: BorderSide.none, // No border line
        ),
        filled: true,
        fillColor: Colors.grey[200], // Light grey background for input fields
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      onTap: onTap,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a date';
        }
        return null;
        // TODO: Add more robust date validation if needed
      },
    );
  }

  // Date picker for Start Date
  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryColor, // Use primary color for date picker
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedStartDate = picked;
        _startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        // TODO: Fetch and update table data based on selected dates
        // After fetching new data into _fullSummaryData, call:
        _filterAndCalculateTotals(); // Filter and recalculate totals based on new data
      });
    }
  }

  // Date picker for End Date
  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryColor, // Use primary color for date picker
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedEndDate = picked;
        _endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        // TODO: Fetch and update table data based on selected dates
        // After fetching new data into _fullSummaryData, call:
        _filterAndCalculateTotals(); // Filter and recalculate totals based on new data
      });
    }
  }

  // Helper method to build an action button with icon
  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      // Use Expanded to make buttons share space equally
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4.0,
        ), // Add horizontal padding between buttons
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color, // Use the passed-in color
            foregroundColor: Colors.white, // Button text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Rounded corners
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 12,
            ), // Vertical padding
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center, // Center content in the row
            children: [
              Icon(icon, size: 18), // Add icon
              const SizedBox(width: 8), // Spacing between icon and text
              Text(
                text,
                style: const TextStyle(fontSize: 12),
              ), // Slightly smaller text for buttons
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build the search field
  Widget _buildSearchField() {
    return TextFormField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Enter search term',
        hintStyle: TextStyle(
          color: Colors.grey[500],
          fontSize: 14, // Consistent font size
        ),
        prefixIcon: Icon(
          Icons.search,
          color: Colors.grey[600],
        ), // Search icon color
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // More rounded corners
          borderSide: BorderSide.none, // No border line
        ),
        filled: true,
        fillColor: Colors.grey[200], // Light grey background
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      // onChanged listener is now replaced by the addListener in initState
    );
  }

  // Helper method to build the row count dropdown
  Widget _buildRowCountDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ), // Adjust padding
      decoration: BoxDecoration(
        color: Colors.grey[200], // Light grey background
        borderRadius: BorderRadius.circular(8), // More rounded corners
        border: Border.all(color: Colors.grey[300]!), // Add a subtle border
      ),
      child: DropdownButtonHideUnderline(
        // Hide the default underline
        child: DropdownButton<int>(
          value: _selectedRowCount,
          icon: Icon(
            Icons.arrow_drop_down,
            color: _primaryColor,
          ), // Dropdown icon color
          elevation: 16,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
          ), // Consistent font size
          onChanged: (int? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedRowCount = newValue;
                _filterAndCalculateTotals(); // Filter and recalculate when row count changes
              });
            }
          },
          items:
              _availableRowCounts.map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  // Display 'All' for the large number, otherwise display the number
                  child: Text(value == 99999 ? 'All' : value.toString()),
                );
              }).toList(),
        ),
      ),
    );
  }

  // Method to build the data table
  Widget _buildSummaryDataTable() {
    // Combine displayed summary data and total data for the table
    final List<Map<String, dynamic>> tableData = [
      ..._displayedSummaryData,
      _totalData,
    ];

    return Container(
      // Wrap table in Container for decoration
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          8,
        ), // Rounded corners for the table container
        boxShadow: [
          // Add a subtle shadow
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        // Clip content to the rounded corners
        borderRadius: BorderRadius.circular(8),
        child: SingleChildScrollView(
          // Keep SingleChildScrollView for potential overflow
          scrollDirection: Axis.horizontal, // Keep horizontal scrolling
          child: DataTable(
            columnSpacing: 12.0, // Adjusted spacing between columns
            dataRowHeight: 48.0, // Increased row height for better readability
            headingRowColor: WidgetStateColor.resolveWith(
              (states) => _primaryColor,
            ), // Header background color
            headingTextStyle: const TextStyle(
              // Header text style
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12.0, // Slightly reduced font size for headers
            ),
            dataTextStyle: const TextStyle(
              // Data row text style
              color: Colors.black87,
              fontSize: 13.0, // Slightly larger font size for data
            ),
            dividerThickness: 1.0, // Add horizontal lines between rows
            columns: const <DataColumn>[
              DataColumn(label: Text('Purchaser Code')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Product')),
              DataColumn(label: Text('Qty'), numeric: true), // Numeric column
              DataColumn(label: Text('Basic Value'), numeric: true),
              DataColumn(label: Text('Bill Value'), numeric: true),
              DataColumn(label: Text('Excise'), numeric: true),
              DataColumn(label: Text('Sales Tax'), numeric: true),
              DataColumn(label: Text('Transit Ins.'), numeric: true),
              DataColumn(label: Text('Freight'), numeric: true),
              DataColumn(
                label: Text('Servc.Tax'),
                numeric: true,
              ), // Added Service Tax column
              DataColumn(
                label: Text('Cess on Servc Tax'),
                numeric: true,
              ), // Added Cess on Service Tax column
              DataColumn(
                label: Text('Total Value'),
                numeric: true,
              ), // Added Total Value column
            ],
            rows:
                tableData.map<DataRow>((rowData) {
                  // Check if it's the total row
                  final isTotalRow = rowData['purchaserCode'] == 'Total';
                  return DataRow(
                    cells: <DataCell>[
                      DataCell(
                        Text(rowData['purchaserCode']?.toString() ?? ''),
                      ), // Handle potential null
                      DataCell(Text(rowData['name']?.toString() ?? '')),
                      DataCell(Text(rowData['product']?.toString() ?? '')),
                      DataCell(Text(rowData['qty']?.toString() ?? '0')),
                      DataCell(
                        Text((rowData['basicValue'] ?? 0.0).toStringAsFixed(2)),
                      ), // Format to 2 decimal places
                      DataCell(
                        Text((rowData['billValue'] ?? 0.0).toStringAsFixed(2)),
                      ),
                      DataCell(
                        Text((rowData['excise'] ?? 0.0).toStringAsFixed(2)),
                      ),
                      DataCell(
                        Text((rowData['salesTax'] ?? 0.0).toStringAsFixed(2)),
                      ),
                      DataCell(
                        Text((rowData['transitIns'] ?? 0.0).toStringAsFixed(2)),
                      ),
                      DataCell(
                        Text((rowData['freight'] ?? 0.0).toStringAsFixed(2)),
                      ),
                      DataCell(
                        Text((rowData['servcTax'] ?? 0.0).toStringAsFixed(2)),
                      ), // Display Service Tax
                      DataCell(
                        Text(
                          (rowData['cessOnServcTax'] ?? 0.0).toStringAsFixed(2),
                        ),
                      ), // Display Cess on Service Tax
                      DataCell(
                        Text((rowData['totalValue'] ?? 0.0).toStringAsFixed(2)),
                      ), // Display Total Value
                    ],
                    // Apply different color to the total row
                    color: WidgetStateProperty.resolveWith<Color?>((
                      Set<WidgetState> states,
                    ) {
                      if (isTotalRow) {
                        return Colors
                            .blue[50]; // Very light blue background for total row
                      }
                      // Apply alternate row color for data rows
                      final index = _displayedSummaryData.indexOf(rowData);
                      if (index != -1 && index % 2 == 0) {
                        return Colors.grey[100]; // Light grey for even rows
                      }
                      return null; // Use default background color for odd rows
                    }),

                    // Make total row bold
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}
