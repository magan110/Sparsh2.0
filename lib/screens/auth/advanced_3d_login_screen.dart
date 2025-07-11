import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learning2/features/worker/presentation/pages/Worker_Home_Screen.dart';
import 'package:learning2/features/dashboard/presentation/pages/home_screen.dart';
import 'package:learning2/features/authentication/presentation/pages/log_in_otp.dart';
import 'package:learning2/core/constants/fonts.dart';
import 'package:learning2/core/components/advanced_3d/advanced_3d_components.dart';
import 'package:learning2/core/utils/responsive_design.dart';
import 'package:learning2/core/utils/form_validators/form_validators.dart';
import 'package:learning2/core/theme/app_theme.dart';
import '../../registration/customer_registration.dart';
import 'forgot_password_screen.dart';

class Advanced3DLoginScreen extends StatefulWidget {
  final bool fromSplash;

  const Advanced3DLoginScreen({super.key, this.fromSplash = false});

  @override
  State<Advanced3DLoginScreen> createState() => _Advanced3DLoginScreenState();
}

class _Advanced3DLoginScreenState extends State<Advanced3DLoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final String apiUrl = "https://192.168.55.182:7023/api/Auth/login";
  bool _obscurePassword = true;
  bool _isLoading = false;
  late FirebaseMessaging _messaging;
  String? _deviceToken;
  final _formKey = GlobalKey<FormState>();

  // Animation controllers
  late AnimationController _animController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _logoAnimation;

  @override
  void initState() {
    super.initState();
    _initializeFirebaseMessaging();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    _animController.forward();
  }

  void _initializeFirebaseMessaging() async {
    _messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    _deviceToken = await _messaging.getToken();
  }

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final String userID = _usernameController.text.trim();
    final String password = _passwordController.text.trim();
    final String appRegId = _deviceToken ?? "UnknownDevice";

    final Map<String, dynamic> requestBody = {
      'userID': userID,
      'password': password,
      'appRegId': appRegId,
    };

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result.first.rawAddress.isEmpty) {
        throw const SocketException('No Internet Connection');
      }

      final client = IOClient(
        HttpClient()..badCertificateCallback = (cert, host, port) => true,
      );
      final response = await client.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['msg'] == 'Authentication successful') {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);

          final String role = responseData['role'] ?? '';

          // Navigate based on role
          Widget nextScreen;
          switch (role) {
            case 'Worker':
              nextScreen = const WorkerHomeScreen();
              break;
            case 'Customer':
              nextScreen = const HomeScreen();
              break;
            default:
              nextScreen = const HomeScreen();
          }

          if (mounted) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 800),
                pageBuilder: (_, __, ___) => nextScreen,
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          }
        } else {
          _showErrorDialog(
            "Authentication failed. Please check your credentials.",
          );
        }
      } else {
        _showErrorDialog("Failed to authenticate. Please try again.");
      }
      client.close();
    } on SocketException catch (_) {
      _showErrorDialog(
        'No Internet Connection\nPlease check your connection and try again.',
      );
    } catch (e) {
      _showErrorDialog('An error occurred: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => Advanced3DCard(
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
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Container(
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
            child: Stack(
              children: [
                // Animated background elements
                ...List.generate(5, (index) {
                  return Positioned(
                    top: (index * 150.0) - 50,
                    right: (index % 2 == 0) ? -50 : null,
                    left: (index % 2 == 1) ? -50 : null,
                    child: Opacity(
                      opacity: _backgroundAnimation.value * 0.1,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),

                // Main content
                SafeArea(
                  child: ResponsiveFormWrapper(
                    child: SingleChildScrollView(
                      child: AdvancedStaggeredAnimation(
                        children: [
                          SizedBox(height: ResponsiveSpacing.xxLarge(context)),
                          
                          // App Logo
                          Transform.scale(
                            scale: _logoAnimation.value,
                            child: Advanced3DCard(
                              backgroundColor: Colors.white,
                              borderRadius: 20,
                              enableGlassMorphism: true,
                              enable3DTransform: true,
                              enableHoverEffect: false,
                              padding: ResponsiveSpacing.paddingMedium(context),
                              child: Container(
                                width: ResponsiveUtil.scaledSize(context, 250),
                                height: ResponsiveUtil.scaledSize(context, 100),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Image.asset(
                                  'assets/logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: ResponsiveSpacing.large(context)),
                          
                          // App Name
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0.8),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds),
                            child: Text(
                              'SPARSH',
                              style: ResponsiveTypography.displayMedium(context).copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          
                          SizedBox(height: ResponsiveSpacing.xxLarge(context)),
                          
                          // Login Form
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
                                    'Welcome Back',
                                    style: ResponsiveTypography.headlineMedium(context).copyWith(
                                      color: SparshTheme.primaryBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: ResponsiveSpacing.small(context)),
                                  Text(
                                    'Sign in to continue your journey',
                                    style: ResponsiveTypography.bodyMedium(context).copyWith(
                                      color: SparshTheme.textSecondary,
                                    ),
                                  ),
                                  SizedBox(height: ResponsiveSpacing.xLarge(context)),
                                  
                                  // Username Field
                                  Advanced3DTextFormField(
                                    controller: _usernameController,
                                    hintText: 'Enter your username',
                                    labelText: 'Username',
                                    prefixIcon: Icons.person_outline,
                                    validator: (value) => FormValidators.validateRequired(value, fieldName: 'Username'),
                                    enableGlassMorphism: true,
                                    enable3DEffect: true,
                                  ),
                                  SizedBox(height: ResponsiveSpacing.large(context)),
                                  
                                  // Password Field
                                  Advanced3DTextFormField(
                                    controller: _passwordController,
                                    hintText: 'Enter your password',
                                    labelText: 'Password',
                                    prefixIcon: Icons.lock_outline,
                                    obscureText: _obscurePassword,
                                    validator: (value) => FormValidators.validateRequired(value, fieldName: 'Password'),
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
                                  SizedBox(height: ResponsiveSpacing.medium(context)),
                                  
                                  // Forgot Password
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const ForgotPasswordScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Forgot Password?',
                                        style: ResponsiveTypography.bodyMedium(context).copyWith(
                                          color: SparshTheme.primaryBlue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: ResponsiveSpacing.large(context)),
                                  
                                  // Login Button
                                  Advanced3DButton(
                                    text: 'LOGIN',
                                    onPressed: _isLoading ? null : loginUser,
                                    isLoading: _isLoading,
                                    width: double.infinity,
                                    backgroundColor: SparshTheme.primaryBlue,
                                    enableGlassMorphism: true,
                                    enable3DEffect: true,
                                    enablePulseEffect: false,
                                    icon: Icons.login,
                                  ),
                                  SizedBox(height: ResponsiveSpacing.large(context)),
                                  
                                  // Divider
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: SparshTheme.borderGrey,
                                          thickness: 1,
                                        ),
                                      ),
                                      Padding(
                                        padding: ResponsiveSpacing.paddingHorizontalMedium(context),
                                        child: Text(
                                          'OR',
                                          style: ResponsiveTypography.bodySmall(context).copyWith(
                                            color: SparshTheme.textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: SparshTheme.borderGrey,
                                          thickness: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: ResponsiveSpacing.large(context)),
                                  
                                  // OTP Login Button
                                  Advanced3DButton(
                                    text: 'Login with OTP',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const LogInOtp(),
                                        ),
                                      );
                                    },
                                    width: double.infinity,
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: SparshTheme.primaryBlue,
                                    borderColor: SparshTheme.primaryBlue,
                                    enableGlassMorphism: false,
                                    enable3DEffect: true,
                                    icon: Icons.phone_android,
                                  ),
                                  SizedBox(height: ResponsiveSpacing.medium(context)),
                                  
                                  // Register Link
                                  Center(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const CustomerRegistrationScreen(),
                                          ),
                                        );
                                      },
                                      child: RichText(
                                        text: TextSpan(
                                          text: "Don't have an account? ",
                                          style: ResponsiveTypography.bodyMedium(context).copyWith(
                                            color: SparshTheme.textSecondary,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'Register',
                                              style: ResponsiveTypography.bodyMedium(context).copyWith(
                                                color: SparshTheme.primaryBlue,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
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
              ],
            ),
          );
        },
      ),
    );
  }
}