import 'package:flutter/material.dart';
import 'package:learning2/core/constants/fonts.dart';

void main() => runApp(const MaterialApp(home: EmployeeDetails()));

class EmployeeDetails extends StatefulWidget {
  const EmployeeDetails({super.key});
  @override
  State<EmployeeDetails> createState() => _EmployeeDetailsState();
}

class _EmployeeDetailsState extends State<EmployeeDetails> {
  // Filter fields (same as your code)
  String siteValue = 'ALL';
  String commHrValue = 'ALL';
  String zoneValue = 'ALL';
  String sortingOrderValue = 'ALL';
  String reportAsPerValue = 'Aman';
  String activeLeftValue = 'Active';

  final List<String> siteList = ['ALL', 'Site', 'Mktg', 'Grc', 'Katni', 'Nathdwara'];
  final List<String> commHrList = ['ALL', 'Commercial', 'HR', 'Mktg', 'Tech'];
  final List<String> zoneList = ['ALL', 'Export', 'Central', 'East', 'North', 'South', 'West'];
  final List<String> sortingOrderList = [
    'ALL', 'Age', 'DepartMent', 'Grade', 'Designation', 'QualCode', 'Left Date', 'Token No'
  ];
  final List<String> reportAsPerList = ['Aman', 'R B Gupta'];
  final List<String> activeLeftList = ['Active', 'Left'];

  final TextEditingController asOnDate = TextEditingController();
  final TextEditingController leftFromDate = TextEditingController();
  final TextEditingController leftToDate = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // Table columns
  final List<String> columns = [
    "SNO", "Dept Code", "DepartMent", "Empl Code", "Name", "Adderss", "Desg.", "Grad Cd", "Grd Ds",
    "DOB.", "join Dt(Grup)", "Left Date", "Prv Exp.", "Exp(Grup)", "Totl Exp", "Exp(Unit)", "AGE",
    "Father Name", "Bw Join Dt", "Anni.Date", "PAN No", "Aadhar No", "PF No", "Basic Rate",
    "Poornata Id No", "Location Code", "Location Desc", "Area Code", "Zone Code", "Email Id",
    "Site/Mktg/Grc", "Function Code", "Qual Code", "Qual Desc", "Qual Year", "Marital Status",
    "Quartr No", "Blood Group", "Conf. Date", "Empl Stat", "State Desc", "Bank No", "Bank IFSC No",
    "Mobile No", "Job Band Grade", "Native State", "Prev.Unit", "IRS Trans Flag", "Left Reason",
    "IRS Trans Unit", "Spouse Name", "Gender"
  ];

  // Dummy Data
  List<List<String>> getDummyRows() {
    return List.generate(10, (i) => [
      "${i + 1}", "D${i + 101}", "Dept${i + 1}", "E${1000 + i}", "Emp Name $i", "Address $i",
      "Manager", "G${i + 1}", "Desc $i", "01/01/198${i % 10}", "01/01/20${10 + i}", "",
      "5", "2", "7", "4", "${25 + i}", "Father $i", "01/01/201${i % 10}", "10/10/201${i % 10}",
      "PAN123$i", "AADHAR$i", "PF$i", "20000", "PNID$i", "LOC${i + 1}", "Loc Desc $i", "A${i + 1}",
      "ZC${i + 1}", "emp$i@email.com", "Site", "FC${i + 1}", "QC${i + 1}", "Qual Desc $i",
      "201${i % 10}", "Married", "Q${i + 1}", "O+", "01/07/202${i % 10}", "Active", "State $i",
      "BN${i + 1}", "IFSC${i + 1}", "900000000$i", "Band${i + 1}", "State $i", "PU${i + 1}", "N",
      "Retired", "TU${i + 1}", "Spouse $i", i % 2 == 0 ? "M" : "F"
    ]);
  }

  List<List<String>> filteredRows = [];

  @override
  void initState() {
    super.initState();
    filteredRows = getDummyRows();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    asOnDate.dispose();
    leftFromDate.dispose();
    leftToDate.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final search = _searchController.text.toLowerCase();
    final allRows = getDummyRows();
    if (search.isEmpty) {
      setState(() => filteredRows = allRows);
      return;
    }
    setState(() {
      filteredRows = allRows.where((row) =>
          row.any((cell) => cell.toLowerCase().contains(search))
      ).toList();
    });
  }

  Future<void> _pickDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
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
      controller.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF8FAFF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Employee Details'),
        elevation: 0,
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(controller: asOnDate, label: 'As On Date', icon: Icons.calendar_today, onTap: () => _pickDate(context, asOnDate)),
              _buildDropdown(label: 'Report As Per (Aman / R B Gupta)', value: reportAsPerValue, items: reportAsPerList, onChanged: (val) => setState(() => reportAsPerValue = val!)),
              _buildDropdown(label: 'Active / Left', value: activeLeftValue, items: activeLeftList, onChanged: (val) => setState(() => activeLeftValue = val!)),
              _buildTextField(controller: leftFromDate, label: 'Left From Date', icon: Icons.calendar_today, onTap: () => _pickDate(context, leftFromDate)),
              _buildTextField(controller: leftToDate, label: 'Left To Date', icon: Icons.calendar_today, onTap: () => _pickDate(context, leftToDate)),
              _buildDropdown(label: 'Site/Mktg/Grc/Katni/All', value: siteValue, items: siteList, onChanged: (val) => setState(() => siteValue = val!)),
              _buildDropdown(label: 'Comm/Hr/Mktg/Tech/All', value: commHrValue, items: commHrList, onChanged: (val) => setState(() => commHrValue = val!)),
              _buildDropdown(label: 'Zone Wise/All', value: zoneValue, items: zoneList, onChanged: (val) => setState(() => zoneValue = val!)),
              _buildDropdown(label: 'Sorting Order', value: sortingOrderValue, items: sortingOrderList, onChanged: (val) => setState(() => sortingOrderValue = val!)),
              const SizedBox(height: 18),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      minimumSize: const Size(90, 46),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {},
                    child: Text('Go', style: Fonts.bodyBold.copyWith(fontSize: 18)),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Text(
                      'As on 24/05/2025 at 14:16:50',
                      style: Fonts.body.copyWith(color: Colors.grey.shade800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // --- SEARCH BAR ---
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.97),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                  ),
                  style: Fonts.body.copyWith(fontWeight: FontWeight.w500),
                ),
              ),

              // --- FULL TABLE IN A FANTASTIC CARD ---
              Card(
                elevation: 13,
                shadowColor: Colors.blue.shade100.withOpacity(0.38),
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.white.withOpacity(0.97),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: filteredRows.isEmpty
                        ? _buildNoData(context)
                        : DataTable(
                      headingRowHeight: 50,
                      dataRowHeight: 40,
                      columnSpacing: 22,
                      horizontalMargin: 10,
                      columns: columns
                          .map(
                            (c) => DataColumn(
                          label: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade600,
                                  Colors.blue.shade400
                                ],
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 7, horizontal: 11),
                            child: Text(
                              c,
                              style: Fonts.bodyBold.copyWith(
                                color: Colors.white,
                                fontSize: 13.3,
                                letterSpacing: 0.1,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      )
                          .toList(),
                      rows: filteredRows
                          .map(
                            (row) => DataRow(
                          cells: row
                              .map(
                                (cell) => DataCell(
                              Container(
                                width: 102,
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: Text(
                                  cell,
                                  style: Fonts.body.copyWith(
                                    color: Colors.blueGrey.shade900,
                                    fontSize: 12.8,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          )
                              .toList(),
                        ),
                      )
                          .toList(),
                      headingRowColor: WidgetStateProperty.resolveWith(
                            (states) => Colors.transparent,
                      ),
                      dividerThickness: 0.65,
                      border: TableBorder(
                        horizontalInside: BorderSide(
                            width: 0.48, color: Colors.blue.shade100),
                        verticalInside: BorderSide(
                            width: 0.21, color: Colors.blue.shade50),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoData(BuildContext context) {
    return Container(
      height: 120,
      width: 360,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, color: Colors.blueGrey[200], size: 48),
          const SizedBox(height: 12),
          Text(
            "No data available in table",
            style: Fonts.body.copyWith(
              color: Colors.blueGrey[400],
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, IconData? icon, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        readOnly: icon != null,
        onTap: onTap,
        style: Fonts.body,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          suffixIcon: icon != null ? Icon(icon, color: Colors.blue) : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDropdown({required String label, required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: items.map((e) => DropdownMenuItem<String>(
          value: e,
          child: Text(
            e,
            style: Fonts.body,
          ),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
