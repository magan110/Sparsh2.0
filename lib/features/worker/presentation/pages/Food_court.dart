import 'package:flutter/material.dart';
import 'package:learning2/core/constants/fonts.dart';

class FoodCourt extends StatefulWidget {
  const FoodCourt({super.key});

  @override
  State<FoodCourt> createState() => _FoodCourtState();
}

class _FoodCourtState extends State<FoodCourt> {

  final List<String> processTypes = ["Add", "Update", "Delete"];
  String? selectedProcessType = "Add";

  List<Map<String, dynamic>> items = [
    {
      "name": "CHOCOLATE -CAKES / 500 ML",
      "price": 320.0,
      "img": "https://www.havmor.com/sites/default/files/products/Chocolate-Cake.png",
      "qty": 0,
    },
    {
      "name": "DRYFRUIT RABDI KULFI / 70 ML",
      "price": 40.0,
      "img": "https://www.havmor.com/sites/default/files/products/Dryfruit-Rabdi-Kulfi.png",
      "qty": 0,
    },
    {
      "name": "BLACK FOREST / 500 ML",
      "price": 350.0,
      "img": "https://www.havmor.com/sites/default/files/products/Black-Forest.png",
      "qty": 0,
    },
    {
      "name": "RUM N RAISIN / 500 ML",
      "price": 370.0,
      "img": "https://www.havmor.com/sites/default/files/products/Rum-n-Raisin.png",
      "qty": 0,
    },
  ];

  Widget _buildHeaderCard() {
    return Card(
      color: const Color(0xFFFDFDFD),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      elevation: 9,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text('Mr BHARAT KACHHAWAHA',
                style: Fonts.body.copyWith(fontWeight: FontWeight.w500, fontSize: 18)),
            const SizedBox(height: 12),
            Text('Process Type',
                style: Fonts.body.copyWith(fontWeight: FontWeight.w600, fontSize: 22)),
            const SizedBox(height: 7),
            DropdownButtonFormField<String>(
              value: selectedProcessType,
              items: processTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(
                    type,
                    style: Fonts.body.copyWith(fontWeight: FontWeight.w600, color: Colors.grey[800]),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  selectedProcessType = val!;
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF6DB3F2), width: 2),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              dropdownColor: Colors.white,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(int idx) {
    var item = items[idx];
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      elevation: 8,
      margin: const EdgeInsets.all(7),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                item['img'],
                height: 65,
                width: 65,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 65,
                  width: 65,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 30, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              item['name'],
              textAlign: TextAlign.center,
              style: Fonts.body.copyWith(fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Price : ",
                    style: Fonts.body.copyWith(fontWeight: FontWeight.w600, color: Colors.teal, fontSize: 13.5),
                  ),
                  TextSpan(
                    text: "${item['price']}",
                    style: Fonts.bodyBold.copyWith(color: Colors.teal, fontSize: 14),
                  ),
                  TextSpan(
                    text: " NO",
                    style: Fonts.body.copyWith(color: Colors.grey[600], fontSize: 11.5, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _iconButton(idx, false),
                Container(
                  width: 28,
                  alignment: Alignment.center,
                  child: Text(
                    "${item['qty']}",
                    style: Fonts.bodyBold.copyWith(fontSize: 15),
                  ),
                ),
                _iconButton(idx, true),
              ],
            ),
            const SizedBox(height: 6),
            // PRICE SHOWN IMMEDIATELY BELOW THE QTY CONTROLS
            Text(
              "₹ ${(item['qty'] * item['price']).toStringAsFixed(2)}",
              style: Fonts.bodyBold.copyWith(color: Colors.indigo, fontSize: 15.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconButton(int idx, bool isPlus) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () {
        setState(() {
          if (isPlus) {
            items[idx]['qty']++;
          } else if (items[idx]['qty'] > 0) {
            items[idx]['qty']--;
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
            color: isPlus ? Colors.teal : Colors.grey[300],
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              if (isPlus)
                const BoxShadow(
                  color: Colors.tealAccent,
                  blurRadius: 7,
                  offset: Offset(0, 2),
                )
            ]),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Icon(
          isPlus ? Icons.add : Icons.remove,
          color: isPlus ? Colors.white : Colors.black87,
          size: 18,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Let grid auto-size based on content. No fixed height.
    return Scaffold(
      backgroundColor: const Color(0xFFD2E4FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeaderCard(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.74, // ~square, adjust for your look
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemBuilder: (context, idx) => _buildItemCard(idx),
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}
