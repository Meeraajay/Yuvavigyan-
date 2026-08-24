import 'package:flutter/material.dart';

import 'widgets/welcome_card.dart';
import 'widgets/dashboard_card.dart';
import 'widgets/task_section.dart';
import 'widgets/students_support_section.dart';
import 'widgets/activity_section.dart';
import 'widgets/quick_action_section.dart';

class TutorHomePage extends StatelessWidget {
  const TutorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    int crossAxisCount;

    if (width >= 1200) {
      crossAxisCount = 4;
    } else if (width >= 700) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 2;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          const WelcomeCard(),

          const SizedBox(height: 30),

          // Overview
          const Text(
            "Overview",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.8,
            children: const [
              DashboardCard(
                title: "Primary Learner",
                value: "Lakshmi Amma",
                subtitle: "Session 4",
                icon: Icons.person,
                color: Colors.blue,
              ),
              DashboardCard(
                title: "Current Session",
                value: "Session 4",
                subtitle: "Digital Payments",
                icon: Icons.menu_book_rounded,
                color: Colors.orange,
              ),
              DashboardCard(
                title: "Pending Assessment",
                value: "1",
                subtitle: "Needs Evaluation",
                icon: Icons.assignment_turned_in_outlined,
                color: Colors.green,
              ),
              DashboardCard(
                title: "Feedback Pending",
                value: "1",
                subtitle: "Submit Today",
                icon: Icons.feedback_outlined,
                color: Colors.purple,
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Today's Session Plan
          const TaskSection(),

          const SizedBox(height: 30),

          // Students Requiring Support
          const StudentsSupportSection(),

          const SizedBox(height: 30),

          // Recent Activity
          const ActivitySection(),

          const SizedBox(height: 30),

          // Quick Actions
          const QuickActionSection(),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}