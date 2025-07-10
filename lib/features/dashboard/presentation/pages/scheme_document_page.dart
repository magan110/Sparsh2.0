// File: lib/scheme_document_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SchemeDocumentPage extends StatefulWidget {
  const SchemeDocumentPage({super.key});

  @override
  State<SchemeDocumentPage> createState() => _SchemeDocumentPageState();
}

class _SchemeDocumentPageState extends State<SchemeDocumentPage> {
  // ======== Date Controllers ========
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();

  // Date Format
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

  // ======== Dropdown Selections & Multi-Select Selections ========
  String? _selectedProcessType;
  String? _selectedPurchaserEmployee;
  String? _selectedGeography;
  final List<String> _selectedType = [];
  final List<String> _selectedUserTypes = [];
  String? _selectedCircularType;

  // Example data (replace with your real lists)
  final List<String> _processTypes = ['Add', 'Edit', 'Delete'];
  final List<String> _purchaserEmployees = ['Select', 'Employee A', 'Employee B'];
  final List<String> _geographies = ['Select', 'North', 'South', 'East', 'West'];
  final List<String> _types = ['Scheme A', 'Scheme B', 'Scheme C', 'Scheme D'];
  final List<String> _userTypes = ['Retailer', 'Stockiest', 'Distributor'];
  final List<String> _circularTypes = ['Select', 'Circular A', 'Circular B'];

  // ======== Text Controllers ========
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startDateController.text = '';
    _endDateController.text = '';
    _expiryDateController.text = '';
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _expiryDateController.dispose();
    _descriptionController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  /// Opens a DatePicker and updates the given controller
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

  /// Toggles selection for a given list (multi-select)
  void _toggleMultiSelect(String item, List<String> list) {
    setState(() {
      if (list.contains(item)) {
        list.remove(item);
      } else {
        list.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Gradient background
      decoration: const BoxDecoration(
        color: Colors.blue,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Scheme Document',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isMobile = constraints.maxWidth < 600;

                Widget formCard = Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.98),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: isMobile
                      ? _buildMobileLayout()
                      : _buildTabletDesktopLayout(),
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    formCard,
                    const SizedBox(height: 24),
                    // Submit Button
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Implement submit logic
                        debugPrint('--- SUBMIT PRESSED ---');
                        debugPrint('Process Type: $_selectedProcessType');
                        debugPrint(
                            'Purchaser/Employee: $_selectedPurchaserEmployee');
                        debugPrint('Geography: $_selectedGeography');
                        debugPrint('Type: $_selectedType');
                        debugPrint('Type of user: $_selectedUserTypes');
                        debugPrint(
                            'Type of Circular: $_selectedCircularType');
                        debugPrint(
                            'Description: ${_descriptionController.text}');
                        debugPrint('Start Date: ${_startDateController.text}');
                        debugPrint('End Date: ${_endDateController.text}');
                        debugPrint(
                            'Expiry Date: ${_expiryDateController.text}');
                        debugPrint('Remark: ${_remarkController.text}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Mobile layout: stack all fields vertically
  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Process Type *
        const Text('Process Type: *', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _selectedProcessType ?? _processTypes.first,
          decoration: _inputDecoration(),
          items: _processTypes.map((proc) {
            return DropdownMenuItem(value: proc, child: Text(proc));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedProcessType = value;
            });
          },
        ),
        const SizedBox(height: 16),

        // Purchaser / Employee *
        const Text('Purchaser / Employee: *', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _selectedPurchaserEmployee ?? _purchaserEmployees.first,
          decoration: _inputDecoration(),
          items: _purchaserEmployees.map((pe) {
            return DropdownMenuItem(value: pe, child: Text(pe));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedPurchaserEmployee = value;
            });
          },
        ),
        const SizedBox(height: 16),

        // Geography *
        const Text('Geography: *', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _selectedGeography ?? _geographies.first,
          decoration: _inputDecoration(),
          items: _geographies.map((g) {
            return DropdownMenuItem(value: g, child: Text(g));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedGeography = value;
            });
          },
        ),
        const SizedBox(height: 16),

        // Type *
        const Text('Type: *', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 6),
        OutlinedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (_) => Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _types.map((type) {
                    final bool checked = _selectedType.contains(type);
                    return CheckboxListTile(
                      title: Text(type),
                      value: checked,
                      onChanged: (_) {
                        _toggleMultiSelect(type, _selectedType);
                      },
                    );
                  }).toList(),
                ),
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.grey.shade50,
            side: BorderSide(color: Colors.grey.shade400),
            padding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _selectedType.isEmpty
                  ? '0 options selected'
                  : '${_selectedType.length} options selected',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Type of user: *
        const Text('Type of user: *', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 6),
        OutlinedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (_) => Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _userTypes.map((ut) {
                    final bool checked = _selectedUserTypes.contains(ut);
                    return CheckboxListTile(
                      title: Text(ut),
                      value: checked,
                      onChanged: (_) {
                        _toggleMultiSelect(ut, _selectedUserTypes);
                      },
                    );
                  }).toList(),
                ),
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.grey.shade50,
            side: BorderSide(color: Colors.grey.shade400),
            padding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _selectedUserTypes.isEmpty
                  ? '0 options selected'
                  : '${_selectedUserTypes.length} options selected',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Type of Circular *
        const Text('Type of Circular: *', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _selectedCircularType ?? _circularTypes.first,
          decoration: _inputDecoration(),
          items: _circularTypes.map((c) {
            return DropdownMenuItem(value: c, child: Text(c));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCircularType = value;
            });
          },
        ),
        const SizedBox(height: 16),

        // Description Search (Scheme, Retailer, stockiest, Price): *
        const Text(
          'Description Search (Scheme, Retailer, stockiest, Price): *',
          style: TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _descriptionController,
          decoration: _inputDecoration(
              hintText: 'Enter description here...'),
        ),
        const SizedBox(height: 16),

        // Start Date *
        const Text('Start Date: *', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _pickDate(context, _startDateController),
          child: AbsorbPointer(
            child: TextField(
              controller: _startDateController,
              decoration: _inputDecoration(
                hintText: 'DD/MM/YYYY',
                suffixIcon: const Icon(Icons.calendar_today),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // End Date
        const Text('End Date:', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _pickDate(context, _endDateController),
          child: AbsorbPointer(
            child: TextField(
              controller: _endDateController,
              decoration: _inputDecoration(
                hintText: 'DD/MM/YYYY',
                suffixIcon: const Icon(Icons.calendar_today),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Expiry Date
        const Text('Expiry Date:', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _pickDate(context, _expiryDateController),
          child: AbsorbPointer(
            child: TextField(
              controller: _expiryDateController,
              decoration: _inputDecoration(
                hintText: 'DD/MM/YYYY',
                suffixIcon: const Icon(Icons.calendar_today),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Remark
        const Text('Remark', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 6),
        TextField(
          controller: _remarkController,
          minLines: 3,
          maxLines: 5,
          decoration: _inputDecoration(hintText: 'Enter remarks...'),
        ),
        const SizedBox(height: 24),

        // Attach Supporting
        const Text('Attach Supporting', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            ElevatedButton(
              onPressed: () {
                // TODO: implement document upload
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child:
              const Text('Document Upload', style: TextStyle(fontSize: 16)),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: implement document view
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child:
              const Text('Document View', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ],
    );
  }

  /// Tablet/Desktop layout: fields arranged in rows/columns
  Widget _buildTabletDesktopLayout() {
    return Column(
      children: [
        // Row 1: Process, Purchaser/Employee, Geography, Type
        Row(
          children: [
            // Process Type *
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Process Type: *', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedProcessType ?? _processTypes.first,
                    decoration: _inputDecoration(),
                    items: _processTypes.map((proc) {
                      return DropdownMenuItem(
                          value: proc, child: Text(proc));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProcessType = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Purchaser / Employee *
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Purchaser / Employee: *',
                      style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedPurchaserEmployee ??
                        _purchaserEmployees.first,
                    decoration: _inputDecoration(),
                    items: _purchaserEmployees.map((pe) {
                      return DropdownMenuItem(
                          value: pe, child: Text(pe));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPurchaserEmployee = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Geography *
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Geography: *', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedGeography ?? _geographies.first,
                    decoration: _inputDecoration(),
                    items: _geographies.map((g) {
                      return DropdownMenuItem(
                          value: g, child: Text(g));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGeography = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Type *
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Type: *', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 6),
                  OutlinedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: _types.map((type) {
                              final bool checked =
                              _selectedType.contains(type);
                              return CheckboxListTile(
                                title: Text(type),
                                value: checked,
                                onChanged: (_) {
                                  _toggleMultiSelect(type, _selectedType);
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.grey.shade50,
                      side: BorderSide(color: Colors.grey.shade400),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _selectedType.isEmpty
                            ? '0 options selected'
                            : '${_selectedType.length} options selected',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Row 2: Type of user, Type of Circular, Description, Start Date
        Row(
          children: [
            // Type of user: *
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Type of user: *',
                      style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 6),
                  OutlinedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: _userTypes.map((ut) {
                              final bool checked =
                              _selectedUserTypes.contains(ut);
                              return CheckboxListTile(
                                title: Text(ut),
                                value: checked,
                                onChanged: (_) {
                                  _toggleMultiSelect(
                                      ut, _selectedUserTypes);
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.grey.shade50,
                      side: BorderSide(color: Colors.grey.shade400),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _selectedUserTypes.isEmpty
                            ? '0 options selected'
                            : '${_selectedUserTypes.length} options selected',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Type of Circular *
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Type of Circular: *',
                      style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value:
                    _selectedCircularType ?? _circularTypes.first,
                    decoration: _inputDecoration(),
                    items: _circularTypes.map((c) {
                      return DropdownMenuItem(
                          value: c, child: Text(c));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCircularType = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Description Search *
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description Search (Scheme, Retailer, stockiest, Price): *',
                    style: TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _descriptionController,
                    decoration: _inputDecoration(
                        hintText: 'Enter description here...'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Start Date *
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Start Date: *', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _pickDate(context, _startDateController),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _startDateController,
                        decoration: _inputDecoration(
                          hintText: 'DD/MM/YYYY',
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Row 3: End Date, Expiry Date, Remark, (empty for spacing)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // End Date
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('End Date:', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _pickDate(context, _endDateController),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _endDateController,
                        decoration: _inputDecoration(
                          hintText: 'DD/MM/YYYY',
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Expiry Date
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Expiry Date:', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _pickDate(context, _expiryDateController),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _expiryDateController,
                        decoration: _inputDecoration(
                          hintText: 'DD/MM/YYYY',
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Remark
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Remark', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _remarkController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: _inputDecoration(hintText: 'Enter remarks...'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Empty space to fill the row (no widget)
            const Expanded(flex: 2, child: SizedBox()),
          ],
        ),

        const SizedBox(height: 24),

        // Attach Supporting
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Attach Supporting', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // TODO: implement document upload
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Document Upload',
                        style: TextStyle(fontSize: 16)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: implement document view
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Document View',
                        style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// InputDecoration for all text fields & dropdowns
  InputDecoration _inputDecoration(
      {String? hintText, Widget? suffixIcon, bool enabled = true}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade200,
      enabled: enabled,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
