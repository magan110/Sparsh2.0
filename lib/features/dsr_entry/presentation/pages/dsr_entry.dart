import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

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
        childAspectRatio: 1.18,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _activityItems.length,
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: selected ? const Color(0xFF2196F3) : Colors.grey.shade200,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    _activityIcons[label] ?? Icons.assignment,
                    size: 28,
                    color: const Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2196F3),
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            ),
          ),
          title: Row(
            children: [
              const Icon(Icons.assignment_outlined, size: 28),
              const SizedBox(width: 10),
              Text(
                'DSR Entry',
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF2196F3),
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius:
            BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
          ),
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Icon(Icons.info_outline, color: Colors.white, size: 24),
                            Text('Instructions',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Fill in the details below to submit your daily sales report.',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Activity Information
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 6),
                          child: Text('Activity Type',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                        ),
                        _buildActivityGrid(constraints.maxWidth),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
