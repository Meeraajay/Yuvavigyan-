import 'package:flutter/material.dart';

import 'tutor_home_page.dart';
import 'tutor_materials_page.dart';
import 'students/assigned_students_page.dart';
import 'tutor_assessments_page.dart';
import 'feedback_page.dart';

// ============================================================
// TUTOR DASHBOARD
// ============================================================

class TutorDashboard extends StatefulWidget {
  const TutorDashboard({
    super.key,
  });

  @override
  State<TutorDashboard> createState() =>
      _TutorDashboardState();
}

class _TutorDashboardState
    extends State<TutorDashboard> {
  // ==========================================================
  // OPEN A TUTOR TAB AS A REAL PAGE
  // ==========================================================
  //
  // Because Students / Materials / Assessments / Feedback
  // are opened using Navigator.push(), Flutter automatically
  // shows the back arrow in their existing AppBars.
  //
  // Back arrow -> Tutor Home
  //
  // ==========================================================

  void _openTab(int pageIndex) {
    if (pageIndex < 1 || pageIndex > 4) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _TutorTabPage(
          initialIndex: pageIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const destinations = [
      NavigationDestination(
        icon: Icon(
          Icons.home_outlined,
        ),
        selectedIcon: Icon(
          Icons.home_rounded,
        ),
        label: "Home",
      ),

      NavigationDestination(
        icon: Icon(
          Icons.people_outline_rounded,
        ),
        selectedIcon: Icon(
          Icons.people_alt_rounded,
        ),
        label: "Students",
      ),

      NavigationDestination(
        icon: Icon(
          Icons.folder_outlined,
        ),
        selectedIcon: Icon(
          Icons.folder_rounded,
        ),
        label: "Materials",
      ),

      NavigationDestination(
        icon: Icon(
          Icons.grading_outlined,
        ),
        selectedIcon: Icon(
          Icons.grading_rounded,
        ),
        label: "Assessments",
      ),

      NavigationDestination(
        icon: Icon(
          Icons.feedback_outlined,
        ),
        selectedIcon: Icon(
          Icons.feedback_rounded,
        ),
        label: "Feedback",
      ),
    ];

    // ==========================================================
    // HOME IS THE ROOT PAGE
    // ==========================================================

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F8FC),

      body: TutorHomePage(
        onNavigate: _openTab,
      ),

      bottomNavigationBar:
          NavigationBar(
        selectedIndex: 0,

        onDestinationSelected:
            (pageIndex) {
          if (pageIndex == 0) {
            return;
          }

          _openTab(pageIndex);
        },

        backgroundColor:
            Colors.white,

        indicatorColor:
            const Color(
          0xFFE8EAF6,
        ),

        elevation: 8,

        destinations:
            destinations,
      ),
    );
  }
}

// ============================================================
// TUTOR SUB PAGE
// ============================================================
//
// This is used for:
// 1 -> Students
// 2 -> Materials
// 3 -> Assessments
// 4 -> Feedback
//
// Since this widget is opened with Navigator.push(),
// the AppBars inside these pages automatically display:
//
// ←
//
// Pressing that arrow pops this route and returns to Home.
//
// ============================================================

class _TutorTabPage
    extends StatefulWidget {
  final int initialIndex;

  const _TutorTabPage({
    required this.initialIndex,
  });

  @override
  State<_TutorTabPage> createState() =>
      _TutorTabPageState();
}

class _TutorTabPageState
    extends State<_TutorTabPage> {
  late int index;

  @override
  void initState() {
    super.initState();

    index = widget.initialIndex;
  }

  // ==========================================================
  // BOTTOM NAVIGATION
  // ==========================================================

  void _navigateToPage(
    int pageIndex,
  ) {
    // Home
    if (pageIndex == 0) {
      Navigator.pop(context);
      return;
    }

    if (pageIndex < 1 ||
        pageIndex > 4) {
      return;
    }

    setState(() {
      index = pageIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      // Index 0 is never displayed here.
      // Selecting Home pops this route.
      const SizedBox.shrink(),

      const AssignedStudentsPage(),

      const TutorMaterialsPage(),

      const TutorAssessmentsPage(),

      const FeedbackPage(),
    ];

    const destinations = [
      NavigationDestination(
        icon: Icon(
          Icons.home_outlined,
        ),
        selectedIcon: Icon(
          Icons.home_rounded,
        ),
        label: "Home",
      ),

      NavigationDestination(
        icon: Icon(
          Icons.people_outline_rounded,
        ),
        selectedIcon: Icon(
          Icons.people_alt_rounded,
        ),
        label: "Students",
      ),

      NavigationDestination(
        icon: Icon(
          Icons.folder_outlined,
        ),
        selectedIcon: Icon(
          Icons.folder_rounded,
        ),
        label: "Materials",
      ),

      NavigationDestination(
        icon: Icon(
          Icons.grading_outlined,
        ),
        selectedIcon: Icon(
          Icons.grading_rounded,
        ),
        label: "Assessments",
      ),

      NavigationDestination(
        icon: Icon(
          Icons.feedback_outlined,
        ),
        selectedIcon: Icon(
          Icons.feedback_rounded,
        ),
        label: "Feedback",
      ),
    ];

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F8FC),

      // IndexedStack keeps each Tutor tab alive
      // while moving between tabs.
      body: IndexedStack(
        index: index,
        children: pages,
      ),

      bottomNavigationBar:
          NavigationBar(
        selectedIndex: index,

        onDestinationSelected:
            _navigateToPage,

        backgroundColor:
            Colors.white,

        indicatorColor:
            const Color(
          0xFFE8EAF6,
        ),

        elevation: 8,

        destinations:
            destinations,
      ),
    );
  }
}