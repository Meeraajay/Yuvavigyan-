import 'package:flutter/material.dart';

import 'tutor_home_page.dart';
import 'students/assigned_students_page.dart';
import 'evaluation_history_page.dart';
import 'feedback_page.dart';
import 'reports_page.dart';

class TutorDashboard extends StatefulWidget {
  const TutorDashboard({super.key});

  @override
  State<TutorDashboard> createState() => _TutorDashboardState();
}

class _TutorDashboardState extends State<TutorDashboard> {
  int index = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = [
      TutorHomePage(
        onNavigate: _navigateToPage,
      ),
      const AssignedStudentsPage(),
      const EvaluationHistoryPage(),
      const ReportsPage(),
      const FeedbackPage(),
    ];
  }

  void _navigateToPage(int pageIndex) {
    if (pageIndex < 0 || pageIndex >= pages.length) {
      return;
    }

    setState(() {
      index = pageIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tutor Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Logout will be added later.
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