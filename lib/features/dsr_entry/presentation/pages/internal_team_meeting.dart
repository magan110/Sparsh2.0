import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../core/theme/app_theme.dart';
import 'dsr_entry.dart';

class InternalTeamMeeting extends StatefulWidget {
  const InternalTeamMeeting({super.key});

  @override
  State<InternalTeamMeeting> createState() => _InternalTeamMeetingState();
}

class _InternalTeamMeetingState extends State<InternalTeamMeeting> {
  String? _processItem = 'Select';
  List<String> _processdropdownItems = ['Select'];
  bool _isLoadingProcessTypes = true;
  String? _processTypeError;

  final TextEditingController _submissionDateController = TextEditingController();
  final TextEditingController _reportDateController     = TextEditingController();

  final TextEditingController _meetwithController = TextEditingController();
  final TextEditingController _meetdiscController  = TextEditingController();
  final TextEditingController _learnnngController  = TextEditingController();

  final List<int> _uploadRows = [0];
  final ImagePicker _picker = ImagePicker();
  final List<List<String>> _selectedImagePaths = [[]]; // multiple per row

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchProcessTypes();
    _setSubmissionDateToToday();
  }

  Future<void> _fetchProcessTypes() async {
    setState(() { _isLoadingProcessTypes = true; _processTypeError = null; });
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
          _processdropdownItems = ['Select', ...processTypes];
          _isLoadingProcessTypes = false;
        });
      } else {
        setState(() {
          _processdropdownItems = ['Select'];
          _isLoadingProcessTypes = false;
          _processTypeError = 'Failed to load process types.';
        });
      }
    } catch (e) {
      setState(() {
        _processdropdownItems = ['Select'];
        _isLoadingProcessTypes = false;
        _processTypeError = 'Failed to load process types.';
      });
    }
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
      firstDate: threeDaysAgo,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
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

  void _onSubmit({required bool exitAfter}) async {
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed'); // DEBUG
      return;
    }

    final dsrData = {
      'ActivityType': 'Internal Team Meetings / Review Meetings',
      'SubmissionDate': _submissionDateController.text,
      'ReportDate': _reportDateController.text,
      'CreateId': 'SYSTEM',
      'AreaCode': _processItem ?? '',
      'Purchaser': _meetwithController.text,
      'PurchaserCode': '',
      'dsrRem01': _meetdiscController.text,
      'dsrRem02': _learnnngController.text,
      'dsrRem03': '',
      'dsrRem04': '',
      'dsrRem05': '',
      'dsrRem06': '',
      'dsrRem07': '',
      'dsrRem08': '',
    };
    print('Prepared DSR Data: ' + dsrData.toString()); // DEBUG

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
    print('Submitting DSR Data: ' + dsrData.toString()); // DEBUG
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
                        Text(_processTypeError!, style: TextStyle(color: Colors.red)),
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
                            items: _processdropdownItems
                                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                                .toList(),
                            onChanged: _processdropdownItems.length > 1 ? (val) => setState(() => _processItem = val) : null,
                            validator: (val) => (val == null || val == 'Select') ? 'Please select a process' : null,
                          ),
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
                          suffixIcon: Icon(Icons.lock, color: Colors.grey),
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
                          suffixIcon: Icon(Icons.calendar_today),
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
                child: const Text('Submit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
