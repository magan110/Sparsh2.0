import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import 'dsr_entry.dart';

class BtlActivities extends StatefulWidget {
  const BtlActivities({super.key});

  @override
  State<BtlActivities> createState() => _BtlActivitiesState();
}

class _BtlActivitiesState extends State<BtlActivities> {
  // ─── State & Controllers ────────────────────────────────────────────────────
  String? _processItem = 'Select';
  final _processItems = ['Select', 'Add', 'Update'];

  String? _activityTypeItem = 'Select';
  final _activityTypes = [
    'Select',
    'Retailer Meet',
    'Stokiest Meet',
    'Painter Meet',
    'Architect Meet',
    'Counter Meet',
    'Painter Training Program',
    'Other BTL Activities',
  ];

  final _dateController       = TextEditingController();
  final _reportDateController = TextEditingController();
  DateTime? _selectedDate;
  DateTime? _selectedReportDate;

  final _participantsController = TextEditingController();
  final _townController         = TextEditingController();
  final _learningsController    = TextEditingController();

  final List<XFile?> _selectedImages = [null];
  final _picker               = ImagePicker();

  final _formKey = GlobalKey<FormState>();
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _dateController.dispose();
    _reportDateController.dispose();
    _participantsController.dispose();
    _townController.dispose();
    _learningsController.dispose();
    super.dispose();
  }

  // ─── Helpers: Pickers ────────────────────────────────────────────────────────
  Future<void> _pickDate(TextEditingController ctrl, DateTime? initial,
      ValueChanged<DateTime> onSelected) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      onSelected(picked);
      ctrl.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _pickImage(int idx) async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _selectedImages[idx] = file);
    }
  }

  void _showImage(XFile file) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Image.file(File(file.path),
            fit: BoxFit.contain,
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6),
      ),
    );
  }

  void _addImageField() {
    if (_selectedImages.length < 3) {
      setState(() => _selectedImages.add(null));
    }
  }

  void _removeImageField(int idx) {
    if (_selectedImages.length > 1) {
      setState(() => _selectedImages.removeAt(idx));
    }
  }
  // ─────────────────────────────────────────────────────────────────────────────

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
        _activityTypeItem = 'Select';
        _dateController.clear();
        _reportDateController.clear();
        _selectedDate        = null;
        _selectedReportDate  = null;
        _participantsController.clear();
        _townController.clear();
        _learningsController.clear();
        _selectedImages
          ..clear()
          ..add(null);
      });
    }
  }

  // ─── Widget Builders ────────────────────────────────────────────────────────
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
        isExpanded: true,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          isCollapsed: true,
        ),
        items:
        items.map((it) => DropdownMenuItem(value: it, child: Text(it))).toList(),
        onChanged: onChanged,
        validator: validator,
      );

  Widget _buildDateField(TextEditingController ctrl, VoidCallback onTap,
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
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none),
          suffixIcon: IconButton(icon: const Icon(Icons.calendar_today), onPressed: onTap),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      }) =>
      TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: validator,
      );

  Widget _buildImageRow(int idx) {
    final file = _selectedImages[idx];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Document ${idx + 1}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(idx),
              icon: Icon(file != null ? Icons.refresh : Icons.upload_file),
              label: Text(file != null ? 'Replace' : 'Upload'),
            ),
            const SizedBox(width: 12),
            if (file != null)
              ElevatedButton.icon(
                onPressed: () => _showImage(file),
                icon: const Icon(Icons.visibility),
                label: const Text('View'),
              ),
            const Spacer(),
            if (_selectedImages.length > 1 && idx == _selectedImages.length - 1)
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () => _removeImageField(idx),
              ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          onPressed: () =>
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DsrEntry())),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: const Text('BTL Activities'),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Process Section ───────────────────────────────────────
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
                    _buildLabel('Process Type'),
                    _buildDropdown(
                      value: _processItem,
                      items: _processItems,
                      onChanged: (v) => setState(() => _processItem = v),
                      validator: (v) =>
                      (v == null || v == 'Select') ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Date Section ─────────────────────────────────────────
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
                    _buildLabel('Submission Date'),
                    _buildDateField(
                      _dateController,
                          () => _pickDate(_dateController, _selectedDate!,
                              (d) => _selectedDate = d),
                      'Select Date',
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildLabel('Report Date'),
                    _buildDateField(
                      _reportDateController,
                          () => _pickDate(_reportDateController, _selectedReportDate!,
                              (d) => _selectedReportDate = d),
                      'Select Date',
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── BTL Activity Details ─────────────────────────────────
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
                    _buildLabel('Type Of Activity'),
                    _buildDropdown(
                      value: _activityTypeItem,
                      items: _activityTypes,
                      onChanged: (v) => setState(() => _activityTypeItem = v),
                      validator: (v) =>
                      (v == null || v == 'Select') ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildLabel('No. Of Participants'),
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
                    const SizedBox(height: 12),
                    _buildLabel('Town in Which Activity Conducted'),
                    _buildTextField(
                      'Enter town',
                      _townController,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildLabel('Learning\'s From Activity'),
                    _buildTextField(
                      'Enter your learnings',
                      _learningsController,
                      maxLines: 3,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Supporting Documents ────────────────────────────────
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
                    Text(
                      'Upload up to 3 images related to your activity',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(_selectedImages.length, _buildImageRow),
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
              const SizedBox(height: 24),

              // ── Submit Buttons ───────────────────────────────────────
              ElevatedButton(
                onPressed: () => _onSubmit(false),
                child: const Text('Submit & New'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _onSubmit(true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green),
                child: const Text('Submit & Exit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
