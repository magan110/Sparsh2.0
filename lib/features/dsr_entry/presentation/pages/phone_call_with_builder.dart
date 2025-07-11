import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../core/theme/app_theme.dart';
import 'dsr_entry.dart';

class PhoneCallWithBuilder extends StatefulWidget {
  const PhoneCallWithBuilder({super.key});

  @override
  State<PhoneCallWithBuilder> createState() => _PhoneCallWithBuilderState();
}

class _PhoneCallWithBuilderState extends State<PhoneCallWithBuilder> {
  final _formKey = GlobalKey<FormState>();

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
  bool _isLoadingProcessTypes = true;
  bool _isLoadingAreaCodes = true;
  bool _isLoadingPurchasers = false;
  bool _isLoadingPurchaserCodes = false;

  final TextEditingController _submissionDateController = TextEditingController();
  final TextEditingController _reportDateController     = TextEditingController();

  final TextEditingController _codeController         = TextEditingController();
  final TextEditingController _siteController         = TextEditingController();
  final TextEditingController _contractorController   = TextEditingController();
  String? _metWithItem = 'Select';
  final List<String> _metWithItems = ['Select', 'Builder', 'Contractor'];
  final TextEditingController _namedesgController     = TextEditingController();
  final TextEditingController _topicController        = TextEditingController();
  final TextEditingController _ugaiRecoveryController = TextEditingController();
  final TextEditingController _grievanceController    = TextEditingController();
  final TextEditingController _otherPointController   = TextEditingController();

  List<File?> _selectedImages = [null];

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setSubmissionDateToToday();
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
    try {
      final url = Uri.parse('http://192.168.36.25/api/DsrTry/getProcessTypes');
      print('🔍 Fetching process types from: $url');
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout: Process types API took too long to respond');
        },
      );
      print('📡 Process types response status: ${response.statusCode}');
      print('📄 Process types response body: ${response.body}');
      print('📄 Response headers: ${response.headers}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('📊 Parsed process types data: $data');
        
        List<String> processTypes = [];
        
        // Based on the C# controller, the response format is:
        // {"processTypes": [{"code": "...", "description": "..."}, ...]}
        if (data is Map && data.containsKey('processTypes')) {
          final processTypesList = data['processTypes'] as List;
          print('📋 ProcessTypes list type: ${processTypesList.runtimeType}');
          print('📋 First item type: ${processTypesList.isNotEmpty ? processTypesList.first.runtimeType : 'Empty list'}');
          print('📋 First item: ${processTypesList.isNotEmpty ? processTypesList.first : 'Empty list'}');
          
          processTypes = processTypesList.map((type) {
            print('📝 Processing type item: $type (type: ${type.runtimeType})');
            // Handle both object format and direct string format
            if (type is Map) {
              print('📝 Type item keys: ${type.keys.toList()}');
              print('📝 Type item values: ${type.values.toList()}');
              // Try different possible property names
              final description = type['Description']?.toString() ?? 
                                type['description']?.toString() ?? 
                                type['desc']?.toString();
              final code = type['Code']?.toString() ?? 
                          type['code']?.toString();
              print('📝 Processing type object - Description: "$description", Code: "$code"');
              return description ?? code ?? '';
            } else {
              print('📝 Processing type as string: "$type"');
              return type.toString();
            }
          }).where((type) => type.isNotEmpty).toList();
          print('✅ Found ProcessTypes property with ${processTypes.length} items');
          
          // If processTypes is empty, try to use defaultType mapping
          if (processTypes.isEmpty && data.containsKey('defaultType')) {
            final defaultType = data['defaultType'] as Map;
            processTypes = defaultType.values.map((value) => value.toString()).toList();
            print('✅ Using DefaultType mapping: $processTypes');
          }
        } else {
          print('❌ Unexpected response format: ${data.runtimeType}');
          print('📋 Available keys: ${data is Map ? data.keys.toList() : 'Not a Map'}');
          print('📋 Full response data: $data');
          
          // Try to extract process types from the response in different ways
          if (data is Map) {
            // Try to find any array that might contain process types
            for (var entry in data.entries) {
              if (entry.value is List) {
                print('📋 Found list in key "${entry.key}": ${entry.value}');
                final list = entry.value as List;
                if (list.isNotEmpty) {
                  final firstItem = list.first;
                  print('📋 First item in "${entry.key}": $firstItem (type: ${firstItem.runtimeType})');
                }
              }
            }
            
            // Try to use processTypes if it exists but we missed it
            if (data.containsKey('processTypes')) {
              print('📋 Found processTypes key, trying to use it...');
              final processTypesList = data['processTypes'] as List;
              processTypes = processTypesList.map((type) {
                if (type is Map) {
                  return type['description']?.toString() ?? type['code']?.toString() ?? '';
                } else {
                  return type.toString();
                }
              }).where((type) => type.isNotEmpty).toList();
              print('✅ Successfully extracted process types: $processTypes');
            }
          }
          
          if (processTypes.isEmpty) {
            throw Exception('Unexpected response format: ${data.runtimeType}. Available keys: ${data is Map ? data.keys.toList() : 'Not a Map'}');
          }
        }
        
        setState(() {
          _processTypes = ['Select', ...processTypes];
          _isLoadingProcessTypes = false;
        });
        print('✅ Process types loaded: $_processTypes');
      } else {
        print('❌ Failed to fetch process types: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to fetch process types: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error fetching process types: $e');
      setState(() {
        // Fallback to hardcoded process types if API fails
        _processTypes = ['Select', 'Add', 'Update'];
        _isLoadingProcessTypes = false;
      });
      // Show warning message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Using default process types. API error: ${e.toString()}'),
          backgroundColor: SparshTheme.warningOrange ?? Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
          print('✅ Area codes is a List with ${data.length} items');
          
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
            }).toList()
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
      
      // Based on the C# controller, use getPurchaserCode endpoint
      final url = Uri.parse('http://192.168.36.25/api/DsrTry/getPurchaserCode')
          .replace(queryParameters: {
        'areaCode': _selectedAreaCode,
        'purchaserType': purchaserCode,
      });
      
      print('🌐 Calling purchaser code API: $url');
      
      final response = await http.get(url);
      print('📡 Purchaser code response status: ${response.statusCode}');
      print('📄 Purchaser code response body: ${response.body}');
      
      final data = jsonDecode(response.body);
      print('Purchaser code API data: $data'); // Debug print
      
      // Accept both PurchaserCodes and purchaserCodes
      if (data is Map && (data.containsKey('PurchaserCodes') || data.containsKey('purchaserCodes'))) {
        final purchaserCodesList = (data['PurchaserCodes'] ?? data['purchaserCodes']) as List;
        final purchaserCodes = purchaserCodesList.map((code) => code.toString()).toList();
        
        if (purchaserCodes.isNotEmpty) {
          setState(() {
            _purchaserCodes = [
              {'code': 'Select', 'name': 'Select'},
              ...purchaserCodes.map((code) => {'code': code, 'name': code}).toList()
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
        throw Exception('Invalid response format: expected Map with PurchaserCodes but got ${data.runtimeType}. Data: $data');
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
    _siteController.dispose();
    _contractorController.dispose();
    _namedesgController.dispose();
    _topicController.dispose();
    _ugaiRecoveryController.dispose();
    _grievanceController.dispose();
    _otherPointController.dispose();
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
      firstDate: threeDaysAgo,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
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

  void _onSubmit({required bool exitAfter}) async {
    if (!_formKey.currentState!.validate()) return;
    
    // Additional validation for dropdown fields
    if (_selectedProcessType == 'Select') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a Process Type'),
          backgroundColor: SparshTheme.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    if (_selectedAreaCode == 'Select') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select an Area Code'),
          backgroundColor: SparshTheme.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    if (_selectedPurchaser == 'Select') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a Purchaser Type'),
          backgroundColor: SparshTheme.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    if (_selectedPurchaserCode == 'Select') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a Purchaser Code'),
          backgroundColor: SparshTheme.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    if (_metWithItem == 'Select') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select who you met with'),
          backgroundColor: SparshTheme.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final dsrData = {
      'ActivityType': 'Phone Call with Builder /Stockist',
      'SubmissionDate': _submissionDateController.text,
      'ReportDate': _reportDateController.text,
      'CreateId': 'SYSTEM',
      'AreaCode': _selectedAreaCode ?? '',
      'Purchaser': _selectedPurchaser ?? '',
      'PurchaserCode': _selectedPurchaserCode ?? '',
      'ProcessType': _selectedProcessType ?? '',
      'MetWith': _metWithItem ?? '',
      'dsrRem01': _namedesgController.text,
      'dsrRem02': _topicController.text,
      'dsrRem03': _ugaiRecoveryController.text,
      'dsrRem04': _grievanceController.text,
      'dsrRem05': _otherPointController.text,
      'dsrRem06': _siteController.text,
      'dsrRem07': _contractorController.text,
      'dsrRem08': _codeController.text,
    };

    try {
      await submitDsrEntry(dsrData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(exitAfter
              ? 'Submitted successfully. Exiting...'
              : 'Submitted successfully. Ready for new entry.'),
          backgroundColor: SparshTheme.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (exitAfter) {
        Navigator.of(context).pop();
      } else {
        _clearForm();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Submission failed: ${e.toString()}'),
          backgroundColor: SparshTheme.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _clearForm() {
    setState(() {
      _selectedProcessType = 'Select';
      _submissionDateController.clear();
      _reportDateController.clear();
      _selectedAreaCode = 'Select';
      _selectedPurchaser = 'Select';
      _selectedPurchaserCode = 'Select';
      _codeController.clear();
      _siteController.clear();
      _contractorController.clear();
      _metWithItem = 'Select';
      _namedesgController.clear();
      _topicController.clear();
      _ugaiRecoveryController.clear();
      _grievanceController.clear();
      _otherPointController.clear();
      _selectedImages = [null];
    });
    _formKey.currentState!.reset();
  }

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
              _buildDropdownField(
                value: _selectedProcessType,
                items: _processTypes,
                onChanged: _onProcessTypeChanged,
                isLoading: _isLoadingProcessTypes,
              ),
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
                  suffixIcon: Icon(Icons.lock, color: Colors.grey),
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
              // Custom dropdown for Area Code: display 'code - name', value is code
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
                        items: _areaCodes.map((area) {
                          final code = area['code']!;
                          final name = area['name']!;
                          return DropdownMenuItem(
                            value: code,
                            child: Text(code == 'Select' ? 'Select' : '$code - $name'),
                          );
                        }).toList(),
                        onChanged: _onAreaCodeChanged,
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
              _buildDropdownField(
                value: _selectedPurchaserCode,
                items: _purchaserCodes.map((code) => code['name']!).toList(),
                onChanged: (value) {
                  final selectedCode = _purchaserCodes.firstWhere(
                    (code) => code['name'] == value,
                    orElse: () => {'code': 'Select', 'name': 'Select'},
                  );
                  _onPurchaserCodeChanged(selectedCode['code']);
                },
                isLoading: _isLoadingPurchaserCodes,
              ),
              const SizedBox(height: 10),
              _buildLabel('Site Name'),
              _buildTextField('Enter Site Name', controller: _siteController),
              const SizedBox(height: 10),
              _buildLabel('Contractor Working at Site'),
              _buildTextField(
                  'Enter Contractor Name', controller: _contractorController),
              const SizedBox(height: 10),
              _buildLabel('Met With'),
              _buildDropdownField(
                value: _metWithItem,
                items: _metWithItems,
                onChanged: (val) => setState(() => _metWithItem = val),
              ),
              const SizedBox(height: 10),
              _buildLabel('Name and Designation of Person'),
              _buildTextField(
                  'Enter Name and Designation', controller: _namedesgController),
              const SizedBox(height: 10),
              _buildLabel('Topic Discussed'),
              _buildTextField('Enter Topic Discussed',
                  controller: _topicController, maxLines: 3),
              const SizedBox(height: 10),
              _buildLabel('Ugai Recovery Plans'),
              _buildTextField('Enter Ugai Recovery Plans',
                  controller: _ugaiRecoveryController, maxLines: 3),
              const SizedBox(height: 10),
              _buildLabel('Any Purchaser Grievances'),
              _buildTextField('Enter Purchaser Grievances',
                  controller: _grievanceController, maxLines: 3),
              const SizedBox(height: 10),
              _buildLabel('Any Other Point'),
              _buildTextField('Enter Any Other Point',
                  controller: _otherPointController, maxLines: 3),
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
}
