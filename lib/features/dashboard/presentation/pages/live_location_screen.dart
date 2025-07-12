import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/components/advanced_3d_components.dart';
import '../../../../core/utils/responsive_util.dart';

class LiveLocationScreen extends StatefulWidget {
  const LiveLocationScreen({super.key});

  @override
  State<LiveLocationScreen> createState() => _LiveLocationScreenState();
}

class _LiveLocationScreenState extends State<LiveLocationScreen> 
    with TickerProviderStateMixin {
  Position? _currentPosition;
  String _errorMessage = '';
  bool _isLoading = false;
  bool _isTracking = false;
  bool _isLocationServiceEnabled = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _checkLocationPermission();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLocationServiceEnabled = false;
        _errorMessage = 'Location services are disabled.';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _errorMessage = 'Location permissions are denied';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _errorMessage = 'Location permissions are permanently denied, we cannot request permissions.';
      });
      return;
    }

    setState(() {
      _isLocationServiceEnabled = true;
    });
    
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get location: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SparshTheme.scaffoldBackground,
      appBar: Advanced3DAppBar(
        title: Text(
          'Live Location',
          style: SparshTypography.heading5.copyWith(color: Colors.white),
        ),
        backgroundColor: SparshTheme.primaryBlue,
        enableGlassMorphism: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: _getCurrentLocation,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: ResponsiveUtil.scaledPadding(context, all: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildLocationIcon(),
              SizedBox(height: ResponsiveUtil.scaledSize(context, 24)),
              _buildLocationInfo(),
              SizedBox(height: ResponsiveUtil.scaledSize(context, 24)),
              _buildLocationControls(),
              SizedBox(height: ResponsiveUtil.scaledSize(context, 24)),
              _buildTrackingSettings(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationIcon() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isTracking ? _pulseAnimation.value : 1.0,
          child: Container(
            width: ResponsiveUtil.scaledSize(context, 120),
            height: ResponsiveUtil.scaledSize(context, 120),
            decoration: BoxDecoration(
              color: _isLocationServiceEnabled 
                  ? SparshTheme.primaryBlue.withOpacity(0.1)
                  : SparshTheme.errorRed.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: _isLocationServiceEnabled 
                    ? SparshTheme.primaryBlue
                    : SparshTheme.errorRed,
                width: 3,
              ),
            ),
            child: Icon(
              _isLocationServiceEnabled 
                  ? Icons.location_on
                  : Icons.location_off,
              color: _isLocationServiceEnabled 
                  ? SparshTheme.primaryBlue
                  : SparshTheme.errorRed,
              size: ResponsiveUtil.scaledSize(context, 60),
            ),
          ),
        );
      },
    ).animate().fadeIn(duration: 600.ms).scale();
  }

  Widget _buildLocationInfo() {
    if (_isLoading) {
      return Advanced3DCard(
        enableGlassMorphism: false,
        child: Column(
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
            Text(
              'Getting your location...',
              style: SparshTypography.bodyMedium.copyWith(
                color: SparshTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Advanced3DCard(
        enableGlassMorphism: false,
        backgroundColor: SparshTheme.errorLight,
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: SparshTheme.errorRed,
              size: ResponsiveUtil.scaledSize(context, 48),
            ),
            SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
            Text(
              'Error',
              style: SparshTypography.heading6.copyWith(
                color: SparshTheme.errorRed,
              ),
            ),
            SizedBox(height: ResponsiveUtil.scaledSize(context, 8)),
            Text(
              _errorMessage,
              style: SparshTypography.bodyMedium.copyWith(
                color: SparshTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_currentPosition == null) {
      return Advanced3DCard(
        enableGlassMorphism: false,
        child: Column(
          children: [
            Icon(
              Icons.location_searching,
              color: SparshTheme.textSecondary,
              size: ResponsiveUtil.scaledSize(context, 48),
            ),
            SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
            Text(
              'Location data not available',
              style: SparshTypography.bodyMedium.copyWith(
                color: SparshTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Advanced3DCard(
      enableGlassMorphism: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: SparshTheme.primaryBlue,
                size: ResponsiveUtil.scaledSize(context, 24),
              ),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 8)),
              Text(
                'Current Location',
                style: SparshTypography.heading6.copyWith(
                  color: SparshTheme.primaryBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 20)),
          _buildLocationDataRow(
            'Latitude',
            _currentPosition!.latitude.toStringAsFixed(6),
            Icons.explore,
          ),
          _buildLocationDataRow(
            'Longitude',
            _currentPosition!.longitude.toStringAsFixed(6),
            Icons.explore_off,
          ),
          _buildLocationDataRow(
            'Accuracy',
            '${_currentPosition!.accuracy.toStringAsFixed(2)} meters',
            Icons.gps_fixed,
          ),
          _buildLocationDataRow(
            'Altitude',
            '${_currentPosition!.altitude.toStringAsFixed(2)} meters',
            Icons.terrain,
          ),
          _buildLocationDataRow(
            'Speed',
            '${_currentPosition!.speed.toStringAsFixed(2)} m/s',
            Icons.speed,
          ),
          _buildLocationDataRow(
            'Last Updated',
            DateTime.now().toString().substring(0, 19),
            Icons.access_time,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideY(begin: 0.2);
  }

  Widget _buildLocationDataRow(String label, String value, IconData icon) {
    return Container(
      padding: ResponsiveUtil.scaledPadding(context, vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: SparshTheme.textSecondary,
            size: ResponsiveUtil.scaledSize(context, 18),
          ),
          SizedBox(width: ResponsiveUtil.scaledSize(context, 12)),
          Expanded(
            child: Text(
              label,
              style: SparshTypography.bodyMedium.copyWith(
                color: SparshTheme.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: SparshTypography.bodyBold.copyWith(
              color: SparshTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationControls() {
    return Advanced3DCard(
      enableGlassMorphism: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.control_camera,
                color: SparshTheme.primaryBlue,
                size: ResponsiveUtil.scaledSize(context, 24),
              ),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 8)),
              Text(
                'Location Controls',
                style: SparshTypography.heading6.copyWith(
                  color: SparshTheme.primaryBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 20)),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _getCurrentLocation,
                  icon: Icon(_isLoading ? Icons.refresh : Icons.my_location),
                  label: Text(_isLoading ? 'Refreshing...' : 'Refresh Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SparshTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: ResponsiveUtil.scaledPadding(context, vertical: 16),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 16)),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (_currentPosition != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Location: ${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share Location'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SparshTheme.primaryBlue,
                    side: BorderSide(color: SparshTheme.primaryBlue),
                    padding: ResponsiveUtil.scaledPadding(context, vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.2);
  }

  Widget _buildTrackingSettings() {
    return Advanced3DCard(
      enableGlassMorphism: false,
      backgroundColor: _isTracking 
          ? SparshTheme.successLight
          : SparshTheme.cardBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.track_changes,
                color: _isTracking ? SparshTheme.successGreen : SparshTheme.primaryBlue,
                size: ResponsiveUtil.scaledSize(context, 24),
              ),
              SizedBox(width: ResponsiveUtil.scaledSize(context, 8)),
              Text(
                'Location Tracking',
                style: SparshTypography.heading6.copyWith(
                  color: _isTracking ? SparshTheme.successGreen : SparshTheme.primaryBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
          Text(
            'Enable continuous location tracking to monitor your position in real-time.',
            style: SparshTypography.bodyMedium.copyWith(
              color: SparshTheme.textSecondary,
            ),
          ),
          SizedBox(height: ResponsiveUtil.scaledSize(context, 20)),
          Row(
            children: [
              Expanded(
                child: Text(
                  _isTracking ? 'Tracking Active' : 'Tracking Inactive',
                  style: SparshTypography.bodyBold.copyWith(
                    color: _isTracking ? SparshTheme.successGreen : SparshTheme.textSecondary,
                  ),
                ),
              ),
              Switch(
                value: _isTracking,
                onChanged: _isLocationServiceEnabled 
                    ? (value) {
                        setState(() {
                          _isTracking = value;
                        });
                        if (value) {
                          _animationController.repeat(reverse: true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Location tracking started'),
                            ),
                          );
                        } else {
                          _animationController.stop();
                          _animationController.forward();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Location tracking stopped'),
                            ),
                          );
                        }
                      }
                    : null,
                activeColor: SparshTheme.successGreen,
              ),
            ],
          ),
          if (_isTracking) ...[
            SizedBox(height: ResponsiveUtil.scaledSize(context, 16)),
            Container(
              padding: ResponsiveUtil.scaledPadding(context, all: 12),
              decoration: BoxDecoration(
                color: SparshTheme.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(SparshBorderRadius.md),
                border: Border.all(
                  color: SparshTheme.successGreen.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: SparshTheme.successGreen,
                    size: ResponsiveUtil.scaledSize(context, 20),
                  ),
                  SizedBox(width: ResponsiveUtil.scaledSize(context, 8)),
                  Expanded(
                    child: Text(
                      'Location is being tracked continuously. This may affect battery life.',
                      style: SparshTypography.bodySmall.copyWith(
                        color: SparshTheme.successGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 0.2);
  }
}
