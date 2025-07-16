import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'dsr_entry.dart';
import 'package:learning2/core/constants/fonts.dart';
import 'package:learning2/core/theme/app_theme.dart';
import 'package:learning2/core/utils/document_number_storage.dart';
import 'dsr_exception_entry.dart';

class MeetingsWithContractor extends StatefulWidget {
  const MeetingsWithContractor({super.key});

  @override
  State<MeetingsWithContractor> createState() => _MeetingsWithContractorState();
}

class _MeetingsWithContractorState extends State<MeetingsWithContractor> {
  // Dynamic dropdown state
  List<Map<String, String>> _processTypes = [{'code': 'Select', 'description': 'Select'}];
  String? _selectedProcessTypeDescription = 'Select';
  String? _selectedProcessTypeCode;
  bool _isLoadingProcessTypes = true;

  List<Map<String, String>> _areaCodes = [];
  String? _selectedAreaCode = 'Select';
  bool _isLoadingAreaCodes = true;

  // Purchaser dropdown state
  List<Map<String, String>> _purchasers = [{'code': 'Select', 'description': 'Select'}];
  String? _selectedPurchaserDescription = 'Select';
  String? _selectedPurchaserCodeValue;
  bool _isLoadingPurchasers = false;

  // Purchaser code dropdown state
  List<Map<String, String>> _purchaserCodes = [{'code': 'Select', 'name': 'Select'}];
  String? _selectedPurchaserCode = 'Select';
  bool _isLoadingPurchaserCodes = false;

  final TextEditingController _submissionDateController = TextEditingController();
  final TextEditingController _reportDateController     = TextEditingController();
  DateTime? _selectedSubmissionDate;
  DateTime? _selectedReportDate;

  final List<int> _uploadRows    = [0];
  final ImagePicker _picker      = ImagePicker();
  final List<File?> _selectedImages = [null];
  
  final _documentNumberController = TextEditingController();
  String? _documentNumber;
  
  // Controllers for Action Remarks rows
  final List<TextEditingController> _actionPointsControllers = [TextEditingController()];
  final List<TextEditingController> _closerDateControllers = [TextEditingController()];

  // Product dropdown state
  String? _selectedProduct = 'Select';
  // Add controllers for text fields that lose state
  final TextEditingController _newOrdersController = TextEditingController();
  final TextEditingController _ugaiRecoveryController = TextEditingController();
  final TextEditingController _grievanceController = TextEditingController();
  final TextEditingController _otherPointsController = TextEditingController();
  // Coordinate controllers (if you choose to display these)

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadInitialDocumentNumber();
    _fetchProcessTypes();
    _fetchAreaCodes();
    _fetchPurchasers();
    _setSubmissionDateToToday();
  }

  // Load document number when screen initializes
  Future<void> _loadInitialDocumentNumber() async {
    final savedDocNumber = await DocumentNumberStorage.loadDocumentNumber(DocumentNumberKeys.meetingsContractor);
    if (savedDocNumber != null) {
      setState(() {
        _documentNumber = savedDocNumber;
      });
    }
  }

  @override
  void dispose() {
    _submissionDateController.dispose();
    _reportDateController.dispose();
   
    _documentNumberController.dispose();
    // Dispose new controllers
    _newOrdersController.dispose();
    _ugaiRecoveryController.dispose();
    _grievanceController.dispose();
    _otherPointsController.dispose();
    // Dispose Action Remarks controllers
    for (var controller in _actionPointsControllers) {
      controller.dispose();
    }
    for (var controller in _closerDateControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _setSubmissionDateToToday() {
    final today = DateTime.now();
    _selectedSubmissionDate = today;
    _submissionDateController.text = DateFormat('yyyy-MM-dd').format(today);
  }

  Future<void> _pickReportDate() async {
    final now = DateTime.now();
    final threeDaysAgo = now.subtract(const Duration(days: 3));
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedReportDate ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: SparshTheme.primaryBlueAccent,
            onPrimary: Colors.white,
            onSurface: SparshTheme.textPrimary,
          ),
          dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      if (picked.isBefore(threeDaysAgo)) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Please Put Valid DSR Date.'),
            content: const Text(
              'You Can submit DSR only Last Three Days. If You want to submit back date entry Please enter Exception entry (Path : Transcation --> DSR Exception Entry). Take Approval from concerned and Fill DSR Within 3 days after approval.'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DsrExceptionEntryPage()),
                  );
                },
                child: const Text('Go to Exception Entry'),
              ),
            ],
          ),
        );
        return;
      }
      setState(() {
        _selectedReportDate = picked;
        _reportDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _addRow() {
    setState(() {
      _uploadRows.add(_uploadRows.length);
      _selectedImages.add(null);
      _actionPointsControllers.add(TextEditingController());
      _closerDateControllers.add(TextEditingController());
    });
  }

  void _removeRow() {
    if (_uploadRows.length <= 1) return;
    setState(() {
      _uploadRows.removeLast();
      _selectedImages.removeLast();
      _actionPointsControllers.removeLast();
      _closerDateControllers.removeLast();
    });
  }

  Future<void> _pickImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImages[index] = File(pickedFile.path);
      });
    }
  }

  void _showImageDialog(File imageFile) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.contain,
              image: FileImage(imageFile),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> submitDsrEntry(Map<String, dynamic> dsrData) async {
    final url = Uri.parse('http://192.168.36.25/api/DsrTry');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dsrData),
    );
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
    if (response.statusCode == 201) {
      print('✅ Data inserted successfully!');
    } else {
      print('❌ Data NOT inserted! Error: ${response.body}');
    }
  }

  void _onSubmit({required bool exitAfter}) async {
    if (!_formKey.currentState!.validate()) return;

    // Map form fields to DsrEntryDto structure
    final dsrData = {
      'ActivityType': _selectedProcessTypeCode == 'U' ? 'Meetings with Contractor / Stockist' : 'Meetings with Contractor / Stockist', // or use code if needed
      'ProcessType': _selectedProcessTypeCode ?? '',
      'SubmissionDate': _selectedSubmissionDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'ReportDate': _selectedReportDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      
      'AreaCode': _selectedAreaCode ?? '',
      'Purchaser': _selectedPurchaserCodeValue ?? '',
      'PurchaserCode': _selectedPurchaserCode ?? '',
      'dsrRem01': _newOrdersController.text,
      'dsrRem02': _ugaiRecoveryController.text,
      'dsrRem03': _grievanceController.text,
      'dsrRem04': _otherPointsController.text,
      'dsrRem05': '',
      'dsrRem06': '',
      'dsrRem07': '',
      'dsrRem08': '',
    };

    try {
      await submitDsrEntry(dsrData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(exitAfter
              ? 'Submitted successfully. Exiting...'
              : 'Submitted successfully. Ready for new entry.'),
          backgroundColor: SparshTheme.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (exitAfter) {
        Navigator.of(context).pop();
      } else {
        _resetForm();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Submission failed: \\${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Add a method to reset the form (clear document number)
  void _resetForm() {
    setState(() {
      _documentNumber = null;
      _documentNumberController.clear();
      _selectedProcessTypeDescription = 'Select';
      _selectedProcessTypeCode = null;
      // Clear other form fields as needed
    });
    DocumentNumberStorage.clearDocumentNumber(DocumentNumberKeys.meetingsContractor); // Clear from persistent storage
  }

  // Update fetch process types to store code and description
  Future<void> _fetchProcessTypes() async {
    setState(() { _isLoadingProcessTypes = true; });
    try {
      final url = Uri.parse('http://192.168.36.25/api/DsrTry/getProcessTypes');
      final response = await http.get(url);
      print('ProcessTypes API status: ${response.statusCode}');
      print('ProcessTypes API raw body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('ProcessTypes API data: ${data}');
        if (data is List) {
          final processTypes = [
            {'code': 'Select', 'description': 'Select'},
            ...data.map<Map<String, String>>((item) => {
              'code': item['code']?.toString() ?? '',
              'description': item['description']?.toString() ?? '',
            }).where((item) => item['code']!.isNotEmpty && item['description']!.isNotEmpty)
          ];
          print('Mapped processTypes: ${processTypes}');
          setState(() {
            _processTypes = processTypes;
            _isLoadingProcessTypes = false;
          });
        }
      } else {
        print('ProcessTypes API error status: ${response.statusCode}');
        setState(() {
          _processTypes = [{'code': 'Select', 'description': 'Select'}];
          _isLoadingProcessTypes = false;
        });
      }
    } catch (e) {
      print('Error fetching process types: ${e}');
      setState(() {
        _processTypes = [{'code': 'Select', 'description': 'Select'}];
        _isLoadingProcessTypes = false;
      });
    }
  }

  Future<void> _fetchAreaCodes() async {
    setState(() { _isLoadingAreaCodes = true; });
    try {
      final url = Uri.parse('http://192.168.36.25/api/DsrTry/getAreaCodes');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          final processedAreaCodes = data.map((item) {
            final code = item['Code']?.toString() ?? item['code']?.toString() ?? item['AreaCode']?.toString() ?? '';
            final name = item['Name']?.toString() ?? item['name']?.toString() ?? code;
            return {'code': code, 'name': name};
          }).where((item) => item['code']!.isNotEmpty && item['code'] != '   ').toList();
          // Remove duplicates
          final seenCodes = <String>{};
          final uniqueAreaCodes = [
            {'code': 'Select', 'name': 'Select'},
            ...processedAreaCodes.where((item) {
              if (seenCodes.contains(item['code'])) return false;
              seenCodes.add(item['code']!);
              return true;
            })
          ];
          setState(() {
            _areaCodes = uniqueAreaCodes;
            _isLoadingAreaCodes = false;
            // Reset selected value if not present
            final validCodes = _areaCodes.map((a) => a['code']).toSet();
            if (_selectedAreaCode == null || !validCodes.contains(_selectedAreaCode)) {
              _selectedAreaCode = 'Select';
            }
          });
        } else {
          setState(() {
            _areaCodes = [{'code': 'Select', 'name': 'Select'}];
            _isLoadingAreaCodes = false;
          });
        }
      } else {
        setState(() {
          _areaCodes = [{'code': 'Select', 'name': 'Select'}];
          _isLoadingAreaCodes = false;
        });
      }
    } catch (e) {
      setState(() {
        _areaCodes = [{'code': 'Select', 'name': 'Select'}];
        _isLoadingAreaCodes = false;
      });
    }
  }

  // Fetch Purchaser options
  Future<void> _fetchPurchasers() async {
    setState(() { _isLoadingPurchasers = true; });
    try {
      final url = Uri.parse('http://192.168.36.25/api/DsrTry/getPurchaserOptions');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          final purchasers = [
            {'code': 'Select', 'description': 'Select'},
            ...data.map<Map<String, String>>((item) => {
              'code': item['code']?.toString() ?? '',
              'description': item['description']?.toString() ?? '',
            }).where((item) => item['code']!.isNotEmpty && item['description']!.isNotEmpty)
          ];
          setState(() {
            _purchasers = purchasers;
            _isLoadingPurchasers = false;
          });
        }
      } else {
        setState(() {
          _purchasers = [{'code': 'Select', 'description': 'Select'}];
          _isLoadingPurchasers = false;
        });
      }
    } catch (e) {
      setState(() {
        _purchasers = [{'code': 'Select', 'description': 'Select'}];
        _isLoadingPurchasers = false;
      });
    }
  }

  // Fetch Purchaser Codes
  Future<void> _fetchPurchaserCodes(String areaCode, String purchaserFlag) async {
    if (areaCode == 'Select' || purchaserFlag == 'Select') {
      setState(() {
        _purchaserCodes = [{'code': 'Select', 'name': 'Select'}];
        _selectedPurchaserCode = 'Select';
      });
      return;
    }
    setState(() {
      _isLoadingPurchaserCodes = true;
      _selectedPurchaserCode = 'Select';
    });
    try {
      final url = Uri.parse('http://192.168.36.25/api/DsrTry/getPurchaserCode?areaCode=$areaCode&purchaserFlag=$purchaserFlag');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && (data.containsKey('purchaserCodes') || data.containsKey('PurchaserCodes'))) {
          final purchaserCodesList = (data['purchaserCodes'] ?? data['PurchaserCodes']) as List;
          final purchaserCodes = purchaserCodesList.map((item) => {
            'code': (item['code'] ?? item['Code'] ?? '').toString().trim(),
            'name': (item['name'] ?? item['Name'] ?? item['code'] ?? item['Code'] ?? '').toString().trim(),
          }).where((item) => item['code']!.isNotEmpty).toList();
          setState(() {
            _purchaserCodes = [
              {'code': 'Select', 'name': 'Select'},
              ...purchaserCodes
            ];
            _isLoadingPurchaserCodes = false;
          });
        } else {
          setState(() {
            _purchaserCodes = [{'code': 'Select', 'name': 'Select'}];
            _isLoadingPurchaserCodes = false;
          });
        }
      } else {
        setState(() {
          _purchaserCodes = [{'code': 'Select', 'name': 'Select'}];
          _isLoadingPurchaserCodes = false;
        });
      }
    } catch (e) {
      setState(() {
        _purchaserCodes = [{'code': 'Select', 'name': 'Select'}];
        _isLoadingPurchaserCodes = false;
      });
    }
  }

  // Remove local generateDocumentNumber and add backend fetch logic
  Future<String?> _fetchDocumentNumberFromServer() async {
    try {
      final url = Uri.parse('http://192.168.36.25/api/DsrTry/generateDocumentNumber');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode('KKR'), // Hardcoded to KKR
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String? documentNumber;
        if (data is Map<String, dynamic>) {
          documentNumber = data['DocumentNumber'] as String?;
          if (documentNumber == null) documentNumber = data['documentNumber'] as String?;
          if (documentNumber == null) documentNumber = data['docuNumb'] as String?;
        } else if (data is String) {
          documentNumber = data;
        }
        if (documentNumber != null && documentNumber.isNotEmpty) {
          // Save to persistent storage
          if (documentNumber != null) {
            await DocumentNumberStorage.saveDocumentNumber(DocumentNumberKeys.meetingsContractor, documentNumber);
          }
          return documentNumber;
        } else {
          throw Exception('Invalid document number received from server');
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Update process type change handler to use code/description
  void _onProcessTypeChanged(String? code) {
    setState(() {
      _selectedProcessTypeCode = code;
      final selected = _processTypes.firstWhere(
        (item) => item['code'] == code,
        orElse: () => {'code': '', 'description': ''},
      );
      _selectedProcessTypeDescription = selected['description'];
    });
    if (code == "U") {
      // Only generate document number if we don't already have one
      if (_documentNumber == null) {
        setState(() {
          _documentNumberController.text = "Generating...";
        });
        try {
          _fetchDocumentNumberFromServer().then((docNumber) {
            setState(() {
              _documentNumber = docNumber;
              _documentNumberController.text = docNumber ?? "";
            });
          }).catchError((e) {
            setState(() {
              _selectedProcessTypeDescription = 'Select';
              _selectedProcessTypeCode = null;
              _documentNumber = null;
              _documentNumberController.clear();
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to generate document number:  e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          });
        } catch (e) {
          setState(() {
            _selectedProcessTypeDescription = 'Select';
            _selectedProcessTypeCode = null;
            _documentNumber = null;
            _documentNumberController.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to generate document number:  e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // If we already have a document number, just display it
        setState(() {
          _documentNumberController.text = _documentNumber!;
        });
      }
    } else {
      // For "Add" or any other process type, just clear the display but keep the document number in memory
      setState(() {
        _documentNumberController.text = "";
      });
    }
  }
  void _onAreaCodeChanged(String? value) {
    setState(() {
      _selectedAreaCode = value;
      _selectedPurchaserDescription = 'Select';
      _selectedPurchaserCodeValue = null;
      _selectedPurchaserCode = 'Select';
      _purchaserCodes = [{'code': 'Select', 'name': 'Select'}];
    });
    if (value != null && value != 'Select') {
      // Optionally, you can refetch purchasers if they depend on area
      //_fetchPurchasers();
    }
  }

  void _onPurchaserChanged(String? desc) {
    setState(() {
      _selectedPurchaserDescription = desc;
      final selected = _purchasers.firstWhere(
        (item) => item['description'] == desc,
        orElse: () => {'code': '', 'description': ''},
      );
      _selectedPurchaserCodeValue = selected['code'];
      _selectedPurchaserCode = 'Select';
      _purchaserCodes = [{'code': 'Select', 'name': 'Select'}];
    });
    if (_selectedPurchaserCodeValue != null && _selectedPurchaserCodeValue != 'Select' && _selectedAreaCode != null && _selectedAreaCode != 'Select') {
      _fetchPurchaserCodes(_selectedAreaCode!, _selectedPurchaserCodeValue!);
    }
  }

  void _onPurchaserCodeChanged(String? code) {
    setState(() {
      _selectedPurchaserCode = code;
    });
  }

  Widget _buildTextField(
      String hintText, {
        TextEditingController? controller,
        TextInputType? keyboardType,
        int maxLines = 1,
        String? Function(String?)? validator,
        bool readOnly = false,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: SparshTheme.textSecondary, fontSize: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(SparshBorderRadius.md), borderSide: BorderSide.none),
        filled: true,
        fillColor: SparshTheme.cardBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      validator: validator,
    );
  }

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
        hintStyle: const TextStyle(color: SparshTheme.textSecondary, fontSize: 16),
        suffixIcon: IconButton(icon: const Icon(Icons.calendar_today, color: SparshTheme.primaryBlueAccent), onPressed: onTap),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(SparshBorderRadius.md), borderSide: BorderSide.none),
        filled: true,
        fillColor: SparshTheme.cardBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      onTap: onTap,
      validator: (value) => (value == null || value.isEmpty) ? 'Please select a date' : null,
    );
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: SparshTypography.labelLarge.copyWith(color: SparshTheme.textPrimary),
  );

  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        color: Colors.white,
      ),
      child: DropdownButton<String>(
        dropdownColor: Colors.white,
        isExpanded: true,
        underline: Container(),
        value: value,
        onChanged: onChanged,
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item, style: Fonts.body.copyWith(fontSize: 16, color: Colors.black87))))
            .toList(),
      ),
    );
  }

  Widget _buildSearchableDropdownField({
    required String selected,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) =>
      DropdownSearch<String>(
        items: items,
        selectedItem: selected,
        onChanged: onChanged,
        validator: validator,
        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: const TextFieldProps(
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: TextStyle(color: Colors.black54),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                borderSide: BorderSide(color: Colors.blueAccent),
              ),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          itemBuilder: (context, item, isSelected) => Padding(
            padding: const EdgeInsets.all(12),
            child: Text(item, style: Fonts.body.copyWith(color: Colors.black87)),
          ),
        ),
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            hintText: 'Select',
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: SparshTheme.scaffoldBackground,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DsrEntry())),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
          ),
          title: Text(
            'Meeting With Contractor',
            style: SparshTypography.heading5.copyWith(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: SparshTheme.primaryBlueAccent,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [SparshTheme.scaffoldBackground, SparshTheme.cardBackground],
              stops: [0.0, 1.0],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Process Type Dropdown
                  _buildLabel('Process type'),
                  const SizedBox(height: 8),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                      color: Colors.white,
                    ),
                    child: _isLoadingProcessTypes
                        ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                        : DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedProcessTypeDescription,
                            underline: Container(),
                            items: _processTypes.map((item) {
                              return DropdownMenuItem(
                                value: item['description'],
                                child: Text(item['description']!),
                              );
                            }).toList(),
                            onChanged: (desc) {
                              setState(() {
                                _selectedProcessTypeDescription = desc;
                                final selected = _processTypes.firstWhere(
                                  (item) => item['description'] == desc,
                                  orElse: () => {'code': '', 'description': ''},
                                );
                                _selectedProcessTypeCode = selected['code'];
                              });
                              _onProcessTypeChanged(_selectedProcessTypeCode);
                            },
                          ),
                  ),
                  if (_selectedProcessTypeCode == "U")
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextFormField(
                        controller: _documentNumberController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Document Number",
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),
                  _buildLabel('Submission Date'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _submissionDateController,
                    readOnly: true,
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: 'Submission Date',
                      filled: true,
                      fillColor: SparshTheme.lightGreyBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(SparshBorderRadius.md),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: const Icon(Icons.lock, color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    validator: (val) => (val == null || val.isEmpty) ? 'Please select a date' : null,
                  ),

                  const SizedBox(height: 24),
                  _buildLabel('Report Date'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _reportDateController,
                    readOnly: true,
                    onTap: _pickReportDate,
                    decoration: InputDecoration(
                      hintText: 'Select Report Date',
                      filled: true,
                      fillColor: SparshTheme.lightGreyBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(SparshBorderRadius.md),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    validator: (val) => (val == null || val.isEmpty) ? 'Please select a date' : null,
                  ),

                  const SizedBox(height: 24),
                  _buildLabel('Area Code'),
                  const SizedBox(height: 8),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                      color: Colors.white,
                    ),
                    child: _isLoadingAreaCodes
                        ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                        : DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedAreaCode,
                            underline: Container(),
                            items: _areaCodes.map((area) {
                              final code = area['code']!;
                              final name = area['name']!;
                              return DropdownMenuItem(
                                value: code,
                                child: Text(code == 'Select' ? 'Select' : '$code - $name'),
                              );
                            }).toList(),
                            onChanged: _onAreaCodeChanged,
                          ),
                  ),

                  const SizedBox(height: 24),
                  _buildLabel('Purchaser'),
                  const SizedBox(height: 8),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                      color: Colors.white,
                    ),
                    child: _isLoadingPurchasers
                        ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                        : DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedPurchaserDescription,
                            underline: Container(),
                            items: _purchasers.map((item) {
                              return DropdownMenuItem(
                                value: item['description'],
                                child: Text(item['description']!),
                              );
                            }).toList(),
                            onChanged: _onPurchaserChanged,
                          ),
                  ),

                  const SizedBox(height: 24),
                  _buildLabel('Purchaser Code'),
                  const SizedBox(height: 8),
                  Builder(
                    builder: (context) {
                      return Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                          color: Colors.white,
                        ),
                        child: _isLoadingPurchaserCodes
                            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                            : DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedPurchaserCode,
                                underline: Container(),
                                items: _purchaserCodes.map((item) {
                                  final code = item['code']!;
                                  final name = item['name']!;
                                  return DropdownMenuItem(
                                    value: code,
                                    child: Text(code == 'Select' ? 'Select' : '$code - $name'),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPurchaserCode = value ?? 'Select';
                                  });
                                },
                              ),
                      );
                    },
                  ),

                 

                  const SizedBox(height: 24),
                  _buildLabel('New Orders Received'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    'New Orders Received',
                    controller: _newOrdersController,
                  ),

                  const SizedBox(height: 24),
                  _buildLabel('Ugai Recovery Plans'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    'Ugai Recovery Plans',
                    controller: _ugaiRecoveryController,
                    maxLines: 2,
                  ),

                  const SizedBox(height: 24),
                  _buildLabel('Any Purchaser Grievances'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    'Any Purchaser Grievances',
                    controller: _grievanceController,
                    maxLines: 2,
                  ),

                  const SizedBox(height: 24),
                  _buildLabel('Any Other Points'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    'Any Other Points',
                    controller: _otherPointsController,
                    maxLines: 2,
                  ),

                  const SizedBox(height: 24),
                  _buildLabel('Action Remarks'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildLabel('Action Points')),
                            Expanded(child: _buildLabel('Closer Date')),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: _removeRow,
                            ),
                          ],
                        ),
                        ...List.generate(_uploadRows.length, (index) {
                          return Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  '',
                                  controller: _actionPointsControllers[index], // Use controller
                                  maxLines: 2,
                                ),
                              ),
                              Expanded(
                                child: _buildDateField(
                                  _closerDateControllers[index], // Use controller
                                  () async {
                                    // Date picker for closer date
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now().add(const Duration(days: 365)),
                                    );
                                    // Set value if picked
                                    if (picked != null) {
                                      setState(() {
                                        _closerDateControllers[index].text = DateFormat('yyyy-MM-dd').format(picked);
                                      });
                                    }
                                  },
                                  'Closer Date',
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: _removeRow,
                              ),
                            ],
                          );
                        }),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ElevatedButton(
                              onPressed: _addRow,
                              child: const Text('Add'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildLabel('Upload Supporting'),
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: SparshTheme.cardBackground,
                      borderRadius: BorderRadius.circular(SparshBorderRadius.lg),
                      border: Border.all(color: SparshTheme.borderGrey),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.photo_library_rounded, color: SparshTheme.primaryBlueAccent, size: 24),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Supporting Documents',
                                style: Fonts.bodyBold.copyWith(fontSize: 18, color: SparshTheme.primaryBlueAccent),
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Upload images related to your activity', style: Fonts.body.copyWith(fontSize: 14, color: Colors.grey.shade600)),
                        const SizedBox(height: 16),
                        ...List.generate(_uploadRows.length, (index) {
                          final file = _selectedImages[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: file != null ? Colors.green.shade200 : Colors.grey.shade200, width: 1.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: SparshTheme.primaryBlueAccent.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text('Document ${index + 1}',
                                          style: Fonts.bodyBold.copyWith(fontSize: 14, color: SparshTheme.primaryBlueAccent)),
                                    ),
                                    const Spacer(),
                                    if (file != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration:
                                        BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(20)),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.check_circle, color: Colors.green, size: 16),
                                            SizedBox(width: 4),
                                            Text('Uploaded',
                                                style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500, fontSize: 14)),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (file != null)
                                  GestureDetector(
                                    onTap: () => _showImageDialog(file),
                                    child: Container(
                                      height: 120,
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
                                      ),
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          margin: const EdgeInsets.all(8),
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
                                          child: const Icon(Icons.zoom_in, color: Colors.white, size: 20),
                                        ),
                                      ),
                                    ),
                                  ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _pickImage(index),
                                        icon: Icon(file != null ? Icons.refresh : Icons.upload_file, size: 18),
                                        label: Text(file != null ? 'Replace' : 'Upload'),
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: file != null ? Colors.amber.shade600 : SparshTheme.primaryBlueAccent,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                    ),
                                    if (_uploadRows.length > 1)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: ElevatedButton.icon(
                                          onPressed: _removeRow,
                                          icon: const Icon(Icons.remove_circle_outline, size: 20),
                                          label: const Text('Remove'),
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor: Colors.redAccent,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _addRow,
                              icon: const Icon(Icons.add_photo_alternate, size: 20),
                              label: const Text('Document'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.blueAccent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () => _onSubmit(exitAfter: false),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: Fonts.bodyBold.copyWith(fontSize: 16),
                          elevation: 3.0,
                        ),
                        child: const Text('Submit & New'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _onSubmit(exitAfter: true),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: Fonts.bodyBold.copyWith(fontSize: 16),
                          elevation: 3.0,
                        ),
                        child: const Text('Submit & Exit'),
                      ),
                    ],
                  ),

                  // Hidden offstage fields (unchanged UI)
                  

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
