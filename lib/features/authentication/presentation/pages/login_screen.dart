import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';
import 'package:learning2/features/worker/presentation/pages/Worker_Home_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learning2/features/dashboard/presentation/pages/home_screen.dart';
import 'log_in_otp.dart';
import 'package:learning2/core/constants/fonts.dart';
import 'package:learning2/core/components/advanced_3d/advanced_3d_components.dart';
import 'package:learning2/core/utils/responsive_design.dart';
import 'package:learning2/core/utils/form_validators/form_validators.dart';
import 'package:learning2/core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  final bool fromSplash;

  const LoginScreen({super.key, this.fromSplash = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final String apiUrl = "https://192.168.55.182:7023/api/Auth/login";
  bool _obscurePassword = true;
  bool _isLoading = false;
  final bool _rememberMe = false;
  late FirebaseMessaging _messaging;
  String? _deviceToken;
  final _formKey = GlobalKey<FormState>();

  // Animation controllers
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeFirebaseMessaging();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
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
                transitionDuration: const Duration(milliseconds: 500),
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
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Text('Error', style: TextStyle(color: Colors.red)),
          ],
        ),
        content: Text(message),
        actions: [
          Advanced3DButton(
            onPressed: () => Navigator.pop(context),
            backgroundColor: SparshTheme.primaryBlue,
            foregroundColor: Colors.white,
            padding: ResponsiveSpacing.symmetric(context, horizontal: 16, vertical: 8),
            borderRadius: 8,
            child: Text('OK'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
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
      backgroundColor: SparshTheme.scaffoldBackground,
      body: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value.dy * 50),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      SparshTheme.primaryBlue,
                      SparshTheme.primaryBlue.withOpacity(0.8),
                      SparshTheme.primaryBlue.withOpacity(0.6),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: ResponsiveSpacing.all(context, 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        // App Logo
                        Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Advanced3DCard(
                            width: 250,
                            height: 100,
                            borderRadius: 20,
                            enableGlassMorphism: true,
                            backgroundColor: Colors.white,
                            padding: ResponsiveSpacing.all(context, 8),
                            child: Image.asset(
                              'assets/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // App Name
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white70,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds),
                          child: Text(
                            'SPARSH',
                            style: TextStyle(
                              fontSize: ResponsiveTypography.headingLarge(context),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Login Card
                        Advanced3DCard(
                          width: ResponsiveUtil.getScreenWidth(context),
                          padding: ResponsiveSpacing.all(context, 30),
                          borderRadius: 25,
                          enableGlassMorphism: true,
                          backgroundColor: SparshTheme.cardBackground,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome Back',
                                  style: TextStyle(
                                    fontSize: ResponsiveTypography.headingMedium(context),
                                    fontWeight: FontWeight.bold,
                                    color: SparshTheme.primaryBlue,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Sign in to continue',
                                  style: TextStyle(
                                    fontSize: ResponsiveTypography.bodyText1(context),
                                    color: SparshTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 30),

                                // Username Field
                                Advanced3DTextField(
                                  controller: _usernameController,
                                  hintText: 'Username',
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: SparshTheme.primaryBlue,
                                  ),
                                  borderRadius: 15,
                                  backgroundColor: SparshTheme.cardBackground,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your username';
                                    }
                                    return null;
                                  },
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(
                                      RegExp(r'\s'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Password Field
                                Advanced3DTextField(
                                  controller: _passwordController,
                                  hintText: 'Password',
                                  obscureText: _obscurePassword,
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: SparshTheme.primaryBlue,
                                  ),
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
                                  borderRadius: 15,
                                  backgroundColor: SparshTheme.cardBackground,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 15),

                                // Forgot Password
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        // TODO: Implement forgot password
                                      },
                                      child: Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          fontSize: ResponsiveTypography.bodyText2(context),
                                          color: SparshTheme.primaryBlue,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 25),

                                // Login Button
                                Advanced3DButton(
                                  onPressed: _isLoading ? null : loginUser,
                                  backgroundColor: SparshTheme.primaryBlue,
                                  foregroundColor: Colors.white,
                                  padding: ResponsiveSpacing.symmetric(
                                    context,
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  borderRadius: 30,
                                  width: ResponsiveUtil.getScreenWidth(context),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          'LOGIN',
                                          style: TextStyle(
                                            fontSize: ResponsiveTypography.bodyText1(context),
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // OTP Login Option
                        Advanced3DButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LogInOtp(),
                              ),
                            );
                          },
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          padding: ResponsiveSpacing.symmetric(
                            context,
                            horizontal: 20,
                            vertical: 15,
                          ),
                          borderRadius: 30,
                          width: ResponsiveUtil.getScreenWidth(context),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.phone_android,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Login with OTP',
                                style: TextStyle(
                                  fontSize: ResponsiveTypography.bodyText1(context),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
