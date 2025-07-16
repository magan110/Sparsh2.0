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

class WorkFromHome extends StatefulWidget {
  const WorkFromHome({super.key});

  @override
  State<WorkFromHome> createState() => _WorkFromHomeState();
}

class _WorkFromHomeState extends State<WorkFromHome> {
  Map<String, String>? _processItem;
  List<Map<String, String>> _processdropdownItems = [];
  bool _isLoadingProcessTypes = true;
  String? _processTypeError;

  // Geolocation
  Position? _currentPosition;


  final TextEditingController _submissionDateController = TextEditingController();
  final TextEditingController _reportDateController     = TextEditingController();
  DateTime? _selectedSubmissionDate;
  DateTime? _selectedReportDate;

  // ─── NEW CONTROLLERS ─────────────────────────────────────────────────────────
  final TextEditingController _activityDetails1Controller = TextEditingController();
  final TextEditingController _activityDetails2Controller = TextEditingController();
  final TextEditingController _activityDetails3Controller = TextEditingController();
  final TextEditingController _otherPointsController      = TextEditingController();
  // ─────────────────────────────────────────────────────────────────────────────

  final List<int> _uploadRows       = [0];
  final List<File?> _selectedImages = [null];
  final ImagePicker _picker         = ImagePicker();
  final _formKey                    = GlobalKey<FormState>();

  final _documentNumberController = TextEditingController();
  String? _documentNumber;

  @override
  void initState() {
    super.initState();
    _initGeolocation();
    _loadInitialDocumentNumber();
    _fetchProcessTypes();
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
    final savedDocNumber = await DocumentNumberStorage.loadDocumentNumber(DocumentNumberKeys.workFromHome);
    if (savedDocNumber != null) {
      setState(() {
        _documentNumber = savedDocNumber;
      });
    }
  }

  Future<void> _fetchProcessTypes() async {
    setState(() { _isLoadingProcessTypes = true; _processTypeError = null; });
    try {
      final url = Uri.parse('http://192.168.36.25/api/DsrTry/getProcessTypes');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List processTypesList = [];
        if (data is List) {
          processTypesList = data;
        } else if (data is Map && (data['ProcessTypes'] != null || data['processTypes'] != null)) {
          processTypesList = (data['ProcessTypes'] ?? data['processTypes']) as List;
        }
        final processTypes = processTypesList.map<Map<String, String>>((type) {
          if (type is Map) {
            return {
              'code': type['Code']?.toString() ?? type['code']?.toString() ?? '',
              'description': type['Description']?.toString() ?? type['description']?.toString() ?? '',
            };
          } else {
            return {'code': type.toString(), 'description': type.toString()};
          }
        }).where((type) => type['code']!.isNotEmpty && type['description']!.isNotEmpty).toList();
        setState(() {
          _processdropdownItems = processTypes;
          _processItem = null;
          _isLoadingProcessTypes = false;
        });
      } else {
        setState(() {
          _processdropdownItems = [];
          _processItem = null;
          _isLoadingProcessTypes = false;
          _processTypeError = 'Failed to load process types.';
        });
      }
    } catch (e) {
      setState(() {
        _processdropdownItems = [];
        _processItem = null;
        _isLoadingProcessTypes = false;
        _processTypeError = 'Failed to load process types.';
      });
    }
  }

  @override
  void dispose() {
    _submissionDateController.dispose();
    _reportDateController.dispose();

    // ─── DISPOSE NEW CONTROLLERS ──────────────────────────────────────────────
    _activityDetails1Controller.dispose();
    _activityDetails2Controller.dispose();
    _activityDetails3Controller.dispose();
    _otherPointsController.dispose();
    _documentNumberController.dispose();
    // ──────────────────────────────────────────────────────────────────────────

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
      initialDate: now,
      firstDate: DateTime(now.year - 10), // Allow any past date (last 10 years)
      lastDate: now,  // Only allow up to today
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
    });
  }

  void _removeRow() {
    if (_uploadRows.length <= 1) return;
    setState(() {
      _uploadRows.removeLast();
      _selectedImages.removeLast();
    });
  }

  Future<void> _pickImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImages[index] = File(pickedFile.path));
    }
  }

  void _showImageDialog(File imageFile) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              imageFile,
              fit: BoxFit.contain,
              errorBuilder: (c, e, s) => Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Unable to load image', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
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

  InputDecoration get _multilineDecoration => InputDecoration(
    hintText: '',
    filled: true,
    fillColor: SparshTheme.cardBackground,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(SparshBorderRadius.sm),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: SparshSpacing.md, vertical: SparshSpacing.sm),
    isCollapsed: true,
  );

  // Add a method to reset the form (clear document number)
  void _resetForm() {
    setState(() {
      _documentNumber = null;
      _documentNumberController.clear();
      _processItem = null;
      // Clear other form fields as needed
    });
    DocumentNumberStorage.clearDocumentNumber(DocumentNumberKeys.workFromHome); // Clear from persistent storage
  }

  Future<void> _onSubmit({required bool exitAfter}) async {
    if (!_formKey.currentState!.validate()) return;

    // ensure we have location
    if (_currentPosition == null) {
      await _initGeolocation();
    }


    final dsrData = {
      'ActivityType': 'Work From Home',
      'SubmissionDate': _selectedSubmissionDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'ReportDate': _selectedReportDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
  
      'dsrRem01': _activityDetails1Controller.text,
      'dsrRem02': _activityDetails2Controller.text,
      'dsrRem03': _activityDetails3Controller.text,
      'dsrRem04': _otherPointsController.text,

      // Geography
      'latitude': _currentPosition?.latitude.toString() ?? '',
      'longitude': _currentPosition?.longitude.toString() ?? '',

    };

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
          await DocumentNumberStorage.saveDocumentNumber(DocumentNumberKeys.workFromHome, documentNumber);
        }
        
        return documentNumber;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const DsrEntry())),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 22),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Work From Home',
              style: SparshTypography.heading2.copyWith(color: Colors.black),
            ),
            Text(
              'Daily Sales Report Entry',
              style: SparshTypography.body.copyWith(color: Colors.black54),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black, size: 24),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Help information for Work From Home'),
                duration: Duration(seconds: 2),
              ),
            ),
          )
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SparshSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                              // ─── Process Section ──────────────────────────────────────────────
                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: SparshSpacing.md),
                  padding: const EdgeInsets.all(SparshSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(SparshBorderRadius.sm),
                    boxShadow: SparshShadows.sm,
                  ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Process',
                      style: SparshTypography.heading5.copyWith(color: SparshTheme.textPrimary),
                    ),
                    const SizedBox(height: SparshSpacing.sm),
                    if (_processTypeError != null)
                      Text(_processTypeError!, style: const TextStyle(color: Colors.red)),
                    _isLoadingProcessTypes
                      ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                      : DropdownButtonFormField<Map<String, String>>(
                          value: _processItem,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: SparshTheme.cardBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(SparshBorderRadius.sm),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: SparshSpacing.md, vertical: SparshSpacing.sm),
                            isCollapsed: true,
                          ),
                          isExpanded: true,
                          items: _processdropdownItems
                              .map((item) => DropdownMenuItem(
                            value: item,
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 250),
                              child: Text(item['description'] ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(fontSize: 14)),
                            ),
                          ))
                              .toList(),
                          onChanged: (val) async {
                            setState(() {
                              _processItem = val;
                            });
                            if (val != null && val['description'] == "Update") {
                              if (_documentNumber == null) {
                                setState(() {
                                  _documentNumberController.text = "Generating...";
                                });
                                try {
                                  final docNumber = await _fetchDocumentNumberFromServer();
                                  setState(() {
                                    _documentNumber = docNumber;
                                    _documentNumberController.text = docNumber ?? "";
                                  });
                                } catch (e) {
                                  setState(() {
                                    _documentNumberController.text = "Error generating document number";
                                  });
                                }
                              } else {
                                setState(() {
                                  _documentNumberController.text = _documentNumber!;
                                });
                              }
                            } else {
                              setState(() {
                                _documentNumberController.text = "";
                              });
                            }
                          },
                          validator: (v) =>
                          (v == null) ? 'Required' : null,
                        ),
                   if (_processItem != null && _processItem!['description'] == "Update")
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

                              // ─── Date Section ─────────────────────────────────────────────────
                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: SparshSpacing.md),
                  padding: const EdgeInsets.all(SparshSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(SparshBorderRadius.sm),
                    boxShadow: SparshShadows.sm,
                  ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Submission Date',
                      style: SparshTypography.heading5.copyWith(color: SparshTheme.textPrimary),
                    ),
                    const SizedBox(height: SparshSpacing.sm),
                    TextFormField(
                      controller: _submissionDateController,
                      readOnly: true,
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: 'Submission Date',
                        filled: true,
                        fillColor: SparshTheme.cardBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(SparshBorderRadius.sm),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: SparshSpacing.md, vertical: SparshSpacing.sm),
                        isCollapsed: true,
                        suffixIcon: const Icon(Icons.lock, color: Colors.grey),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: SparshSpacing.md),
                    Text(
                      'Report Date',
                      style: SparshTypography.heading5.copyWith(color: SparshTheme.textPrimary),
                    ),
                    const SizedBox(height: SparshSpacing.sm),
                    TextFormField(
                      controller: _reportDateController,
                      readOnly: true,
                      onTap: _pickReportDate,
                      decoration: InputDecoration(
                        hintText: 'Select Report Date',
                        filled: true,
                        fillColor: SparshTheme.cardBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(SparshBorderRadius.sm),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: SparshSpacing.md, vertical: SparshSpacing.sm),
                        isCollapsed: true,
                        suffixIcon: const Icon(Icons.calendar_today, size: SparshIconSize.md),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ],
                ),
              ),

                              // ─── NEW: Activity Details Section ───────────────────────────────
                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: SparshSpacing.md),
                  padding: const EdgeInsets.all(SparshSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(SparshBorderRadius.sm),
                    boxShadow: SparshShadows.sm,
                  ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activity Details',
                      style: SparshTypography.heading5.copyWith(color: SparshTheme.textPrimary),
                    ),
                    const SizedBox(height: SparshSpacing.sm),
                    TextFormField(
                      controller: _activityDetails1Controller,
                      maxLines: 3,
                      decoration: _multilineDecoration.copyWith(
                        hintText: 'Activity Details 1',
                      ),
                      validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: SparshSpacing.md),
                    Text(
                      'Activity Details 2',
                      style: SparshTypography.heading5.copyWith(color: SparshTheme.textPrimary),
                    ),
                    const SizedBox(height: SparshSpacing.sm),
                    TextFormField(
                      controller: _activityDetails2Controller,
                      maxLines: 3,
                      decoration: _multilineDecoration.copyWith(
                        hintText: 'Activity Details 2',
                      ),
                    ),
                    const SizedBox(height: SparshSpacing.md),
                    Text(
                      'Activity Details 3',
                      style: SparshTypography.heading5.copyWith(color: SparshTheme.textPrimary),
                    ),
                    const SizedBox(height: SparshSpacing.sm),
                    TextFormField(
                      controller: _activityDetails3Controller,
                      maxLines: 3,
                      decoration: _multilineDecoration.copyWith(
                        hintText: 'Activity Details 3',
                      ),
                    ),
                    const SizedBox(height: SparshSpacing.md),
                    Text(
                      'Other Points',
                      style: SparshTypography.heading5.copyWith(color: SparshTheme.textPrimary),
                    ),
                    const SizedBox(height: SparshSpacing.sm),
                    TextFormField(
                      controller: _otherPointsController,
                      maxLines: 3,
                      decoration: _multilineDecoration.copyWith(
                        hintText: 'Other Points',
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Upload Supporting Documents ──────────────────────────────────
              

              // ─── Submit Button Card ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(SparshBorderRadius.sm),
                  boxShadow: SparshShadows.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _onSubmit(exitAfter: false),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Submit'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: SparshTheme.primaryBlueAccent,
                        elevation: 3.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(SparshBorderRadius.sm)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: SparshSpacing.md),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const DsrEntry())),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to DSR Entry'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: SparshTheme.primaryBlueAccent,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(SparshBorderRadius.sm),
                            side: const BorderSide(color: SparshTheme.primaryBlueAccent)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        elevation: 1.0,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
