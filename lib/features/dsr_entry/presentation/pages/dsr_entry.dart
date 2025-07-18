import 'package:flutter/material.dart';
import 'package:learning2/core/theme/app_theme.dart';
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

class _DsrEntryState extends State<DsrEntry> {
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

  Widget _buildActivityList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _activityItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: SparshSpacing.md),
      itemBuilder: (context, i) {
        final label = _activityItems[i];
        final selected = _selectedActivity == label;
        return GestureDetector(
          onTap: () {
            setState(() => _selectedActivity = label);
            _navigateTo(label);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(SparshSpacing.sm),
            decoration: BoxDecoration(
              color: SparshTheme.cardBackground,
              borderRadius: BorderRadius.circular(SparshBorderRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: SparshTheme.textPrimary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: selected ? SparshTheme.primaryBlueAccent : SparshTheme.borderGrey,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: SparshTheme.primaryBlueAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(SparshSpacing.sm),
                  child: Icon(
                    _activityIcons[label] ?? Icons.assignment,
                    size: SparshIconSize.md,
                    color: SparshTheme.primaryBlueAccent,
                  ),
                ),
                const SizedBox(width: SparshSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: SparshTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: SparshTheme.primaryBlueAccent,
                    ),
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
    if (response.statusCode == 201) {
      debugPrint('✅ Data inserted successfully!');
    } else {
      debugPrint('❌ Data NOT inserted! Error: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SparshTheme.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          ),
        ),
        title: Row(
          children: [
            const Icon(Icons.assignment_outlined, size: SparshIconSize.xxl),
            const SizedBox(width: SparshSpacing.sm),
            Text(
              'DSR Entry',
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: SparshTheme.primaryBlueAccent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(SparshBorderRadius.xl),
            bottomRight: Radius.circular(SparshBorderRadius.xl),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: SparshSpacing.md, vertical: SparshSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions container...
            Container(
              padding: const EdgeInsets.all(SparshSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3),
                borderRadius: BorderRadius.circular(SparshBorderRadius.xl),
                boxShadow: [
                  BoxShadow(
                    color: SparshTheme.textTertiary.withOpacity(0.3),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: SparshSpacing.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Icon(Icons.info_outline,
                          color: Colors.white, size: SparshIconSize.xxl),
                      Text('Instructions',
                          style: SparshTypography.heading5
                              .copyWith(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: SparshSpacing.sm),
                  Text(
                    'Fill in the details below to submit your daily sales report.',
                    style:
                        SparshTypography.body.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SparshSpacing.md),

            // Activity list
            Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(SparshSpacing.md),
                decoration: BoxDecoration(
                  color: SparshTheme.cardBackground,
                  borderRadius: BorderRadius.circular(SparshBorderRadius.xl),
                  boxShadow: [
                    BoxShadow(
                      color: SparshTheme.textTertiary.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: SparshSpacing.xs, bottom: SparshSpacing.xs),
                      child: Text('Activity Type',
                          style: SparshTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: SparshTheme.textPrimary)),
                    ),
                    _buildActivityList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
