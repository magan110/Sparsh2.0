import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:responsive_sizer/responsive_sizer.dart'; // Removed problematic import

class SalesGrowth extends StatefulWidget {
  const SalesGrowth({super.key});

  @override
  State<SalesGrowth> createState() => _SalesGrowthState();
}

class _SalesGrowthState extends State<SalesGrowth> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // Sample dynamic data for the table
  final List<Map<String, dynamic>> _salesData = [
    {
      'Product': 'White Cement',
      'CY YTD': 2294.500,
      'LY YTD': 2326.600,
      'CY MTD': 0.000,
      'LY MTD': 2296.750,
      'Growth YTD': -0.10,
      'Growth MTD': -100.00,
    },
    {
      'Product': 'Wall Care Putty',
      'CY YTD': 4141.780,
      'LY YTD': 4174.140,
      'CY MTD': 0.000,
      'LY MTD': 4152.520,
      'Growth YTD': -0.26,
      'Growth MTD': -100.00,
    },
    {
      'Product': 'VAP',
      'CY YTD': 63.130,
      'LY YTD': 63.130,
      'CY MTD': 0.000,
      'LY MTD': 63.130,
      'Growth YTD': 0.00,
      'Growth MTD': -100.00,
    },
  ];

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary:
                  Colors
                      .indigo, // Use a more vibrant primary color.  Consider using Theme.of(context).primaryColor
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Colors.indigo,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      controller.text = formattedDate;
    }
  }

  Widget _buildDateField(
    BuildContext context,
    String labelText,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.datetime,
      readOnly: true,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: 'Select date',
        labelStyle: TextStyle(color: Colors.grey[700]),
        prefixIcon: const Icon(
          Icons.calendar_today,
          color: Colors.indigo,
        ), // Consistent icon color
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0), // Slightly more rounded
          borderSide: BorderSide(color: Colors.grey.shade300), // Lighter border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(
            color: Colors.indigo,
            width: 2.0,
          ), // Focused border color
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ), // Consistent enabled border
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: 12.0,
        ), // Padding
      ),
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        _selectDate(context, controller);
      },
    );
  }

  Widget _buildLabelText(BuildContext context, String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18, // Use responsive font size
        fontWeight: FontWeight.w600,
        color: Colors.grey,
      ),
    );
  }

  // Function to build the table
  Widget _buildSalesDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            12.0,
          ), // Rounded corners for the table
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200, // Light shadow
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2), // Shadow offset
            ),
          ],
          color: Colors.white, //ensure table has white background.
        ),
        child: DataTable(
          border: TableBorder.all(
            color: Colors.grey.shade300,
          ), // ADDED THIS LINE
          columns: const [
            DataColumn(
              label: Text(
                'Product',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.indigo,
                ),
              ),
            ), //Styled Header
            DataColumn(
              label: Text(
                'CY YTD',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.indigo,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'LY YTD',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.indigo,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'CY MTD',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.indigo,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'LY MTD',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.indigo,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Growth YTD',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.indigo,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Growth MTD',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.indigo,
                ),
              ),
            ),
          ],
          rows:
              _salesData.map((data) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        data['Product'].toString(),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    DataCell(
                      Text(
                        data['CY YTD'].toString(),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    DataCell(
                      Text(
                        data['LY YTD'].toString(),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    DataCell(
                      Text(
                        data['CY MTD'].toString(),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    DataCell(
                      Text(
                        data['LY MTD'].toString(),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    DataCell(
                      Text(
                        data['Growth YTD'].toString(),
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              data['Growth YTD'] < 0
                                  ? Colors.red
                                  : Colors.green,
                        ), // Color code growth (Good Improvement)
                      ),
                    ),
                    DataCell(
                      Text(
                        data['Growth MTD'].toString(),
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              data['Growth MTD'] < 0
                                  ? Colors.red
                                  : Colors.green,
                        ), // Color code growth (Good Improvement)
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //use ResponsiveSizer here
    return Scaffold(
      backgroundColor: Colors.grey[50], // Very light background
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabelText(context, 'Start Date'),
            const SizedBox(height: 10),
            _buildDateField(context, 'Start Date', _startDateController),
            const SizedBox(height: 20),
            _buildLabelText(context, 'End Date'),
            const SizedBox(height: 10),
            _buildDateField(context, 'End Date', _endDateController),
            const SizedBox(height: 20),
            _buildLabelText(context, 'Sales Growth Data'),
            const SizedBox(height: 10),
            _buildSalesDataTable(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
