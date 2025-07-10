import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:learning2/features/dashboard/presentation/pages/home_screen.dart'; // Import for date formatting

class AccountStatement extends StatefulWidget {
  const AccountStatement({super.key});

  @override
  State<AccountStatement> createState() => _AccountStatementState();
}

class _AccountStatementState extends State<AccountStatement> {
  // Controllers for date fields
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // Selected values for dropdowns
  String? selectedRole;
  final List<String> roles = ['Select', 'Purchaser', 'Retailer'];

  String? selectedArea;
  final List<String> areas = [
    'Select',
    'pali',
    'jaipur', // Added another area for demonstration
    'jodhpur',
    'udaipur',
  ];

  // Controller for the Code text field
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    // Dispose of all controllers when the widget is disposed
    _startDateController.dispose();
    _endDateController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  // Function to show the date picker and update the corresponding text field
  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Initial date is today's date
      firstDate: DateTime(2000), // Earliest possible date
      lastDate: DateTime(2101), // Latest possible date
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue, // Header background color
              onPrimary: Colors.white, // Header text color
              surface: Colors.white, // Calendar background color
              onSurface: Colors.black, // Calendar text color
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Colors.white,
            ), // Dialog background color
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      // Format the date before setting it to the text field
      final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      controller.text = formattedDate;
    }
  }

  // Helper function to build a styled text field for dates
  Widget _buildDateField(
    BuildContext context,
    String labelText,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.datetime,
      readOnly:
          true, // Make the text field read-only to force date picker usage
      decoration: InputDecoration(
        labelText: labelText,
        hintText: 'Select date',
        labelStyle: TextStyle(color: Colors.blueGrey[700]),
        prefixIcon: const Icon(
          Icons.calendar_today,
          color: Colors.blue,
        ), // Calendar icon
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.blue, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        filled: true,
        fillColor: Colors.grey[50], // Light grey background
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: 10.0,
        ),
      ),
      onTap: () {
        // Remove focus from the TextField and open the date picker
        FocusScope.of(context).requestFocus(FocusNode());
        _selectDate(context, controller);
      },
    );
  }

  // Helper function to build a styled text widget for labels
  Widget _buildLabelText(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600, // Slightly less bold than before
        color: Colors.blueGrey[800], // Darker text color
      ),
    );
  }

  // Helper function to build a styled DropdownSearch widget
  Widget _buildDropdownField({
    required String labelText,
    required List<String> items,
    required String? selectedItem,
    required ValueChanged<String?> onChanged,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabelText(context, labelText),
        const SizedBox(height: 8), // Reduced spacing
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 0,
          ), // Adjusted padding
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(10), // Rounded corners
            color: Colors.grey[50], // Light grey background
          ),
          child: DropdownSearch<String>(
            popupProps: PopupProps.menu(
              showSearchBox: true, // Search box enabled
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: "Search...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 10.0,
                  ),
                ),
              ),
              menuProps: MenuProps(borderRadius: BorderRadius.circular(10.0)),
            ),
            items: items,
            selectedItem: selectedItem,
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.blueGrey[400]),
                border: InputBorder.none, // No border on the dropdown itself
                contentPadding: EdgeInsets.zero, // Remove default padding
              ),
            ),
            onChanged: onChanged,
            dropdownButtonProps: DropdownButtonProps(
              icon: Icon(Icons.arrow_drop_down, color: Colors.blueGrey[600]),
            ),
          ),
        ),
      ],
    );
  }

  // Helper function to build a styled text field for the Code
  Widget _buildCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabelText(context, 'Code*'),
        const SizedBox(height: 8), // Reduced spacing
        TextField(
          controller: _codeController,
          decoration: InputDecoration(
            hintText: 'Enter code',
            hintStyle: TextStyle(color: Colors.blueGrey[400]),
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ), // Rounded corners
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.blue, width: 2.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            filled: true,
            fillColor: Colors.grey[50], // Light grey background
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15.0,
              horizontal: 10.0,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor:
            Colors.grey[100], // Light grey background for the whole screen
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text(
            'Account Statement',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue, // Blue app bar
          iconTheme: const IconThemeData(
            color: Colors.white,
          ), // White icons in app bar
        ),
        body: SingleChildScrollView(
          // Allow scrolling if content overflows
          padding: const EdgeInsets.all(16.0), // Increased padding
          child: Card(
            // Wrap content in a Card for better visual separation
            elevation: 4.0, // Add shadow to the card
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                12.0,
              ), // Rounded corners for the card
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Padding inside the card
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Start Date Field
                  _buildDateField(context, 'Start Date', _startDateController),
                  const SizedBox(height: 16), // Increased spacing
                  // End Date Field
                  _buildDateField(context, 'End Date', _endDateController),
                  const SizedBox(height: 16), // Increased spacing
                  // Purchaser Type Dropdown
                  _buildDropdownField(
                    labelText: 'Purchaser Type',
                    items: roles,
                    selectedItem: selectedRole,
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value;
                      });
                    },
                    hintText: 'Select Purchaser Type',
                  ),
                  const SizedBox(height: 16), // Increased spacing
                  // Area Code Dropdown
                  _buildDropdownField(
                    labelText: 'Area Code',
                    items: areas,
                    selectedItem: selectedArea,
                    onChanged: (value) {
                      setState(() {
                        selectedArea = value;
                      });
                    },
                    hintText: 'Select Area Code',
                  ),
                  const SizedBox(height: 16), // Increased spacing
                  // Code Text Field
                  _buildCodeField(),
                  const SizedBox(
                    height: 24,
                  ), // Increased spacing before the button
                  // GO Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement GO button logic
                        print('Start Date: ${_startDateController.text}');
                        print('End Date: ${_endDateController.text}');
                        print('Purchaser Type: $selectedRole');
                        print('Area Code: $selectedArea');
                        print('Code: ${_codeController.text}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Button background color
                        foregroundColor: Colors.white, // Button text color
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ), // Button padding
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ), // Button text style
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            10,
                          ), // Rounded corners for button
                        ),
                        elevation: 3.0, // Add shadow to the button
                      ),
                      child: const Text('GO'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
