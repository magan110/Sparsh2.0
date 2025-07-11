import 'package:flutter/material.dart';
import 'package:learning2/core/components/advanced_3d/advanced_3d_components.dart';
import 'package:learning2/core/utils/responsive_design.dart';
import 'package:learning2/core/utils/form_validators/form_validators.dart';
import 'package:learning2/core/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DSREntryScreen extends StatefulWidget {
  const DSREntryScreen({super.key});

  @override
  State<DSREntryScreen> createState() => _DSREntryScreenState();
}

class _DSREntryScreenState extends State<DSREntryScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Basic Information Controllers
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();
  final TextEditingController _customerEmailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  // Product Information
  final List<ProductEntry> _products = [ProductEntry()];
  
  // Photo Information
  final List<File> _photos = [];
  final ImagePicker _picker = ImagePicker();

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _dateController.text = DateTime.now().toString().split(' ')[0];
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
    _pageController.dispose();
    _dateController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerEmailController.dispose();
    _locationController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _nextStep() async {
    if (_currentStep < 2) {
      if (_validateCurrentStep()) {
        setState(() => _currentStep++);
        await _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _submitDSR();
    }
  }

  Future<void> _previousStep() async {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      await _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _formKey.currentState!.validate();
      case 1:
        return _products.any((product) => product.isValid);
      case 2:
        return true; // Photo step is optional
      default:
        return false;
    }
  }

  Future<void> _submitDSR() async {
    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      _showErrorDialog('Failed to submit DSR. Please try again.');
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
                'DSR Submitted Successfully',
                style: ResponsiveTypography.headlineSmall(context).copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveSpacing.medium(context)),
              Text(
                'Your Daily Sales Report has been submitted successfully.',
                style: ResponsiveTypography.bodyMedium(context),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveSpacing.large(context)),
              Advanced3DButton(
                text: 'Continue',
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
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

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _photos.add(File(image.path));
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _photos.add(File(image.path));
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  void _addProduct() {
    setState(() {
      _products.add(ProductEntry());
    });
  }

  void _removeProduct(int index) {
    if (_products.length > 1) {
      setState(() {
        _products.removeAt(index);
      });
    }
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
                        title: 'DSR Entry',
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
                        actions: [
                          IconButton(
                            icon: Icon(
                              Icons.save_outlined,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              // Save as draft
                            },
                          ),
                        ],
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
                                        child: Icon(
                                          _getStepIcon(index),
                                          color: isActive 
                                              ? SparshTheme.primaryBlue
                                              : Colors.white,
                                          size: ResponsiveUtil.scaledSize(context, 20),
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
                              _buildBasicInfoStep(),
                              _buildProductsStep(),
                              _buildPhotosStep(),
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
                                text: _currentStep == 2 ? 'Submit DSR' : 'Next',
                                onPressed: _isLoading ? null : _nextStep,
                                isLoading: _isLoading,
                                backgroundColor: Colors.white,
                                foregroundColor: SparshTheme.primaryBlue,
                                enableGlassMorphism: true,
                                icon: _currentStep == 2 ? Icons.send : Icons.arrow_forward,
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

  IconData _getStepIcon(int index) {
    switch (index) {
      case 0:
        return Icons.info_outline;
      case 1:
        return Icons.inventory_2_outlined;
      case 2:
        return Icons.photo_camera_outlined;
      default:
        return Icons.circle;
    }
  }

  String _getStepTitle(int index) {
    switch (index) {
      case 0:
        return 'Basic Info';
      case 1:
        return 'Products';
      case 2:
        return 'Photos';
      default:
        return '';
    }
  }

  Widget _buildBasicInfoStep() {
    return Advanced3DCard(
      backgroundColor: Colors.white,
      borderRadius: 25,
      enableGlassMorphism: true,
      enable3DTransform: true,
      enableHoverEffect: false,
      padding: ResponsiveSpacing.paddingLarge(context),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: AdvancedStaggeredAnimation(
            children: [
              Text(
                'Basic Information',
                style: ResponsiveTypography.headlineMedium(context).copyWith(
                  color: SparshTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ResponsiveSpacing.medium(context)),
              Text(
                'Please provide the basic details for your DSR',
                style: ResponsiveTypography.bodyMedium(context).copyWith(
                  color: SparshTheme.textSecondary,
                ),
              ),
              SizedBox(height: ResponsiveSpacing.xLarge(context)),
              
              // Date Field
              Advanced3DTextFormField(
                controller: _dateController,
                hintText: 'Select date',
                labelText: 'Date',
                prefixIcon: Icons.calendar_today_outlined,
                validator: (value) => FormValidators.validateRequired(value, fieldName: 'Date'),
                enableGlassMorphism: true,
                enable3DEffect: true,
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_month, color: SparshTheme.textSecondary),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      _dateController.text = date.toString().split(' ')[0];
                    }
                  },
                ),
              ),
              SizedBox(height: ResponsiveSpacing.large(context)),
              
              // Customer Name Field
              Advanced3DTextFormField(
                controller: _customerNameController,
                hintText: 'Customer name',
                labelText: 'Customer Name',
                prefixIcon: Icons.person_outline,
                validator: (value) => FormValidators.validateRequired(value, fieldName: 'Customer Name'),
                enableGlassMorphism: true,
                enable3DEffect: true,
              ),
              SizedBox(height: ResponsiveSpacing.large(context)),
              
              // Customer Phone Field
              Advanced3DTextFormField(
                controller: _customerPhoneController,
                hintText: 'Customer phone number',
                labelText: 'Customer Phone',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: FormValidators.validatePhoneNumber,
                enableGlassMorphism: true,
                enable3DEffect: true,
              ),
              SizedBox(height: ResponsiveSpacing.large(context)),
              
              // Customer Email Field
              Advanced3DTextFormField(
                controller: _customerEmailController,
                hintText: 'Customer email (optional)',
                labelText: 'Customer Email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    return FormValidators.validateEmail(value);
                  }
                  return null;
                },
                enableGlassMorphism: true,
                enable3DEffect: true,
              ),
              SizedBox(height: ResponsiveSpacing.large(context)),
              
              // Location Field
              Advanced3DTextFormField(
                controller: _locationController,
                hintText: 'Visit location',
                labelText: 'Location',
                prefixIcon: Icons.location_on_outlined,
                validator: (value) => FormValidators.validateRequired(value, fieldName: 'Location'),
                enableGlassMorphism: true,
                enable3DEffect: true,
                suffixIcon: IconButton(
                  icon: Icon(Icons.my_location, color: SparshTheme.textSecondary),
                  onPressed: () {
                    // Get current location
                  },
                ),
              ),
              SizedBox(height: ResponsiveSpacing.large(context)),
              
              // Remarks Field
              Advanced3DTextFormField(
                controller: _remarksController,
                hintText: 'Additional remarks',
                labelText: 'Remarks',
                prefixIcon: Icons.notes_outlined,
                maxLines: 3,
                enableGlassMorphism: true,
                enable3DEffect: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsStep() {
    return Advanced3DCard(
      backgroundColor: Colors.white,
      borderRadius: 25,
      enableGlassMorphism: true,
      enable3DTransform: true,
      enableHoverEffect: false,
      padding: ResponsiveSpacing.paddingLarge(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Products',
                style: ResponsiveTypography.headlineMedium(context).copyWith(
                  color: SparshTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Advanced3DButton(
                text: 'Add Product',
                onPressed: _addProduct,
                backgroundColor: SparshTheme.primaryBlue,
                foregroundColor: Colors.white,
                borderRadius: 20,
                enableGlassMorphism: true,
                enable3DEffect: true,
                icon: Icons.add,
                width: ResponsiveUtil.scaledSize(context, 140),
                height: ResponsiveUtil.scaledSize(context, 40),
              ),
            ],
          ),
          SizedBox(height: ResponsiveSpacing.medium(context)),
          Text(
            'Add products sold during this visit',
            style: ResponsiveTypography.bodyMedium(context).copyWith(
              color: SparshTheme.textSecondary,
            ),
          ),
          SizedBox(height: ResponsiveSpacing.large(context)),
          
          Expanded(
            child: ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(bottom: ResponsiveSpacing.medium(context)),
                  child: Advanced3DCard(
                    backgroundColor: SparshTheme.lightBlueBackground,
                    borderRadius: 20,
                    enableGlassMorphism: false,
                    enable3DTransform: true,
                    padding: ResponsiveSpacing.paddingMedium(context),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Product ${index + 1}',
                              style: ResponsiveTypography.titleMedium(context).copyWith(
                                color: SparshTheme.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_products.length > 1)
                              IconButton(
                                icon: Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () => _removeProduct(index),
                              ),
                          ],
                        ),
                        SizedBox(height: ResponsiveSpacing.medium(context)),
                        
                        // Product Name
                        Advanced3DTextFormField(
                          controller: _products[index].nameController,
                          hintText: 'Product name',
                          labelText: 'Product Name',
                          prefixIcon: Icons.inventory_2_outlined,
                          enableGlassMorphism: true,
                          enable3DEffect: true,
                        ),
                        SizedBox(height: ResponsiveSpacing.medium(context)),
                        
                        // Quantity and Price
                        Row(
                          children: [
                            Expanded(
                              child: Advanced3DTextFormField(
                                controller: _products[index].quantityController,
                                hintText: 'Quantity',
                                labelText: 'Quantity',
                                prefixIcon: Icons.numbers,
                                keyboardType: TextInputType.number,
                                enableGlassMorphism: true,
                                enable3DEffect: true,
                              ),
                            ),
                            SizedBox(width: ResponsiveSpacing.medium(context)),
                            Expanded(
                              child: Advanced3DTextFormField(
                                controller: _products[index].priceController,
                                hintText: 'Price',
                                labelText: 'Price',
                                prefixIcon: Icons.currency_rupee,
                                keyboardType: TextInputType.number,
                                enableGlassMorphism: true,
                                enable3DEffect: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosStep() {
    return Advanced3DCard(
      backgroundColor: Colors.white,
      borderRadius: 25,
      enableGlassMorphism: true,
      enable3DTransform: true,
      enableHoverEffect: false,
      padding: ResponsiveSpacing.paddingLarge(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Photos',
            style: ResponsiveTypography.headlineMedium(context).copyWith(
              color: SparshTheme.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ResponsiveSpacing.medium(context)),
          Text(
            'Add photos of the visit (optional)',
            style: ResponsiveTypography.bodyMedium(context).copyWith(
              color: SparshTheme.textSecondary,
            ),
          ),
          SizedBox(height: ResponsiveSpacing.large(context)),
          
          // Photo Upload Options
          Row(
            children: [
              Expanded(
                child: Advanced3DButton(
                  text: 'Camera',
                  onPressed: _pickImage,
                  backgroundColor: SparshTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  enableGlassMorphism: true,
                  enable3DEffect: true,
                  icon: Icons.camera_alt,
                ),
              ),
              SizedBox(width: ResponsiveSpacing.medium(context)),
              Expanded(
                child: Advanced3DButton(
                  text: 'Gallery',
                  onPressed: _pickImageFromGallery,
                  backgroundColor: Colors.transparent,
                  foregroundColor: SparshTheme.primaryBlue,
                  borderColor: SparshTheme.primaryBlue,
                  enableGlassMorphism: false,
                  enable3DEffect: true,
                  icon: Icons.photo_library,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveSpacing.large(context)),
          
          // Photo Grid
          Expanded(
            child: _photos.isEmpty
                ? Center(
                    child: GlassMorphismContainer(
                      borderRadius: 20,
                      backgroundColor: SparshTheme.lightBlueBackground,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_camera_outlined,
                            size: ResponsiveUtil.scaledSize(context, 80),
                            color: SparshTheme.textTertiary,
                          ),
                          SizedBox(height: ResponsiveSpacing.medium(context)),
                          Text(
                            'No photos added yet',
                            style: ResponsiveTypography.bodyMedium(context).copyWith(
                              color: SparshTheme.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveUtil.isDesktop(context) ? 3 : 2,
                      crossAxisSpacing: ResponsiveSpacing.medium(context),
                      mainAxisSpacing: ResponsiveSpacing.medium(context),
                    ),
                    itemCount: _photos.length,
                    itemBuilder: (context, index) {
                      return Advanced3DCard(
                        backgroundColor: Colors.white,
                        borderRadius: 15,
                        enableGlassMorphism: true,
                        enable3DTransform: true,
                        padding: EdgeInsets.all(ResponsiveSpacing.small(context)),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _photos[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: GestureDetector(
                                onTap: () => _removePhoto(index),
                                child: Container(
                                  padding: EdgeInsets.all(ResponsiveSpacing.small(context) / 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: ResponsiveUtil.scaledSize(context, 16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class ProductEntry {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  bool get isValid {
    return nameController.text.isNotEmpty &&
           quantityController.text.isNotEmpty &&
           priceController.text.isNotEmpty;
  }

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    priceController.dispose();
  }
}