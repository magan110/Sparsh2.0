import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../core/theme/app_theme.dart';
import 'dsr_entry.dart';

class OfficeWork extends StatefulWidget {
  const OfficeWork({super.key});
  @override
  State<OfficeWork> createState() => _OfficeWorkState();
}

class _OfficeWorkState extends State<OfficeWork> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _submissionDateController = TextEditingController();
  final TextEditingController _reportDateController     = TextEditingController();

  // Dynamic field definitions
  List<Map<String, dynamic>> _fields = [];
  bool _isLoading = true;

  List<File?> _selectedImages = [null];

  @override
  void initState() {
    super.initState();
    _setSubmissionDateToToday();
    _initializeFields();
  }

  void _setSubmissionDateToToday() {
    final today = DateTime.now();
    _submissionDateController.text = DateFormat('yyyy-MM-dd').format(today);
  }

  Future<void> _initializeFields() async {
    try {
      // Fetch process types from API
      final processTypes = await _fetchProcessTypes();
      
      setState(() {
        _fields = [
          {
            'label': 'Process Type',
            'type': 'dropdown',
            'items': processTypes,
            'value': processTypes.isNotEmpty ? processTypes[0] : 'Select',
            'key': 'ProcessType',
          },
          {
            'label': 'Work Related To',
            'controller': TextEditingController(),
            'type': 'text',
            'maxLines': 3,
            'key': 'dsrRem01',
          },
          {
            'label': 'No. of Hours Spent',
            'controller': TextEditingController(),
            'type': 'number',
            'key': 'dsrRem02',
          },
        ];
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching process types: $e');
      // Fallback to default process types
      setState(() {
        _fields = [
          {
            'label': 'Process Type',
            'type': 'dropdown',
            'items': ['Select', 'Add', 'Update'],
            'value': 'Select',
            'key': 'ProcessType',
          },
          {
            'label': 'Work Related To',
            'controller': TextEditingController(),
            'type': 'text',
            'maxLines': 3,
            'key': 'dsrRem01',
          },
          {
            'label': 'No. of Hours Spent',
            'controller': TextEditingController(),
            'type': 'number',
            'key': 'dsrRem02',
          },
        ];
        _isLoading = false;
      });
    }
  }

  Future<List<String>> _fetchProcessTypes() async {
    try {
      final url = Uri.parse('http://192.168.36.25/api/DsrTry/getProcessTypes');
      print('🔍 Fetching process types from: $url');
      
      final response = await http.get(url);
      print('📡 Process types response status: ${response.statusCode}');
      print('📄 Process types response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('📊 Parsed process types data: $data');
        
        List<String> processTypes = [];
        
        // Try different response formats
        if (data is Map && data.containsKey('processTypes')) {
          // Format: {"processTypes": [{"description": "..."}, ...]}
          final processTypesList = data['processTypes'] as List;
          processTypes = processTypesList.map((type) => type['description'] as String).toList();
          print('✅ Found processTypes property with ${processTypes.length} items');
        } else if (data is Map && data.containsKey('ProcessTypes')) {
          // Format: {"ProcessTypes": [{"Description": "..."}, ...]}
          final processTypesList = data['ProcessTypes'] as List;
          processTypes = processTypesList.map((type) => type['Description'] as String).toList();
          print('✅ Found ProcessTypes property with ${processTypes.length} items');
        } else if (data is List) {
          // Format: [{"description": "..."}, ...]
          processTypes = data.map((type) => type['description'] as String).toList();
          print('✅ Found direct List format with ${processTypes.length} items');
        } else if (data is Map && data.containsKey('data')) {
          // Format: {"data": [{"description": "..."}, ...]}
          final processTypesList = data['data'] as List;
          processTypes = processTypesList.map((type) => type['description'] as String).toList();
          print('✅ Found data property with ${processTypes.length} items');
        } else {
          print('❌ Unexpected response format: ${data.runtimeType}');
          print('📋 Available keys: ${data is Map ? data.keys.toList() : 'Not a Map'}');
          throw Exception('Unexpected response format: ${data.runtimeType}');
        }
        
        print('✅ Process types loaded: $processTypes');
        return processTypes;
      } else {
        print('❌ Failed to fetch process types: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to fetch process types: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error fetching process types: $e');
      // Return default process types as fallback
      return ['Select', 'Add', 'Update'];
    }
  }

  @override
  void dispose() {
    _submissionDateController.dispose();
    _reportDateController.dispose();
    for (final field in _fields) {
      if (field['type'] == 'text' || field['type'] == 'number') {
        field['controller'].dispose();
      }
    }
    super.dispose();
  }

  Future<void> _pickSubmissionDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _submissionDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickReportDate() async {
    final now = DateTime.now();
    final threeDaysAgo = now.subtract(const Duration(days: 3));
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: threeDaysAgo,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _reportDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

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

  void _onSubmit({required bool exitAfter}) async {
    if (!_formKey.currentState!.validate()) return;

    final dsrData = <String, dynamic>{
      'ActivityType': 'Office Work',
      'SubmissionDate': _submissionDateController.text,
      'ReportDate': _reportDateController.text,
      'CreateId': 'SYSTEM',
      // Map dynamic fields to their keys
      ...{
        for (final field in _fields)
          if (field['type'] == 'dropdown')
            field['key'] as String: field['value']
          else
            field['key'] as String: field['controller'].text
      },
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
          content: Text('Submission failed:  e.toString()}'),
          backgroundColor: SparshTheme.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _clearForm() {
    setState(() {
      _submissionDateController.clear();
      _reportDateController.clear();
      for (final field in _fields) {
        if (field['type'] == 'dropdown') {
          field['value'] = field['items'][0];
        } else if (field['type'] == 'text' || field['type'] == 'number') {
          field['controller'].clear();
        }
      }
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
    if (_isLoading) {
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
          title: const Text('Office Work', style: TextStyle(color: Colors.white)),
          backgroundColor: SparshTheme.primaryBlue,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
        title: const Text('Office Work', style: TextStyle(color: Colors.white)),
        backgroundColor: SparshTheme.primaryBlue,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(SparshSpacing.md),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Render dynamic fields
              for (final field in _fields) ...[
                _buildLabel(field['label']),
                if (field['type'] == 'dropdown')
                  _buildDropdownField(
                    value: field['value'],
                    items: List<String>.from(field['items']),
                    onChanged: (val) => setState(() => field['value'] = val),
                  )
                else
                  _buildTextField(
                    field['label'],
                    controller: field['controller'],
                    keyboardType: field['type'] == 'number' ? TextInputType.number : TextInputType.text,
                    maxLines: field['maxLines'] ?? 1,
                  ),
                const SizedBox(height: SparshSpacing.sm),
              ],
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
                  suffixIcon: Icon(Icons.lock, color: Colors.grey),
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
                                  Icon(Icons.check_circle, color: SparshTheme.successGreen, size: 16),
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
                              icon: Icon(Icons.remove_circle_outline, color: SparshTheme.errorRed),
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

  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) =>
      Container(
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
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
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
