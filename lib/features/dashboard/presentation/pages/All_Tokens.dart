import 'package:flutter/material.dart';
import 'package:learning2/data/sources/token_database.dart';
import 'package:learning2/core/constants/fonts.dart';
import 'package:learning2/core/components/advanced_3d/advanced_3d_components.dart';
import 'package:learning2/core/utils/responsive_design.dart';
import 'package:learning2/core/utils/form_validators/form_validators.dart';
import 'package:learning2/core/theme/app_theme.dart';

class AllTokens extends StatefulWidget {
  const AllTokens({super.key});

  @override
  State<AllTokens> createState() => _AllTokensState();
}

class _AllTokensState extends State<AllTokens> with TickerProviderStateMixin {
  final TokenDatabase _tokenDatabase = TokenDatabase();
  late Future<List<Map<String, dynamic>>> _tokensFuture;

  // Animation controllers
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadTokens();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _loadTokens() {
    setState(() {
      _tokensFuture = _tokenDatabase.getAllTokenData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SparshTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'All Tokens',
          style: ResponsiveTypography.titleLarge(context).copyWith(
            color: SparshTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: SparshTheme.cardBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: SparshTheme.primaryBlue),
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
      body: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: Column(
                children: [
                  // Header Card
                  Container(
                    margin: ResponsiveSpacing.paddingMedium(context),
                    child: Advanced3DCard(
                      padding: ResponsiveSpacing.paddingLarge(context),
                      backgroundColor: SparshTheme.cardBackground,
                      borderRadius: 20,
                      enableGlassMorphism: true,
                      child: Row(
                        children: [
                          Container(
                            padding: ResponsiveSpacing.paddingSmall(context),
                            decoration: BoxDecoration(
                              color: SparshTheme.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.token,
                              color: SparshTheme.primaryBlue,
                              size: ResponsiveUtil.scaledSize(context, 24),
                            ),
                          ),
                          SizedBox(width: ResponsiveSpacing.medium(context)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'All Tokens',
                                  style: ResponsiveTypography.headlineSmall(context).copyWith(
                                    color: SparshTheme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'View all scanned tokens history',
                                  style: ResponsiveTypography.bodyMedium(context).copyWith(
                                    color: SparshTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Tokens List
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _tokensFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: Advanced3DCard(
                              padding: ResponsiveSpacing.paddingXLarge(context),
                              backgroundColor: SparshTheme.cardBackground,
                              borderRadius: 20,
                              enableGlassMorphism: true,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      SparshTheme.primaryBlue,
                                    ),
                                  ),
                                  SizedBox(height: ResponsiveSpacing.medium(context)),
                                  Text(
                                    'Loading tokens...',
                                    style: ResponsiveTypography.bodyLarge(context).copyWith(
                                      color: SparshTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Advanced3DCard(
                              padding: ResponsiveSpacing.paddingXLarge(context),
                              backgroundColor: SparshTheme.cardBackground,
                              borderRadius: 20,
                              enableGlassMorphism: true,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: ResponsiveUtil.scaledSize(context, 48),
                                  ),
                                  SizedBox(height: ResponsiveSpacing.medium(context)),
                                  Text(
                                    'Error loading tokens',
                                    style: ResponsiveTypography.headlineSmall(context).copyWith(
                                      color: SparshTheme.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: ResponsiveSpacing.small(context)),
                                  Text(
                                    '${snapshot.error}',
                                    textAlign: TextAlign.center,
                                    style: ResponsiveTypography.bodyMedium(context).copyWith(
                                      color: SparshTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Advanced3DCard(
                              padding: ResponsiveSpacing.paddingXLarge(context),
                              backgroundColor: SparshTheme.cardBackground,
                              borderRadius: 20,
                              enableGlassMorphism: true,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.token_outlined,
                                    color: SparshTheme.primaryBlue,
                                    size: ResponsiveUtil.scaledSize(context, 48),
                                  ),
                                  SizedBox(height: ResponsiveSpacing.medium(context)),
                                  Text(
                                    'No Tokens Found',
                                    style: ResponsiveTypography.headlineSmall(context).copyWith(
                                      color: SparshTheme.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: ResponsiveSpacing.small(context)),
                                  Text(
                                    'Start scanning tokens to see them here',
                                    textAlign: TextAlign.center,
                                    style: ResponsiveTypography.bodyMedium(context).copyWith(
                                      color: SparshTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return _buildTokenList(snapshot.data!);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTokenList(List<Map<String, dynamic>> tokens) {
    return ListView.builder(
      padding: ResponsiveSpacing.paddingMedium(context),
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

        return AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            final delay = index * 0.1;
            final animationValue = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: _animController,
                curve: Interval(
                  delay,
                  (delay + 0.5).clamp(0.0, 1.0),
                  curve: Curves.easeOutCubic,
                ),
              ),
            );
            
            return FadeTransition(
              opacity: animationValue,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - animationValue.value)),
                child: Container(
                  margin: EdgeInsets.only(bottom: ResponsiveSpacing.medium(context)),
                  child: Advanced3DCard(
                    backgroundColor: SparshTheme.cardBackground,
                    borderRadius: 16,
                    enableGlassMorphism: true,
                    enableHoverEffect: true,
                    child: ExpansionTile(
                      title: Text(
                        'Token: $tokenValue',
                        style: ResponsiveTypography.bodyLarge(context).copyWith(
                          color: SparshTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Scanned: $formattedDate',
                        style: ResponsiveTypography.bodySmall(context).copyWith(
                          color: SparshTheme.textSecondary,
                        ),
                      ),
                      leading: Container(
                        padding: ResponsiveSpacing.paddingSmall(context),
                        decoration: BoxDecoration(
                          color: isValid ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isValid ? Icons.check_circle : Icons.cancel,
                          color: isValid ? Colors.green : Colors.red,
                          size: ResponsiveUtil.scaledSize(context, 20),
                        ),
                      ),
                      children: [
                        Container(
                          padding: ResponsiveSpacing.paddingLarge(context),
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
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding: EdgeInsets.only(bottom: ResponsiveSpacing.small(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: ResponsiveUtil.scaledSize(context, 100),
            child: Text(
              '$label:',
              style: ResponsiveTypography.bodyMedium(context).copyWith(
                color: SparshTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: ResponsiveTypography.bodyMedium(context).copyWith(
                color: SparshTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
