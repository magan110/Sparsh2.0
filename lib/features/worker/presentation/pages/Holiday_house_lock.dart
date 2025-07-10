import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:learning2/core/constants/fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leave Application',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
      home: const HolidayHouseLock(),
    );
  }
}

class HolidayHouseLock extends StatefulWidget {
  const HolidayHouseLock({super.key});

  @override
  State<HolidayHouseLock> createState() => _HolidayHouseLockState();
}

class _HolidayHouseLockState extends State<HolidayHouseLock> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _fromDate;
  DateTime? _toDate;
  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;
  String? _purpose = 'Leave';
  String? _otherPurpose;

  final TextEditingController _employeeIdController = TextEditingController(text: 'S0857');
  final TextEditingController _employeeNameController = TextEditingController(text: 'Ram Babu Gupta');
  final TextEditingController _houseNoController = TextEditingController(text: 'C - 10');
  final TextEditingController _mobileNoController = TextEditingController(text: '9799290049');
  final TextEditingController _documentNoController = TextEditingController(text: 'Document no for update');

  @override
  void initState() {
    super.initState();
    // Set default dates to today and tomorrow
    _fromDate = DateTime.now();
    _toDate = DateTime.now().add(const Duration(days: 1));
    _fromTime = const TimeOfDay(hour: 11, minute: 31);
    _toTime = const TimeOfDay(hour: 11, minute: 31);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Holiday House Lock '),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader('Process Information'),
              _buildProcessInfoSection(),
              const SizedBox(height: 20),
              _buildSectionHeader('Employee Details'),
              _buildEmployeeDetailsSection(),
              const SizedBox(height: 20),
              _buildSectionHeader('Visit Details'),
              _buildVisitDetailsSection(),
              const SizedBox(height: 30),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: Fonts.heading2.copyWith(color: Colors.blue.shade800),
      ),
    );
  }

  Widget _buildProcessInfoSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Process Type',
                    ),
                    value: 'Add',
                    items: const [
                      DropdownMenuItem(value: 'Add', child: Text('Add')),
                      DropdownMenuItem(value: 'Edit', child: Text('Edit')),
                      DropdownMenuItem(value: 'Delete', child: Text('Delete')),
                    ],
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: _documentNoController,
                    decoration: const InputDecoration(
                      labelText: 'Document No',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter document number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeDetailsSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _employeeIdController,
                    decoration: const InputDecoration(
                      labelText: 'Employee ID',
                    ),
                    readOnly: true,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: _employeeNameController,
                    decoration: const InputDecoration(
                      labelText: 'Employee Name',
                    ),
                    readOnly: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _houseNoController,
                    decoration: const InputDecoration(
                      labelText: 'Employee House No',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter house number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: _mobileNoController,
                    decoration: const InputDecoration(
                      labelText: 'Employee Mobile No',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter mobile number';
                      }
                      if (value.length != 10) {
                        return 'Enter valid 10-digit number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Purpose of Visit',
              ),
              value: _purpose,
              items: const [
                DropdownMenuItem(value: 'Leave', child: Text('Leave')),
                DropdownMenuItem(value: 'Meeting', child: Text('OD')),
                DropdownMenuItem(value: 'Training', child: Text('C Shift')),
                DropdownMenuItem(value: 'Other', child: Text('Off Duty')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (value) {
                setState(() {
                  _purpose = value;
                });
              },
            ),
            if (_purpose == 'Other')
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Other Purpose',
                  ),
                  onChanged: (value) {
                    _otherPurpose = value;
                  },
                  validator: (value) {
                    if (_purpose == 'Other' && (value == null || value.isEmpty)) {
                      return 'Please specify purpose';
                    }
                    return null;
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitDetailsSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Visit Place',
                hintText: 'Enter visit location',
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'From Date',
                      ),
                      child: Text(
                        _fromDate != null
                            ? DateFormat('dd/MM/yyyy').format(_fromDate!)
                            : 'Select date',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'From Time',
                      ),
                      child: Text(
                        _fromTime != null
                            ? _fromTime!.format(context)
                            : 'Select time',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'To Date',
                      ),
                      child: Text(
                        _toDate != null
                            ? DateFormat('dd/MM/yyyy').format(_toDate!)
                            : 'Select date',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'To Time',
                      ),
                      child: Text(
                        _toTime != null
                            ? _toTime!.format(context)
                            : 'Select time',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade700,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text('Your Holiday House Lock Security has been submitted successfully.', style: Fonts.bodyBold.copyWith(fontSize: 16, color: Colors.white)),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? _fromDate! : _toDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isFromTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isFromTime ? _fromTime! : _toTime!,
    );
    if (picked != null) {
      setState(() {
        if (isFromTime) {
          _fromTime = picked;
        } else {
          _toTime = picked;
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, proceed with submission
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Holiday House Lock Security'),
          content: const Text('Your Holiday House Lock Security has been submitted successfully.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      // Here you would typically send the data to your backend
      print('Form submitted with:');
      print('Employee ID: ${_employeeIdController.text}');
      print('Employee Name: ${_employeeNameController.text}');
      print('House No: ${_houseNoController.text}');
      print('Mobile No: ${_mobileNoController.text}');
      print('Purpose: ${_purpose == 'Other' ? _otherPurpose : _purpose}');
      print('From: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime(
        _fromDate!.year,
        _fromDate!.month,
        _fromDate!.day,
        _fromTime!.hour,
        _fromTime!.minute,
      ))}');
      print('To: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime(
        _toDate!.year,
        _toDate!.month,
        _toDate!.day,
        _toTime!.hour,
        _toTime!.minute,
      ))}');
    }
  }

  @override
  void dispose() {
    _employeeIdController.dispose();
    _employeeNameController.dispose();
    _houseNoController.dispose();
    _mobileNoController.dispose();
    _documentNoController.dispose();
    super.dispose();
  }
}

