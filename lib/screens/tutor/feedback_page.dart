import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FeedbackPage extends StatefulWidget {
  final String? studentId;

  const FeedbackPage({
    super.key,
    this.studentId,
  });

  @override
  State<FeedbackPage> createState() =>
      _FeedbackPageState();
}

class _FeedbackPageState
    extends State<FeedbackPage> {
  double rating = 3;
  String selectedCategory = "General";

  final TextEditingController
      feedbackController =
      TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  List<Map<String, dynamic>>
      assignedStudents = [];

  String? selectedStudentId;

  @override
  void initState() {
    super.initState();

    selectedStudentId =
        widget.studentId;

    _loadAssignedStudents();
  }

  @override
  void dispose() {
    feedbackController.dispose();
    super.dispose();
  }

  Future<void>
      _loadAssignedStudents() async {
    try {
      final tutor =
          FirebaseAuth.instance.currentUser;

      if (tutor == null) {
        throw Exception(
          "No tutor is currently logged in.",
        );
      }

      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where(
                'assignedTutorId',
                isEqualTo: tutor.uid,
              )
              .get();

      final students =
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
                            'Student',
                    'email':
                        data['email'] ??
                            '',
                    'batchId':
                        data['batchId'] ??
                            '',
                    'batchName':
                        data['batchName'] ??
                            '',
                  };
                },
              )
              .toList();

      students.sort(
        (a, b) => a['name']
            .toString()
            .compareTo(
              b['name'].toString(),
            ),
      );

      if (selectedStudentId != null &&
          !students.any(
            (student) =>
                student['id'] ==
                selectedStudentId,
          )) {
        selectedStudentId = null;
      }

      if (selectedStudentId == null &&
          students.length == 1) {
        selectedStudentId =
            students.first['id']
                .toString();
      }

      if (!mounted) return;

      setState(() {
        assignedStudents = students;
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
            "Could not load assigned students: $e",
          ),
        ),
      );
    }
  }

  Map<String, dynamic>?
      _selectedStudent() {
    if (selectedStudentId == null) {
      return null;
    }

    for (final student
        in assignedStudents) {
      if (student['id'] ==
          selectedStudentId) {
        return student;
      }
    }

    return null;
  }

  Future<void> _saveFeedback() async {
    final student =
        _selectedStudent();

    if (student == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Please select a student.",
          ),
        ),
      );
      return;
    }

    final message =
        feedbackController.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter feedback before saving.",
          ),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final tutor =
          FirebaseAuth.instance.currentUser;

      if (tutor == null) {
        throw Exception(
          "No tutor is currently logged in.",
        );
      }

      final tutorDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(tutor.uid)
              .get();

      final tutorName =
          tutorDoc.data()?['name']
                  ?.toString() ??
              'Tutor';

      await FirebaseFirestore.instance
          .collection('tutor_feedback')
          .add({
        'studentId':
            student['id'],
        'studentName':
            student['name'],
        'studentEmail':
            student['email'],
        'batchId':
            student['batchId'],
        'batchName':
            student['batchName'],
        'tutorId': tutor.uid,
        'tutorName':
            tutorName,
        'category':
            selectedCategory,
        'rating': rating.toInt(),
        'message': message,
        'readByStudent': false,
        'createdAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      feedbackController.clear();

      setState(() {
        rating = 3;
        selectedCategory =
            "General";
        isSaving = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Feedback Saved Successfully",
          ),
          backgroundColor:
              Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Could not save feedback: $e",
          ),
        ),
      );
    }
  }

  Widget _buildGiveFeedback() {
    final selected =
        _selectedStudent();

    if (isLoading) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (assignedStudents.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            "No students are assigned to you yet.",
            textAlign:
                TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      padding:
          const EdgeInsets.all(18),
      children: [
        const Text(
          "Give Feedback",
          style: TextStyle(
            fontSize: 26,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          "Save structured feedback for one of your assigned students.",
          style: TextStyle(
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 20),

        _CardSection(
          title: "Student",
          child:
              DropdownButtonFormField<
                  String>(
            initialValue:
                selectedStudentId,
            isExpanded: true,
            decoration:
                InputDecoration(
              labelText:
                  "Select Student",
              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius
                        .circular(
                  12,
                ),
              ),
            ),
            items: assignedStudents
                .map(
                  (student) =>
                      DropdownMenuItem<
                          String>(
                    value: student['id']
                        .toString(),
                    child: Text(
                      student['name']
                          .toString(),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedStudentId =
                    value;
              });
            },
          ),
          footer: selected != null
              ? Text(
                  selected['batchName']
                              ?.toString()
                              .isNotEmpty ==
                          true
                      ? "Batch: ${selected['batchName']}"
                      : "Batch not assigned",
                  style:
                      const TextStyle(
                    color:
                        Colors.grey,
                  ),
                )
              : null,
        ),

        const SizedBox(height: 16),

        _CardSection(
          title:
              "Feedback Category",
          child:
              DropdownButtonFormField<
                  String>(
            initialValue:
                selectedCategory,
            decoration:
                InputDecoration(
              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius
                        .circular(
                  12,
                ),
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: "General",
                child:
                    Text("General"),
              ),
              DropdownMenuItem(
                value:
                    "Understanding",
                child: Text(
                  "Understanding",
                ),
              ),
              DropdownMenuItem(
                value:
                    "Participation",
                child: Text(
                  "Participation",
                ),
              ),
              DropdownMenuItem(
                value: "Practice",
                child:
                    Text("Practice"),
              ),
              DropdownMenuItem(
                value:
                    "Improvement",
                child: Text(
                  "Needs Improvement",
                ),
              ),
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }

              setState(() {
                selectedCategory =
                    value;
              });
            },
          ),
        ),

        const SizedBox(height: 16),

        _CardSection(
          title:
              "Student Performance Rating",
          child: Column(
            children: [
              Slider(
                value: rating,
                min: 1,
                max: 5,
                divisions: 4,
                label: rating
                    .toInt()
                    .toString(),
                onChanged: (value) {
                  setState(() {
                    rating = value;
                  });
                },
              ),
              Text(
                "${rating.toInt()} / 5",
                style:
                    const TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight
                          .bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        _CardSection(
          title: "Tutor Feedback",
          child: TextField(
            controller:
                feedbackController,
            maxLines: 6,
            decoration:
                InputDecoration(
              hintText:
                  "Enter feedback about the student...",
              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius
                        .circular(
                  12,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        SizedBox(
          height: 52,
          child:
              ElevatedButton.icon(
            onPressed: isSaving
                ? null
                : _saveFeedback,
            icon: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.save,
                  ),
            label: Text(
              isSaving
                  ? "Saving..."
                  : "Save Feedback",
            ),
            style:
                ElevatedButton
                    .styleFrom(
              backgroundColor:
                  const Color(
                0xFF3F51B5,
              ),
              foregroundColor:
                  Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _markStudentMessagesRead() async {
    final tutor =
        FirebaseAuth.instance.currentUser;

    if (tutor == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('feedback')
            .where(
              'tutorId',
              isEqualTo: tutor.uid,
            )
            .get();

    final batch =
        FirebaseFirestore.instance.batch();

    bool hasChanges = false;

    for (final doc in snapshot.docs) {
      if (doc.data()['readByTutor'] != true) {
        batch.update(
          doc.reference,
          {
            'readByTutor': true,
            'readByTutorAt':
                FieldValue.serverTimestamp(),
          },
        );

        hasChanges = true;
      }
    }

    if (hasChanges) {
      await batch.commit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tutorId =
        FirebaseAuth
            .instance.currentUser?.uid;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor:
            const Color(
          0xFFF7F8FC,
        ),
        appBar: AppBar(
          title:
              const Text("Feedback"),
          backgroundColor:
              Colors.white,
          foregroundColor:
              const Color(
            0xFF222222,
          ),
          elevation: 0.5,
          bottom: TabBar(
            onTap: (index) {
              if (index == 1) {
                _markStudentMessagesRead();
              }
            },
            tabs: const [
              Tab(
                icon: Icon(
                  Icons
                      .rate_review_outlined,
                ),
                text: "Give Feedback",
              ),
              Tab(
                icon: Icon(
                  Icons
                      .inbox_outlined,
                ),
                text:
                    "Student Messages",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildGiveFeedback(),
            tutorId == null
                ? const Center(
                    child: Text(
                      "Tutor login not found.",
                    ),
                  )
                : _ReceivedFeedbackList(
                    tutorId:
                        tutorId,
                  ),
          ],
        ),
      ),
    );
  }
}

class _ReceivedFeedbackList
    extends StatelessWidget {
  final String tutorId;

  const _ReceivedFeedbackList({
    required this.tutorId,
  });

  String _formatDate(
    dynamic value,
  ) {
    if (value is! Timestamp) {
      return "";
    }

    final date = value.toDate();

    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<
        QuerySnapshot<
            Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance
              .collection('feedback')
              .where(
                'tutorId',
                isEqualTo: tutorId,
              )
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child:
                CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding:
                  const EdgeInsets.all(
                24,
              ),
              child: Text(
                "Could not load student messages.\n\n"
                "${snapshot.error}",
                textAlign:
                    TextAlign.center,
              ),
            ),
          );
        }

        final docs =
            snapshot.data?.docs.toList() ??
                [];

        docs.sort(
          (a, b) {
            final aValue =
                a.data()['createdAt'];
            final bValue =
                b.data()['createdAt'];

            final aDate =
                aValue is Timestamp
                    ? aValue.toDate()
                    : DateTime(1970);

            final bDate =
                bValue is Timestamp
                    ? bValue.toDate()
                    : DateTime(1970);

            return bDate.compareTo(
              aDate,
            );
          },
        );

        if (docs.isEmpty) {
          return const Center(
            child: Padding(
              padding:
                  EdgeInsets.all(24),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Icon(
                    Icons
                        .inbox_outlined,
                    size: 70,
                    color:
                        Colors.grey,
                  ),
                  SizedBox(
                    height: 14,
                  ),
                  Text(
                    "No feedback messages received from students yet.",
                    textAlign:
                        TextAlign.center,
                    style:
                        TextStyle(
                      color:
                          Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding:
              const EdgeInsets.all(
            18,
          ),
          itemCount: docs.length,
          itemBuilder:
              (context, index) {
            final data =
                docs[index].data();

            final studentName =
                data['studentName']
                        ?.toString() ??
                    'Student';

            final message =
                data['message']
                        ?.toString() ??
                    '';

            final batchName =
                data['batchName']
                        ?.toString() ??
                    '';

            return Container(
              margin:
                  const EdgeInsets.only(
                bottom: 12,
              ),
              padding:
                  const EdgeInsets.all(
                16,
              ),
              decoration:
                  BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius
                        .circular(
                  16,
                ),
                border: Border.all(
                  color:
                      const Color(
                    0xFFEEF0F5,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor:
                            Color(
                          0xFFE8EAF6,
                        ),
                        child: Icon(
                          Icons
                              .person_outline,
                          color:
                              Color(
                            0xFF3F51B5,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              studentName,
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                fontSize:
                                    16,
                              ),
                            ),
                            if (batchName
                                .isNotEmpty)
                              Text(
                                batchName,
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.grey,
                                  fontSize:
                                      12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        _formatDate(
                          data[
                              'createdAt'],
                        ),
                        style:
                            const TextStyle(
                          color:
                              Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    message,
                    style:
                        const TextStyle(
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CardSection
    extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? footer;

  const _CardSection({
    required this.title,
    required this.child,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              const Color(
            0xFFEEF0F5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
                const TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          child,
          if (footer != null) ...[
            const SizedBox(
              height: 10,
            ),
            footer!,
          ],
        ],
      ),
    );
  }
}
