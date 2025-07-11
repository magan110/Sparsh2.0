import 'package:flutter/material.dart';
import 'package:learning2/core/components/advanced_3d/advanced_3d_components.dart';
import 'package:learning2/core/utils/responsive_design.dart';
import 'package:learning2/core/utils/form_validators/form_validators.dart';
import 'package:learning2/core/theme/app_theme.dart';
import 'otp_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _resetMethod = 'email'; // 'email' or 'phone'

  late AnimationController _animController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
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

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _sendResetCode() async {
    if (!_formKey.currentState!.validate()) return;

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
              purpose: 'reset_password',
              contactInfo: _resetMethod == 'email' 
                  ? _emailController.text.trim()
                  : _phoneController.text.trim(),
              contactMethod: _resetMethod,
            ),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Failed to send reset code. Please try again.');
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
                                'Forgot Password',
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
                              Icons.lock_reset,
                              size: ResponsiveUtil.scaledSize(context, 80),
                              color: SparshTheme.primaryBlue,
                            ),
                          ),
                          
                          SizedBox(height: ResponsiveSpacing.xLarge(context)),
                          
                          // Title and Description
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
                                    'Reset Password',
                                    style: ResponsiveTypography.headlineMedium(context).copyWith(
                                      color: SparshTheme.primaryBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: ResponsiveSpacing.medium(context)),
                                  Text(
                                    'Choose how you want to receive your password reset code',
                                    style: ResponsiveTypography.bodyMedium(context).copyWith(
                                      color: SparshTheme.textSecondary,
                                    ),
                                  ),
                                  SizedBox(height: ResponsiveSpacing.xLarge(context)),
                                  
                                  // Reset Method Selection
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _resetMethod = 'email';
                                            });
                                          },
                                          child: Advanced3DCard(
                                            backgroundColor: _resetMethod == 'email' 
                                                ? SparshTheme.primaryBlue.withOpacity(0.1)
                                                : SparshTheme.lightGreyBackground,
                                            borderColor: _resetMethod == 'email' 
                                                ? SparshTheme.primaryBlue
                                                : SparshTheme.borderGrey,
                                            borderRadius: 15,
                                            enableGlassMorphism: false,
                                            enable3DTransform: true,
                                            padding: ResponsiveSpacing.paddingMedium(context),
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.email_outlined,
                                                  color: _resetMethod == 'email' 
                                                      ? SparshTheme.primaryBlue
                                                      : SparshTheme.textSecondary,
                                                  size: ResponsiveUtil.scaledSize(context, 32),
                                                ),
                                                SizedBox(height: ResponsiveSpacing.small(context)),
                                                Text(
                                                  'Email',
                                                  style: ResponsiveTypography.bodyMedium(context).copyWith(
                                                    color: _resetMethod == 'email' 
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
                                          onTap: () {
                                            setState(() {
                                              _resetMethod = 'phone';
                                            });
                                          },
                                          child: Advanced3DCard(
                                            backgroundColor: _resetMethod == 'phone' 
                                                ? SparshTheme.primaryBlue.withOpacity(0.1)
                                                : SparshTheme.lightGreyBackground,
                                            borderColor: _resetMethod == 'phone' 
                                                ? SparshTheme.primaryBlue
                                                : SparshTheme.borderGrey,
                                            borderRadius: 15,
                                            enableGlassMorphism: false,
                                            enable3DTransform: true,
                                            padding: ResponsiveSpacing.paddingMedium(context),
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.phone_android,
                                                  color: _resetMethod == 'phone' 
                                                      ? SparshTheme.primaryBlue
                                                      : SparshTheme.textSecondary,
                                                  size: ResponsiveUtil.scaledSize(context, 32),
                                                ),
                                                SizedBox(height: ResponsiveSpacing.small(context)),
                                                Text(
                                                  'Phone',
                                                  style: ResponsiveTypography.bodyMedium(context).copyWith(
                                                    color: _resetMethod == 'phone' 
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
                                  
                                  SizedBox(height: ResponsiveSpacing.xLarge(context)),
                                  
                                  // Input Field
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: _resetMethod == 'email'
                                        ? Advanced3DTextFormField(
                                            key: const Key('email'),
                                            controller: _emailController,
                                            hintText: 'Enter your email address',
                                            labelText: 'Email Address',
                                            prefixIcon: Icons.email_outlined,
                                            keyboardType: TextInputType.emailAddress,
                                            validator: FormValidators.validateEmail,
                                            enableGlassMorphism: true,
                                            enable3DEffect: true,
                                          )
                                        : Advanced3DTextFormField(
                                            key: const Key('phone'),
                                            controller: _phoneController,
                                            hintText: 'Enter your phone number',
                                            labelText: 'Phone Number',
                                            prefixIcon: Icons.phone_android,
                                            keyboardType: TextInputType.phone,
                                            validator: FormValidators.validatePhoneNumber,
                                            enableGlassMorphism: true,
                                            enable3DEffect: true,
                                          ),
                                  ),
                                  
                                  SizedBox(height: ResponsiveSpacing.xLarge(context)),
                                  
                                  // Send Button
                                  Advanced3DButton(
                                    text: 'Send Reset Code',
                                    onPressed: _isLoading ? null : _sendResetCode,
                                    isLoading: _isLoading,
                                    width: double.infinity,
                                    backgroundColor: SparshTheme.primaryBlue,
                                    enableGlassMorphism: true,
                                    enable3DEffect: true,
                                    icon: _resetMethod == 'email' 
                                        ? Icons.email_outlined
                                        : Icons.sms_outlined,
                                  ),
                                  
                                  SizedBox(height: ResponsiveSpacing.large(context)),
                                  
                                  // Back to Login
                                  Center(
                                    child: TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        'Back to Login',
                                        style: ResponsiveTypography.bodyMedium(context).copyWith(
                                          color: SparshTheme.primaryBlue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
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
}