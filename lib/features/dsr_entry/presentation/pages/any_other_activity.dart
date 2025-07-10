import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import 'dsr_entry.dart';

class AnyOtherActivity extends StatefulWidget {
  const AnyOtherActivity({super.key});

  @override
  State<AnyOtherActivity> createState() => _AnyOtherActivityState();
}

class _AnyOtherActivityState extends State<AnyOtherActivity> {
  // 1) CONTROLLERS for dropdowns and dates
  String? _processItem = 'Select';
  final List<String> _processdropdownItems = ['Select', 'Add', 'Update'];

  final TextEditingController _dateController       = TextEditingController();
  final TextEditingController _reportDateController = TextEditingController();
  DateTime? _selectedDate;
  DateTime? _selectedReportDate;

  // 2) CONTROLLERS for activity text fields
  final TextEditingController _activity1Controller        = TextEditingController();
  final TextEditingController _activity2Controller        = TextEditingController();
  final TextEditingController _activity3Controller        = TextEditingController();
  final TextEditingController _anyOtherPointsController   = TextEditingController();

  // 3) IMAGE UPLOAD state (up to 3)
  final List<int> _uploadRows       = [0];
  final ImagePicker _picker         = ImagePicker();
  final List<XFile?> _selectedImages= [null];

  final _formKey = GlobalKey<FormState>();

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
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final pick = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
    );
    if (pick != null) {
      setState(() {
        _selectedDate = pick;
        _dateController.text = DateFormat('dd-MM-yy').format(pick);
      });
    }
  }

  Future<void> _pickReportDate() async {
    final now = DateTime.now();
    final pick = await showDatePicker(
      context: context,
      initialDate: _selectedReportDate ?? now,
      firstDate: DateTime(2000),
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

  void _onSubmit(bool exitAfter) {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(exitAfter
            ? 'Form validated. Exiting…'
            : 'Form validated. Ready for new entry.'),
        backgroundColor: Colors.green,
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
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
  );

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) =>
      DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[100],
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          isCollapsed: true,
        ),
        items: items
            .map((it) => DropdownMenuItem(value: it, child: Text(it)))
            .toList(),
        onChanged: onChanged,
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
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: onTap,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onTap: onTap,
        validator: validator,
      );

  Widget _buildMultilineField(
      String hint, TextEditingController ctrl, int minLines) =>
      TextFormField(
        controller: ctrl,
        minLines: minLines,
        maxLines: minLines + 1,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Any Other Activity'),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Activity Information ───────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Activity Information'),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      value: _processItem,
                      items: _processdropdownItems,
                      onChanged: (v) => setState(() => _processItem = v),
                      validator: (v) => (v == null || v == 'Select') ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildLabel('Submission Date'),
                    _buildDateField(_dateController, _pickDate, 'Select Date',
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
                    const SizedBox(height: 12),
                    _buildLabel('Report Date'),
                    _buildDateField(_reportDateController, _pickReportDate, 'Select Date',
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Activity Details ───────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Activity Details'),
                    const SizedBox(height: 12),
                    _buildMultilineField('Activity Details 1', _activity1Controller, 3),
                    const SizedBox(height: 12),
                    _buildMultilineField('Activity Details 2', _activity2Controller, 3),
                    const SizedBox(height: 12),
                    _buildMultilineField('Activity Details 3', _activity3Controller, 3),
                    const SizedBox(height: 12),
                    _buildLabel('Any Other Points'),
                    _buildMultilineField('Any Other Points', _anyOtherPointsController, 3),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Supporting Documents ─────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.photo_library_rounded, color: Color(0xFF2196F3), size: 24),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Supporting Documents',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // each image row
                    ..._uploadRows.map((idx) {
                      final file = _selectedImages[idx];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Document ${idx + 1}',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _pickImage(idx),
                                  icon: Icon(
                                      file != null ? Icons.refresh : Icons.upload_file),
                                  label: Text(file != null ? 'Replace' : 'Upload'),
                                ),
                                const SizedBox(width: 12),
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
                                    color: Colors.red,
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

              const SizedBox(height: 24),

              // ── Submit Buttons ────────────────────────────────────
              ElevatedButton(
                onPressed: () => _onSubmit(false),
                child: const Text('Submit & New'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _onSubmit(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Submit & Exit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
