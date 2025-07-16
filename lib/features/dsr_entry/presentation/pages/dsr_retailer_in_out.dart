import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../../../core/theme/app_theme.dart';
import 'DsrVisitScreen.dart';

class DsrRetailerInOut extends StatefulWidget {
  const DsrRetailerInOut({super.key});

  @override
  State<DsrRetailerInOut> createState() => _DsrRetailerInOutState();
}

class PurchaserRetailerType {
  final String code;
  final String description;
  PurchaserRetailerType({required this.code, required this.description});
  factory PurchaserRetailerType.fromJson(Map<String, dynamic> json) {
    return PurchaserRetailerType(
      code: json['code'] ?? json['Code'],
      description: json['description'] ?? json['Description'],
    );
  }
}

class AreaCodeModel {
  final String code;
  final String name;
  AreaCodeModel({required this.code, required this.name});
  factory AreaCodeModel.fromJson(Map<String, dynamic> json) {
    return AreaCodeModel(
      code: json['code'] ?? json['Code'],
      name: json['name'] ?? json['Name'],
    );
  }
}

class _DsrRetailerInOutState extends State<DsrRetailerInOut>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  // State
  final String _purchaserRetailerItem = 'Select';
  AreaCodeModel? _selectedAreaCode;
  DateTime? _selectedDate;

  // Controllers
  final _dateController            = TextEditingController();
  final _yourLatitudeController    = TextEditingController();
  final _yourLongitudeController   = TextEditingController();
  final _custLatitudeController    = TextEditingController();
  final _custLongitudeController   = TextEditingController();
  final _codeSearchController      = TextEditingController();
  final _customerNameController    = TextEditingController();

  // Dropdown data
  PurchaserRetailerType? _selectedPurchaserRetailerType;
  List<PurchaserRetailerType> _purchaserRetailerTypes = [];
  bool _isLoadingPurchaserRetailerTypes = false;
  List<AreaCodeModel> _areaCodes = [];
  bool _isLoadingAreaCodes = false;

  final _formKey = GlobalKey<FormState>();
  final List<XFile?> _selectedImages = [null];
  final _picker = ImagePicker();

  // Colors - Using theme constants
  final _primaryColor    = SparshTheme.primaryBlueAccent;
  final _secondaryColor  = SparshTheme.primaryBlueLight;
  final _backgroundColor = SparshTheme.scaffoldBackground;
  final _cardColor       = SparshTheme.cardBackground;
  final _textColor       = SparshTheme.textPrimary;
  final _hintColor       = SparshTheme.textSecondary;

  List<String> _codeSearchList = [];
  String? _selectedCodeSearch;
  bool _isLoadingCodeSearch = false;

  double _calculatedDistance = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController, curve: Curves.easeOut,
    );
    _animationController.forward();
    _selectedDate = DateTime.now();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    _fetchPurchaserRetailerTypes();
    _fetchAreaCodes();
    _captureYourLocation();
    _yourLatitudeController.addListener(_calculateDistance);
    _yourLongitudeController.addListener(_calculateDistance);
    _custLatitudeController.addListener(_calculateDistance);
    _custLongitudeController.addListener(_calculateDistance);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _dateController.dispose();
    _yourLatitudeController.removeListener(_calculateDistance);
    _yourLongitudeController.removeListener(_calculateDistance);
    _custLatitudeController.removeListener(_calculateDistance);
    _custLongitudeController.removeListener(_calculateDistance);
    _yourLatitudeController.dispose();
    _yourLongitudeController.dispose();
    _custLatitudeController.dispose();
    _custLongitudeController.dispose();
    _codeSearchController.dispose();
    _customerNameController.dispose();
    super.dispose();
  }

  Future<Position> _determinePosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw 'Location services are disabled.';
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied.';
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied.';
    }
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  void _updateYourLocation(String lat, String lon) {
    _yourLatitudeController.text = lat;
    _yourLongitudeController.text = lon;
    _calculateDistance();
  }

  void _updateCustomerLocation(String lat, String lon) {
    _custLatitudeController.text = lat;
    _custLongitudeController.text = lon;
    _calculateDistance();
  }

  Future<void> _captureYourLocation() async {
    try {
      final pos = await _determinePosition();
      _updateYourLocation(pos.latitude.toStringAsFixed(6), pos.longitude.toStringAsFixed(6));
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _captureCustomerLocation() async {
    try {
      final pos = await _determinePosition();
      _updateCustomerLocation(pos.latitude.toStringAsFixed(6), pos.longitude.toStringAsFixed(6));
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final threeDaysAgo = now.subtract(const Duration(days: 3));
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: threeDaysAgo,
      lastDate: now,  // Only allow up to today
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: SparshTheme.primaryBlueAccent,
            onPrimary: Colors.white,
            onSurface: SparshTheme.textPrimary,
          ),
          dialogTheme: const DialogThemeData(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // Calculate distance between user and customer location
  void _calculateDistance() {
    try {
      final userLat = double.tryParse(_yourLatitudeController.text) ?? 0.0;
      final userLon = double.tryParse(_yourLongitudeController.text) ?? 0.0;
      final custLat = double.tryParse(_custLatitudeController.text) ?? 0.0;
      final custLon = double.tryParse(_custLongitudeController.text) ?? 0.0;

      if (userLat != 0.0 && userLon != 0.0 && custLat != 0.0 && custLon != 0.0) {
        final distance = _calculateDistanceInMeters(userLat, userLon, custLat, custLon);
        setState(() {
          _calculatedDistance = distance;
        });
      }
    } catch (e) {
      print('Error calculating distance: $e');
    }
  }

  double _calculateDistanceInMeters(double lat1, double lon1, double lat2, double lon2) {
    const double pi = math.pi;
    var radlat1 = pi * lat1 / 180;
    var radlat2 = pi * lat2 / 180;
    var theta = lon1 - lon2;
    var radtheta = pi * theta / 180;
    var dist = math.sin(radlat1) * math.sin(radlat2) +
               math.cos(radlat1) * math.cos(radlat2) * math.cos(radtheta);
    if (dist > 1) dist = 1;
    dist = math.acos(dist);
    dist = dist * 180 / pi;
    dist = dist * 60 * 1.1515;           // miles
    dist = dist * 1.609344 * 1000;       // convert to meters
    return dist;
  }

  void _showDistanceWarningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SparshBorderRadius.xl),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: SparshTheme.warningOrange,
              size: SparshSpacing.lg,
            ),
            const SizedBox(width: SparshSpacing.sm),
            Text(
              'Distance Warning',
              style: SparshTypography.heading5.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are currently ${_calculatedDistance.toStringAsFixed(2)} meters away from the customer location.',
              style: SparshTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: SparshSpacing.sm),
            Container(
              padding: const EdgeInsets.all(SparshSpacing.md),
              decoration: BoxDecoration(
                color: SparshTheme.warningOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(SparshBorderRadius.lg),
                border: Border.all(color: SparshTheme.warningOrange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: SparshTheme.warningOrange,
                    size: SparshSpacing.lg,
                  ),
                  const SizedBox(width: SparshSpacing.sm),
                  Expanded(
                    child: Text(
                      'Please visit within 100 meters radius of the shop to proceed with IN entry.',
                      style: SparshTypography.bodyLarge.copyWith(
                        color: SparshTheme.warningOrange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SparshSpacing.sm),
            Text(
              'Current distance: ${_calculatedDistance.toStringAsFixed(2)} meters',
              style: SparshTypography.bodyMedium.copyWith(
                color: SparshTheme.errorRed,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Required distance: ≤ 100 meters',
              style: SparshTypography.bodyMedium.copyWith(
                color: SparshTheme.successGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK, I Understand', style: SparshTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showExceptionEntryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SparshBorderRadius.xl),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: SparshTheme.primaryBlue,
              size: SparshSpacing.lg,
            ),
            const SizedBox(width: SparshSpacing.sm),
            Text(
              'Exception Entry',
              style: SparshTypography.heading5.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are currently ${_calculatedDistance.toStringAsFixed(2)} meters away from the customer location.',
              style: SparshTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: SparshSpacing.sm),
            Container(
              padding: const EdgeInsets.all(SparshSpacing.md),
              decoration: BoxDecoration(
                color: SparshTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(SparshBorderRadius.lg),
                border: Border.all(color: SparshTheme.primaryBlue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.navigation,
                    color: SparshTheme.primaryBlue,
                    size: SparshSpacing.lg,
                  ),
                  const SizedBox(width: SparshSpacing.sm),
                  Expanded(
                    child: Text(
                      'Since you are outside the 100-meter radius, you will be redirected to the DSR Visit Screen for exception entry.',
                      style: SparshTypography.bodyLarge.copyWith(
                        color: SparshTheme.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SparshSpacing.sm),
            Text(
              'Current distance: ${_calculatedDistance.toStringAsFixed(2)} meters',
              style: SparshTypography.bodyMedium.copyWith(
                color: SparshTheme.errorRed,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Required distance: ≤ 100 meters',
              style: SparshTypography.bodyMedium.copyWith(
                color: SparshTheme.successGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK, I Understand', style: SparshTypography.bodyLarge.copyWith(fontWeight: FontWeight.w500)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DsrVisitScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SparshTheme.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SparshBorderRadius.lg),
              ),
            ),
            child: Text('OK, I Understand', style: SparshTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _onSubmit(String entryType) {
    print('Submit pressed: $entryType, distance: $_calculatedDistance');
    if (!_formKey.currentState!.validate()) return;
    // Check distance before proceeding
    if (entryType == 'IN' && _calculatedDistance > 101) {
      print('Showing distance warning dialog');
      _showDistanceWarningDialog();
      return;
    }
    if (entryType == 'Exception' && _calculatedDistance > 101) {
      print('Showing exception entry dialog');
      _showExceptionEntryDialog();
      return;
    }
    // Normal submit logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Form validated. Entry type: $entryType'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      color: _cardColor,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SparshBorderRadius.xl)),
      child: Padding(
        padding: const EdgeInsets.all(SparshSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title,
                style: SparshTypography.heading5.copyWith(color: _textColor)),
            const SizedBox(height: SparshSpacing.md),
            child,
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText, String? labelText}) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      hintStyle: TextStyle(color: _hintColor),
      labelStyle: TextStyle(color: _textColor.withOpacity(0.7)),
      filled: true,
      fillColor: _cardColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(SparshBorderRadius.lg), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildElevatedButton(
      {required IconData icon, required String label, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: SparshSpacing.lg),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _secondaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SparshBorderRadius.lg)),
        padding: const EdgeInsets.symmetric(vertical: SparshSpacing.md),
      ),
    );
  }

  Widget _buildActionButton(
      {required String label, required Color color, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SparshBorderRadius.lg)),
        padding: const EdgeInsets.symmetric(vertical: SparshSpacing.lg),
      ),
      child: Text(label, style: SparshTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildImageRow(int idx) {
    final file = _selectedImages[idx];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Document ${idx + 1}',
            style: SparshTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: SparshSpacing.sm),
        Row(
          children: [
            ElevatedButton.icon(
              icon: Icon(file != null ? Icons.refresh : Icons.upload_file),
              label: Text(file != null ? 'Replace' : 'Upload'),
              onPressed: () async {
                final img = await _picker.pickImage(source: ImageSource.gallery);
                if (img != null) setState(() => _selectedImages[idx] = img);
              },
            ),
            const SizedBox(width: SparshSpacing.sm),
            if (file != null)
              ElevatedButton.icon(
                icon: const Icon(Icons.visibility),
                label: const Text('View'),
                onPressed: () => _showImage(file),
              ),
            const Spacer(),
            if (_selectedImages.length > 1 && idx == _selectedImages.length - 1)
              IconButton(
                icon: const Icon(Icons.remove_circle, color: SparshTheme.errorRed),
                onPressed: () => setState(() => _selectedImages.removeLast()),
              ),
          ],
        ),
        const SizedBox(height: SparshSpacing.sm),
      ],
    );
  }

  void _showImage(XFile file) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Image.file(
          File(file.path),
          fit: BoxFit.contain,
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
        ),
      ),
    );
  }

  Future<void> _fetchPurchaserRetailerTypes() async {
    setState(() => _isLoadingPurchaserRetailerTypes = true);
    try {
      final response = await http.get(Uri.parse('http://192.168.36.25/api/PersonalVisit/getPurchaserRetailerTypes'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _purchaserRetailerTypes = data.map((e) => PurchaserRetailerType.fromJson(e)).toList();
        });
      }
    } catch (e) {
      // Optionally show error
    } finally {
      setState(() => _isLoadingPurchaserRetailerTypes = false);
    }
  }

  Future<void> _fetchAreaCodes() async {
    setState(() => _isLoadingAreaCodes = true);
    try {
      final response = await http.get(Uri.parse('http://192.168.36.25/api/PersonalVisit/getAreaCodes'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _areaCodes = data.map((e) => AreaCodeModel.fromJson(e)).toList();
        });
      }
    } catch (e) {
      // Optionally show error
    } finally {
      setState(() => _isLoadingAreaCodes = false);
    }
  }

  void _onAreaOrPurchaserRetailerChanged() {
    if (_selectedAreaCode != null && _selectedPurchaserRetailerType != null) {
      _fetchCodeSearch();
    } else {
      setState(() {
        _codeSearchList = [];
        _selectedCodeSearch = null;
      });
    }
  }

  Future<void> _fetchCodeSearch() async {
    setState(() {
      _isLoadingCodeSearch = true;
      _codeSearchList = [];
      _selectedCodeSearch = null;
    });
    try {
      final areaCode = _selectedAreaCode?.code;
      final purchaserRetailerType = _selectedPurchaserRetailerType?.code;
      if (areaCode == null || purchaserRetailerType == null) return;
      final url = 'http://192.168.36.25/api/PersonalVisit/getCodeSearch?areaCode=$areaCode&purchaserRetailerType=$purchaserRetailerType';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _codeSearchList = data.map((e) => e.toString()).toList();
        });
      }
    } catch (e) {
      // Optionally show error
    } finally {
      setState(() => _isLoadingCodeSearch = false);
    }
  }

  Future<void> _fetchCustomerDetails(String code) async {
    try {
      final url = 'http://192.168.36.25/api/PersonalVisit/fetchRetailerDetails?cusRtlCd=$code';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final details = data[0];
          setState(() {
            _customerNameController.text = details['retlName']?.toString() ?? details['custName']?.toString() ?? '';
            _custLatitudeController.text = details['latitute']?.toString() ?? '';
            _custLongitudeController.text = details['lgtitute']?.toString() ?? '';
          });
        }
      }
    } catch (e) {
      // Optionally show error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DSR Retailer IN OUT',
                style: SparshTypography.heading5.copyWith(color: Colors.white)),
            Text('Daily Sales Report Entry',
                style: SparshTypography.body.copyWith(color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Help information for DSR Retailer IN OUT'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SparshBorderRadius.md)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SparshSpacing.lg),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildCard(
                  title: 'Purchaser / Retailer',
                  child: _isLoadingPurchaserRetailerTypes
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownSearch<PurchaserRetailerType>(
                          selectedItem: _selectedPurchaserRetailerType,
                          items: _purchaserRetailerTypes,
                          itemAsString: (type) => type == null ? '' : type.description,
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: _inputDecoration(),
                          ),
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              decoration: _inputDecoration(hintText: 'Search Purchaser/Retailer'),
                            ),
                          ),
                          onChanged: (v) {
                            setState(() => _selectedPurchaserRetailerType = v);
                            _onAreaOrPurchaserRetailerChanged();
                          },
                          validator: (v) => (v == null) ? 'Required' : null,
                        ),
                ),
                _buildCard(
                  title: 'Area Code',
                  child: _isLoadingAreaCodes
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownSearch<AreaCodeModel>(
                          selectedItem: _selectedAreaCode,
                          items: _areaCodes,
                          itemAsString: (area) => area == null ? '' : '${area.code}-${area.name}',
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: _inputDecoration(),
                          ),
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              decoration: _inputDecoration(hintText: 'Search Area Code'),
                            ),
                          ),
                          onChanged: (v) {
                            setState(() => _selectedAreaCode = v);
                            _onAreaOrPurchaserRetailerChanged();
                          },
                          validator: (v) => (v == null) ? 'Required' : null,
                        ),
                ),
                _buildCard(
                  title: 'Code Search',
                  child: _isLoadingCodeSearch
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownSearch<String>(
                          selectedItem: _selectedCodeSearch,
                          items: _codeSearchList,
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: _inputDecoration(hintText: 'Select Code'),
                          ),
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              decoration: _inputDecoration(hintText: 'Search Code'),
                            ),
                          ),
                          onChanged: (_codeSearchList.isEmpty)
                              ? null
                              : (v) {
                                  setState(() => _selectedCodeSearch = v);
                                  if (v != null && v.isNotEmpty) {
                                    _fetchCustomerDetails(v);
                                  }
                                },
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                ),
                _buildCard(
                  title: 'Customer Details',
                  child: TextFormField(
                    controller: _customerNameController,
                    decoration: _inputDecoration(hintText: 'Customer Name'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ),
                _buildCard(
                  title: 'Date',
                  child: TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: _inputDecoration(hintText: 'Select Date').copyWith(
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today, color: SparshTheme.primaryBlueAccent),
                        onPressed: _pickDate,
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ),
                _buildCard(
                  title: 'Your Location',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _yourLatitudeController,
                        readOnly: true,
                        decoration: _inputDecoration(labelText: 'Latitude'),
                      ),
                      const SizedBox(height: SparshSpacing.sm),
                      TextFormField(
                        controller: _yourLongitudeController,
                        readOnly: true,
                        decoration: _inputDecoration(labelText: 'Longitude'),
                      ),
                    ],
                  ),
                ),
                _buildCard(
                  title: 'Customer Location',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _custLatitudeController,
                        readOnly: true,
                        decoration: _inputDecoration(labelText: 'Latitude'),
                      ),
                      const SizedBox(height: SparshSpacing.sm),
                      TextFormField(
                        controller: _custLongitudeController,
                        readOnly: true,
                        decoration: _inputDecoration(labelText: 'Longitude'),
                      ),
                    ],
                  ),
                ),
                _buildCard(
                  title: 'Distance',
                  child: Container(
                    padding: const EdgeInsets.all(SparshSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _calculatedDistance > 0 
                          ? (_calculatedDistance > 101 
                            ? [SparshTheme.errorRed.withOpacity(0.08), SparshTheme.errorRed.withOpacity(0.03)]
                            : [SparshTheme.successGreen.withOpacity(0.08), SparshTheme.successGreen.withOpacity(0.03)])
                          : [SparshTheme.textTertiary.withOpacity(0.08), SparshTheme.textTertiary.withOpacity(0.03)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(SparshBorderRadius.xl),
                      border: Border.all(
                        color: _calculatedDistance > 0 
                          ? (_calculatedDistance > 101 ? SparshTheme.errorRed.withOpacity(0.2) : SparshTheme.successGreen.withOpacity(0.2))
                          : SparshTheme.textTertiary.withOpacity(0.2),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_calculatedDistance > 0 
                            ? (_calculatedDistance > 101 ? SparshTheme.errorRed : SparshTheme.successGreen)
                            : SparshTheme.textTertiary).withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: (_calculatedDistance > 0 
                            ? (_calculatedDistance > 101 ? SparshTheme.errorRed : SparshTheme.successGreen)
                            : SparshTheme.textTertiary).withOpacity(0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_calculatedDistance == 0)
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.calculate, color: SparshTheme.primaryBlueAccent, size: SparshSpacing.lg),
                              onPressed: _calculateDistance,
                              tooltip: 'Calculate distance manually',
                            ),
                          ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(SparshSpacing.md),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _calculatedDistance > 0 
                                    ? (_calculatedDistance > 101 
                                      ? [SparshTheme.errorRed.withOpacity(0.1), SparshTheme.errorRed.withOpacity(0.05)]
                                      : [SparshTheme.successGreen.withOpacity(0.1), SparshTheme.successGreen.withOpacity(0.05)])
                                    : [SparshTheme.textTertiary.withOpacity(0.1), SparshTheme.textTertiary.withOpacity(0.05)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(SparshBorderRadius.lg),
                                boxShadow: [
                                  BoxShadow(
                                    color: (_calculatedDistance > 0 
                                      ? (_calculatedDistance > 101 ? SparshTheme.errorRed : SparshTheme.successGreen)
                                      : SparshTheme.textTertiary).withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.straighten,
                                color: _calculatedDistance > 0 
                                  ? (_calculatedDistance > 101 ? SparshTheme.errorRed : SparshTheme.successGreen)
                                  : SparshTheme.textTertiary,
                                size: SparshSpacing.xl,
                              ),
                            ),
                            const SizedBox(width: SparshSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _calculatedDistance > 0 
                                      ? '${_calculatedDistance.toStringAsFixed(2)} meters'
                                      : 'Not calculated',
                                    style: SparshTypography.heading3.copyWith(
                                      color: _calculatedDistance > 0 
                                        ? (_calculatedDistance > 101 ? SparshTheme.errorRed : SparshTheme.successGreen)
                                        : SparshTheme.textTertiary,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                      height: 1.2,
                                    ),
                                  ),
                                  if (_calculatedDistance > 0)
                                    Container(
                                      margin: const EdgeInsets.only(top: SparshSpacing.sm),
                                      padding: const EdgeInsets.symmetric(horizontal: SparshSpacing.md, vertical: SparshSpacing.sm),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: (_calculatedDistance > 101 
                                            ? [SparshTheme.errorRed.withOpacity(0.1), SparshTheme.errorRed.withOpacity(0.05)]
                                            : [SparshTheme.successGreen.withOpacity(0.1), SparshTheme.successGreen.withOpacity(0.05)]),
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius: BorderRadius.circular(SparshBorderRadius.lg),
                                        border: Border.all(
                                          color: (_calculatedDistance > 101 ? SparshTheme.errorRed : SparshTheme.successGreen).withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        _calculatedDistance > 101 
                                          ? 'Distance exceeds 101m limit'
                                          : 'Within acceptable range',
                                        style: SparshTypography.bodySmall.copyWith(
                                          color: _calculatedDistance > 101 ? SparshTheme.errorRed : SparshTheme.successGreen,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  if (_calculatedDistance == 0)
                                    Container(
                                      margin: const EdgeInsets.only(top: SparshSpacing.sm),
                                      padding: const EdgeInsets.symmetric(horizontal: SparshSpacing.md, vertical: SparshSpacing.sm),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [SparshTheme.textTertiary.withOpacity(0.1), SparshTheme.textTertiary.withOpacity(0.05)],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius: BorderRadius.circular(SparshBorderRadius.lg),
                                        border: Border.all(
                                          color: SparshTheme.textTertiary.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        'Required distance: ≤ 100 meters',
                                        style: SparshTypography.bodyMedium.copyWith(
                                          color: SparshTheme.textTertiary,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: SparshSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.login, size: SparshSpacing.lg),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: SparshSpacing.md),
                      child: Text(
                        'IN',
                        style: SparshTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    onPressed: () => _onSubmit('IN'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SparshTheme.primaryBlueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SparshBorderRadius.lg),
                      ),
                      elevation: 6,
                      padding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(height: SparshSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.error_outline, size: SparshSpacing.lg),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: SparshSpacing.md),
                      child: Text(
                        'Exception Entry',
                        style: SparshTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    onPressed: () => _onSubmit('Exception'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SparshTheme.warningOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SparshBorderRadius.lg),
                      ),
                      elevation: 6,
                      padding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
