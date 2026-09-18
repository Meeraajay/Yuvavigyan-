import 'package:flutter/material.dart';

import 'widgets/action_button_card.dart';
import '../evaluation_form_page.dart';
import '../attendance_page.dart';
import '../application_form_page.dart';

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

            // ------------------------------------------------------------
            // STUDENT PROFILE
            // ------------------------------------------------------------

            const Text(
              "Student Profile",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    child: Icon(
                      Icons.person,
                      size: 35,
                    ),
                  ),

                  SizedBox(width: 15),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Lakshmi Amma",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text("Age: 68"),
                      Text("Batch: YUVAVIJNAN 2026"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ------------------------------------------------------------
            // CURRENT SESSION
            // ------------------------------------------------------------

            const Text(
              "Current Session",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Session 4",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text("Digital Payments"),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ------------------------------------------------------------
            // LEARNING PROGRESS
            // ------------------------------------------------------------

            const Text(
              "Learning Progress",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Sessions Completed"),
                      Text(
                        "8 / 10",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  LinearProgressIndicator(
                    value: 0.80,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(10),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "80% completed",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ------------------------------------------------------------
            // STUDY MATERIAL STATUS
            // ------------------------------------------------------------

            const Text(
              "Study Material Status",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    title: Text("Video"),
                    trailing: Text("Viewed"),
                  ),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    title: Text("Notes"),
                    trailing: Text("Viewed"),
                  ),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.pending,
                      color: Colors.orange,
                    ),
                    title: Text("Practice Activity"),
                    trailing: Text("Pending"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ------------------------------------------------------------
            // TUTOR ACTIONS
            // ------------------------------------------------------------

            const Text(
              "Tutor Actions",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // Application Form
            ActionButtonCard(
              icon: Icons.description_outlined,
              title: "Application Form",
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const ApplicationFormPage(),
                  ),
                );
              },
            ),

            // Attendance
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

            // Evaluation
            ActionButtonCard(
              icon: Icons.assignment_turned_in,
              title: "Evaluate Assessment",
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const EvaluationFormPage(),
                  ),
                );
              },
            ),

            // Feedback
            ActionButtonCard(
              icon: Icons.feedback,
              title: "Give Feedback",
              color: Colors.deepPurple,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Feedback module is available from the Tutor Dashboard.",
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}