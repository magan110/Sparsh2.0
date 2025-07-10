// File: lib/accounts_statement_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AccountsStatementPage extends StatefulWidget {
  const AccountsStatementPage({super.key});

  @override
  State<AccountsStatementPage> createState() => _AccountsStatementPageState();
}

class _AccountsStatementPageState extends State<AccountsStatementPage> {
  // Controllers for date fields
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // Dropdown selections
  String? _selectedPurchaserType;
  String? _selectedAreaCode;

  // Controller for "Code" field
  final TextEditingController _codeController = TextEditingController();

  // Sample items (replace with real data)
  final List<String> _purchaserTypes = [
    'Select',
    'Retailer',
    'Distributor',
    'Wholesaler'
  ];
  final List<String> _areaCodes = ['Select', 'Area 1', 'Area 2', 'Area 3'];

  // DateFormat for "dd/MM/yyyy"
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    // Initialize date fields as empty (or you can default them to today)
    _startDateController.text = '';
    _endDateController.text = '';
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _codeController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Container(
      // Full-screen gradient background
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
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Accounts Statement – Confidential',
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isMobile = constraints.maxWidth < 600;

                // Build form card
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.98),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      child: isMobile
                          ? _buildMobileLayout()
                          : _buildTabletDesktopLayout(),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Layout for mobile (stack all fields vertically)
  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Start Date
        const Text('Start Date:', style: TextStyle(fontSize: 14)),
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

        // Purchaser Type *
        const Text('Purchaser Type *', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _selectedPurchaserType ?? _purchaserTypes.first,
          decoration: _inputDecoration(),
          items: _purchaserTypes.map((p) {
            return DropdownMenuItem(
              value: p,
              child: Text(p),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedPurchaserType = value;
            });
          },
        ),
        const SizedBox(height: 16),

        // Area Code *
        const Text('Area Code *', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _selectedAreaCode ?? _areaCodes.first,
          decoration: _inputDecoration(),
          items: _areaCodes.map((a) {
            return DropdownMenuItem(
              value: a,
              child: Text(a),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedAreaCode = value;
            });
          },
        ),
        const SizedBox(height: 16),

        // Code *
        const Text('Code *', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 6),
        TextField(
          controller: _codeController,
          decoration: _inputDecoration(hintText: 'Enter Code'),
        ),
        const SizedBox(height: 16),

        // Go button
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () {
              // TODO: Implement "Go" logic
              debugPrint('--- GO PRESSED ---');
              debugPrint('Start Date: ${_startDateController.text}');
              debugPrint('End Date: ${_endDateController.text}');
              debugPrint('Purchaser Type: $_selectedPurchaserType');
              debugPrint('Area Code: $_selectedAreaCode');
              debugPrint('Code: ${_codeController.text}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(80, 48),
            ),
            child: const Text('Go', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  /// Layout for tablet/desktop (fields arranged in two rows)
  Widget _buildTabletDesktopLayout() {
    return Column(
      children: [
        Row(
          children: [
            // Start Date (flex: 2)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Start Date:', style: TextStyle(fontSize: 14)),
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
            const SizedBox(width: 16),

            // End Date (flex: 2)
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

            // Purchaser Type * (flex: 2)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Purchaser Type *',
                      style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedPurchaserType ?? _purchaserTypes.first,
                    decoration: _inputDecoration(),
                    items: _purchaserTypes.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text(p),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPurchaserType = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            // Area Code * (flex: 2)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Area Code *', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedAreaCode ?? _areaCodes.first,
                    decoration: _inputDecoration(),
                    items: _areaCodes.map((a) {
                      return DropdownMenuItem(
                        value: a,
                        child: Text(a),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAreaCode = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Code * (flex: 2)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Code *', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _codeController,
                    decoration: _inputDecoration(hintText: 'Enter Code'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Go Button (fixed width)
            SizedBox(
              width: 80,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement "Go" logic
                  debugPrint('--- GO PRESSED ---');
                  debugPrint('Start Date: ${_startDateController.text}');
                  debugPrint('End Date: ${_endDateController.text}');
                  debugPrint('Purchaser Type: $_selectedPurchaserType');
                  debugPrint('Area Code: $_selectedAreaCode');
                  debugPrint('Code: ${_codeController.text}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text('Go', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// InputDecoration for all text fields
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
