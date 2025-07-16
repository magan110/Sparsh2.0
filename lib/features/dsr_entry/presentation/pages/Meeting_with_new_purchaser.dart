import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learning2/core/theme/app_theme.dart';
import 'dsr_entry.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/document_number_storage.dart';
import 'dsr_exception_entry.dart';

class MeetingWithNewPurchaser extends StatefulWidget {
  const MeetingWithNewPurchaser({super.key});
  @override
  State<MeetingWithNewPurchaser> createState() => _MeetingWithNewPurchaserState();
}

class _MeetingWithNewPurchaserState extends State<MeetingWithNewPurchaser> {
  // Process type dropdown state
  String? _processItem = 'Select';
  List<String> _processdropdownItems = ['Select'];
  bool _isLoadingProcessTypes = true;
  String? _processTypeError;

  // Document-number dropdown state
  bool _loadingDocs = false;
  List<String> _documentNumbers = [];
  String? _selectedDocuNumb;

  final _submissionDateController = TextEditingController();
  final _reportDateController = TextEditingController();
  final _purchaserNameController = TextEditingController();
  final _topicDiscussedController = TextEditingController();
  final _remarksController = TextEditingController();

  DateTime? _selectedSubmissionDate;
  DateTime? _selectedReportDate;
  final List<int> _uploadRows = [0];
  final ImagePicker _picker = ImagePicker();
  final List<File?> _selectedImages = [null];
  final _formKey = GlobalKey<FormState>();

  final _documentNumberController = TextEditingController();
  String? _documentNumber;

  @override
  void initState() {
    super.initState();
    _loadInitialDocumentNumber();
    _fetchProcessTypes();
    _setSubmissionDateToToday();
  }

  // Load document number when screen initializes
  Future<void> _loadInitialDocumentNumber() async {
    final savedDocNumber = await DocumentNumberStorage.loadDocumentNumber(DocumentNumberKeys.meetingNewPurchaser);
    if (savedDocNumber != null) {
      setState(() {
        _documentNumber = savedDocNumber;
      });
    }
  }

  // Fetch process types from backend
  Future<void> _fetchProcessTypes() async {
    setState(() { _isLoadingProcessTypes = true; _processTypeError = null; });
    try {
      final url = Uri.parse('http://192.168.36.25/api/DsrTry/getProcessTypes');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List processTypesList = [];
        if (data is List) {
          processTypesList = data;
        } else if (data is Map &&
            (data['ProcessTypes'] != null || data['processTypes'] != null)) {
          processTypesList =
              (data['ProcessTypes'] ?? data['processTypes']) as List;
        }
        final processTypes = processTypesList
            .map<String>((type) {
              if (type is Map) {
                return type['Description']?.toString() ??
                    type['description']?.toString() ??
                    '';
              } else {
                return type.toString();
              }
            })
            .where((desc) => desc.isNotEmpty)
            .toList();
        setState(() {
          _processdropdownItems = ['Select', ...processTypes];
          _processItem = 'Select';
          _isLoadingProcessTypes = false;
        });
      } else {
        throw Exception('Failed to load process types.');
      }
    } catch (e) {
      setState(() {
        _processdropdownItems = ['Select'];
        _processItem = 'Select';
        _isLoadingProcessTypes = false;
        _processTypeError = 'Failed to load process types.';
      });
    }
  }

  // Fetch document numbers for Update
  Future<void> _fetchDocumentNumbers() async {
    setState(() {
      _loadingDocs = true;
      _documentNumbers = [];
      _selectedDocuNumb = null;
    });
    final uri = Uri.parse(
      'http://192.168.36.25/api/DsrTry/getDocumentNumbers?dsrParam=50' // Use correct param for this activity
    );
    try {
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as List;
        setState(() {
          _documentNumbers = data
            .map((e) {
              return (e['DocuNumb']
                   ?? e['docuNumb']
                   ?? e['DocumentNumber']
                   ?? e['documentNumber']
                   ?? '').toString();
            })
            .where((s) => s.isNotEmpty)
            .toList();
        });
      }
    } catch (_) {
      // ignore errors
    } finally {
      setState(() { _loadingDocs = false; });
    }
  }

  // Fetch details for a document number and populate fields
  Future<void> _fetchAndPopulateDetails(String docuNumb) async {
    final uri = Uri.parse('http://192.168.36.25/api/DsrTry/getDsrEntry?docuNumb=$docuNumb');
    try {
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        setState(() {
          _purchaserNameController.text = data['Purchaser'] ?? '';
          _topicDiscussedController.text = data['dsrRem01'] ?? '';
          _remarksController.text = data['dsrRem02'] ?? '';
          if (data['SubmissionDate'] != null) {
            _selectedSubmissionDate = DateTime.tryParse(data['SubmissionDate']);
            if (_selectedSubmissionDate != null) {
              _submissionDateController.text = DateFormat('yyyy-MM-dd').format(_selectedSubmissionDate!);
            }
          }
          if (data['ReportDate'] != null) {
            _selectedReportDate = DateTime.tryParse(data['ReportDate']);
            if (_selectedReportDate != null) {
              _reportDateController.text = DateFormat('yyyy-MM-dd').format(_selectedReportDate!);
            }
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _submissionDateController.dispose();
    _reportDateController.dispose();
    _purchaserNameController.dispose();
    _topicDiscussedController.dispose();
    _remarksController.dispose();
    _documentNumberController.dispose();
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
      firstDate: DateTime(now.year - 10),
      lastDate: now,
    );
    if (picked != null) {
      if (picked.isBefore(threeDaysAgo)) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Please Put Valid DSR Date.'),
            content: const Text(
              'You Can submit DSR only Last Three Days. If You want to submit back date entry Please enter Exception entry (Path : Transcation --> DSR Exception Entry). Take Approval from concerned and Fill DSR Within 3 days after approval.'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DsrExceptionEntryPage()),
                  );
                },
                child: const Text('Go to Exception Entry'),
              ),
            ],
          ),
        );
        return;
      }
      setState(() {
        _selectedReportDate = picked;
        _reportDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickDate(TextEditingController controller, DateTime? selectedDate, ValueChanged<DateTime> onPicked) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) => Theme(
        data: SparshTheme.lightTheme,
        child: child!,
      ),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
      onPicked(picked);
    }
  }

  void _addRow() {
    setState(() {
      _uploadRows.add(_uploadRows.length);
      _selectedImages.add(null);
    });
  }

  void _removeRow() {
    if (_uploadRows.length > 1) {
      setState(() {
        _uploadRows.removeLast();
        _selectedImages.removeLast();
      });
    }
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
            image: DecorationImage(image: FileImage(imageFile), fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  void _onSubmit({required bool exitAfter}) async {
    if (!_formKey.currentState!.validate()) return;

    final dsrData = {
      'ActivityType': 'Meeting with New Purchaser(Trade Purchaser) / Retailer',
      'SubmissionDate': _selectedSubmissionDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'ReportDate': _selectedReportDate?.toIso8601String() ?? DateTime.now().toIso8601String(),


      'dsrRem01': _topicDiscussedController.text,
      'dsrRem02': _remarksController.text,
      'dsrRem03': '',
      'dsrRem04': '',
      'dsrRem05': '',
      'dsrRem06': '',
      'dsrRem07': '',
      'dsrRem08': '',
      'DsrParam': '50',
      'DocuNumb': _processItem == 'Update' ? _selectedDocuNumb : null,
      'ProcessType': _processItem == 'Update' ? 'U' : 'A',
    };

    try {
      final url = Uri.parse(
        'http://192.168.36.25/api/DsrTry/' + (_processItem == 'Update' ? 'update' : '')
      );
      final resp = _processItem == 'Update'
          ? await http.put(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(dsrData),
            )
          : await http.post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(dsrData),
            );

      final success = (_processItem == 'Update' && resp.statusCode == 204) ||
                      (_processItem != 'Update' && resp.statusCode == 201);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? exitAfter
                  ? '${_processItem == 'Update' ? 'Updated' : 'Submitted'} successfully. Exiting...'
                  : '${_processItem == 'Update' ? 'Updated' : 'Submitted'} successfully. Ready for new entry.'
              : 'Error: ${resp.body}'),
          backgroundColor: success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (success) {
        if (exitAfter) {
          Navigator.of(context).pop();
        } else {
          _resetForm();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exception: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Add a method to reset the form (clear document number)
  void _resetForm() {
    setState(() {
      _documentNumber = null;
      _documentNumberController.clear();
      _processItem = 'Select';
      // Clear other form fields as needed
    });
    DocumentNumberStorage.clearDocumentNumber(DocumentNumberKeys.meetingNewPurchaser); // Clear from persistent storage
  }

  Future<void> submitDsrEntry(Map<String, dynamic> dsrData) async {
    final url = Uri.parse('http://192.168.36.25/api/DsrTry');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dsrData),
    );
    print('Status: \\${response.statusCode}');
    print('Body: \\${response.body}');
    if (response.statusCode == 201) {
      print('✅ Data inserted successfully!');
    } else {
      print('❌ Data NOT inserted! Error: \\${response.body}');
    }
  }

  Future<String?> _fetchDocumentNumberFromServer() async {
    try {
      final url = Uri.parse('http://192.168.36.25/api/DsrTry/generateDocumentNumber');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode('KKR'), // Hardcoded to KKR
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String? documentNumber;
        if (data is Map<String, dynamic>) {
          documentNumber = data['documentNumber'] ?? data['DocumentNumber'] ?? data['docNumber'] ?? data['DocNumber'];
        } else if (data is String) {
          documentNumber = data;
        }
        
        // Save to persistent storage
        if (documentNumber != null) {
          await DocumentNumberStorage.saveDocumentNumber(DocumentNumberKeys.meetingNewPurchaser, documentNumber);
        }
        
        return documentNumber;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SparshTheme.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: SparshIconSize.lg),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DsrEntry())),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Meeting with New Purchaser', style: SparshTypography.heading5.copyWith(color: Colors.white)),
            Text('Daily Sales Report Entry', style: SparshTypography.bodySmall.copyWith(color: Colors.white70)),
          ],
        ),
        backgroundColor: SparshTheme.primaryBlueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Help information for Meeting with New Purchaser')),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SparshSpacing.md),
          child: Column(
            children: [
              _buildDropdownCard(),
              _buildDateCard(),
              _buildTextField(_purchaserNameController, 'Purchaser Name'),
              _buildTextField(_topicDiscussedController, 'Topic Discussed'),
              _buildTextField(_remarksController, 'Remarks', minLines: 2, maxLines: 4),
              _buildImageUploadCard(),
              const SizedBox(height: SparshSpacing.md),
              ElevatedButton(
                onPressed: () => _onSubmit(exitAfter: true),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: SparshSpacing.md,horizontal: SparshSpacing.lg),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SparshBorderRadius.md)),
                ),
                child: const Text('Submit', style: SparshTypography.button),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: SparshSpacing.md),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SparshBorderRadius.md)),
      child: Padding(
        padding: const EdgeInsets.all(SparshSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardTitle(Icons.settings_outlined, 'Process'),
            const SizedBox(height: SparshSpacing.md),
            if (_processTypeError != null)
              Text(_processTypeError!, style: const TextStyle(color: Colors.red)),
            _isLoadingProcessTypes
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : DropdownButtonFormField<String>(
                  value: _processItem,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: SparshTheme.lightGreyBackground,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(SparshBorderRadius.sm), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: SparshSpacing.md, vertical: SparshSpacing.sm),
                  ),
                  isExpanded: true,
                  items: _processdropdownItems.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                  onChanged: (val) async {
                    setState(() {
                      _processItem = val;
                    });
                    if (val == 'Update') await _fetchDocumentNumbers();
                  },
                  validator: (val) => val == 'Select' ? 'Please select a process' : null,
                ),
            if (_processItem == 'Update') ...[
              const SizedBox(height: 8.0),
              _loadingDocs
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    value: _selectedDocuNumb,
                    decoration: const InputDecoration(labelText: 'Document Number'),
                    items: _documentNumbers
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (v) async {
                      setState(() => _selectedDocuNumb = v);
                      if (v != null) await _fetchAndPopulateDetails(v);
                    },
                    validator: (v) => v == null ? 'Required' : null,
                  ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: SparshSpacing.md),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SparshBorderRadius.md)),
      child: Padding(
        padding: const EdgeInsets.all(SparshSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardTitle(Icons.date_range_outlined, 'Date Information'),
            const SizedBox(height: SparshSpacing.md),
            TextFormField(
              controller: _submissionDateController,
              readOnly: true,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Submission Date',
                filled: true,
                fillColor: SparshTheme.lightGreyBackground,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(SparshBorderRadius.md), borderSide: BorderSide.none),
                suffixIcon: const Icon(Icons.lock, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(horizontal: SparshSpacing.md, vertical: SparshSpacing.sm),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Submission date required' : null,
            ),
            const SizedBox(height: SparshSpacing.md),
            TextFormField(
              controller: _reportDateController,
              readOnly: true,
              onTap: _pickReportDate,
              decoration: InputDecoration(
                labelText: 'Report Date',
                filled: true,
                fillColor: SparshTheme.lightGreyBackground,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(SparshBorderRadius.md), borderSide: BorderSide.none),
                suffixIcon: const Icon(Icons.calendar_today),
                contentPadding: const EdgeInsets.symmetric(horizontal: SparshSpacing.md, vertical: SparshSpacing.sm),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Report date required' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int minLines = 1, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SparshSpacing.md),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Enter $label',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(SparshBorderRadius.md)),
        ),
        minLines: minLines,
        maxLines: maxLines,
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildImageUploadCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: SparshSpacing.md),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SparshBorderRadius.md)),
      child: Padding(
        padding: const EdgeInsets.all(SparshSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardTitle(Icons.photo_library_rounded, 'Supporting Documents'),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(icon: const Icon(Icons.add_circle, color: SparshTheme.primaryBlue), onPressed: _addRow),
                IconButton(icon: const Icon(Icons.remove_circle, color: SparshTheme.errorRed), onPressed: _removeRow),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _uploadRows.length,
              itemBuilder: (_, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: SparshSpacing.md),
                  child: Container(
                    padding: const EdgeInsets.all(SparshSpacing.sm),
                    decoration: BoxDecoration(
                      color: SparshTheme.lightGreyBackground,
                      borderRadius: BorderRadius.circular(SparshBorderRadius.sm),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedImages[index] == null ? 'No image selected' : 'Image selected',
                            style: _selectedImages[index] == null ? SparshTypography.bodySmall : SparshTypography.bodyMedium,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(index),
                          icon: const Icon(Icons.add_photo_alternate),
                          label: const Text('Select'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SparshBorderRadius.sm)),
                          ),
                        ),
                        if (_selectedImages[index] != null) ...[
                          const SizedBox(width: SparshSpacing.sm),
                          IconButton(
                            icon: const Icon(Icons.visibility),
                            onPressed: () => _showImageDialog(_selectedImages[index]!),
                            color: SparshTheme.primaryBlue,
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
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: SparshTypography.bodyBold),
        const SizedBox(height: SparshSpacing.xs),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          decoration: InputDecoration(
            labelText: label,
            hintText: 'Select $label',
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          validator: (val) => val == null || val.isEmpty ? 'Please select $label' : null,
        ),
      ],
    );
  }

  Widget _cardTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: SparshTheme.primaryBlue),
        const SizedBox(width: SparshSpacing.sm),
        Text(title, style: SparshTypography.heading6),
      ],
    );
  }
}
