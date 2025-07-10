import 'package:flutter/material.dart';
import 'package:learning2/features/dashboard/presentation/pages/All_Tokens.dart';
import '../../../../data/sources/token_database.dart' show TokenDatabase;
import 'token_summary_model.dart';
import 'token_scan.dart';
import 'package:learning2/core/constants/fonts.dart';

class TokenSummaryScreen extends StatefulWidget {
  final String activeTab;
  final List<String>? tokens;

  const TokenSummaryScreen({super.key, this.activeTab = 'Summary', this.tokens});

  @override
  State<TokenSummaryScreen> createState() => _TokenSummaryScreenState();
}

class _TokenSummaryScreenState extends State<TokenSummaryScreen> {
  late TokenSummaryModel summary;
  final TokenDatabase _tokenDatabase = TokenDatabase();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    summary = TokenSummaryModel();
  }

  void _navigateToTokenScanPage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const TokenScanPage()),
          (Route<dynamic> route) => false,
    );
  }

  // Save tokens to database
  Future<void> _saveTokens() async {
    if (_isSaving) return; // Prevent multiple saves

    setState(() {
      _isSaving = true;
    });

    try {
      // Get all tokens from the summary model
      final scannedTokens = summary.scannedTokens;

      if (scannedTokens.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No tokens to save'), backgroundColor: Colors.orange),
        );
        return;
      }

      // Debug: Print tokens before saving
      debugPrint('Saving ${scannedTokens.length} tokens to database:');
      for (var token in scannedTokens) {
        debugPrint('Token: ${token['token']}, isValid: ${token['isValid']}');
      }

      // Process tokens to ensure they have the correct format
      List<Map<String, dynamic>> processedTokens = [];
      for (var token in scannedTokens) {
        // Make sure each token has a 'token' field
        if (!token.containsKey('token') && token.containsKey('tokenIdn')) {
          token['token'] = token['tokenIdn'];
        }

        // Make sure each token has an 'isValid' field
        if (!token.containsKey('isValid') && token.containsKey('isActive')) {
          token['isValid'] = token['isActive'] == 'Y' || token['isActive'] == 'y';
        }

        // Only add valid tokens
        if (token.containsKey('token') &&
            token['token'] != null &&
            token['token'].toString().isNotEmpty) {
          processedTokens.add(token);
        }
      }

      // Save tokens to database
      await _tokenDatabase.insertTokens(processedTokens);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tokens saved successfully'), backgroundColor: Colors.green),
      );

      // Navigate to token details page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AllTokens()),
      );
    } catch (e) {
      if (!mounted) return;

      // Show error message with more details
      debugPrint('Error saving tokens: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving tokens: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(label: 'RETRY', textColor: Colors.white, onPressed: _saveTokens),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    summary = TokenSummaryModel();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Token Summary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateToTokenScanPage, // Changed to navigate to TokenScanPage
        ),
      ),
      body: Column(
        children: [
          _buildTopNav(context, widget.activeTab),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6)],
                    ),
                    child: _buildSummaryTable(),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 10),
                      _buildButton(
                        "Close",
                        Colors.grey,
                        Colors.black,
                        _navigateToTokenScanPage,
                      ), // Changed to navigate to TokenScanPage
                      _isSaving
                          ? Container(
                        width: 120,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.blue.withAlpha(179), // 0.7 * 255 = 179
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        ),
                      )
                          : _buildButton("Save", Colors.blue, Colors.white, () {
                        _saveTokens();
                      }),
                    ],
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
              style: Fonts.bodyBold.copyWith(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade400),
      children: [
        _buildTableRow('Total Scan', summary.totalScan.toString(), Colors.blue),
        _buildTableRow('Valid Scan', summary.validScan.toString(), Colors.green),
        _buildTableRow('Expired Scan', summary.expiredScan.toString(), Colors.orange),
        _buildTableRow('Already Scanned', summary.alreadyScanned.toString(), Colors.deepPurple),
        _buildTableRow('Invalid Scan', summary.invalidScan.toString(), Colors.red),
        _buildTableRow('Total Amount', summary.totalAmount.toString(), Colors.black),
      ],
    );
  }

  Widget _buildButton(String text, Color bgColor, Color textColor, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      ),
      icon: Icon(text == "Close" ? Icons.close : Icons.save, color: textColor),
      label: Text(text, style: Fonts.body.copyWith(color: textColor, fontSize: 16)),
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
      ),
    );
  }
  }
