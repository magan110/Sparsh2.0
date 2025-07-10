import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:learning2/data/sources/token_database.dart';
import 'All_Tokens.dart';
import 'package:learning2/core/constants/fonts.dart';

class TokenScanPage extends StatefulWidget {
  const TokenScanPage({super.key});
  @override
  State<TokenScanPage> createState() => _TokenScanPageState();
}

class _TokenScanPageState extends State<TokenScanPage> {
  MobileScannerController? _cameraController;
  String? _scannedValue;
  String? _pinValidationMessage;
  bool _isTokenValid = false;
  int _remainingAttempts = 3;
  final List<TextEditingController> pinControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );
  List<FocusNode> pinFocusNodes = List.generate(3, (_) => FocusNode());
  bool _isTorchOn = false;
  bool _isProcessingScan = false;
  DateTime? _lastScanTime;

  // Set to store recently scanned tokens to prevent duplicates
  final Set<String> _recentlyScannedTokens = {};

  // Map to track last scan time for each token
  final Map<String, DateTime> _lastScanTimeMap = {};

  // Map to track when we last showed an error message for a token
  final Map<String, DateTime> _lastErrorMessageTimeMap = {};

  // Set to store tokens that have reached maximum PIN attempts
  final Set<String> _maxAttemptsReachedTokens = {};

  // Set to store tokens that have been successfully validated
  final Set<String> _validatedTokens = {};

  final List<TokenCard> _attemptedCards = [];
  String? _apiAutoPin;
  bool _showMaxAttemptsError = false;
  Map<String, dynamic> _tokenDetails = {}; // Store token details for later use

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCamera();
    });
  }

  Future<void> _initializeCamera() async {
    try {
      if (_cameraController != null) {
        await _cameraController?.stop();
        _cameraController?.dispose();
      }

      setState(() {
        _cameraController = MobileScannerController(
          detectionSpeed:
              DetectionSpeed.unrestricted, // Use unrestricted for maximum speed
          facing: CameraFacing.back,
          formats: [BarcodeFormat.qrCode], // Only scan QR codes
          torchEnabled: false,
        );
      });

      await _cameraController?.start();
    } catch (e) {
      print('Camera initialization error: $e');
      // Retry camera initialization after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _initializeCamera();
      });
    }
  }

  void _validateToken(String value) {
    // Clean up the value (remove any whitespace, etc.)
    String cleanValue = value.trim();

    // Check if we're already processing a scan
    if (_isProcessingScan) {
      return;
    }

    // Check if this token has reached maximum PIN attempts
    if (_maxAttemptsReachedTokens.contains(cleanValue)) {
      // Check if we've shown an error message for this token recently
      final now = DateTime.now();
      final lastErrorTime = _lastErrorMessageTimeMap[cleanValue];

      // Only show the error message if we haven't shown it in the last 5 seconds
      if (lastErrorTime == null || now.difference(lastErrorTime) > const Duration(seconds: 5)) {
        // Show a message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This token has reached maximum PIN attempts. Please contact IT or Company Officer.',
            ),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );

        // Update the last error time for this token
        _lastErrorMessageTimeMap[cleanValue] = now;
      }

      // Don't process this token
      return;
    }

    // Check if this token has already been successfully validated
    if (_validatedTokens.contains(cleanValue)) {
      // Check if we've shown an error message for this token recently
      final now = DateTime.now();
      final lastErrorTime = _lastErrorMessageTimeMap[cleanValue];

      // Only show the error message if we haven't shown it in the last 5 seconds
      if (lastErrorTime == null || now.difference(lastErrorTime) > const Duration(seconds: 5)) {
        // Show a message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This token has already been validated and cannot be scanned again.',
            ),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );

        // Update the last error time for this token
        _lastErrorMessageTimeMap[cleanValue] = now;
      }

      // Don't process this token
      return;
    }

    // Check if this token was recently scanned
    // If it was scanned more than 2 seconds ago, allow it to be scanned again
    // Reuse the now variable if it's already defined, otherwise create it
    final now = DateTime.now();
    if (_recentlyScannedTokens.contains(cleanValue) &&
        _lastScanTimeMap.containsKey(cleanValue)) {
      final lastScanTime = _lastScanTimeMap[cleanValue]!;
      if (now.difference(lastScanTime) < const Duration(seconds: 2)) {
        print('Token scanned too recently, wait 2 seconds: $cleanValue');
        return;
      } else {
        // It's been more than 2 seconds, remove from recently scanned tokens
        _recentlyScannedTokens.remove(cleanValue);
        print('Allowing rescan after 2 seconds: $cleanValue');
      }
    }

    // Implement a faster debounce (200ms instead of 500ms)
    if (_lastScanTime != null &&
        now.difference(_lastScanTime!) < const Duration(milliseconds: 200)) {
      return;
    }
    _lastScanTime = now;

    // Store the scan time for this token
    _lastScanTimeMap[cleanValue] = now;

    // Print the scanned value for debugging
    print('==================== QR CODE SCAN DETAILS ====================');
    print('Scanned QR code raw value: $value');

    // Try to parse as JSON to see the structure
    if (value.trim().startsWith('{') || value.trim().startsWith('[')) {
      try {
        var jsonData = jsonDecode(value);
        print('QR code parsed as JSON:');
        print(const JsonEncoder.withIndent('  ').convert(jsonData));

        // If it's a JSON object, print each field separately
        if (jsonData is Map) {
          print('\nQR code fields:');
          jsonData.forEach((key, value) {
            print('  $key: $value');
          });
        }
      } catch (e) {
        print('QR code is not in valid JSON format, using as plain text: $e');
      }
    } else {
      print('QR code is not in JSON format, using as plain text');
    }
    print('===========================================================');

    // Add this token to recently scanned tokens to prevent continuous scanning
    _recentlyScannedTokens.add(cleanValue);

    // Limit the size of the set to prevent memory leaks
    if (_recentlyScannedTokens.length > 10) {
      _recentlyScannedTokens.remove(_recentlyScannedTokens.first);
    }

    setState(() {
      _isProcessingScan = true;
      _scannedValue = cleanValue; // Use the cleaned value
      _isTokenValid = false;
      _pinValidationMessage = null;
      _remainingAttempts = 3;
      _apiAutoPin = null;
      _showMaxAttemptsError = false;
    });

    _fetchTokenDetails(cleanValue); // Use the cleaned value
  }

  Future<void> _fetchTokenDetails(String value) async {
    try {
      // Store the original value for debugging
      print('Original QR code value: $value');

      // Set default values
      Map<String, dynamic> qrData = {};
      bool hasNumCvvNo = false;
      String tokenValue = value.trim(); // Use trimmed value by default

      // First check if the value looks like a JSON string
      if (value.trim().startsWith('{') || value.trim().startsWith('[')) {
        try {
          // Try to parse as JSON
          var decodedData = jsonDecode(value);

          // Handle case when the QR code contains an array of objects
          if (decodedData is List && decodedData.isNotEmpty) {
            qrData = decodedData[0];
          } else if (decodedData is Map<String, dynamic>) {
            qrData = decodedData;
          }

          // Check if numCvvNo is present in the QR data
          hasNumCvvNo = qrData.containsKey('numCvvNo');

          // If tokenIdn is present in the QR data, use it as the token number
          if (qrData.containsKey('tokenIdn')) {
            tokenValue = qrData['tokenIdn'].toString().trim();
            print('Using tokenIdn from JSON: $tokenValue');
          }
        } catch (e) {
          // Not a valid JSON string, continue with the original value
          print('QR code is not in valid JSON format: $e');
          // For non-JSON QR codes, we assume numCvvNo is not present
          hasNumCvvNo = false;
        }
      } else {
        // Not a JSON string at all, just use the raw value
        print('QR code is not in JSON format, using raw value: $tokenValue');
        hasNumCvvNo = false;
      }

      // Update the scanned value
      setState(() {
        _scannedValue = tokenValue;
      });

      // Check if the token is valid using the tokenProc/execute API
      print('Checking token validity with tokenProc/execute API: $tokenValue');
      try {
        // Using the correct format based on Postman examples with additional headers
        final scanResponse = await http
            .post(
              Uri.parse(
                'https://qa.birlawhite.com:55232/api/tokenProc/execute',
              ),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode({'Param1': tokenValue}),
            )
            .timeout(const Duration(seconds: 5));

        // Log detailed information about the request and response
        print(
          'tokenProc/execute response: ${scanResponse.statusCode} - ${scanResponse.body}',
        );

        // Parse the response to check if the token is valid
        bool isTokenValid = false;
        Map<String, dynamic> responseData = {};

        // First check if the response is a valid JSON
        if (scanResponse.statusCode == 200) {
          try {
            // Check if the response is an array or an object
            if (scanResponse.body.startsWith('[') &&
                scanResponse.body.endsWith(']')) {
              // Handle array response
              List<dynamic> responseArray = jsonDecode(scanResponse.body);
              if (responseArray.isNotEmpty) {
                // Use the first item in the array
                responseData = responseArray[0];
                print('Response is an array, using first item: $responseData');
              }
            } else if (scanResponse.body.startsWith('{') &&
                scanResponse.body.endsWith('}')) {
              // Handle object response
              responseData = jsonDecode(scanResponse.body);
            }

            // Check if isActive parameter is present and is "Y"
            if (responseData.containsKey('isActive')) {
              // Check if isActive is "Y" (active)
              String isActiveStr = responseData['isActive'].toString();
              isTokenValid = isActiveStr == 'Y' || isActiveStr == 'y';
              print(
                'Token isActive status: $isActiveStr, isTokenValid: $isTokenValid',
              );
            } else {
              // If isActive is not present, fall back to checking for success message
              isTokenValid = scanResponse.body.toLowerCase().contains(
                "success",
              );
            }
          } catch (e) {
            print('Error parsing token validity response: $e');
            // Fall back to checking for success message
            isTokenValid = scanResponse.body.toLowerCase().contains("success");
          }
        } else {
          // If status code is not 200, the token is invalid
          isTokenValid = false;
        }

        // If the token is not valid, we don't need to proceed further
        if (!isTokenValid) {
          setState(() {
            _isProcessingScan = false;
            _isTokenValid = false;
            _pinValidationMessage = '❌ Invalid Token';
          });

          // Add the invalid token to the attempted cards
          _addAttemptedToken('N/A', false, {});
          return;
        }

        // If we reach here, the token is valid
        // Store the token details for later use
        Map<String, dynamic> tokenDetails = {};
        if (scanResponse.body.isNotEmpty) {
          try {
            // Check if the response is an array or an object
            if (scanResponse.body.startsWith('[') &&
                scanResponse.body.endsWith(']')) {
              // Handle array response
              List<dynamic> responseArray = jsonDecode(scanResponse.body);
              if (responseArray.isNotEmpty) {
                // Use the first item in the array
                tokenDetails = responseArray[0];
                print('Token details from array: $tokenDetails');
              }
            } else if (scanResponse.body.startsWith('{') &&
                scanResponse.body.endsWith('}')) {
              // Handle object response
              tokenDetails = jsonDecode(scanResponse.body);
            } else {
              // If it's just a string like "success", create a simple map
              tokenDetails = {'status': scanResponse.body.replaceAll('"', '')};
            }
          } catch (e) {
            print('Error parsing token details: $e');
            // Create a default map with the response as status
            tokenDetails = {'status': scanResponse.body.replaceAll('"', '')};
          }
        }

        setState(() {
          _isProcessingScan = false;
          _tokenDetails = tokenDetails; // Store token details for later use
        });

        // Check if numCvvNo is present in the QR data or token details
        bool requiresPin = false;
        String expectedPin = '';

        // First check if numCvvNo is present in the QR data
        if (hasNumCvvNo) {
          requiresPin = true;
          // If PIN is in QR data, store it
          if (qrData.containsKey('numCvvNo')) {
            expectedPin = qrData['numCvvNo'].toString();
          }
        } else {
          // If not in QR data, check if it's in the token details from API
          if (tokenDetails.containsKey('numCvvNo')) {
            // Check if numCvvNo is not empty
            var cvvValue = tokenDetails['numCvvNo'];
            if (cvvValue != null &&
                cvvValue.toString().isNotEmpty &&
                cvvValue.toString() != '{}' &&
                cvvValue.toString() != 'null') {
              requiresPin = true;
              expectedPin = cvvValue.toString();
              print('PIN required: numCvvNo = $cvvValue');
            }
          }
        }

        // Store the expected PIN for validation
        _apiAutoPin = expectedPin;

        if (requiresPin) {
          // Show PIN dialog if PIN is required
          _showPinDialog();
        } else {
          // If PIN is not required, proceed directly with validation
          // The _validatePin method will handle showing the token details
          await _validatePin('');
        }

        return; // Exit the function after handling the token
      } catch (e) {
        print('Error checking token validity: $e');
        // Continue with the process even if there's an error
      }

      setState(() {
        _isProcessingScan = false;
      });

      // Only show PIN dialog if numCvvNo is present in the QR data
      if (hasNumCvvNo) {
        _showPinDialog();
      } else {
        // If numCvvNo is not present, proceed directly with validation
        // Use empty string as PIN since it's not required
        await _validatePin('');
      }
    } catch (e) {
      print('Error fetching token details: $e');
      setState(() {
        _isProcessingScan = false;
      });
      // We'll restart the scan instead of calling _validatePin again
      // This prevents duplicate cards from being created
      _restartScan();
    }
  }

  Future<void> _validatePin(String value) async {
    // Check if this is a direct process (no PIN required)
    bool isDirectProcess = value.isEmpty;

    // Only check remaining attempts if this is not a direct process
    if (_remainingAttempts <= 0 && !isDirectProcess) {
      setState(() {
        _showMaxAttemptsError = true;
      });
      return;
    }

    final tokenNum = _scannedValue;
    try {
      // First, check if the token is valid using the tokenProc/execute API
      print('Validating token with tokenProc/execute API: $tokenNum');

      // Create request body with token and PIN if provided
      Map<String, dynamic> requestBody = {'Param1': tokenNum ?? ''};

      // We don't need to send the PIN to the API
      // We'll validate it locally against the numCvvNo value from the API response

      final scanResponse = await http
          .post(
            Uri.parse('https://qa.birlawhite.com:55232/api/tokenProc/execute'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 5));

      // Log detailed information about the tokenProc response
      print('tokenProc/execute detailed response:');
      print('Status code: ${scanResponse.statusCode}');
      print('Response body: ${scanResponse.body}');
      print('Headers: ${scanResponse.headers}');

      // Parse the response to check if the token is valid
      bool isTokenValid = false;
      Map<String, dynamic> responseData = {};
      String expectedPin = '';

      // First check if the response is a valid JSON
      if (scanResponse.statusCode == 200) {
        try {
          // Check if the response is an array or an object
          if (scanResponse.body.startsWith('[') &&
              scanResponse.body.endsWith(']')) {
            // Handle array response
            List<dynamic> responseArray = jsonDecode(scanResponse.body);
            if (responseArray.isNotEmpty) {
              // Use the first item in the array
              responseData = responseArray[0];
              print('Response is an array, using first item: $responseData');
            }
          } else if (scanResponse.body.startsWith('{') &&
              scanResponse.body.endsWith('}')) {
            // Handle object response
            responseData = jsonDecode(scanResponse.body);
          }

          // Check if isActive parameter is present and is "Y"
          if (responseData.containsKey('isActive')) {
            // Check if isActive is "Y" (active)
            String isActiveStr = responseData['isActive'].toString();
            isTokenValid = isActiveStr == 'Y' || isActiveStr == 'y';
            print(
              'Token isActive status: $isActiveStr, isTokenValid: $isTokenValid',
            );

            // Extract the expected PIN from numCvvNo
            if (responseData.containsKey('numCvvNo')) {
              var cvvValue = responseData['numCvvNo'];
              if (cvvValue != null &&
                  cvvValue.toString().isNotEmpty &&
                  cvvValue.toString() != '{}' &&
                  cvvValue.toString() != 'null') {
                expectedPin = cvvValue.toString();
                print('Expected PIN from API: $expectedPin');
              }
            }

            // If this is a PIN validation (not direct process) and we have an expected PIN
            if (!isDirectProcess &&
                value.isNotEmpty &&
                expectedPin.isNotEmpty) {
              // Check if the entered PIN matches the expected PIN
              if (value != expectedPin) {
                setState(() {
                  _remainingAttempts--;
                  _pinValidationMessage =
                      '❌ PIN $value is Incorrect. $_remainingAttempts attempts left.';
                  _addAttemptedToken(value, false, responseData);

                  if (_remainingAttempts <= 0) {
                    _isTokenValid = false;
                    _showMaxAttemptsError = true;

                    // Add the token to the set of tokens that have reached maximum PIN attempts
                    if (_scannedValue != null) {
                      _maxAttemptsReachedTokens.add(_scannedValue!);
                      print('Token added to max attempts list: $_scannedValue');
                    }

                    Future.delayed(const Duration(milliseconds: 900), () {
                      if (mounted && Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                      _showMaxRetryDialog();
                    });
                  }
                });
                return;
              }
            }
          } else {
            // If isActive is not present, fall back to checking for success message
            isTokenValid = scanResponse.body.toLowerCase().contains("success");
          }
        } catch (e) {
          print('Error parsing token validity response: $e');
          // Fall back to checking for success message
          isTokenValid = scanResponse.body.toLowerCase().contains("success");
        }
      } else {
        // If status code is not 200, the token is invalid
        isTokenValid = false;
      }

      if (!isTokenValid) {
        setState(() {
          _isTokenValid = false;
          _pinValidationMessage = '❌ Invalid Token';
          _addAttemptedToken(isDirectProcess ? 'N/A' : value, false, {});
        });

        if (!isDirectProcess) {
          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        }
        _restartScan();
        return;
      }

      // Parse token details from scan response
      Map<String, dynamic> detail = {};
      if (scanResponse.statusCode == 200) {
        try {
          // Check if the response is an array or an object
          if (scanResponse.body.startsWith('[') &&
              scanResponse.body.endsWith(']')) {
            // Handle array response
            List<dynamic> responseArray = jsonDecode(scanResponse.body);
            if (responseArray.isNotEmpty) {
              // Use the first item in the array
              detail = responseArray[0];
              print('Token details from array: $detail');
            }
          } else if (scanResponse.body.startsWith('{') &&
              scanResponse.body.endsWith('}')) {
            // Handle object response
            detail = jsonDecode(scanResponse.body);
          } else {
            // If it's just a string like "success", create a simple map
            detail = {'status': scanResponse.body.replaceAll('"', '')};
          }
        } catch (e) {
          print('Error parsing scan response: $e');
          // Create a default map with the response as status
          detail = {'status': scanResponse.body.replaceAll('"', '')};
        }
      }

      // We've already validated the token using the tokenProc/execute API
      // If we've reached here, the token is valid

      // If we reach here, the token process was successful
      setState(() {
        // Show different message based on whether PIN was required
        _pinValidationMessage =
            isDirectProcess
                ? '✅ Token Processed Successfully!'
                : '✅ PIN $value is Correct!';
        _isTokenValid = true;

        // Keep the token in the tracking sets to prevent it from being scanned again
        // Add the token to the set of validated tokens
        // This will prevent it from being scanned again
        if (_scannedValue != null) {
          _validatedTokens.add(_scannedValue!);
          print('Added valid token to validated tokens set: $_scannedValue');
        }

        _addAttemptedToken(isDirectProcess ? 'N/A' : value, true, detail);
      });

      // Only try to pop dialog if we're not in direct process mode
      if (!isDirectProcess) {
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
      _restartScan();
    } catch (e) {
      print('Error validating token: $e');
      setState(() {
        // Only decrement attempts if this is not a direct process
        if (!isDirectProcess) {
          _remainingAttempts--;
        }
        _pinValidationMessage = '❌ Error. $_remainingAttempts attempts left.';
        _addAttemptedToken(isDirectProcess ? 'N/A' : value, false, {});

        if (_remainingAttempts <= 0 && !isDirectProcess) {
          _isTokenValid = false;
          _showMaxAttemptsError = true;

          // Add the token to the set of tokens that have reached maximum PIN attempts
          if (_scannedValue != null) {
            _maxAttemptsReachedTokens.add(_scannedValue!);
            print('Token added to max attempts list: $_scannedValue');
          }

          Future.delayed(const Duration(milliseconds: 900), () {
            if (mounted && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
            _showMaxRetryDialog();
          });
        }
      });
    }
  }

  void _addAttemptedToken(
    String enteredPin,
    bool isValid,
    Map<String, dynamic> detail,
  ) {
    // Create a map for additional details if the token is valid
    Map<String, String>? additionalDetails;

    if (isValid && detail.isNotEmpty) {
      additionalDetails = {
        // Basic Information
        'Token ID': detail['tokenIdn']?.toString() ?? '',
        'Valid Until': detail['ValidDate']?.toString() ?? '',
        'Status': detail['isActive']?.toString() ?? '',
        'Secondary Status': detail['isActive2']?.toString() ?? '',
        'Token Type': detail['TokenType']?.toString() ?? '',
        'Expiry Flag': detail['exprFlag']?.toString() ?? '',

        // Financial Information
        'Amount': '₹${detail['paramAd1']?.toString() ?? '0'}',
        'Handling Fee': '₹${detail['paramAd2']?.toString() ?? '0'}',
        'Discount': '₹${detail['paramAd3']?.toString() ?? '0'}',
        'Total Amount': '₹${detail['paramAd4']?.toString() ?? '0'}',
        'Additional Amount': '₹${detail['paramAd5']?.toString() ?? '0'}',

        // Usage Information
        'Scan Count': detail['ScanCount']?.toString() ?? '0',
        'Scan Allowed': detail['ScanAllow']?.toString() ?? '0',
        'Scanned By': detail['scanby']?.toString() ?? 'Not scanned yet',

        // Administrative Information
        'Updated By': detail['updateId']?.toString() ?? '',
        'Secondary Update ID': detail['updateId2']?.toString() ?? '',
        'PIN Required':
            detail['numCvvNo'] != null && detail['numCvvNo'].toString() != '{}'
                ? 'Yes'
                : 'No',
      };
    }

    setState(() {
      _attemptedCards.insert(
        0,
        TokenCard(
          token: _scannedValue ?? '',
          id: isValid ? (detail['tokenIdn']?.toString() ?? '') : '',
          date: isValid ? (detail['ValidDate']?.toString() ?? '') : '',
          value: isValid ? (detail['paramAd1']?.toString() ?? '') : '',
          handling: isValid ? (detail['paramAd2']?.toString() ?? '') : '',
          isValid: isValid,
          pin: enteredPin,
          additionalDetails: additionalDetails,
          initiallyExpanded: isValid, // Auto-expand valid tokens
        ),
      );
    });

    // Token has been added to the list
  }

  void _restartScan() {
    setState(() {
      // Don't remove the token from recently scanned tokens or max attempts tokens
      // This ensures that valid tokens cannot be scanned again

      _scannedValue = null;
      _isTokenValid = false;
      _pinValidationMessage = null;
      _remainingAttempts = 3;
      _showMaxAttemptsError = false;
      _isProcessingScan = false;
      for (var controller in pinControllers) {
        controller.clear();
      }
      pinFocusNodes[0].requestFocus();
    });
  }

  // Method to submit all tokens to the AllTokens screen
  void _submitAllTokens() {
    // Check if there are any valid tokens to submit
    final validTokens = _attemptedCards.where((card) => card.isValid).toList();

    if (validTokens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No valid tokens to submit'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Prepare token data for all valid tokens
    List<Map<String, dynamic>> allTokenData = [];

    // Calculate summary statistics
    int totalScan = _attemptedCards.length;
    int validScan = validTokens.length;
    int expiredScan = 0;
    int alreadyScanned = 0;
    int invalidScan = _attemptedCards.length - validTokens.length;
    int totalAmount = 0;

    for (var tokenCard in validTokens) {
      // Create token data map
      final Map<String, dynamic> tokenData = {
        'token': tokenCard.token,
        'tokenIdn': tokenCard.id,
        'isActive': 'Y',  // Mark as valid
        'paramAd1': tokenCard.value,
        'paramAd2': tokenCard.handling,
        'ValidDate': tokenCard.date,
      };

      // Add additional details if available
      if (tokenCard.additionalDetails != null) {
        tokenData.addAll(tokenCard.additionalDetails!);
      }

      // Calculate total amount
      try {
        totalAmount += int.parse(tokenCard.value);
      } catch (e) {
        // Ignore parsing errors
      }

      allTokenData.add(tokenData);
    }

    // Show token summary popup
    _showTokenSummaryPopup(allTokenData, totalScan, validScan, expiredScan, alreadyScanned, invalidScan, totalAmount);
  }

  // Method to show summary popup for all tokens
  void _showTokenSummaryPopup(List<Map<String, dynamic>> allTokenData, int totalScan, int validScan,
      int expiredScan, int alreadyScanned, int invalidScan, int totalAmount) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(0),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Table(
                  border: TableBorder.all(color: Colors.grey.shade400),
                  children: [
                    _buildTableRow('Total Scan', totalScan.toString(), Colors.blue),
                    _buildTableRow('Valid Scan', validScan.toString(), Colors.green),
                    _buildTableRow('Expired Scan', expiredScan.toString(), Colors.orange),
                    _buildTableRow('Already Scanned', alreadyScanned.toString(), Colors.deepPurple),
                    _buildTableRow('Invalid Scan', invalidScan.toString(), Colors.red),
                    _buildTableRow('Total Amount', totalAmount.toString(), Colors.black),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      icon: const Icon(Icons.close),
                      label: Text('Close', style: Fonts.bodyBold.copyWith(fontSize: 16)),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.of(context).pop(); // Close the dialog

                        try {
                          // Create a TokenDatabase instance
                          final TokenDatabase tokenDatabase = TokenDatabase();
                          int successCount = 0;

                          // Save each token to the database
                          for (var tokenData in allTokenData) {
                            await tokenDatabase.insertToken(tokenData['token'], tokenData);
                            successCount++;
                          }

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$successCount tokens saved successfully'),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
                            ),
                          );

                          // Navigate to AllTokens screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AllTokens()),
                          );
                        } catch (e) {
                          // Show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error saving tokens: $e'),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      icon: const Icon(Icons.save),
                      label: Text('Save', style: Fonts.bodyBold.copyWith(fontSize: 16)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to build summary rows
  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Fonts.bodyBold,
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  // Helper method to build table rows for the summary popup
  TableRow _buildTableRow(String label, String value, Color valueColor) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(label, style: Fonts.bodyBold),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Text(
              value,
              style: Fonts.bodyBold.copyWith(fontSize: 16, fontWeight: FontWeight.bold, color: valueColor),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _cameraController?.stop();
    _cameraController?.dispose();
    for (var node in pinFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _showMaxRetryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Max Attempts Reached'),
            content: const Text(
              'You have entered wrong PIN 3 times.\n'
              'This token has been blocked and cannot be scanned again.\n'
              'Please contact IT or Company Officer.',
            ),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                  _restartScan();
                },
              ),
            ],
          ),
    );
  }

  // _showTokenDetailsCard method has been removed to prevent duplicate cards

  void _showPinDialog() {
    // Don't pre-fill the PIN fields, let the user enter the PIN manually
    // We still have the expected PIN in _apiAutoPin for validation
    // Clear all PIN fields
    for (int i = 0; i < 3; i++) {
      pinControllers[i].text = '';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateInner) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              contentPadding: const EdgeInsets.all(20),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Enter PIN to Validate Token",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text("Token No.", style: Fonts.bodyBold.copyWith(fontSize: 18)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _scannedValue ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Enter Pin Code :",
                      style: Fonts.bodyBold.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return Container(
                          width: 50,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          child: TextField(
                            controller: pinControllers[index],
                            focusNode: pinFocusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            obscureText: false,
                            autofocus: index == 0,
                            enabled: !_showMaxAttemptsError,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (value) async {
                              if (value.isNotEmpty) {
                                if (index < 2) {
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(pinFocusNodes[index + 1]);
                                }
                                String pin =
                                    pinControllers.map((c) => c.text).join();
                                if (pin.length == 3 &&
                                    pinControllers.every(
                                      (c) =>
                                          c.text.isNotEmpty &&
                                          RegExp(r'\d').hasMatch(c.text),
                                    )) {
                                  FocusScope.of(context).unfocus();
                                  await _validatePin(pin);
                                  setStateInner(() {});
                                }
                              } else if (index > 0) {
                                FocusScope.of(
                                  context,
                                ).requestFocus(pinFocusNodes[index - 1]);
                              }
                            },
                            onTap: () {
                              pinControllers[index]
                                  .selection = TextSelection.fromPosition(
                                TextPosition(
                                  offset: pinControllers[index].text.length,
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    if (_showMaxAttemptsError)
                      const Text(
                        "❌ You have reached the maximum attempts.",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (_pinValidationMessage != null && !_showMaxAttemptsError)
                      Text(
                        _pinValidationMessage ?? '',
                        style: TextStyle(
                          color:
                              _pinValidationMessage!.contains('❌')
                                  ? Colors.red
                                  : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: 280,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child:
                          _cameraController != null
                              ? MobileScanner(
                                controller: _cameraController,
                                onDetect: (capture) {
                                  final barcode = capture.barcodes.first;
                                  if (barcode.rawValue != null &&
                                      barcode.format == BarcodeFormat.qrCode) {
                                    _validateToken(barcode.rawValue!);
                                  }
                                },
                                scanWindow: Rect.largest,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, child) {
                                  return Center(
                                    child: Text('Camera error: $error'),
                                  );
                                },
                              )
                              : const Center(
                                child: CircularProgressIndicator(),
                              ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isTorchOn ? Icons.flash_off : Icons.flash_on,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            _cameraController?.toggleTorch().then((_) {
                              setState(() {
                                _isTorchOn = !_isTorchOn;
                              });
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  if (_isProcessingScan)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black54,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Scan a token',
              style: Fonts.bodyBold,
            ),
            const SizedBox(height: 10),
            Container(height: 1, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            _buildTopNav(context, 'Details'),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  if (_attemptedCards.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        "Token/PIN Attempts:",
                        style: Fonts.bodyBold,
                      ),
                    ),
                  ..._attemptedCards,

                  // Only show the submit button if there are token cards
                  if (_attemptedCards.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton.icon(
                        onPressed: _submitAllTokens,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.save),
                        label: const Text(
                          'Submit All Tokens',
                          style: Fonts.bodyBold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNav(BuildContext context, String activeTab) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 1.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(
              context,
              'Details',
              activeTab == 'Details',
              const Text('Details'),
            ),
            _navItem(
              context,
              'All Tokens',
              activeTab == 'All Tokens',
              const AllTokens(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    String label,
    bool isActive,
    Widget targetPage,
  ) {
    return GestureDetector(
      onTap: () {
        print('Tapped on $label tab, isActive: $isActive');
        if (!isActive) {
          print('Navigating to $label screen');
          if (label == 'All Tokens') {
            // Explicitly navigate to AllTokens
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AllTokens()),
            );
          } else {
            // Navigate to the target page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => targetPage),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isActive
                  ? const Color.fromRGBO(0, 112, 183, 1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class TokenCard extends StatefulWidget {
  final String token;
  final String id;
  final String date;
  final String value;
  final String handling;
  final bool isValid;
  final String pin;
  final Map<String, String>? additionalDetails; // Added for more token details
  final bool initiallyExpanded; // Control initial expansion state

  const TokenCard({
    super.key,
    required this.token,
    required this.id,
    required this.date,
    required this.value,
    required this.handling,
    required this.isValid,
    required this.pin,
    this.additionalDetails,
    this.initiallyExpanded = false, // Default to collapsed
  });

  @override
  State<TokenCard> createState() => _TokenCardState();
}

class _TokenCardState extends State<TokenCard> {
  late bool isExpanded;

  @override
  void initState() {
    super.initState();
    // Initialize expansion state from widget property
    // Always expand valid tokens by default
    isExpanded = widget.initiallyExpanded || widget.isValid;
  }

  // Method to submit token to AllTokens screen
  void _submitTokenToAllTokens(BuildContext context) async {
    if (!widget.isValid) {
      // Only valid tokens can be submitted
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only valid tokens can be submitted'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Create a token data map
      final Map<String, dynamic> tokenData = {
        'token': widget.token,
        'tokenIdn': widget.id,
        'isActive': 'Y',  // Mark as valid
        'paramAd1': widget.value,
        'paramAd2': widget.handling,
        'ValidDate': widget.date,
      };

      // Add all additional details
      if (widget.additionalDetails != null) {
        tokenData.addAll(widget.additionalDetails!);
      }

      // Save to database
      final TokenDatabase tokenDatabase = TokenDatabase();
      await tokenDatabase.insertToken(widget.token, tokenData);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Token ${widget.token} submitted successfully'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate to AllTokens screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AllTokens()),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting token: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Helper method to build a section of details
  Widget _buildDetailSection(String title, List<String> keys) {
    // Filter out keys that don't have values or have null/empty values
    final validKeys =
        keys.where((key) {
          final value = widget.additionalDetails?[key];
          return value != null && value.isNotEmpty && value != 'null';
        }).toList();

    // If no valid keys, don't show the section
    if (validKeys.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        // Section content
        ...validKeys.map((key) {
          final value = widget.additionalDetails![key]!;
          return Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '$key:',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(value, style: const TextStyle(fontSize: 13)),
                ),
              ],
            ),
          );
        }),
        // Add a divider after the section
        const Divider(height: 16, thickness: 0.5),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => isExpanded = !isExpanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: widget.isValid ? Colors.blue : Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.token,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child:
                  widget.isValid
                      ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Main token information in a card
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Token ID row
                                if (widget.id.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        const Text(
                                          'Token ID: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          widget.id,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),

                                // Valid until row
                                if (widget.date.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        const Text(
                                          'Valid Until: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          widget.date,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),

                                // Amount row
                                if (widget.value.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        const Text(
                                          'Amount: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          '₹${widget.value}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // Handling fee row
                                if (widget.handling.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        const Text(
                                          'Handling Fee: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          '₹${widget.handling}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),

                                // PIN row
                                Row(
                                  children: [
                                    const Text(
                                      'PIN: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Container(
                                      width: 50,
                                      height: 30,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.blue),
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.blue.shade50,
                                      ),
                                      child: Text(
                                        widget.pin,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Display additional details if available
                          if (widget.additionalDetails != null &&
                              widget.additionalDetails!.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                const Divider(height: 1, thickness: 1),
                                const SizedBox(height: 12),
                                const Text(
                                  'Token Details:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Group details into sections with all the requested parameters
                                _buildDetailSection('Basic Information', [
                                  'Token ID',
                                  'Valid Until',
                                  'Status',
                                  'Secondary Status',
                                  'Token Type',
                                  'Expiry Flag',
                                  'PIN Required',
                                ]),

                                const SizedBox(height: 8),
                                _buildDetailSection('Financial Information', [
                                  'Amount',
                                  'Handling Fee',
                                  'Discount',
                                  'Total Amount',
                                  'Additional Amount',
                                ]),

                                const SizedBox(height: 8),
                                _buildDetailSection('Usage Information', [
                                  'Scan Count',
                                  'Scan Allowed',
                                  'Scanned By',
                                ]),

                                const SizedBox(height: 8),
                                _buildDetailSection(
                                  'Administrative Information',
                                  ['Updated By', 'Secondary Update ID'],
                                ),
                              ],
                            ),

                          const SizedBox(height: 12),
                          // Status indicator
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withAlpha(100),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Token Accepted',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Submit button
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _submitTokenToAllTokens(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.send, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Submit Token',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Error - ${widget.token}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const Text(
                            'Please check with IT or Company Officer',
                            style: TextStyle(fontSize: 16),
                          ),
                          Row(
                            children: [
                              const Text('Tried PIN: '),
                              Container(
                                width: 50,
                                height: 30,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.red),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  widget.pin,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Rejected',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
            ),
        ],
      ),
    );
  }
}
