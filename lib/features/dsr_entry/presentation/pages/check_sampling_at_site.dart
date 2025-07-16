import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/document_number_storage.dart';
import 'dsr_entry.dart';
import 'dsr_exception_entry.dart';

class ApiConstants {
  static const String baseUrl = 'http://192.168.36.25/api';
  static const String getProcessTypes = '/DsrTry/getProcessTypes';
  static const String getProductOptions = '/DsrTry/getProductOptions';
  static const String getQualityOptions = '/DsrTry/getQualityOptions';
  static const String getStatusOptions = '/DsrTry/getStatusOptions';
  static const String dsrTry = '/DsrTry';

  static String url(String endpoint) => 'baseUrlendpoint'.replaceAll('baseUrl', baseUrl).replaceAll('endpoint', endpoint);
}

class CheckSamplingAtSite extends StatefulWidget {
  const CheckSamplingAtSite({super.key});

  @override
  State<CheckSamplingAtSite> createState() => _CheckSamplingAtSiteState();
}

class _CheckSamplingAtSiteState extends State<CheckSamplingAtSite> {
  // ─── State & Controllers ────────────────────────────────────────────────────
  // Dynamic dropdown state
  List<Map<String, String>> _processTypes = [{'code': 'Select', 'description': 'Select'}];
  String? _selectedProcessTypeDescription = 'Select';
  String? _selectedProcessTypeCode;
  bool _isLoadingProcessTypes = true;

    // Geolocation
  Position? _currentPosition;

  List<String> _productNames = ['Select'];
  String? _selectedProductName = 'Select';
  bool _isLoadingProductNames = true;

  List<String> _qualityOptions = ['Select'];
  final String? _selectedQuality = 'Select';
  bool _isLoadingQualityOptions = true;

  List<String> _statusOptions = ['Select'];
  final String? _selectedStatus = 'Select';
  bool _isLoadingStatusOptions = true;

  String? _processItem = 'Select';
  final _processItems = ['Select', 'Add', 'Update'];

  final _dateController = TextEditingController();
  final _reportDateController = TextEditingController();
  DateTime? _selectedDate;
  DateTime? _selectedReportDate;

  final _siteController = TextEditingController();
  final _productController = TextEditingController();
  final _potentialController = TextEditingController();
  final _applicatorController = TextEditingController();

  String? _qualityItem = 'Select';
  final _qualityItems = ['Select', 'Average', 'Medium', 'Good'];

  String? _statusItem = 'Select';
  final _statusItems = [
    'Select',
    'Yet To be Checked By Purchaser',
    'Approved',
    'Rejected',
  ];

  final _contactNameController = TextEditingController();
  final _mobileController = TextEditingController();

  final List<XFile?> _selectedImages = [null];
  final _picker = ImagePicker();

  final _documentNumberController = TextEditingController();
  String? _documentNumber;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
        _initGeolocation();
    _loadInitialDocumentNumber();
    _fetchProcessTypes();
    _fetchProductNames();
    _fetchQualityOptions();
    _fetchStatusOptions();
    _setSubmissionDateToToday();
  }

  Future<void> _initGeolocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services disabled.');
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions denied.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions permanently denied.');
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = pos;
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }


  // Load document number when screen initializes
  Future<void> _loadInitialDocumentNumber() async {
    final savedDocNumber = await DocumentNumberStorage.loadDocumentNumber(DocumentNumberKeys.checkSamplingSite);
    if (savedDocNumber != null) {
      setState(() {
        _documentNumber = savedDocNumber;
      });
    }
  }

  Future<void> _fetchProcessTypes() async {
    setState(() { _isLoadingProcessTypes = true; });
    try {
      final url = Uri.parse(ApiConstants.url(ApiConstants.getProcessTypes));
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          final processTypes = [
            {'code': 'Select', 'description': 'Select'},
            ...data.map<Map<String, String>>((item) => {
              'code': item['Code']?.toString() ?? item['code']?.toString() ?? '',
              'description': item['Description']?.toString() ?? item['description']?.toString() ?? '',
            }).where((item) => item['code']!.isNotEmpty && item['description']!.isNotEmpty)
          ];
          setState(() {
            _processTypes = processTypes;
            _isLoadingProcessTypes = false;
          });
        } else {
          setState(() {
            _processTypes = [{'code': 'Select', 'description': 'Select'}];
            _isLoadingProcessTypes = false;
          });
        }
      } else {
        setState(() {
          _processTypes = [{'code': 'Select', 'description': 'Select'}];
          _isLoadingProcessTypes = false;
        });
      }
    } catch (e) {
      setState(() {
        _processTypes = [{'code': 'Select', 'description': 'Select'}];
        _isLoadingProcessTypes = false;
      });
    }
  }

  Future<void> _fetchProductNames() async {
    setState(() { _isLoadingProductNames = true; });
    try {
      final url = Uri.parse(ApiConstants.url(ApiConstants.getProductOptions));
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final productNames = (data is List ? data : <String>[]).map((e) => e.toString()).toList();
        setState(() {
          _productNames = ['Select', ...productNames];
          _isLoadingProductNames = false;
        });
      } else {
        setState(() {
          _productNames = ['Select'];
          _isLoadingProductNames = false;
        });
      }
    } catch (e) {
      setState(() {
        _productNames = ['Select'];
        _isLoadingProductNames = false;
      });
    }
  }

  Future<void> _fetchQualityOptions() async {
    setState(() { _isLoadingQualityOptions = true; });
    try {
      final url = Uri.parse(ApiConstants.url(ApiConstants.getQualityOptions));
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final qualityOptions = (data is List ? data : <String>[]).map((e) => e.toString()).toList();
        setState(() {
          _qualityOptions = ['Select', ...qualityOptions];
          _isLoadingQualityOptions = false;
        });
      } else {
        setState(() {
          _qualityOptions = ['Select'];
          _isLoadingQualityOptions = false;
        });
      }
    } catch (e) {
      setState(() {
        _qualityOptions = ['Select'];
        _isLoadingQualityOptions = false;
      });
    }
  }

  Future<void> _fetchStatusOptions() async {
    setState(() { _isLoadingStatusOptions = true; });
    try {
      final url = Uri.parse(ApiConstants.url(ApiConstants.getStatusOptions));
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final statusOptions = (data is List ? data : <String>[]).map((e) => e.toString()).toList();
        setState(() {
          _statusOptions = ['Select', ...statusOptions];
          _isLoadingStatusOptions = false;
        });
      } else {
        setState(() {
          _statusOptions = ['Select'];
          _isLoadingStatusOptions = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusOptions = ['Select'];
        _isLoadingStatusOptions = false;
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _reportDateController.dispose();
    _siteController.dispose();
    _productController.dispose();
    _potentialController.dispose();
    _applicatorController.dispose();
    _contactNameController.dispose();
    _mobileController.dispose();
    _documentNumberController.dispose();
    super.dispose();
  }

  void _setSubmissionDateToToday() {
    final today = DateTime.now();
    _selectedDate = today;
    _dateController.text = DateFormat('yyyy-MM-dd').format(today);
  }

  Future<void> _pickReportDate() async {
    final now = DateTime.now();
    final threeDaysAgo = now.subtract(const Duration(days: 3));
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedReportDate ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
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

  Future<void> _pickDate(
    TextEditingController ctrl,
    DateTime? initialDate,
    ValueChanged<DateTime> onSelected, {
    bool isReportDate = false,
  }) async {
    final now = DateTime.now();
    final firstDate = isReportDate 
        ? now.subtract(const Duration(days: 3))  // Last 3 days for report date
        : DateTime(2000);  // Any date for submission date
    final lastDate = isReportDate 
        ? now  // Today for report date
        : DateTime(now.year + 5);  // Future date for submission date
    
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      onSelected(picked);
      ctrl.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _pickImage(int idx) async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _selectedImages[idx] = file);
  }

  void _showImage(XFile file) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Image.file(
          File(file.path),
          fit: BoxFit.contain,
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
        ),
      ),
    );
  }

  void _addImageField() {
    if (_selectedImages.length < 3) setState(() => _selectedImages.add(null));
  }

  void _removeImageField(int idx) {
    if (_selectedImages.length > 1) setState(() => _selectedImages.removeAt(idx));
  }

  Future<void> _onSubmit({required bool exitAfter}) async {
    if (!_formKey.currentState!.validate()) return;

    // ensure we have location
    if (_currentPosition == null) {
      await _initGeolocation();
    }


    final dsrData = {
      'ActivityType': 'Visit to Get / Check Sampling at Site',
      'ProcessType': _selectedProcessTypeCode ?? '',
      'SubmissionDate': _selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'ReportDate': _selectedReportDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      // 'CreateId': 'SYSTEM',
      // 'AreaCode': _siteController.text,
      // 'Purchaser': _productController.text,
      // 'PurchaserCode': '',
      'dsrRem01': _siteController.text,
      'dsrRem02': _selectedProductName ?? '',
      'dsrRem03': _potentialController.text,
      'dsrRem04': _applicatorController.text,
      'dsrRem05': (_qualityItem != null && _qualityItem != 'Select') ? _qualityItem : '',
      'dsrRem06': (_statusItem != null && _statusItem != 'Select') ? _statusItem : '',
      'dsrRem07': _contactNameController.text,
      'dsrRem08': _mobileController.text,
      // 'SupportingDocuments': _selectedImages.map((file) => file?.path).toList(),
      // Geography
      'latitude': _currentPosition?.latitude.toString() ?? '',
      'longitude': _currentPosition?.longitude.toString() ?? '',
    };
    print('Prepared DSR Data: $dsrData'); // DEBUG

    try {
      await submitDsrEntry(dsrData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(exitAfter
              ? 'Submitted successfully. Exiting...'
              : 'Submitted successfully. Ready for new entry.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (exitAfter) {
        Navigator.of(context).pop();
      } else {
        _formKey.currentState!.reset();
        setState(() {
          _processItem = 'Select';
          _selectedDate = null;
          _selectedReportDate = null;
          _dateController.clear();
          _reportDateController.clear();
          _siteController.clear();
          _productController.clear();
          _potentialController.clear();
          _applicatorController.clear();
          _qualityItem = 'Select';
          _statusItem = 'Select';
          _contactNameController.clear();
          _mobileController.clear();
          _selectedImages
            ..clear()
            ..add(null);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Submission failed: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> submitDsrEntry(Map<String, dynamic> dsrData) async {
    print('Submitting DSR Data: $dsrData'); // DEBUG
    final url = Uri.parse(ApiConstants.url(ApiConstants.dsrTry));
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dsrData),
      );
      print('API Response Status: ${response.statusCode}'); // DEBUG
      print('API Response Body: ${response.body}'); // DEBUG
      if (response.statusCode == 201) {
        print('✅ Data inserted successfully!');
      } else {
        print('❌ Data NOT inserted! Error: ${response.body}');
      }
    } catch (e) {
      print('API Exception: ${e.toString()}'); // DEBUG
      rethrow;
    }
  }

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
          documentNumber = data['documentNumber'] ?? data['DocumentNumber'] ?? data['docNumber'] ?? data['DocNumber'];
        } else if (data is String) {
          documentNumber = data;
        }
        
        // Save to persistent storage
        if (documentNumber != null) {
          await DocumentNumberStorage.saveDocumentNumber(DocumentNumberKeys.checkSamplingSite, documentNumber);
        }
        
        return documentNumber;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: SparshSpacing.sm),
        child: Text(text, style: SparshTypography.bodyBold),
      );

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) => DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          filled: true,
          fillColor: SparshTheme.lightGreyBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SparshBorderRadius.sm),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: SparshSpacing.md,
            vertical: SparshSpacing.sm,
          ),
        ),
        items: items.map((it) => DropdownMenuItem(value: it, child: Text(it))).toList(),
        onChanged: onChanged,
        validator: validator,
      );

  Widget _buildDateField(
    TextEditingController ctrl,
    VoidCallback onTap,
    String hint, {
    String? Function(String?)? validator,
  }) => TextFormField(
        controller: ctrl,
        readOnly: true,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: SparshTheme.lightGreyBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SparshBorderRadius.sm),
            borderSide: BorderSide.none,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today, size: SparshIconSize.md),
            onPressed: onTap,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: SparshSpacing.md,
            vertical: SparshSpacing.sm,
          ),
        ),
        onTap: onTap,
        validator: validator,
      );

  Widget _buildTextField(
    String hint,
    TextEditingController ctrl, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) => TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: SparshTheme.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SparshBorderRadius.sm),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: SparshSpacing.md,
            vertical: SparshSpacing.sm,
          ),
        ),
        validator: validator,
      );

  Widget _buildImageRow(int idx) {
    final file = _selectedImages[idx];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Document ${idx + 1}', style: SparshTypography.bodyBold),
        const SizedBox(height: SparshSpacing.xs),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(idx),
              icon: Icon(file != null ? Icons.refresh : Icons.upload_file),
              label: Text(file != null ? 'Replace' : 'Upload'),
            ),
            const SizedBox(width: SparshSpacing.sm),
            if (file != null)
              ElevatedButton.icon(
                onPressed: () => _showImage(file),
                icon: const Icon(Icons.visibility),
                label: const Text('View'),
              ),
            const Spacer(),
            if (_selectedImages.length > 1 && idx == _selectedImages.length - 1)
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: SparshTheme.errorRed),
                onPressed: () => _removeImageField(idx),
              ),
          ],
        ),
        const SizedBox(height: SparshSpacing.md),
      ],
    );
  }

  Widget _sectionContainer({required Widget child}) => Container(
        decoration: BoxDecoration(
          color: SparshTheme.cardBackground,
          borderRadius: BorderRadius.circular(SparshBorderRadius.md),
          boxShadow: SparshShadows.card,
        ),
        padding: const EdgeInsets.all(SparshSpacing.md),
        child: child,
      );

  // Add a method to reset the form (clear document number)
  void _resetForm() {
    setState(() {
      _documentNumber = null;
      _documentNumberController.clear();
      _processItem = 'Select';
      // Clear other form fields as needed
    });
    DocumentNumberStorage.clearDocumentNumber(DocumentNumberKeys.checkSamplingSite); // Clear from persistent storage
  }

  void _onProcessTypeChanged(String? desc) {
    setState(() {
      _selectedProcessTypeDescription = desc;
      final selected = _processTypes.firstWhere(
        (item) => item['description'] == desc,
        orElse: () => {'code': '', 'description': ''},
      );
      _selectedProcessTypeCode = selected['code'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SparshTheme.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DsrEntry()),
          ),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: Text(
          'Check Sampling at Site',
          style: SparshTypography.heading5.copyWith(color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: SparshTheme.primaryBlueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SparshSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Process Section
              _sectionContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Process Type'),
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
                                _onProcessTypeChanged(desc);
                                if (desc == "Update") {
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
                                      });
                                    } catch (e) {
                                      setState(() {
                                        _documentNumberController.text = "Error generating document number";
                                      });
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
                              },
                            ),
                    ),
                    if (_selectedProcessTypeDescription == "Update")
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
                  ],
                ),
              ),
              const SizedBox(height: SparshSpacing.md),

              // Date Section
              _sectionContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Submission Date'),
                    TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: 'Submission Date',
                        filled: true,
                        fillColor: SparshTheme.lightGreyBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(SparshBorderRadius.sm),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: SparshSpacing.md,
                          vertical: SparshSpacing.sm,
                        ),
                        suffixIcon: const Icon(Icons.lock, color: Colors.grey),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: SparshSpacing.sm),
                    _buildLabel('Report Date'),
                    TextFormField(
                      controller: _reportDateController,
                      readOnly: true,
                      onTap: _pickReportDate,
                      decoration: InputDecoration(
                        hintText: 'Select Report Date',
                        filled: true,
                        fillColor: SparshTheme.lightGreyBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(SparshBorderRadius.sm),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: SparshSpacing.md,
                          vertical: SparshSpacing.sm,
                        ),
                        suffixIcon: const Icon(Icons.calendar_today, size: SparshIconSize.md),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SparshSpacing.md),

              // Site & Product Section
              _sectionContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Site Name'),
                    _buildTextField(
                      'Enter Site Name',
                      _siteController,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: SparshSpacing.sm),
                    _buildLabel('Product Name'),
                    // _buildTextField(
                    //   'Enter Product Name',
                    //   _productController,
                    //   validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    // ),
                    _isLoadingProductNames
                        ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                        : DropdownButtonFormField<String>(
                            value: _selectedProductName,
                            isExpanded: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: SparshTheme.lightGreyBackground,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(SparshBorderRadius.sm),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: SparshSpacing.md,
                                vertical: SparshSpacing.sm,
                              ),
                            ),
                            items: _productNames.map((it) => DropdownMenuItem(value: it, child: Text(it))).toList(),
                            onChanged: (v) => setState(() => _selectedProductName = v),
                            validator: (v) => (v == null || v == 'Select') ? 'Required' : null,
                          ),
                  ],
                ),
              ),
              const SizedBox(height: SparshSpacing.md),

              // Potential & Applicator Section
              _sectionContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Potential (MT)'),
                    _buildTextField(
                      'Enter Potential',
                      _potentialController,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        return null;
                      },
                    ),
                    const SizedBox(height: SparshSpacing.sm),
                    _buildLabel('Applicator Name'),
                    _buildTextField(
                      'Enter Applicator Name',
                      _applicatorController,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SparshSpacing.md),

              // Quality & Status Section
              _sectionContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Quality of Sample'),
                    _buildDropdown(
                      value: _qualityItem,
                      items: _qualityOptions,
                      onChanged: (v) => setState(() => _qualityItem = v),
                      validator: (v) => (v == null || v == 'Select') ? 'Required' : null,
                    ),
                    const SizedBox(height: SparshSpacing.sm),
                    _buildLabel('Status of Sample'),
                    _buildDropdown(
                      value: _statusItem,
                      items: _statusOptions,
                      onChanged: (v) => setState(() => _statusItem = v),
                      validator: (v) => (v == null || v == 'Select') ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SparshSpacing.md),

              // Contact & Mobile Section
              _sectionContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Contact Name'),
                    _buildTextField(
                      'Enter Contact Name',
                      _contactNameController,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: SparshSpacing.sm),
                    _buildLabel('Mobile Number'),
                    _buildTextField(
                      'Enter Mobile Number',
                      _mobileController,
                      keyboardType: TextInputType.phone,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SparshSpacing.md),

              // Supporting Documents Section
              _sectionContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.photo_library_rounded,
                          color: SparshTheme.primaryBlueAccent,
                          size: SparshIconSize.lg,
                        ),
                        SizedBox(width: SparshSpacing.sm),
                        Expanded(
                          child: Text(
                            'Supporting Documents',
                            style: SparshTypography.bodyBold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SparshSpacing.sm),
                    ...List.generate(
                      _selectedImages.length,
                      (idx) => _buildImageRow(idx),
                    ),
                    if (_selectedImages.length < 3)
                      Center(
                        child: TextButton.icon(
                          onPressed: _addImageField,
                          icon: const Icon(Icons.add_photo_alternate),
                          label: const Text('Add More Image'),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: SparshSpacing.lg),

              // Submit Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _onSubmit(exitAfter: false),
                      child: const Text('Submit & New'),
                    ),
                  ),
                  const SizedBox(width: SparshSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _onSubmit(exitAfter: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SparshTheme.successGreen,
                      ),
                      child: const Text('Submit & Exit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
