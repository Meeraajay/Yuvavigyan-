import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class AllocateStudentsScreen extends StatefulWidget {
  const AllocateStudentsScreen({super.key});

  @override
  State<AllocateStudentsScreen> createState() =>
      _AllocateStudentsScreenState();
}

class _AllocateStudentsScreenState
    extends State<AllocateStudentsScreen> {
  bool isLoading = false;
  bool isAllocating = false;
  bool allocationLocked = false;

  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> tutors = [];

  List<Map<String, String>> allocationResult = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      final allUsers = snapshot.docs.map((doc) {
        final data = doc.data();

        return {
          'id': doc.id,
          'name': data['name'] ?? 'No Name',
          'email': data['email'] ?? '',
          'role': data['role'] ?? '',
          'isActive': data['isActive'] ?? true,
          'assignedTutorId':
              data['assignedTutorId'],
          'studentId': data['studentId'],
        };
      }).toList();

      if (!mounted) return;

      setState(() {
        students = allUsers
            .where(
              (user) =>
                  user['role'] == 'student' &&
                  user['isActive'] == true,
            )
            .toList();

        tutors = allUsers
            .where(
              (user) =>
                  user['role'] == 'tutor' &&
                  user['isActive'] == true,
            )
            .toList();
      });

      _loadExistingResults(
        students,
        tutors,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error loading users: $e',
          ),
        ),
      );
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _loadExistingResults(
    List<Map<String, dynamic>> currentStudents,
    List<Map<String, dynamic>> currentTutors,
  ) {
    final results =
        <Map<String, String>>[];

    for (var student in currentStudents) {
      final tutorId =
          student['assignedTutorId'];

      if (tutorId != null &&
          tutorId.toString().isNotEmpty) {
        final tutorName =
            currentTutors.firstWhere(
          (tutor) =>
              tutor['id'] == tutorId,
          orElse: () => {
            'name': 'Unknown Tutor',
          },
        )['name'];

        results.add({
          'studentName':
              student['name'].toString(),
          'tutorName':
              tutorName.toString(),
          'status': 'Assigned',
        });
      } else {
        results.add({
          'studentName':
              student['name'].toString(),
          'tutorName': 'No Tutor',
          'status': 'Not Applicable',
        });
      }
    }

    for (var tutor in currentTutors) {
      bool hasStudent =
          currentStudents.any(
        (student) =>
            student['assignedTutorId'] ==
            tutor['id'],
      );

      if (!hasStudent) {
        results.add({
          'studentName': 'No Student',
          'tutorName':
              tutor['name'].toString(),
          'status': 'Not Applicable',
        });
      }
    }

    if (!mounted) return;

    if (results.isNotEmpty) {
      setState(() {
        allocationResult = results;

        allocationLocked =
            currentStudents.any(
          (student) =>
              student['assignedTutorId'] != null &&
              student['assignedTutorId']
                  .toString()
                  .isNotEmpty,
        );
      });
    } else {
      setState(() {
        allocationResult = [];
        allocationLocked = false;
      });
    }
  }

  Future<void> allocateStudents() async {
    if (allocationLocked) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Allocation already saved. Press Reset first.',
          ),
        ),
      );

      return;
    }

    if (students.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'No active students found.',
          ),
        ),
      );

      return;
    }

    if (tutors.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'No active tutors found.',
          ),
        ),
      );

      return;
    }

    setState(() {
      isAllocating = true;
      allocationResult = [];
    });

    try {
      final shuffledStudents =
          List<Map<String, dynamic>>.from(
        students,
      )..shuffle(Random());

      final shuffledTutors =
          List<Map<String, dynamic>>.from(
        tutors,
      )..shuffle(Random());

      final batch =
          FirebaseFirestore.instance.batch();

      final results =
          <Map<String, String>>[];

      final pairCount =
          shuffledStudents.length <
                  shuffledTutors.length
              ? shuffledStudents.length
              : shuffledTutors.length;

      for (int i = 0;
          i < pairCount;
          i++) {
        final student =
            shuffledStudents[i];

        final tutor =
            shuffledTutors[i];

        batch.update(
          FirebaseFirestore.instance
              .collection('users')
              .doc(student['id']),
          {
            'assignedTutorId':
                tutor['id'],
          },
        );

        results.add({
          'studentName':
              student['name'].toString(),
          'tutorName':
              tutor['name'].toString(),
          'status': 'Assigned',
        });
      }

      for (int i = pairCount;
          i < shuffledStudents.length;
          i++) {
        final student =
            shuffledStudents[i];

        batch.update(
          FirebaseFirestore.instance
              .collection('users')
              .doc(student['id']),
          {
            'assignedTutorId': null,
          },
        );

        results.add({
          'studentName':
              student['name'].toString(),
          'tutorName': 'No Tutor',
          'status': 'Not Applicable',
        });
      }

      for (int i = pairCount;
          i < shuffledTutors.length;
          i++) {
        final tutor =
            shuffledTutors[i];

        results.add({
          'studentName': 'No Student',
          'tutorName':
              tutor['name'].toString(),
          'status': 'Not Applicable',
        });
      }

      await batch.commit();

      if (!mounted) return;

      setState(() {
        allocationResult = results;
        allocationLocked = true;
      });

      await fetchUsers();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Allocation Saved Successfully ✅',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Error allocating: $e',
          ),
        ),
      );
    }

    if (mounted) {
      setState(() {
        isAllocating = false;
      });
    }
  }

  Future<void> resetAllocations() async {
    try {
      setState(() {
        isLoading = true;
      });

      final query =
          await FirebaseFirestore.instance
              .collection('users')
              .where(
                'role',
                isEqualTo: 'student',
              )
              .where(
                'isActive',
                isEqualTo: true,
              )
              .get();

      final batch =
          FirebaseFirestore.instance.batch();

      for (var doc in query.docs) {
        batch.update(
          doc.reference,
          {
            'assignedTutorId': null,
          },
        );
      }

      await batch.commit();

      if (!mounted) return;

      setState(() {
        allocationResult = [];
        allocationLocked = false;
      });

      await fetchUsers();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'All allocations reset ✅',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Reset error: $e',
          ),
        ),
      );
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Student Allocation",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(
                              16),
                      decoration: BoxDecoration(
                        color: allocationLocked
                            ? const Color(
                                0xFFECFDF5)
                            : const Color(
                                0xFFFFFBEB),
                        borderRadius:
                            BorderRadius.circular(
                                14),
                        border: Border.all(
                          color: allocationLocked
                              ? const Color(
                                  0xFFA7F3D0)
                              : const Color(
                                  0xFFFDE68A),
                        ),
                      ),

                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration:
                                BoxDecoration(
                              color: allocationLocked
                                  ? const Color(
                                      0xFFD1FAE5)
                                  : const Color(
                                      0xFFFEF3C7),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          12),
                            ),
                            child: Icon(
                              allocationLocked
                                  ? Icons
                                      .lock_rounded
                                  : Icons
                                      .lock_open_rounded,
                              color: allocationLocked
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),

                          const SizedBox(
                              width: 13),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  allocationLocked
                                      ? "Allocation Saved"
                                      : "Ready to Allocate",
                                  style:
                                      TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    color: allocationLocked
                                        ? Colors
                                            .green
                                            .shade800
                                        : Colors
                                            .orange
                                            .shade900,
                                  ),
                                ),

                                const SizedBox(
                                    height: 3),

                                Text(
                                  allocationLocked
                                      ? "Student-tutor assignments are saved."
                                      : "Click Allocate Randomly to assign tutors.",
                                  style:
                                      TextStyle(
                                    fontSize: 13,
                                    color: allocationLocked
                                        ? Colors
                                            .green
                                            .shade700
                                        : Colors
                                            .orange
                                            .shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            "Active Students",
                            students.length,
                            Icons
                                .school_rounded,
                            const Color(
                                0xFF2563EB),
                          ),
                        ),

                        const SizedBox(
                            width: 14),

                        Expanded(
                          child: _statCard(
                            "Active Tutors",
                            tutors.length,
                            Icons
                                .person_rounded,
                            const Color(
                                0xFF059669),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child:
                          ElevatedButton.icon(
                        onPressed:
                            isAllocating ||
                                    allocationLocked
                                ? null
                                : allocateStudents,

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(
                                  0xFF2563EB),
                          foregroundColor:
                              Colors.white,
                          elevation: 0,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        12),
                          ),
                        ),

                        icon: isAllocating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2,
                                  color: Colors
                                      .white,
                                ),
                              )
                            : const Icon(
                                Icons
                                    .shuffle_rounded,
                              ),

                        label: Text(
                          isAllocating
                              ? "Allocating..."
                              : allocationLocked
                                  ? "Allocation Locked"
                                  : "Allocate Randomly",
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child:
                          OutlinedButton.icon(
                        onPressed:
                            resetAllocations,

                        style:
                            OutlinedButton.styleFrom(
                          foregroundColor:
                              Colors.red,
                          side:
                              const BorderSide(
                            color: Color(
                                0xFFFCA5A5),
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        12),
                          ),
                        ),

                        icon: const Icon(
                          Icons.refresh_rounded,
                        ),

                        label: const Text(
                          "Reset All Assignments",
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    Row(
                      children: [
                        const Text(
                          "Allocation Results",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                            color: Color(
                                0xFF1F2937),
                          ),
                        ),

                        const Spacer(),

                        Text(
                          "${allocationResult.length} results",
                          style:
                              const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Expanded(
                      child:
                          allocationResult
                                  .isEmpty
                              ? const Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      CircleAvatar(
                                        radius: 35,
                                        backgroundColor:
                                            Color(
                                                0xFFEFF6FF),
                                        child:
                                            Icon(
                                          Icons
                                              .account_tree_outlined,
                                          size:
                                              35,
                                          color:
                                              Color(
                                                  0xFF2563EB),
                                        ),
                                      ),
                                      SizedBox(
                                          height:
                                              15),
                                      Text(
                                        "No allocations yet",
                                        style:
                                            TextStyle(
                                          fontSize:
                                              17,
                                          fontWeight:
                                              FontWeight
                                                  .w600,
                                        ),
                                      ),
                                      SizedBox(
                                          height:
                                              5),
                                      Text(
                                        "Use Allocate Randomly to assign students.",
                                        textAlign:
                                            TextAlign
                                                .center,
                                        style:
                                            TextStyle(
                                          color: Colors
                                              .grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount:
                                      allocationResult
                                          .length,

                                  itemBuilder:
                                      (context,
                                          index) {
                                    final item =
                                        allocationResult[
                                            index];

                                    final isNA =
                                        item['status'] ==
                                            'Not Applicable';

                                    return Container(
                                      margin:
                                          const EdgeInsets
                                              .only(
                                              bottom:
                                                  10),
                                      padding:
                                          const EdgeInsets
                                              .all(
                                              15),

                                      decoration:
                                          BoxDecoration(
                                        color:
                                            Colors.white,
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                                    14),
                                        border:
                                            Border.all(
                                          color:
                                              const Color(
                                                  0xFFE5E7EB),
                                        ),
                                      ),

                                      child: Row(
                                        children: [
                                          Container(
                                            width:
                                                44,
                                            height:
                                                44,
                                            decoration:
                                                BoxDecoration(
                                              color: isNA
                                                  ? const Color(
                                                      0xFFFFF7ED)
                                                  : const Color(
                                                      0xFFECFDF5),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      12),
                                            ),
                                            child:
                                                Icon(
                                              isNA
                                                  ? Icons.warning_amber_rounded
                                                  : Icons.check_circle_rounded,
                                              color: isNA
                                                  ? Colors.orange
                                                  : Colors.green,
                                            ),
                                          ),

                                          const SizedBox(
                                              width:
                                                  14),

                                          Expanded(
                                            child:
                                                Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${item['studentName']}  →  ${item['tutorName']}",
                                                  style:
                                                      const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w600,
                                                    fontSize:
                                                        15,
                                                  ),
                                                ),

                                                const SizedBox(
                                                    height:
                                                        4),

                                                Text(
                                                  "Status: ${item['status']}",
                                                  style:
                                                      TextStyle(
                                                    fontSize:
                                                        12,
                                                    color: isNA
                                                        ? Colors.orange
                                                        : Colors.green,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _statCard(
    String label,
    int count,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  "$count",
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight:
                        FontWeight.bold,
                    color: color,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}