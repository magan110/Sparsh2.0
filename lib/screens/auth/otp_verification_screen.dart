import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:learning2/core/components/advanced_3d/advanced_3d_components.dart';
import 'package:learning2/core/utils/responsive_design.dart';
import 'package:learning2/core/utils/form_validators/form_validators.dart';
import 'package:learning2/core/theme/app_theme.dart';
import 'reset_password_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String purpose; // 'login', 'reset_password', 'registration'
  final String contactInfo;
  final String contactMethod; // 'email' or 'phone'

  const OTPVerificationScreen({
    super.key,
    required this.purpose,
    required this.contactInfo,
    required this.contactMethod,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _canResend = false;
  int _countdown = 60;
  Timer? _timer;

  late AnimationController _animController;
  late AnimationController _pulseController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startCountdown();
  }

  void _setupAnimations() {
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _animController.forward();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _canResend = true;
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    _pulseController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otpValue {
    return _otpControllers.map((controller) => controller.text).join();
  }

  Future<void> _verifyOTP() async {
    if (_otpValue.length != 6) {
      _showErrorDialog('Please enter complete OTP');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        // Navigate based on purpose
        switch (widget.purpose) {
          case 'reset_password':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ResetPasswordScreen(
                  contactInfo: widget.contactInfo,
                  otp: _otpValue,
                ),
              ),
            );
            break;
          case 'registration':
            // Navigate to registration success or next step
            Navigator.pop(context, true);
            break;
          case 'login':
            // Navigate to home screen
            Navigator.pop(context, true);
            break;
        }
      }
    } catch (e) {
      _showErrorDialog('Invalid OTP. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;

    setState(() {
      _countdown = 60;
      _canResend = false;
    });

    // Clear all OTP fields
    for (var controller in _otpControllers) {
      controller.clear();
    }

    // Focus on first field
    _focusNodes[0].requestFocus();

    // Start countdown again
    _startCountdown();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP sent successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
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

  void _onOTPChanged(String value, int index) {
    if (value.length == 1) {
      // Move to next field
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      }
    } else if (value.isEmpty) {
      // Move to previous field
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }

    // Auto-verify when all fields are filled
    if (_otpValue.length == 6) {
      _verifyOTP();
    }
  }

  String _getMaskedContact() {
    if (widget.contactMethod == 'email') {
      final parts = widget.contactInfo.split('@');
      if (parts.length == 2) {
        final username = parts[0];
        final domain = parts[1];
        final maskedUsername = username.length > 2
            ? '${username.substring(0, 2)}${'*' * (username.length - 2)}'
            : username;
        return '$maskedUsername@$domain';
      }
    } else {
      // Phone number
      if (widget.contactInfo.length > 4) {
        return '${widget.contactInfo.substring(0, 2)}${'*' * (widget.contactInfo.length - 4)}${widget.contactInfo.substring(widget.contactInfo.length - 2)}';
      }
    }
    return widget.contactInfo;
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
                                'OTP Verification',
                                style: ResponsiveTypography.headlineSmall(context).copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: ResponsiveSpacing.xxLarge(context)),
                          
                          // Icon
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: GlassMorphismContainer(
                                  borderRadius: 50,
                                  child: Icon(
                                    Icons.security,
                                    size: ResponsiveUtil.scaledSize(context, 80),
                                    color: SparshTheme.primaryBlue,
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          SizedBox(height: ResponsiveSpacing.xLarge(context)),
                          
                          // OTP Form
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
                                children: [
                                  Text(
                                    'Enter Verification Code',
                                    style: ResponsiveTypography.headlineMedium(context).copyWith(
                                      color: SparshTheme.primaryBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: ResponsiveSpacing.medium(context)),
                                  Text(
                                    'We have sent a 6-digit code to\n${_getMaskedContact()}',
                                    style: ResponsiveTypography.bodyMedium(context).copyWith(
                                      color: SparshTheme.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: ResponsiveSpacing.xLarge(context)),
                                  
                                  // OTP Input Fields
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: List.generate(6, (index) {
                                      return SizedBox(
                                        width: ResponsiveUtil.scaledSize(context, 50),
                                        child: Advanced3DTextFormField(
                                          controller: _otpControllers[index],
                                          enableGlassMorphism: true,
                                          enable3DEffect: true,
                                          borderRadius: 12,
                                          keyboardType: TextInputType.number,
                                          textStyle: ResponsiveTypography.headlineSmall(context).copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: SparshTheme.primaryBlue,
                                          ),
                                          onChanged: (value) => _onOTPChanged(value, index),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                            LengthLimitingTextInputFormatter(1),
                                          ],
                                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                        ),
                                      );
                                    }),
                                  ),
                                  
                                  SizedBox(height: ResponsiveSpacing.xLarge(context)),
                                  
                                  // Verify Button
                                  Advanced3DButton(
                                    text: 'Verify OTP',
                                    onPressed: _isLoading ? null : _verifyOTP,
                                    isLoading: _isLoading,
                                    width: double.infinity,
                                    backgroundColor: SparshTheme.primaryBlue,
                                    enableGlassMorphism: true,
                                    enable3DEffect: true,
                                    icon: Icons.verified_user,
                                  ),
                                  
                                  SizedBox(height: ResponsiveSpacing.large(context)),
                                  
                                  // Resend OTP
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Didn't receive the code? ",
                                        style: ResponsiveTypography.bodyMedium(context).copyWith(
                                          color: SparshTheme.textSecondary,
                                        ),
                                      ),
                                      if (_canResend)
                                        TextButton(
                                          onPressed: _resendOTP,
                                          child: Text(
                                            'Resend',
                                            style: ResponsiveTypography.bodyMedium(context).copyWith(
                                              color: SparshTheme.primaryBlue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      else
                                        Text(
                                          'Resend in ${_countdown}s',
                                          style: ResponsiveTypography.bodyMedium(context).copyWith(
                                            color: SparshTheme.textTertiary,
                                          ),
                                        ),
                                    ],
                                  ),
                                  
                                  SizedBox(height: ResponsiveSpacing.medium(context)),
                                  
                                  // Change Method
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      'Change ${widget.contactMethod}',
                                      style: ResponsiveTypography.bodyMedium(context).copyWith(
                                        color: SparshTheme.primaryBlue,
                                        fontWeight: FontWeight.w600,
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

// Start the pulse animation when the screen is displayed
class _PulseAnimation extends StatefulWidget {
  final Widget child;

  const _PulseAnimation({required this.child});

  @override
  _PulseAnimationState createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<_PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}