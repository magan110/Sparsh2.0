import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/document_number_storage.dart';
import 'dsr_entry.dart';
import 'dsr_exception_entry.dart';

class BtlActivities extends StatefulWidget {
  const BtlActivities({super.key});

  @override
  State<BtlActivities> createState() => _BtlActivitiesState();
}

class _BtlActivitiesState extends State<BtlActivities> {
  // ─── State & Controllers ────────────────────────────────────────────────────
  String? _processItem = 'Select';
  List<String> _processItems = ['Select'];
  bool _isLoadingProcessTypes = true;
  String? _processTypeError;

  String? _activityTypeItem = 'Select';
  List<String> _activityTypes = ['Select'];
  bool _isLoadingActivityTypes = true;
  String? _activityTypeError;

  final _dateController       = TextEditingController();
  final _reportDateController = TextEditingController();
  DateTime? _selectedDate;
  DateTime? _selectedReportDate;

  final _participantsController = TextEditingController();
  final _townController         = TextEditingController();
  final _learningsController    = TextEditingController();

  final List<XFile?> _selectedImages = [null];
  final _picker               = ImagePicker();

  final _documentNumberController = TextEditingController();
  String? _documentNumber;

  Position? _currentPosition;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadInitialDocumentNumber();
    _fetchProcessTypes();
    _fetchActivityTypes();
    _initDate();
    _getCurrentLocation();
  }

  void _initDate() {
    final today = DateTime.now();
    _dateController.text = DateFormat('yyyy-MM-dd').format(today);
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services disabled.');
      }
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
      // You might want to show a Snackbar or fallback if location fails
      debugPrint('Error getting location: $e');
    }
  }

  // Load document number when screen initializes
  Future<void> _loadInitialDocumentNumber() async {
    final savedDocNumber = await DocumentNumberStorage.loadDocumentNumber(DocumentNumberKeys.btlActivities);
    if (savedDocNumber != null) {
      setState(() {
        _documentNumber = savedDocNumber;
      });
    }
  }



Future<void> _fetchProcessTypes() async {
  setState(() {
    _isLoadingProcessTypes = true;
    _processTypeError = null;
  });

  const cacheKey = 'processTypesCache';
  List<String>? freshList;

  try {
    final url = Uri.parse('http://192.168.36.25/api/DsrTry/getProcessTypes');
    final response = await http
        .get(url)
        .timeout(const Duration(seconds: 10)); // guard against hanging
    if (response.statusCode != 200) {
      throw Exception('Status code ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    if (data is! List) {
      throw Exception('Unexpected payload');
    }

    // parse either "description" or "Description"
    freshList = data.whereType<Map<String, dynamic>>().map((type) {
      final desc = type['description'] ?? type['Description'];
      return desc?.toString().trim() ?? '';
    }).where((s) => s.isNotEmpty).toList();

    if (freshList.isEmpty) {
      throw Exception('No process types returned');
    }

    // cache to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(cacheKey, freshList);

  } catch (e) {
    // on any error, try to load from cache
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getStringList(cacheKey);

    if (cached != null && cached.isNotEmpty) {
      freshList = List.from(cached);
    } else {
      // no cache → real failure
      setState(() {
        _processItems = ['Select'];
        _isLoadingProcessTypes = false;
        _processTypeError = 'Failed to load process types: ${e.toString()}';
      });
      return;
    }
  }

  // success (fresh or cached)
  setState(() {
    _processItems = ['Select', ...freshList!];
    _isLoadingProcessTypes = false;
    _processTypeError = null;
  });
}
  Future<void> _fetchActivityTypes() async {
    setState(() { _isLoadingActivityTypes = true; _activityTypeError = null; });
    try {
      final url = Uri.parse('http://192.168.36.25/api/DsrTry/getBtlActivityTypes');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final activityTypes = (data is List ? data : <String>[]).map((e) => e.toString()).toList();
        setState(() {
          _activityTypes = ['Select', ...activityTypes];
          _isLoadingActivityTypes = false;
        });
      } else {
        setState(() {
          _activityTypes = ['Select'];
          _isLoadingActivityTypes = false;
          _activityTypeError = 'Failed to load activity types.';
        });
      }
    } catch (e) {
      setState(() {
        _activityTypes = ['Select'];
        _isLoadingActivityTypes = false;
        _activityTypeError = 'Failed to load activity types.';
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _reportDateController.dispose();
    _participantsController.dispose();
    _townController.dispose();
    _learningsController.dispose();
    _documentNumberController.dispose();
    super.dispose();
  }

  // Document number generation is now handled entirely by the backend API

  // Method to fetch document number from server using the simplified endpoint
  Future<String?> _fetchDocumentNumberFromServer() async {
    try {
      final url = Uri.parse('http://192.168.36.25/api/DsrTry/generateDocumentNumber');
      
      print('🔍 Calling API: $url');
      print('📤 Request body: "KKR" (hardcoded area code)');
      
      // Send only the area code as a simple string
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode('KKR'), // Hardcoded to KKR
      );
      
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('📋 Parsed data: $data');
        
        // Try different possible field names for document number
        String? documentNumber;
        if (data is Map<String, dynamic>) {
          documentNumber = data['documentNumber'] ?? data['DocumentNumber'] ?? data['docNumber'] ?? data['DocNumber'];
        } else if (data is String) {
          documentNumber = data;
        }
        
        print('📄 Extracted document number: $documentNumber');
        
        // Save to persistent storage
        if (documentNumber != null) {
          await DocumentNumberStorage.saveDocumentNumber(DocumentNumberKeys.btlActivities, documentNumber);
        }
        
        return documentNumber;
      } else {
        print('❌ API call failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error calling API: $e');
      return null;
    }
  }

  Future<void> _pickDate(
    TextEditingController ctrl,
    DateTime? initial,
    ValueChanged<DateTime> onSelected, {
    bool isReportDate = false,
  }) async {
    final now = DateTime.now();
    final threeDaysAgo = now.subtract(const Duration(days: 3));
    final firstDate = isReportDate 
        ? DateTime(now.year - 10)
        : DateTime(2000);
    final lastDate = isReportDate 
        ? now
        : DateTime(now.year + 5);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      if (isReportDate && picked.isBefore(threeDaysAgo)) {
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

    Future<void> _onSubmit(bool exitAfter) async {
    if (!_formKey.currentState!.validate()) return;

    // ensure we have a position before submitting
    if (_currentPosition == null) {
      await _getCurrentLocation();
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Submitting form...'),
          backgroundColor: Colors.blue,
        ),
      );

      final submissionData = {
        'ActivityType': 'BTL Activities',
        'SubmissionDate': _selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'ReportDate': _selectedReportDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'dsrRem01': _activityTypeItem ?? '',
        'dsrRem02': _participantsController.text,
        'dsrRem03': _townController.text,
        'dsrRem04': _learningsController.text,
        'dsrRem05': '',
        'dsrRem06': '',
        'dsrRem07': '',
        'dsrRem08': '',
        // include live coords:
        'latitude': _currentPosition?.latitude.toString()  ?? '',
        'longitude': _currentPosition?.longitude.toString() ?? '',
      };

      final url = Uri.parse('http://192.168.36.25/api/DsrTry');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(submissionData),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              exitAfter
                  ? 'Form submitted successfully. Exiting...'
                  : 'Form submitted successfully. Ready for new entry.',
            ),
            backgroundColor: SparshTheme.successGreen,
          ),
        );

        if (exitAfter) {
          Navigator.of(context).pop();
        } else {
          _formKey.currentState!.reset();
          setState(() {
            _processItem = 'Select';
            _activityTypeItem = 'Select';
            _dateController.clear();
            _reportDateController.clear();
            _selectedDate = null;
            _selectedReportDate = null;
            _participantsController.clear();
            _townController.clear();
            _learningsController.clear();
            _documentNumber = null;
            _documentNumberController.clear();
            _selectedImages
              ..clear()
              ..add(null);
          });
        }
      } else {
        throw Exception('Failed to submit form: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Submission failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
    bool enabled = true,
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
        onChanged: enabled ? onChanged : null,
        validator: validator,
      );

  Widget _buildDateField(
          TextEditingController ctrl,
          VoidCallback onTap,
          String hint,
          String? Function(String?)? validator) =>
      TextFormField(
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
        title: const Text('BTL Activities'),
        backgroundColor: SparshTheme.primaryBlueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SparshSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Process Section ───────────────────────────────
              _sectionContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Process Type'),
                    const SizedBox(height: SparshSpacing.sm),
                    if (_processTypeError != null)
                      Text(_processTypeError!, style: const TextStyle(color: Colors.red)),
                    _isLoadingProcessTypes
                        ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                        : _buildDropdown(
                            value: _processItem,
                            items: _processItems,
                            onChanged: (val) async {
                              setState(() {
                                _processItem = val;
                              });
                              
                              if (val == "Update") {
                                // Only generate document number if we don't already have one
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
                            validator: (v) => (v == null || v == 'Select') ? 'Required' : null,
                            enabled: _processItems.length > 1,
                          ),
                    if (_processItem == "Update")
                      Padding(
                        padding: const EdgeInsets.only(top: SparshSpacing.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _documentNumberController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: "Document Number",
                                filled: true,
                                fillColor: SparshTheme.lightGreyBackground,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(SparshBorderRadius.sm),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: SparshSpacing.sm),
                            
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: SparshSpacing.md),

              // ── Date Section ─────────────────────────────────
              _sectionContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Submission Date'),
                    const SizedBox(height: SparshSpacing.xs),
                    TextFormField(
                      controller: _dateController,
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
                        suffixIcon: const Icon(Icons.lock, color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: SparshSpacing.md,
                          vertical: SparshSpacing.sm,
                        ),
                      ),
                    ),
                    const SizedBox(height: SparshSpacing.sm),
                    _buildLabel('Report Date'),
                    const SizedBox(height: SparshSpacing.xs),
                    _buildDateField(
                      _reportDateController,
                      () => _pickDate(
                        _reportDateController,
                        _selectedReportDate,
                        (d) => _selectedReportDate = d,
                        isReportDate: true,
                      ),
                      'Select Date',
                      (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SparshSpacing.md),

              // ── BTL Activity Details ─────────────────────────
              _sectionContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Type Of Activity'),
                    const SizedBox(height: SparshSpacing.sm),
                    if (_activityTypeError != null)
                      Text(_activityTypeError!, style: const TextStyle(color: Colors.red)),
                    _isLoadingActivityTypes
                        ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                        : _buildDropdown(
                            value: _activityTypeItem,
                            items: _activityTypes,
                            onChanged: (v) => setState(() => _activityTypeItem = v),
                            validator: (v) => (v == null || v == 'Select') ? 'Required' : null,
                            enabled: _activityTypes.length > 1,
                          ),
                    const SizedBox(height: SparshSpacing.sm),
                    _buildLabel('No. Of Participants'),
                    const SizedBox(height: SparshSpacing.xs),
                    _buildTextField(
                      'Enter number of participants',
                      _participantsController,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (int.tryParse(v) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: SparshSpacing.sm),
                    _buildLabel('Town in Which Activity Conducted'),
                    const SizedBox(height: SparshSpacing.xs),
                    _buildTextField(
                      'Enter town',
                      _townController,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: SparshSpacing.sm),
                    _buildLabel('Learnings From Activity'),
                    const SizedBox(height: SparshSpacing.xs),
                    _buildTextField(
                      'Enter your learnings',
                      _learningsController,
                      maxLines: 3,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SparshSpacing.md),

              // ── Supporting Documents ─────────────────────────
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
                    const Text(
                      'Upload up to 3 images related to your activity',
                      style: SparshTypography.body,
                    ),
                    const SizedBox(height: SparshSpacing.sm),
                    ...List.generate(
                      _selectedImages.length,
                      (idx) => _buildImageRow(idx),
                    ),
                    if (_selectedImages.length < 3) ...[
                      Center(
                        child: TextButton.icon(
                          onPressed: _addImageField,
                          icon: const Icon(Icons.add_photo_alternate),
                          label: const Text('Add More Image'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: SparshSpacing.lg),

              // ── Submit Buttons ───────────────────────────────
              ElevatedButton(
                onPressed: () => _onSubmit(false),
                child: const Text('Submit & New'),
              ),
              const SizedBox(height: SparshSpacing.sm),
              ElevatedButton(
                onPressed: () => _onSubmit(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SparshTheme.successGreen,
                ),
                child: const Text('Submit & Exit'),
              ),

            ],
          ),
        ),
      ),
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
    DocumentNumberStorage.clearDocumentNumber(DocumentNumberKeys.btlActivities); // Clear from persistent storage
  }
}
