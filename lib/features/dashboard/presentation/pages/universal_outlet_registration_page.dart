// File: lib/universal_outlet_registration.dart

import 'package:flutter/material.dart';

class UniversalOutletRegistrationPage extends StatefulWidget {
  const UniversalOutletRegistrationPage({super.key});

  @override
  State<UniversalOutletRegistrationPage> createState() =>
      _UniversalOutletRegistrationPageState();
}

class _UniversalOutletRegistrationPageState
    extends State<UniversalOutletRegistrationPage> {
  // Controllers for text fields
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _address3Controller = TextEditingController();
  final TextEditingController _concernEmployeeController =
  TextEditingController(text: 'undefined');
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _alternateMobileController =
  TextEditingController();
  final TextEditingController _gstController = TextEditingController();

  final TextEditingController _panController = TextEditingController();
  final TextEditingController _retailerNameController =
  TextEditingController();
  final TextEditingController _marketNameController = TextEditingController();
  final TextEditingController _whiteCementController = TextEditingController();
  final TextEditingController _wallCareController = TextEditingController();
  final TextEditingController _contactNameController = TextEditingController();

  // Dropdown selections
  String? _selectedArea;
  String? _selectedDistrict;
  String? _selectedCity;
  String? _selectedPinCode;
  String? _selectedPaintNonPaint;
  final List<String> _selectedPaintNonPaintDetails = [];

  // Toggle for address mode: 'geo' or 'pin'
  String _addressMode = 'geo';

  // Dropdown lists (placeholder values; replace with real data)
  final List<String> _areas = ['Select', 'Area A', 'Area B', 'Area C'];
  final List<String> _districts = ['select', 'District X', 'District Y'];
  final List<String> _cities = ['Select City', 'City 1', 'City 2'];
  final List<String> _pinCodes = ['-- Select Pin Code --', '400001', '400002'];
  final List<String> _paintNonPaintOptions = ['Paint', 'Non Paint'];
  final List<String> _paintNonPaintDetailsOptions = [
    'Detail 1',
    'Detail 2',
    'Detail 3'
  ];

  @override
  void dispose() {
    // Dispose all controllers
    _address1Controller.dispose();
    _address2Controller.dispose();
    _address3Controller.dispose();
    _concernEmployeeController.dispose();
    _mobileController.dispose();
    _alternateMobileController.dispose();
    _gstController.dispose();

    _panController.dispose();
    _retailerNameController.dispose();
    _marketNameController.dispose();
    _whiteCementController.dispose();
    _wallCareController.dispose();
    _contactNameController.dispose();
    super.dispose();
  }

  /// Toggles a detail in the "Paint / Non-Paint Details" checklist.
  void _togglePaintNonPaintDetail(String detail) {
    setState(() {
      if (_selectedPaintNonPaintDetails.contains(detail)) {
        _selectedPaintNonPaintDetails.remove(detail);
      } else {
        _selectedPaintNonPaintDetails.add(detail);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Wrap the entire Scaffold in a Container with a blue gradient
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1976D2),
            Color(0xFF42A5F5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        // Make the Scaffold background transparent so the gradient shows through
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          // Transparent AppBar so gradient extends behind it
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Universal Outlets Registration',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () {
              Navigator.pop(context);
            },
            tooltip: 'Back',
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // If device width < 600, stack cards vertically
                bool isMobile = constraints.maxWidth < 600;

                // Build the two cards in either a Column (mobile) or Row (tablet/desktop)
                Widget cardsSection = isMobile
                    ? Column(
                  children: [
                    _buildBasicDetailsCard(isMobile),
                    const SizedBox(height: 16),
                    _buildContactDetailsCard(isMobile),
                  ],
                )
                    : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildBasicDetailsCard(isMobile)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildContactDetailsCard(isMobile)),
                  ],
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    cardsSection,
                    const SizedBox(height: 24),
                    // Submit button at the bottom
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Implement your submit logic here
                        // For now, just print all entered data:
                        debugPrint('--- SUBMIT PRESSED ---');
                        debugPrint('Area: $_selectedArea');
                        debugPrint('Address Mode: $_addressMode');
                        debugPrint('Address1: ${_address1Controller.text}');
                        debugPrint('Address2: ${_address2Controller.text}');
                        debugPrint('Address3: ${_address3Controller.text}');
                        debugPrint('Concern Employee: ${_concernEmployeeController.text}');
                        debugPrint('District: $_selectedDistrict');
                        if (_addressMode == 'pin') {
                          debugPrint('Pin Code: $_selectedPinCode');
                        }
                        debugPrint('City: $_selectedCity');
                        debugPrint('Mobile: ${_mobileController.text}');
                        debugPrint('Alternate Mobile: ${_alternateMobileController.text}');
                        debugPrint('GST Number: ${_gstController.text}');
                        debugPrint('PAN NO: ${_panController.text}');
                        debugPrint('Retailer Name: ${_retailerNameController.text}');
                        debugPrint('Market Name: ${_marketNameController.text}');
                        debugPrint('WC Potential: ${_whiteCementController.text}');
                        debugPrint('WCP Potential: ${_wallCareController.text}');
                        debugPrint('Paint/Non-Paint Type: $_selectedPaintNonPaint');
                        debugPrint('Paint/Non-Paint Details: $_selectedPaintNonPaintDetails');
                        debugPrint('Contact Name: ${_contactNameController.text}');
                        // At this point, you can send data to your API or process it further
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Left "Basic Details" card
  Widget _buildBasicDetailsCard(bool isMobile) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Basic Details',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 16),

            // Area *
            const Text('Area *', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedArea ?? _areas.first,
              decoration: _inputDecoration(),
              items: _areas.map((area) {
                return DropdownMenuItem(
                  value: area,
                  child: Text(area),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedArea = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Address Capture using Geo Location / Select Pin * (mutually exclusive)
            const Text(
              'Address Capture using Geo Location / Select Pin *',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _addressMode = 'geo';
                      });
                      // TODO: implement Geo Location logic
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _addressMode == 'geo'
                          ? Colors.blue.withOpacity(0.15)
                          : Colors.white,
                      side: BorderSide(
                        color: _addressMode == 'geo'
                            ? Colors.blue
                            : Colors.grey.shade400,
                      ),
                    ),
                    child: const Text('Geo Location'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _addressMode = 'pin';
                      });
                      // TODO: implement Pin Code logic
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _addressMode == 'pin'
                          ? Colors.blue.withOpacity(0.15)
                          : Colors.white,
                      side: BorderSide(
                        color: _addressMode == 'pin'
                            ? Colors.blue
                            : Colors.grey.shade400,
                      ),
                    ),
                    child: const Text('Pin Code'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Address 1 *
            const Text('Address 1 *', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _address1Controller,
              decoration: _inputDecoration(hintText: 'Address 1'),
            ),
            const SizedBox(height: 16),

            // Address 2
            const Text('Address 2', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _address2Controller,
              decoration: _inputDecoration(hintText: 'Address 2'),
            ),
            const SizedBox(height: 16),

            // Address 3
            const Text('Address 3', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _address3Controller,
              decoration: _inputDecoration(hintText: 'Address 3'),
            ),
            const SizedBox(height: 16),

            // Concern Employee *
            const Text('Concern Employee *', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _concernEmployeeController,
              readOnly: true,
              decoration: _inputDecoration(),
            ),
            const SizedBox(height: 6),
            Text(
              'undefined',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),

            // District *
            const Text('District *', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedDistrict ?? _districts.first,
              decoration: _inputDecoration(),
              items: _districts.map((dist) {
                return DropdownMenuItem(
                  value: dist,
                  child: Text(dist),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDistrict = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Pin Code * (only show if addressMode == 'pin')
            if (_addressMode == 'pin') ...[
              const Text('Pin Code *', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedPinCode ?? _pinCodes.first,
                decoration: _inputDecoration(),
                items: _pinCodes.map((pin) {
                  return DropdownMenuItem(
                    value: pin,
                    child: Text(pin),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPinCode = value;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],

            // City * (always show)
            const Text('City *', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedCity ?? _cities.first,
              decoration: _inputDecoration(),
              items: _cities.map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCity = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Mobile *
            const Text('Mobile *', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration(hintText: 'Mobile'),
            ),
            const SizedBox(height: 16),

            // Alternate Mobile
            const Text('Alternate Mobile', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _alternateMobileController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration(hintText: 'Alternate Mobile'),
            ),
            const SizedBox(height: 16),

            // GST Number
            const Text('GST Number', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _gstController,
              decoration: _inputDecoration(hintText: 'GST No', enabled: false),
            ),
          ],
        ),
      ),
    );
  }

  /// Right "Contact Details" card
  Widget _buildContactDetailsCard(bool isMobile) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Contact Details',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 16),

            // PAN NO
            const Text('PAN NO', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _panController,
              decoration: _inputDecoration(hintText: 'PAN', enabled: false),
            ),
            const SizedBox(height: 16),

            // Retailer Name *
            const Text('Retailer Name *', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _retailerNameController,
              decoration: _inputDecoration(hintText: 'Retailer Name'),
            ),
            const SizedBox(height: 16),

            // Market Name *
            const Text('Market Name *', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _marketNameController,
              decoration: _inputDecoration(hintText: 'Market Name'),
            ),
            const SizedBox(height: 16),

            // Total WC Potential (Monthly) *
            const Text('Total WC Potential (Monthly)*',
                style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _whiteCementController,
              keyboardType: TextInputType.number,
              decoration:
              _inputDecoration(hintText: 'White Cement Potential'),
            ),
            const SizedBox(height: 16),

            // Total WCP Potential (Monthly) *
            const Text('Total WCP Potential (Monthly)*',
                style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _wallCareController,
              keyboardType: TextInputType.number,
              decoration:
              _inputDecoration(hintText: 'Wall care Putty Potential'),
            ),
            const SizedBox(height: 16),

            // Paint / Non-Paint Type *
            const Text('Paint / Non-Paint Type *',
                style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            Row(
              children: _paintNonPaintOptions.map((option) {
                final bool isSelected = _selectedPaintNonPaint == option;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedPaintNonPaint = option;
                        // When selecting a type, clear detail selections
                        _selectedPaintNonPaintDetails.clear();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isSelected
                          ? Colors.blue.withOpacity(0.15)
                          : Colors.white,
                      side: BorderSide(
                          color: isSelected ? Colors.blue : Colors.grey.shade400),
                    ),
                    child: Text(option),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Paint / Non-Paint Details (multi-select)
            const Text('Paint / Non-Paint Details',
                style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            OutlinedButton(
              onPressed: () {
                // Show a modal bottom sheet with checkboxes
                showModalBottomSheet(
                  context: context,
                  builder: (_) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _paintNonPaintDetailsOptions.map((detail) {
                        final bool checked =
                        _selectedPaintNonPaintDetails.contains(detail);
                        return CheckboxListTile(
                          title: Text(detail),
                          value: checked,
                          onChanged: (_) {
                            _togglePaintNonPaintDetail(detail);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.grey.shade50,
                side: BorderSide(color: Colors.grey.shade400),
                padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _selectedPaintNonPaintDetails.isEmpty
                      ? '0 options selected'
                      : '${_selectedPaintNonPaintDetails.length} options selected',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Contact Name *
            const Text('Contact Name *', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _contactNameController,
              decoration: _inputDecoration(hintText: 'Contact Name'),
            ),
            const SizedBox(height: 16),

            // Retailer Shop Image
            const Text('Retailer Shop Image', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // TODO: implement image upload
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('Upload'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    // TODO: implement image view
                  },
                  child: const Text('View'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper: unified InputDecoration for text fields
  InputDecoration _inputDecoration({String? hintText, bool enabled = true}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade200,
      enabled: enabled,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
