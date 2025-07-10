// File: lib/grc_lead_entry_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';

/// GRC Lead Entry Page
///
/// – Full‐screen blue gradient background
/// – Transparent AppBar with back arrow, title, Home/Log Out
/// – A large white card containing:
///    * "Process Details" (many dropdown/text fields)
///    * "Buyer Detail" (GST, PAN, Aadhar, Remarks, and upload buttons)
///    * A Submit button at the very bottom
/// – Fully responsive: stacks vertically on mobile (width < 600), side‐by‐side on tablet/desktop.
class GrcLeadEntryPage extends StatefulWidget {
  const GrcLeadEntryPage({super.key});

  @override
  State<GrcLeadEntryPage> createState() => _GrcLeadEntryPageState();
}

class _GrcLeadEntryPageState extends State<GrcLeadEntryPage> {
  // Controllers for text fields
  final TextEditingController _processTypeController = TextEditingController(text: 'Add');
  final TextEditingController _leadDateController = TextEditingController();
  final TextEditingController _leadQtyController = TextEditingController();
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _projectAddressController = TextEditingController();
  final TextEditingController _contactPersonController = TextEditingController();
  final TextEditingController _architectNameController = TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _gstController = TextEditingController(text: 'GSTIN');
  final TextEditingController _panController = TextEditingController(text: 'PAN');
  final TextEditingController _aadharController = TextEditingController(text: 'AADHAR');
  final TextEditingController _remarksController = TextEditingController();

  // Dropdown selections
  String? _onsiteOffsite;
  String? _unitOfMeasurement;
  String? _deliveryPeriod;
  String? _kindOfProject;
  String? _contactPersonType;

  // Sample dropdown items
  final List<String> _yesNoItems = ['Onsite', 'Offsite'];
  final List<String> _uomItems = ['Sq. Ft.', 'Sq. Meter', 'Piece'];
  final List<String> _deliveryPeriodItems = ['1 Week', '2 Weeks', '1 Month'];
  final List<String> _projectTypeItems = ['Residential', 'Commercial', 'Industrial'];
  final List<String> _contactTypeItems = ['Owner', 'Architect', 'Contractor'];

  // Date formatter
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    // Default lead date → today
    DateTime now = DateTime.now();
    _leadDateController.text = _dateFormatter.format(now);
  }

  @override
  void dispose() {
    _processTypeController.dispose();
    _leadDateController.dispose();
    _leadQtyController.dispose();
    _projectNameController.dispose();
    _projectAddressController.dispose();
    _contactPersonController.dispose();
    _architectNameController.dispose();
    _mobileNoController.dispose();
    _emailController.dispose();
    _gstController.dispose();
    _panController.dispose();
    _aadharController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  /// Open date picker and update controller
  Future<void> _pickDate(
      BuildContext context, TextEditingController controller) async {
    DateTime initialDate;
    try {
      initialDate = _dateFormatter.parse(controller.text);
    } catch (_) {
      initialDate = DateTime.now();
    }
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = _dateFormatter.format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Full-screen blue gradient background
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1976D2),
            Color(0xFF42A5F5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          // Transparent AppBar
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'GRC Lead Entry',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back',
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: LayoutBuilder(builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 600;

              // Build the two main sections either stacked (mobile) or side-by-side (desktop)
              Widget content = isMobile
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProcessDetailsSection(isMobile),
                  const SizedBox(height: 24),
                  _buildBuyerDetailSection(isMobile),
                  const SizedBox(height: 24),
                  _buildUploadAndSubmit(),
                ],
              )
                  : Column(
                children: [
                  // Place both sections side-by-side in a row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildProcessDetailsSection(isMobile)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildBuyerDetailSection(isMobile)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildUploadAndSubmit(),
                ],
              );

              return content;
            }),
          ),
        ),
      ),
    );
  }

  /// "Process Details" section
  Widget _buildProcessDetailsSection(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Process Details',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 16),
          // Use either single-column or multi-column rows depending on isMobile
          if (isMobile) ...[
            _buildDropdownField(
              label: 'Define Onsite/Offsite *',
              selectedValue: _onsiteOffsite,
              items: _yesNoItems,
              onChanged: (v) => setState(() => _onsiteOffsite = v),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Process Type *',
              controller: _processTypeController,
            ),
            const SizedBox(height: 12),
            _buildDateField(
              label: 'Lead Date',
              controller: _leadDateController,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Lead Qty *',
              controller: _leadQtyController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _buildDropdownField(
              label: 'Unit of Measurement (optional)',
              selectedValue: _unitOfMeasurement,
              items: _uomItems,
              onChanged: (v) => setState(() => _unitOfMeasurement = v),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Project Name *',
              controller: _projectNameController,
            ),
            const SizedBox(height: 12),
            _buildDropdownField(
              label: 'Delivery Period',
              selectedValue: _deliveryPeriod,
              items: _deliveryPeriodItems,
              onChanged: (v) => setState(() => _deliveryPeriod = v),
            ),
            const SizedBox(height: 12),
            _buildDropdownField(
              label: 'Kind of project',
              selectedValue: _kindOfProject,
              items: _projectTypeItems,
              onChanged: (v) => setState(() => _kindOfProject = v),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Project Address *',
              controller: _projectAddressController,
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Contact Person (optional)',
              controller: _contactPersonController,
            ),
            const SizedBox(height: 12),
            _buildDropdownField(
              label: 'Contact Person Type',
              selectedValue: _contactPersonType,
              items: _contactTypeItems,
              onChanged: (v) => setState(() => _contactPersonType = v),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Architect Name *',
              controller: _architectNameController,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Mobile No *',
              controller: _mobileNoController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
          ] else ...[
            // Desktop / tablet → arrange in rows of three columns each
            Row(
              children: [
                Expanded(
                  child: _buildDropdownField(
                    label: 'Define Onsite/Offsite *',
                    selectedValue: _onsiteOffsite,
                    items: _yesNoItems,
                    onChanged: (v) => setState(() => _onsiteOffsite = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    label: 'Process Type *',
                    controller: _processTypeController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateField(
                    label: 'Lead Date',
                    controller: _leadDateController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Lead Qty *',
                    controller: _leadQtyController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdownField(
                    label: 'Unit of Measurement (optional)',
                    selectedValue: _unitOfMeasurement,
                    items: _uomItems,
                    onChanged: (v) => setState(() => _unitOfMeasurement = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    label: 'Project Name *',
                    controller: _projectNameController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDropdownField(
                    label: 'Delivery Period',
                    selectedValue: _deliveryPeriod,
                    items: _deliveryPeriodItems,
                    onChanged: (v) => setState(() => _deliveryPeriod = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdownField(
                    label: 'Kind of project',
                    selectedValue: _kindOfProject,
                    items: _projectTypeItems,
                    onChanged: (v) => setState(() => _kindOfProject = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    label: 'Project Address *',
                    controller: _projectAddressController,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Contact Person (optional)',
                    controller: _contactPersonController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdownField(
                    label: 'Contact Person Type',
                    selectedValue: _contactPersonType,
                    items: _contactTypeItems,
                    onChanged: (v) => setState(() => _contactPersonType = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    label: 'Architect Name *',
                    controller: _architectNameController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Mobile No *',
                    controller: _mobileNoController,
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(width: 12),
                // Empty third column for alignment
                const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// "Buyer Detail" section
  Widget _buildBuyerDetailSection(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Buyer Detail',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 16),
          if (isMobile) ...[
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'GST Number',
                    controller: _gstController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'PAN NO',
                    controller: _panController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'AADHAR NO',
                    controller: _aadharController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Remarks *',
              controller: _remarksController,
            ),
          ] else ...[
            // Desktop: three columns for GST, PAN, Aadhar
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'GST Number',
                    controller: _gstController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    label: 'PAN NO',
                    controller: _panController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    label: 'AADHAR NO',
                    controller: _aadharController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Remarks *',
              controller: _remarksController,
            ),
          ],
        ],
      ),
    );
  }

  /// Upload buttons and Submit
  Widget _buildUploadAndSubmit() {
    // Each "upload" group: label + blue "Upload Image" button + a grey placeholder for "View"
    Widget uploadRow(String label) {
      return Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.black87)),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              // TODO: implement file pick/upload
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Upload Image', style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 8),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.visibility, size: 20, color: Colors.grey),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        uploadRow('Upload Aadhar'),
        const SizedBox(height: 12),
        uploadRow('Upload PAN'),
        const SizedBox(height: 12),
        uploadRow('Upload Drawing'),
        const SizedBox(height: 12),
        uploadRow('Upload GST'),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            // TODO: handle Submit
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            minimumSize: const Size(150, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Submit',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  /// Helper: build a text field with a label above
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  /// Helper: build a date field (read-only) with calendar icon
  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _pickDate(context, controller),
          child: AbsorbPointer(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                suffixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Helper: build a dropdown field with a label above
  Widget _buildDropdownField({
    required String label,
    required String? selectedValue,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            if (label.contains('*'))
              const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 6),
        DropdownSearch<String>(
          items: items,
          selectedItem: selectedValue,
          onChanged: onChanged,
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          popupProps: PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: "Search...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
