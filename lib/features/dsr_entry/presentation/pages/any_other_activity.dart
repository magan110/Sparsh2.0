import 'dart:io';
import 'package:flutter/material.dart';
import 'package:learning2/core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AnyOtherActivity extends StatefulWidget {
  const AnyOtherActivity({super.key});

  @override
  State<AnyOtherActivity> createState() => _AnyOtherActivityState();
}

class _AnyOtherActivityState extends State<AnyOtherActivity> {
  // 1) CONTROLLERS for dropdowns and dates
  String? _processItem = 'Select';
  List<String> _processdropdownItems = ['Select'];
  bool _isLoadingProcessTypes = true;
  String? _processTypeError;

  final TextEditingController _dateController       = TextEditingController();
  final TextEditingController _reportDateController = TextEditingController();
  DateTime? _selectedDate;
  DateTime? _selectedReportDate;

  // 2) CONTROLLERS for activity text fields
  final TextEditingController _activity1Controller      = TextEditingController();
  final TextEditingController _activity2Controller      = TextEditingController();
  final TextEditingController _activity3Controller      = TextEditingController();
  final TextEditingController _anyOtherPointsController = TextEditingController();

  // 3) IMAGE UPLOAD state (up to 3)
  final List<int> _uploadRows        = [0];
  final ImagePicker _picker          = ImagePicker();
  final List<XFile?> _selectedImages = [null];

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

  @override
  void dispose() {
    _dateController.dispose();
    _reportDateController.dispose();
    _activity1Controller.dispose();
    _activity2Controller.dispose();
    _activity3Controller.dispose();
    _anyOtherPointsController.dispose();
    super.dispose();
  }

  // DATE PICKERS
  void _setSubmissionDateToToday() {
    final today = DateTime.now();
    _selectedDate = today;
    _dateController.text = DateFormat('dd-MM-yy').format(today);
  }

  Future<void> _pickReportDate() async {
    final now = DateTime.now();
    final threeDaysAgo = now.subtract(const Duration(days: 3));
    final pick = await showDatePicker(
      context: context,
      initialDate: _selectedReportDate ?? now,
      firstDate: threeDaysAgo,
      lastDate: DateTime(now.year + 5),
    );
    if (pick != null) {
      setState(() {
        _selectedReportDate = pick;
        _reportDateController.text = DateFormat('dd-MM-yy').format(pick);
      });
    }
  }

  // IMAGE PICKER
  Future<void> _pickImage(int idx) async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _selectedImages[idx] = file);
    }
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
    if (_uploadRows.length < 3) {
      setState(() {
        _uploadRows.add(_uploadRows.length);
        _selectedImages.add(null);
      });
    }
  }

  void _removeRow() {
    if (_uploadRows.length > 1) {
      setState(() {
        _uploadRows.removeLast();
        _selectedImages.removeLast();
      });
    }
  }

  void _onSubmit({required bool exitAfter}) async {
    if (!_formKey.currentState!.validate()) return;

    final dsrData = {
      'ActivityType': 'Any Other Activity',
      'SubmissionDate': _selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'ReportDate': _selectedReportDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'CreateId': 'SYSTEM',
      'AreaCode': _processItem ?? '',
      'Purchaser': _activity1Controller.text,
      'PurchaserCode': '',
      'dsrRem01': _activity1Controller.text,
      'dsrRem02': _activity2Controller.text,
      'dsrRem03': _activity3Controller.text,
      'dsrRem04': _anyOtherPointsController.text,
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
        _formKey.currentState!.reset();
        setState(() {
          _processItem = 'Select';
          _dateController.clear();
          _reportDateController.clear();
          _selectedDate = null;
          _selectedReportDate = null;
          _activity1Controller.clear();
          _activity2Controller.clear();
          _activity3Controller.clear();
          _anyOtherPointsController.clear();
          _uploadRows
            ..clear()
            ..add(0);
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

  Widget _buildLabel(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(bottom: SparshSpacing.sm),
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      );

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
    bool enabled = true,
  }) =>
      DropdownButtonFormField<String>(
        value: value,
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
        items: items
            .map((it) => DropdownMenuItem(value: it, child: Text(it)))
            .toList(),
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
            icon: const Icon(Icons.calendar_today, size: SparshIconSize.lg),
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

  Widget _buildMultilineField(
    String hint,
    TextEditingController ctrl,
    int minLines,
  ) =>
      TextFormField(
        controller: ctrl,
        minLines: minLines,
        maxLines: minLines + 1,
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
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SparshTheme.lightGreyBackground,
      appBar: AppBar(
        title: const Text('Any Other Activity'),
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
                    _buildLabel(context, 'Activity Information'),
                    const SizedBox(height: SparshSpacing.sm),
                    _buildLabel(context, 'Process Type'),
                    if (_processTypeError != null)
                      Text(_processTypeError!, style: TextStyle(color: Colors.red)),
                    _isLoadingProcessTypes
                      ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                      : _buildDropdown(
                          value: _processItem,
                          items: _processdropdownItems,
                          onChanged: (v) => setState(() => _processItem = v),
                          validator: (v) => (v == null || v == 'Select') ? 'Required' : null,
                          enabled: _processdropdownItems.length > 1,
                        ),
                    const SizedBox(height: SparshSpacing.sm),
                    _buildLabel(context, 'Submission Date'),
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
                        suffixIcon: Icon(Icons.lock, color: Colors.grey),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: SparshSpacing.sm),
                    _buildLabel(context, 'Report Date'),
                    _buildDateField(
                      _reportDateController,
                      _pickReportDate,
                      'Select Date',
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
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
                    _buildLabel(context, 'Activity Details'),
                    const SizedBox(height: SparshSpacing.sm),
                    _buildMultilineField('Activity Details 1', _activity1Controller, 3),
                    const SizedBox(height: SparshSpacing.sm),
                    _buildMultilineField('Activity Details 2', _activity2Controller, 3),
                    const SizedBox(height: SparshSpacing.sm),
                    _buildMultilineField('Activity Details 3', _activity3Controller, 3),
                    const SizedBox(height: SparshSpacing.sm),
                    _buildLabel(context, 'Any Other Points'),
                    _buildMultilineField('Any Other Points', _anyOtherPointsController, 3),
                  ],
                ),
              ),

              const SizedBox(height: SparshSpacing.md),

              // ── Supporting Documents ─────────────────────────────
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
                    Row(
                      children: [
                        Icon(Icons.photo_library_rounded,
                            color: SparshTheme.primaryBlueAccent,
                            size: SparshIconSize.lg),
                        const SizedBox(width: SparshSpacing.sm),
                        Expanded(
                          child: Text(
                            'Supporting Documents',
                            style: Theme.of(context).textTheme.headlineSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SparshSpacing.sm),
                    // each image row
                    ..._uploadRows.map((idx) {
                      final file = _selectedImages[idx];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: SparshSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Document ${idx + 1}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: SparshSpacing.xs),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _pickImage(idx),
                                  icon: Icon(
                                      file != null ? Icons.refresh : Icons.upload_file),
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
                                if (_uploadRows.length > 1 && idx == _uploadRows.last)
                                  IconButton(
                                    onPressed: _removeRow,
                                    icon: const Icon(Icons.remove_circle),
                                    color: SparshTheme.errorRed,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                    if (_uploadRows.length < 3)
                      Center(
                        child: TextButton.icon(
                          onPressed: _addRow,
                          icon: const Icon(Icons.add_photo_alternate),
                          label: const Text('Add More Image'),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: SparshSpacing.lg),

              // ── Submit Buttons ────────────────────────────────────
              ElevatedButton(
                onPressed: () => _onSubmit(exitAfter: false),
                child: const Text('Submit & New'),
              ),
              const SizedBox(height: SparshSpacing.sm),
              ElevatedButton(
                onPressed: () => _onSubmit(exitAfter: true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: SparshTheme.successGreen),
                child: const Text('Submit & Exit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
