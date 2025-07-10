import 'package:flutter/material.dart';
import 'package:learning2/data/sources/token_database.dart';
import 'package:learning2/core/constants/fonts.dart';

class AllTokens extends StatefulWidget {
  const AllTokens({super.key});

  @override
  State<AllTokens> createState() => _AllTokensState();
}

class _AllTokensState extends State<AllTokens> {
  final TokenDatabase _tokenDatabase = TokenDatabase();
  late Future<List<Map<String, dynamic>>> _tokensFuture;

  @override
  void initState() {
    super.initState();
    _loadTokens();
  }

  void _loadTokens() {
    setState(() {
      _tokensFuture = _tokenDatabase.getAllTokenData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tokens'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTokens,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _tokensFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tokens found'));
          } else {
            return _buildTokenList(snapshot.data!);
          }
        },
      ),
    );
  }

  Widget _buildTokenList(List<Map<String, dynamic>> tokens) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tokens.length,
      itemBuilder: (context, index) {
        final token = tokens[index];
        final tokenData = token['tokenData'] as Map<String, dynamic>;
        final timestamp = DateTime.parse(token['timestamp']);
        final formattedDate = '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute}';

        // Extract relevant token details
        final tokenValue = token['token'] as String;
        final isValid = tokenData['isActive'] == 'Y';
        final tokenId = tokenData['tokenIdn']?.toString() ?? 'N/A';
        final amount = tokenData['paramAd1']?.toString() ?? 'N/A';
        final validDate = tokenData['ValidDate']?.toString() ?? 'N/A';

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            title: Text(
              'Token: $tokenValue',
              style: Fonts.bodyBold,
            ),
            subtitle: Text('Scanned: $formattedDate'),
            leading: CircleAvatar(
              backgroundColor: isValid ? Colors.green : Colors.red,
              child: Icon(
                isValid ? Icons.check : Icons.close,
                color: Colors.white,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Token ID', tokenId),
                    _buildDetailRow('Status', isValid ? 'Valid' : 'Invalid'),
                    _buildDetailRow('Amount', amount),
                    _buildDetailRow('Valid Until', validDate),
                    _buildDetailRow('Scan Date', formattedDate),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Fonts.bodyBold,
            ),
          ),
          Expanded(
            child: Text(value, style: Fonts.body),
          ),
        ],
      ),
    );
  }
}
