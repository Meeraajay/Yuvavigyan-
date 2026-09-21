import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../application_form_page.dart';
import '../attendance_page.dart';
import '../evaluation_form_page.dart';
import '../feedback_page.dart';
import '../tutor_materials_page.dart';
import 'widgets/action_button_card.dart';

class StudentDetailsPage extends StatefulWidget {
  final String studentId;

  const StudentDetailsPage({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentDetailsPage> createState() =>
      _StudentDetailsPageState();
}

class _StudentDetailsPageState
    extends State<StudentDetailsPage> {
  bool isLoading = true;
  String? errorMessage;

  Map<String, dynamic> student = {};

  @override
  void initState() {
    super.initState();
    _loadStudent();
  }

  Future<void> _loadStudent() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.studentId)
              .get();

      if (!doc.exists ||
          doc.data() == null) {
        throw Exception(
          "Student record was not found.",
        );
      }

      if (!mounted) return;

      setState(() {
        student = doc.data()!;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  String _value(
    List<String> keys, {
    String fallback = "Not provided",
  }) {
    for (final key in keys) {
      final value = student[key];

      if (value != null &&
          value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title:
              const Text("Student Details"),
        ),
        body: const Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title:
              const Text("Student Details"),
        ),
        body: Center(
          child: Padding(
            padding:
                const EdgeInsets.all(24),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Text(
                  "Could not load student details.\n\n"
                  "$errorMessage",
                  textAlign:
                      TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                      errorMessage = null;
                    });

                    _loadStudent();
                  },
                  child:
                      const Text("Retry"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final name = _value(
      [
        'name',
        'fullName',
        'studentName',
      ],
      fallback: 'Student',
    );

    final email = _value(
      ['email'],
      fallback: '',
    );

    final batchId = _value(
      ['batchId'],
      fallback: '',
    );

    final batchName = _value(
      [
        'batchName',
        'batch',
        'batch_name',
      ],
      fallback: 'Not assigned',
    );

    final applicationCompleted =
        student['applicationCompleted'] ==
                true ||
            student['applicationStatus']
                    ?.toString() ==
                'completed';

    final active =
        student['isActive'] != false;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F8FC),
      appBar: AppBar(
        title:
            const Text("Student Details"),
        backgroundColor: Colors.white,
        foregroundColor:
            const Color(0xFF222222),
        elevation: 0.5,
      ),
      body: RefreshIndicator(
        onRefresh: _loadStudent,
        child: ListView(
          padding:
              const EdgeInsets.all(18),
          children: [
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient:
                    const LinearGradient(
                  colors: [
                    Color(0xFF4859B9),
                    Color(0xFF7A89D7),
                  ],
                  begin:
                      Alignment.centerLeft,
                  end:
                      Alignment.centerRight,
                ),
                borderRadius:
                    BorderRadius.circular(
                  22,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor:
                        Colors.white,
                    child: Text(
                      name.isEmpty
                          ? "S"
                          : name[0]
                              .toUpperCase(),
                      style:
                          const TextStyle(
                        fontSize: 26,
                        color: Color(
                          0xFF3F51B5,
                        ),
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          name,
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize: 23,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                        if (email
                            .isNotEmpty) ...[
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            email,
                            style:
                                TextStyle(
                              color: Colors
                                  .white
                                  .withOpacity(
                                0.82,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(
                          height: 8,
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _InfoBadge(
                              icon: Icons
                                  .school_rounded,
                              text:
                                  batchName,
                            ),
                            _InfoBadge(
                              icon: active
                                  ? Icons
                                      .check_circle
                                  : Icons
                                      .cancel,
                              text: active
                                  ? "Active"
                                  : "Inactive",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding:
                  const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
                border: Border.all(
                  color: const Color(
                    0xFFEEF0F5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration:
                        BoxDecoration(
                      color: applicationCompleted
                          ? const Color(
                              0xFFE0F3F1,
                            )
                          : const Color(
                              0xFFFFF0D7,
                            ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                    ),
                    child: Icon(
                      applicationCompleted
                          ? Icons
                              .task_alt_rounded
                          : Icons
                              .pending_actions_rounded,
                      color: applicationCompleted
                          ? const Color(
                              0xFF00897B,
                            )
                          : const Color(
                              0xFFEF6C00,
                            ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        const Text(
                          "Admission Application",
                          style:
                              TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          applicationCompleted
                              ? "Application form completed"
                              : "Application form is pending",
                          style:
                              const TextStyle(
                            color:
                                Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  TextButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ApplicationFormPage(
                            studentId:
                                widget
                                    .studentId,
                          ),
                        ),
                      );

                      _loadStudent();
                    },
                    child: Text(
                      applicationCompleted
                          ? "View / Edit"
                          : "Complete",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Tutor Actions",
              style: TextStyle(
                fontSize: 21,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ActionButtonCard(
              icon:
                  Icons.description_outlined,
              title: applicationCompleted
                  ? "View / Edit Application Form"
                  : "Complete Application Form",
              color:
                  const Color(0xFF3F51B5),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ApplicationFormPage(
                      studentId:
                          widget.studentId,
                    ),
                  ),
                );

                _loadStudent();
              },
            ),

            ActionButtonCard(
              icon: Icons.how_to_reg,
              title: "Mark Attendance",
              color:
                  const Color(0xFF009688),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AttendancePage(
                      studentId:
                          widget.studentId,
                    ),
                  ),
                );
              },
            ),

            ActionButtonCard(
              icon: Icons
                  .assignment_turned_in,
              title: "Evaluate Student",
              color:
                  const Color(0xFFFF9800),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        EvaluationFormPage(
                      studentId:
                          widget.studentId,
                    ),
                  ),
                );
              },
            ),

            ActionButtonCard(
              icon: Icons.feedback_rounded,
              title: "Give Feedback",
              color:
                  const Color(0xFF159BD7),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FeedbackPage(
                      studentId:
                          widget.studentId,
                    ),
                  ),
                );
              },
            ),

            ActionButtonCard(
              icon: Icons.folder_rounded,
              title:
                  "View Learning Materials",
              color:
                  const Color(0xFFE84B59),
              onTap: batchId.isEmpty
                  ? () {
                      ScaffoldMessenger.of(
                              context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "This student does not have a batch assigned yet.",
                          ),
                        ),
                      );
                    }
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TutorMaterialsPage(
                            initialBatchId:
                                batchId,
                            initialBatchName:
                                batchName,
                          ),
                        ),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoBadge({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(
          0.16,
        ),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style:
                const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
