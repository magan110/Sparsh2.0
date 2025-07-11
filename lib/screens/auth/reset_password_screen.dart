import 'package:flutter/material.dart';
import 'package:learning2/core/components/advanced_3d/advanced_3d_components.dart';
import 'package:learning2/core/utils/responsive_design.dart';
import 'package:learning2/core/utils/form_validators/form_validators.dart';
import 'package:learning2/core/theme/app_theme.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String contactInfo;
  final String otp;

  const ResetPasswordScreen({
    super.key,
    required this.contactInfo,
    required this.otp,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Password strength indicators
  bool _hasMinLength = false;
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasNumbers = false;
  bool _hasSpecialChars = false;

  late AnimationController _animController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _newPasswordController.addListener(_updatePasswordStrength);
  }

  void _setupAnimations() {
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOut,
      ),
    );

    _animController.forward();
  }

  void _updatePasswordStrength() {
    final password = _newPasswordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
      _hasLowerCase = RegExp(r'[a-z]').hasMatch(password);
      _hasNumbers = RegExp(r'[0-9]').hasMatch(password);
      _hasSpecialChars = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    });
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  double get _passwordStrength {
    int count = 0;
    if (_hasMinLength) count++;
    if (_hasUpperCase) count++;
    if (_hasLowerCase) count++;
    if (_hasNumbers) count++;
    if (_hasSpecialChars) count++;
    return count / 5.0;
  }

  Color get _strengthColor {
    if (_passwordStrength <= 0.2) return Colors.red;
    if (_passwordStrength <= 0.4) return Colors.orange;
    if (_passwordStrength <= 0.6) return Colors.yellow;
    if (_passwordStrength <= 0.8) return Colors.lightGreen;
    return Colors.green;
  }

  String get _strengthText {
    if (_passwordStrength <= 0.2) return 'Very Weak';
    if (_passwordStrength <= 0.4) return 'Weak';
    if (_passwordStrength <= 0.6) return 'Fair';
    if (_passwordStrength <= 0.8) return 'Strong';
    return 'Very Strong';
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      _showErrorDialog('Failed to reset password. Please try again.');
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
                'Password Reset Successfully',
                style: ResponsiveTypography.headlineSmall(context).copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveSpacing.medium(context)),
              Text(
                'Your password has been updated successfully. You can now login with your new password.',
                style: ResponsiveTypography.bodyMedium(context),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveSpacing.large(context)),
              Advanced3DButton(
                text: 'Continue to Login',
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
                  child: ResponsiveFormWrapper(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // App Bar
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: ResponsiveUtil.scaledSize(context, 24),
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                              Text(
                                'Reset Password',
                                style: ResponsiveTypography.headlineSmall(context).copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: ResponsiveSpacing.xxLarge(context)),
                          
                          // Icon
                          GlassMorphismContainer(
                            borderRadius: 50,
                            child: Icon(
                              Icons.security,
                              size: ResponsiveUtil.scaledSize(context, 80),
                              color: SparshTheme.primaryBlue,
                            ),
                          ),
                          
                          SizedBox(height: ResponsiveSpacing.xLarge(context)),
                          
                          // Reset Form
                          Advanced3DCard(
                            backgroundColor: Colors.white,
                            borderRadius: 25,
                            enableGlassMorphism: true,
                            enable3DTransform: true,
                            enableHoverEffect: false,
                            padding: ResponsiveSpacing.paddingLarge(context),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Create New Password',
                                    style: ResponsiveTypography.headlineMedium(context).copyWith(
                                      color: SparshTheme.primaryBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: ResponsiveSpacing.medium(context)),
                                  Text(
                                    'Your new password must be different from previously used passwords.',
                                    style: ResponsiveTypography.bodyMedium(context).copyWith(
                                      color: SparshTheme.textSecondary,
                                    ),
                                  ),
                                  SizedBox(height: ResponsiveSpacing.xLarge(context)),
                                  
                                  // New Password Field
                                  Advanced3DTextFormField(
                                    controller: _newPasswordController,
                                    hintText: 'Enter new password',
                                    labelText: 'New Password',
                                    prefixIcon: Icons.lock_outline,
                                    obscureText: _obscureNewPassword,
                                    validator: FormValidators.validatePassword,
                                    enableGlassMorphism: true,
                                    enable3DEffect: true,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureNewPassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: SparshTheme.textSecondary,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureNewPassword = !_obscureNewPassword;
                                        });
                                      },
                                    ),
                                  ),
                                  
                                  SizedBox(height: ResponsiveSpacing.medium(context)),
                                  
                                  // Password Strength Indicator
                                  if (_newPasswordController.text.isNotEmpty) ...[
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Password Strength: ',
                                              style: ResponsiveTypography.bodySmall(context).copyWith(
                                                color: SparshTheme.textSecondary,
                                              ),
                                            ),
                                            Text(
                                              _strengthText,
                                              style: ResponsiveTypography.bodySmall(context).copyWith(
                                                color: _strengthColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: ResponsiveSpacing.small(context)),
                                        LinearProgressIndicator(
                                          value: _passwordStrength,
                                          backgroundColor: Colors.grey.shade300,
                                          valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                                        ),
                                        SizedBox(height: ResponsiveSpacing.medium(context)),
                                        
                                        // Password Requirements
                                        Wrap(
                                          spacing: ResponsiveSpacing.small(context),
                                          runSpacing: ResponsiveSpacing.small(context),
                                          children: [
                                            _buildRequirementChip('8+ characters', _hasMinLength),
                                            _buildRequirementChip('Uppercase', _hasUpperCase),
                                            _buildRequirementChip('Lowercase', _hasLowerCase),
                                            _buildRequirementChip('Numbers', _hasNumbers),
                                            _buildRequirementChip('Special chars', _hasSpecialChars),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: ResponsiveSpacing.large(context)),
                                  ],
                                  
                                  // Confirm Password Field
                                  Advanced3DTextFormField(
                                    controller: _confirmPasswordController,
                                    hintText: 'Confirm new password',
                                    labelText: 'Confirm Password',
                                    prefixIcon: Icons.lock_outline,
                                    obscureText: _obscureConfirmPassword,
                                    validator: (value) => FormValidators.validateConfirmPassword(
                                      value,
                                      _newPasswordController.text,
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
                                  
                                  // Reset Button
                                  Advanced3DButton(
                                    text: 'Reset Password',
                                    onPressed: _isLoading ? null : _resetPassword,
                                    isLoading: _isLoading,
                                    width: double.infinity,
                                    backgroundColor: SparshTheme.primaryBlue,
                                    enableGlassMorphism: true,
                                    enable3DEffect: true,
                                    icon: Icons.security,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          SizedBox(height: ResponsiveSpacing.xxLarge(context)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementChip(String label, bool isValid) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveSpacing.small(context),
        vertical: ResponsiveSpacing.small(context) / 2,
      ),
      decoration: BoxDecoration(
        color: isValid ? Colors.green.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isValid ? Colors.green : Colors.grey,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.circle_outlined,
            color: isValid ? Colors.green : Colors.grey,
            size: ResponsiveUtil.scaledSize(context, 16),
          ),
          SizedBox(width: ResponsiveSpacing.small(context) / 2),
          Text(
            label,
            style: ResponsiveTypography.bodySmall(context).copyWith(
              color: isValid ? Colors.green : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}