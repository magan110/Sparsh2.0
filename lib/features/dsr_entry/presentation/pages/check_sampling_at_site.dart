import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../core/theme/app_theme.dart';
import 'dsr_entry.dart';

class ApiConstants {
  static const String baseUrl = 'http://192.168.36.25/api';
  static const String getProcessTypes = '/DsrTry/getProcessTypes';
  static const String getProductOptions = '/DsrTry/getProductOptions';
  static const String getQualityOptions = '/DsrTry/getQualityOptions';
  static const String getStatusOptions = '/DsrTry/getStatusOptions';
  static const String dsrTry = '/DsrTry';

  static String url(String endpoint) => 'baseUrlendpoint'.replaceAll('baseUrl', baseUrl).replaceAll('endpoint', endpoint);
}

class CheckSamplingAtSite extends StatefulWidget {
  const CheckSamplingAtSite({super.key});

  @override
  State<CheckSamplingAtSite> createState() => _CheckSamplingAtSiteState();
}

class _CheckSamplingAtSiteState extends State<CheckSamplingAtSite> {
  // ─── State & Controllers ────────────────────────────────────────────────────
  // Dynamic dropdown state
  List<String> _processTypes = ['Select'];
  String? _selectedProcessType = 'Select';
  bool _isLoadingProcessTypes = true;

  List<String> _productNames = ['Select'];
  String? _selectedProductName = 'Select';
  bool _isLoadingProductNames = true;

  List<String> _qualityOptions = ['Select'];
  String? _selectedQuality = 'Select';
  bool _isLoadingQualityOptions = true;

  List<String> _statusOptions = ['Select'];
  String? _selectedStatus = 'Select';
  bool _isLoadingStatusOptions = true;

  String? _processItem = 'Select';
  final _processItems = ['Select', 'Add', 'Update'];

  final _dateController = TextEditingController();
  final _reportDateController = TextEditingController();
  DateTime? _selectedDate;
  DateTime? _selectedReportDate;

  final _siteController = TextEditingController();
  final _productController = TextEditingController();
  final _potentialController = TextEditingController();
  final _applicatorController = TextEditingController();

  String? _qualityItem = 'Select';
  final _qualityItems = ['Select', 'Average', 'Medium', 'Good'];

  String? _statusItem = 'Select';
  final _statusItems = [
    'Select',
    'Yet To be Checked By Purchaser',
    'Approved',
    'Rejected',
  ];

  final _contactNameController = TextEditingController();
  final _mobileController = TextEditingController();

  final List<XFile?> _selectedImages = [null];
  final _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchProcessTypes();
    _fetchProductNames();
    _fetchQualityOptions();
    _fetchStatusOptions();
    _setSubmissionDateToToday();
  }

  Future<void> _fetchProcessTypes() async {
    setState(() { _isLoadingProcessTypes = true; });
    try {
      final url = Uri.parse(ApiConstants.url(ApiConstants.getProcessTypes));
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
          _processTypes = ['Select', ...processTypes];
          _isLoadingProcessTypes = false;
        });
      } else {
        setState(() {
          _processTypes = ['Select'];
          _isLoadingProcessTypes = false;
        });
      }
    } catch (e) {
      setState(() {
        _processTypes = ['Select'];
        _isLoadingProcessTypes = false;
      });
    }
  }

  Future<void> _fetchProductNames() async {
    setState(() { _isLoadingProductNames = true; });
    try {
      final url = Uri.parse(ApiConstants.url(ApiConstants.getProductOptions));
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final productNames = (data is List ? data : <String>[]).map((e) => e.toString()).toList();
        setState(() {
          _productNames = ['Select', ...productNames];
          _isLoadingProductNames = false;
        });
      } else {
        setState(() {
          _productNames = ['Select'];
          _isLoadingProductNames = false;
        });
      }
    } catch (e) {
      setState(() {
        _productNames = ['Select'];
        _isLoadingProductNames = false;
      });
    }
  }

  Future<void> _fetchQualityOptions() async {
    setState(() { _isLoadingQualityOptions = true; });
    try {
      final url = Uri.parse(ApiConstants.url(ApiConstants.getQualityOptions));
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final qualityOptions = (data is List ? data : <String>[]).map((e) => e.toString()).toList();
        setState(() {
          _qualityOptions = ['Select', ...qualityOptions];
          _isLoadingQualityOptions = false;
        });
      } else {
        setState(() {
          _qualityOptions = ['Select'];
          _isLoadingQualityOptions = false;
        });
      }
    } catch (e) {
      setState(() {
        _qualityOptions = ['Select'];
        _isLoadingQualityOptions = false;
      });
    }
  }

  Future<void> _fetchStatusOptions() async {
    setState(() { _isLoadingStatusOptions = true; });
    try {
      final url = Uri.parse(ApiConstants.url(ApiConstants.getStatusOptions));
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final statusOptions = (data is List ? data : <String>[]).map((e) => e.toString()).toList();
        setState(() {
          _statusOptions = ['Select', ...statusOptions];
          _isLoadingStatusOptions = false;
        });
      } else {
        setState(() {
          _statusOptions = ['Select'];
          _isLoadingStatusOptions = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusOptions = ['Select'];
        _isLoadingStatusOptions = false;
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _reportDateController.dispose();
    _siteController.dispose();
    _productController.dispose();
    _potentialController.dispose();
    _applicatorController.dispose();
    _contactNameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _setSubmissionDateToToday() {
    final today = DateTime.now();
    _selectedDate = today;
    _dateController.text = DateFormat('yyyy-MM-dd').format(today);
  }

  Future<void> _pickReportDate() async {
    final now = DateTime.now();
    final threeDaysAgo = now.subtract(const Duration(days: 3));
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedReportDate ?? now,
      firstDate: threeDaysAgo,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedReportDate = picked;
        _reportDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickDate(
    TextEditingController ctrl,
    DateTime? initialDate,
    ValueChanged<DateTime> onSelected,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
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

  void _onSubmit({required bool exitAfter}) async {
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed'); // DEBUG
      return;
    }

    final dsrData = {
      'ActivityType': 'Visit to Get / Check Sampling at Site',
      'SubmissionDate': _selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'ReportDate': _selectedReportDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      // 'CreateId': 'SYSTEM',
      // 'AreaCode': _siteController.text,
      // 'Purchaser': _productController.text,
      // 'PurchaserCode': '',
      'dsrRem01': _siteController.text,
      'dsrRem02': _selectedProductName ?? '',
      'dsrRem03': _potentialController.text,
      'dsrRem04': _applicatorController.text,
      'dsrRem05': _selectedQuality ?? '',
      'dsrRem06': _selectedStatus ?? '',
      'dsrRem07': _contactNameController.text,
      'dsrRem08': _mobileController.text,
      // 'SupportingDocuments': _selectedImages.map((file) => file?.path).toList(),
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
          _selectedDate = null;
          _selectedReportDate = null;
          _dateController.clear();
          _reportDateController.clear();
          _siteController.clear();
          _productController.clear();
          _potentialController.clear();
          _applicatorController.clear();
          _qualityItem = 'Select';
          _statusItem = 'Select';
          _contactNameController.clear();
          _mobileController.clear();
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
    print('Submitting DSR Data: ' + dsrData.toString()); // DEBUG
    final url = Uri.parse(ApiConstants.url(ApiConstants.dsrTry));
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

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: SparshSpacing.sm),
        child: Text(text, style: SparshTypography.bodyBold),
      );

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
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
        onChanged: onChanged,
        validator: validator,
      );

  Widget _buildDateField(
    TextEditingController ctrl,
    VoidCallback onTap,
    String hint, {
    String? Function(String?)? validator,
  }) => TextFormField(
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
                icon: Icon(Icons.remove_circle_outline, color: SparshTheme.errorRed),
                onPressed: () => _removeImageField(idx),
              ),
          ],
        ),
        const SizedBox(height: SparshSpacing.md),
      ],
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
        title: Text(
          'Check Sampling at Site',
          style: SparshTypography.heading5.copyWith(color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: SparshTheme.primaryBlueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SparshSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Process Section
              _sectionContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Process Type'),
                    _buildDropdown(
                      value: _processItem,
                      items: _processTypes,
                      onChanged: (v) => setState(() => _processItem = v),
                      validator: (v) => (v == null || v == 'Select') ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SparshSpacing.md),

              // Date Section
              _sectionContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        suffixIcon: Icon(Icons.lock, color: Colors.grey),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
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
                        fillColor: SparshTheme.lightGreyBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(SparshBorderRadius.sm),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: SparshSpacing.md,
                          vertical: SparshSpacing.sm,
                        ),
                        suffixIcon: const Icon(Icons.calendar_today, size: SparshIconSize.md),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SparshSpacing.md),

              // Site & Product Section
              _sectionContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Site Name'),
                    _buildTextField(
                      'Enter Site Name',
                      _siteController,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: SparshSpacing.sm),
                    _buildLabel('Product Name'),
                    // _buildTextField(
                    //   'Enter Product Name',
                    //   _productController,
                    //   validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    // ),
                    _isLoadingProductNames
                        ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                        : DropdownButtonFormField<String>(
                            value: _selectedProductName,
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
                            items: _productNames.map((it) => DropdownMenuItem(value: it, child: Text(it))).toList(),
                            onChanged: (v) => setState(() => _selectedProductName = v),
                            validator: (v) => (v == null || v == 'Select') ? 'Required' : null,
                          ),
                  ],
                ),
              ),
              const SizedBox(height: SparshSpacing.md),

              // Potential & Applicator Section
              _sectionContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Potential (MT)'),
                    _buildTextField(
                      'Enter Potential',
                      _potentialController,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        return null;
                      },
                    ),
                    const SizedBox(height: SparshSpacing.sm),
                    _buildLabel('Applicator Name'),
                    _buildTextField(
                      'Enter Applicator Name',
                      _applicatorController,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SparshSpacing.md),

              // Quality & Status Section
              _sectionContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Quality of Sample'),
                    _buildDropdown(
                      value: _qualityItem,
                      items: _qualityOptions,
                      onChanged: (v) => setState(() => _qualityItem = v),
                      validator: (v) => (v == null || v == 'Select') ? 'Required' : null,
                    ),
                    const SizedBox(height: SparshSpacing.sm),
                    _buildLabel('Status of Sample'),
                    _buildDropdown(
                      value: _statusItem,
                      items: _statusOptions,
                      onChanged: (v) => setState(() => _statusItem = v),
                      validator: (v) => (v == null || v == 'Select') ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SparshSpacing.md),

              // Contact & Mobile Section
              _sectionContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Contact Name'),
                    _buildTextField(
                      'Enter Contact Name',
                      _contactNameController,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: SparshSpacing.sm),
                    _buildLabel('Mobile Number'),
                    _buildTextField(
                      'Enter Mobile Number',
                      _mobileController,
                      keyboardType: TextInputType.phone,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SparshSpacing.md),

              // Supporting Documents Section
              _sectionContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                    ...List.generate(
                      _selectedImages.length,
                      (idx) => _buildImageRow(idx),
                    ),
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
              const SizedBox(height: SparshSpacing.lg),

              // Submit Buttons
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SparshTheme.successGreen,
                      ),
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
}
