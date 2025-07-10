import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';

import 'dsr_entry.dart';
import 'package:learning2/core/constants/fonts.dart';

class MeetingsWithContractor extends StatefulWidget {
  const MeetingsWithContractor({super.key});

  @override
  State<MeetingsWithContractor> createState() => _MeetingsWithContractorState();
}

class _MeetingsWithContractorState extends State<MeetingsWithContractor> {
  String? _processItem = 'Select';
  final List<String> _processdropdownItems = ['Select', 'Add', 'Update'];

  String? _areaCode = 'Select';
  final List<String> _majorCitiesInIndia = [
    'Select', 'Mumbai', 'Delhi', 'Ahmedabad', 'Pune', 'Surat'
  ];
  final Map<String, Map<String, double>> _cityCoordinates = {
    'Mumbai': {'latitude': 19.0760, 'longitude': 72.8777},
    'Delhi': {'latitude': 28.7041, 'longitude': 77.1025},
    'Ahmedabad': {'latitude': 23.0225, 'longitude': 72.5714},
    'Pune': {'latitude': 18.5204, 'longitude': 73.8567},
    'Surat': {'latitude': 21.1702, 'longitude': 72.8311},
  };

  String? _purchaserItem = 'Select';
  final List<String> _purchaserdropdownItems = [
    'Select',
    'Purchaser(Non Trade)',
    'AUTHORISED DEALER',
  ];

  final TextEditingController _submissionDateController = TextEditingController();
  final TextEditingController _reportDateController     = TextEditingController();
  DateTime? _selectedSubmissionDate;
  DateTime? _selectedReportDate;

  final List<int> _uploadRows    = [0];
  final ImagePicker _picker      = ImagePicker();
  final List<File?> _selectedImages = [null];

  // Coordinate controllers (if you choose to display these)
  final TextEditingController _yourLatitudeController  = TextEditingController();
  final TextEditingController _yourLongitudeController = TextEditingController();
  final TextEditingController _custLatitudeController  = TextEditingController();
  final TextEditingController _custLongitudeController = TextEditingController();

  // Hidden required fields for your original API (kept hidden in UI)
  final TextEditingController _contrnamController  = TextEditingController();
  final TextEditingController _topcdissController  = TextEditingController();
  final TextEditingController _remarkscController  = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _submissionDateController.dispose();
    _reportDateController.dispose();
    _yourLatitudeController.dispose();
    _yourLongitudeController.dispose();
    _custLatitudeController.dispose();
    _custLongitudeController.dispose();
    _contrnamController.dispose();
    _topcdissController.dispose();
    _remarkscController.dispose();
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

  void _onSubmit({required bool exitAfter}) {
    if (!_formKey.currentState!.validate()) return;

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
      _resetForm();
    }
  }

  void _resetForm() {
    setState(() {
      _processItem = 'Select';
      _areaCode = 'Select';
      _purchaserItem = 'Select';

      _selectedSubmissionDate = null;
      _selectedReportDate     = null;
      _submissionDateController.clear();
      _reportDateController.clear();

      _yourLatitudeController.clear();
      _yourLongitudeController.clear();
      _custLatitudeController.clear();
      _custLongitudeController.clear();

      _contrnamController.clear();
      _topcdissController.clear();
      _remarkscController.clear();

      _uploadRows
        ..clear()
        ..add(0);
      _selectedImages
        ..clear()
        ..add(null);
    });
    _formKey.currentState!.reset();
  }

  Widget _buildTextField(
      String hintText, {
        TextEditingController? controller,
        TextInputType? keyboardType,
        int maxLines = 1,
        String? Function(String?)? validator,
        bool readOnly = false,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      validator: validator,
    );
  }

  Widget _buildDateField(
      TextEditingController controller,
      VoidCallback onTap,
      String hintText,
      ) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
        suffixIcon: IconButton(icon: const Icon(Icons.calendar_today, color: Colors.blueAccent), onPressed: onTap),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      onTap: onTap,
      validator: (value) => (value == null || value.isEmpty) ? 'Please select a date' : null,
    );
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: Fonts.body.copyWith(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87),
  );

  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        color: Colors.white,
      ),
      child: DropdownButton<String>(
        dropdownColor: Colors.white,
        isExpanded: true,
        underline: Container(),
        value: value,
        onChanged: onChanged,
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item, style: Fonts.body.copyWith(fontSize: 16, color: Colors.black87))))
            .toList(),
      ),
    );
  }

  Widget _buildSearchableDropdownField({
    required String selected,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) =>
      DropdownSearch<String>(
        items: items,
        selectedItem: selected,
        onChanged: onChanged,
        validator: validator,
        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: const TextFieldProps(
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: TextStyle(color: Colors.black54),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                borderSide: BorderSide(color: Colors.blueAccent),
              ),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          itemBuilder: (context, item, isSelected) => Padding(
            padding: const EdgeInsets.all(12),
            child: Text(item, style: Fonts.body.copyWith(color: Colors.black87)),
          ),
        ),
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            hintText: 'Select',
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DsrEntry())),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
          ),
          title: const Text(
            'Meetings With Contractor',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: const Color(0xFF2196F3),
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.grey.shade100, Colors.white],
              stops: const [0.0, 1.0],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildLabel('Process type'),
                  const SizedBox(height: 8),
                  _buildDropdownField(
                    value: _processItem,
                    items: _processdropdownItems,
                    onChanged: (val) => setState(() => _processItem = val),
                  ),

                  const SizedBox(height: 24),
                  _buildLabel('Submission Date'),
                  const SizedBox(height: 8),
                  _buildDateField(_submissionDateController, _pickSubmissionDate, 'Select Date'),

                  const SizedBox(height: 24),
                  _buildLabel('Report Date'),
                  const SizedBox(height: 8),
                  _buildDateField(_reportDateController, _pickReportDate, 'Select Date'),

                  const SizedBox(height: 24),
                  _buildLabel('Area code *:'),
                  const SizedBox(height: 8),
                  _buildSearchableDropdownField(
                    selected: _areaCode!,
                    items: _majorCitiesInIndia,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _areaCode = val;
                          if (_cityCoordinates.containsKey(val)) {
                            _custLatitudeController.text =
                                _cityCoordinates[val]!['latitude']!.toString();
                            _custLongitudeController.text =
                                _cityCoordinates[val]!['longitude']!.toString();
                          } else {
                            _custLatitudeController.clear();
                            _custLongitudeController.clear();
                          }
                        });
                      }
                    },
                    validator: (val) => (val == null || val == 'Select') ? 'Please select an Area Code' : null,
                  ),

                  const SizedBox(height: 24),
                  _buildLabel('Purchaser'),
                  const SizedBox(height: 8),
                  _buildDropdownField(
                    value: _purchaserItem,
                    items: _purchaserdropdownItems,
                    onChanged: (val) => setState(() => _purchaserItem = val),
                  ),

                  const SizedBox(height: 24),
                  _buildLabel('Upload Supporting'),
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.photo_library_rounded, color: Color(0xFF2196F3), size: 24),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Supporting Documents',
                                style: Fonts.bodyBold.copyWith(fontSize: 18, color: const Color(0xFF2196F3)),
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Upload images related to your activity', style: Fonts.body.copyWith(fontSize: 14, color: Colors.grey.shade600)),
                        const SizedBox(height: 16),
                        ...List.generate(_uploadRows.length, (index) {
                          final file = _selectedImages[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: file != null ? Colors.green.shade200 : Colors.grey.shade200, width: 1.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2196F3).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text('Document ${index + 1}',
                                          style: Fonts.bodyBold.copyWith(fontSize: 14, color: const Color(0xFF2196F3))),
                                    ),
                                    const Spacer(),
                                    if (file != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration:
                                        BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(20)),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.check_circle, color: Colors.green, size: 16),
                                            SizedBox(width: 4),
                                            Text('Uploaded',
                                                style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500, fontSize: 14)),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (file != null)
                                  GestureDetector(
                                    onTap: () => _showImageDialog(file),
                                    child: Container(
                                      height: 120,
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
                                      ),
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          margin: const EdgeInsets.all(8),
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
                                          child: const Icon(Icons.zoom_in, color: Colors.white, size: 20),
                                        ),
                                      ),
                                    ),
                                  ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _pickImage(index),
                                        icon: Icon(file != null ? Icons.refresh : Icons.upload_file, size: 18),
                                        label: Text(file != null ? 'Replace' : 'Upload'),
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: file != null ? Colors.amber.shade600 : const Color(0xFF2196F3),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                    ),
                                    if (_uploadRows.length > 1)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: ElevatedButton.icon(
                                          onPressed: _removeRow,
                                          icon: const Icon(Icons.remove_circle_outline, size: 20),
                                          label: const Text('Remove'),
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor: Colors.redAccent,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _addRow,
                              icon: const Icon(Icons.add_photo_alternate, size: 20),
                              label: const Text('Document'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.blueAccent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () => _onSubmit(exitAfter: false),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: Fonts.bodyBold.copyWith(fontSize: 16),
                          elevation: 3.0,
                        ),
                        child: const Text('Submit & New'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _onSubmit(exitAfter: true),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: Fonts.bodyBold.copyWith(fontSize: 16),
                          elevation: 3.0,
                        ),
                        child: const Text('Submit & Exit'),
                      ),
                    ],
                  ),

                  // Hidden offstage fields (unchanged UI)
                  Offstage(
                    offstage: true,
                    child: Column(
                      children: [
                        TextFormField(controller: _contrnamController),
                        TextFormField(controller: _topcdissController),
                        TextFormField(controller: _remarkscController),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
