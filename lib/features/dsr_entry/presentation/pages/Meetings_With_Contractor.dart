import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dsr_entry.dart';
import 'package:learning2/core/constants/fonts.dart';
import 'package:learning2/core/theme/app_theme.dart';

class MeetingsWithContractor extends StatefulWidget {
  const MeetingsWithContractor({super.key});

  @override
  State<MeetingsWithContractor> createState() => _MeetingsWithContractorState();
}

class _MeetingsWithContractorState extends State<MeetingsWithContractor> {
  // Dynamic dropdown state
  List<String> _processTypes = ['Select'];
  String? _selectedProcessType = 'Select';
  bool _isLoadingProcessTypes = true;

  List<Map<String, String>> _areaCodes = [];
  String? _selectedAreaCode = 'Select';
  bool _isLoadingAreaCodes = true;

  List<Map<String, String>> _purchasers = [];
  String? _selectedPurchaser = 'Select';
  bool _isLoadingPurchasers = false;

  List<Map<String, String>> _purchaserCodes = [];
  String? _selectedPurchaserCode = 'Select';
  bool _isLoadingPurchaserCodes = false;

  final TextEditingController _submissionDateController = TextEditingController();
  final TextEditingController _reportDateController     = TextEditingController();
  DateTime? _selectedSubmissionDate;
  DateTime? _selectedReportDate;

  final List<int> _uploadRows    = [0];
  final ImagePicker _picker      = ImagePicker();
  final List<File?> _selectedImages = [null];
  
  // Controllers for Action Remarks rows
  final List<TextEditingController> _actionPointsControllers = [TextEditingController()];
  final List<TextEditingController> _closerDateControllers = [TextEditingController()];

  // Product dropdown state
  String? _selectedProduct = 'Select';
  // Coordinate controllers (if you choose to display these)
  final TextEditingController _yourLatitudeController  = TextEditingController();
  final TextEditingController _yourLongitudeController = TextEditingController();
  final TextEditingController _custLatitudeController  = TextEditingController();
  final TextEditingController _custLongitudeController = TextEditingController();

  // Hidden required fields for your original API (kept hidden in UI)
  final TextEditingController _contrnamController  = TextEditingController();
  final TextEditingController _topcdissController  = TextEditingController();
  final TextEditingController _remarkscController  = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchProcessTypes();
    _fetchAreaCodes();
    _setSubmissionDateToToday();
  }

  @override
  void dispose() {
    _submissionDateController.dispose();
    _reportDateController.dispose();
    _yourLatitudeController.dispose();
    _yourLongitudeController.dispose();
    _custLatitudeController.dispose();
    _custLongitudeController.dispose();
    _contrnamController.dispose();
    _topcdissController.dispose();
    _remarkscController.dispose();
    
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
      firstDate: threeDaysAgo,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
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
      'ActivityType': 'Meetings with Contractor / Stockist',
      'SubmissionDate': _selectedSubmissionDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'ReportDate': _selectedReportDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'CreateId': 'SYSTEM',
      'AreaCode': _selectedAreaCode ?? '',
      'Purchaser': _selectedPurchaser ?? '',
      'PurchaserCode': _selectedPurchaserCode ?? '',
      'dsrRem01': _contrnamController.text,
      'dsrRem02': _topcdissController.text,
      'dsrRem03': _remarkscController.text,
      'dsrRem04': '',
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

  void _resetForm() {
    setState(() {
      _selectedProcessType = 'Select';
      _selectedAreaCode = 'Select';
      _selectedPurchaser = 'Select';
      _selectedPurchaserCode = 'Select';

      _selectedSubmissionDate = null;
      _selectedReportDate     = null;
      _submissionDateController.clear();
      _reportDateController.clear();

      _yourLatitudeController.clear();
      _yourLongitudeController.clear();
      _custLatitudeController.clear();
      _custLongitudeController.clear();

      _contrnamController.clear();
      _topcdissController.clear();
      _remarkscController.clear();

      _uploadRows
        ..clear()
        ..add(0);
      _selectedImages
        ..clear()
        ..add(null);
      _actionPointsControllers
        ..clear()
        ..add(TextEditingController());
      _closerDateControllers
        ..clear()
        ..add(TextEditingController());
    });
    _formKey.currentState!.reset();
  }

  Future<void> _fetchProcessTypes() async {
    setState(() { _isLoadingProcessTypes = true; });
    try {
      final url = Uri.parse('http://192.168.36.25/api/DsrTry/getProcessTypes');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final processTypesList = (data['ProcessTypes'] ?? data['processTypes']) as List;
        final processTypes = processTypesList.map((type) {
          if (type is Map) {
            return type['Description']?.toString() ?? type['description']?.toString() ?? type['Code']?.toString() ?? type['code']?.toString() ?? '';
          } else {
            return type.toString();
          }
        }).where((type) => type.isNotEmpty).toList();
        setState(() {
          _processTypes = ['Select', ...processTypes];
          _isLoadingProcessTypes = false;
        });
      } else {
        setState(() {
          _processTypes = ['Select'];
          _isLoadingProcessTypes = false;
        });
      }
    } catch (e) {
      setState(() {
        _processTypes = ['Select'];
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

  Future<void> _fetchPurchasers(String areaCode) async {
    if (areaCode == 'Select') {
      setState(() {
        _purchasers = [{'code': 'Select', 'name': 'Select'}];
        _selectedPurchaser = 'Select';
        _selectedPurchaserCode = 'Select';
        _purchaserCodes = [{'code': 'Select', 'name': 'Select'}];
      });
      return;
    }
    setState(() {
      _isLoadingPurchasers = true;
      _selectedPurchaser = 'Select';
      _selectedPurchaserCode = 'Select';
      _purchaserCodes = [{'code': 'Select', 'name': 'Select'}];
    });
    try {
      final url = Uri.parse('http://192.168.36.25/api/DsrTry/getPurchaserOptions');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          // Remove duplicates by code
          final seenCodes = <String>{};
          final uniquePurchasers = [
            {'code': 'Select', 'name': 'Select'},
            ...data.map((item) => {
              'code': item['Code']?.toString() ?? item['code']?.toString() ?? '',
              'name': item['Description']?.toString() ?? item['description']?.toString() ?? '',
            }).where((item) {
              if (item['code']!.isEmpty || seenCodes.contains(item['code'])) return false;
              seenCodes.add(item['code']!);
              return true;
            }).toList()
          ];
          setState(() {
            _purchasers = uniquePurchasers;
            _isLoadingPurchasers = false;
            // Reset selected value if not present
            final validCodes = _purchasers.map((p) => p['code']).toSet();
            if (_selectedPurchaser == null || !validCodes.contains(_selectedPurchaser)) {
              _selectedPurchaser = 'Select';
            }
          });
        } else {
          setState(() {
            _purchasers = [{'code': 'Select', 'name': 'Select'}];
            _isLoadingPurchasers = false;
          });
        }
      } else {
        setState(() {
          _purchasers = [{'code': 'Select', 'name': 'Select'}];
          _isLoadingPurchasers = false;
        });
      }
    } catch (e) {
      setState(() {
        _purchasers = [{'code': 'Select', 'name': 'Select'}];
        _isLoadingPurchasers = false;
      });
    }
  }

  Future<void> _fetchPurchaserCodes(String purchaserCode) async {
    if (purchaserCode == 'Select' || _selectedAreaCode == 'Select') {
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
      final url = Uri.parse('http://192.168.36.25/api/DsrTry/getPurchaserCode')
          .replace(queryParameters: {
        'areaCode': _selectedAreaCode,
        'purchaserType': purchaserCode,
      });
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      if (data is Map && (data.containsKey('PurchaserCodes') || data.containsKey('purchaserCodes'))) {
        final purchaserCodesList = (data['PurchaserCodes'] ?? data['purchaserCodes']) as List;
        final purchaserCodes = purchaserCodesList.map((code) => code.toString()).toList();
        if (purchaserCodes.isNotEmpty) {
          setState(() {
            _purchaserCodes = [
              {'code': 'Select', 'name': 'Select'},
              ...purchaserCodes.map((code) => {'code': code, 'name': code}).toList()
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

  // Dropdown change handlers
  void _onProcessTypeChanged(String? value) {
    setState(() {
      _selectedProcessType = value;
    });
  }
  void _onAreaCodeChanged(String? value) {
    setState(() {
      _selectedAreaCode = value;
      _selectedPurchaser = 'Select';
      _selectedPurchaserCode = 'Select';
    });
    if (value != null && value != 'Select') {
      _fetchPurchasers(value);
    }
  }
  void _onPurchaserChanged(String? value) {
    setState(() {
      _selectedPurchaser = value;
      _selectedPurchaserCode = 'Select';
    });
    if (value != null && value != 'Select') {
      _fetchPurchaserCodes(value);
    }
  }
  void _onPurchaserCodeChanged(String? value) {
    setState(() {
      _selectedPurchaserCode = value;
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
        hintStyle: TextStyle(color: SparshTheme.textSecondary, fontSize: 16),
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
        hintStyle: TextStyle(color: SparshTheme.textSecondary, fontSize: 16),
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [SparshTheme.scaffoldBackground, SparshTheme.cardBackground],
              stops: const [0.0, 1.0],
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
                            value: _selectedProcessType,
                            underline: Container(),
                            items: _processTypes
                                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                                .toList(),
                            onChanged: _onProcessTypeChanged,
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
                      suffixIcon: Icon(Icons.lock, color: Colors.grey),
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
                            value: _selectedPurchaser,
                            underline: Container(),
                            items: _purchasers.map((purchaser) {
                              final code = purchaser['code']!;
                              final name = purchaser['name']!;
                              return DropdownMenuItem(
                                value: code,
                                child: Text(code == 'Select' ? 'Select' : name),
                              );
                            }).toList(),
                            onChanged: _onPurchaserChanged,
                          ),
                  ),

                  const SizedBox(height: 24),
                  _buildLabel('Purchaser Code'),
                  const SizedBox(height: 8),
                  Container(
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
                            items: _purchaserCodes.map((code) {
                              return DropdownMenuItem(
                                value: code['code'],
                                child: Text(code['code'] == 'Select' ? 'Select' : code['code']!),
                              );
                            }).toList(),
                            onChanged: _onPurchaserCodeChanged,
                          ),
                  ),

                  // Product Name Dropdown (as per screenshot)
                  const SizedBox(height: 24),
                  _buildLabel('Product for which Sample is applied'),
                  const SizedBox(height: 8),
                  DropdownSearch<String>(
                    items: const [
                      'Select',
                      'White Cement',
                      'Wall Care Putty',
                      'Textura',
                      'Levelplast',
                      'Wall Primer',
                    ],
                    selectedItem: _selectedProduct ?? 'Select',
                    onChanged: (value) {
                      setState(() {
                        _selectedProduct = value;
                      });
                    },
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
                  ),

                  const SizedBox(height: 24),
                  _buildLabel('New Orders Received'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    'New Orders Received',
                    controller: TextEditingController(), // Add controller if needed
                  ),

                  const SizedBox(height: 24),
                  _buildLabel('Ugai Recovery Plans'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    'Ugai Recovery Plans',
                    controller: TextEditingController(), // Add controller if needed
                    maxLines: 2,
                  ),

                  const SizedBox(height: 24),
                  _buildLabel('Any Purchaser Grievances'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    'Any Purchaser Grievances',
                    controller: TextEditingController(), // Add controller if needed
                    maxLines: 2,
                  ),

                  const SizedBox(height: 24),
                  _buildLabel('Any Other Points'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    'Any Other Points',
                    controller: TextEditingController(), // Add controller if needed
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
                            Icon(Icons.photo_library_rounded, color: SparshTheme.primaryBlueAccent, size: 24),
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
                  Offstage(
                    offstage: true,
                    child: Column(
                      children: [
                        TextFormField(controller: _contrnamController),
                        TextFormField(controller: _topcdissController),
                        TextFormField(controller: _remarkscController),
                      ],
                    ),
                  ),

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
