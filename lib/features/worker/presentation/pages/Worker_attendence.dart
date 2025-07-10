import 'package:flutter/material.dart';

class WorkerAttendence extends StatefulWidget {
  const WorkerAttendence({super.key});

  @override
  State<WorkerAttendence> createState() => _WorkerAttendenceState();
}

class _WorkerAttendenceState extends State<WorkerAttendence> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Attendence'),
      ),
      body: const Column(
        children: [

        ],
      ),
    );
  }
}
