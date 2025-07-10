import 'package:flutter/material.dart';

// --- Reusable Widgets (Moved to top for clarity) ---

// Custom Text Widget
class TextModel {
  Widget buildText(BuildContext context, String text) {
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1.0)),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14, // Consistent font size
          fontWeight: FontWeight.w500, // Made labels medium weight
          color: Colors.black87, // Slightly darker text for better contrast
        ),
      ),
    );
  }
}

// Date Picker Text Field
class DatePickerTextField extends StatefulWidget {
  final TextEditingController? controller; // Made controller optional

  const DatePickerTextField({super.key, this.controller});

  @override
  _DatePickerTextFieldState createState() => _DatePickerTextFieldState();
}

class _DatePickerTextFieldState extends State<DatePickerTextField> {
  late TextEditingController _controller; // Use a non-nullable controller

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
            TextEditingController(); // Initialize with provided or new
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose(); // Dispose only if we created it internally
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // Use InkWell for better visual feedback
      onTap: () async {
        DateTime? selectedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (context, child) {
            // Theming the date picker
            return Theme(
              data: ThemeData.light().copyWith(
                // Use .light() or .dark()
                primaryColor: Colors.blueAccent, // Consistent primary color
                colorScheme: const ColorScheme.light(
                  primary: Colors.blueAccent,
                ),
                buttonTheme: const ButtonThemeData(
                  textTheme: ButtonTextTheme.primary,
                ),
              ),
              child: child!,
            );
          },
        );
        _controller.text =
        "${selectedDate?.toLocal()}".split(' ')[0]; // Format date
      },
      child: IgnorePointer(
        // Prevents direct text editing, keeps visual
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Select Date',
            suffixIcon: const Icon(
              Icons.calendar_today,
              color: Colors.grey,
            ), // Consistent icon color
            border: OutlineInputBorder(
              // Added outline border for better appearance
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ), // Adjusted padding
            isDense: true, // Make the input field more compact.
          ),
          readOnly: true, // Ensure the user can't type in the field
          style: const TextStyle(fontSize: 16), // Consistent font size
        ),
      ),
    );
  }
}

// Search Field Widget
class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged; // Added onChanged

  const SearchField({super.key, required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged, // Use the provided onChanged callback
      decoration: InputDecoration(
        hintText: 'Search...',
        prefixIcon: const Icon(
          Icons.search,
          color: Colors.grey,
        ), // Consistent icon color
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        isDense: true,
      ),
      style: const TextStyle(fontSize: 16), // Consistent font size
    );
  }
}

// Searchable Dropdown Widget
class SearchableDropdownExample extends StatefulWidget {
  final List<String> items;
  final ValueChanged<String?>? onChanged; // Added onChanged
  final String? hintText;

  const SearchableDropdownExample({
    super.key,
    required this.items,
    this.onChanged,
    this.hintText = "Select Item",
  });

  @override
  _SearchableDropdownExampleState createState() =>
      _SearchableDropdownExampleState();
}

class _SearchableDropdownExampleState extends State<SearchableDropdownExample> {
  String? _selectedItem;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _selectedItem,
      onChanged: (newValue) {
        setState(() {
          _selectedItem = newValue;
        });
        widget.onChanged?.call(newValue); // Notify parent widget
      },
      items:
      widget.items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ), // Consistent font size
        );
      }).toList(),
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        isDense: true,
      ),

      // Use a builder to customize the dropdown.
    );
  }
}

// --- Main Widget ---

class DayWiseSummary extends StatefulWidget {
  const DayWiseSummary({super.key});

  @override
  State<DayWiseSummary> createState() => _DayWiseSummaryState();
}

class _DayWiseSummaryState extends State<DayWiseSummary> {
  final textModel = TextModel();
  final List<String> items = ['all', 'OlA255-SELF - AMBIKA PIPE DISTRIBUTORS'];
  final List<String> rows = ['all', '2', '10', '25', '50'];

  final TextEditingController searchController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  String? _selectedRowsPerPage; // Changed to String? to handle 'all'
  String? _selectedSelfCode;
  List<Map<String, dynamic>> _displayedData = [];

  // Dummy data for the table
  final List<Map<String, dynamic>> dummyData = [
    {
      'Product': 'Product A',
      'Invoice No': 'INV001',
      'Date': '2023-01-01',
      'Qty': 10,
      'Basic Value': 100.00,
      'Bill Value': 118.00,
      'Excise': 5.00,
      'Sales Tax': 13.00,
      'Transit Ins.': 2.00,
      'Freight': 3.00,
      'Servc.Tax': 0.00,
      'Cess on Servc Tax': 0.00,
      'Total Value': 141.00,
    },
    {
      'Product': 'Product B',
      'Invoice No': 'INV002',
      'Date': '2023-01-02',
      'Qty': 5,
      'Basic Value': 250.00,
      'Bill Value': 295.00,
      'Excise': 10.00,
      'Sales Tax': 35.00,
      'Transit Ins.': 5.00,
      'Freight': 5.00,
      'Servc.Tax': 0.00,
      'Cess on Servc Tax': 0.00,
      'Total Value': 350.00,
    },
    {
      'Product': 'Product C',
      'Invoice No': 'INV003',
      'Date': '2023-01-03',
      'Qty': 20,
      'Basic Value': 50.00,
      'Bill Value': 59.00,
      'Excise': 2.50,
      'Sales Tax': 6.50,
      'Transit Ins.': 1.00,
      'Freight': 1.50,
      'Servc.Tax': 0.00,
      'Cess on Servc Tax': 0.00,
      'Total Value': 70.00,
    },
    {
      'Product': 'Product D',
      'Invoice No': 'INV004',
      'Date': '2023-01-04',
      'Qty': 15,
      'Basic Value': 150.00,
      'Bill Value': 177.00,
      'Excise': 7.50,
      'Sales Tax': 19.50,
      'Transit Ins.': 3.00,
      'Freight': 4.50,
      'Servc.Tax': 0.00,
      'Cess on Servc Tax': 0.00,
      'Total Value': 211.50,
    },
    {
      'Product': 'Product E',
      'Invoice No': 'INV005',
      'Date': '2023-01-05',
      'Qty': 8,
      'Basic Value': 200.00,
      'Bill Value': 236.00,
      'Excise': 10.00,
      'Sales Tax': 26.00,
      'Transit Ins.': 4.00,
      'Freight': 6.00,
      'Servc.Tax': 0.00,
      'Cess on Servc Tax': 0.00,
      'Total Value': 282.00,
    },
    {
      'Product': 'Product F',
      'Invoice No': 'INV006',
      'Date': '2023-01-06',
      'Qty': 12,
      'Basic Value': 120.00,
      'Bill Value': 141.60,
      'Excise': 6.00,
      'Sales Tax': 15.60,
      'Transit Ins.': 2.40,
      'Freight': 3.60,
      'Servc.Tax': 0.00,
      'Cess on Servc Tax': 0.00,
      'Total Value': 169.20,
    },
  ];

  @override
  void initState() {
    super.initState();
    _displayedData = dummyData;
  }

  @override
  void dispose() {
    searchController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter data based on selected rows per page
    List<Map<String, dynamic>> displayedData = [];
    if (_selectedRowsPerPage == 'all') {
      displayedData = _displayedData;
    } else {
      int rowsPerPage = int.tryParse(_selectedRowsPerPage ?? '10') ?? 10;
      displayedData = _displayedData.take(rowsPerPage).toList();
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            backgroundColor: Colors.lightBlueAccent,
            title: const Text(
              'Day Wise Summary',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            elevation: 4.0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form Section
                  Card(
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          textModel.buildText(context, 'Start Date'),
                          const SizedBox(height: 8),
                          DatePickerTextField(controller: _startDateController),
                          const SizedBox(height: 16),
                          textModel.buildText(context, 'End Date'),
                          const SizedBox(height: 8),
                          DatePickerTextField(controller: _endDateController),
                          const SizedBox(height: 16),
                          textModel.buildText(
                            context,
                            'Self / Guarantee Code / Merge Code *',
                          ),
                          const SizedBox(height: 8),
                          SearchableDropdownExample(
                            items: items,
                            onChanged: (value) {
                              setState(() {
                                _selectedSelfCode = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        print("Go button pressed");
                        print("Start Date: ${_startDateController.text}");
                        print("End Date: ${_endDateController.text}");
                        print("Selected Code: $_selectedSelfCode");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 3.0,
                      ),
                      child: const Text("Go"),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              ElevatedButton.icon(
                                onPressed: () {
                                  print('Copy button pressed');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[600],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  textStyle: const TextStyle(fontSize: 14),
                                  elevation: 2.0,
                                ),
                                icon: const Icon(Icons.copy, size: 18),
                                label: const Text('Copy'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  print('CSV button pressed');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange[700],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  textStyle: const TextStyle(fontSize: 14),
                                  elevation: 2.0,
                                ),
                                icon: const Icon(Icons.description, size: 18),
                                label: const Text('CSV'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  print('Excel button pressed');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple[600],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  textStyle: const TextStyle(fontSize: 14),
                                  elevation: 2.0,
                                ),
                                icon: const Icon(Icons.table_chart, size: 18),
                                label: const Text('Excel'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  print('PDF button pressed');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[600],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  textStyle: const TextStyle(fontSize: 14),
                                  elevation: 2.0,
                                ),
                                icon: const Icon(
                                  Icons.picture_as_pdf,
                                  size: 18,
                                ),
                                label: const Text('PDF'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: SearchableDropdownExample(
                                  items: rows,
                                  hintText: "Rows",
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedRowsPerPage = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: SearchField(
                                controller: searchController,
                                onChanged: (value) {
                                  setState(() {
                                    // Filter the displayed data based on the search term
                                    if (value.isEmpty) {
                                      _displayedData = dummyData;
                                    } else {
                                      _displayedData =
                                          dummyData
                                              .where(
                                                (item) => item['Product']
                                                .toString()
                                                .toLowerCase()
                                                .contains(
                                              value.toLowerCase(),
                                            ),
                                          )
                                              .toList();
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateColor.resolveWith(
                            (states) => Colors.lightBlueAccent.withOpacity(0.2),
                      ),
                      dataRowColor: WidgetStateColor.resolveWith(
                            (states) => Colors.grey.withOpacity(0.05),
                      ),
                      columnSpacing: 20.0,
                      horizontalMargin: 10.0,
                      columns: const <DataColumn>[
                        DataColumn(
                          label: Text(
                            'Product',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Invoice No',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Date',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Qty',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Basic Value',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Bill Value',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Excise',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Sales Tax',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Transit Ins.',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Freight',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Servc.Tax',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Cess on Servc Tax',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Total Value',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      rows:
                      displayedData.map<DataRow>((data) {
                        double totalValue =
                            (data['Bill Value'] ?? 0) +
                                (data['Excise'] ?? 0) +
                                (data['Sales Tax'] ?? 0) +
                                (data['Transit Ins.'] ?? 0) +
                                (data['Freight'] ?? 0) +
                                (data['Servc.Tax'] ?? 0) +
                                (data['Cess on Servc Tax'] ?? 0);
                        return DataRow(
                          cells: <DataCell>[
                            DataCell(Text(data['Product'].toString())),
                            DataCell(Text(data['Invoice No'].toString())),
                            DataCell(Text(data['Date'].toString())),
                            DataCell(Text(data['Qty'].toString())),
                            DataCell(
                              Text(
                                (data['Basic Value'] ?? 0.0)
                                    .toStringAsFixed(2),
                              ),
                            ),
                            DataCell(
                              Text(
                                (data['Bill Value'] ?? 0.0).toStringAsFixed(
                                  2,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                (data['Excise'] ?? 0.0).toStringAsFixed(2),
                              ),
                            ),
                            DataCell(
                              Text(
                                (data['Sales Tax'] ?? 0.0).toStringAsFixed(
                                  2,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                (data['Transit Ins.'] ?? 0.0)
                                    .toStringAsFixed(2),
                              ),
                            ),
                            DataCell(
                              Text(
                                (data['Freight'] ?? 0.0).toStringAsFixed(2),
                              ),
                            ),
                            DataCell(
                              Text(
                                (data['Servc.Tax'] ?? 0.0).toStringAsFixed(
                                  2,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                (data['Cess on Servc Tax'] ?? 0.0)
                                    .toStringAsFixed(2),
                              ),
                            ),
                            DataCell(Text(totalValue.toStringAsFixed(2))),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}