import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/document_number_storage.dart';
import 'dsr_entry.dart';
import 'dsr_exception_entry.dart';

class PhoneCallWithBuilder extends StatefulWidget {
  const PhoneCallWithBuilder({super.key});

  @override
  State<PhoneCallWithBuilder> createState() => _PhoneCallWithBuilderState();
}

class _PhoneCallWithBuilderState extends State<PhoneCallWithBuilder> {
  final _formKey = GlobalKey<FormState>();

  // Geolocation
  Position? _currentPosition;
  // Dynamic data
  List<String> _processTypes = ['Select'];
  List<Map<String, String>> _areaCodes = [];
  List<Map<String, String>> _purchasers = [];
  List<Map<String, String>> _purchaserCodes = [];
  
  // Selected values
  String? _selectedProcessType = 'Select';
  String? _selectedAreaCode = 'Select';
  String? _selectedPurchaser = 'Select';
  String? _selectedPurchaserCode = 'Select';
  
  // Loading states
  bool _isLoadingAreaCodes = true;
  bool _isLoadingPurchasers = false;
  bool _isLoadingPurchaserCodes = false;

  final TextEditingController _submissionDateController = TextEditingController();
  final TextEditingController _reportDateController     = TextEditingController();

  final TextEditingController _codeController         = TextEditingController();
  // final TextEditingController _siteController         = TextEditingController();
  // final TextEditingController _contractorController   = TextEditingController();
  // String? _metWithItem = 'Select';
  // final List<String> _metWithItems = ['Select', 'Builder', 'Contractor'];
  // final TextEditingController _namedesgController     = TextEditingController();
  // final TextEditingController _topicController        = TextEditingController();
  // final TextEditingController _ugaiRecoveryController = TextEditingController();
  // final TextEditingController _grievanceController    = TextEditingController();
  // final TextEditingController _otherPointController   = TextEditingController();

  // Dynamic field config for activity type
  final Map<String, List<Map<String, String>>> activityFieldConfig = {
    "Phone Call with Builder /Stockist": [
      {"label": "Site Name", "key": "siteName", "rem": "dsrRem01"},
      {"label": "Contractor Working at Site", "key": "contractorName", "rem": "dsrRem02"},
      {"label": "Met With", "key": "metWith", "rem": "dsrRem03"},
      {"label": "Name and Designation of Person", "key": "nameDesg", "rem": "dsrRem04"},
      {"label": "Topic Discussed", "key": "topic", "rem": "dsrRem05"},
      {"label": "Ugai Recovery Plans", "key": "ugaiRecovery", "rem": "dsrRem06"},
      {"label": "Any Purchaser Grievances", "key": "grievance", "rem": "dsrRem07"},
      {"label": "Any Other Point", "key": "otherPoint", "rem": "dsrRem08"},
    ],
  };

  // Dynamic controllers for text fields
  final Map<String, TextEditingController> _controllers = {};
  String? _metWithItem = 'Select';
  final List<String> _metWithItems = ['Select', 'Builder', 'Contractor'];

  List<File?> _selectedImages = [null];

  final _documentNumberController = TextEditingController();
  String? _documentNumber;

  String get _selectedActivityType => "Phone Call with Builder /Stockist";

  // Add/Update process type state
  String? _processItem = 'Select';
  List<String> _processdropdownItems = ['Select', 'Add', 'Update'];
  String? _processTypeError;

  // Document-number dropdown state
  bool _loadingDocs = false;
  List<String> _documentNumbers = [];
  String? _selectedDocuNumb;

  @override
  void initState() {
    super.initState();
    _initGeolocation();
    _loadInitialDocumentNumber();
    _fetchProcessTypes();
    _fetchAreaCodes(); // <-- Added to load area codes
    _setSubmissionDateToToday();
    _initControllersForActivity(_selectedActivityType);
  }
  Future<void> _initGeolocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services disabled.');
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions denied.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions permanently denied.');
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = pos;
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }
  
  void _initControllersForActivity(String activityType) {
    final config = activityFieldConfig[activityType] ?? [];
    for (final field in config) {
      if (field['key'] != 'metWith') {
        _controllers[field['key']!] = TextEditingController();
      }
    }
  }

  // Load document number when screen initializes
  Future<void> _loadInitialDocumentNumber() async {
    final savedDocNumber = await DocumentNumberStorage.loadDocumentNumber(DocumentNumberKeys.phoneCallBuilder);
    if (savedDocNumber != null) {
      setState(() {
        _documentNumber = savedDocNumber;
      });
    }
  }

  Future<void> _initializeData() async {
    // Test API connectivity first
    await _testApiConnectivity();
    
    await Future.wait([
      _fetchProcessTypes(),
      _fetchAreaCodes(),
    ]);
  }

  Future<void> _testApiConnectivity() async {
    try {
      final url = Uri.parse('http://192.168.36.25/api/DsrTry/getProcessTypes');
      print('🔍 Testing API connectivity to: $url');
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('API connectivity test timeout');
        },
      );
      
      print('✅ API connectivity test successful: ${response.statusCode}');
      print('📄 Test response body: ${response.body}');
      
      // Try to parse the response to see the structure
      try {
        final data = jsonDecode(response.body);
        print('📊 Test parsed data: $data');
        print('📊 Data type: ${data.runtimeType}');
                  if (data is Map) {
            print('📊 Available keys: ${data.keys.toList()}');
            if (data.containsKey('processTypes')) {
              final processTypes = data['processTypes'] as List;
            print('📊 ProcessTypes list length: ${processTypes.length}');
            if (processTypes.isNotEmpty) {
              print('📊 First ProcessType item: ${processTypes.first}');
              print('📊 First ProcessType item type: ${processTypes.first.runtimeType}');
              if (processTypes.first is Map) {
                final firstItem = processTypes.first as Map;
                print('📊 First ProcessType item keys: ${firstItem.keys.toList()}');
                print('📊 First ProcessType item values: ${firstItem.values.toList()}');
              }
            }
          }
        }
      } catch (parseError) {
        print('❌ Failed to parse test response: $parseError');
      }
    } catch (e) {
      print('❌ API connectivity test failed: $e');
      // Don't show error to user yet, let the main fetch handle it
    }
  }

  Future<void> _fetchProcessTypes() async {
    setState(() {
      _processTypeError = null;
    });
    // Hardcoded for now, can be fetched from backend if needed
    setState(() {
      _processdropdownItems = ['Select', 'Add', 'Update'];
      _processItem = 'Select';
    });
  }

  // Fetch document numbers for Update
  Future<void> _fetchDocumentNumbers() async {
    setState(() {
      _loadingDocs = true;
      _documentNumbers = [];
      _selectedDocuNumb = null;
    });
    final uri = Uri.parse(
      'http://192.168.36.25/api/DsrTry/getDocumentNumbers?dsrParam=12' // Use correct param for this activity
    );
    try {
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as List;
        setState(() {
          _documentNumbers = data
            .map((e) {
              return (e['DocuNumb']
                   ?? e['docuNumb']
                   ?? e['DocumentNumber']
                   ?? e['documentNumber']
                   ?? '').toString();
            })
            .where((s) => s.isNotEmpty)
            .toList();
        });
      }
    } catch (_) {
      // ignore errors
    } finally {
      setState(() { _loadingDocs = false; });
    }
  }

  // Fetch details for a document number and populate fields
  Future<void> _fetchAndPopulateDetails(String docuNumb) async {
    final uri = Uri.parse('http://192.168.36.25/api/DsrTry/getDsrEntry?docuNumb=$docuNumb');
    try {
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        // Populate all dynamic fields
        final config = activityFieldConfig[_selectedActivityType] ?? [];
        for (final field in config) {
          if (field['key'] == 'metWith') {
            setState(() {
              _metWithItem = data[field['rem']] ?? 'Select';
            });
          } else {
            _controllers[field['key']!]?.text = data[field['rem']] ?? '';
          }
        }
        setState(() {
          _submissionDateController.text = data['SubmissionDate']?.toString()?.substring(0, 10) ?? '';
          _reportDateController.text = data['ReportDate']?.toString()?.substring(0, 10) ?? '';
          _selectedAreaCode = data['AreaCode'] ?? 'Select';
          _selectedPurchaser = data['Purchaser'] ?? 'Select';
          _selectedPurchaserCode = data['PurchaserCode'] ?? 'Select';
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchAreaCodes() async {
    try {
      final url = Uri.parse('http://192.168.36.25/api/DsrTry/getAreaCodes');
      print('🔍 Fetching area codes from: $url');
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout: Area codes API took too long to respond');
        },
      );
      print('📡 Area codes response status: ${response.statusCode}');
      print('📄 Area codes response body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('📊 Parsed area codes data: $data');
        if (data is List) {
          if (data.isEmpty) {
            setState(() {
              _areaCodes = [{'code': 'Select', 'name': 'Select'}];
              _isLoadingAreaCodes = false;
            });
            print('❌ Area codes list is empty');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No area codes available.'),
                backgroundColor: SparshTheme.errorRed,
              ),
            );
            return;
          }
          // Based on the C# controller, the response format is:
          // [{"Code": "...", "Name": "..."}, ...]
          final processedAreaCodes = data.map((item) {
            print('🏷️ Processing area code item: $item');
            print('🏷️ Item type: ${item.runtimeType}');
            if (item is Map) {
              print('🏷️ Item keys: ${item.keys.toList()}');
              print('🏷️ Item values: ${item.values.toList()}');
            }
            // Try different property name cases
            final code = item['Code']?.toString().trim() ?? 
                        item['code']?.toString().trim() ?? 
                        item['AreaCode']?.toString().trim() ?? '';
            final name = item['Name']?.toString().trim() ?? 
                        item['name']?.toString().trim() ?? 
                        code;
            print('📝 Extracted - code: "$code", name: "$name"');
            return {
              'code': code,
              'name': name,
            };
          }).where((item) {
            final isValid = item['code']!.isNotEmpty && item['code'] != '   ';
            if (!isValid) {
              print('❌ Filtered out invalid item: ${item['code']}');
            }
            return isValid;
          }).toList();
          print('✅ Processed ${processedAreaCodes.length} valid area codes');
          // Remove duplicates by code
          final seenCodes = <String>{};
          final uniqueAreaCodes = [
            {'code': 'Select', 'name': 'Select'},
            ...processedAreaCodes.where((item) {
              if (seenCodes.contains(item['code'])) return false;
              seenCodes.add(item['code']!);
              return true;
            })
          ];
          setState(() {
            _areaCodes = uniqueAreaCodes;
            _isLoadingAreaCodes = false;
            // Reset selected value if not present
            final validCodes = _areaCodes.map((a) => a['code']).toSet();
            if (_selectedAreaCode == null || !validCodes.contains(_selectedAreaCode)) {
              _selectedAreaCode = 'Select';
            }
          });
          print('📋 Final area codes list length: ${_areaCodes.length}');
          print('📋 First 5 area codes: ${_areaCodes.take(5).toList()}');
        } else {
          print('❌ Area codes data is not a List, it is: ${data.runtimeType}');
          throw Exception('Invalid response format: expected List but got ${data.runtimeType}');
        }
      } else if (response.statusCode == 404) {
        setState(() {
          _areaCodes = [{'code': 'Select', 'name': 'Select'}];
          _isLoadingAreaCodes = false;
        });
        print('❌ No area codes found (404)');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No area codes found.'),
            backgroundColor: SparshTheme.errorRed,
          ),
        );
      } else {
        print('❌ Failed to fetch area codes: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to fetch area codes: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error fetching area codes: $e');
      setState(() {
        _areaCodes = [{'code': 'Select', 'name': 'Select'}];
        _isLoadingAreaCodes = false;
      });
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load area codes: ${e.toString()}'),
          backgroundColor: SparshTheme.errorRed,
        ),
      );
    }
  }

  Future<void> _fetchPurchasers(String areaCode) async {
    if (areaCode == 'Select') {
      setState(() {
        _purchasers = [{'code': 'Select', 'name': 'Select'}];
        _selectedPurchaser = 'Select';
        _selectedPurchaserCode = 'Select';
        _purchaserCodes = [{'code': 'Select', 'name': 'Select'}];
      });
      return;
    }

    setState(() {
      _isLoadingPurchasers = true;
      _selectedPurchaser = 'Select';
      _selectedPurchaserCode = 'Select';
      _purchaserCodes = [{'code': 'Select', 'name': 'Select'}];
    });

    try {
      print('🔍 Fetching purchaser options');
      
      // Based on the C# controller, use getPurchaserOptions endpoint
      final url = Uri.parse('http://192.168.36.25/api/DsrTry/getPurchaserOptions');
      
      print('🌐 Calling purchaser options API: $url');
      
      final response = await http.get(url);
      print('📡 Purchaser options response status: ${response.statusCode}');
      print('📄 Purchaser options response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('📊 Parsed purchaser options data: $data');
        print('Purchaser options API data: $data'); // Debug print
        
        if (data is List) {
          // Remove duplicates by code
          final seenCodes = <String>{};
          final uniquePurchasers = [
            {'code': 'Select', 'name': 'Select'},
            ...data.map((item) => {
              'code': item['Code']?.toString() ?? item['code']?.toString() ?? '',
              'name': item['Description']?.toString() ?? item['description']?.toString() ?? '',
            }).where((item) {
              if (item['code']!.isEmpty || seenCodes.contains(item['code'])) return false;
              seenCodes.add(item['code']!);
              return true;
            })
          ];
          setState(() {
            _purchasers = uniquePurchasers;
            _isLoadingPurchasers = false;
            // Reset selected value if not present
            final validCodes = _purchasers.map((p) => p['code']).toSet();
            if (_selectedPurchaser == null || !validCodes.contains(_selectedPurchaser)) {
              _selectedPurchaser = 'Select';
            }
          });
          
          print('📋 Purchaser options loaded: $_purchasers');
        } else {
          throw Exception('Invalid response format: expected List but got ${data.runtimeType}');
        }
      } else {
        throw Exception('Failed to fetch purchaser options: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error fetching purchaser options: $e');
      setState(() {
        _purchasers = [{'code': 'Select', 'name': 'Select'}];
        _isLoadingPurchasers = false;
      });
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load purchaser options: ${e.toString()}'),
          backgroundColor: SparshTheme.errorRed,
        ),
      );
    }
  }

  Future<void> _fetchPurchaserCodes(String purchaserCode) async {
    if (purchaserCode == 'Select' || _selectedAreaCode == 'Select') {
      setState(() {
        _purchaserCodes = [{'code': 'Select', 'name': 'Select'}];
        _selectedPurchaserCode = 'Select';
      });
      return;
    }

    setState(() {
      _isLoadingPurchaserCodes = true;
      _selectedPurchaserCode = 'Select';
    });

    try {
      print('🔍 Fetching purchaser codes for area: $_selectedAreaCode, purchaser type: $purchaserCode');
      // Use correct query parameter name: purchaserFlag
      final url = Uri.parse('http://192.168.36.25/api/DsrTry/getPurchaserCode')
          .replace(queryParameters: {
        'areaCode': _selectedAreaCode,
        'purchaserFlag': purchaserCode,
      });
      print('🌐 Calling purchaser code API: $url');
      final response = await http.get(url);
      print('📡 Purchaser code response status: ${response.statusCode}');
      print('📄 Purchaser code response body: ${response.body}');

      // Handle empty or invalid response
      if (response.body == null || response.body.trim().isEmpty) {
        setState(() {
          _purchaserCodes = [{'code': 'Select', 'name': 'Select'}];
          _isLoadingPurchaserCodes = false;
        });
        print('❌ Purchaser code API returned empty response');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No purchaser codes found (empty response).'),
            backgroundColor: SparshTheme.errorRed,
          ),
        );
        return;
      }

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        setState(() {
          _purchaserCodes = [{'code': 'Select', 'name': 'Select'}];
          _isLoadingPurchaserCodes = false;
        });
        print('❌ Purchaser code API returned invalid JSON');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid response from server for purchaser codes.'),
            backgroundColor: SparshTheme.errorRed,
          ),
        );
        return;
      }
      print('Purchaser code API data: $data'); // Debug print

      // Accept both PurchaserCodes and purchaserCodes
      if (data is Map && (data.containsKey('purchaserCodes') || data.containsKey('PurchaserCodes'))) {
        final purchaserCodesList = (data['purchaserCodes'] ?? data['PurchaserCodes']) as List;
        // Parse objects to extract code and name
        final purchaserCodes = purchaserCodesList.map((item) => {
          'code': (item['code'] ?? item['Code'] ?? '').toString().trim(),
          'name': (item['name'] ?? item['Name'] ?? item['code'] ?? item['Code'] ?? '').toString().trim(),
        }).where((item) => item['code']!.isNotEmpty).toList();
        print('Parsed purchaserCodes: $purchaserCodes');
        if (purchaserCodes.isNotEmpty) {
          setState(() {
            _purchaserCodes = [
              {'code': 'Select', 'name': 'Select'},
              ...purchaserCodes
            ];
            _isLoadingPurchaserCodes = false;
          });
          print('📋 Purchaser codes loaded: $purchaserCodes');
        } else {
          setState(() {
            _purchaserCodes = [{'code': 'Select', 'name': 'Select'}];
            _isLoadingPurchaserCodes = false;
          });
          print('⚠️ No purchaser codes found for the given parameters');
        }
      } else {
        throw Exception('Invalid response format: expected Map with PurchaserCodes but got  [1m${data.runtimeType} [0m. Data: $data');
      }
    } catch (e) {
      print('💥 Error fetching purchaser codes: $e');
      setState(() {
        _purchaserCodes = [{'code': 'Select', 'name': 'Select'}];
        _isLoadingPurchaserCodes = false;
      });
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load purchaser codes: ${e.toString()}'),
          backgroundColor: SparshTheme.errorRed,
        ),
      );
    }
  }

  void _onProcessTypeChanged(String? value) {
    setState(() {
      _selectedProcessType = value;
    });
  }

  void _onAreaCodeChanged(String? value) {
    setState(() {
      _selectedAreaCode = value;
      _selectedPurchaser = 'Select';
      _selectedPurchaserCode = 'Select';
    });
    if (value != null && value != 'Select') {
      _fetchPurchasers(value);
    }
  }

  void _onPurchaserChanged(String? value) {
    setState(() {
      _selectedPurchaser = value;
      _selectedPurchaserCode = 'Select';
    });
    if (value != null && value != 'Select') {
      _fetchPurchaserCodes(value);
    }
  }

  void _onPurchaserCodeChanged(String? value) {
    setState(() {
      _selectedPurchaserCode = value;
    });
  }

  @override
  void dispose() {
    _submissionDateController.dispose();
    _reportDateController.dispose();
    _codeController.dispose();
    _documentNumberController.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _setSubmissionDateToToday() {
    final today = DateTime.now();
    _submissionDateController.text = DateFormat('yyyy-MM-dd').format(today);
  }

  Future<void> _pickReportDate() async {
    final now = DateTime.now();
    final threeDaysAgo = now.subtract(const Duration(days: 3));
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
    );
    if (picked != null) {
      if (picked.isBefore(threeDaysAgo)) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Please Put Valid DSR Date.'),
            content: const Text(
              'You Can submit DSR only Last Three Days. If You want to submit back date entry Please enter Exception entry (Path : Transcation --> DSR Exception Entry). Take Approval from concerned and Fill DSR Within 3 days after approval.'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DsrExceptionEntryPage()),
                  );
                },
                child: const Text('Go to Exception Entry'),
              ),
            ],
          ),
        );
        return;
      }
      setState(() {
        _reportDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickImage(int index) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImages[index] = File(pickedFile.path);
      });
    }
  }

  void _showImageDialog(File imageFile) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.contain,
              image: FileImage(imageFile),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> submitDsrEntry(Map<String, dynamic> dsrData) async {
    final url = Uri.parse('http://192.168.36.25/api/DsrTry');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dsrData),
    );
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
    if (response.statusCode == 201) {
      print('✅ Data inserted successfully!');
    } else {
      print('❌ Data NOT inserted! Error: ${response.body}');
    }
  }

  // Update _onSubmit to handle Add/Update
  Future<void> _onSubmit({required bool exitAfter}) async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentPosition == null) await _initGeolocation();

    final dsrData = <String, dynamic>{
      'ActivityType': _selectedActivityType,
      'SubmissionDate': _submissionDateController.text,
      'ReportDate': _reportDateController.text,
      'CreateId': '2948',
      'AreaCode': _selectedAreaCode ?? '',
      'Purchaser': _selectedPurchaser ?? '',
      'PurchaserCode': _selectedPurchaserCode ?? '',
      'DsrParam': '12',
      'DocuNumb': _processItem == 'Update' ? _selectedDocuNumb : null,
      'ProcessType': _processItem == 'Update' ? 'U' : 'A',
      'latitude': _currentPosition?.latitude.toString() ?? '',
      'longitude': _currentPosition?.longitude.toString() ?? '',
    };
    final config = activityFieldConfig[_selectedActivityType] ?? [];
    for (final field in config) {
      if (field['key'] == 'metWith') {
        dsrData[field['rem']!] = _metWithItem ?? '';
      } else {
        dsrData[field['rem']!] = _controllers[field['key']!]?.text ?? '';
      }
    }
    // Add images if needed (existing logic)
    final imageData = <String, dynamic>{};
    for (int i = 0; i < _selectedImages.length; i++) {
      final file = _selectedImages[i];
      if (file != null) {
        final imageBytes = await file.readAsBytes();
        final base64Image = 'data:image/jpeg;base64,${base64Encode(imageBytes)}';
        imageData['image${i + 1}'] = base64Image;
      }
    }
    dsrData['Images'] = imageData;

    try {
      final url = Uri.parse(
        'http://192.168.36.25/api/DsrTry/' + (_processItem == 'Update' ? 'update' : '')
      );
      final resp = _processItem == 'Update'
          ? await http.put(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(dsrData),
            )
          : await http.post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(dsrData),
            );

      final success = (_processItem == 'Update' && resp.statusCode == 204) ||
                      (_processItem != 'Update' && resp.statusCode == 201);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? exitAfter
                  ? '${_processItem == 'Update' ? 'Updated' : 'Submitted'} successfully. Exiting...'
                  : '${_processItem == 'Update' ? 'Updated' : 'Submitted'} successfully. Ready for new entry.'
              : 'Error: ${resp.body}'),
          backgroundColor: success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (success) {
        if (exitAfter) {
          Navigator.of(context).pop();
        } else {
          _clearForm();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exception: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _clearForm() {
    setState(() {
      _processItem = 'Select';
      _selectedDocuNumb = null;
      _submissionDateController.clear();
      _reportDateController.clear();
      _selectedAreaCode = 'Select';
      _selectedPurchaser = 'Select';
      _selectedPurchaserCode = 'Select';
      _codeController.clear();
      _metWithItem = 'Select';
      _selectedImages = [null];
      for (final c in _controllers.values) {
        c.clear();
      }
    });
    _formKey.currentState!.reset();
  }

  Future<String?> _fetchDocumentNumberFromServer() async {
    try {
      final url = Uri.parse('http://192.168.36.25/api/DsrTry/generateDocumentNumber');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(_selectedAreaCode ?? 'KKR'), // Use selected area code or fallback to KKR
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String? documentNumber;
        if (data is Map<String, dynamic>) {
          documentNumber = data['documentNumber'] ?? data['DocumentNumber'] ?? data['docNumber'] ?? data['DocNumber'];
        } else if (data is String) {
          documentNumber = data;
        }
        
        // Save to persistent storage
        if (documentNumber != null) {
          await DocumentNumberStorage.saveDocumentNumber(DocumentNumberKeys.phoneCallBuilder, documentNumber);
        }
        
        return documentNumber;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Widget dropdownButtonProcessType({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
    bool enabled = true,
  }) => DropdownButtonFormField<String>(
    value: value,
    isExpanded: true,
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    items: items.map((it) => DropdownMenuItem(value: it, child: Text(it))).toList(),
    onChanged: enabled
        ? (v) async {
            setState(() {
              _selectedProcessType = v;
            });
            if (v == "Update") {
              // Only generate document number if we don't already have one
              if (_documentNumber == null) {
                setState(() {
                  _documentNumberController.text = "Generating...";
                });
                
                try {
                  final docNumber = await _fetchDocumentNumberFromServer();
                  setState(() {
                    _documentNumber = docNumber;
                    _documentNumberController.text = docNumber ?? "";
                  });
                } catch (e) {
                  setState(() {
                    _documentNumberController.text = "Error generating document number";
                  });
                }
              } else {
                // If we already have a document number, just display it
                setState(() {
                  _documentNumberController.text = _documentNumber!;
                });
              }
            } else {
              // For "Add" or any other process type, just clear the display but keep the document number in memory
              setState(() {
                _documentNumberController.text = "";
              });
            }
          }
        : null,
    validator: validator,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SparshTheme.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () =>
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DsrEntry())),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
        ),
        title: Text(
          'Phone Call With Builder',
          style: SparshTypography.heading5.copyWith(color: Colors.white),
        ),
        backgroundColor: SparshTheme.primaryBlueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildLabel('Process type'),
              _processTypeError != null
                ? Text(
                    _processTypeError!,
                    style: SparshTypography.labelLarge.copyWith(color: SparshTheme.errorRed),
                  )
                : _processdropdownItems.length == 1
                    ? const Center(child: Text('No process types available.'))
                    : DropdownButtonFormField<String>(
                        value: _processItem,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: _processdropdownItems.map((it) => DropdownMenuItem(value: it, child: Text(it))).toList(),
                        onChanged: (val) async {
                          setState(() {
                            _processItem = val;
                          });
                          if (val == 'Update') await _fetchDocumentNumbers();
                        },
                        validator: (v) => v == null || v == 'Select' ? 'Please select a Process Type' : null,
                      ),
              if (_processItem == 'Update') ...[
                const SizedBox(height: 8.0),
                _loadingDocs
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      value: _selectedDocuNumb,
                      decoration: const InputDecoration(labelText: 'Document Number'),
                      items: _documentNumbers
                          .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                          .toList(),
                      onChanged: (v) async {
                        setState(() => _selectedDocuNumb = v);
                        if (v != null) await _fetchAndPopulateDetails(v);
                      },
                      validator: (v) => v == null ? 'Required' : null,
                    ),
              ],
              const SizedBox(height: 10),
              _buildLabel('Submission Date'),
              TextFormField(
                controller: _submissionDateController,
                readOnly: true,
                enabled: false,
                decoration: InputDecoration(
                  hintText: 'Submission Date',
                  filled: true,
                  fillColor: SparshTheme.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SparshBorderRadius.md),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: const Icon(Icons.lock, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(horizontal: SparshSpacing.md, vertical: SparshSpacing.sm),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Submission date required' : null,
              ),
              const SizedBox(height: 10),
              _buildLabel('Report Date'),
              TextFormField(
                controller: _reportDateController,
                readOnly: true,
                onTap: _pickReportDate,
                decoration: InputDecoration(
                  hintText: 'Select Report Date',
                  filled: true,
                  fillColor: SparshTheme.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SparshBorderRadius.md),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: const Icon(Icons.calendar_today),
                  contentPadding: const EdgeInsets.symmetric(horizontal: SparshSpacing.md, vertical: SparshSpacing.sm),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Select date' : null,
              ),
              const SizedBox(height: 10),
              _buildLabel('Area Code'),
              // Area code dropdown
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(SparshBorderRadius.md),
                  border: Border.all(color: SparshTheme.borderGrey, width: 1),
                  color: SparshTheme.cardBackground,
                ),
                child: _isLoadingAreaCodes
                    ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                    : DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedAreaCode,
                        underline: Container(),
                        items: _areaCodes.map((areaCode) {
                          final code = areaCode['code']!;
                          final name = areaCode['name']!;
                          return DropdownMenuItem(
                            value: code,
                            child: Text(code == 'Select' ? 'Select' : name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAreaCode = value;
                          });
                          // Fetch purchasers when area code changes
                          if (value != null && value != 'Select') {
                            _fetchPurchasers(value);
                          } else {
                            // Reset purchaser and purchaser code when area code is deselected
                            setState(() {
                              _purchasers = [{'code': 'Select', 'name': 'Select'}];
                              _selectedPurchaser = 'Select';
                              _selectedPurchaserCode = 'Select';
                              _purchaserCodes = [{'code': 'Select', 'name': 'Select'}];
                            });
                          }
                        },
                      ),
              ),
              const SizedBox(height: 10),
              _buildLabel('Purchaser Type'),
              // Custom dropdown for Purchaser Type: display full name, value is code
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(SparshBorderRadius.md),
                  border: Border.all(color: SparshTheme.borderGrey, width: 1),
                  color: SparshTheme.cardBackground,
                ),
                child: _isLoadingPurchasers
                    ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                    : DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedPurchaser,
                        underline: Container(),
                        items: _purchasers.map((purchaser) {
                          final code = purchaser['code']!;
                          final name = purchaser['name']!;
                          return DropdownMenuItem(
                            value: code,
                            child: Text(code == 'Select' ? 'Select' : name),
                          );
                        }).toList(),
                        onChanged: _onPurchaserChanged,
                      ),
              ),
              const SizedBox(height: 10),
              _buildLabel('Purchaser Code'),
              Builder(
                builder: (context) {
                  final itemsList = _purchaserCodes
                      .map((code) => code['code'] == 'Select'
                          ? 'Select'
                          : '${code['code']} - ${code['name']}')
                      .toList();
                  print('Dropdown itemsList: $itemsList');
                  String? dropdownValue = _selectedPurchaserCode == 'Select'
                      ? 'Select'
                      : (_purchaserCodes.firstWhere(
                              (c) => c['code'] == _selectedPurchaserCode,
                              orElse: () => {'code': 'Select', 'name': 'Select'})['code'] == 'Select'
                          ? 'Select'
                          : '${_selectedPurchaserCode} - ${_purchaserCodes.firstWhere((c) => c['code'] == _selectedPurchaserCode, orElse: () => {'name': ''})['name']}');
                  return _buildDropdownField(
                    value: dropdownValue,
                    items: itemsList,
                    onChanged: (value) {
                      setState(() {
                        if (value == 'Select') {
                          _selectedPurchaserCode = 'Select';
                        } else {
                          _selectedPurchaserCode = value?.split(' - ')?.first ?? 'Select';
                        }
                      });
                    },
                    isLoading: _isLoadingPurchaserCodes,
                  );
                },
              ),
              const SizedBox(height: 10),
              ..._buildDynamicFields(),
              const SizedBox(height: 10),
              _buildLabel('Upload Images'),
              ...List.generate(_selectedImages.length, (i) {
                final file = _selectedImages[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SparshTheme.lightGreyBackground,
                    borderRadius: BorderRadius.circular(SparshBorderRadius.md),
                    border: Border.all(
                      color:
                      file != null ? SparshTheme.successGreen : SparshTheme.borderGrey,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Document ${i + 1}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          const Spacer(),
                          if (file != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: SparshTheme.successLight,
                                borderRadius: BorderRadius.circular(SparshBorderRadius.lg),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle,
                                      color: SparshTheme.successGreen, size: 16),
                                  SizedBox(width: 4),
                                  Text('Uploaded',
                                      style: TextStyle(
                                          color: SparshTheme.successGreen,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _pickImage(i),
                              icon: Icon(
                                  file != null ? Icons.refresh : Icons.upload_file,
                                  size: 18),
                              label: Text(file != null ? 'Replace' : 'Upload'),
                            ),
                          ),
                          if (file != null) ...[
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showImageDialog(file),
                                icon: const Icon(Icons.visibility, size: 18),
                                label: const Text('View'),
                                style:
                                ElevatedButton.styleFrom(backgroundColor: SparshTheme.successGreen),
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectedImages.removeAt(i);
                                });
                              },
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: SparshTheme.errorRed),
                            ),
                          ]
                        ],
                      ),
                    ],
                  ),
                );
              }),
              if (_selectedImages.length < 3)
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedImages.add(null);
                      });
                    },
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Add More Image'),
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _onSubmit(exitAfter: false),
                      child: const Text('Submit & New'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _onSubmit(exitAfter: true),
                      child: const Text('Submit & Exit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDynamicFields() {
    final config = activityFieldConfig[_selectedActivityType] ?? [];
    return config.map((field) {
      if (field['key'] == 'metWith') {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel(field['label']!),
            _buildDropdownField(
              value: _metWithItem,
              items: _metWithItems,
              onChanged: (val) => setState(() => _metWithItem = val),
            ),
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel(field['label']!),
            _buildTextField(
              'Enter ${field['label']}',
              controller: _controllers[field['key']!],
              maxLines: field['key'] == 'topic' || field['key'] == 'ugaiRecovery' || field['key'] == 'grievance' || field['key'] == 'otherPoint' ? 3 : 1,
            ),
          ],
        );
      }
    }).toList();
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Text(
      text,
      style: SparshTypography.labelLarge.copyWith(color: SparshTheme.textPrimary),
    ),
  );

  Widget _buildTextField(
      String hint, {
        TextEditingController? controller,
        TextInputType? keyboardType,
        int maxLines = 1,
      }) =>
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: SparshTheme.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SparshBorderRadius.md),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: SparshSpacing.md, vertical: SparshSpacing.sm),
        ),
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
      );

  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isLoading = false,
  }) =>
      Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SparshBorderRadius.md),
          border: Border.all(color: SparshTheme.borderGrey, width: 1),
          color: SparshTheme.cardBackground,
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : DropdownButton<String>(
                isExpanded: true,
                value: value,
                underline: Container(),
                items: items
                    .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: onChanged,
              ),
      );

  Widget _buildDateField(
      TextEditingController controller, VoidCallback onTap, String hint) =>
      TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: SparshTheme.cardBackground,
          suffixIcon:
          IconButton(icon: const Icon(Icons.calendar_today), onPressed: onTap),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SparshBorderRadius.md),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: SparshSpacing.md, vertical: SparshSpacing.sm),
        ),
        onTap: onTap,
        validator: (val) => val == null || val.isEmpty ? 'Select date' : null,
      );

  // Add a method to reset the form (clear document number)
  void _resetForm() {
    setState(() {
      _documentNumber = null;
      _documentNumberController.clear();
      _selectedProcessType = 'Select';
      // Clear other form fields as needed
    });
    DocumentNumberStorage.clearDocumentNumber(DocumentNumberKeys.phoneCallBuilder); // Clear from persistent storage
  }
}
