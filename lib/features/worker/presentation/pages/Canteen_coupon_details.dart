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
      title: 'Canteen Coupon Detail Employee',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const CanteenCouponDetails(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CanteenCouponDetails extends StatefulWidget {
  const CanteenCouponDetails({super.key});

  @override
  State<CanteenCouponDetails> createState() => _CanteenCouponDetailsState();
}

class _CanteenCouponDetailsState extends State<CanteenCouponDetails> {
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  String couponType = 'Select';
  String userType = 'Personnel';
  final ScrollController _horizontalHeaderScrollController = ScrollController();
  final ScrollController _horizontalBodyScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final List<Map<String, dynamic>> _dummyData = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generateDummyData();
    // Sync scroll positions after the frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _horizontalHeaderScrollController.addListener(_syncHeaderScroll);
      _horizontalBodyScrollController.addListener(_syncBodyScroll);
    });
  }

  void _syncHeaderScroll() {
    if (_horizontalHeaderScrollController.offset != _horizontalBodyScrollController.offset) {
      _horizontalBodyScrollController.jumpTo(_horizontalHeaderScrollController.offset);
    }
  }

  void _syncBodyScroll() {
    if (_horizontalBodyScrollController.offset != _horizontalHeaderScrollController.offset) {
      _horizontalHeaderScrollController.jumpTo(_horizontalBodyScrollController.offset);
    }
  }

  void _generateDummyData() {
    final departments = ['HR', 'Finance', 'IT', 'Operations', 'Marketing'];
    final names = [
      'John Doe',
      'Jane Smith',
      'Robert Johnson',
      'Emily Davis',
      'Michael Wilson'
    ];

    for (int i = 0; i < 50; i++) {
      _dummyData.add({
        'fNo': 'F${1000 + i}',
        'docDate': DateFormat('dd/MM/yyyy').format(DateTime.now().subtract(Duration(days: i))),
        'scannedBy': 'Scanner ${i + 1}',
        'empCode': 'EMP${100 + i}',
        'empName': names[i % names.length],
        'deptCode': 'DEPT${i % 5 + 1}',
        'deptName': departments[i % departments.length],
        'food': i % 2 == 0 ? 'Yes' : 'No',
        'tea': i % 3 == 0 ? 'Yes' : 'No',
        'namkeen': i % 4 == 0 ? 'Yes' : 'No',
        'packed': i % 5 == 0 ? 'Yes' : 'No',
      });
    }
  }

  @override
  void dispose() {
    _horizontalHeaderScrollController.dispose();
    _horizontalBodyScrollController.dispose();
    _verticalScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? fromDate : toDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final columnWidths = [90.0, 130.0, 130.0, 130.0, 160.0, 135.0, 160.0, 85.0, 85.0, 95.0, 115.0];
    final totalWidth = columnWidths.reduce((sum, width) => sum + width);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Canteen Coupon Detail'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filter Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Date filters row
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateField(
                            context,
                            'From Date',
                            fromDate,
                            true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDateField(
                            context,
                            'To Date',
                            toDate,
                            false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Dropdown filters row
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            'Official/Personnel',
                            userType,
                            ['Official', 'Personnel'],
                                (value) => setState(() => userType = value!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdownField(
                            'Coupon Type',
                            couponType,
                            ['Select', 'Food', 'Tea', 'Namkeen'],
                                (value) => setState(() => couponType = value!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Status Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'As on ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            // Table Section
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // Table Header (NO Scrollbar)
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.85),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: SingleChildScrollView(
                        controller: _horizontalHeaderScrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        child: Row(
                          children: [
                            SizedBox(
                              width: totalWidth,
                              child: Row(
                                children: [
                                  _buildHeaderCell('F No', columnWidths[0]),
                                  _buildHeaderCell('Document Date', columnWidths[1]),
                                  _buildHeaderCell('Scanned By', columnWidths[2]),
                                  _buildHeaderCell('Employee Code', columnWidths[3]),
                                  _buildHeaderCell('Employee Name', columnWidths[4]),
                                  _buildHeaderCell('Dept/Cont Code', columnWidths[5]),
                                  _buildHeaderCell('Dept/Cont Name', columnWidths[6]),
                                  _buildHeaderCell('Food', columnWidths[7]),
                                  _buildHeaderCell('Tea', columnWidths[8]),
                                  _buildHeaderCell('Namkeen', columnWidths[9]),
                                  _buildHeaderCell('Packed Item', columnWidths[10], isLast: true),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Table Body (NO Scrollbar)
                    Expanded(
                      child: _dummyData.isEmpty
                          ? _buildEmptyState()
                          : SingleChildScrollView(
                        controller: _horizontalBodyScrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        child: SizedBox(
                          width: totalWidth,
                          child: SingleChildScrollView(
                            controller: _verticalScrollController,
                            scrollDirection: Axis.vertical,
                            physics: const ClampingScrollPhysics(),
                            child: Column(
                              children: [
                                ..._dummyData.map((data) => _buildDataRow(data, columnWidths)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(
      BuildContext context, String label, DateTime date, bool isFromDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Fonts.bodyBold,
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => _selectDate(context, isFromDate),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('dd/MM/yyyy').format(date)),
                const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildDropdownField(
      String label,
      String value,
      List<String> items,
      ValueChanged<String?> onChanged,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Fonts.bodyBold,
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text, double width, {bool isLast = false}) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        border: Border(
          right: isLast ? BorderSide.none : const BorderSide(color: Colors.white, width: 1.2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      child: Text(
        text,
        style: Fonts.bodyBold.copyWith(color: Colors.white),
        overflow: TextOverflow.visible,
        softWrap: true,
        textAlign: TextAlign.center,
        maxLines: 2, // Allow header text to wrap if needed
      ),
    );
  }

  Widget _buildDataRow(Map<String, dynamic> data, List<double> columnWidths) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildDataCell(data['fNo'], columnWidths[0]),
          _buildDataCell(data['docDate'], columnWidths[1]),
          _buildDataCell(data['scannedBy'], columnWidths[2]),
          _buildDataCell(data['empCode'], columnWidths[3]),
          _buildDataCell(data['empName'], columnWidths[4]),
          _buildDataCell(data['deptCode'], columnWidths[5]),
          _buildDataCell(data['deptName'], columnWidths[6]),
          _buildDataCell(data['food'], columnWidths[7]),
          _buildDataCell(data['tea'], columnWidths[8]),
          _buildDataCell(data['namkeen'], columnWidths[9]),
          _buildDataCell(data['packed'], columnWidths[10], isLast: true),
        ],
      ),
    );
  }

  Widget _buildDataCell(String text, double width, {bool isLast = false}) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        border: Border(
          right: isLast ? BorderSide.none : const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      alignment: Alignment.center,
      child: Text(
        text,
        overflow: TextOverflow.visible,
        softWrap: true,
        textAlign: TextAlign.center,
        style: Fonts.body,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.table_rows_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No data available in table',
            style: Fonts.body,
          ),
        ],
      ),
    );
  }
}
