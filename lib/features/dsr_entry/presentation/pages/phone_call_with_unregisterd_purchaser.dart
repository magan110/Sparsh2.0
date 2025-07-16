import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../core/theme/app_theme.dart';
import 'dsr_entry.dart';

class PhoneCallWithUnregisterdPurchaser extends StatefulWidget {
  const PhoneCallWithUnregisterdPurchaser({super.key});

  @override
  State<PhoneCallWithUnregisterdPurchaser> createState() => _PhoneCallWithUnregisterdPurchaserState();
}

class _PhoneCallWithUnregisterdPurchaserState extends State<PhoneCallWithUnregisterdPurchaser> {
  // Process dropdown
  String? _processItem = 'Select';
  final List<String> _processdropdownItems = ['Select', 'Add', 'Update'];

  // Dates
  final TextEditingController _submissionDateController = TextEditingController();
  final TextEditingController _reportDateController = TextEditingController();

  // Area Code dropdown
  String? _areaCode = 'Select';
  final List<String> _areaCodes = ['Select', 'North', 'South', 'East', 'West'];

  // Mobile No
  final TextEditingController _mobileController = TextEditingController();

  // Purchaser / Retailer dropdown
  String? _purchaserType = 'Select';
  final List<String> _purchaserTypes = [
    'Select',
    'Purchaser (Non Trade)',
    'Authorised Dealer'
  ];

  // Party Name
  final TextEditingController _partyNameController = TextEditingController();

  // Counter Type dropdown
  String? _counterType = 'Select';
  final List<String> _counterTypes = ['Select', 'Type A', 'Type B'];

  // Pin Code
  final TextEditingController _pinCodeController = TextEditingController();

  // District
  final TextEditingController _districtController = TextEditingController();

  // Visited City
  final TextEditingController _visitedCityController = TextEditingController();

  // Name & Designation
  final TextEditingController _nameDesigController = TextEditingController();

  // Topics discussed
  final TextEditingController _topicsController = TextEditingController();

  // Images
  List<File?> _selectedImages = [null];
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _submissionDateController.dispose();
    _reportDateController.dispose();
    _mobileController.dispose();
    _partyNameController.dispose();
    _pinCodeController.dispose();
    _districtController.dispose();
    _visitedCityController.dispose();
    _nameDesigController.dispose();
    _topicsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _setSubmissionDateToToday();
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
      firstDate: DateTime(now.year - 10), // Allow any past date (last 10 years)
      lastDate: now,  // Only allow up to today
    );
    if (picked != null) {
      setState(() {
        _reportDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _pickImage(int index) async {
    final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImages[index] = File(pickedFile.path));
    }
  }

  void _showImageDialog(File imageFile) {
    showDialog(
      context: context,
      builder: (_) =>
          Dialog(
            child: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.8,
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.6,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.contain,
                  image: FileImage(imageFile),
                ),
              ),
            ),
          ),
    );
  }

  void _onSubmit({required bool exitAfter}) async {
    if (!_formKey.currentState!.validate()) return;

    final dsrData = {
      'ActivityType': 'Phone Call with Unregistered Purchasers',
      'SubmissionDate': _submissionDateController.text,
      'ReportDate': _reportDateController.text,
      'CreateId': 'SYSTEM',
      'AreaCode': _areaCode ?? '',
      'Purchaser': _purchaserType ?? '',
      'PurchaserCode': '',
      'dsrRem01': _mobileController.text,
      'dsrRem02': _partyNameController.text,
      'dsrRem03': _counterType ?? '',
      'dsrRem04': _pinCodeController.text,
      'dsrRem05': _districtController.text,
      'dsrRem06': _visitedCityController.text,
      'dsrRem07': _nameDesigController.text,
      'dsrRem08': _topicsController.text,
      'Images': _selectedImages.map((file) => file?.path).toList(),
    };

    try {
      await submitDsrEntry(dsrData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(exitAfter
              ? 'Submitted successfully. Exiting...'
              : 'Submitted successfully. Ready for new entry.'),
          backgroundColor: SparshTheme.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (exitAfter) {
        Navigator.of(context).pop();
      } else {
        _clearForm();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Submission failed: ${e.toString()}'),
          backgroundColor: SparshTheme.errorRed,
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
      _areaCode = 'Select';
      _mobileController.clear();
      _purchaserType = 'Select';
      _partyNameController.clear();
      _counterType = 'Select';
      _pinCodeController.clear();
      _districtController.clear();
      _visitedCityController.clear();
      _nameDesigController.clear();
      _topicsController.clear();
      _selectedImages = [null];
    });
    _formKey.currentState!.reset();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SparshTheme.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () =>
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const DsrEntry())),
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 22),
        ),
        title: Text(
          'Phone Call with Unregistered Purchasers',
          style: SparshTypography.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: SparshTheme.primaryBlueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildLabel('Process Type'),
              _buildDropdownField(
                value: _processItem,
                items: _processdropdownItems,
                onChanged: (v) => setState(() => _processItem = v),
              ),
              const SizedBox(height: 12),

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
                  contentPadding: const EdgeInsets.symmetric(horizontal: SparshSpacing.md, vertical: SparshSpacing.sm),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: SparshSpacing.md, vertical: SparshSpacing.sm),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Select date' : null,
              ),
              const SizedBox(height: 12),

              _buildLabel('Area Code'),
              _buildDropdownField(
                value: _areaCode,
                items: _areaCodes,
                onChanged: (v) => setState(() => _areaCode = v),
              ),
              const SizedBox(height: 12),

              _buildLabel('Mobile No'),
              _buildTextField(
                  'Mobile No',
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),

              _buildLabel('Purchaser / Retailer'),
              _buildDropdownField(
                value: _purchaserType,
                items: _purchaserTypes,
                onChanged: (v) => setState(() => _purchaserType = v),
              ),
              const SizedBox(height: 12),

              _buildLabel('Party Name'),
              _buildTextField('Party Name',
                  controller: _partyNameController,
                  maxLines: 2,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),

              _buildLabel('Counter Type'),
              _buildDropdownField(
                value: _counterType,
                items: _counterTypes,
                onChanged: (v) => setState(() => _counterType = v),
              ),
              const SizedBox(height: 12),

              _buildLabel('Pin Code *'),
              _buildTextField('Enter Pin Code Number',
                  controller: _pinCodeController,
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              TextButton(
                onPressed: () {
                  // TODO: lookup pin code
                },
                child: const Text('Update Pincode'),
              ),
              const SizedBox(height: 12),

              _buildLabel('District *'),
              _buildTextField('District',
                  controller: _districtController,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),

              _buildLabel('Visited City'),
              _buildTextField('Visited City',
                  controller: _visitedCityController),
              const SizedBox(height: 12),

              _buildLabel('Name & Designation of Person'),
              _buildTextField('Name & Designation of Person',
                  controller: _nameDesigController,
                  maxLines: 2,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),

              _buildLabel('Topics discussed during meeting'),
              _buildTextField('Topics discussed during meeting',
                  controller: _topicsController,
                  maxLines: 3,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const SizedBox(height: 24),

              _buildLabel('Upload Images'),
              const SizedBox(height: 8),
              ...List.generate(_selectedImages.length, (i) {
                final file = _selectedImages[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SparshTheme.lightGreyBackground,
                    borderRadius: BorderRadius.circular(SparshBorderRadius.md),
                    border: Border.all(
                        color: file != null
                            ? SparshTheme.successGreen
                            : SparshTheme.borderGrey,
                        width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Document ${i + 1}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                          const Spacer(),
                          if (file != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: SparshTheme.successLight,
                                borderRadius: BorderRadius.circular(SparshBorderRadius.lg),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle,
                                      color: SparshTheme.successGreen, size: 16),
                                  SizedBox(width: 4),
                                  Text('Uploaded',
                                      style: TextStyle(
                                          color: SparshTheme.successGreen
                                          ,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13)),
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
                              icon: Icon(file != null
                                  ? Icons.refresh
                                  : Icons.upload_file,
                                  size: 18),
                              label:
                              Text(file != null ? 'Replace' : 'Upload'),
                            ),
                          ),
                          if (file != null) ...[
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showImageDialog(file),
                                icon: const Icon(Icons.visibility, size: 18),
                                label: const Text('View'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: SparshTheme.successGreen),
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectedImages.removeAt(i);
                                });
                              },
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: SparshTheme.errorRed),
                            ),
                          ]
                        ],
                      ),
                    ],
                  ),
                );
              }),
              if (_selectedImages.length < 3) ...[
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
                const SizedBox(height: 24),
              ],

              ElevatedButton(
                onPressed: () => _onSubmit(exitAfter: false),
                child: const Text('Submit & New'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _onSubmit(exitAfter: true),
                child: const Text('Submit & Exit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          text,
          style: SparshTypography.labelLarge.copyWith(color: SparshTheme.textPrimary),
        ),
      );

  Widget _buildTextField(String hint, {
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: SparshTheme.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SparshBorderRadius.md),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: SparshSpacing.md, vertical: SparshSpacing.sm),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SparshBorderRadius.md),
        border: Border.all(color: SparshTheme.borderGrey, width: 1),
        color: SparshTheme.cardBackground,
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        value: value,
        underline: Container(),
        items: items.map((item) =>
            DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, VoidCallback onTap,
      String hint) =>
      TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: SparshTheme.cardBackground,
          suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today), onPressed: onTap),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SparshBorderRadius.md),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: SparshSpacing.md, vertical: SparshSpacing.sm),
        ),
        onTap: onTap,
        validator: (val) => val == null || val.isEmpty ? 'Select date' : null,
      );
}