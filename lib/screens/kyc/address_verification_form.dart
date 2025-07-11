import 'package:flutter/material.dart';
import 'package:learning2/core/components/advanced_3d/advanced_3d_components.dart';
import 'package:learning2/core/utils/responsive_design.dart';
import 'package:learning2/core/utils/form_validators/form_validators.dart';
import 'package:learning2/core/theme/app_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddressVerificationForm extends StatefulWidget {
  const AddressVerificationForm({super.key});

  @override
  State<AddressVerificationForm> createState() => _AddressVerificationFormState();
}

class _AddressVerificationFormState extends State<AddressVerificationForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form Controllers
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();

  // Document uploads
  File? _electricityBillDocument;
  File? _bankStatementDocument;
  File? _rentAgreementDocument;
  File? _propertyTaxDocument;
  File? _gasBillDocument;
  File? _telephoneBillDocument;

  String _selectedProofType = 'Electricity Bill';
  final List<String> _proofTypes = [
    'Electricity Bill',
    'Bank Statement',
    'Rent Agreement',
    'Property Tax Receipt',
    'Gas Bill',
    'Telephone Bill'
  ];

  String _addressType = 'Permanent';
  bool _sameAsCurrentAddress = false;

  final ImagePicker _picker = ImagePicker();

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _countryController.text = 'India';
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
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _countryController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument(AddressDocumentType type) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null) {
        setState(() {
          switch (type) {
            case AddressDocumentType.electricityBill:
              _electricityBillDocument = File(result.files.single.path!);
              break;
            case AddressDocumentType.bankStatement:
              _bankStatementDocument = File(result.files.single.path!);
              break;
            case AddressDocumentType.rentAgreement:
              _rentAgreementDocument = File(result.files.single.path!);
              break;
            case AddressDocumentType.propertyTax:
              _propertyTaxDocument = File(result.files.single.path!);
              break;
            case AddressDocumentType.gasBill:
              _gasBillDocument = File(result.files.single.path!);
              break;
            case AddressDocumentType.telephoneBill:
              _telephoneBillDocument = File(result.files.single.path!);
              break;
          }
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to pick document. Please try again.');
    }
  }

  Future<void> _takePhoto(AddressDocumentType type) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          switch (type) {
            case AddressDocumentType.electricityBill:
              _electricityBillDocument = File(image.path);
              break;
            case AddressDocumentType.bankStatement:
              _bankStatementDocument = File(image.path);
              break;
            case AddressDocumentType.rentAgreement:
              _rentAgreementDocument = File(image.path);
              break;
            case AddressDocumentType.propertyTax:
              _propertyTaxDocument = File(image.path);
              break;
            case AddressDocumentType.gasBill:
              _gasBillDocument = File(image.path);
              break;
            case AddressDocumentType.telephoneBill:
              _telephoneBillDocument = File(image.path);
              break;
          }
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to take photo. Please try again.');
    }
  }

  void _removeDocument(AddressDocumentType type) {
    setState(() {
      switch (type) {
        case AddressDocumentType.electricityBill:
          _electricityBillDocument = null;
          break;
        case AddressDocumentType.bankStatement:
          _bankStatementDocument = null;
          break;
        case AddressDocumentType.rentAgreement:
          _rentAgreementDocument = null;
          break;
        case AddressDocumentType.propertyTax:
          _propertyTaxDocument = null;
          break;
        case AddressDocumentType.gasBill:
          _gasBillDocument = null;
          break;
        case AddressDocumentType.telephoneBill:
          _telephoneBillDocument = null;
          break;
      }
    });
  }

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate that at least one document is uploaded
    if (_electricityBillDocument == null && _bankStatementDocument == null && 
        _rentAgreementDocument == null && _propertyTaxDocument == null && 
        _gasBillDocument == null && _telephoneBillDocument == null) {
      _showErrorDialog('Please upload at least one address proof document.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      _showErrorDialog('Failed to save address verification. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
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
                Icons.check_circle,
                color: Colors.green,
                size: ResponsiveUtil.scaledSize(context, 64),
              ),
              SizedBox(height: ResponsiveSpacing.medium(context)),
              Text(
                'KYC Submitted Successfully',
                style: ResponsiveTypography.headlineSmall(context).copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveSpacing.medium(context)),
              Text(
                'Your KYC documents have been submitted successfully. You will be notified once the verification is complete.',
                style: ResponsiveTypography.bodyMedium(context),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveSpacing.large(context)),
              Advanced3DButton(
                text: 'Continue',
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                backgroundColor: SparshTheme.primaryBlue,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
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
            mainSize: MainAxisSize.min,
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
                        title: 'Address Verification',
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
                                      'Address Verification',
                                      style: ResponsiveTypography.headlineMedium(context).copyWith(
                                        color: SparshTheme.primaryBlue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    Text(
                                      'Please provide your address details and supporting documents',
                                      style: ResponsiveTypography.bodyMedium(context).copyWith(
                                        color: SparshTheme.textSecondary,
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveSpacing.xLarge(context)),
                                    
                                    // Address Type Selection
                                    Text(
                                      'Address Type',
                                      style: ResponsiveTypography.titleMedium(context).copyWith(
                                        color: SparshTheme.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildAddressTypeOption('Permanent', Icons.home),
                                        ),
                                        SizedBox(width: ResponsiveSpacing.small(context)),
                                        Expanded(
                                          child: _buildAddressTypeOption('Current', Icons.location_on),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: ResponsiveSpacing.xLarge(context)),
                                    
                                    // Address Details
                                    Text(
                                      'Address Details',
                                      style: ResponsiveTypography.titleMedium(context).copyWith(
                                        color: SparshTheme.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    Advanced3DTextFormField(
                                      controller: _addressLine1Controller,
                                      hintText: 'House/Flat/Building No.',
                                      labelText: 'Address Line 1',
                                      prefixIcon: Icons.home_outlined,
                                      validator: (value) => FormValidators.validateRequired(value, fieldName: 'Address Line 1'),
                                      enableGlassMorphism: true,
                                      enable3DEffect: true,
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    Advanced3DTextFormField(
                                      controller: _addressLine2Controller,
                                      hintText: 'Street/Area/Locality',
                                      labelText: 'Address Line 2',
                                      prefixIcon: Icons.location_on_outlined,
                                      validator: (value) => FormValidators.validateRequired(value, fieldName: 'Address Line 2'),
                                      enableGlassMorphism: true,
                                      enable3DEffect: true,
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    Advanced3DTextFormField(
                                      controller: _landmarkController,
                                      hintText: 'Landmark (Optional)',
                                      labelText: 'Landmark',
                                      prefixIcon: Icons.place_outlined,
                                      enableGlassMorphism: true,
                                      enable3DEffect: true,
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    
                                    // City, State, Pincode
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Advanced3DTextFormField(
                                            controller: _cityController,
                                            hintText: 'City',
                                            labelText: 'City',
                                            prefixIcon: Icons.location_city_outlined,
                                            validator: (value) => FormValidators.validateRequired(value, fieldName: 'City'),
                                            enableGlassMorphism: true,
                                            enable3DEffect: true,
                                          ),
                                        ),
                                        SizedBox(width: ResponsiveSpacing.medium(context)),
                                        Expanded(
                                          child: Advanced3DTextFormField(
                                            controller: _stateController,
                                            hintText: 'State',
                                            labelText: 'State',
                                            prefixIcon: Icons.map_outlined,
                                            validator: (value) => FormValidators.validateRequired(value, fieldName: 'State'),
                                            enableGlassMorphism: true,
                                            enable3DEffect: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Advanced3DTextFormField(
                                            controller: _pincodeController,
                                            hintText: 'Pincode',
                                            labelText: 'Pincode',
                                            prefixIcon: Icons.pin_drop_outlined,
                                            keyboardType: TextInputType.number,
                                            validator: FormValidators.validatePincode,
                                            enableGlassMorphism: true,
                                            enable3DEffect: true,
                                          ),
                                        ),
                                        SizedBox(width: ResponsiveSpacing.medium(context)),
                                        Expanded(
                                          child: Advanced3DTextFormField(
                                            controller: _countryController,
                                            hintText: 'Country',
                                            labelText: 'Country',
                                            prefixIcon: Icons.public_outlined,
                                            validator: (value) => FormValidators.validateRequired(value, fieldName: 'Country'),
                                            enableGlassMorphism: true,
                                            enable3DEffect: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: ResponsiveSpacing.xLarge(context)),
                                    
                                    // Document Upload Section
                                    Text(
                                      'Address Proof Documents',
                                      style: ResponsiveTypography.titleMedium(context).copyWith(
                                        color: SparshTheme.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    Text(
                                      'Please upload any of the following documents as address proof:',
                                      style: ResponsiveTypography.bodyMedium(context).copyWith(
                                        color: SparshTheme.textSecondary,
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveSpacing.large(context)),
                                    
                                    // Electricity Bill
                                    _buildDocumentUpload(
                                      'Electricity Bill',
                                      'Upload recent electricity bill',
                                      AddressDocumentType.electricityBill,
                                      _electricityBillDocument,
                                      Icons.electrical_services,
                                      Colors.orange,
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    
                                    // Bank Statement
                                    _buildDocumentUpload(
                                      'Bank Statement',
                                      'Upload recent bank statement',
                                      AddressDocumentType.bankStatement,
                                      _bankStatementDocument,
                                      Icons.account_balance,
                                      Colors.green,
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    
                                    // Rent Agreement
                                    _buildDocumentUpload(
                                      'Rent Agreement',
                                      'Upload rent agreement',
                                      AddressDocumentType.rentAgreement,
                                      _rentAgreementDocument,
                                      Icons.assignment,
                                      Colors.blue,
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    
                                    // Property Tax
                                    _buildDocumentUpload(
                                      'Property Tax Receipt',
                                      'Upload property tax receipt',
                                      AddressDocumentType.propertyTax,
                                      _propertyTaxDocument,
                                      Icons.receipt_long,
                                      Colors.purple,
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    
                                    // Gas Bill
                                    _buildDocumentUpload(
                                      'Gas Bill',
                                      'Upload recent gas bill',
                                      AddressDocumentType.gasBill,
                                      _gasBillDocument,
                                      Icons.local_gas_station,
                                      Colors.red,
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    
                                    // Telephone Bill
                                    _buildDocumentUpload(
                                      'Telephone Bill',
                                      'Upload recent telephone bill',
                                      AddressDocumentType.telephoneBill,
                                      _telephoneBillDocument,
                                      Icons.phone,
                                      Colors.teal,
                                    ),
                                    SizedBox(height: ResponsiveSpacing.xLarge(context)),
                                    
                                    // Submit Button
                                    Advanced3DButton(
                                      text: 'Submit KYC',
                                      onPressed: _isLoading ? null : _saveAndContinue,
                                      isLoading: _isLoading,
                                      width: double.infinity,
                                      backgroundColor: SparshTheme.primaryBlue,
                                      enableGlassMorphism: true,
                                      enable3DEffect: true,
                                      icon: Icons.verified_user,
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

  Widget _buildAddressTypeOption(String type, IconData icon) {
    bool isSelected = _addressType == type;
    return GestureDetector(
      onTap: () => setState(() => _addressType = type),
      child: Advanced3DCard(
        backgroundColor: isSelected 
            ? SparshTheme.primaryBlue.withOpacity(0.1)
            : SparshTheme.lightGreyBackground,
        borderColor: isSelected 
            ? SparshTheme.primaryBlue
            : SparshTheme.borderGrey,
        borderRadius: 15,
        enableGlassMorphism: false,
        enable3DTransform: true,
        padding: ResponsiveSpacing.paddingMedium(context),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? SparshTheme.primaryBlue
                  : SparshTheme.textSecondary,
              size: ResponsiveUtil.scaledSize(context, 32),
            ),
            SizedBox(height: ResponsiveSpacing.small(context)),
            Text(
              type,
              style: ResponsiveTypography.bodyMedium(context).copyWith(
                color: isSelected 
                    ? SparshTheme.primaryBlue
                    : SparshTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentUpload(String title, String description, AddressDocumentType type, 
      File? document, IconData icon, Color color) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              SizedBox(width: ResponsiveSpacing.small(context)),
              Expanded(
                child: Text(
                  title,
                  style: ResponsiveTypography.titleSmall(context).copyWith(
                    color: SparshTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveSpacing.small(context)),
          if (document != null) ...[
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                SizedBox(width: ResponsiveSpacing.small(context)),
                Expanded(
                  child: Text(
                    'Document uploaded successfully',
                    style: ResponsiveTypography.bodySmall(context).copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _removeDocument(type),
                  icon: Icon(Icons.delete, color: Colors.red, size: 20),
                ),
              ],
            ),
            if (document.path.toLowerCase().endsWith('.pdf')) ...[
              SizedBox(height: ResponsiveSpacing.small(context)),
              Row(
                children: [
                  Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                  SizedBox(width: ResponsiveSpacing.small(context)),
                  Text(
                    'PDF Document',
                    style: ResponsiveTypography.bodySmall(context).copyWith(
                      color: SparshTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(height: ResponsiveSpacing.small(context)),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  document,
                  height: 80,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ] else ...[
            Text(
              description,
              style: ResponsiveTypography.bodySmall(context).copyWith(
                color: SparshTheme.textSecondary,
              ),
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
                    height: 36,
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
                    height: 36,
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

enum AddressDocumentType {
  electricityBill,
  bankStatement,
  rentAgreement,
  propertyTax,
  gasBill,
  telephoneBill,
}