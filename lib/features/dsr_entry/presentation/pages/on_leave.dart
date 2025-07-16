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

class OnLeave extends StatefulWidget {
  const OnLeave({super.key});
  @override
  State<OnLeave> createState() => _OnLeaveState();
}

class _OnLeaveState extends State<OnLeave> {
  final _formKey = GlobalKey<FormState>();

  // Geolocation
  Position? _currentPosition;

  // Add/Update process type state
  String? _processItem = 'Select';
  List<String> _processdropdownItems = ['Select'];
  bool _isLoadingProcessTypes = true;
  String? _processTypeError;

  // Document-number dropdown state
  bool _loadingDocs = false;
  List<String> _documentNumbers = [];
  String? _selectedDocuNumb;

  final TextEditingController _submissionDateController = TextEditingController();
  final TextEditingController _reportDateController     = TextEditingController();
  final TextEditingController _remarksController         = TextEditingController();

  List<File?> _selectedImages = [null];

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

  // Load document number when screen initializes
  Future<void> _loadInitialDocumentNumber() async {
    final savedDocNumber = await DocumentNumberStorage.loadDocumentNumber(DocumentNumberKeys.onLeave);
    if (savedDocNumber != null) {
      setState(() {
        _documentNumber = savedDocNumber;
      });
    }
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


  // Fetch process types from backend
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
        final processTypes = processTypesList.map<String>((type) {
          if (type is Map) {
            return type['Description']?.toString() ?? type['description']?.toString() ?? '';
          } else {
            return type.toString();
          }
        }).where((desc) => desc.isNotEmpty).toList();
        setState(() {
          _processdropdownItems = ['Select', ...processTypes];
          _processItem = 'Select';
          _isLoadingProcessTypes = false;
        });
      } else {
        setState(() {
          _processdropdownItems = ['Select'];
          _processItem = 'Select';
          _isLoadingProcessTypes = false;
          _processTypeError = 'Failed to load process types.';
        });
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

  // Fetch document numbers for Update
  Future<void> _fetchDocumentNumbers() async {
    setState(() {
      _loadingDocs = true;
      _documentNumbers = [];
      _selectedDocuNumb = null;
    });
    final uri = Uri.parse(
      'http://192.168.36.25/api/DsrTry/getDocumentNumbers?dsrParam=54' // Use correct param for this activity
    );
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

  // Fetch details for a document number and populate fields
  Future<void> _fetchAndPopulateDetails(String docuNumb) async {
    final uri = Uri.parse('http://192.168.36.25/api/DsrTry/getDsrEntry?docuNumb=$docuNumb');
    try {
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        setState(() {
          _remarksController.text = data['dsrRem01'] ?? '';
          if (data['SubmissionDate'] != null) {
            _submissionDateController.text = data['SubmissionDate'].toString().substring(0, 10);
          }
          if (data['ReportDate'] != null) {
            _reportDateController.text = data['ReportDate'].toString().substring(0, 10);
          }
        });
      }
    } catch (_) {}
  }

  void _setSubmissionDateToToday() {
    final today = DateTime.now();
    _submissionDateController.text = DateFormat('yyyy-MM-dd').format(today);
  }

  Future<void> _pickReportDate() async {
    final now = DateTime.now();
    final threeDaysAgo = now.subtract(const Duration(days: 3));
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
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
        _reportDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  void dispose() {
    _submissionDateController.dispose();
    _reportDateController.dispose();
    _remarksController.dispose();
    _documentNumberController.dispose();
    super.dispose();
  }

  // Update document number fetch to use selected code
  /*
  Future<String?> _fetchDocumentNumberFromServer() async {
    try {
      final url = Uri.parse('http://192.168.36.25/api/DsrTry/generateDocumentNumber');
      final areaCode = _processItem != null ? _processItem!['code'] : null;
      if (areaCode == null || areaCode.isEmpty) return null;
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(areaCode),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String? documentNumber;
        if (data is Map<String, dynamic>) {
          documentNumber = data['documentNumber'] ?? data['DocumentNumber'] ?? data['docNumber'] ?? data['DocNumber'];
        } else if (data is String) {
          documentNumber = data;
        }
        if (documentNumber != null) {
          await DocumentNumberStorage.saveDocumentNumber(DocumentNumberKeys.onLeave, documentNumber);
        }
        return documentNumber;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
  */

  Future<void> _pickImage(int index) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
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
        child: Image.file(imageFile, fit: BoxFit.contain),
      ),
    );
  }

  Future<void> submitDsrEntry(Map<String, dynamic> dsrData) async {
    print('Submitting DSR Data: $dsrData'); // DEBUG
    final url = Uri.parse('http://192.168.36.25/api/DsrTry');
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

  Future<void> _onSubmit({required bool exitAfter}) async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentPosition == null) {
      await _initGeolocation();
    }

    final dsrData = {
      'ActivityType': 'On Leave / Holiday / Off Day',
      'SubmissionDate': _submissionDateController.text,
      'ReportDate': _reportDateController.text,
      'dsrRem01': _remarksController.text,
      'latitude': _currentPosition?.latitude.toString() ?? '',
      'longitude': _currentPosition?.longitude.toString() ?? '',
      'DsrParam': '54',
      'DocuNumb': _processItem == 'Update' ? _selectedDocuNumb : null,
      'ProcessType': _processItem == 'Update' ? 'U' : 'A',
    };
    print('Prepared DSR Data: $dsrData'); // DEBUG

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
          _clearForm();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exception: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _clearForm() {
    setState(() {
      _processItem = 'Select';
      _submissionDateController.clear();
      _reportDateController.clear();
      _remarksController.clear();
      _selectedImages = [null];
    });
    _formKey.currentState!.reset();
  }

  // Add a method to reset the form (clear document number)
  void _resetForm() {
    setState(() {
      _documentNumber = null;
      _documentNumberController.clear();
      _processItem = null;
      // Clear other form fields as needed
    });
    DocumentNumberStorage.clearDocumentNumber(DocumentNumberKeys.onLeave); // Clear from persistent storage
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
        title: const Text('On Leave', style: TextStyle(color: Colors.white)),
        backgroundColor: SparshTheme.primaryBlueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(SparshSpacing.md),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildLabel('Process type'),
              if (_processTypeError != null)
                Text(_processTypeError!, style: const TextStyle(color: Colors.red)),
              _isLoadingProcessTypes
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : DropdownButtonFormField<String>(
                    value: _processItem,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: SparshTheme.cardBackground,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(SparshBorderRadius.md), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: SparshSpacing.sm, vertical: SparshSpacing.sm),
                    ),
                    items: _processdropdownItems.map((it) => DropdownMenuItem(value: it, child: Text(it))).toList(),
                    onChanged: (val) async {
                      setState(() {
                        _processItem = val;
                      });
                      if (val == 'Update') await _fetchDocumentNumbers();
                    },
                    validator: (v) => v == null || v == 'Select' ? 'Required' : null,
                  ),
              if (_processItem == 'Update') ...[
                const SizedBox(height: 8.0),
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
                        if (v != null) await _fetchAndPopulateDetails(v);
                      },
                      validator: (v) => v == null ? 'Required' : null,
                    ),
              ],
              const SizedBox(height: SparshSpacing.sm),
              _buildLabel('Submission Date'),
              TextFormField(
                controller: _submissionDateController,
                readOnly: true,
                enabled: false,
                decoration: InputDecoration(
                  hintText: 'Submission Date',
                  filled: true,
                  fillColor: SparshTheme.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SparshBorderRadius.md),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: const Icon(Icons.lock, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(horizontal: SparshSpacing.sm, vertical: SparshSpacing.sm),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
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
                  fillColor: SparshTheme.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SparshBorderRadius.md),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: const Icon(Icons.calendar_today),
                  contentPadding: const EdgeInsets.symmetric(horizontal: SparshSpacing.sm, vertical: SparshSpacing.sm),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: SparshSpacing.sm),
              _buildLabel('Remarks'),
              _buildTextField(
                'Enter Remarks',
                controller: _remarksController,
                maxLines: 3,
              ),
              const SizedBox(height: SparshSpacing.sm),
              _buildLabel('Upload Images'),
              ...List.generate(_selectedImages.length, (i) {
                final file = _selectedImages[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: SparshSpacing.md),
                  padding: const EdgeInsets.all(SparshSpacing.sm),
                  decoration: BoxDecoration(
                    color: SparshTheme.cardBackground,
                    borderRadius: BorderRadius.circular(SparshBorderRadius.md),
                    border: Border.all(
                      color: file != null ? SparshTheme.successGreen : SparshTheme.borderGrey,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Document ${i + 1}',
                            style: SparshTypography.bodyBold,
                          ),
                          const Spacer(),
                          if (file != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: SparshSpacing.sm, vertical: 3),
                              decoration: BoxDecoration(
                                color: SparshTheme.successGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(SparshBorderRadius.xl),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle, color: SparshTheme.successGreen, size: 16),
                                  const SizedBox(width: SparshSpacing.xs),
                                  Text(
                                    'Uploaded',
                                    style: SparshTypography.labelMedium.copyWith(
                                      color: SparshTheme.successGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _pickImage(i),
                              icon: Icon(file != null ? Icons.refresh : Icons.upload_file, size: 18),
                              label: Text(file != null ? 'Replace' : 'Upload'),
                            ),
                          ),
                          if (file != null) ...[
                            const SizedBox(width: SparshSpacing.sm),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showImageDialog(file),
                                icon: const Icon(Icons.visibility, size: 18),
                                label: const Text('View'),
                                style: ElevatedButton.styleFrom(backgroundColor: SparshTheme.successGreen),
                              ),
                            ),
                            const SizedBox(width: SparshSpacing.sm),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectedImages.removeAt(i);
                                });
                              },
                              icon: const Icon(Icons.remove_circle_outline, color: SparshTheme.errorRed),
                            ),
                          ]
                        ],
                      ),
                    ],
                  ),
                );
              }),
              if (_selectedImages.length < 3)
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedImages.add(null);
                      });
                    },
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Add More Image'),
                  ),
                ),
              const SizedBox(height: SparshSpacing.lg),
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

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Text(
      text,
      style: SparshTypography.bodyBold.copyWith(color: SparshTheme.textPrimary),
    ),
  );

  Widget _buildTextField(
      String hint, {
        TextEditingController? controller,
        TextInputType? keyboardType,
        int maxLines = 1,
      }) =>
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(SparshBorderRadius.md)),
          contentPadding: const EdgeInsets.symmetric(horizontal: SparshSpacing.sm, vertical: SparshSpacing.sm),
        ),
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
      );

  // Update dropdown field to use new structure
  Widget _buildDropdownField({
    required Map<String, String>? value,
    required List<Map<String, String>> items,
    required ValueChanged<Map<String, String>?> onChanged,
    bool enabled = true,
  }) =>
      Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SparshBorderRadius.md),
          border: Border.all(color: SparshTheme.borderGrey, width: 1),
          color: SparshTheme.cardBackground,
        ),
        child: DropdownButton<Map<String, String>>(
          isExpanded: true,
          value: value,
          underline: Container(),
          hint: const Text('Select'),
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(item['description'] ?? ''),
          )).toList(),
          onChanged: enabled ? onChanged : null,
        ),
      );

  Widget _buildDateField(TextEditingController controller, VoidCallback onTap, String hint) =>
      TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: IconButton(icon: const Icon(Icons.calendar_today), onPressed: onTap),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(SparshBorderRadius.md)),
          contentPadding: const EdgeInsets.symmetric(horizontal: SparshSpacing.sm, vertical: SparshSpacing.sm),
        ),
        onTap: onTap,
        validator: (val) => val == null || val.isEmpty ? 'Select date' : null,
      );
}
