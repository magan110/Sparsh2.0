import 'package:flutter/material.dart';
import 'package:learning2/core/theme/app_theme.dart';
import 'package:learning2/core/components/advanced_3d/advanced_3d_components.dart';
import 'package:learning2/core/utils/responsive_design.dart';
import 'package:learning2/core/utils/form_validators/form_validators.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Meeting_with_new_purchaser.dart';
import 'Meetings_With_Contractor.dart';
import 'any_other_activity.dart';
import 'btl_activites.dart';
import 'check_sampling_at_site.dart';
import 'dsr_retailer_in_out.dart';
import 'internal_team_meeting.dart';
import 'office_work.dart';
import 'on_leave.dart';
import 'phone_call_with_builder.dart';
import 'phone_call_with_unregisterd_purchaser.dart';
import 'work_from_home.dart';
import 'package:learning2/features/dashboard/presentation/pages/home_screen.dart';

class DsrEntry extends StatefulWidget {
  const DsrEntry({super.key});

  @override
  State<DsrEntry> createState() => _DsrEntryState();
}

class _DsrEntryState extends State<DsrEntry> with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final List<String> _activityItems = [
    'Personal Visit',
    'Phone Call with Builder/Stockist',
    'Meetings With Contractor / Stockist',
    'Visit to Get / Check Sampling at Site',
    'Meeting with New Purchaser(Trade Purchaser)/Retailer',
    'BTL Activities',
    'Internal Team Meetings / Review Meetings',
    'Office Work',
    'On Leave / Holiday / Off Day',
    'Work From Home',
    'Any Other Activity',
    'Phone call with Unregistered Purchasers',
  ];
  String? _selectedActivity;

  final Map<String, IconData> _activityIcons = {
    'Personal Visit': Icons.person_pin_circle,
    'Phone Call with Builder/Stockist': Icons.phone_in_talk,
    'Meetings With Contractor / Stockist': Icons.groups,
    'Visit to Get / Check Sampling at Site': Icons.fact_check,
    'Meeting with New Purchaser(Trade Purchaser)/Retailer': Icons.handshake,
    'BTL Activities': Icons.campaign,
    'Internal Team Meetings / Review Meetings': Icons.people_outline,
    'Office Work': Icons.desktop_windows,
    'On Leave / Holiday / Off Day': Icons.beach_access,
    'Work From Home': Icons.home_work,
    'Any Other Activity': Icons.miscellaneous_services,
    'Phone call with Unregistered Purchasers': Icons.call,
  };

  final _formKey = GlobalKey<FormState>();

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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _navigateTo(String label) {
    final map = {
      'Personal Visit': () => const DsrRetailerInOut(),
      'Phone Call with Builder/Stockist': () => const PhoneCallWithBuilder(),
      'Meetings With Contractor / Stockist': () => const MeetingsWithContractor(),
      'Visit to Get / Check Sampling at Site': () => const CheckSamplingAtSite(),
      'Meeting with New Purchaser(Trade Purchaser)/Retailer': () => const MeetingWithNewPurchaser(),
      'BTL Activities': () => const BtlActivities(),
      'Internal Team Meetings / Review Meetings': () => const InternalTeamMeeting(),
      'Office Work': () => const OfficeWork(),
      'On Leave / Holiday / Off Day': () => const OnLeave(),
      'Work From Home': () => const WorkFromHome(),
      'Any Other Activity': () => const AnyOtherActivity(),
      'Phone call with Unregistered Purchasers': () => const PhoneCallWithUnregisterdPurchaser(),
    };
    final builder = map[label];
    if (builder != null) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => builder()));
    }
  }

  Widget _buildActivityGrid(double maxWidth) {
    // Determine cols: phones=2, small tablets=3, large=4
    int crossAxisCount = 2;
    if (maxWidth >= 900) {
      crossAxisCount = 4;
    } else if (maxWidth >= 600) {
      crossAxisCount = 3;
    }
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.6,
        crossAxisSpacing: ResponsiveUtil.scaledSize(context, 16),
        mainAxisSpacing: ResponsiveUtil.scaledSize(context, 16),
      ),
      itemCount: _activityItems.length,
      itemBuilder: (context, i) {
        final label = _activityItems[i];
        final selected = _selectedActivity == label;
        
        return Advanced3DCard(
          onTap: () {
            setState(() => _selectedActivity = label);
            _navigateTo(label);
          },
          backgroundColor: selected 
              ? SparshTheme.primaryBlue.withOpacity(0.1) 
              : SparshTheme.cardBackground,
          borderRadius: 16,
          enableGlassMorphism: true,
          child: Padding(
            padding: ResponsiveSpacing.all(context, 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: selected
                        ? SparshTheme.primaryBlue
                        : SparshTheme.primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: SparshTheme.primaryBlue.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _activityIcons[label] ?? Icons.assignment,
                    size: 30,
                    color: selected 
                        ? Colors.white 
                        : SparshTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ResponsiveTypography.bodyText2(context),
                    fontWeight: FontWeight.w600,
                    color: selected 
                        ? SparshTheme.primaryBlue 
                        : SparshTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> submitDsrEntry(Map<String, dynamic> dsrData) async {
    final url = Uri.parse('http://192.168.36.25/api/DsrTry');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dsrData),
    );
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
    if (response.statusCode == 201) {
      print('✅ Data inserted successfully!');
    } else {
      print('❌ Data NOT inserted! Error: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: SparshTheme.scaffoldBackground,
        appBar: Advanced3DAppBar(
          title: 'DSR Entry',
          centerTitle: true,
          backgroundColor: SparshTheme.primaryBlue,
          elevation: 8,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            ),
          ),
        ),
        body: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: ResponsiveSpacing.all(context, 16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header Card
                            Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Advanced3DCard(
                                width: ResponsiveUtil.getScreenWidth(context),
                                padding: ResponsiveSpacing.all(context, 20),
                                borderRadius: 20,
                                enableGlassMorphism: true,
                                backgroundColor: SparshTheme.primaryBlue,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.assignment_outlined,
                                          size: 32,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'DSR Entry',
                                                style: TextStyle(
                                                  fontSize: ResponsiveTypography.headingLarge(context),
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                'Daily Sales Report Entry',
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
                                      padding: ResponsiveSpacing.all(context, 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Select an activity type to proceed with your DSR entry',
                                              style: TextStyle(
                                                fontSize: ResponsiveTypography.bodyText2(context),
                                                color: Colors.white,
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
                            const SizedBox(height: 24),

                            // Activity Selection
                            Advanced3DCard(
                              padding: ResponsiveSpacing.all(context, 20),
                              backgroundColor: SparshTheme.cardBackground,
                              borderRadius: 20,
                              enableGlassMorphism: true,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Select Activity Type',
                                    style: TextStyle(
                                      fontSize: ResponsiveTypography.headingMedium(context),
                                      fontWeight: FontWeight.bold,
                                      color: SparshTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildActivityGrid(constraints.maxWidth),
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
            );
          },
        ),
      ),
    );
  }
}
