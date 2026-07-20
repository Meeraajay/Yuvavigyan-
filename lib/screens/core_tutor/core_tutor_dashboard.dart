import 'package:flutter/material.dart';

class CoreTutorDashboard extends StatelessWidget {
  const CoreTutorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Core Tutor Dashboard")),
      body: const Center(
        child: Text("Welcome Core Tutor"),
      ),
    );
  }
}