import 'package:flutter/material.dart';

class TelephoneDirectory extends StatelessWidget {
  const TelephoneDirectory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Telephone Directory'),
      ),
      body: const Center(
        child: Text('Telephone Directory Content'),
      ),
    );
  }
}
