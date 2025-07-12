import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/components/advanced_3d_components.dart';
import '../../../../core/utils/responsive_util.dart';

class HolidayHouseLock extends StatefulWidget {
  const HolidayHouseLock({super.key});

  @override
  State<HolidayHouseLock> createState() => _HolidayHouseLockState();
}

class _HolidayHouseLockState extends State<HolidayHouseLock> 
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  DateTime? _fromDate;
  DateTime? _toDate;
  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;
  String? _purpose = 'Leave';
  String? _otherPurpose;
  String? _processType = 'Add';
  String? _visitPlace;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _employeeIdController = TextEditingController(text: 'S0857');
  final TextEditingController _employeeNameController = TextEditingController(text: 'Ram Babu Gupta');
  final TextEditingController _houseNoController = TextEditingController(text: 'C - 10');
  final TextEditingController _mobileNoController = TextEditingController(text: '9799290049');
  final TextEditingController _documentNoController = TextEditingController(text: 'Document no for update');
  final TextEditingController _visitPlaceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Set default dates to today and tomorrow
    _fromDate = DateTime.now();
    _toDate = DateTime.now().add(const Duration(days: 1));
    _fromTime = const TimeOfDay(hour: 11, minute: 31);
    _toTime = const TimeOfDay(hour: 11, minute: 31);
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _employeeIdController.dispose();
    _employeeNameController.dispose();
    _houseNoController.dispose();
    _mobileNoController.dispose();
    _documentNoController.dispose();
    _visitPlaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SparshTheme.scaffoldBackground,
      appBar: Advanced3DAppBar(
        title: Text(
          'Holiday House Lock',
          style: SparshTypography.heading5.copyWith(color: Colors.white),
        ),
        backgroundColor: SparshTheme.primaryBlue,
        enableGlassMorphism: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: ResponsiveUtil.scaledPadding(context, all: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProcessInfoSection(),
                SizedBox(height: ResponsiveUtil.scaledSize(context, 20)),
                _buildEmployeeDetailsSection(),
                SizedBox(height: ResponsiveUtil.scaledSize(context, 20)),
                _buildVisitDetailsSection(),
                SizedBox(height: ResponsiveUtil.scaledSize(context, 30)),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProcessInfoSection() {
    return Advanced3DCard(
      enableGlassMorphism: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Process Information', Icons.settings),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          Row(
            children: [
              Expanded(
                child: _buildAdvanced3DDropdown(
                  label: 'Process Type',
                  value: _processType,
                  items: const ['Add', 'Edit', 'Delete'],
                  onChanged: (value) {
                    setState(() {
                      _processType = value;
                    });
                  },
                ),
              ),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 15)),
              Expanded(
                child: _buildAdvanced3DTextField(
                  controller: _documentNoController,
                  label: 'Document No',
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
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildEmployeeDetailsSection() {
    return Advanced3DCard(
      enableGlassMorphism: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Employee Details', Icons.person),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          Row(
            children: [
              Expanded(
                child: _buildAdvanced3DTextField(
                  controller: _employeeIdController,
                  label: 'Employee ID',
                  readOnly: true,
                ),
              ),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 15)),
              Expanded(
                child: _buildAdvanced3DTextField(
                  controller: _employeeNameController,
                  label: 'Employee Name',
                  readOnly: true,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          Row(
            children: [
              Expanded(
                child: _buildAdvanced3DTextField(
                  controller: _houseNoController,
                  label: 'Employee House No',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter house number';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 15)),
              Expanded(
                child: _buildAdvanced3DTextField(
                  controller: _mobileNoController,
                  label: 'Employee Mobile No',
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
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          _buildAdvanced3DDropdown(
            label: 'Purpose of Visit',
            value: _purpose,
            items: const ['Leave', 'OD', 'C Shift', 'Off Duty', 'Other'],
            onChanged: (value) {
              setState(() {
                _purpose = value;
              });
            },
          ),
          if (_purpose == 'Other')
            Padding(
              padding: ResponsiveUtil.scaledPadding(context, top: 16),
              child: _buildAdvanced3DTextField(
                label: 'Other Purpose',
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
    ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideY(begin: 0.2);
  }

  Widget _buildVisitDetailsSection() {
    return Advanced3DCard(
      enableGlassMorphism: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Visit Details', Icons.location_on),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          _buildAdvanced3DTextField(
            controller: _visitPlaceController,
            label: 'Visit Place',
            hintText: 'Enter visit location',
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          Row(
            children: [
              Expanded(
                child: _buildDateTimeField(
                  label: 'From Date',
                  value: _fromDate != null
                      ? DateFormat('dd/MM/yyyy').format(_fromDate!)
                      : 'Select date',
                  onTap: () => _selectDate(context, true),
                ),
              ),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 15)),
              Expanded(
                child: _buildDateTimeField(
                  label: 'From Time',
                  value: _fromTime != null
                      ? _fromTime!.format(context)
                      : 'Select time',
                  onTap: () => _selectTime(context, true),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          Row(
            children: [
              Expanded(
                child: _buildDateTimeField(
                  label: 'To Date',
                  value: _toDate != null
                      ? DateFormat('dd/MM/yyyy').format(_toDate!)
                      : 'Select date',
                  onTap: () => _selectDate(context, false),
                ),
              ),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 15)),
              Expanded(
                child: _buildDateTimeField(
                  label: 'To Time',
                  value: _toTime != null
                      ? _toTime!.format(context)
                      : 'Select time',
                  onTap: () => _selectTime(context, false),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.2);
  }

  Widget _buildSubmitButton() {
    return Advanced3DCard(
      enableGlassMorphism: false,
      backgroundColor: SparshTheme.primaryBlue,
      child: InkWell(
        onTap: _submitForm,
        child: Container(
          padding: ResponsiveUtil.scaledPadding(context, vertical: 20),
          alignment: Alignment.center,
          child: Text(
            'Submit Holiday House Lock Request',
            style: SparshTypography.bodyBold.copyWith(
              fontSize: ResponsiveUtil.scaledSize(context, 16),
              color: Colors.white,
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 0.2);
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: SparshTheme.primaryBlue,
          size: ResponsiveUtil.scaledSize(context, 24),
        ),
        SizedBox(width: ResponsiveUtil.scaledSize(context, 8)),
        Text(
          title,
          style: SparshTypography.heading6.copyWith(
            color: SparshTheme.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildAdvanced3DTextField({
    TextEditingController? controller,
    required String label,
    String? hintText,
    TextInputType? keyboardType,
    bool readOnly = false,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: SparshTheme.cardBackground,
        borderRadius: BorderRadius.circular(SparshBorderRadius.md),
        boxShadow: SparshShadows.sm,
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          labelStyle: SparshTypography.bodyMedium.copyWith(
            color: SparshTheme.textSecondary,
          ),
          hintStyle: SparshTypography.bodyMedium.copyWith(
            color: SparshTheme.textTertiary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SparshBorderRadius.md),
            borderSide: BorderSide(color: SparshTheme.borderGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SparshBorderRadius.md),
            borderSide: BorderSide(color: SparshTheme.primaryBlue, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SparshBorderRadius.md),
            borderSide: BorderSide(color: SparshTheme.borderGrey),
          ),
          filled: true,
          fillColor: readOnly ? SparshTheme.borderLightGrey : SparshTheme.cardBackground,
          contentPadding: ResponsiveUtil.scaledPadding(context, all: 16),
        ),
        style: SparshTypography.bodyMedium,
        keyboardType: keyboardType,
        readOnly: readOnly,
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildAdvanced3DDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: SparshTheme.cardBackground,
        borderRadius: BorderRadius.circular(SparshBorderRadius.md),
        boxShadow: SparshShadows.sm,
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: SparshTypography.bodyMedium.copyWith(
            color: SparshTheme.textSecondary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SparshBorderRadius.md),
            borderSide: BorderSide(color: SparshTheme.borderGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SparshBorderRadius.md),
            borderSide: BorderSide(color: SparshTheme.primaryBlue, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SparshBorderRadius.md),
            borderSide: BorderSide(color: SparshTheme.borderGrey),
          ),
          filled: true,
          fillColor: SparshTheme.cardBackground,
          contentPadding: ResponsiveUtil.scaledPadding(context, all: 16),
        ),
        value: value,
        style: SparshTypography.bodyMedium,
        dropdownColor: SparshTheme.cardBackground,
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, style: SparshTypography.bodyMedium),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: SparshTheme.cardBackground,
        borderRadius: BorderRadius.circular(SparshBorderRadius.md),
        boxShadow: SparshShadows.sm,
      ),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: SparshTypography.bodyMedium.copyWith(
              color: SparshTheme.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SparshBorderRadius.md),
              borderSide: BorderSide(color: SparshTheme.borderGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SparshBorderRadius.md),
              borderSide: BorderSide(color: SparshTheme.borderGrey),
            ),
            filled: true,
            fillColor: SparshTheme.cardBackground,
            contentPadding: ResponsiveUtil.scaledPadding(context, all: 16),
          ),
          child: Text(
            value,
            style: SparshTypography.bodyMedium,
          ),
        ),
      ),
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
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SparshBorderRadius.lg),
          ),
          title: Text(
            'Holiday House Lock Security',
            style: SparshTypography.heading6.copyWith(
              color: SparshTheme.primaryBlue,
            ),
          ),
          content: Text(
            'Your Holiday House Lock Security has been submitted successfully.',
            style: SparshTypography.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: SparshTypography.bodyBold.copyWith(
                  color: SparshTheme.primaryBlue,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}

