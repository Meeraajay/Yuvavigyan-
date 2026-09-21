import 'package:flutter/material.dart';

import 'tutor_home_page.dart';
import 'tutor_materials_page.dart';
import 'students/assigned_students_page.dart';
import 'evaluation_history_page.dart';
import 'feedback_page.dart';

class TutorDashboard extends StatefulWidget {
  const TutorDashboard({super.key});

  @override
  State<TutorDashboard> createState() => _TutorDashboardState();
}

class _TutorDashboardState extends State<TutorDashboard> {
  int index = 0;

  void _navigateToPage(int pageIndex) {
    if (pageIndex < 0 || pageIndex > 4) return;

    setState(() {
      index = pageIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      TutorHomePage(
        onNavigate: _navigateToPage,
      ),
      const AssignedStudentsPage(),
      const TutorMaterialsPage(),
      const EvaluationHistoryPage(),
      const FeedbackPage(),
    ];

    const destinations = [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: "Home",
      ),
      NavigationDestination(
        icon: Icon(Icons.people_outline_rounded),
        selectedIcon: Icon(Icons.people_alt_rounded),
        label: "Students",
      ),
      NavigationDestination(
        icon: Icon(Icons.folder_outlined),
        selectedIcon: Icon(Icons.folder_rounded),
        label: "Materials",
      ),
      NavigationDestination(
        icon: Icon(Icons.grading_outlined),
        selectedIcon: Icon(Icons.grading_rounded),
        label: "Evaluate",
      ),
      NavigationDestination(
        icon: Icon(Icons.feedback_outlined),
        selectedIcon: Icon(Icons.feedback_rounded),
        label: "Feedback",
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: IndexedStack(
        index: index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: _navigateToPage,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE8EAF6),
        elevation: 8,
        destinations: destinations,
      ),
    );
  }
}
