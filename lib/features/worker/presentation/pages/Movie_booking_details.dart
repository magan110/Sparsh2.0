import 'package:flutter/material.dart';

import 'Worker_Home_Screen.dart';
import 'package:learning2/core/constants/fonts.dart';

class MovieBookingDetails extends StatefulWidget {
  const MovieBookingDetails({super.key});

  @override
  State<MovieBookingDetails> createState() => _MovieBookingDetailsState();
}

class _MovieBookingDetailsState extends State<MovieBookingDetails> {
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String _selectedRowsOption = 'Show all';
  String? _selectedMovieShowTime;

  final List<String> _rowsOptions = [
    'Show all',
    '2 rows',
    '10 rows',
    '25 rows',
    '50 rows',
  ];

  final List<String> _movieShowTimes = [
    '10:00 AM - Movie A',
    '02:00 PM - Movie B',
    '06:00 PM - Movie C',
    '09:00 PM - Movie D',
  ];

  final List<String> headers = [
    'Booking No',
    'Show Booking',
    'Code',
    'Name',
    'Pass (Personal+Guest)',
    'Mobile No',
    'Entry Pass',
  ];

  final List<Map<String, String>> _tableData = [
    {
      'Booking No': 'B1001',
      'Show Booking': '10:00 AM - Movie A',
      'Code': 'ABCDE',
      'Name': 'John Doe',
      'Pass (Personal+Guest)': '2+1',
      'Mobile No': '1234567890',
      'Entry Pass': 'EP001',
    },
    {
      'Booking No': 'B1002',
      'Show Booking': '02:00 PM - Movie B',
      'Code': 'FGHIJ',
      'Name': 'Jane Smith',
      'Pass (Personal+Guest)': '1+0',
      'Mobile No': '0987654321',
      'Entry Pass': 'EP002',
    },
    {
      'Booking No': 'B1003',
      'Show Booking': '06:00 PM - Movie C',
      'Code': 'KLMNO',
      'Name': 'Peter Jones',
      'Pass (Personal+Guest)': '3+2',
      'Mobile No': '1122334455',
      'Entry Pass': 'EP003',
    },
    {
      'Booking No': 'B1004',
      'Show Booking': '10:00 AM - Movie A',
      'Code': 'PQRST',
      'Name': 'Alice Brown',
      'Pass (Personal+Guest)': '1+1',
      'Mobile No': '5544332211',
      'Entry Pass': 'EP004',
    },
    {
      'Booking No': 'B1005',
      'Show Booking': '02:00 PM - Movie B',
      'Code': 'UVWXY',
      'Name': 'Bob White',
      'Pass (Personal+Guest)': '2+0',
      'Mobile No': '9988776655',
      'Entry Pass': 'EP005',
    },
    {
      'Booking No': 'B1006',
      'Show Booking': '10:00 AM - Movie A',
      'Code': 'ZXCVB',
      'Name': 'Charlie Green',
      'Pass (Personal+Guest)': '1+0',
      'Mobile No': '1112223333',
      'Entry Pass': 'EP006',
    },
    {
      'Booking No': 'B1007',
      'Show Booking': '06:00 PM - Movie C',
      'Code': 'ASDFG',
      'Name': 'Diana Prince',
      'Pass (Personal+Guest)': '2+2',
      'Mobile No': '4445556666',
      'Entry Pass': 'EP007',
    },
    {
      'Booking No': 'B1008',
      'Show Booking': '09:00 PM - Movie D',
      'Code': 'QWERT',
      'Name': 'Bruce Wayne',
      'Pass (Personal+Guest)': '1+0',
      'Mobile No': '7778889999',
      'Entry Pass': 'EP008',
    },
    {
      'Booking No': 'B1009',
      'Show Booking': '10:00 AM - Movie A',
      'Code': 'YUBNM',
      'Name': 'Clark Kent',
      'Pass (Personal+Guest)': '3+0',
      'Mobile No': '0001112222',
      'Entry Pass': 'EP009',
    },
    {
      'Booking No': 'B1010',
      'Show Booking': '02:00 PM - Movie B',
      'Code': 'PLKJH',
      'Name': 'Lois Lane',
      'Pass (Personal+Guest)': '1+1',
      'Mobile No': '3334445555',
      'Entry Pass': 'EP010',
    },
    {
      'Booking No': 'B1011',
      'Show Booking': '06:00 PM - Movie C',
      'Code': 'MNBVC',
      'Name': 'Barry Allen',
      'Pass (Personal+Guest)': '2+1',
      'Mobile No': '6667778888',
      'Entry Pass': 'EP011',
    },
    {
      'Booking No': 'B1012',
      'Show Booking': '09:00 PM - Movie D',
      'Code': 'ZXCVB',
      'Name': 'Hal Jordan',
      'Pass (Personal+Guest)': '1+0',
      'Mobile No': '9990001111',
      'Entry Pass': 'EP012',
    },
  ];

  List<Map<String, String>> _filteredTableData = [];

  // Dummy data to display when no actual bookings are found after filtering
  final List<Map<String, String>> _noResultsDummyData = [
    {
      'Booking No': '---',
      'Show Booking': 'No bookings found',
      'Code': '---',
      'Name': '---',
      'Pass (Personal+Guest)': '---',
      'Mobile No': '---',
      'Entry Pass': '---',
    }
  ];

  @override
  void initState() {
    super.initState();
    _filterTableData(); // Initialize with filtered data (which will include dummy if _tableData is empty)
    _searchController.addListener(_filterTableData); // Listen for search input changes
  }

  @override
  void dispose() {
    _passController.dispose();
    _searchController.removeListener(_filterTableData); // Remove listener
    _searchController.dispose();
    super.dispose();
  }

  // Method to filter table data based on search query and selected show time
  void _filterTableData() {
    List<Map<String, String>> tempFilteredData = _tableData;

    // Filter by selected movie show time
    if (_selectedMovieShowTime != null && _selectedMovieShowTime != 'Show all') {
      tempFilteredData = tempFilteredData.where((data) {
        return data['Show Booking'] == _selectedMovieShowTime;
      }).toList();
    }

    // Filter by search query
    if (_searchController.text.isNotEmpty) {
      final String query = _searchController.text.toLowerCase();
      tempFilteredData = tempFilteredData.where((data) {
        // Check if any value in the row contains the search query
        return data.values.any((value) => value.toLowerCase().contains(query));
      }).toList();
    }

    // Apply 'Rows per page' limit
    int rowsLimit = 0;
    if (_selectedRowsOption == 'Show all') {
      rowsLimit = tempFilteredData.length; // Show all available rows
    } else {
      rowsLimit = int.tryParse(_selectedRowsOption.split(' ')[0]) ?? tempFilteredData.length;
    }

    List<Map<String, String>> finalDataToDisplay = tempFilteredData.take(rowsLimit).toList();

    // If after all filtering and limiting, the list is empty, add dummy data
    if (finalDataToDisplay.isEmpty) {
      finalDataToDisplay = _noResultsDummyData;
    }

    setState(() {
      _filteredTableData = finalDataToDisplay;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Movie Booking Details'),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WorkerHomeScreen()),
              );
            },
            icon: const Icon(Icons.arrow_back_ios_new),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle(
                "Entry Pass Detail",
                Icons.confirmation_num_outlined,
                theme.primaryColor,
              ),
              const SizedBox(height: 16),
              _buildStyledTextField(
                controller: _passController,
                hintText: "Entry Pass No",
                keyboardType: TextInputType.number, // Changed to number for entry pass
                cardColor: theme.cardColor,
                textColor: theme.textTheme.bodyLarge!.color!,
                hintColor: theme.inputDecorationTheme.hintStyle!.color!,
              ),
              const SizedBox(height: 32),
              _buildSectionTitle(
                "Select Show Time & Movie",
                Icons.theaters_outlined,
                theme.primaryColor,
              ),
              const SizedBox(height: 16),
              _buildStyledDropdown(
                hintText: "Select Show Time & Movie",
                items: _movieShowTimes,
                selectedValue: _selectedMovieShowTime,
                onChanged: (value) {
                  setState(() {
                    _selectedMovieShowTime = value;
                    _filterTableData(); // Re-filter when show time changes
                  });
                },
                cardColor: theme.cardColor,
                textColor: theme.textTheme.bodyLarge!.color!,
                hintColor: theme.inputDecorationTheme.hintStyle!.color!,
              ),
              const SizedBox(height: 32),
              _buildStyledDropdown(
                hintText: "Rows per page",
                items: _rowsOptions,
                selectedValue: _selectedRowsOption,
                onChanged: (newValue) {
                  setState(() {
                    _selectedRowsOption = newValue!;
                    _filterTableData(); // Re-filter when rows option changes
                  });
                },
                cardColor: theme.cardColor,
                textColor: theme.textTheme.bodyLarge!.color!,
                hintColor: theme.inputDecorationTheme.hintStyle!.color!,
              ),
              const SizedBox(height: 24),
              _buildStyledTextField(
                controller: _searchController,
                hintText: "Search bookings...",
                cardColor: theme.cardColor,
                textColor: theme.textTheme.bodyLarge!.color!,
                hintColor: theme.inputDecorationTheme.hintStyle!.color!,
                suffixIcon: Icons.search,
              ),
              const SizedBox(height: 24),
              // Always render the SingleChildScrollView and DataTable
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                            theme.primaryColor.withOpacity(0.2)),
                        headingTextStyle: theme.textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                        dataRowColor:
                        WidgetStateProperty.resolveWith<Color?>(
                                (Set<WidgetState> states) {
                              if (states.contains(WidgetState.selected)) {
                                return theme.primaryColor.withOpacity(0.1);
                              }
                              return Colors.grey[50];
                            }),
                        dataTextStyle: theme.textTheme.bodyMedium!.copyWith(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                        border: TableBorder(
                          horizontalInside:
                          BorderSide(color: Colors.grey.shade300, width: 1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        columnSpacing: 20,
                        horizontalMargin: 16,
                        dataRowMinHeight: 50,
                        dataRowMaxHeight: 60,
                        columns: headers
                            .map(
                              (header) => DataColumn(
                            label: Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(header, textAlign: TextAlign.center),
                            ),
                          ),
                        )
                            .toList(),
                        rows: _filteredTableData.map(
                              (data) {
                            return DataRow(
                              cells: headers
                                  .map(
                                    (header) => DataCell(
                                  Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 8),
                                    child: Text(
                                      data[header] ?? 'N/A',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              )
                                  .toList(),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildStyledDropdown({
  required String hintText,
  required List<String> items,
  required String? selectedValue,
  required ValueChanged<String?> onChanged,
  required Color cardColor,
  required Color textColor,
  required Color hintColor,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24.0),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          hint: Text(
            hintText,
            style: TextStyle(color: hintColor),
          ),
          icon: Icon(Icons.keyboard_arrow_down, color: textColor),
          isExpanded: true,
          style: TextStyle(color: textColor),
          dropdownColor: cardColor,
          items: items
              .map(
                (item) => DropdownMenuItem(
              value: item,
              child: Text(item),
            ),
          )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    ),
  );
}

Widget _buildSectionTitle(String title, IconData icon, Color iconColor) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24.0),
    child: Row(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(color: Color(0xFF2196F3)),
        ),
      ],
    ),
  );
}

Widget _buildStyledTextField({
  required TextEditingController controller,
  required String hintText,
  TextInputType keyboardType = TextInputType.text,
  required Color cardColor,
  required Color textColor,
  required Color hintColor,
  IconData? suffixIcon,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24.0),
    child: Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          hintText: hintText,
          hintStyle: TextStyle(color: hintColor),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          suffixIcon:
          suffixIcon != null ? Icon(suffixIcon, color: hintColor) : null,
        ),
      ),
    ),
  );
}
