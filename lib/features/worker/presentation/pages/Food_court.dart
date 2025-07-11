import 'package:flutter/material.dart';
import 'package:learning2/core/constants/fonts.dart';
import 'package:learning2/core/components/advanced_3d/advanced_3d_components.dart';
import 'package:learning2/core/utils/responsive_design.dart';
import 'package:learning2/core/utils/form_validators/form_validators.dart';
import 'package:learning2/core/theme/app_theme.dart';

class FoodCourt extends StatefulWidget {
  const FoodCourt({super.key});

  @override
  State<FoodCourt> createState() => _FoodCourtState();
}

class _FoodCourtState extends State<FoodCourt> with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

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

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Widget _buildHeaderCard() {
    return Advanced3DCard(
      padding: ResponsiveSpacing.all(context, 18),
      margin: ResponsiveSpacing.symmetric(context, horizontal: 20, vertical: 16),
      borderRadius: 25,
      enableGlassMorphism: true,
      backgroundColor: SparshTheme.cardBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            'Mr BHARAT KACHHAWAHA',
            style: TextStyle(
              fontSize: ResponsiveTypography.bodyText1(context),
              fontWeight: FontWeight.w500,
              color: SparshTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Process Type',
            style: TextStyle(
              fontSize: ResponsiveTypography.headingMedium(context),
              fontWeight: FontWeight.w600,
              color: SparshTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Advanced3DCard(
            backgroundColor: SparshTheme.cardBackground,
            borderRadius: 14,
            child: Padding(
              padding: ResponsiveSpacing.all(context, 4),
              child: DropdownButtonFormField<String>(
                value: selectedProcessType,
                items: processTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(
                      type,
                      style: TextStyle(
                        fontSize: ResponsiveTypography.bodyText1(context),
                        fontWeight: FontWeight.w600,
                        color: SparshTheme.textPrimary,
                      ),
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
                  fillColor: SparshTheme.cardBackground,
                  contentPadding: ResponsiveSpacing.symmetric(context, horizontal: 16, vertical: 14),
                  border: InputBorder.none,
                ),
                dropdownColor: SparshTheme.cardBackground,
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: SparshTheme.primaryBlue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(int idx) {
    var item = items[idx];
    return Advanced3DCard(
      borderRadius: 22,
      enableGlassMorphism: true,
      backgroundColor: SparshTheme.cardBackground,
      margin: ResponsiveSpacing.all(context, 7),
      child: Padding(
        padding: ResponsiveSpacing.symmetric(context, horizontal: 8, vertical: 10),
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
                  decoration: BoxDecoration(
                    color: SparshTheme.textSecondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.image, size: 30, color: SparshTheme.textSecondary),
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              item['name'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveTypography.bodyText2(context),
                fontWeight: FontWeight.w600,
                color: SparshTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Price : ",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.teal,
                      fontSize: ResponsiveTypography.bodyText2(context),
                    ),
                  ),
                  TextSpan(
                    text: "₹${item['price']}",
                    style: TextStyle(
                      color: Colors.teal,
                      fontSize: ResponsiveTypography.bodyText1(context),
                      fontWeight: FontWeight.bold,
                    ),
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
                    style: TextStyle(
                      fontSize: ResponsiveTypography.bodyText1(context),
                      fontWeight: FontWeight.bold,
                      color: SparshTheme.textPrimary,
                    ),
                  ),
                ),
                _iconButton(idx, true),
              ],
            ),
            const SizedBox(height: 6),
            // Total price
            Text(
              "₹ ${(item['qty'] * item['price']).toStringAsFixed(2)}",
              style: TextStyle(
                color: SparshTheme.primaryBlue,
                fontSize: ResponsiveTypography.bodyText1(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconButton(int idx, bool isPlus) {
    return Advanced3DButton(
      onPressed: () {
        setState(() {
          if (isPlus) {
            items[idx]['qty']++;
          } else if (items[idx]['qty'] > 0) {
            items[idx]['qty']--;
          }
        });
      },
      backgroundColor: isPlus ? Colors.teal : SparshTheme.textSecondary.withOpacity(0.3),
      foregroundColor: isPlus ? Colors.white : SparshTheme.textPrimary,
      padding: ResponsiveSpacing.symmetric(context, horizontal: 7, vertical: 3),
      borderRadius: 30,
      child: Icon(
        isPlus ? Icons.add : Icons.remove,
        size: 18,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SparshTheme.scaffoldBackground,
      appBar: Advanced3DAppBar(
        title: 'Food Court',
        centerTitle: true,
        backgroundColor: SparshTheme.primaryBlue,
        elevation: 8,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: ResponsiveSpacing.all(context, 8),
                  child: Column(
                    children: [
                      // Header Card with animation
                      Transform.scale(
                        scale: _scaleAnimation.value,
                        child: _buildHeaderCard(),
                      ),
                      
                      // Items Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: ResponsiveUtil.isDesktop(context) ? 3 : 2,
                          childAspectRatio: 0.74,
                          mainAxisSpacing: ResponsiveUtil.scaledSize(context, 8),
                          crossAxisSpacing: ResponsiveUtil.scaledSize(context, 8),
                        ),
                        itemBuilder: (context, idx) => _buildItemCard(idx),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
