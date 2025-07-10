import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:learning2/core/constants/fonts.dart';

class EmployeeMaster extends StatefulWidget {
  const EmployeeMaster({super.key});

  @override
  State<EmployeeMaster> createState() => _EmployeeMasterState();
}

class _EmployeeMasterState extends State<EmployeeMaster> {
  // Image picker and selected image
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Fields with their metadata
  late final List<Map<String, dynamic>> fields;

  final List<String> dateFields = [
    'Birth Date',
    'Group Join Date',
    'Unit Join Date',
    'Confirmation Date',
    'Anniv. Date',
    'Left Date',
  ];

  @override
  void initState() {
    super.initState();
    fields = [
      {
        'type': 'dropdown',
        'label': 'Process Type',
        'items': ['Add', 'Update'],
        'value': 'Add',
      },
      {
        'label': 'Employee Code',
        'controller': TextEditingController(),
        'suffixIcon': Icons.search,
      },
      {
        'label': 'Location',
        'controller': TextEditingController(),
        'suffixIcon': Icons.search,
      },
      {'label': 'Area', 'controller': TextEditingController()},
      {
        'label': 'Dept Code',
        'controller': TextEditingController(),
        'suffixIcon': Icons.search,
      },
      {'type': 'image'},
      {'label': 'First Name', 'controller': TextEditingController()},
      {'label': 'Second Name', 'controller': TextEditingController()},
      {'label': 'Last Name', 'controller': TextEditingController()},
      {'label': 'Fathers Name *', 'controller': TextEditingController()},
      {
        'type': 'dropdown',
        'label': 'Male / Female',
        'value': 'Select',
        'items': ['Select', 'Male', 'Female'],
      },
      {'label': 'Qtr No', 'controller': TextEditingController()},
      {
        'type': 'dropdown',
        'label': 'Grade',
        'value': 'Select',
        'items': [
          'Select',
          '',
          'B',
          'C',
          'EXECUTIVE (EP)',
          'JEP',
          'SR VP',
          'VP',
          'ASST VP',
          'GENERAL MANAGER',
          'DY G M',
          'SR.MANAGER',
          'MANAGER',
          'DY MANAGER',
          'ASST MANAGER',
          'SR OFFICER',
          'OFFICER',
          'ASST OFFICER',
          'JUNIOR OFFICER',
          'SR SUPERVISOR',
          'SUPERVISOR',
          'SUPPORT STAFF',
          'Sr President',
        ],
      },
      {
        'type': 'dropdown',
        'label': 'Designation',
        'value': 'Select',
        'items': [
          'Select',
          'President',
          'Joint Executive President',
          'Senior Vice President',
          'Vice President',
          'Assistant Vice President',
          'General Manager',
          'Deputy General Manager',
          'Senior Manager',
          'Manager',
          'Deputy Manager',
          'Assistant Manager',
          'Senior Engineer',
          'Senior Officer',
          'Engineer',
          'G.E.T.',
          'M.T.',
          'Officer',
          'Assistant Engineer',
          'Assistant Officer',
          'Junior Engineer',
          'Junior Officer',
          'Senior Supervisor',
          'Supervisor',
          'Trainee Supervisor',
          'Support Staff',
          'DG-Cum-TG Operator',
          'C.E.O.',
          'Executive Assistant',
          'DET',
          'Assistant Officer (Trainee)',
          'Asst General Manager',
          'Joint President',
          'Assistant General Manager',
          'Senior General Manager',
          'SBU Head',
          'Staff Trainee',
          'Trainee',
        ],
      },

      {
        'type': 'dropdown',
        'label': 'Job Band',
        'value': 'Select',
        'items': [
          'Select',
          'Job Band 001',
          'Job Band 002',
          'Job Band 003',
          'Job Band 004',
          'Job Band 005',
          'Job Band 006',
          'Job Band 007',
          'Job Band 008',
          'Job Band 009',
          'Job Band 010',
          'Job Band 011',
          'Job Band 11B',
        ],
      },

      {'label': 'Birth Date', 'controller': TextEditingController()},
      {'label': 'Group Join Date', 'controller': TextEditingController()},
      {'label': 'Unit Join Date', 'controller': TextEditingController()},
      {'label': 'Confirmation Date', 'controller': TextEditingController()},
      {'label': 'Anniv. Date', 'controller': TextEditingController()},
      {'label': 'Left Date', 'controller': TextEditingController()},
      {
        'type': 'dropdown',
        'label': 'Employee Status',
        'value': 'Select',
        'items': [
          'Select',
          'Confirmation',
          'Probation',
          'Trial',
          'Training',
        ],
      },

      {
        'type': 'dropdown',
        'label': 'Marital Status',
        'value': 'Select',
        'items': ['Select', 'Single', 'Married'],
      },
      {
        'type': 'dropdown',
        'label': 'Job Band / Grade',
        'value': 'Select',
        'items': ['Select', 'Band 1', 'Band 2'],
      },
      {'label': 'Pf Number', 'controller': TextEditingController()},
      {
        'label': 'Pf Additional Perc',
        'controller': TextEditingController(text: '0'),
      },
      {'label': 'Basic Rate', 'controller': TextEditingController(text: '0')},
      {'label': 'Address1 *', 'controller': TextEditingController()},
      {'label': 'Address2 *', 'controller': TextEditingController()},
      {'label': 'Address3', 'controller': TextEditingController()},
      {'label': 'City *', 'controller': TextEditingController()},
      {
        'type': 'dropdown',
        'label': 'Native State',
        'value': 'Select',
        'items': [
          'Select',
          'Andaman & Nicobar Islands',
          'Andhra Pradesh',
          'Arunachal Pradesh',
          'Assam',
          'Bihar',
          'Chandigarh',
          'Chhattisgarh',
          'Dadra & Nagar Haveli',
          'Daman & Diu',
          'Export-Domestic',
          'Export-International',
          'Goa',
          'Gujarat',
          'Haryana',
          'Himachal Pradesh',
          'Jammu & Kashmir',
          'Jharkhand',
          'Karnataka',
          'Kerala',
          'Lakshadweep',
          'Madhya Pradesh',
          'Maharashtra',
          'Manipur',
          'Meghalaya',
          'Mizoram',
          'Nagaland',
          'Nct Of Delhi',
          'Odisha',
          'Puducherry',
          'Punjab',
          'Rajasthan',
          'Sikkim',
          'Tamil Nadu',
          'Telangana',
          'Tripura',
          'Uttar Pradesh',
          'Uttarakhand',
          'West Bengal',
        ],
      },

      {'label': 'Pin Code', 'controller': TextEditingController()},
      {'label': 'Res No', 'controller': TextEditingController()},
      {'label': 'Mobile No', 'controller': TextEditingController()},
      {'label': 'Pan No', 'controller': TextEditingController()},
      {'label': 'Pooranata Employee No', 'controller': TextEditingController()},
      {'label': 'Spouse Name *', 'controller': TextEditingController()},
      {
        'type': 'dropdown',
        'label': 'Permanent Address in Jodhpur Dist.(Yes/No)',
        'value': 'Select',
        'items': ['Select', 'Yes', 'No'],
      },
      {
        'type': 'dropdown',
        'label': 'Employee Category',
        'value': 'Select',
        'items': [
          'Select',
          'Area Sales Head',
          'Sr Territory Sales Incharge',
          'Territory Sales Incharge',
          'TSI Institutional Sales',
          'Area Sales Head Rural',
          'Regional Head Rural',
          'Sr Area Sales Head',
          'RM Institutional',
          'Sr TSI Institutional Sales',
          'Zonal Head',
          'State Head',
          'Unit Head',
          'Function Head',
          'Dept Head For Plant Employee',
          'Section Head For Plant Employee',
          'FLE For Plant Employee',
          'TSI - CASC',
          'Sales Executive',
          'Sr Sales Executive',
          'Sales Executive Institutional Sales',
          'Sr Sales Executive Institutional Sales',
          'SR - CASC',
        ],
      },

      {'label': 'Previous Employer', 'controller': TextEditingController()},
      {'label': 'Experience', 'controller': TextEditingController(text: '0')},
      {
        'type': 'dropdown',
        'label': 'Punching At Site Flag',
        'value': 'Select',
        'items': ['Select', 'Yes', 'No'],
      },
      {'label': 'Blood Group', 'controller': TextEditingController()},
      {'label': 'Qual. Desc', 'controller': TextEditingController()},
      {'label': 'Qual. Year', 'controller': TextEditingController()},
      {
        'type': 'dropdown',
        'label': 'Reg./Cor./Pvt.',
        'value': 'Select',
        'items': [
          'Select',
          'Correspond',
          'Distance Learning',
          'Private',
          'Regular',
        ],
      },

      {
        'type': 'dropdown',
        'label': 'IRS Transfer Flag(Yes/No)',
        'value': 'Select',
        'items': ['Select', 'Yes', 'No'],
      },
      {'label': 'IRS Unit Name', 'controller': TextEditingController()},
      {'label': 'Left Reason', 'controller': TextEditingController()},
      {
        'type': 'dropdown',
        'label': 'Is Active Flag',
        'value': 'Yes',
        'items': ['Yes', 'No'],
      },
      {
        'type': 'dropdown',
        'label': 'Employee Position Code (Marketing)',
        'value': 'Select',
        'items': ['Select'],
      },
    ];
  }

  @override
  void dispose() {
    for (final field in fields) {
      if (field['controller'] != null) field['controller'].dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, Map<String, dynamic> field) async {
    final now = DateTime.now();
    final initialDate = DateTime.tryParse(field['controller']?.text ?? '') ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1960),
      lastDate: DateTime(now.year + 10),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.blue.shade700,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        field['controller'].text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Master'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          color: const Color(0xFFF7F9FC),
          child: ListView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
            itemCount: fields.length + 1,
            itemBuilder: (context, i) {
              if (i == fields.length) {
                // Centered Submit Button
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(
                    child: SizedBox(
                      width: 180,
                      child: ElevatedButton(
                        onPressed: () {
                          // You can add your form submission logic here
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Submitted!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[500],
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('Submit', style: Fonts.bodyBold.copyWith(fontSize: 19)),
                      ),
                    ),
                  ),
                );
              }
              final field = fields[i];
              if (field['type'] == 'dropdown') {
                return _dropdownField(field);
              }
              if (field['type'] == 'image') {
                return _imageUploadField();
              }
              // Check if field is a date field
              if (dateFields.contains(field['label'])) {
                return _formField(
                  field['label'],
                  field['controller'],
                  readOnly: true,
                  suffixIcon: Icons.calendar_month,
                  onTap: () => _pickDate(context, field),
                );
              }
              return _formField(
                field['label'],
                field['controller'],
                readOnly: field['readOnly'] ?? false,
                suffixIcon: field['suffixIcon'],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _formField(
      String label,
      TextEditingController controller, {
        bool readOnly = false,
        IconData? suffixIcon,
        VoidCallback? onTap,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Fonts.body.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            decoration: InputDecoration(
              suffixIcon: suffixIcon != null
                  ? Icon(suffixIcon, color: Colors.blue.shade400)
                  : null,
              filled: true,
              fillColor: const Color(0xFFF3F7FB),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(
                  color: Colors.blueGrey.shade50,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(
                  color: Colors.blueGrey.shade100,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownField(Map<String, dynamic> field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field['label'],
            style: Fonts.body.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: field['value'],
            items: field['items']!
                .map<DropdownMenuItem<String>>(
                  (e) => DropdownMenuItem<String>(value: e, child: Text(e)),
            )
                .toList(),
            onChanged: (val) => setState(() => field['value'] = val),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF3F7FB),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(
                  color: Colors.blueGrey.shade50,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(
                  color: Colors.blueGrey.shade100,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageUploadField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Image Upload (in Update Mode,\nNo Need of submit after Upload\nClick Image or Refresh Page)",
            style: Fonts.body.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Column(
              children: [
                // The gesture area for preview
                GestureDetector(
                  onTap: _selectedImage != null
                      ? () {
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        backgroundColor: Colors.transparent,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: InteractiveViewer(
                            minScale: 0.7,
                            maxScale: 4,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                      : null,
                  child: _selectedImage != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue.shade100),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image, color: Colors.blueGrey, size: 40),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await _picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 600,
                    );
                    if (picked != null) {
                      setState(() => _selectedImage = File(picked.path));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    minimumSize: const Size(0, 40), // Height fixed, width flexible
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Upload Image', style: Fonts.body.copyWith(fontWeight: FontWeight.w600, fontSize: 16)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}
