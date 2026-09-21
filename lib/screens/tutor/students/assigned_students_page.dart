import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'student_details_page.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/student_card.dart';

class AssignedStudentsPage extends StatefulWidget {
  const AssignedStudentsPage({super.key});

  @override
  State<AssignedStudentsPage> createState() =>
      _AssignedStudentsPageState();
}

class _AssignedStudentsPageState
    extends State<AssignedStudentsPage> {
  final TextEditingController searchController =
      TextEditingController();

  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>>
      filteredStudents = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    fetchAssignedStudents();
    searchController.addListener(
      filterStudents,
    );
  }

  Future<void> fetchAssignedStudents() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final currentUser =
          FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception(
          "No tutor is currently logged in.",
        );
      }

      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where(
                'assignedTutorId',
                isEqualTo:
                    currentUser.uid,
              )
              .get();

      final fetchedStudents =
          snapshot.docs
              .where(
                (doc) {
                  final data = doc.data();

                  return data['role']
                              ?.toString() ==
                          'student' &&
                      data['isActive'] !=
                          false;
                },
              )
              .map(
                (doc) {
                  final data = doc.data();

                  return <
                      String,
                      dynamic>{
                    'id': doc.id,
                    'name':
                        data['name'] ??
                            'No Name',
                    'email':
                        data['email'] ??
                            '',
                    'batchId':
                        data['batchId'] ??
                            '',
                    'batchName':
                        data['batchName'] ??
                            '',
                    'applicationCompleted':
                        data['applicationCompleted'] ==
                                true ||
                            data['applicationStatus']
                                    ?.toString() ==
                                'completed',
                  };
                },
              )
              .toList();

      fetchedStudents.sort(
        (a, b) => a['name']
            .toString()
            .toLowerCase()
            .compareTo(
              b['name']
                  .toString()
                  .toLowerCase(),
            ),
      );

      if (!mounted) return;

      setState(() {
        students = fetchedStudents;
        filteredStudents =
            List<Map<String, dynamic>>.from(
          fetchedStudents,
        );
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Error loading students: $e",
          ),
        ),
      );
    }
  }

  void filterStudents() {
    final query = searchController.text
        .trim()
        .toLowerCase();

    if (!mounted) return;

    setState(() {
      if (query.isEmpty) {
        filteredStudents =
            List<Map<String, dynamic>>.from(
          students,
        );
        return;
      }

      filteredStudents =
          students.where(
        (student) {
          final name = student['name']
              .toString()
              .toLowerCase();

          final email = student['email']
              .toString()
              .toLowerCase();

          final batch = student['batchName']
              .toString()
              .toLowerCase();

          return name.contains(query) ||
              email.contains(query) ||
              batch.contains(query);
        },
      ).toList();
    });
  }

  @override
  void dispose() {
    searchController.removeListener(
      filterStudents,
    );
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uniqueBatchCount = students
        .map(
          (student) =>
              student['batchId']
                  ?.toString() ??
              '',
        )
        .where(
          (batchId) =>
              batchId.isNotEmpty,
        )
        .toSet()
        .length;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F8FC),
      appBar: AppBar(
        title:
            const Text("My Students"),
        backgroundColor: Colors.white,
        foregroundColor:
            const Color(0xFF222222),
        elevation: 0.5,
      ),
      body: RefreshIndicator(
        onRefresh: fetchAssignedStudents,
        child: ListView(
          padding:
              const EdgeInsets.all(18),
          children: [
            const Text(
              "Assigned Students",
              style: TextStyle(
                fontSize: 26,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "${students.length} student"
              "${students.length == 1 ? '' : 's'} "
              "across $uniqueBatchCount batch"
              "${uniqueBatchCount == 1 ? '' : 'es'}",
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 18),

            SearchBarWidget(
              controller:
                  searchController,
            ),

            const SizedBox(height: 20),

            if (isLoading)
              const Center(
                child: Padding(
                  padding:
                      EdgeInsets.all(40),
                  child:
                      CircularProgressIndicator(),
                ),
              )
            else if (students.isEmpty)
              const Padding(
                padding:
                    EdgeInsets.symmetric(
                  vertical: 70,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons
                          .people_outline_rounded,
                      size: 70,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      height: 14,
                    ),
                    Text(
                      "No students are assigned to you yet.",
                      textAlign:
                          TextAlign.center,
                      style:
                          TextStyle(
                        color:
                            Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            else if (filteredStudents
                .isEmpty)
              const Padding(
                padding:
                    EdgeInsets.symmetric(
                  vertical: 60,
                ),
                child: Text(
                  "No matching students found.",
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              )
            else
              ...filteredStudents.map(
                (student) =>
                    StudentCard(
                  name: student['name']
                      .toString(),
                  email: student[
                          'email']
                      .toString(),
                  batchName: student[
                              'batchName']
                          ?.toString()
                          .trim()
                          .isNotEmpty ==
                      true
                      ? student[
                              'batchName']
                          .toString()
                      : "Batch not assigned",
                  applicationCompleted:
                      student[
                              'applicationCompleted'] ==
                          true,
                  onViewDetails: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            StudentDetailsPage(
                          studentId:
                              student['id']
                                  .toString(),
                        ),
                      ),
                    ).then(
                      (_) =>
                          fetchAssignedStudents(),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
