import 'package:flutter/material.dart';

import 'student_details_page.dart';
import 'widgets/batch_info_card.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/student_card.dart';

class AssignedStudentsPage extends StatefulWidget {
  const AssignedStudentsPage({super.key});

  @override
  State<AssignedStudentsPage> createState() => _AssignedStudentsPageState();
}

class _AssignedStudentsPageState extends State<AssignedStudentsPage> {
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> students = [
    {
      "name": "Lakshmi Amma",
      "session": "Session 4 • Digital Payments",
      "progress": 0.80,
      "status": "Pending",
      "color": Colors.orange,
    },
    {
      "name": "Raman Sir",
      "session": "Session 4 • Digital Payments",
      "progress": 0.95,
      "status": "Completed",
      "color": Colors.green,
    },
    {
      "name": "Mary Teacher",
      "session": "Session 4 • Digital Payments",
      "progress": 0.70,
      "status": "Scheduled",
      "color": Colors.blue,
    },
    {
      "name": "Joseph Uncle",
      "session": "Session 4 • Digital Payments",
      "progress": 0.55,
      "status": "Pending",
      "color": Colors.orange,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Assigned Students",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          SearchBarWidget(
            controller: searchController,
          ),

          const SizedBox(height: 20),

          const BatchInfoCard(
            batch: "YUVAVIJNAN 2026",
            session: "Session 4",
            topic: "Digital Payments",
            totalStudents: 24,
          ),

          const SizedBox(height: 25),

          const Text(
            "Student List",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];

              return StudentCard(
                name: student["name"],
                session: student["session"],
                progress: student["progress"],
                assessmentStatus: student["status"],
                statusColor: student["color"],
                onViewDetails: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StudentDetailsPage(),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}