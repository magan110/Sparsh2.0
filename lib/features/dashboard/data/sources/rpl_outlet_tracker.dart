import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:learning2/features/dashboard/presentation/pages/home_screen.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class RplOutletTracker extends StatefulWidget {
  const RplOutletTracker({super.key});

  @override
  State<RplOutletTracker> createState() => _RplOutletTrackerState();
}

class _RplOutletTrackerState extends State<RplOutletTracker> {
  String? selectedReportType;
  final List<String> roles = [
    'RPL 1 Tracker',
    'RPL 2(Revised Working) Tracker',
    'RPL 3 Tracker',
    'RPL 4 Tracker',
    'RPL 5 Tracker',
    'RPL 6 Enroll List',
    'RPL 6 Tracker',
  ];

  String? selectedOutputType;
  final List<String> types = [
    'HTML',
    'Excel - CSV Download',
    'Tab Delim.Text',
    'Pivot',
  ];

  // Custom Text Style
  final TextStyle _labelTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.blueGrey[800],
    fontFamily: GoogleFonts.lato().fontFamily, // Use a modern font like Lato
  );

  Widget _buildLabelText(BuildContext context, String text) {
    return Text(text, style: _labelTextStyle);
  }

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
        const SizedBox(height: 12), // Increased spacing
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: DropdownSearch<String>(
            popupProps: PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: "Search...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14.0,
                    horizontal: 12.0,
                  ),
                ),
              ),
              menuProps: MenuProps(
                borderRadius: BorderRadius.circular(12.0),
                elevation: 8,
              ),
            ),
            items: items,
            selectedItem: selectedItem,
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            onChanged: onChanged,
            dropdownButtonProps: DropdownButtonProps(
              icon: Icon(Icons.arrow_drop_down, color: Colors.blueGrey[700]),
              padding: EdgeInsets.zero,
              iconSize: 30,
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
        appBar: AppBar(
          backgroundColor: Colors.lightBlue,
          leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.0)),
            child: Text(
              'Outlet Tracker',
              style: GoogleFonts.lato(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          elevation: 0,
          centerTitle: true,
        ),
        backgroundColor: Colors.grey[50],
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildDropdownField(
                labelText: 'Select Report Type',
                items: roles,
                selectedItem: selectedReportType,
                onChanged:
                    (value) => setState(() => selectedReportType = value),
                hintText: 'Enter Tracker',
              ),
              const SizedBox(height: 20),
              _buildDropdownField(
                labelText: 'Output Type',
                items: types,
                selectedItem: selectedOutputType,
                onChanged:
                    (value) => setState(() => selectedOutputType = value),
                hintText: 'Enter Type',
              ),
              const SizedBox(height: 20),
              _buildLabelText(context, 'Specific Codes (, Separated List)*'),
              const SizedBox(height: 12),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  fillColor: Colors.white,
                ),
                style: TextStyle(fontFamily: GoogleFonts.lato().fontFamily),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  textStyle: TextStyle(
                    fontFamily: GoogleFonts.lato().fontFamily,
                    fontSize: 18,
                  ),
                ),
                child: const Text('GO'),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(
                      onPressed: () {
                        // TODO: Implement copy functionality
                        print('Copy button pressed');
                      },
                      icon: Icons.copy,
                      label: 'Copy',
                      backgroundColor: Colors.green,
                    ),
                    _buildActionButton(
                      onPressed: () {
                        // TODO: Implement CSV download functionality
                        print('CSV button pressed');
                      },
                      icon: Icons.file_present,
                      label: 'CSV',
                      backgroundColor: Colors.grey[600]!,
                    ),
                    _buildActionButton(
                      onPressed: () {
                        // TODO: Implement Excel download functionality
                        print('Excel button pressed');
                      },
                      icon: Icons.file_copy,
                      label: 'Excel',
                      backgroundColor: Colors.purple,
                    ),
                    _buildActionButton(
                      onPressed: () {
                        // TODO: Implement PDF download functionality
                        print('PDF button pressed');
                      },
                      icon: Icons.picture_as_pdf,
                      label: 'PDF',
                      backgroundColor: Colors.red,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Refactored Action Button
  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
  }) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white),
          label: Text(
            label,
            style: TextStyle(
              fontFamily: GoogleFonts.lato().fontFamily,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 12,
            ), // Adjusted padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 3,
            textStyle: const TextStyle(fontSize: 12),
            visualDensity: VisualDensity.compact,
          ),
        ),
      ),
    );
  }
}
