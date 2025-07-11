import 'package:flutter/material.dart';
import 'package:learning2/core/components/advanced_3d/advanced_3d_components.dart';
import 'package:learning2/core/utils/responsive_design.dart';
import 'package:learning2/core/utils/form_validators/form_validators.dart';
import 'package:learning2/core/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'address_verification_form.dart';

class IdentityVerificationForm extends StatefulWidget {
  const IdentityVerificationForm({super.key});

  @override
  State<IdentityVerificationForm> createState() => _IdentityVerificationFormState();
}

class _IdentityVerificationFormState extends State<IdentityVerificationForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form Controllers
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _voterIdController = TextEditingController();
  final TextEditingController _passportController = TextEditingController();
  final TextEditingController _drivingLicenseController = TextEditingController();

  // Document uploads
  File? _panDocument;
  File? _aadhaarDocument;
  File? _voterIdDocument;
  File? _passportDocument;
  File? _drivingLicenseDocument;
  File? _photoDocument;

  String _selectedIdType = 'PAN';
  final List<String> _idTypes = ['PAN', 'Aadhaar', 'Voter ID', 'Passport', 'Driving License'];

  final ImagePicker _picker = ImagePicker();

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _panController.dispose();
    _aadhaarController.dispose();
    _voterIdController.dispose();
    _passportController.dispose();
    _drivingLicenseController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument(DocumentType type) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null) {
        setState(() {
          switch (type) {
            case DocumentType.pan:
              _panDocument = File(result.files.single.path!);
              break;
            case DocumentType.aadhaar:
              _aadhaarDocument = File(result.files.single.path!);
              break;
            case DocumentType.voterID:
              _voterIdDocument = File(result.files.single.path!);
              break;
            case DocumentType.passport:
              _passportDocument = File(result.files.single.path!);
              break;
            case DocumentType.drivingLicense:
              _drivingLicenseDocument = File(result.files.single.path!);
              break;
            case DocumentType.photo:
              _photoDocument = File(result.files.single.path!);
              break;
          }
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to pick document. Please try again.');
    }
  }

  Future<void> _takePhoto(DocumentType type) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          switch (type) {
            case DocumentType.pan:
              _panDocument = File(image.path);
              break;
            case DocumentType.aadhaar:
              _aadhaarDocument = File(image.path);
              break;
            case DocumentType.voterID:
              _voterIdDocument = File(image.path);
              break;
            case DocumentType.passport:
              _passportDocument = File(image.path);
              break;
            case DocumentType.drivingLicense:
              _drivingLicenseDocument = File(image.path);
              break;
            case DocumentType.photo:
              _photoDocument = File(image.path);
              break;
          }
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to take photo. Please try again.');
    }
  }

  void _removeDocument(DocumentType type) {
    setState(() {
      switch (type) {
        case DocumentType.pan:
          _panDocument = null;
          break;
        case DocumentType.aadhaar:
          _aadhaarDocument = null;
          break;
        case DocumentType.voterID:
          _voterIdDocument = null;
          break;
        case DocumentType.passport:
          _passportDocument = null;
          break;
        case DocumentType.drivingLicense:
          _drivingLicenseDocument = null;
          break;
        case DocumentType.photo:
          _photoDocument = null;
          break;
      }
    });
  }

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate that at least one document is uploaded
    if (_panDocument == null && _aadhaarDocument == null && 
        _voterIdDocument == null && _passportDocument == null && 
        _drivingLicenseDocument == null) {
      _showErrorDialog('Please upload at least one identity document.');
      return;
    }

    if (_photoDocument == null) {
      _showErrorDialog('Please upload your photograph.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddressVerificationForm(),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Failed to save identity verification. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Advanced3DCard(
          backgroundColor: Colors.white,
          borderRadius: 20,
          enableGlassMorphism: true,
          width: ResponsiveUtil.getScreenWidth(context) * 0.8,
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
                'Error',
                style: ResponsiveTypography.headlineSmall(context).copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ResponsiveSpacing.medium(context)),
              Text(
                message,
                style: ResponsiveTypography.bodyMedium(context),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveSpacing.large(context)),
              Advanced3DButton(
                text: 'OK',
                onPressed: () => Navigator.pop(context),
                backgroundColor: SparshTheme.primaryBlue,
                width: ResponsiveUtil.scaledSize(context, 120),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              SparshTheme.primaryBlue.withOpacity(0.9),
              SparshTheme.primaryBlue.withOpacity(0.7),
              SparshTheme.primaryBlue.withOpacity(0.5),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // App Bar
                      Advanced3DAppBar(
                        title: 'Identity Verification',
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        enableGlassMorphism: false,
                        elevation: 0,
                        leading: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      
                      // Form Content
                      Expanded(
                        child: ResponsiveFormWrapper(
                          child: SingleChildScrollView(
                            child: Advanced3DCard(
                              backgroundColor: Colors.white,
                              borderRadius: 25,
                              enableGlassMorphism: true,
                              enable3DTransform: true,
                              enableHoverEffect: false,
                              padding: ResponsiveSpacing.paddingLarge(context),
                              child: Form(
                                key: _formKey,
                                child: AdvancedStaggeredAnimation(
                                  children: [
                                    // Header
                                    Text(
                                      'Identity Verification',
                                      style: ResponsiveTypography.headlineMedium(context).copyWith(
                                        color: SparshTheme.primaryBlue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    Text(
                                      'Please provide your identity documents for verification',
                                      style: ResponsiveTypography.bodyMedium(context).copyWith(
                                        color: SparshTheme.textSecondary,
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveSpacing.xLarge(context)),
                                    
                                    // Photo Upload
                                    Text(
                                      'Upload Photograph',
                                      style: ResponsiveTypography.titleMedium(context).copyWith(
                                        color: SparshTheme.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    _buildDocumentUpload(
                                      'Upload your recent photograph',
                                      DocumentType.photo,
                                      _photoDocument,
                                      Icons.face,
                                      Colors.orange,
                                    ),
                                    SizedBox(height: ResponsiveSpacing.xLarge(context)),
                                    
                                    // PAN Card
                                    Text(
                                      'PAN Card',
                                      style: ResponsiveTypography.titleMedium(context).copyWith(
                                        color: SparshTheme.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    Advanced3DTextFormField(
                                      controller: _panController,
                                      hintText: 'Enter PAN number',
                                      labelText: 'PAN Number',
                                      prefixIcon: Icons.credit_card,
                                      validator: (value) {
                                        if (value != null && value.isNotEmpty) {
                                          return FormValidators.validatePAN(value);
                                        }
                                        return null;
                                      },
                                      enableGlassMorphism: true,
                                      enable3DEffect: true,
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    _buildDocumentUpload(
                                      'Upload PAN card copy',
                                      DocumentType.pan,
                                      _panDocument,
                                      Icons.credit_card,
                                      Colors.blue,
                                    ),
                                    SizedBox(height: ResponsiveSpacing.xLarge(context)),
                                    
                                    // Aadhaar Card
                                    Text(
                                      'Aadhaar Card',
                                      style: ResponsiveTypography.titleMedium(context).copyWith(
                                        color: SparshTheme.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    Advanced3DTextFormField(
                                      controller: _aadhaarController,
                                      hintText: 'Enter Aadhaar number',
                                      labelText: 'Aadhaar Number',
                                      prefixIcon: Icons.fingerprint,
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value != null && value.isNotEmpty) {
                                          return FormValidators.validateAadhaar(value);
                                        }
                                        return null;
                                      },
                                      enableGlassMorphism: true,
                                      enable3DEffect: true,
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    _buildDocumentUpload(
                                      'Upload Aadhaar card copy',
                                      DocumentType.aadhaar,
                                      _aadhaarDocument,
                                      Icons.fingerprint,
                                      Colors.green,
                                    ),
                                    SizedBox(height: ResponsiveSpacing.xLarge(context)),
                                    
                                    // Voter ID (Optional)
                                    Text(
                                      'Voter ID (Optional)',
                                      style: ResponsiveTypography.titleMedium(context).copyWith(
                                        color: SparshTheme.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    Advanced3DTextFormField(
                                      controller: _voterIdController,
                                      hintText: 'Enter Voter ID number',
                                      labelText: 'Voter ID Number',
                                      prefixIcon: Icons.how_to_vote,
                                      enableGlassMorphism: true,
                                      enable3DEffect: true,
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    _buildDocumentUpload(
                                      'Upload Voter ID card copy',
                                      DocumentType.voterID,
                                      _voterIdDocument,
                                      Icons.how_to_vote,
                                      Colors.purple,
                                    ),
                                    SizedBox(height: ResponsiveSpacing.xLarge(context)),
                                    
                                    // Passport (Optional)
                                    Text(
                                      'Passport (Optional)',
                                      style: ResponsiveTypography.titleMedium(context).copyWith(
                                        color: SparshTheme.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    Advanced3DTextFormField(
                                      controller: _passportController,
                                      hintText: 'Enter Passport number',
                                      labelText: 'Passport Number',
                                      prefixIcon: Icons.travel_explore,
                                      enableGlassMorphism: true,
                                      enable3DEffect: true,
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    _buildDocumentUpload(
                                      'Upload Passport copy',
                                      DocumentType.passport,
                                      _passportDocument,
                                      Icons.travel_explore,
                                      Colors.indigo,
                                    ),
                                    SizedBox(height: ResponsiveSpacing.xLarge(context)),
                                    
                                    // Driving License (Optional)
                                    Text(
                                      'Driving License (Optional)',
                                      style: ResponsiveTypography.titleMedium(context).copyWith(
                                        color: SparshTheme.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    Advanced3DTextFormField(
                                      controller: _drivingLicenseController,
                                      hintText: 'Enter Driving License number',
                                      labelText: 'Driving License Number',
                                      prefixIcon: Icons.drive_eta,
                                      enableGlassMorphism: true,
                                      enable3DEffect: true,
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    _buildDocumentUpload(
                                      'Upload Driving License copy',
                                      DocumentType.drivingLicense,
                                      _drivingLicenseDocument,
                                      Icons.drive_eta,
                                      Colors.teal,
                                    ),
                                    SizedBox(height: ResponsiveSpacing.xLarge(context)),
                                    
                                    // Submit Button
                                    Advanced3DButton(
                                      text: 'Save & Continue',
                                      onPressed: _isLoading ? null : _saveAndContinue,
                                      isLoading: _isLoading,
                                      width: double.infinity,
                                      backgroundColor: SparshTheme.primaryBlue,
                                      enableGlassMorphism: true,
                                      enable3DEffect: true,
                                      icon: Icons.arrow_forward,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentUpload(String title, DocumentType type, File? document, IconData icon, Color color) {
    return Advanced3DCard(
      backgroundColor: document != null 
          ? color.withOpacity(0.1)
          : SparshTheme.lightGreyBackground,
      borderColor: document != null 
          ? color
          : SparshTheme.borderGrey,
      borderRadius: 15,
      enableGlassMorphism: false,
      enable3DTransform: true,
      padding: ResponsiveSpacing.paddingMedium(context),
      child: Column(
        children: [
          if (document != null) ...[
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 24),
                SizedBox(width: ResponsiveSpacing.small(context)),
                Expanded(
                  child: Text(
                    'Document uploaded successfully',
                    style: ResponsiveTypography.bodyMedium(context).copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _removeDocument(type),
                  icon: Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
            SizedBox(height: ResponsiveSpacing.small(context)),
            if (document.path.toLowerCase().endsWith('.pdf')) ...[
              Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
              SizedBox(height: ResponsiveSpacing.small(context)),
              Text(
                'PDF Document',
                style: ResponsiveTypography.bodySmall(context).copyWith(
                  color: SparshTheme.textSecondary,
                ),
              ),
            ] else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  document,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ] else ...[
            Icon(icon, color: color, size: 40),
            SizedBox(height: ResponsiveSpacing.medium(context)),
            Text(
              title,
              style: ResponsiveTypography.bodyMedium(context).copyWith(
                color: SparshTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveSpacing.medium(context)),
            Row(
              children: [
                Expanded(
                  child: Advanced3DButton(
                    text: 'Camera',
                    onPressed: () => _takePhoto(type),
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    enableGlassMorphism: true,
                    enable3DEffect: true,
                    icon: Icons.camera_alt,
                    height: 40,
                  ),
                ),
                SizedBox(width: ResponsiveSpacing.small(context)),
                Expanded(
                  child: Advanced3DButton(
                    text: 'Gallery',
                    onPressed: () => _pickDocument(type),
                    backgroundColor: Colors.transparent,
                    foregroundColor: color,
                    borderColor: color,
                    enableGlassMorphism: false,
                    enable3DEffect: true,
                    icon: Icons.photo_library,
                    height: 40,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

enum DocumentType {
  pan,
  aadhaar,
  voterID,
  passport,
  drivingLicense,
  photo,
}