import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

// Import all the required screens
import 'Meetings_With_Contractor.dart';
import 'any_other_activity.dart';
import 'btl_activites.dart';
import 'check_sampling_at_site.dart';
import 'dsr_entry.dart';
import 'dsr_retailer_in_out.dart';
import 'internal_team_meeting.dart';
import 'office_work.dart';
import 'on_leave.dart';
import 'phone_call_with_builder.dart';
import 'phone_call_with_unregisterd_purchaser.dart';
import 'work_from_home.dart';

class MeetingWithNewPurchaser extends StatefulWidget {
  const MeetingWithNewPurchaser({super.key});

  @override
  State<MeetingWithNewPurchaser> createState() => _MeetingWithNewPurchaserState();
}

class _MeetingWithNewPurchaserState extends State<MeetingWithNewPurchaser> {
  String? _processItem = 'Select';
  final List<String> _processdropdownItems = ['Select', 'Add', 'Update'];

  final TextEditingController _submissionDateController = TextEditingController();
  final TextEditingController _reportDateController     = TextEditingController();

  final TextEditingController _purchaserNameController  = TextEditingController();
  final TextEditingController _topicDiscussedController = TextEditingController();
  final TextEditingController _remarksController         = TextEditingController();

  DateTime? _selectedSubmissionDate;
  DateTime? _selectedReportDate;

  final List<int> _uploadRows = [0];
  final ImagePicker _picker   = ImagePicker();
  final List<File?> _selectedImages = [null];

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _submissionDateController.dispose();
    _reportDateController.dispose();
    _purchaserNameController.dispose();
    _topicDiscussedController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _pickSubmissionDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedSubmissionDate ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2196F3),
            onPrimary: Colors.white,
            onSurface: Colors.black87,
          ),
          dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedSubmissionDate = picked;
        _submissionDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickReportDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedReportDate ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2196F3),
            onPrimary: Colors.white,
            onSurface: Colors.black87,
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

  // === Stubbed submit: validate, show SnackBar, reset ===
  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Form validated. Submitted successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    _resetForm();
  }

  void _resetForm() {
    setState(() {
      _processItem = 'Select';
      _selectedSubmissionDate = null;
      _selectedReportDate     = null;
      _submissionDateController.clear();
      _reportDateController.clear();
      _purchaserNameController.clear();
      _topicDiscussedController.clear();
      _remarksController.clear();
      _uploadRows
        ..clear()
        ..add(0);
      _selectedImages
        ..clear()
        ..add(null);
    });
    _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DsrEntry()),
          ),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Meeting with New Purchaser',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white),
            ),
            Text(
              'Daily Sales Report Entry',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white, size: 24),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Help information for Meeting with New Purchaser'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Process Selection Card
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.settings_outlined, color: Color(0xFF2196F3)),
                        const SizedBox(width: 8),
                        Text('Process', style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _processItem,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        isCollapsed: true,
                      ),
                      isExpanded: true,
                      items: _processdropdownItems
                          .map((item) => DropdownMenuItem<String>(value: item, child: Text(item)))
                          .toList(),
                      onChanged: (val) => setState(() => _processItem = val),
                      validator: (val) => (val == null || val == 'Select') ? 'Please select a process' : null,
                    ),
                  ],
                ),
              ),

              // Date Selection Card
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.date_range_outlined, color: Color(0xFF2196F3)),
                          const SizedBox(width: 8),
                          Text('Date Information', style: Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Submission Date', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _submissionDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Submission Date',
                          hintText: 'Select Submission Date',
                          suffixIcon: IconButton(icon: const Icon(Icons.calendar_today), onPressed: _pickSubmissionDate),
                        ),
                        onTap: _pickSubmissionDate,
                        validator: (val) => (val == null || val.isEmpty) ? 'Please select a submission date' : null,
                      ),
                      const SizedBox(height: 16),
                      Text('Report Date', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _reportDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Report Date',
                          hintText: 'Select Report Date',
                          suffixIcon: IconButton(icon: const Icon(Icons.calendar_today), onPressed: _pickReportDate),
                        ),
                        onTap: _pickReportDate,
                        validator: (val) => (val == null || val.isEmpty) ? 'Please select a report date' : null,
                      ),
                    ],
                  ),
                ),
              ),

              // Purchaser Name
              TextFormField(
                controller: _purchaserNameController,
                decoration: InputDecoration(
                  labelText: 'Purchaser Name',
                  hintText: 'Enter Purchaser Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Topic Discussed
              TextFormField(
                controller: _topicDiscussedController,
                decoration: InputDecoration(
                  labelText: 'Topic Discussed',
                  hintText: 'Enter Topic Discussed',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Remarks
              TextFormField(
                controller: _remarksController,
                decoration: InputDecoration(
                  labelText: 'Remarks',
                  hintText: 'Enter Remarks',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                minLines: 2,
                maxLines: 4,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Image Upload Card
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.photo_library_rounded, color: Colors.blue, size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Supporting Documents',
                              style: Theme.of(context).textTheme.titleLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_circle),
                            color: Colors.blue,
                            onPressed: _addRow,
                            tooltip: 'Add Image Row',
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle),
                            color: Colors.red,
                            onPressed: _removeRow,
                            tooltip: 'Remove Image Row',
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Upload images related to your activity', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _uploadRows.length,
                        itemBuilder: (_, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedImages[index] == null ? 'No image selected' : 'Image selected',
                                      style: TextStyle(
                                        color: _selectedImages[index] == null ? Colors.grey[600] : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: () => _pickImage(index),
                                    icon: const Icon(Icons.add_photo_alternate),
                                    label: const Text('Select'),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                  if (_selectedImages[index] != null) ...[
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.visibility),
                                      onPressed: () => _showImageDialog(_selectedImages[index]!),
                                      tooltip: 'View Image',
                                      color: Colors.blue,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Submit Button
              ElevatedButton(
                onPressed: _onSubmit,
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
