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

class InternalTeamMeeting extends StatefulWidget {
  const InternalTeamMeeting({super.key});

  @override
  State<InternalTeamMeeting> createState() => _InternalTeamMeetingState();
}

class _InternalTeamMeetingState extends State<InternalTeamMeeting> {
  // Geolocation
  Position? _currentPosition;

  // Process type dropdown state
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

  final TextEditingController _meetwithController = TextEditingController();
  final TextEditingController _meetdiscController  = TextEditingController();
  final TextEditingController _learnnngController  = TextEditingController();

  final List<int> _uploadRows = [0];
  final ImagePicker _picker = ImagePicker();
  final List<List<String>> _selectedImagePaths = [[]]; // multiple per row

  final _documentNumberController = TextEditingController();
  String? _documentNumber;

  final _formKey = GlobalKey<FormState>();

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
    final savedDocNumber = await DocumentNumberStorage.loadDocumentNumber(DocumentNumberKeys.internalTeamMeeting);
    if (savedDocNumber != null) {
      setState(() {
        _documentNumber = savedDocNumber;
      });
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
        } else if (data is Map &&
            (data['ProcessTypes'] != null || data['processTypes'] != null)) {
          processTypesList =
              (data['ProcessTypes'] ?? data['processTypes']) as List;
        }
        final processTypes = processTypesList
            .map<String>((type) {
              if (type is Map) {
                return type['Description']?.toString() ??
                    type['description']?.toString() ??
                    '';
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

  // Fetch document numbers for Update
  Future<void> _fetchDocumentNumbers() async {
    setState(() {
      _loadingDocs = true;
      _documentNumbers = [];
      _selectedDocuNumb = null;
    });
    final uri = Uri.parse(
      'http://192.168.36.25/api/DsrTry/getDocumentNumbers?dsrParam=52' // Use correct param for this activity
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
          _meetwithController.text = data['dsrRem01'] ?? '';
          _meetdiscController.text = data['dsrRem02'] ?? '';
          _learnnngController.text = data['dsrRem03'] ?? '';
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
      initialDate: DateTime.now(),
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
    _meetwithController.dispose();
    _meetdiscController.dispose();
    _learnnngController.dispose();
    _documentNumberController.dispose();
    super.dispose();
  }

  void _addRow() {
    setState(() {
      _uploadRows.add(_uploadRows.length);
      _selectedImagePaths.add([]);
    });
  }

  void _removeRow() {
    if (_uploadRows.length <= 1) return;
    setState(() {
      _uploadRows.removeLast();
      _selectedImagePaths.removeLast();
    });
  }

  Future<void> _pickImages(int rowIndex) async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImagePaths[rowIndex] = pickedFiles.map((e) => e.path).toList();
      });
    }
  }

  void _showImagesDialog(int rowIndex) {
    final paths = _selectedImagePaths[rowIndex];
    if (paths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No images selected for this row to view.')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Selected Images',
                style: SparshTypography.heading2.copyWith(color: SparshTheme.primaryBlueAccent),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                width: double.maxFinite,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: paths.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Image.file(File(paths[i]), height: 180, width: 180, fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(foregroundColor: SparshTheme.primaryBlueAccent),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // SUBMIT / UPDATE
  Future<void> _onSubmit({required bool exitAfter}) async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentPosition == null) await _initGeolocation();

    final dsrData = {
      'ActivityType': 'Internal Team Meetings / Review Meetings',
      'SubmissionDate': _submissionDateController.text,
      'ReportDate': _reportDateController.text,
      'dsrRem01': _meetwithController.text,
      'dsrRem02': _meetdiscController.text,
      'dsrRem03': _learnnngController.text,
      'latitude': _currentPosition?.latitude.toString() ?? '',
      'longitude': _currentPosition?.longitude.toString() ?? '',
      'DsrParam': '52',
      'DocuNumb': _processItem == 'Update' ? _selectedDocuNumb : null,
      'ProcessType': _processItem == 'Update' ? 'U' : 'A',
      'CreateId': '2948',
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
        print('Error submitting DSR: Status \u001b[33m\u001b[1m${resp.statusCode}\u001b[0m\nBody: ${resp.body}');
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
            _submissionDateController.clear();
            _reportDateController.clear();
            _meetwithController.clear();
            _meetdiscController.clear();
            _learnnngController.clear();
            _uploadRows
              ..clear()
              ..add(0);
            _selectedImagePaths
              ..clear()
              ..add([]);
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

  Future<String?> _fetchDocumentNumberFromServer() async {
    try {
      final url = Uri.parse('http://192.168.36.25/api/DsrTry/generateDocumentNumber');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'areaCode': _processItem == 'Update' ? _selectedDocuNumb : null}),
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
          await DocumentNumberStorage.saveDocumentNumber(DocumentNumberKeys.internalTeamMeeting, documentNumber);
        }
        
        return documentNumber;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Add a method to reset the form (clear document number)
  void _resetForm() {
    setState(() {
      _documentNumber = null;
      _documentNumberController.clear();
      // Clear other form fields as needed
    });
    DocumentNumberStorage.clearDocumentNumber(DocumentNumberKeys.internalTeamMeeting); // Clear from persistent storage
  }

  void _onProcessTypeChanged(String? desc) {
    setState(() {
      // _selectedProcessTypeDescription = desc; // This line is removed
      // final selected = _processTypes.firstWhere( // This line is removed
      //   (item) => item['description'] == desc, // This line is removed
      //   orElse: () => {'code': '', 'description': ''}, // This line is removed
      // ); // This line is removed
      // _selectedProcessTypeCode = selected['code']; // This line is removed
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
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
        ),
        title: Text(
          'Internal Team Meeting',
          style: SparshTypography.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: SparshTheme.primaryBlue,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Process Type
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_processTypeError != null)
                        Text(_processTypeError!, style: const TextStyle(color: Colors.red)),
                      _isLoadingProcessTypes
                        ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                        : DropdownButtonFormField<String>(
                            value: _processItem,
                            decoration: InputDecoration(
                              labelText: "Process Type",
                              filled: true,
                              fillColor: SparshTheme.lightGreyBackground,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            items: _processdropdownItems.map((it) => DropdownMenuItem(value: it, child: Text(it))).toList(),
                            onChanged: (val) async {
                              setState(() => _processItem = val);
                              if (val == 'Update') await _fetchDocumentNumbers();
                            },
                            validator: (val) => (val == null || val == 'Select') ? 'Please select a process' : null,
                          ),
                      if (_processItem == "Update") ...[
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
                    ],
                  ),
                ),
              ),

              // Dates
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _submissionDateController,
                        readOnly: true,
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'Submission Date',
                          filled: true,
                          fillColor: SparshTheme.lightGreyBackground,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          suffixIcon: const Icon(Icons.lock, color: Colors.grey),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        validator: (val) => (val == null || val.isEmpty) ? 'Please select submission date' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _reportDateController,
                        readOnly: true,
                        onTap: _pickReportDate,
                        decoration: InputDecoration(
                          labelText: 'Report Date',
                          filled: true,
                          fillColor: SparshTheme.lightGreyBackground,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          suffixIcon: const Icon(Icons.calendar_today),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        validator: (val) => (val == null || val.isEmpty) ? 'Please select report date' : null,
                      ),
                    ],
                  ),
                ),
              ),

              // Text fields
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextFormField(
                  controller: _meetwithController,
                  decoration: InputDecoration(
                    labelText: 'Meeting With Whom (required)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Enter Meetwith' : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextFormField(
                  controller: _meetdiscController,
                  decoration: InputDecoration(
                    labelText: 'Meeting Discussion Points (required)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  maxLines: 3,
                  validator: (v) => v == null || v.isEmpty ? 'Enter Meetdisc' : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextFormField(
                  controller: _learnnngController,
                  decoration: InputDecoration(
                    labelText: 'Learnings (required)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  maxLines: 3,
                  validator: (v) => v == null || v.isEmpty ? 'Enter Learnnng' : null,
                ),
              ),

              // Image upload section
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SparshTheme.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))],
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.photo_library_rounded, color: Color(0xFF2196F3), size: 24),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Supporting Documents',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Upload images related to your activity', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                    const SizedBox(height: 16),
                    ...List.generate(_uploadRows.length, (index) {
                      final paths = _selectedImagePaths[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: SparshTheme.lightGreyBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: paths.isNotEmpty ? Colors.green.shade200 : Colors.grey.shade200, width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                  child: Text('Document ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 33, 150, 243), fontSize: 14)),
                                ),
                                const Spacer(),
                                if (paths.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(20)),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                                        SizedBox(width: 4),
                                        Text('Uploaded', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500, fontSize: 14)),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (paths.isNotEmpty)
                              GestureDetector(
                                onTap: () => _showImagesDialog(index),
                                child: Container(
                                  height: 120,
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(image: FileImage(File(paths[0])), fit: BoxFit.cover),
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
                                    onPressed: () => _pickImages(index),
                                    icon: Icon(paths.isNotEmpty ? Icons.refresh : Icons.upload_file, size: 18),
                                    label: Text(paths.isNotEmpty ? 'Replace' : 'Upload'),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: paths.isNotEmpty ? Colors.amber.shade600 : Colors.blueAccent,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                                if (paths.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _showImagesDialog(index),
                                      icon: const Icon(Icons.visibility, size: 18),
                                      label: const Text('View'),
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                    ),
                                  ),
                                ],
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (_uploadRows.length > 1)
                          ElevatedButton.icon(
                            onPressed: _removeRow,
                            icon: const Icon(Icons.remove_circle_outline, size: 20),
                            label: const Text('Remove'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              ElevatedButton(
                onPressed: () => _onSubmit(exitAfter: false),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(_processItem == 'Update' ? 'Update & New' : 'Submit & New', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _onSubmit(exitAfter: true),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: SparshTheme.successGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(_processItem == 'Update' ? 'Update & Exit' : 'Submit & Exit', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
