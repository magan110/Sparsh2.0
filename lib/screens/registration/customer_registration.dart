import 'package:flutter/material.dart';
import 'package:learning2/core/components/advanced_3d/advanced_3d_components.dart';
import 'package:learning2/core/utils/responsive_design.dart';
import 'package:learning2/core/utils/form_validators/form_validators.dart';
import 'package:learning2/core/theme/app_theme.dart';
import '../auth/otp_verification_screen.dart';

class CustomerRegistrationScreen extends StatefulWidget {
  const CustomerRegistrationScreen({super.key});

  @override
  State<CustomerRegistrationScreen> createState() => _CustomerRegistrationScreenState();
}

class _CustomerRegistrationScreenState extends State<CustomerRegistrationScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final _formKeys = List.generate(3, (index) => GlobalKey<FormState>());
  int _currentStep = 0;
  bool _isLoading = false;

  // Personal Information Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  String _selectedGender = 'Male';

  // Address Information Controllers
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  // Account Information Controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  late AnimationController _animController;
  late AnimationController _progressController;
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
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    _progressController.dispose();
    
    // Dispose all controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _countryController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    
    super.dispose();
  }

  Future<void> _nextStep() async {
    if (_currentStep < 2) {
      if (_formKeys[_currentStep].currentState!.validate()) {
        setState(() => _currentStep++);
        await _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _progressController.forward();
      }
    } else {
      _submitRegistration();
    }
  }

  Future<void> _previousStep() async {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      await _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _progressController.reverse();
    }
  }

  Future<void> _submitRegistration() async {
    if (!_formKeys[_currentStep].currentState!.validate()) return;
    if (!_agreeToTerms) {
      _showErrorDialog('Please agree to the terms and conditions');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        // Navigate to OTP verification
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(
              purpose: 'registration',
              contactInfo: _phoneController.text.trim(),
              contactMethod: 'phone',
            ),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Registration failed. Please try again.');
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
                        title: 'Customer Registration',
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
                      
                      // Progress Indicator
                      Container(
                        padding: ResponsiveSpacing.paddingMedium(context),
                        child: Row(
                          children: List.generate(3, (index) {
                            bool isActive = index <= _currentStep;
                            return Expanded(
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: ResponsiveSpacing.small(context),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: ResponsiveUtil.scaledSize(context, 40),
                                      height: ResponsiveUtil.scaledSize(context, 40),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isActive 
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.3),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: ResponsiveTypography.bodyMedium(context).copyWith(
                                            color: isActive 
                                                ? SparshTheme.primaryBlue
                                                : Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveSpacing.small(context)),
                                    Text(
                                      _getStepTitle(index),
                                      style: ResponsiveTypography.bodySmall(context).copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      
                      // Form Content
                      Expanded(
                        child: ResponsiveFormWrapper(
                          child: PageView(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _buildPersonalInfoStep(),
                              _buildAddressInfoStep(),
                              _buildAccountInfoStep(),
                            ],
                          ),
                        ),
                      ),
                      
                      // Navigation Buttons
                      Container(
                        padding: ResponsiveSpacing.paddingMedium(context),
                        child: Row(
                          children: [
                            if (_currentStep > 0)
                              Expanded(
                                child: Advanced3DButton(
                                  text: 'Previous',
                                  onPressed: _previousStep,
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  borderColor: Colors.white,
                                  enableGlassMorphism: false,
                                  icon: Icons.arrow_back,
                                ),
                              ),
                            if (_currentStep > 0)
                              SizedBox(width: ResponsiveSpacing.medium(context)),
                            Expanded(
                              child: Advanced3DButton(
                                text: _currentStep == 2 ? 'Register' : 'Next',
                                onPressed: _isLoading ? null : _nextStep,
                                isLoading: _isLoading,
                                backgroundColor: Colors.white,
                                foregroundColor: SparshTheme.primaryBlue,
                                enableGlassMorphism: true,
                                icon: _currentStep == 2 ? Icons.person_add : Icons.arrow_forward,
                              ),
                            ),
                          ],
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

  String _getStepTitle(int index) {
    switch (index) {
      case 0:
        return 'Personal Info';
      case 1:
        return 'Address Info';
      case 2:
        return 'Account Info';
      default:
        return '';
    }
  }

  Widget _buildPersonalInfoStep() {
    return Advanced3DCard(
      backgroundColor: Colors.white,
      borderRadius: 25,
      enableGlassMorphism: true,
      enable3DTransform: true,
      enableHoverEffect: false,
      padding: ResponsiveSpacing.paddingLarge(context),
      child: Form(
        key: _formKeys[0],
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Information',
                style: ResponsiveTypography.headlineMedium(context).copyWith(
                  color: SparshTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ResponsiveSpacing.medium(context)),
              Text(
                'Please provide your personal details',
                style: ResponsiveTypography.bodyMedium(context).copyWith(
                  color: SparshTheme.textSecondary,
                ),
              ),
              SizedBox(height: ResponsiveSpacing.xLarge(context)),
              
              // Name Fields
              Row(
                children: [
                  Expanded(
                    child: Advanced3DTextFormField(
                      controller: _firstNameController,
                      hintText: 'First Name',
                      labelText: 'First Name',
                      prefixIcon: Icons.person_outline,
                      validator: (value) => FormValidators.validateRequired(value, fieldName: 'First Name'),
                      enableGlassMorphism: true,
                      enable3DEffect: true,
                    ),
                  ),
                  SizedBox(width: ResponsiveSpacing.medium(context)),
                  Expanded(
                    child: Advanced3DTextFormField(
                      controller: _lastNameController,
                      hintText: 'Last Name',
                      labelText: 'Last Name',
                      prefixIcon: Icons.person_outline,
                      validator: (value) => FormValidators.validateRequired(value, fieldName: 'Last Name'),
                      enableGlassMorphism: true,
                      enable3DEffect: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveSpacing.large(context)),
              
              // Email Field
              Advanced3DTextFormField(
                controller: _emailController,
                hintText: 'Email Address',
                labelText: 'Email Address',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: FormValidators.validateEmail,
                enableGlassMorphism: true,
                enable3DEffect: true,
              ),
              SizedBox(height: ResponsiveSpacing.large(context)),
              
              // Phone Field
              Advanced3DTextFormField(
                controller: _phoneController,
                hintText: 'Phone Number',
                labelText: 'Phone Number',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: FormValidators.validatePhoneNumber,
                enableGlassMorphism: true,
                enable3DEffect: true,
              ),
              SizedBox(height: ResponsiveSpacing.large(context)),
              
              // Date of Birth Field
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
                      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
                      firstDate: DateTime.now().subtract(const Duration(days: 36500)), // 100 years ago
                      lastDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
                    );
                    if (date != null) {
                      _dateOfBirthController.text = '${date.day}/${date.month}/${date.year}';
                    }
                  },
                ),
              ),
              SizedBox(height: ResponsiveSpacing.large(context)),
              
              // Gender Selection
              Text(
                'Gender',
                style: ResponsiveTypography.titleMedium(context).copyWith(
                  color: SparshTheme.textPrimary,
                ),
              ),
              SizedBox(height: ResponsiveSpacing.medium(context)),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedGender = 'Male'),
                      child: Advanced3DCard(
                        backgroundColor: _selectedGender == 'Male' 
                            ? SparshTheme.primaryBlue.withOpacity(0.1)
                            : SparshTheme.lightGreyBackground,
                        borderColor: _selectedGender == 'Male' 
                            ? SparshTheme.primaryBlue
                            : SparshTheme.borderGrey,
                        borderRadius: 15,
                        enableGlassMorphism: false,
                        enable3DTransform: true,
                        padding: ResponsiveSpacing.paddingMedium(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.male,
                              color: _selectedGender == 'Male' 
                                  ? SparshTheme.primaryBlue
                                  : SparshTheme.textSecondary,
                            ),
                            SizedBox(width: ResponsiveSpacing.small(context)),
                            Text(
                              'Male',
                              style: ResponsiveTypography.bodyMedium(context).copyWith(
                                color: _selectedGender == 'Male' 
                                    ? SparshTheme.primaryBlue
                                    : SparshTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveSpacing.medium(context)),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedGender = 'Female'),
                      child: Advanced3DCard(
                        backgroundColor: _selectedGender == 'Female' 
                            ? SparshTheme.primaryBlue.withOpacity(0.1)
                            : SparshTheme.lightGreyBackground,
                        borderColor: _selectedGender == 'Female' 
                            ? SparshTheme.primaryBlue
                            : SparshTheme.borderGrey,
                        borderRadius: 15,
                        enableGlassMorphism: false,
                        enable3DTransform: true,
                        padding: ResponsiveSpacing.paddingMedium(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.female,
                              color: _selectedGender == 'Female' 
                                  ? SparshTheme.primaryBlue
                                  : SparshTheme.textSecondary,
                            ),
                            SizedBox(width: ResponsiveSpacing.small(context)),
                            Text(
                              'Female',
                              style: ResponsiveTypography.bodyMedium(context).copyWith(
                                color: _selectedGender == 'Female' 
                                    ? SparshTheme.primaryBlue
                                    : SparshTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildAddressInfoStep() {
    return Advanced3DCard(
      backgroundColor: Colors.white,
      borderRadius: 25,
      enableGlassMorphism: true,
      enable3DTransform: true,
      enableHoverEffect: false,
      padding: ResponsiveSpacing.paddingLarge(context),
      child: Form(
        key: _formKeys[1],
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Address Information',
                style: ResponsiveTypography.headlineMedium(context).copyWith(
                  color: SparshTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ResponsiveSpacing.medium(context)),
              Text(
                'Please provide your address details',
                style: ResponsiveTypography.bodyMedium(context).copyWith(
                  color: SparshTheme.textSecondary,
                ),
              ),
              SizedBox(height: ResponsiveSpacing.xLarge(context)),
              
              // Address Line 1
              Advanced3DTextFormField(
                controller: _addressLine1Controller,
                hintText: 'Address Line 1',
                labelText: 'Address Line 1',
                prefixIcon: Icons.home_outlined,
                validator: (value) => FormValidators.validateRequired(value, fieldName: 'Address Line 1'),
                enableGlassMorphism: true,
                enable3DEffect: true,
              ),
              SizedBox(height: ResponsiveSpacing.large(context)),
              
              // Address Line 2
              Advanced3DTextFormField(
                controller: _addressLine2Controller,
                hintText: 'Address Line 2 (Optional)',
                labelText: 'Address Line 2',
                prefixIcon: Icons.home_outlined,
                enableGlassMorphism: true,
                enable3DEffect: true,
              ),
              SizedBox(height: ResponsiveSpacing.large(context)),
              
              // City and State
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
              SizedBox(height: ResponsiveSpacing.large(context)),
              
              // Pincode and Country
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountInfoStep() {
    return Advanced3DCard(
      backgroundColor: Colors.white,
      borderRadius: 25,
      enableGlassMorphism: true,
      enable3DTransform: true,
      enableHoverEffect: false,
      padding: ResponsiveSpacing.paddingLarge(context),
      child: Form(
        key: _formKeys[2],
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account Information',
                style: ResponsiveTypography.headlineMedium(context).copyWith(
                  color: SparshTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ResponsiveSpacing.medium(context)),
              Text(
                'Create your account credentials',
                style: ResponsiveTypography.bodyMedium(context).copyWith(
                  color: SparshTheme.textSecondary,
                ),
              ),
              SizedBox(height: ResponsiveSpacing.xLarge(context)),
              
              // Username Field
              Advanced3DTextFormField(
                controller: _usernameController,
                hintText: 'Username',
                labelText: 'Username',
                prefixIcon: Icons.account_circle_outlined,
                validator: FormValidators.validateUsername,
                enableGlassMorphism: true,
                enable3DEffect: true,
              ),
              SizedBox(height: ResponsiveSpacing.large(context)),
              
              // Password Field
              Advanced3DTextFormField(
                controller: _passwordController,
                hintText: 'Password',
                labelText: 'Password',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscurePassword,
                validator: FormValidators.validatePassword,
                enableGlassMorphism: true,
                enable3DEffect: true,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: SparshTheme.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              SizedBox(height: ResponsiveSpacing.large(context)),
              
              // Confirm Password Field
              Advanced3DTextFormField(
                controller: _confirmPasswordController,
                hintText: 'Confirm Password',
                labelText: 'Confirm Password',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscureConfirmPassword,
                validator: (value) => FormValidators.validateConfirmPassword(
                  value,
                  _passwordController.text,
                ),
                enableGlassMorphism: true,
                enable3DEffect: true,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: SparshTheme.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              SizedBox(height: ResponsiveSpacing.xLarge(context)),
              
              // Terms and Conditions
              GestureDetector(
                onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: ResponsiveUtil.scaledSize(context, 24),
                      height: ResponsiveUtil.scaledSize(context, 24),
                      decoration: BoxDecoration(
                        color: _agreeToTerms ? SparshTheme.primaryBlue : Colors.transparent,
                        border: Border.all(
                          color: _agreeToTerms ? SparshTheme.primaryBlue : SparshTheme.borderGrey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: _agreeToTerms
                          ? Icon(
                              Icons.check,
                              color: Colors.white,
                              size: ResponsiveUtil.scaledSize(context, 16),
                            )
                          : null,
                    ),
                    SizedBox(width: ResponsiveSpacing.medium(context)),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: 'I agree to the ',
                          style: ResponsiveTypography.bodyMedium(context).copyWith(
                            color: SparshTheme.textSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: 'Terms and Conditions',
                              style: ResponsiveTypography.bodyMedium(context).copyWith(
                                color: SparshTheme.primaryBlue,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(
                              text: ' and ',
                              style: ResponsiveTypography.bodyMedium(context).copyWith(
                                color: SparshTheme.textSecondary,
                              ),
                            ),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: ResponsiveTypography.bodyMedium(context).copyWith(
                                color: SparshTheme.primaryBlue,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}