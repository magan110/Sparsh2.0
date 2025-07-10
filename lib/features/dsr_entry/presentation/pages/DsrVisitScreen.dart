import 'package:flutter/material.dart';
import 'package:learning2/features/dashboard/presentation/pages/edit_kyc_screen.dart';

class DsrVisitScreen extends StatefulWidget {
  const DsrVisitScreen({super.key});

  @override
  State<DsrVisitScreen> createState() => _DsrVisitScreenState();
}

class _DsrVisitScreenState extends State<DsrVisitScreen> {
  // Form controllers and variables
  String processType = 'A';
  String? documentNo;
  String? purchaserType;
  String? areaCode;
  String? purchaserCode;
  String? kycStatus = 'Verified';
  String? reportDate;
  String? marketName;
  String? displayContest;
  String? pendingIssue;
  String? pendingIssueDetail;
  String? issueDetail;
  String? wcEnrolment;
  String? wcpEnrolment;
  String? vapEnrolment;
  String? wcStock;
  String? wcpStock;
  String? vapStock;
  String? slWcVolume;
  String? slWpVolume;
  String? orderExecutionDate;
  String? remarks;
  String? cityReason;
  String? tileAdhesiveSeller;
  String? tileAdhesiveStock;
  String? name = '';
  String? kycEditUrl;

  // Dynamic lists
  List<Map<String, String>> productList = [];
  List<Map<String, String>> giftList = [];
  List<Map<String, String>> marketSkuList = [];

  // Brands selling checkboxes
  Map<String, bool> brandsWc = {
    'BW': false,
    'JK': false,
    'RK': false,
    'OT': false,
  };
  Map<String, bool> brandsWcp = {
    'BW': false,
    'JK': false,
    'AP': false,
    'BG': false,
    'AC': false,
    'PM': false,
    'OT': false,
  };

  // Averages (mock data)
  Map<String, String> last3MonthsAvg = {
    'JK_WC': '0',
    'JK_WCP': '0',
    'AS_WC': '0',
    'AS_WCP': '0',
    'OT_WC': '0',
    'OT_WCP': '0',
  };
  Map<String, String> currentMonthBW = {
    'WC': '0.00',
    'WCP': '0.00',
    'VAP': '0.00',
  };

  final _formKey = GlobalKey<FormState>();

  // Mock data for dropdowns
  final List<String> documentNoList = ['Doc001', 'Doc002', 'Doc003'];
  final List<String> purchaserTypeList = [
    'Retailer',
    'Rural Retailer',
    'Stockiest',
    'Direct Dealer',
    'Rural Stockiest',
    'AD',
    'UBS',
  ];
  final List<String> areaCodeList = ['Area1', 'Area2', 'Area3'];
  final List<String> pendingIssueDetails = ['Token', 'Scheme', 'Product', 'Other'];
  final List<String> cityReasons = [
    'Network Issue',
    'Battery Low',
    'Mobile Not working',
    'Location not capturing',
    'Wrong Location OF Retailer',
    'Wrong Location Captured',
  ];
  final List<String> tileAdhesiveOptions = ['YES', 'NO'];

  // Mock data for last billing date as per Tally
  final List<Map<String, String>> lastBillingData = [
    {'product': 'White Cement', 'date': '16 Nov 2023', 'qty': '0.65000'},
    {'product': 'Water Proofing Compound', 'date': '22 Jul 2023', 'qty': '0.01500'},
  ];

  // Helper to add product row
  void addProductRow() {
    setState(() {
      productList.add({
        'product': '',
        'sku': '',
        'qty': '',
      });
    });
  }

  void removeProductRow(int index) {
    setState(() {
      productList.removeAt(index);
    });
  }

  // Helper to add gift row
  void addGiftRow() {
    setState(() {
      giftList.add({
        'giftType': '',
        'qty': '',
      });
    });
  }

  void removeGiftRow(int index) {
    setState(() {
      giftList.removeAt(index);
    });
  }

  // Helper to add market SKU row
  void addMarketSkuRow() {
    setState(() {
      marketSkuList.add({
        'brand': '',
        'product': '',
        'priceB': '',
        'priceC': '',
      });
    });
  }

  void removeMarketSkuRow(int index) {
    setState(() {
      marketSkuList.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    // Add one row by default for each dynamic list
    if (productList.isEmpty) addProductRow();
    if (giftList.isEmpty) addGiftRow();
    if (marketSkuList.isEmpty) addMarketSkuRow();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('DSR Visit Entry'),
        elevation: 4,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
      ),
      backgroundColor: theme.colorScheme.surface.withOpacity(0.98),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Process Type ---
                const _SectionHeader(icon: Icons.settings, label: 'Process Type'),
                _FantasticCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Radio<String>(
                            value: 'A',
                            groupValue: processType,
                            onChanged: (v) => setState(() => processType = v!),
                          ),
                          const Text('Add'),
                          Radio<String>(
                            value: 'U',
                            groupValue: processType,
                            onChanged: (v) => setState(() => processType = v!),
                          ),
                          const Text('Update'),
                          Radio<String>(
                            value: 'D',
                            groupValue: processType,
                            onChanged: (v) => setState(() => processType = v!),
                          ),
                          const Text('Delete'),
                        ],
                      ),
                      if (processType != 'A')
                        DropdownButtonFormField<String>(
                          value: documentNo,
                          decoration: _fantasticInputDecoration('Document No'),
                          items: documentNoList
                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) => setState(() => documentNo = v),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // --- Purchaser/Retailer Type, Area Code, Purchaser Code, Name, KYC ---
                const _SectionHeader(icon: Icons.person, label: 'Purchaser / Retailer Details'),
                _FantasticCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: purchaserType,
                        decoration: _fantasticInputDecoration('Purchaser / Retailer Type *'),
                        items: purchaserTypeList
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => purchaserType = v),
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: areaCode,
                        decoration: _fantasticInputDecoration('Area Code *'),
                        items: areaCodeList
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => areaCode = v),
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: _fantasticInputDecoration('Purchaser Code *', icon: Icons.search),
                        onChanged: (v) => purchaserCode = v,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text('Name: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(name ?? '', style: const TextStyle(fontWeight: FontWeight.normal)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary,
                            foregroundColor: theme.colorScheme.onSecondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const EditKycScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit KYC'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: kycStatus,
                        decoration: _fantasticInputDecoration('KYC Status'),
                        items: ['Verified', 'Not Verified']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: null, // Disabled
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // --- Report Date, Market Name, Display Contest, Pending Issues ---
                const _SectionHeader(icon: Icons.event_note, label: 'Report & Market Details'),
                _FantasticCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        decoration: _fantasticInputDecoration('Report Date *', icon: Icons.calendar_today),
                        readOnly: true,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 3)),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              reportDate = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                            });
                          }
                        },
                        controller: TextEditingController(text: reportDate),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: _fantasticInputDecoration('Market Name (Location Or Road Name) *'),
                        onChanged: (v) => marketName = v,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),
                      const Text('Participation of Display Contest *', style: TextStyle(fontWeight: FontWeight.w500)),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'Y',
                            groupValue: displayContest,
                            onChanged: (v) => setState(() => displayContest = v),
                          ),
                          const Text('Yes'),
                          Radio<String>(
                            value: 'N',
                            groupValue: displayContest,
                            onChanged: (v) => setState(() => displayContest = v),
                          ),
                          const Text('No'),
                          Radio<String>(
                            value: 'NA',
                            groupValue: displayContest,
                            onChanged: (v) => setState(() => displayContest = v),
                          ),
                          const Text('NA'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text('Any Pending Issues (Yes/No) *', style: TextStyle(fontWeight: FontWeight.w500)),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'Y',
                            groupValue: pendingIssue,
                            onChanged: (v) => setState(() => pendingIssue = v),
                          ),
                          const Text('Yes'),
                          Radio<String>(
                            value: 'N',
                            groupValue: pendingIssue,
                            onChanged: (v) => setState(() => pendingIssue = v),
                          ),
                          const Text('No'),
                        ],
                      ),
                      if (pendingIssue == 'Y') ...[
                        DropdownButtonFormField<String>(
                          value: pendingIssueDetail,
                          decoration: _fantasticInputDecoration('If Yes, pending issue details *'),
                          items: pendingIssueDetails
                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) => setState(() => pendingIssueDetail = v),
                          validator: (v) => v == null ? 'Required' : null,
                        ),
                        TextFormField(
                          decoration: _fantasticInputDecoration('If Yes, Specify Issue'),
                          onChanged: (v) => issueDetail = v,
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // --- Enrolment Slab ---
                const _SectionHeader(icon: Icons.bar_chart, label: 'Enrolment Slab (in MT)'),
                _FantasticCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        decoration: _fantasticInputDecoration('WC'),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => wcEnrolment = v,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: _fantasticInputDecoration('WCP'),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => wcpEnrolment = v,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: _fantasticInputDecoration('VAP'),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => vapEnrolment = v,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // --- BW Stocks Availability ---
                const _SectionHeader(icon: Icons.inventory, label: 'BW Stocks Availability (in MT)'),
                _FantasticCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        decoration: _fantasticInputDecoration('WC'),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => wcStock = v,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: _fantasticInputDecoration('WCP'),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => wcpStock = v,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: _fantasticInputDecoration('VAP'),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => vapStock = v,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // --- Brands Selling ---
                const _SectionHeader(icon: Icons.check_box, label: 'Brands Selling'),
                _FantasticCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('WC (Industry Volume)', style: TextStyle(fontWeight: FontWeight.w500)),
                      Wrap(
                        spacing: 8,
                        children: brandsWc.keys.map((brand) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: brandsWc[brand],
                                onChanged: (v) => setState(() => brandsWc[brand] = v ?? false),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                              Text(brand),
                            ],
                          );
                        }).toList(),
                      ),
                      TextFormField(
                        decoration: _fantasticInputDecoration('WC Industry Volume in (MT)'),
                        onChanged: (v) => slWcVolume = v,
                      ),
                      const SizedBox(height: 10),
                      const Text('WCP (Industry Volume)', style: TextStyle(fontWeight: FontWeight.w500)),
                      Wrap(
                        spacing: 8,
                        children: brandsWcp.keys.map((brand) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: brandsWcp[brand],
                                onChanged: (v) => setState(() => brandsWcp[brand] = v ?? false),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                              Text(brand),
                            ],
                          );
                        }).toList(),
                      ),
                      TextFormField(
                        decoration: _fantasticInputDecoration('WCP Industry Volume in (MT)'),
                        onChanged: (v) => slWpVolume = v,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // --- Last 3 Months Average ---
                const _SectionHeader(icon: Icons.timeline, label: 'Last 3 Months Average'),
                _FantasticCard(
                  child: Table(
                    border: TableBorder.all(color: theme.dividerColor),
                    children: [
                      const TableRow(children: [
                        SizedBox(),
                        Center(child: Text('WC Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                        Center(child: Text('WCP Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                      ]),
                      TableRow(children: [
                        const Center(child: Text('JK')),
                        TextFormField(
                          initialValue: last3MonthsAvg['JK_WC'],
                          decoration: _fantasticInputDecoration(''),
                          onChanged: (v) => last3MonthsAvg['JK_WC'] = v,
                        ),
                        TextFormField(
                          initialValue: last3MonthsAvg['JK_WCP'],
                          decoration: _fantasticInputDecoration(''),
                          onChanged: (v) => last3MonthsAvg['JK_WCP'] = v,
                        ),
                      ]),
                      TableRow(children: [
                        const Center(child: Text('Asian')),
                        TextFormField(
                          initialValue: last3MonthsAvg['AS_WC'],
                          decoration: _fantasticInputDecoration(''),
                          onChanged: (v) => last3MonthsAvg['AS_WC'] = v,
                        ),
                        TextFormField(
                          initialValue: last3MonthsAvg['AS_WCP'],
                          decoration: _fantasticInputDecoration(''),
                          onChanged: (v) => last3MonthsAvg['AS_WCP'] = v,
                        ),
                      ]),
                      TableRow(children: [
                        const Center(child: Text('Other')),
                        TextFormField(
                          initialValue: last3MonthsAvg['OT_WC'],
                          decoration: _fantasticInputDecoration(''),
                          onChanged: (v) => last3MonthsAvg['OT_WC'] = v,
                        ),
                        TextFormField(
                          initialValue: last3MonthsAvg['OT_WCP'],
                          decoration: _fantasticInputDecoration(''),
                          onChanged: (v) => last3MonthsAvg['OT_WCP'] = v,
                        ),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // --- Current Month - BW ---
                const _SectionHeader(icon: Icons.calendar_month, label: 'Current Month - BW (in MT)'),
                _FantasticCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        initialValue: currentMonthBW['WC'],
                        decoration: _fantasticInputDecoration('WC'),
                        readOnly: true,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        initialValue: currentMonthBW['WCP'],
                        decoration: _fantasticInputDecoration('WCP'),
                        readOnly: true,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        initialValue: currentMonthBW['VAP'],
                        decoration: _fantasticInputDecoration('VAP'),
                        readOnly: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // --- Order Booked in call/e meet (Dynamic List) ---
                const _SectionHeader(icon: Icons.shopping_cart, label: 'Order Booked in call/e meet'),
                _FantasticCard(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Order Booked in call/e meet', style: TextStyle(fontWeight: FontWeight.w500)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: addProductRow,
                          ),
                        ],
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: productList.length,
                        itemBuilder: (context, idx) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    decoration: _fantasticInputDecoration('Product'),
                                    onChanged: (v) => productList[idx]['product'] = v,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    decoration: _fantasticInputDecoration('SKU'),
                                    onChanged: (v) => productList[idx]['sku'] = v,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    decoration: _fantasticInputDecoration('Qty'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (v) => productList[idx]['qty'] = v,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => removeProductRow(idx),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // --- Market -- WCP (Highest selling SKU) (Dynamic List) ---
                const _SectionHeader(icon: Icons.trending_up, label: 'Market -- WCP (Highest selling SKU)'),
                _FantasticCard(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Market -- WCP (Highest selling SKU)', style: TextStyle(fontWeight: FontWeight.w500)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: addMarketSkuRow,
                          ),
                        ],
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: marketSkuList.length,
                        itemBuilder: (context, idx) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    decoration: _fantasticInputDecoration('Brand'),
                                    onChanged: (v) => marketSkuList[idx]['brand'] = v,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    decoration: _fantasticInputDecoration('Product'),
                                    onChanged: (v) => marketSkuList[idx]['product'] = v,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    decoration: _fantasticInputDecoration('Price - B'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (v) => marketSkuList[idx]['priceB'] = v,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    decoration: _fantasticInputDecoration('Price - C'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (v) => marketSkuList[idx]['priceC'] = v,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => removeMarketSkuRow(idx),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // --- Gift Distribution (Dynamic List) ---
                const _SectionHeader(icon: Icons.card_giftcard, label: 'Gift Distribution'),
                _FantasticCard(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Gift Distribution', style: TextStyle(fontWeight: FontWeight.w500)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: addGiftRow,
                          ),
                        ],
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: giftList.length,
                        itemBuilder: (context, idx) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    decoration: _fantasticInputDecoration('Gift Type'),
                                    onChanged: (v) => giftList[idx]['giftType'] = v,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    decoration: _fantasticInputDecoration('Qty'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (v) => giftList[idx]['qty'] = v,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => removeGiftRow(idx),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // --- Tile Adhesives ---
                const _SectionHeader(icon: Icons.layers, label: 'Tile Adhesives'),
                _FantasticCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: tileAdhesiveSeller,
                        decoration: _fantasticInputDecoration('Is this Tile Adhesives seller?'),
                        items: tileAdhesiveOptions
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => tileAdhesiveSeller = v),
                      ),
                      TextFormField(
                        decoration: _fantasticInputDecoration('Tile Adhesive Stock'),
                        onChanged: (v) => tileAdhesiveStock = v,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // --- Order Execution Date, Remarks, Reason ---
                const _SectionHeader(icon: Icons.event, label: 'Order Execution & Remarks'),
                _FantasticCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        decoration: _fantasticInputDecoration('Order Execution date', icon: Icons.calendar_today),
                        readOnly: true,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 30)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() {
                              orderExecutionDate = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                            });
                          }
                        },
                        controller: TextEditingController(text: orderExecutionDate),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: _fantasticInputDecoration('Any other Remarks'),
                        onChanged: (v) => remarks = v,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: cityReason,
                        decoration: _fantasticInputDecoration('Select Reason'),
                        items: cityReasons
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => cityReason = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // --- Map/Location Placeholder ---
                const _SectionHeader(icon: Icons.map, label: 'Map/Location'),
                const _FantasticCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text('Map/Location (to be implemented)'),
                      SizedBox(height: 100, child: Center(child: Text('Map widget placeholder'))),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // --- Last Billing date as per Tally ---
                const _SectionHeader(icon: Icons.receipt_long, label: 'Last Billing date as per Tally'),
                _FantasticCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Table(
                        border: TableBorder.all(color: theme.dividerColor),
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(1),
                        },
                        children: [
                          const TableRow(children: [
                            Padding(
                              padding: EdgeInsets.all(6.0),
                              child: Text('Product', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(6.0),
                              child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(6.0),
                              child: Text('Qty.', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ]),
                          ...lastBillingData.map((row) => TableRow(children: [
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Text(row['product'] ?? ''),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Text(row['date'] ?? ''),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Text(row['qty'] ?? ''),
                            ),
                          ])),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // --- Bottom Action Buttons ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: theme.colorScheme.primary, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        // TODO: Add another activity logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Add Another Activity (mock)')),
                        );
                      },
                      child: const Text('Add Another Activity', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // TODO: Handle submit & exit
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Submitted & Exit (mock)')),
                          );
                        }
                      },
                      child: const Text('Submit & Exit', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: theme.colorScheme.secondary, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        // TODO: Show submitted data logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Show Submitted Data (mock)')),
                        );
                      },
                      child: const Text('Click to See Submitted Data', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Fantastic Section Header Widget ---
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionHeader({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 16),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Fantastic Card Widget ---
class _FantasticCard extends StatelessWidget {
  final Widget child;
  const _FantasticCard({required this.child});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}

// --- Fantastic Input Decoration Helper ---
InputDecoration _fantasticInputDecoration(String label, {IconData? icon}) {
  return InputDecoration(
    labelText: label.isNotEmpty ? label : null,
    filled: true,
    fillColor: Colors.grey[100],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.blue.shade300, width: 1.5),
    ),
    suffixIcon: icon != null ? Icon(icon, size: 20) : null,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );
}
