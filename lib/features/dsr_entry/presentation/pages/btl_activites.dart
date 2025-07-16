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
  // 1) CONTROLLERS for dropdowns and dates
  String? _processItem = 'Select';
  List<String> _processdropdownItems = ['Select'];
  bool _isLoadingProcessTypes = true;
  String? _processTypeError;

  // NEW: Document-number dropdown state
  bool _loadingDocs = false;
  List<String> _documentNumbers = [];
  String? _selectedDocuNumb;

  // Geolocation
  Position? _currentPosition;

  final _dateController       = TextEditingController();
  final _reportDateController = TextEditingController();
  DateTime? _selectedDate;
  DateTime? _selectedReportDate;

  // 2) CONTROLLERS for activity text fields
  final _participantsController = TextEditingController();
  final _townController         = TextEditingController();
  final _learningsController    = TextEditingController();
  String? _activityTypeItem = 'Select';
  List<String> _activityTypes = ['Select'];
  bool _isLoadingActivityTypes = true;
  String? _activityTypeError;

  // 3) IMAGE UPLOAD state (up to 3)
  final List<XFile?> _selectedImages = [null];
  final _picker = ImagePicker();

  // 4) Document-number persistence
  final _documentNumberController = TextEditingController();
  String? _documentNumber;

  // 5) Config: dsrParam for this activity
  String param = '51';

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initGeolocation();
    _loadInitialDocumentNumber();
    _fetchProcessTypes();
    _fetchActivityTypes();
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

  // Load any saved document number
  Future<void> _loadInitialDocumentNumber() async {
    final saved = await DocumentNumberStorage.loadDocumentNumber(DocumentNumberKeys.btlActivities);
    if (saved != null) {
      setState(() {
        _documentNumber = saved;
        _documentNumberController.text = saved;
      });
    }
  }

  Future<void> _fetchProcessTypes() async {
    setState(() {
      _isLoadingProcessTypes = true;
      _processTypeError = null;
    });
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
        final processTypes = processTypesList
            .map<String>((type) {
              if (type is Map) {
                return type['Description']?.toString() ?? type['description']?.toString() ?? '';
              } else {
                return type.toString();
              }
            })
            .where((desc) => desc.isNotEmpty)
            .toList();
        setState(() {
          _processdropdownItems = ['Select', ...processTypes];
          _processItem = 'Select';
          _isLoadingProcessTypes = false;
        });
      } else {
        throw Exception('Failed to load process types.');
      }
    } catch (e) {
      setState(() {
        _processdropdownItems = ['Select'];
        _processItem = 'Select';
        _isLoadingProcessTypes = false;
        _processTypeError = 'Failed to load process types.';
      });
    }
  }

  // Fetch docuNumb list when Update selected
  Future<void> _fetchDocumentNumbers() async {
    setState(() {
      _loadingDocs = true;
      _documentNumbers = [];
      _selectedDocuNumb = null;
    });
    final uri = Uri.parse('http://192.168.36.25/api/DsrTry/getDocumentNumbers?dsrParam=$param');
    try {
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as List;
        setState(() {
          _documentNumbers = data
            .map((e) {
              return (e['DocuNumb']
                   ?? e['docuNumb']
                   ?? e['DocumentNumber']
                   ?? e['documentNumber']
                   ?? '').toString();
            })
            .where((s) => s.isNotEmpty)
            .toList();
        });
      }
    } catch (_) {
      // ignore errors
    } finally {
      setState(() { _loadingDocs = false; });
    }
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

  // Fetch details for a selected document number and populate form fields
  Future<void> _fetchDocumentDetails(String docuNumb) async {
    final url = Uri.parse('http://192.168.36.25/api/DsrTry/getDocumentDetails?docuNumb=$docuNumb');
    try {
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        setState(() {
          _activityTypeItem = data['dsrRem01'] ?? 'Select';
          _participantsController.text = data['dsrRem02'] ?? '';
          _townController.text = data['dsrRem03'] ?? '';
          _learningsController.text = data['dsrRem04'] ?? '';
          _selectedDate = DateTime.tryParse(data['SubmissionDate'] ?? '') ?? DateTime.now();
          _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
          _selectedReportDate = DateTime.tryParse(data['ReportDate'] ?? '') ?? DateTime.now();
          _reportDateController.text = DateFormat('yyyy-MM-dd').format(_selectedReportDate!);
        });
      }
    } catch (e) {
      print('Error fetching document details: $e');
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

  // DATE PICKERS
  void _setSubmissionDateToToday() {
    final today = DateTime.now();
    _selectedDate = today;
    _dateController.text = DateFormat('yyyy-MM-dd').format(today);
  }

  Future<void> _pickReportDate() async {
    final now = DateTime.now();
    final threeDaysAgo = now.subtract(const Duration(days: 3));
    final pick = await showDatePicker(
      context: context,
      initialDate: _selectedReportDate ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
    );
    if (pick != null) {
      if (pick.isBefore(threeDaysAgo)) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Invalid DSR Date'),
            content: const Text(
              'You can only submit up to 3 days back. Use Exception Entry for older dates.'
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
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
        _selectedReportDate = pick;
        _reportDateController.text = DateFormat('yyyy-MM-dd').format(pick);
      });
    }
  }

  // IMAGE PICKER
  Future<void> _pickImage(int idx) async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _selectedImages[idx] = file);
  }

  void _showImageDialog(XFile file) {
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

  void _addRow() {
    if (_selectedImages.length < 3) {
      setState(() {
        _selectedImages.add(null);
      });
    }
  }

  void _removeRow(int idx) {
    if (_selectedImages.length > 1) {
      setState(() {
        _selectedImages.removeAt(idx);
      });
    }
  }

  // SUBMIT / UPDATE
  Future<void> _onSubmit({required bool exitAfter}) async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentPosition == null) await _initGeolocation();

    final dsrData = {
      'ActivityType':   'BTL Activities',
      'SubmissionDate': _selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'ReportDate':     _selectedReportDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'dsrRem01':       _activityTypeItem ?? '',
      'dsrRem02':       _participantsController.text,
      'dsrRem03':       _townController.text,
      'dsrRem04':       _learningsController.text,
      'latitude':       _currentPosition?.latitude.toString() ?? '',
      'longitude':      _currentPosition?.longitude.toString() ?? '',
      'DsrParam':       param,
      'DocuNumb':       _processItem == 'Update' ? _selectedDocuNumb : null,
      'ProcessType':    _processItem == 'Update' ? 'U' : 'A',
      'CreateId':       '2948',
    };

    try {
      final url = Uri.parse(
        'http://192.168.36.25/api/DsrTry/' + (_processItem == 'Update' ? 'update' : '')
      );
      final resp = _processItem == 'Update'
          ? await http.put(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(dsrData),
            )
          : await http.post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(dsrData),
            );

      final success = (_processItem == 'Update' && resp.statusCode == 204) ||
                      (_processItem != 'Update' && resp.statusCode == 201);

      if (!success) {
        print('Error submitting DSR: Status ${resp.statusCode}\nBody: ${resp.body}');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? exitAfter
                  ? '${_processItem == 'Update' ? 'Updated' : 'Submitted'} successfully. Exiting...'
                  : '${_processItem == 'Update' ? 'Updated' : 'Submitted'} successfully. Ready for new entry.'
              : 'Error: ${resp.body}'),
          backgroundColor: success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (success) {
        if (exitAfter) {
          Navigator.of(context).pop();
        } else {
          _formKey.currentState!.reset();
          setState(() {
            _processItem = 'Select';
            _selectedDocuNumb = null;
            _dateController.clear();
            _reportDateController.clear();
            _selectedDate = null;
            _selectedReportDate = null;
            _activityTypeItem = 'Select';
            _participantsController.clear();
            _townController.clear();
            _learningsController.clear();
            _selectedImages
              ..clear()
              ..add(null);
          });
        }
      }
    } catch (e) {
      print('Exception during submit: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exception: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
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
    String hint, {
    String? Function(String?)? validator,
  }) =>
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
                onPressed: () => _showImageDialog(file),
                icon: const Icon(Icons.visibility),
                label: const Text('View'),
              ),
            const Spacer(),
            if (_selectedImages.length > 1 && idx == _selectedImages.length - 1)
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: SparshTheme.errorRed),
                onPressed: () => _removeRow(idx),
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
              // ── Activity Information ───────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: SparshTheme.cardBackground,
                  borderRadius: BorderRadius.circular(SparshBorderRadius.md),
                  boxShadow: SparshShadows.card,
                ),
                padding: const EdgeInsets.all(SparshSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Activity Information'),
                    const SizedBox(height: SparshSpacing.sm),
                    _buildLabel('Process Type'),
                    if (_processTypeError != null)
                      Text(_processTypeError!, style: const TextStyle(color: Colors.red)),
                    _isLoadingProcessTypes
                      ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                      : _buildDropdown(
                          value: _processItem,
                          items: _processdropdownItems,
                          onChanged: (val) async {
                            setState(() => _processItem = val);
                            if (val == 'Update') await _fetchDocumentNumbers();
                          },
                          validator: (v) => v == null || v == 'Select' ? 'Required' : null,
                          enabled: _processdropdownItems.length > 1,
                        ),
                    if (_processItem == 'Update') ...[
                      const SizedBox(height: SparshSpacing.sm),
                      _loadingDocs
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownButtonFormField<String>(
                            value: _selectedDocuNumb,
                            decoration: const InputDecoration(labelText: 'Document Number'),
                            items: _documentNumbers
                                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                                .toList(),
                            onChanged: (v) async {
                              setState(() => _selectedDocuNumb = v);
                              if (v != null && v.isNotEmpty) {
                                await _fetchDocumentDetails(v);
                              }
                            },
                            validator: (v) => v == null ? 'Required' : null,
                          ),
                    ],
                    const SizedBox(height: SparshSpacing.sm),
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
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: SparshSpacing.sm),
                    _buildLabel('Report Date'),
                    _buildDateField(
                      _reportDateController,
                      () => _pickReportDate(),
                      'Select Date',
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: SparshSpacing.md),

              // ── Activity Details ───────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: SparshTheme.cardBackground,
                  borderRadius: BorderRadius.circular(SparshBorderRadius.md),
                  boxShadow: SparshShadows.card,
                ),
                padding: const EdgeInsets.all(SparshSpacing.md),
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
              Container(
                decoration: BoxDecoration(
                  color: SparshTheme.cardBackground,
                  borderRadius: BorderRadius.circular(SparshBorderRadius.md),
                  boxShadow: SparshShadows.card,
                ),
                padding: const EdgeInsets.all(SparshSpacing.md),
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
                          onPressed: _addRow,
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
                onPressed: () => _onSubmit(exitAfter: false),
                child: Text(_processItem == 'Update' ? 'Update & New' : 'Submit & New'),
              ),
              const SizedBox(height: SparshSpacing.sm),
              ElevatedButton(
                onPressed: () => _onSubmit(exitAfter: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SparshTheme.successGreen,
                ),
                child: Text(_processItem == 'Update' ? 'Update & Exit' : 'Submit & Exit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
