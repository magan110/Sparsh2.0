import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class WorkerAttendence extends StatefulWidget {
  const WorkerAttendence({super.key});

  @override
  State<WorkerAttendence> createState() => _WorkerAttendenceState();
}

class _WorkerAttendenceState extends State<WorkerAttendence> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SparshTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Worker Attendance'),
        backgroundColor: SparshTheme.primaryBlueAccent,
        foregroundColor: Colors.white,
      ),
      body: const Column(
        children: [

        ],
      ),
    );
  }
}
