import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:learning2/core/theme/app_theme.dart';
import 'package:learning2/core/animations/animation_library.dart';
import 'package:learning2/core/animations/advanced_ui_components.dart';
import 'package:learning2/core/animations/form_components.dart';

/// Showcase screen demonstrating all modern form components with animations
class FormShowcaseScreen extends StatefulWidget {
  const FormShowcaseScreen({super.key});

  @override
  State<FormShowcaseScreen> createState() => _FormShowcaseScreenState();
}

class _FormShowcaseScreenState extends State<FormShowcaseScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String? _selectedCountry;
  String? _selectedCity;
  bool _agreedToTerms = false;
  bool _receiveUpdates = true;
  bool _enableNotifications = false;
  
  final List<String> _countries = [
    'United States',
    'United Kingdom', 
    'Canada',
    'Australia',
    'India',
    'Germany',
    'France',
    'Japan',
  ];
  
  final List<String> _cities = [
    'New York',
    'London',
    'Toronto',
    'Sydney',
    'Mumbai',
    'Berlin',
    'Paris',
    'Tokyo',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SparshTheme.scaffoldBackground,
      appBar: GlassAppBar(
        title: 'Form Components Showcase',
        actions: [
          AnimatedMicroIcon(
            icon: Icons.info_outline,
            size: 24,
            color: Colors.white,
            enableBounce: true,
            onTap: () => _showInfoDialog(),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: AnimatedGradientBackground(
        colors: [
          SparshTheme.scaffoldBackground,
          SparshTheme.lightBlueBackground,
          SparshTheme.lightGreenBackground,
        ],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: StaggeredListView(
            children: [
              _buildBasicFormSection(),
              const SizedBox(height: 24),
              _buildDropdownsSection(),
              const SizedBox(height: 24),
              _buildSwitchesSection(),
              const SizedBox(height: 24),
              _buildCheckboxesSection(),
              const SizedBox(height: 24),
              _buildMultiStepFormSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicFormSection() {
    return FloatingPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Animated Form Fields',
                      style: SparshTypography.heading5,
                    ),
                    Text(
                      'Modern form fields with floating labels',
                      style: SparshTypography.bodySmall.copyWith(
                        color: SparshTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AnimatedFormField(
            label: 'Full Name',
            hintText: 'Enter your full name',
            controller: _nameController,
            prefixIcon: const Icon(Icons.person_outline),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Name is required';
              }
              if (value.length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AnimatedFormField(
            label: 'Email Address',
            hintText: 'Enter your email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AnimatedFormField(
            label: 'Phone Number',
            hintText: 'Enter your phone number',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone_outlined),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Phone number is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AnimatedFormField(
            label: 'Password',
            hintText: 'Enter your password',
            controller: _passwordController,
            obscureText: true,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: const Icon(Icons.visibility_outlined),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownsSection() {
    return FloatingPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.purple.shade600],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_drop_down_circle,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Animated Dropdowns',
                      style: SparshTypography.heading5,
                    ),
                    Text(
                      'Search-enabled dropdown components',
                      style: SparshTypography.bodySmall.copyWith(
                        color: SparshTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AnimatedSearchDropdown<String>(
            label: 'Country',
            hintText: 'Select your country',
            items: _countries,
            itemAsString: (country) => country,
            selectedItem: _selectedCountry,
            onChanged: (value) {
              setState(() {
                _selectedCountry = value;
              });
            },
            prefixIcon: const Icon(Icons.flag_outlined),
          ),
          const SizedBox(height: 16),
          AnimatedSearchDropdown<String>(
            label: 'City',
            hintText: 'Select your city',
            items: _cities,
            itemAsString: (city) => city,
            selectedItem: _selectedCity,
            onChanged: (value) {
              setState(() {
                _selectedCity = value;
              });
            },
            prefixIcon: const Icon(Icons.location_city_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchesSection() {
    return FloatingPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.toggle_on,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Animated Switches',
                      style: SparshTypography.heading5,
                    ),
                    Text(
                      'Beautiful toggle switches with animations',
                      style: SparshTypography.bodySmall.copyWith(
                        color: SparshTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AnimatedSwitch(
            value: _receiveUpdates,
            onChanged: (value) {
              setState(() {
                _receiveUpdates = value;
              });
            },
            label: 'Receive Email Updates',
            activeColor: SparshTheme.primaryBlue,
          ),
          const SizedBox(height: 16),
          AnimatedSwitch(
            value: _enableNotifications,
            onChanged: (value) {
              setState(() {
                _enableNotifications = value;
              });
            },
            label: 'Enable Push Notifications',
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxesSection() {
    return FloatingPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.orange.shade600],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_box,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Animated Checkboxes',
                      style: SparshTypography.heading5,
                    ),
                    Text(
                      'Interactive checkboxes with smooth animations',
                      style: SparshTypography.bodySmall.copyWith(
                        color: SparshTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AnimatedCheckbox(
            value: _agreedToTerms,
            onChanged: (value) {
              setState(() {
                _agreedToTerms = value ?? false;
              });
            },
            label: 'I agree to the Terms and Conditions',
            activeColor: SparshTheme.primaryBlue,
          ),
          const SizedBox(height: 16),
          AnimatedCheckbox(
            value: true,
            onChanged: (value) {},
            label: 'Subscribe to Newsletter (checked by default)',
            activeColor: Colors.green,
          ),
          const SizedBox(height: 16),
          AnimatedCheckbox(
            value: false,
            onChanged: (value) {},
            label: 'Enable Beta Features',
            activeColor: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildMultiStepFormSection() {
    return FloatingPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade400, Colors.teal.shade600],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.linear_scale,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Multi-Step Form',
                      style: SparshTypography.heading5,
                    ),
                    Text(
                      'Progressive form with animated indicators',
                      style: SparshTypography.bodySmall.copyWith(
                        color: SparshTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 400,
            child: MultiStepForm(
              steps: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
              ],
              stepTitles: [
                'Personal Info',
                'Contact Details',
                'Preferences',
              ],
              onStepChanged: (step) {
                // Handle step change
              },
              onCompleted: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Form completed successfully!'),
                    backgroundColor: SparshTheme.successGreen,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AnimatedFormField(
            label: 'First Name',
            hintText: 'Enter your first name',
            prefixIcon: const Icon(Icons.person),
          ),
          const SizedBox(height: 16),
          AnimatedFormField(
            label: 'Last Name',
            hintText: 'Enter your last name',
            prefixIcon: const Icon(Icons.person_outline),
          ),
          const SizedBox(height: 16),
          AnimatedFormField(
            label: 'Date of Birth',
            hintText: 'Select your date of birth',
            prefixIcon: const Icon(Icons.calendar_today),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AnimatedFormField(
            label: 'Email',
            hintText: 'Enter your email address',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email),
          ),
          const SizedBox(height: 16),
          AnimatedFormField(
            label: 'Phone',
            hintText: 'Enter your phone number',
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone),
          ),
          const SizedBox(height: 16),
          AnimatedFormField(
            label: 'Address',
            hintText: 'Enter your address',
            maxLines: 3,
            prefixIcon: const Icon(Icons.home),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AnimatedSwitch(
            value: true,
            onChanged: (value) {},
            label: 'Email Notifications',
          ),
          const SizedBox(height: 16),
          AnimatedSwitch(
            value: false,
            onChanged: (value) {},
            label: 'SMS Notifications',
          ),
          const SizedBox(height: 24),
          AnimatedCheckbox(
            value: true,
            onChanged: (value) {},
            label: 'I agree to the Terms of Service',
          ),
          const SizedBox(height: 16),
          AnimatedCheckbox(
            value: false,
            onChanged: (value) {},
            label: 'Subscribe to marketing emails',
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: SparshTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.info,
                color: SparshTheme.primaryBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Form Components',
              style: SparshTypography.heading5,
            ),
          ],
        ),
        content: Text(
          'This showcase demonstrates all the animated form components available in the Sparsh2.0 app, including:\n\n'
          '• Animated form fields with floating labels\n'
          '• Search-enabled dropdowns\n'
          '• Smooth toggle switches\n'
          '• Interactive checkboxes\n'
          '• Multi-step forms with progress indicators\n\n'
          'All components feature smooth animations and modern design patterns.',
          style: SparshTypography.body,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: SparshTheme.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}