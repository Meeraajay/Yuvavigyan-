import 'package:flutter/material.dart';

import 'widgets/action_button_card.dart';
import '../evaluation_form_page.dart';
import '../attendance_page.dart';
import '../feedback_page.dart';

class StudentDetailsPage extends StatelessWidget {
  const StudentDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ============================================================
            // STUDENT PROFILE
            // ============================================================

            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [

                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.deepPurple.shade50,
                      child: const Icon(
                        Icons.person,
                        size: 35,
                        color: Colors.deepPurple,
                      ),
                    ),

                    const SizedBox(width: 20),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [

                        Text(
                          "Lakshmi Amma",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text("Age : 68"),

                        Text("Batch : YUVAVIJNAN 2026"),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ============================================================
            // CURRENT SESSION
            // ============================================================

            const Text(
              "Current Session",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: const Icon(Icons.menu_book),
                title: const Text("Session 4"),
                subtitle: const Text("Digital Payments"),
              ),
            ),

            const SizedBox(height: 25),

            // ============================================================
            // LEARNING PROGRESS
            // ============================================================

            const Text(
              "Learning Progress",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [

                    LinearProgressIndicator(
                      value: 0.80,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(10),
                    ),

                    const SizedBox(height: 12),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "8 of 10 Sessions Completed",
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ============================================================
            // STUDY MATERIAL STATUS
            // ============================================================

            const Text(
              "Study Material Status",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Column(
                children: const [

                  ListTile(
                    leading: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    title: Text("Video Viewed"),
                  ),

                  Divider(height: 1),

                  ListTile(
                    leading: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    title: Text("Notes Viewed"),
                  ),

                  Divider(height: 1),

                  ListTile(
                    leading: Icon(
                      Icons.cancel,
                      color: Colors.red,
                    ),
                    title: Text("Practice Activity Pending"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ============================================================
            // TUTOR ACTIONS
            // ============================================================

            const Text(
              "Tutor Actions",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            // ============================================================
            // MARK ATTENDANCE
            // ============================================================

            ActionButtonCard(
              icon: Icons.how_to_reg,
              title: "Mark Attendance",
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AttendancePage(),
                  ),
                );
              },
            ),

            // ============================================================
            // EVALUATE ASSESSMENT
            // ============================================================

            ActionButtonCard(
              icon: Icons.assignment_turned_in,
              title: "Evaluate Assessment",
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EvaluationFormPage(),
                  ),
                );
              },
            ),

            // ============================================================
            // GIVE FEEDBACK
            // ============================================================

            ActionButtonCard(
              icon: Icons.feedback,
              title: "Give Feedback",
              color: Colors.deepPurple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FeedbackPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}