import 'package:flutter/material.dart';
import 'package:learning2/core/components/advanced_3d/advanced_3d_components.dart';
import 'package:learning2/core/utils/responsive_design.dart';
import 'package:learning2/core/utils/form_validators/form_validators.dart';
import 'package:learning2/core/theme/app_theme.dart';
import 'identity_verification_form.dart';

class PersonalInfoForm extends StatefulWidget {
  const PersonalInfoForm({super.key});

  @override
  State<PersonalInfoForm> createState() => _PersonalInfoFormState();
}

class _PersonalInfoFormState extends State<PersonalInfoForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _placeOfBirthController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _spouseNameController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _annualIncomeController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedMaritalStatus = 'Single';
  String _selectedReligion = 'Hindu';
  String _selectedCategory = 'General';
  String _selectedNationality = 'Indian';

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
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();
    _placeOfBirthController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _spouseNameController.dispose();
    _occupationController.dispose();
    _annualIncomeController.dispose();
    _educationController.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const IdentityVerificationForm(),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Failed to save personal information. Please try again.');
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
                        title: 'Personal Information',
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
                                      'Personal Information',
                                      style: ResponsiveTypography.headlineMedium(context).copyWith(
                                        color: SparshTheme.primaryBlue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    Text(
                                      'Please provide your accurate personal details for KYC verification',
                                      style: ResponsiveTypography.bodyMedium(context).copyWith(
                                        color: SparshTheme.textSecondary,
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveSpacing.xLarge(context)),
                                    
                                    // Name Fields
                                    Text(
                                      'Full Name',
                                      style: ResponsiveTypography.titleMedium(context).copyWith(
                                        color: SparshTheme.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    Advanced3DTextFormField(
                                      controller: _firstNameController,
                                      hintText: 'First Name',
                                      labelText: 'First Name',
                                      prefixIcon: Icons.person_outline,
                                      validator: (value) => FormValidators.validateRequired(value, fieldName: 'First Name'),
                                      enableGlassMorphism: true,
                                      enable3DEffect: true,
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    Advanced3DTextFormField(
                                      controller: _middleNameController,
                                      hintText: 'Middle Name (Optional)',
                                      labelText: 'Middle Name',
                                      prefixIcon: Icons.person_outline,
                                      enableGlassMorphism: true,
                                      enable3DEffect: true,
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    Advanced3DTextFormField(
                                      controller: _lastNameController,
                                      hintText: 'Last Name',
                                      labelText: 'Last Name',
                                      prefixIcon: Icons.person_outline,
                                      validator: (value) => FormValidators.validateRequired(value, fieldName: 'Last Name'),
                                      enableGlassMorphism: true,
                                      enable3DEffect: true,
                                    ),
                                    SizedBox(height: ResponsiveSpacing.xLarge(context)),
                                    
                                    // Personal Details
                                    Text(
                                      'Personal Details',
                                      style: ResponsiveTypography.titleMedium(context).copyWith(
                                        color: SparshTheme.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    Advanced3DTextFormField(
                                      controller: _dateOfBirthController,
                                      hintText: 'Date of Birth',
                                      labelText: 'Date of Birth',
                                      prefixIcon: Icons.calendar_today_outlined,
                                      validator: (value) => FormValidators.validateRequired(value, fieldName: 'Date of Birth'),
                                      enableGlassMorphism: true,
                                      enable3DEffect: true,
                                      suffixIcon: IconButton(
                                        icon: Icon(Icons.calendar_month, color: SparshTheme.textSecondary),
                                        onPressed: () async {
                                          final date = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now().subtract(const Duration(days: 6570)),
                                            firstDate: DateTime.now().subtract(const Duration(days: 36500)),
                                            lastDate: DateTime.now().subtract(const Duration(days: 6570)),
                                          );
                                          if (date != null) {
                                            _dateOfBirthController.text = '${date.day}/${date.month}/${date.year}';
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    Advanced3DTextFormField(
                                      controller: _placeOfBirthController,
                                      hintText: 'Place of Birth',
                                      labelText: 'Place of Birth',
                                      prefixIcon: Icons.place_outlined,
                                      validator: (value) => FormValidators.validateRequired(value, fieldName: 'Place of Birth'),
                                      enableGlassMorphism: true,
                                      enable3DEffect: true,
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    
                                    // Gender Selection
                                    Text(
                                      'Gender',
                                      style: ResponsiveTypography.bodyMedium(context).copyWith(
                                        color: SparshTheme.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveSpacing.small(context)),
                                    _buildSelectionRow([
                                      _buildSelectionOption('Male', Icons.male, _selectedGender == 'Male', 
                                          () => setState(() => _selectedGender = 'Male')),
                                      _buildSelectionOption('Female', Icons.female, _selectedGender == 'Female', 
                                          () => setState(() => _selectedGender = 'Female')),
                                      _buildSelectionOption('Other', Icons.transgender, _selectedGender == 'Other', 
                                          () => setState(() => _selectedGender = 'Other')),
                                    ]),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    
                                    // Marital Status
                                    Text(
                                      'Marital Status',
                                      style: ResponsiveTypography.bodyMedium(context).copyWith(
                                        color: SparshTheme.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveSpacing.small(context)),
                                    _buildSelectionRow([
                                      _buildSelectionOption('Single', Icons.person, _selectedMaritalStatus == 'Single', 
                                          () => setState(() => _selectedMaritalStatus = 'Single')),
                                      _buildSelectionOption('Married', Icons.people, _selectedMaritalStatus == 'Married', 
                                          () => setState(() => _selectedMaritalStatus = 'Married')),
                                      _buildSelectionOption('Divorced', Icons.person_remove, _selectedMaritalStatus == 'Divorced', 
                                          () => setState(() => _selectedMaritalStatus = 'Divorced')),
                                    ]),
                                    SizedBox(height: ResponsiveSpacing.xLarge(context)),
                                    
                                    // Family Details
                                    Text(
                                      'Family Details',
                                      style: ResponsiveTypography.titleMedium(context).copyWith(
                                        color: SparshTheme.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    Advanced3DTextFormField(
                                      controller: _fatherNameController,
                                      hintText: 'Father\'s Name',
                                      labelText: 'Father\'s Name',
                                      prefixIcon: Icons.person_outline,
                                      validator: (value) => FormValidators.validateRequired(value, fieldName: 'Father\'s Name'),
                                      enableGlassMorphism: true,
                                      enable3DEffect: true,
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    Advanced3DTextFormField(
                                      controller: _motherNameController,
                                      hintText: 'Mother\'s Name',
                                      labelText: 'Mother\'s Name',
                                      prefixIcon: Icons.person_outline,
                                      validator: (value) => FormValidators.validateRequired(value, fieldName: 'Mother\'s Name'),
                                      enableGlassMorphism: true,
                                      enable3DEffect: true,
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    if (_selectedMaritalStatus == 'Married')
                                      Advanced3DTextFormField(
                                        controller: _spouseNameController,
                                        hintText: 'Spouse\'s Name',
                                        labelText: 'Spouse\'s Name',
                                        prefixIcon: Icons.person_outline,
                                        validator: (value) => FormValidators.validateRequired(value, fieldName: 'Spouse\'s Name'),
                                        enableGlassMorphism: true,
                                        enable3DEffect: true,
                                      ),
                                    SizedBox(height: ResponsiveSpacing.xLarge(context)),
                                    
                                    // Professional Details
                                    Text(
                                      'Professional Details',
                                      style: ResponsiveTypography.titleMedium(context).copyWith(
                                        color: SparshTheme.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    Advanced3DTextFormField(
                                      controller: _occupationController,
                                      hintText: 'Occupation',
                                      labelText: 'Occupation',
                                      prefixIcon: Icons.work_outline,
                                      validator: (value) => FormValidators.validateRequired(value, fieldName: 'Occupation'),
                                      enableGlassMorphism: true,
                                      enable3DEffect: true,
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    Advanced3DTextFormField(
                                      controller: _annualIncomeController,
                                      hintText: 'Annual Income',
                                      labelText: 'Annual Income',
                                      prefixIcon: Icons.currency_rupee,
                                      keyboardType: TextInputType.number,
                                      validator: FormValidators.validatePositiveNumber,
                                      enableGlassMorphism: true,
                                      enable3DEffect: true,
                                    ),
                                    SizedBox(height: ResponsiveSpacing.medium(context)),
                                    Advanced3DTextFormField(
                                      controller: _educationController,
                                      hintText: 'Education Qualification',
                                      labelText: 'Education',
                                      prefixIcon: Icons.school_outlined,
                                      validator: (value) => FormValidators.validateRequired(value, fieldName: 'Education'),
                                      enableGlassMorphism: true,
                                      enable3DEffect: true,
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

  Widget _buildSelectionRow(List<Widget> options) {
    return Row(
      children: options.map((option) {
        int index = options.indexOf(option);
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: index < options.length - 1 ? ResponsiveSpacing.small(context) : 0,
            ),
            child: option,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSelectionOption(String text, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Advanced3DCard(
        backgroundColor: isSelected 
            ? SparshTheme.primaryBlue.withOpacity(0.1)
            : SparshTheme.lightGreyBackground,
        borderColor: isSelected 
            ? SparshTheme.primaryBlue
            : SparshTheme.borderGrey,
        borderRadius: 12,
        enableGlassMorphism: false,
        enable3DTransform: true,
        padding: ResponsiveSpacing.paddingSmall(context),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? SparshTheme.primaryBlue
                  : SparshTheme.textSecondary,
              size: ResponsiveUtil.scaledSize(context, 24),
            ),
            SizedBox(height: ResponsiveSpacing.small(context) / 2),
            Text(
              text,
              style: ResponsiveTypography.bodySmall(context).copyWith(
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
}