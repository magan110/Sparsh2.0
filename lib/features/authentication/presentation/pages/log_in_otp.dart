import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learning2/features/dashboard/presentation/pages/home_screen.dart';
import 'package:learning2/core/constants/fonts.dart';
import 'package:learning2/core/components/advanced_3d/advanced_3d_components.dart';
import 'package:learning2/core/utils/responsive_design.dart';
import 'package:learning2/core/utils/form_validators/form_validators.dart';
import 'package:learning2/core/theme/app_theme.dart';
// Although not used in this specific screen, keeping if needed elsewhere

class LogInOtp extends StatefulWidget {
  const LogInOtp({super.key});

  @override
  State<LogInOtp> createState() => _LogInOtpState();
}

class _LogInOtpState extends State<LogInOtp>
    with SingleTickerProviderStateMixin {
  // Controllers for text fields
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isOtpSent = false;
  String _verificationId = '';

  // Global key for the form for potential validation later
  final _formKey = GlobalKey<FormState>();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _resendTimer = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed
    _phoneController.dispose();
    _otpController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Helper method to show a simple dialog (e.g., for success or error)
  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              title,
              style: Fonts.bodyBold.copyWith(fontSize: 16),
            ),
            content: Text(
              message,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _startResendTimer() {
    setState(() {
      _resendTimer = 30;
      _canResend = false;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (_resendTimer > 0) {
            _resendTimer--;
            _startResendTimer();
          } else {
            _canResend = true;
          }
        });
      }
    });
  }

  // Send OTP
  Future<void> sendOTP() async {
    if (_phoneController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter phone number");
      return;
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+91${_phoneController.text}', // Add your country code
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification if possible
          await _auth.signInWithCredential(credential);
          _handleSuccessfulLogin();
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage = 'Verification failed';
          if (e.code == 'invalid-phone-number') {
            errorMessage = 'Invalid phone number';
          }
          Fluttertoast.showToast(msg: errorMessage);
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _isOtpSent = true;
            _verificationId = verificationId;
          });
          Fluttertoast.showToast(msg: "OTP sent successfully!");
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to send OTP");
    }
  }

  // Verify OTP
  Future<void> verifyOTP() async {
    if (_otpController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter OTP");
      return;
    }

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text,
      );

      await _auth.signInWithCredential(credential);
      _handleSuccessfulLogin();
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Invalid OTP';
      if (e.code == 'invalid-verification-code') {
        errorMessage = 'Invalid verification code';
      }
      Fluttertoast.showToast(msg: errorMessage);
    } catch (e) {
      Fluttertoast.showToast(msg: "Verification failed");
    }
  }

  Future<void> _handleSuccessfulLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: SparshTheme.scaffoldBackground,
        appBar: Advanced3DAppBar(
          title: 'OTP Verification',
          centerTitle: true,
          backgroundColor: SparshTheme.primaryBlue,
          elevation: 8,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: ResponsiveSpacing.all(context, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Advanced3DCard(
                        width: ResponsiveUtil.getScreenWidth(context),
                        padding: ResponsiveSpacing.all(context, 24),
                        borderRadius: 20,
                        enableGlassMorphism: true,
                        backgroundColor: SparshTheme.primaryBlue,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.security,
                                  size: 32,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'OTP Verification',
                                        style: TextStyle(
                                          fontSize: ResponsiveTypography.headingLarge(context),
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'Secure authentication',
                                        style: TextStyle(
                                          fontSize: ResponsiveTypography.bodyText1(context),
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: ResponsiveSpacing.all(context, 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Enter your mobile number to receive OTP',
                                style: TextStyle(
                                  fontSize: ResponsiveTypography.bodyText1(context),
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Mobile Number Field
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Advanced3DCard(
                        padding: ResponsiveSpacing.all(context, 20),
                        backgroundColor: SparshTheme.cardBackground,
                        borderRadius: 20,
                        enableGlassMorphism: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mobile Number',
                              style: TextStyle(
                                fontSize: ResponsiveTypography.bodyText1(context),
                                fontWeight: FontWeight.w600,
                                color: SparshTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Advanced3DTextField(
                              controller: _phoneController,
                              hintText: 'Enter 10-digit mobile number',
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              prefixIcon: Icon(
                                Icons.phone_android,
                                color: SparshTheme.primaryBlue,
                              ),
                              borderRadius: 15,
                              backgroundColor: SparshTheme.cardBackground,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your mobile number';
                                }
                                if (value.length != 10) {
                                  return 'Please enter a valid 10-digit mobile number';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // OTP Field
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Advanced3DCard(
                        padding: ResponsiveSpacing.all(context, 20),
                        backgroundColor: SparshTheme.cardBackground,
                        borderRadius: 20,
                        enableGlassMorphism: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enter OTP',
                              style: TextStyle(
                                fontSize: ResponsiveTypography.bodyText1(context),
                                fontWeight: FontWeight.w600,
                                color: SparshTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Advanced3DTextField(
                              controller: _otpController,
                              hintText: 'Enter 6-digit OTP',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: SparshTheme.primaryBlue,
                              ),
                              borderRadius: 15,
                              backgroundColor: SparshTheme.cardBackground,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter OTP';
                                }
                                if (value.length != 6) {
                                  return 'Please enter a valid 6-digit OTP';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          if (!_isOtpSent)
                            Advanced3DButton(
                              onPressed: sendOTP,
                              backgroundColor: SparshTheme.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: ResponsiveSpacing.symmetric(context, horizontal: 32, vertical: 16),
                              borderRadius: 15,
                              width: ResponsiveUtil.getScreenWidth(context),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Send OTP',
                                    style: TextStyle(
                                      fontSize: ResponsiveTypography.bodyText1(context),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_isOtpSent) ...[
                            Advanced3DButton(
                              onPressed: verifyOTP,
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: ResponsiveSpacing.symmetric(context, horizontal: 32, vertical: 16),
                              borderRadius: 15,
                              width: ResponsiveUtil.getScreenWidth(context),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.verified, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Verify OTP',
                                    style: TextStyle(
                                      fontSize: ResponsiveTypography.bodyText1(context),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Advanced3DButton(
                              onPressed: _canResend ? sendOTP : null,
                              backgroundColor: _canResend ? SparshTheme.primaryBlue : SparshTheme.cardBackground,
                              foregroundColor: _canResend ? Colors.white : SparshTheme.textSecondary,
                              padding: ResponsiveSpacing.symmetric(context, horizontal: 32, vertical: 12),
                              borderRadius: 15,
                              width: ResponsiveUtil.getScreenWidth(context),
                              child: Text(
                                _canResend ? 'Resend OTP' : 'Resend OTP in $_resendTimer seconds',
                                style: TextStyle(
                                  fontSize: ResponsiveTypography.bodyText1(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
