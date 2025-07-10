// File: lib/retailer_registration_page.dart

import 'package:flutter/material.dart';

class RetailerRegistrationPage extends StatefulWidget {
  const RetailerRegistrationPage({super.key});

  @override
  State<RetailerRegistrationPage> createState() =>
      _RetailerRegistrationPageState();
}

class _RetailerRegistrationPageState extends State<RetailerRegistrationPage> {
  // ======================
  // Existing “Basic Details” controllers & state
  // ======================
  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _firmNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _officeTelephoneController =
  TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _address3Controller = TextEditingController();

  String? _selectedProcessType;
  String? _selectedRetailerCategory;
  String? _selectedArea;
  String? _selectedDistrict;
  String? _selectedPinCode;
  String? _selectedCensusCity;
  String? _selectedCity;

  // “With GST” or “With PAN” toggle
  String _taxToggle = 'gst'; // either 'gst' or 'pan'

  final List<String> _processTypes = ['Add', 'Edit'];
  final List<String> _retailerCategories = ['Urban', 'Rural'];
  final List<String> _areas = ['Select', 'Area A', 'Area B', 'Area C'];
  final List<String> _districts = ['..select..', 'District X', 'District Y'];
  final List<String> _pinCodes = ['Select', '400001', '400002'];
  final List<String> _censusCities = ['Select', 'City A', 'City B'];
  final List<String> _cities = ['--', 'City 1', 'City 2'];

  // ======================
  // Existing “Contact Details” controllers & state
  // ======================
  final TextEditingController _stockistCodeController =
  TextEditingController();
  final TextEditingController _tallyRetailerCodeController =
  TextEditingController();
  final TextEditingController _concernEmployeeController =
  TextEditingController();
  final TextEditingController _schemeRequiredController =
  TextEditingController();
  final TextEditingController _aadharNumberController =
  TextEditingController();
  final TextEditingController _aadharPinController = TextEditingController();
  final TextEditingController _proprietorNameController =
  TextEditingController();

  final List<String> _schemes = ['Select', 'Scheme 1', 'Scheme 2'];

  // ======================
  // New “Bank Details” controllers & state
  // ======================
  final TextEditingController _accountHolderNameController =
  TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _accountNumberController =
  TextEditingController();
  final TextEditingController _bankBranchNoController = TextEditingController();
  final TextEditingController _bankBranchNameController =
  TextEditingController();
  final TextEditingController _bankBranchDescController =
  TextEditingController();

  // ======================
  // New “Business Details” controllers & state
  // ======================
  final TextEditingController _businessStartedYearController =
  TextEditingController();
  final TextEditingController _startedWithBirlaYearController =
  TextEditingController();
  final List<String> _businessTypes = ['Type 1', 'Type 2', 'Type 3'];
  final List<String> _selectedBusinessTypes = [];
  String? _selectedPaintNonPaintType;
  String? _selectedKycVerified;
  String? _selectedBankKycVerified;
  String? _selectedActiveStatus;
  String? _selectedRetailerClass;

  final List<String> _paintNonPaintTypes = ['Paint', 'Non Paint'];
  final List<String> _kycOptions = ['Yes', 'No'];
  final List<String> _activeStatusOptions = ['Yes', 'No'];
  final List<String> _retailerClassOptions = ['Select', 'Class A', 'Class B'];

  @override
  void dispose() {
    // Dispose all controllers
    _gstController.dispose();
    _panController.dispose();
    _firmNameController.dispose();
    _mobileController.dispose();
    _officeTelephoneController.dispose();
    _emailController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _address3Controller.dispose();

    _stockistCodeController.dispose();
    _tallyRetailerCodeController.dispose();
    _concernEmployeeController.dispose();
    _schemeRequiredController.dispose();
    _aadharNumberController.dispose();
    _aadharPinController.dispose();
    _proprietorNameController.dispose();

    _accountHolderNameController.dispose();
    _ifscController.dispose();
    _accountNumberController.dispose();
    _bankBranchNoController.dispose();
    _bankBranchNameController.dispose();
    _bankBranchDescController.dispose();

    _businessStartedYearController.dispose();
    _startedWithBirlaYearController.dispose();
    super.dispose();
  }

  /// Toggle business type detail in the multi‐select
  void _toggleBusinessType(String type) {
    setState(() {
      if (_selectedBusinessTypes.contains(type)) {
        _selectedBusinessTypes.remove(type);
      } else {
        _selectedBusinessTypes.add(type);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Full‐screen gradient background
      decoration: const BoxDecoration(
        color: Colors.blue,
      ),
      child: Scaffold(
        // Make the Scaffold background transparent so the gradient shows behind AppBar
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Retailer Registration',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isMobile = constraints.maxWidth < 600;

                // Existing two cards: Basic Details & Contact Details
                Widget topCards = isMobile
                    ? Column(
                  children: [
                    _basicDetailsCard(isMobile),
                    const SizedBox(height: 16),
                    _contactDetailsCard(isMobile),
                  ],
                )
                    : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _basicDetailsCard(isMobile)),
                    const SizedBox(width: 16),
                    Expanded(child: _contactDetailsCard(isMobile)),
                  ],
                );

                // New cards: Bank Details & Business Details
                Widget bottomCards = isMobile
                    ? Column(
                  children: [
                    _bankDetailsCard(isMobile),
                    const SizedBox(height: 16),
                    _businessDetailsCard(isMobile),
                  ],
                )
                    : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _bankDetailsCard(isMobile)),
                    const SizedBox(width: 16),
                    Expanded(child: _businessDetailsCard(isMobile)),
                  ],
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    topCards,
                    const SizedBox(height: 24),
                    bottomCards,
                    const SizedBox(height: 24),
                    // Submit button at bottom
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Implement the actual submission logic
                        debugPrint('=== SUBMIT PRESSED ===');
                        debugPrint('Process Type: $_selectedProcessType');
                        debugPrint('Retailer Category: $_selectedRetailerCategory');
                        debugPrint('Area: $_selectedArea');
                        debugPrint('Tax Toggle: $_taxToggle');
                        debugPrint('GST: ${_gstController.text}');
                        debugPrint('PAN: ${_panController.text}');
                        debugPrint('Firm Name: ${_firmNameController.text}');
                        debugPrint('Mobile: ${_mobileController.text}');
                        debugPrint('Office Tel: ${_officeTelephoneController.text}');
                        debugPrint('Email: ${_emailController.text}');
                        debugPrint('District: $_selectedDistrict');
                        debugPrint('Pin Code: $_selectedPinCode');
                        debugPrint('Census City: $_selectedCensusCity');
                        debugPrint('City: $_selectedCity');
                        debugPrint('Address1: ${_address1Controller.text}');
                        debugPrint('Address2: ${_address2Controller.text}');
                        debugPrint('Address3: ${_address3Controller.text}');

                        debugPrint('Stockist Code: ${_stockistCodeController.text}');
                        debugPrint('Tally Code: ${_tallyRetailerCodeController.text}');
                        debugPrint('Concern Emp: ${_concernEmployeeController.text}');
                        debugPrint('Scheme: ${_schemeRequiredController.text}');
                        debugPrint('Aadhar No: ${_aadharNumberController.text}');
                        debugPrint('Aadhar Pin: ${_aadharPinController.text}');
                        debugPrint('Proprietor Name: ${_proprietorNameController.text}');

                        debugPrint('Account Holder Name: ${_accountHolderNameController.text}');
                        debugPrint('IFSC: ${_ifscController.text}');
                        debugPrint('Account Number: ${_accountNumberController.text}');
                        debugPrint('Bank Branch No: ${_bankBranchNoController.text}');
                        debugPrint('Bank Branch Name: ${_bankBranchNameController.text}');
                        debugPrint('Bank Branch Desc: ${_bankBranchDescController.text}');

                        debugPrint('Business Start Year: ${_businessStartedYearController.text}');
                        debugPrint('Started with Birla Year: ${_startedWithBirlaYearController.text}');
                        debugPrint('Business Types: $_selectedBusinessTypes');
                        debugPrint('Paint/Non-Paint Type: $_selectedPaintNonPaintType');
                        debugPrint('KYC Verified: $_selectedKycVerified');
                        debugPrint('Bank KYC Verified: $_selectedBankKycVerified');
                        debugPrint('Active Status: $_selectedActiveStatus');
                        debugPrint('Retailer Class: $_selectedRetailerClass');
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

  // ======================
  // “Basic Details” card
  // ======================
  Widget _basicDetailsCard(bool isMobile) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Details',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 16),

            // Process Type
            const Text('Process Type', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedProcessType ?? _processTypes.first,
              decoration: _inputDecoration(),
              items: _processTypes.map((proc) {
                return DropdownMenuItem(
                  value: proc,
                  child: Text(proc),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProcessType = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Retailer Category
            const Text('Retailer Category', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value:
              _selectedRetailerCategory ?? _retailerCategories.first,
              decoration: _inputDecoration(),
              items: _retailerCategories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRetailerCategory = value;
                });
              },
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

            // Register With PAN / GST *
            const Text('Register With PAN / GST *',
                style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _taxToggle = 'gst';
                        _panController.clear();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _taxToggle == 'gst'
                          ? Colors.blue.withValues(alpha: 0.15)
                          : Colors.white,
                      side: BorderSide(
                        color: _taxToggle == 'gst'
                            ? Colors.blue
                            : Colors.grey.shade400,
                      ),
                    ),
                    child: const Text('With GST'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _taxToggle = 'pan';
                        _gstController.clear();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _taxToggle == 'pan'
                          ? Colors.blue.withValues(alpha: 0.15)
                          : Colors.white,
                      side: BorderSide(
                        color: _taxToggle == 'pan'
                            ? Colors.blue
                            : Colors.grey.shade400,
                      ),
                    ),
                    child: const Text('With PAN'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // GST Number *
            const Text('GST Number *', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _gstController,
              enabled: _taxToggle == 'gst',
              decoration: _inputDecoration(
                hintText: 'GST Number',
                enabled: _taxToggle == 'gst',
              ),
            ),
            const SizedBox(height: 16),

            // PAN NO *
            const Text('PAN NO *', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _panController,
              enabled: _taxToggle == 'pan',
              decoration: _inputDecoration(
                hintText: 'PAN',
                enabled: _taxToggle == 'pan',
              ),
            ),
            const SizedBox(height: 16),

            // Firm Name *
            const Text('Firm Name *', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _firmNameController,
              decoration: _inputDecoration(hintText: 'Firm Name'),
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

            // Office Telephone 1
            const Text('Office Telephone 1', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _officeTelephoneController,
              keyboardType: TextInputType.phone,
              decoration:
              _inputDecoration(hintText: 'Office Telephone 1'),
            ),
            const SizedBox(height: 16),

            // Email
            const Text('Email', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration(hintText: 'Email'),
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

            // Pin Code *
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

            // Census City *
            const Text('Census City *', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedCensusCity ?? _censusCities.first,
              decoration: _inputDecoration(),
              items: _censusCities.map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCensusCity = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // City *
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
          ],
        ),
      ),
    );
  }

  // ======================
  // “Contact Details” card
  // ======================
  Widget _contactDetailsCard(bool isMobile) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Details',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 16),

            // Stockist Code *
            const Text('Stockist Code *', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _stockistCodeController,
              decoration: _inputDecoration(
                hintText: '',
                suffixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),

            // Tally Retailer Code (disabled)
            const Text('Tally Retailer Code', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _tallyRetailerCodeController,
              enabled: false,
              decoration: _inputDecoration(
                  hintText: "Stockist's Tally Retailer Code in Ta",
                  enabled: false),
            ),
            const SizedBox(height: 16),

            // Concern Employee *
            const Text('Concern Employee *', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _concernEmployeeController,
              decoration: _inputDecoration(hintText: 'Concern Employee'),
            ),
            const SizedBox(height: 16),

            // Retailer Profile Image *
            const Text('Retailer Profile Image *',
                style: TextStyle(fontSize: 14)),
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
                ElevatedButton(
                  onPressed: () {
                    // TODO: implement image view
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('View'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // PAN/GST NO Image Upload / View *
            const Text('PAN/GST NO Image Upload / View *',
                style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () {
                    // TODO: implement view PAN/GST image
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                  ),
                  child: const Text('View PAN'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    // TODO: implement upload PAN/GST image
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('Upload PAN'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Scheme required *
            const Text('Scheme required *', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _schemeRequiredController.text.isEmpty
                  ? _schemes.first
                  : _schemeRequiredController.text,
              decoration: _inputDecoration(),
              items: _schemes.map((scheme) {
                return DropdownMenuItem(
                  value: scheme,
                  child: Text(scheme),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _schemeRequiredController.text = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Aadhar Card No.
            const Text('Aadhar Card No.', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _aadharNumberController,
              decoration: _inputDecoration(hintText: 'Aadhar Card No.'),
            ),
            const SizedBox(height: 16),

            // Aadhar Card Pin Code
            const Text('Aadhar Card Pin Code',
                style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // TODO: implement view Aadhar
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('View'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    // TODO: implement upload Aadhar ID
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('Upload ID'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Proprietor / Partner Name *
            const Text('Proprietor / Partner Name *',
                style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _proprietorNameController,
              decoration:
              _inputDecoration(hintText: 'Proprietor / Partner Name'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ======================
  // “Bank Details” card (new)
  // ======================
  Widget _bankDetailsCard(bool isMobile) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bank Details',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 16),

            // Account Holder Name
            const Text('Account Holder Name', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _accountHolderNameController,
              decoration: _inputDecoration(hintText: 'Firm Name'),
            ),
            const SizedBox(height: 16),

            // IFSC Code
            const Text('IFSC Code', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _ifscController,
              decoration: _inputDecoration(hintText: 'IFSC Code'),
            ),
            const SizedBox(height: 16),

            // Account Number
            const Text('Account Number', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _accountNumberController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(hintText: 'Account Number'),
            ),
            const SizedBox(height: 16),

            // Bank Document Upload
            const Text('Bank Document Upload', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () {
                    // TODO: implement view check (CHQ)
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                  ),
                  child: const Text('View CHQ'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    // TODO: implement upload bank document
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('Upload'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Bank Branch No
            const Text('Bank Branch No', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _bankBranchNoController,
              decoration: _inputDecoration(hintText: 'Bank Branch No'),
            ),
            const SizedBox(height: 16),

            // Bank Branch Name
            const Text('Bank Branch Name', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _bankBranchNameController,
              decoration: _inputDecoration(hintText: 'Bank Branch Name'),
            ),
            const SizedBox(height: 16),

            // Bank Branch Description
            const Text('Bank Branch Description', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _bankBranchDescController,
              decoration: _inputDecoration(hintText: 'Bank Branch Description'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ======================
  // “Business Details” card (new)
  // ======================
  Widget _businessDetailsCard(bool isMobile) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Business Details',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 16),

            // Business Started from Year (disabled)
            const Text('Business Started from Year', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _businessStartedYearController,
              enabled: false,
              decoration: _inputDecoration(
                hintText: 'Business Started from Year',
                enabled: false,
              ),
            ),
            const SizedBox(height: 16),

            // Started business with BirlaWhite Year (disabled)
            const Text('Started business with BirlaWhite Year', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _startedWithBirlaYearController,
              enabled: false,
              decoration: _inputDecoration(
                hintText: 'Started business with BirlaWhite Y',
                enabled: false,
              ),
            ),
            const SizedBox(height: 16),

            // Type of Business (multi-select)
            const Text('Type of Business', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            OutlinedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _businessTypes.map((type) {
                        final bool checked =
                        _selectedBusinessTypes.contains(type);
                        return CheckboxListTile(
                          title: Text(type),
                          value: checked,
                          onChanged: (_) {
                            _toggleBusinessType(type);
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
                  _selectedBusinessTypes.isEmpty
                      ? '0 options selected'
                      : '${_selectedBusinessTypes.length} options selected',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Paint / Non-Paint Type *
            const Text('Paint / Non-Paint Type *', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedPaintNonPaintType,
              decoration: _inputDecoration(),
              items: _paintNonPaintTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPaintNonPaintType = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // KYC Verified (updatable in Zonal Commercial login) *
            const Text('KYC Verified (updatable in Zonal Commercial login) *',
                style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedKycVerified ?? _kycOptions.first,
              decoration: _inputDecoration(),
              items: _kycOptions.map((opt) {
                return DropdownMenuItem(
                  value: opt,
                  child: Text(opt),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedKycVerified = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Bank KYC Verified (updatable in Zonal Commercial login) *
            const Text('Bank KYC Verified (updatable in Zonal Commercial login) *',
                style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedBankKycVerified ?? _kycOptions.first,
              decoration: _inputDecoration(),
              items: _kycOptions.map((opt) {
                return DropdownMenuItem(
                  value: opt,
                  child: Text(opt),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBankKycVerified = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Active Status (updatable in ZH / Commercial login) *
            const Text('Active Status (updatable in ZH / Commercial login) *',
                style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedActiveStatus ?? _activeStatusOptions.first,
              decoration: _inputDecoration(),
              items: _activeStatusOptions.map((opt) {
                return DropdownMenuItem(
                  value: opt,
                  child: Text(opt),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedActiveStatus = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Retailer Class *
            const Text('Retailer Class *', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedRetailerClass ?? _retailerClassOptions.first,
              decoration: _inputDecoration(),
              items: _retailerClassOptions.map((opt) {
                return DropdownMenuItem(
                  value: opt,
                  child: Text(opt),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRetailerClass = value;
                });
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Helper: unified InputDecoration for text fields
  InputDecoration _inputDecoration({String? hintText, bool enabled = true, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade200,
      enabled: enabled,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
