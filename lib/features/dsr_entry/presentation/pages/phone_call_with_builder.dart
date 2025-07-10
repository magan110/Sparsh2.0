import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import 'dsr_entry.dart';

class PhoneCallWithBuilder extends StatefulWidget {
  const PhoneCallWithBuilder({super.key});

  @override
  State<PhoneCallWithBuilder> createState() => _PhoneCallWithBuilderState();
}

class _PhoneCallWithBuilderState extends State<PhoneCallWithBuilder> {
  final _formKey = GlobalKey<FormState>();

  String? _processItem = 'Select';
  final List<String> _processdropdownItems = ['Select', 'Add', 'Update'];

  final TextEditingController _submissionDateController = TextEditingController();
  final TextEditingController _reportDateController     = TextEditingController();

  String? _areaCode = 'Select';
  final List<String> _areaCodeItems = ['Select', 'Agra', 'Delhi', 'Mumbai'];

  String? _purchaserItem = 'Select';
  final List<String> _purchaserItems = ['Select', 'Purchaser(Non Trade)', 'AUTHORISED DEALER'];

  final TextEditingController _codeController         = TextEditingController();
  final TextEditingController _siteController         = TextEditingController();
  final TextEditingController _contractorController   = TextEditingController();
  String? _metWithItem = 'Select';
  final List<String> _metWithItems = ['Select', 'Builder', 'Contractor'];
  final TextEditingController _namedesgController     = TextEditingController();
  final TextEditingController _topicController        = TextEditingController();
  final TextEditingController _ugaiRecoveryController = TextEditingController();
  final TextEditingController _grievanceController    = TextEditingController();
  final TextEditingController _otherPointController   = TextEditingController();

  List<File?> _selectedImages = [null];

  @override
  void dispose() {
    _submissionDateController.dispose();
    _reportDateController.dispose();
    _codeController.dispose();
    _siteController.dispose();
    _contractorController.dispose();
    _namedesgController.dispose();
    _topicController.dispose();
    _ugaiRecoveryController.dispose();
    _grievanceController.dispose();
    _otherPointController.dispose();
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
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
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
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
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

  void _onSubmit({required bool exitAfter}) {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(exitAfter
            ? 'Form validated. Exiting...'
            : 'Form validated. Ready for new entry.'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (exitAfter) {
      Navigator.of(context).pop();
    } else {
      _clearForm();
    }
  }

  void _clearForm() {
    setState(() {
      _processItem = 'Select';
      _submissionDateController.clear();
      _reportDateController.clear();
      _areaCode = 'Select';
      _purchaserItem = 'Select';
      _codeController.clear();
      _siteController.clear();
      _contractorController.clear();
      _metWithItem = 'Select';
      _namedesgController.clear();
      _topicController.clear();
      _ugaiRecoveryController.clear();
      _grievanceController.clear();
      _otherPointController.clear();
      _selectedImages = [null];
    });
    _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () =>
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DsrEntry())),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
        ),
        title: Text(
          'Phone Call With Builder',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildLabel('Process type'),
              _buildDropdownField(
                value: _processItem,
                items: _processdropdownItems,
                onChanged: (val) => setState(() => _processItem = val),
              ),
              const SizedBox(height: 10),
              _buildLabel('Submission Date'),
              _buildDateField(
                  _submissionDateController, _pickSubmissionDate, 'Select Submission Date'),
              const SizedBox(height: 10),
              _buildLabel('Report Date'),
              _buildDateField(
                  _reportDateController, _pickReportDate, 'Select Report Date'),
              const SizedBox(height: 10),
              _buildLabel('Area Code'),
              _buildDropdownField(
                value: _areaCode,
                items: _areaCodeItems,
                onChanged: (val) => setState(() => _areaCode = val),
              ),
              const SizedBox(height: 10),
              _buildLabel('Purchaser'),
              _buildDropdownField(
                value: _purchaserItem,
                items: _purchaserItems,
                onChanged: (val) => setState(() => _purchaserItem = val),
              ),
              const SizedBox(height: 10),
              _buildLabel('Purchaser Code'),
              _buildTextField('Enter Code', controller: _codeController),
              const SizedBox(height: 10),
              _buildLabel('Site Name'),
              _buildTextField('Enter Site Name', controller: _siteController),
              const SizedBox(height: 10),
              _buildLabel('Contractor Working at Site'),
              _buildTextField(
                  'Enter Contractor Name', controller: _contractorController),
              const SizedBox(height: 10),
              _buildLabel('Met With'),
              _buildDropdownField(
                value: _metWithItem,
                items: _metWithItems,
                onChanged: (val) => setState(() => _metWithItem = val),
              ),
              const SizedBox(height: 10),
              _buildLabel('Name and Designation of Person'),
              _buildTextField(
                  'Enter Name and Designation', controller: _namedesgController),
              const SizedBox(height: 10),
              _buildLabel('Topic Discussed'),
              _buildTextField('Enter Topic Discussed',
                  controller: _topicController, maxLines: 3),
              const SizedBox(height: 10),
              _buildLabel('Ugai Recovery Plans'),
              _buildTextField('Enter Ugai Recovery Plans',
                  controller: _ugaiRecoveryController, maxLines: 3),
              const SizedBox(height: 10),
              _buildLabel('Any Purchaser Grievances'),
              _buildTextField('Enter Purchaser Grievances',
                  controller: _grievanceController, maxLines: 3),
              const SizedBox(height: 10),
              _buildLabel('Any Other Point'),
              _buildTextField('Enter Any Other Point',
                  controller: _otherPointController, maxLines: 3),
              const SizedBox(height: 10),
              _buildLabel('Upload Images'),
              ...List.generate(_selectedImages.length, (i) {
                final file = _selectedImages[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                      file != null ? Colors.green.shade200 : Colors.grey.shade200,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Document ${i + 1}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          const Spacer(),
                          if (file != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle,
                                      color: Colors.green, size: 16),
                                  SizedBox(width: 4),
                                  Text('Uploaded',
                                      style: TextStyle(
                                          color: Colors.green,
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
                              icon: Icon(
                                  file != null ? Icons.refresh : Icons.upload_file,
                                  size: 18),
                              label: Text(file != null ? 'Replace' : 'Upload'),
                            ),
                          ),
                          if (file != null) ...[
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showImageDialog(file),
                                icon: const Icon(Icons.visibility, size: 18),
                                label: const Text('View'),
                                style:
                                ElevatedButton.styleFrom(backgroundColor: Colors.green),
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
                                  color: Colors.red),
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
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _onSubmit(exitAfter: false),
                      child: const Text('Submit & New'),
                    ),
                  ),
                  const SizedBox(width: 12),
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
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          color: Colors.white,
        ),
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          underline: Container(),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      );

  Widget _buildDateField(
      TextEditingController controller, VoidCallback onTap, String hint) =>
      TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon:
          IconButton(icon: const Icon(Icons.calendar_today), onPressed: onTap),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        ),
        onTap: onTap,
        validator: (val) => val == null || val.isEmpty ? 'Select date' : null,
      );
}
