import 'package:flutter/material.dart';

import 'tutor_home_page.dart';
import 'students/assigned_students_page.dart';
import 'evaluation_form_page.dart';

class TutorDashboard extends StatefulWidget {
  const TutorDashboard({super.key});

  @override
  State<TutorDashboard> createState() => _TutorDashboardState();
}

class _TutorDashboardState extends State<TutorDashboard> {
  int index = 0;

  final pages = const [
    TutorHomePage(),
    AssignedStudentsPage(),
    EvaluationFormPage(),
    ReportsPage(),
    FeedbackPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tutor Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Logout Later
            },
          ),
        ],
      ),
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (value) {
          setState(() {
            index = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: "Students",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grading_rounded),
            label: "Evaluate",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: "Reports",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback_outlined),
            label: "Feedback",
          ),
        ],
      ),
    );
  }
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Reports Module\nComing Soon",
        textAlign: TextAlign.center,
      ),
    );
  }
}

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Feedback Module\nComing Soon",
        textAlign: TextAlign.center,
      ),
    );
  }
}