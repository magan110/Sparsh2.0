import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../core/theme/app_theme.dart';
import 'dsr_entry.dart';

class WorkFromHome extends StatefulWidget {
  const WorkFromHome({super.key});

  @override
  State<WorkFromHome> createState() => _WorkFromHomeState();
}

class _WorkFromHomeState extends State<WorkFromHome> {
  String? _processItem = 'Select';
  List<String> _processdropdownItems = ['Select'];
  bool _isLoadingProcessTypes = true;
  String? _processTypeError;

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

  @override
  void initState() {
    super.initState();
    _setSubmissionDateToToday();
    _fetchProcessTypes();
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

  @override
  void dispose() {
    _submissionDateController.dispose();
    _reportDateController.dispose();

    // ─── DISPOSE NEW CONTROLLERS ──────────────────────────────────────────────
    _activityDetails1Controller.dispose();
    _activityDetails2Controller.dispose();
    _activityDetails3Controller.dispose();
    _otherPointsController.dispose();
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

  void _resetForm() {
    setState(() {
      _processItem = 'Select';
      _selectedSubmissionDate = null;
      _selectedReportDate = null;
      _submissionDateController.clear();
      _reportDateController.clear();
      _activityDetails1Controller.clear();
      _activityDetails2Controller.clear();
      _activityDetails3Controller.clear();
      _otherPointsController.clear();
      _uploadRows..clear()..add(0);
      _selectedImages..clear()..add(null);
    });
    _formKey.currentState?.reset();
  }

  void _onSubmit({required bool exitAfter}) async {
    if (!_formKey.currentState!.validate()) return;

    final dsrData = {
      'ActivityType': 'Work From Home',
      'SubmissionDate': _selectedSubmissionDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'ReportDate': _selectedReportDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'CreateId': 'SYSTEM',
      'AreaCode': _processItem ?? '',
      'Purchaser': '',
      'PurchaserCode': '',
      'dsrRem01': _activityDetails1Controller.text,
      'dsrRem02': _activityDetails2Controller.text,
      'dsrRem03': _activityDetails3Controller.text,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SparshTheme.primaryBlueAccent,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const DsrEntry())),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Work From Home',
              style: SparshTypography.heading2.copyWith(color: Colors.white),
            ),
            Text(
              'Daily Sales Report Entry',
              style: SparshTypography.body.copyWith(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white, size: 24),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Help information for Work From Home'),
                duration: Duration(seconds: 2),
              ),
            ),
          )
        ],
        backgroundColor: SparshTheme.primaryBlueAccent,
        elevation: 0,
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
                      Text(_processTypeError!, style: TextStyle(color: Colors.red)),
                    _isLoadingProcessTypes
                      ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                      : DropdownButtonFormField<String>(
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
                              child: Text(item,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(fontSize: 14)),
                            ),
                          ))
                              .toList(),
                          onChanged: _processdropdownItems.length > 1 ? (v) => setState(() => _processItem = v) : null,
                          validator: (v) =>
                          (v == null || v == 'Select') ? 'Required' : null,
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
                        suffixIcon: Icon(Icons.lock, color: Colors.grey),
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
              Container(
                margin: const EdgeInsets.only(top: 20, bottom: SparshSpacing.md),
                padding: const EdgeInsets.all(SparshSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(SparshBorderRadius.sm),
                  boxShadow: SparshShadows.sm,
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // … your existing upload UI unchanged …
                  ],
                ),
              ),

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
                            side: BorderSide(color: SparshTheme.primaryBlueAccent)),
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
