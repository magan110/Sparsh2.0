import 'package:flutter/material.dart';
import 'package:learning2/data/models/SearchableDropdown.dart'; // Assuming these are correctly implemented
// and available.  If not, you'll need to
import 'package:learning2/data/models/DatePickerTextField.dart';
import 'package:learning2/data/models/SearchField.dart';
import 'package:learning2/core/constants/fonts.dart';

// Scheme Type Enum
enum SchemeType { primary, secondary }

// Scheme Status Enum
enum SchemeStatus { active, inactive, pending, completed }

// Scheme Model
class Scheme {
  final String schemeNo;
  final String sparshSchemeNo;
  final String schemeName;
  final SchemeType type;
  final double schemeValue;
  final double adjustmentAmount;
  final double cnDnValue;
  final DateTime postingDate;
  final String cnDnDocumentNo;
  final SchemeStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final String description;
  final Map<String, dynamic> additionalDetails;

  Scheme({
    required this.schemeNo,
    required this.sparshSchemeNo,
    required this.schemeName,
    required this.type,
    required this.schemeValue,
    required this.adjustmentAmount,
    required this.cnDnValue,
    required this.postingDate,
    required this.cnDnDocumentNo,
    this.status = SchemeStatus.active,
    required this.startDate,
    required this.endDate,
    this.description = '',
    this.additionalDetails = const {},
  });

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'schemeNo': schemeNo,
      'sparshSchemeNo': sparshSchemeNo,
      'schemeName': schemeName,
      'type': type.toString(),
      'schemeValue': schemeValue,
      'adjustmentAmount': adjustmentAmount,
      'cnDnValue': cnDnValue,
      'postingDate': postingDate.toIso8601String(),
      'cnDnDocumentNo': cnDnDocumentNo,
      'status': status.toString(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'description': description,
      'additionalDetails': additionalDetails,
    };
  }

  // Create from Map
  factory Scheme.fromMap(Map<String, dynamic> map) {
    return Scheme(
      schemeNo: map['schemeNo'] ?? '',
      sparshSchemeNo: map['sparshSchemeNo'] ?? '',
      schemeName: map['schemeName'] ?? '',
      type: SchemeType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => SchemeType.primary,
      ),
      schemeValue: (map['schemeValue'] ?? 0.0).toDouble(),
      adjustmentAmount: (map['adjustmentAmount'] ?? 0.0).toDouble(),
      cnDnValue: (map['cnDnValue'] ?? 0.0).toDouble(),
      postingDate: DateTime.parse(
        map['postingDate'] ?? DateTime.now().toIso8601String(),
      ),
      cnDnDocumentNo: map['cnDnDocumentNo'] ?? '',
      status: SchemeStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => SchemeStatus.active,
      ),
      startDate: DateTime.parse(
        map['startDate'] ?? DateTime.now().toIso8601String(),
      ),
      endDate: DateTime.parse(
        map['endDate'] ?? DateTime.now().toIso8601String(),
      ),
      description: map['description'] ?? '',
      additionalDetails: map['additionalDetails'] ?? {},
    );
  }

  // Sample data
  static List<Scheme> getSampleData() {
    return [
      Scheme(
        schemeNo: '12345',
        sparshSchemeNo: 'SS123',
        schemeName: 'Summer Promotion 2024',
        type: SchemeType.primary,
        schemeValue: 1000.0,
        adjustmentAmount: 100.0,
        cnDnValue: 50.0,
        postingDate: DateTime(2024, 1, 15),
        cnDnDocumentNo: 'CN123',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 3, 31),
        description: 'Summer season promotion for all products',
        additionalDetails: {
          'targetProducts': ['WC', 'WCP', 'VAP'],
          'minimumPurchase': 500.0,
        },
      ),
      Scheme(
        schemeNo: '67890',
        sparshSchemeNo: 'SS456',
        schemeName: 'Dealer Incentive Program',
        type: SchemeType.secondary,
        schemeValue: 2000.0,
        adjustmentAmount: 200.0,
        cnDnValue: 100.0,
        postingDate: DateTime(2024, 2, 20),
        cnDnDocumentNo: 'DN456',
        startDate: DateTime(2024, 2, 1),
        endDate: DateTime(2024, 4, 30),
        description: 'Special incentives for top performing dealers',
        additionalDetails: {
          'targetDealers': ['D001', 'D002', 'D003'],
          'performanceThreshold': 10000.0,
        },
      ),
    ];
  }
}

class Schema extends StatefulWidget {
  const Schema({super.key});

  @override
  State<Schema> createState() => _SchemaState();
}

class _SchemaState extends State<Schema> {
  final TextEditingController controller = TextEditingController();
  final List<String> types = ['Scheme Period Date', 'Account Ledger wise Date'];
  final List<Map<String, String>> _tableData = [
    {
      'Primary/Secondary Scheme': '',
      'Scheme No.': '',
      'Sparsh Scheme No': '',
      'Scheme Name': '',
      'Scheme Value': '',
      'Adjustment Amount': '',
      'CN / DN Value': '',
      'Posting Date': '',
      'CN / DN Document No': '',
    },
  ];

  // Added a function to build styled text for consistent labels.
  Widget _buildStyledText(String text) {
    return Text(
      text,
      style: Fonts.bodyBold.copyWith(
        color: const Color(0xFF555555), // Darker gray for better readability
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Scheme Details',
          style: Fonts.bodyBold.copyWith(letterSpacing: 0.5),
        ),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.white, Color(0xFFF8F9FA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStyledText('Type'),
                      const SizedBox(height: 12),
                      buildSearchableDropdown(context, types),
                      const SizedBox(height: 20),
                      _buildStyledText('Scheme Start Date'),
                      const SizedBox(height: 12),
                      const DatePickerTextField(),
                      const SizedBox(height: 20),
                      _buildStyledText('Scheme End Date'),
                      const SizedBox(height: 12),
                      const DatePickerTextField(),
                      const SizedBox(height: 20),
                      _buildStyledText('CN / DN No.'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: SearchField(controller: controller)),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              // your action
                            },
                            icon: const Icon(Icons.search, color: Colors.white),
                            label: Text(
                              "Go",
                              style: Fonts.body.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1976D2),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStyledText('Search'),
                      const SizedBox(height: 8),
                      SearchField(controller: controller),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTable(),
          ],
        ),
      ),
    );
  }

  // Moved _tableData outside of the function.
  final List<Map<String, String>> tableData = [
    {
      'Primary/Secondary Scheme': 'Primary',
      'Scheme No.': '12345',
      'Sparsh Scheme No': 'SS123',
      'Scheme Name': 'Sample Scheme 1',
      'Scheme Value': '1000',
      'Adjustment Amount': '100',
      'CN / DN Value': '50',
      'Posting Date': '2023-01-15',
      'CN / DN Document No': 'CN123',
    },
    {
      'Primary/Secondary Scheme': 'Secondary',
      'Scheme No.': '67890',
      'Sparsh Scheme No': 'SS456',
      'Scheme Name': 'Sample Scheme 2',
      'Scheme Value': '2000',
      'Adjustment Amount': '200',
      'CN / DN Value': '100',
      'Posting Date': '2023-02-20',
      'CN / DN Document No': 'DN456',
    },
    {
      'Primary/Secondary Scheme': 'Primary',
      'Scheme No.': '24680',
      'Sparsh Scheme No': 'SS789',
      'Scheme Name': 'Sample Scheme 3',
      'Scheme Value': '1500',
      'Adjustment Amount': '150',
      'CN / DN Value': '75',
      'Posting Date': '2023-03-25',
      'CN / DN Document No': 'CN789',
    },
    {
      'Primary/Secondary Scheme': 'Secondary',
      'Scheme No.': '13579',
      'Sparsh Scheme No': 'SS012',
      'Scheme Name': 'Sample Scheme 4',
      'Scheme Value': '2500',
      'Adjustment Amount': '250',
      'CN / DN Value': '125',
      'Posting Date': '2023-04-30',
      'CN / DN Document No': 'DN012',
    },
    {
      'Primary/Secondary Scheme': 'Primary',
      'Scheme No.': '98765',
      'Sparsh Scheme No': 'SS345',
      'Scheme Name': 'Sample Scheme 5',
      'Scheme Value': '3000',
      'Adjustment Amount': '300',
      'CN / DN Value': '150',
      'Posting Date': '2023-05-05',
      'CN / DN Document No': 'CN345',
    },
    {
      'Primary/Secondary Scheme': 'Secondary',
      'Scheme No.': '54321',
      'Sparsh Scheme No': 'SS678',
      'Scheme Name': 'Sample Scheme 6',
      'Scheme Value': '1800',
      'Adjustment Amount': '180',
      'CN / DN Value': '90',
      'Posting Date': '2023-06-10',
      'CN / DN Document No': 'DN678',
    },
    {
      'Primary/Secondary Scheme': 'Primary',
      'Scheme No.': '86420',
      'Sparsh Scheme No': 'SS901',
      'Scheme Name': 'Sample Scheme 7',
      'Scheme Value': '2200',
      'Adjustment Amount': '220',
      'CN / DN Value': '110',
      'Posting Date': '2023-07-15',
      'CN / DN Document No': 'CN901',
    },
    {
      'Primary/Secondary Scheme': 'Secondary',
      'Scheme No.': '24681',
      'Sparsh Scheme No': 'SS234',
      'Scheme Name': 'Sample Scheme 8',
      'Scheme Value': '2700',
      'Adjustment Amount': '270',
      'CN / DN Value': '135',
      'Posting Date': '2023-08-20',
      'CN / DN Document No': 'DN234',
    },
  ];
  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.table_chart, color: Colors.white, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Scheme Data',
                  style: Fonts.bodyBold.copyWith(
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF5F6FA)),
              dataRowColor: WidgetStateProperty.resolveWith<Color?>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFFE3F2FD);
                }
                return null;
              }),
              columnSpacing: 20,
              horizontalMargin: 20,
              headingTextStyle: Fonts.bodyBold.copyWith(
                color: const Color(0xFF1976D2),
              ),
              dataTextStyle: Fonts.body.copyWith(
                color: const Color(0xFF424242),
              ),
              columns: const [
                DataColumn(label: Text('Primary/Secondary Scheme')),
                DataColumn(label: Text('Scheme No.')),
                DataColumn(label: Text('Sparsh Scheme No')),
                DataColumn(label: Text('Scheme Name')),
                DataColumn(label: Text('Scheme Value'), numeric: true),
                DataColumn(label: Text('Adjustment Amount'), numeric: true),
                DataColumn(label: Text('CN / DN Value'), numeric: true),
                DataColumn(label: Text('Posting Date')),
                DataColumn(label: Text('CN / DN Document No')),
              ],
              rows:
                  tableData.map((item) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  item['Primary/Secondary Scheme'] == 'Primary'
                                      ? const Color(0xFFE3F2FD)
                                      : const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item['Primary/Secondary Scheme'] ?? '-',
                              style: TextStyle(
                                color:
                                    item['Primary/Secondary Scheme'] ==
                                            'Primary'
                                        ? const Color(0xFF1976D2)
                                        : const Color(0xFF2E7D32),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text(item['Scheme No.'] ?? '-')),
                        DataCell(Text(item['Sparsh Scheme No'] ?? '-')),
                        DataCell(
                          Text(
                            item['Scheme Name'] ?? '-',
                            style: Fonts.body.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ),
                        DataCell(
                          Text(
                            '₹${item['Scheme Value'] ?? '-'}',
                            style: Fonts.body.copyWith(
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1976D2),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '₹${item['Adjustment Amount'] ?? '-'}',
                            style: Fonts.body.copyWith(color: const Color(0xFF424242)),
                          ),
                        ),
                        DataCell(
                          Text(
                            '₹${item['CN / DN Value'] ?? '-'}',
                            style: Fonts.body.copyWith(color: const Color(0xFF424242)),
                          ),
                        ),
                        DataCell(
                          Text(
                            item['Posting Date'] ?? '-',
                            style: Fonts.body.copyWith(color: const Color(0xFF757575)),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item['CN / DN Document No'] ?? '-',
                              style: Fonts.body.copyWith(
                                color: const Color(0xFF616161),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
