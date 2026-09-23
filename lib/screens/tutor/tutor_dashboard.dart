import 'package:flutter/material.dart';

import 'tutor_home_page.dart';
import 'tutor_materials_page.dart';
import 'students/assigned_students_page.dart';
import 'tutor_assessments_page.dart';
import 'feedback_page.dart';
import 'tutor_courses_page.dart';

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
  void _openTab(int pageIndex) {
    if (pageIndex < 1 ||
        pageIndex > 5) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _TutorTabPage(
          initialIndex:
              pageIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const destinations = [
      NavigationDestination(
        icon:
            Icon(Icons.home_outlined),
        selectedIcon:
            Icon(Icons.home_rounded),
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

      NavigationDestination(
        icon: Icon(
          Icons.menu_book_outlined,
        ),
        selectedIcon: Icon(
          Icons.menu_book_rounded,
        ),
        label: "Courses",
      ),
    ];

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
// TUTOR TAB ROUTE
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

  void _navigateToPage(
    int pageIndex,
  ) {
    if (pageIndex == 0) {
      Navigator.pop(context);
      return;
    }

    if (pageIndex < 1 ||
        pageIndex > 5) {
      return;
    }

    setState(() {
      index = pageIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const SizedBox.shrink(),

      const AssignedStudentsPage(),

      const TutorMaterialsPage(),

      const TutorAssessmentsPage(),

      const FeedbackPage(),

      const TutorCoursesPage(),
    ];

    const destinations = [
      NavigationDestination(
        icon:
            Icon(Icons.home_outlined),
        selectedIcon:
            Icon(Icons.home_rounded),
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

      NavigationDestination(
        icon: Icon(
          Icons.menu_book_outlined,
        ),
        selectedIcon: Icon(
          Icons.menu_book_rounded,
        ),
        label: "Courses",
      ),
    ];

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F8FC),

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