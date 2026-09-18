import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    fetchAssignedStudents();

    searchController.addListener(() {
      filterStudents();
    });
  }

  Future<void> fetchAssignedStudents() async {
    setState(() {
      isLoading = true;
    });

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('No tutor is currently logged in.');
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(
            'assignedTutorId',
            isEqualTo: currentUser.uid,
          )
          .get();

      final fetchedStudents = snapshot.docs.map((doc) {
        final data = doc.data();

        return {
          'id': doc.id,
          'name': data['name'] ?? 'No Name',
          'email': data['email'] ?? '',
          'progress': data['progress'] ?? 0.0,
          'status': data['status'] ?? 'Pending',
        };
      }).toList();

      if (!mounted) return;

      setState(() {
        students = fetchedStudents;
        filteredStudents = fetchedStudents;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading students: $e'),
        ),
      );
    }
  }

  void filterStudents() {
    final query = searchController.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredStudents = students;
      } else {
        filteredStudents = students.where((student) {
          final name = student['name'].toString().toLowerCase();
          final email = student['email'].toString().toLowerCase();

          return name.contains(query) || email.contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: fetchAssignedStudents,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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

            BatchInfoCard(
              batch: "YUVAVIJNAN 2026",
              session: "Assigned Students",
              topic: "Student Learning",
              totalStudents: students.length,
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

            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (students.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 60,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 12),
                      Text(
                        "No students assigned yet.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (filteredStudents.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Text(
                    "No students found.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredStudents.length,
                itemBuilder: (context, index) {
                  final student = filteredStudents[index];

                  final double progress =
                      (student['progress'] as num?)?.toDouble() ?? 0.0;

                  final String status =
                      student['status']?.toString() ?? 'Pending';

                  Color statusColor;

                  switch (status.toLowerCase()) {
                    case 'completed':
                      statusColor = Colors.green;
                      break;

                    case 'scheduled':
                      statusColor = Colors.blue;
                      break;

                    default:
                      statusColor = Colors.orange;
                  }

                  return StudentCard(
                    name: student['name'],
                    session: "Assigned Student",
                    progress: progress,
                    assessmentStatus: status,
                    statusColor: statusColor,
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
      ),
    );
  }
}