import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../core/theme/app_theme.dart';
import 'dsr_entry.dart';

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

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchProcessTypes();
    _fetchActivityTypes();
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
          _processItems = ['Select', ...processTypes];
          _isLoadingProcessTypes = false;
        });
      } else {
        setState(() {
          _processItems = ['Select'];
          _isLoadingProcessTypes = false;
          _processTypeError = 'Failed to load process types.';
        });
      }
    } catch (e) {
      setState(() {
        _processItems = ['Select'];
        _isLoadingProcessTypes = false;
        _processTypeError = 'Failed to load process types.';
      });
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

  @override
  void dispose() {
    _dateController.dispose();
    _reportDateController.dispose();
    _participantsController.dispose();
    _townController.dispose();
    _learningsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(
    TextEditingController ctrl,
    DateTime? initial,
    ValueChanged<DateTime> onSelected,
  ) async {
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

  void _onSubmit(bool exitAfter) {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          exitAfter
              ? 'Form validated. Exiting…'
              : 'Form validated. Ready for new entry.',
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
        _selectedImages
          ..clear()
          ..add(null);
      });
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
                      Text(_processTypeError!, style: TextStyle(color: Colors.red)),
                    _isLoadingProcessTypes
                        ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                        : _buildDropdown(
                            value: _processItem,
                            items: _processItems,
                            onChanged: (v) => setState(() => _processItem = v),
                            validator: (v) => (v == null || v == 'Select') ? 'Required' : null,
                            enabled: _processItems.length > 1,
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
                    _buildDateField(
                      _dateController,
                      () => _pickDate(
                        _dateController,
                        _selectedDate,
                        (d) => _selectedDate = d,
                      ),
                      'Select Date',
                      (v) => (v == null || v.isEmpty) ? 'Required' : null,
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
                      Text(_activityTypeError!, style: TextStyle(color: Colors.red)),
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
                        const SizedBox(width: SparshSpacing.sm),
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
}
