import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:learning2/core/constants/fonts.dart';

class FirstAid extends StatefulWidget {
  const FirstAid({super.key});

  @override
  State<FirstAid> createState() => _FirstAidState();
}

class _FirstAidState extends State<FirstAid> {
  late final String _currentDate;
  final TextEditingController _deptController = TextEditingController();
  String? _selectedPresence;
  final List<String> _presenceOptions = ['Present On Site', 'Not On Site', 'All'];

  // All data (unfiltered)
  final List<Map<String, String>> _allEmployees = [
    {
      "Employee Code": "3318",
      "Employee Name": "Mr Anoop Shukla",
      "Dept Name": "Mechanical (Katni)",
      "Mobile No": "7222908616",
      "Shift": ""
    },
    {
      "Employee Code": "1837",
      "Employee Name": "Mr Narendra Kumar Chauhan",
      "Dept Name": "Electrical",
      "Mobile No": "9784448775",
      "Shift": ""
    },
    {
      "Employee Code": "2290",
      "Employee Name": "Mr Kuldeep Singh Parihar",
      "Dept Name": "Electrical",
      "Mobile No": "8769347752",
      "Shift": ""
    },
    {
      "Employee Code": "1647",
      "Employee Name": "Mr Surendra Kumar Sharma",
      "Dept Name": "Instrumentation",
      "Mobile No": "9828884421",
      "Shift": ""
    },
    {
      "Employee Code": "1926",
      "Employee Name": "Mr Prem Sukh Tak",
      "Dept Name": "Instrumentation",
      "Mobile No": "9828251256",
      "Shift": ""
    },
    {
      "Employee Code": "2007",
      "Employee Name": "Mr Anil Kumar Gehlot",
      "Dept Name": "Instrumentation",
      "Mobile No": "9414673187",
      "Shift": ""
    },
    {
      "Employee Code": "2950",
      "Employee Name": "Mr Om Prakash Singh",
      "Dept Name": "Instrumentation",
      "Mobile No": "9785916950",
      "Shift": ""
    },
    {
      "Employee Code": "3269",
      "Employee Name": "Mr Rakesh Kumar Sharma",
      "Dept Name": "Quality Control & Environment",
      "Mobile No": "8104939658",
      "Shift": ""
    },
    {
      "Employee Code": "3267",
      "Employee Name": "Mr Shreepal Singh Rajawat",
      "Dept Name": "Process",
      "Mobile No": "9460986032",
      "Shift": ""
    },
    {
      "Employee Code": "3375",
      "Employee Name": "Mr Rajbir Singh",
      "Dept Name": "Process",
      "Mobile No": "8427408476",
      "Shift": ""
    },
  ];

  // Filtered employees list
  late List<Map<String, String>> _filteredEmployees;

  @override
  void initState() {
    super.initState();
    _currentDate = DateFormat('dd MMM yyyy').format(DateTime.now());
    _filteredEmployees = List.from(_allEmployees);
    _deptController.addListener(_filterTable);
  }

  @override
  void dispose() {
    _deptController.removeListener(_filterTable);
    _deptController.dispose();
    super.dispose();
  }

  void _filterTable() {
    final query = _deptController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredEmployees = List.from(_allEmployees);
      } else {
        _filteredEmployees = _allEmployees.where((emp) {
          final dept = emp["Dept Name"]?.toLowerCase() ?? '';
          return dept.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('First Aid Personnel', style: Fonts.bodyBold.copyWith(fontSize: 18)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildText("As on Date"),
            const SizedBox(height: 10),
            _buildReadOnlyDateField(_currentDate),
            const SizedBox(height: 24),
            _buildText("Present On Site, Not On Site, All"),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: _dropdownDecoration(),
              value: _selectedPresence,
              items: _presenceOptions
                  .map((option) =>
                  DropdownMenuItem(value: option, child: Text(option)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedPresence = value),
            ),
            const SizedBox(height: 24),
            _buildText("Department Code"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _deptController,
                    decoration: InputDecoration(
                      hintText: "Enter Department Code",
                      prefixIcon: const Icon(Icons.search, color: Colors.blue, size: 24),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                      backgroundColor: Colors.blue[700],
                    ),
                    onPressed: () {
                      // Optionally use for advanced search/filter
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text("Go", style: Fonts.body.copyWith(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
            EmployeeTable(data: _filteredEmployees),
          ],
        ),
      ),
    );
  }

  Widget _buildText(String str) {
    return Text(
      str,
      style: Fonts.bodyBold.copyWith(fontSize: 16),
    );
  }

  Widget _buildReadOnlyDateField(String dateStr) {
    return TextField(
      readOnly: true,
      controller: TextEditingController(text: dateStr),
      style: Fonts.body.copyWith(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        suffixIcon: Icon(Icons.calendar_today, color: Colors.blue.shade600, size: 24),
      ),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}

// Beautiful DataTable with vertical lines, alternate row colors, and aligned content
class EmployeeTable extends StatelessWidget {
  final List<Map<String, String>> data;
  const EmployeeTable({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 32.0),
        child: Center(
          child: Text(
            "No employees found for this department.",
            style: Fonts.body.copyWith(
              fontSize: 15,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }
    return Card(
      margin: const EdgeInsets.only(top: 30, bottom: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 44,
          dataRowHeight: 44,
          columnSpacing: 28,
          horizontalMargin: 18,
          showBottomBorder: true,
          dividerThickness: 1.3,
          border: TableBorder(
            verticalInside: BorderSide(color: Colors.grey.shade300, width: 1),
            horizontalInside: BorderSide(color: Colors.grey.shade300, width: 1),
            top: BorderSide(color: Colors.blue.shade600, width: 1.8),
            bottom: BorderSide(color: Colors.grey.shade300, width: 1.4),
            left: BorderSide(color: Colors.grey.shade300, width: 1),
            right: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          headingRowColor: WidgetStateProperty.resolveWith((states) => Colors.blue.shade600),
          headingTextStyle: Fonts.bodyBold.copyWith(
            color: Colors.white,
            fontSize: 16,
            letterSpacing: 0.3,
          ),
          columns: const [
            DataColumn(label: Text('Employee Code')),
            DataColumn(label: Text('Employee Name')),
            DataColumn(label: Text('Dept Name')),
            DataColumn(label: Text('Mobile No')),
            DataColumn(label: Text('Shift')),
          ],
          rows: List<DataRow>.generate(
            data.length,
                (index) => DataRow(
              color: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                  return index % 2 == 0
                      ? Colors.white
                      : Colors.blue.shade50.withOpacity(0.7);
                },
              ),
              cells: [
                DataCell(_tableCell(data[index]["Employee Code"]!)),
                DataCell(_tableCell(data[index]["Employee Name"]!)),
                DataCell(_tableCell(data[index]["Dept Name"]!)),
                DataCell(_tableCell(data[index]["Mobile No"]!)),
                DataCell(_tableCell(data[index]["Shift"]!)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tableCell(String value) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
    child: Text(
      value,
      style: Fonts.body.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: Colors.black87,
      ),
    ),
  );
}
