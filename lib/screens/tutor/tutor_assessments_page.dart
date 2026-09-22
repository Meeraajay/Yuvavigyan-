import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TutorAssessmentsPage extends StatefulWidget {
  const TutorAssessmentsPage({super.key});

  @override
  State<TutorAssessmentsPage> createState() =>
      _TutorAssessmentsPageState();
}

class _TutorAssessmentsPageState
    extends State<TutorAssessmentsPage> {
  bool isLoading = true;
  String? errorMessage;

  List<_TutorBatch> batches = [];

  List<QueryDocumentSnapshot<Map<String, dynamic>>>
      testFolders = [];

  List<QueryDocumentSnapshot<Map<String, dynamic>>>
      questions = [];

  List<QueryDocumentSnapshot<Map<String, dynamic>>>
      submissions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String _text(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  String _referenceId(dynamic value) {
    if (value is DocumentReference) {
      return value.id;
    }

    return _text(value);
  }

  String _folderName(
    QueryDocumentSnapshot<Map<String, dynamic>> folder,
  ) {
    final data = folder.data();

    final possibleNames = [
      data['name'],
      data['title'],
      data['testName'],
      data['folderName'],
    ];

    for (final value in possibleNames) {
      final text = _text(value);

      if (text.isNotEmpty) {
        return text;
      }
    }

    return "Test";
  }

  bool _belongsToBatch(
    Map<String, dynamic> data,
    _TutorBatch batch,
  ) {
    final batchId = _text(data['batchId']);
    final batchName = _text(data['batchName']);

    if (batch.id.isNotEmpty) {
      return batchId == batch.id;
    }

    return batchName == batch.name;
  }

  bool _belongsToAnyAssignedBatch(
    Map<String, dynamic> data,
    List<_TutorBatch> assignedBatches,
  ) {
    for (final batch in assignedBatches) {
      if (_belongsToBatch(data, batch)) {
        return true;
      }
    }

    return false;
  }

  bool _questionBelongsToFolder(
    Map<String, dynamic> data,
    String folderId,
    String folderName,
  ) {
    final possibleIds = [
      _referenceId(data['testFolderId']),
      _referenceId(data['folderId']),
      _referenceId(data['testId']),
    ];

    for (final id in possibleIds) {
      if (id.isNotEmpty && id == folderId) {
        return true;
      }
    }

    final possibleNames = [
      _text(data['testFolderName']),
      _text(data['folderName']),
      _text(data['testName']),
    ];

    for (final name in possibleNames) {
      if (name.isNotEmpty && name == folderName) {
        return true;
      }
    }

    return false;
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> _loadData() async {
    try {
      final tutor =
          FirebaseAuth.instance.currentUser;

      if (tutor == null) {
        throw Exception(
          "No tutor is currently logged in.",
        );
      }

      // ----------------------------------------------------------
      // GET STUDENTS ASSIGNED TO THIS TUTOR
      // ----------------------------------------------------------

      final studentsSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where(
                'assignedTutorId',
                isEqualTo: tutor.uid,
              )
              .get();

      final activeStudents =
          studentsSnapshot.docs.where((doc) {
        final data = doc.data();

        return data['role']?.toString() == 'student' &&
            data['isActive'] != false;
      }).toList();

      final studentIds =
          activeStudents.map((doc) => doc.id).toSet();

      // ----------------------------------------------------------
      // GET UNIQUE BATCHES OF ASSIGNED STUDENTS
      // ----------------------------------------------------------

      final Map<String, _TutorBatch>
          batchMap = {};

      for (final student in activeStudents) {
        final data = student.data();

        final batchId =
            _text(data['batchId']);

        final batchName =
            _text(data['batchName']);

        if (batchId.isNotEmpty) {
          batchMap.putIfAbsent(
            batchId,
            () => _TutorBatch(
              id: batchId,
              name: batchName.isNotEmpty
                  ? batchName
                  : batchId,
            ),
          );
        } else if (batchName.isNotEmpty) {
          batchMap.putIfAbsent(
            "name:$batchName",
            () => _TutorBatch(
              id: '',
              name: batchName,
            ),
          );
        }
      }

      final assignedBatches =
          batchMap.values.toList();

      // ----------------------------------------------------------
      // GET TEST FOLDERS
      // ----------------------------------------------------------

      final folderSnapshot =
          await FirebaseFirestore.instance
              .collection('testFolders')
              .get();

      final assignedFolders =
          folderSnapshot.docs.where((doc) {
        return _belongsToAnyAssignedBatch(
          doc.data(),
          assignedBatches,
        );
      }).toList();

      // ----------------------------------------------------------
      // GET QUESTIONS
      // ----------------------------------------------------------

      final testsSnapshot =
          await FirebaseFirestore.instance
              .collection('tests')
              .get();

      final assignedQuestions =
          testsSnapshot.docs.where((doc) {
        return _belongsToAnyAssignedBatch(
          doc.data(),
          assignedBatches,
        );
      }).toList();

      // ----------------------------------------------------------
      // GET STUDENT SUBMISSIONS
      // ----------------------------------------------------------

      final submissionSnapshot =
          await FirebaseFirestore.instance
              .collection(
                'student_test_submissions',
              )
              .get();

      final tutorSubmissions =
          submissionSnapshot.docs.where((doc) {
        return studentIds.contains(
          doc.data()['studentId']?.toString(),
        );
      }).toList();

      tutorSubmissions.sort((a, b) {
        final aTime =
            a.data()['submittedAt'];

        final bTime =
            b.data()['submittedAt'];

        final aDate =
            aTime is Timestamp
                ? aTime.toDate()
                : DateTime(1970);

        final bDate =
            bTime is Timestamp
                ? bTime.toDate()
                : DateTime(1970);

        return bDate.compareTo(aDate);
      });

      if (!mounted) return;

      setState(() {
        batches = assignedBatches;
        testFolders = assignedFolders;
        questions = assignedQuestions;
        submissions = tutorSubmissions;

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

  // ============================================================
  // DATE
  // ============================================================

  String _formatDate(dynamic value) {
    if (value is! Timestamp) {
      return "Date unavailable";
    }

    final date = value.toDate();

    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  // ============================================================
  // OPEN TEST FOLDER
  // ============================================================

  void _openTestFolder(
    _TutorBatch batch,
    QueryDocumentSnapshot<Map<String, dynamic>> folder,
  ) {
    final folderId = folder.id;

    final folderName =
        _folderName(folder);

    final folderQuestions =
        questions.where((question) {
      return _questionBelongsToFolder(
        question.data(),
        folderId,
        folderName,
      );
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TutorFolderQuestionsPage(
          batchName: batch.name,
          testName: folderName,
          questions: folderQuestions,
        ),
      ),
    );
  }

  // ============================================================
  // REVIEW SUBMISSION
  // ============================================================

  Future<void> _openReview(
    QueryDocumentSnapshot<Map<String, dynamic>>
        submission,
  ) async {
    final data = submission.data();

    final questionIds =
        List<String>.from(
      data['questionIds'] ??
          const <String>[],
    );

    final answers =
        Map<String, dynamic>.from(
      data['answers'] ??
          const <String, dynamic>{},
    );

    final List<Map<String, dynamic>>
        questionData = [];

    for (final id in questionIds) {
      final doc =
          await FirebaseFirestore.instance
              .collection('tests')
              .doc(id)
              .get();

      if (doc.exists &&
          doc.data() != null) {
        questionData.add({
          'id': id,
          ...doc.data()!,
        });
      }
    }

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _AssessmentReviewPage(
          submissionId: submission.id,
          submissionData: data,
          questions: questionData,
          answers: answers,
        ),
      ),
    );

    _loadData();
  }

  // ============================================================
  // QUESTIONS TAB
  // ============================================================

  Widget _questionsTab() {
    if (batches.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            "No batches are assigned to your students.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,

      child: ListView(
        padding: const EdgeInsets.all(18),

        children: [
          const Text(
            "Tests for Assigned Batches",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            "Open a test folder to view the questions uploaded by the Core Tutor.",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 22),

          ...batches.map((batch) {
            final foldersForBatch =
                testFolders.where((folder) {
              return _belongsToBatch(
                folder.data(),
                batch,
              );
            }).toList();

            return Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 30,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // ==============================================
                  // BATCH TITLE
                  // ==============================================

                  Row(
                    children: [
                      const Icon(
                        Icons.school_rounded,
                        color:
                            Color(0xFF3F51B5),
                      ),

                      const SizedBox(width: 8),

                      Text(
                        "${batch.name} - Tests",
                        style:
                            const TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  if (foldersForBatch.isEmpty)
                    Container(
                      width:
                          double.infinity,

                      padding:
                          const EdgeInsets.all(
                        20,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            Colors.white,

                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),

                        border:
                            Border.all(
                          color:
                              const Color(
                            0xFFE5E7EB,
                          ),
                        ),
                      ),

                      child:
                          const Text(
                        "No test folders have been created for this batch.",
                        textAlign:
                            TextAlign.center,
                        style:
                            TextStyle(
                          color:
                              Colors.grey,
                        ),
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (
                        context,
                        constraints,
                      ) {
                        final columns =
                            constraints
                                        .maxWidth >=
                                    700
                                ? 2
                                : 1;

                        const spacing =
                            16.0;

                        final cardWidth =
                            (constraints
                                        .maxWidth -
                                    spacing *
                                        (columns -
                                            1)) /
                                columns;

                        return Wrap(
                          spacing: spacing,
                          runSpacing:
                              spacing,

                          children:
                              foldersForBatch
                                  .map(
                            (folder) {
                              final folderName =
                                  _folderName(
                                folder,
                              );

                              final questionCount =
                                  questions
                                      .where(
                                (
                                  question,
                                ) {
                                  return _questionBelongsToFolder(
                                    question
                                        .data(),
                                    folder.id,
                                    folderName,
                                  );
                                },
                              ).length;

                              return SizedBox(
                                width:
                                    cardWidth,

                                height:
                                    220,

                                child:
                                    _TutorTestFolderCard(
                                  testName:
                                      folderName,

                                  questionCount:
                                      questionCount,

                                  onTap: () {
                                    _openTestFolder(
                                      batch,
                                      folder,
                                    );
                                  },
                                ),
                              );
                            },
                          ).toList(),
                        );
                      },
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============================================================
  // SUBMISSIONS TAB
  // ============================================================

  Widget _submissionsTab() {
    if (submissions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            "No student assessment submissions yet.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    final pendingCount =
        submissions.where((doc) {
      return doc.data()['markReleased'] !=
          true;
    }).length;

    return RefreshIndicator(
      onRefresh: _loadData,

      child: ListView(
        padding: const EdgeInsets.all(18),

        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Student Submissions",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              if (pendingCount > 0)
                Chip(
                  avatar:
                      const Icon(
                    Icons
                        .notifications_active_rounded,
                    size: 18,
                    color:
                        Colors.orange,
                  ),

                  label:
                      Text(
                    "$pendingCount pending",
                  ),
                ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          ...submissions.map(
            (submission) {
              final data =
                  submission.data();

              final released =
                  data['markReleased'] ==
                      true;

              final score =
                  data['score'] ?? 0;

              final total =
                  data['totalMarks'] ??
                      0;

              final testName =
                  data['testName']
                              ?.toString()
                              .trim()
                              .isNotEmpty ==
                          true
                      ? data['testName']
                          .toString()
                          .trim()
                      : "Assessment";

              final batchName =
                  data['batchName']
                              ?.toString()
                              .trim()
                              .isNotEmpty ==
                          true
                      ? data['batchName']
                          .toString()
                          .trim()
                      : "Batch not assigned";

              return Card(
                margin:
                    const EdgeInsets.only(
                  bottom: 12,
                ),

                child:
                    ListTile(
                  contentPadding:
                      const EdgeInsets.all(
                    16,
                  ),

                  leading:
                      CircleAvatar(
                    backgroundColor:
                        released
                            ? const Color(
                                0xFFE0F3F1,
                              )
                            : const Color(
                                0xFFFFF0D7,
                              ),

                    child:
                        Icon(
                      released
                          ? Icons
                              .verified_rounded
                          : Icons
                              .pending_actions_rounded,

                      color:
                          released
                              ? const Color(
                                  0xFF00897B,
                                )
                              : const Color(
                                  0xFFEF6C00,
                                ),
                    ),
                  ),

                  title:
                      Text(
                    data['studentName']
                            ?.toString() ??
                        'Student',

                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  subtitle:
                      Padding(
                    padding:
                        const EdgeInsets.only(
                      top: 5,
                    ),

                    child:
                        Text(
                      "$testName\n"
                      "$batchName • "
                      "${released ? 'Released: $score / $total' : 'Submitted • Awaiting review'}"
                      " • ${_formatDate(data['submittedAt'])}",
                    ),
                  ),

                  isThreeLine:
                      true,

                  trailing:
                      FilledButton.tonal(
                    onPressed:
                        () {
                      _openReview(
                        submission,
                      );
                    },

                    child:
                        Text(
                      released
                          ? "View"
                          : "Review",
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,

      child: Scaffold(
        backgroundColor:
            const Color(
          0xFFF7F8FC,
        ),

        appBar:
            AppBar(
          title:
              const Text(
            "Assessments",
          ),

          backgroundColor:
              Colors.white,

          foregroundColor:
              const Color(
            0xFF222222,
          ),

          elevation:
              0.5,

          bottom:
              const TabBar(
            tabs: [
              Tab(
                icon:
                    Icon(
                  Icons
                      .folder_copy_outlined,
                ),
                text:
                    "Questions",
              ),

              Tab(
                icon:
                    Icon(
                  Icons
                      .assignment_turned_in_outlined,
                ),
                text:
                    "Submissions",
              ),
            ],
          ),
        ),

        body:
            isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )
                : errorMessage !=
                        null
                    ? Center(
                        child:
                            Padding(
                          padding:
                              const EdgeInsets.all(
                            24,
                          ),

                          child:
                              Text(
                            "Could not load assessments.\n\n$errorMessage",

                            textAlign:
                                TextAlign.center,
                          ),
                        ),
                      )
                    : TabBarView(
                        children: [
                          _questionsTab(),
                          _submissionsTab(),
                        ],
                      ),
      ),
    );
  }
}

// ============================================================
// TUTOR BATCH
// ============================================================

class _TutorBatch {
  final String id;
  final String name;

  const _TutorBatch({
    required this.id,
    required this.name,
  });
}

// ============================================================
// TEST FOLDER CARD
// ============================================================

class _TutorTestFolderCard
    extends StatelessWidget {
  final String testName;
  final int questionCount;
  final VoidCallback onTap;

  const _TutorTestFolderCard({
    required this.testName,
    required this.questionCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,

      elevation: 2,

      borderRadius:
          BorderRadius.circular(
        24,
      ),

      child:
          InkWell(
        onTap:
            onTap,

        borderRadius:
            BorderRadius.circular(
          24,
        ),

        child:
            Padding(
          padding:
              const EdgeInsets.all(
            20,
          ),

          child:
              Column(
            mainAxisAlignment:
                MainAxisAlignment
                    .center,

            children: [
              Container(
                width: 76,
                height: 76,

                decoration:
                    BoxDecoration(
                  gradient:
                      const LinearGradient(
                    colors: [
                      Color(
                        0xFF8A5AD9,
                      ),
                      Color(
                        0xFF6D3DC2,
                      ),
                    ],
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    22,
                  ),
                ),

                child:
                    const Icon(
                  Icons
                      .assignment_rounded,

                  color:
                      Colors.white,

                  size:
                      42,
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              Text(
                testName,

                maxLines: 2,

                overflow:
                    TextOverflow
                        .ellipsis,

                textAlign:
                    TextAlign.center,

                style:
                    const TextStyle(
                  fontSize: 19,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 7,
              ),

              Text(
                "$questionCount question${questionCount == 1 ? '' : 's'}",

                style:
                    const TextStyle(
                  color:
                      Colors.grey,
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              const Text(
                "Open questions",

                style:
                    TextStyle(
                  color:
                      Colors.grey,
                  fontSize:
                      13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// QUESTIONS INSIDE ONE TEST FOLDER
// ============================================================

class TutorFolderQuestionsPage
    extends StatelessWidget {
  final String batchName;
  final String testName;

  final List<
          QueryDocumentSnapshot<
              Map<String, dynamic>>>
      questions;

  const TutorFolderQuestionsPage({
    super.key,
    required this.batchName,
    required this.testName,
    required this.questions,
  });

  Widget _option(
    String label,
    String text,
    String correctAnswer,
  ) {
    final correct =
        label == correctAnswer;

    return Container(
      width:
          double.infinity,

      margin:
          const EdgeInsets.only(
        bottom: 7,
      ),

      padding:
          const EdgeInsets.all(
        11,
      ),

      decoration:
          BoxDecoration(
        color:
            correct
                ? Colors.green
                    .withOpacity(
                      0.08,
                    )
                : const Color(
                    0xFFF8FAFC,
                  ),

        borderRadius:
            BorderRadius.circular(
          10,
        ),

        border:
            Border.all(
          color:
              correct
                  ? Colors.green
                  : const Color(
                      0xFFE5E7EB,
                    ),
        ),
      ),

      child:
          Row(
        children: [
          Expanded(
            child:
                Text(
              "$label. $text",

              style:
                  TextStyle(
                color:
                    correct
                        ? Colors.green
                        : const Color(
                            0xFF333333,
                          ),

                fontWeight:
                    correct
                        ? FontWeight.w600
                        : FontWeight.normal,
              ),
            ),
          ),

          if (correct)
            const Icon(
              Icons
                  .check_circle_rounded,

              color:
                  Colors.green,

              size:
                  19,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(
        0xFFF7F8FC,
      ),

      appBar:
          AppBar(
        title:
            Text(
          "$batchName - $testName",
        ),
      ),

      body:
          questions.isEmpty
              ? const Center(
                  child:
                      Text(
                    "No questions have been added to this test.",
                    style:
                        TextStyle(
                      color:
                          Colors.grey,
                    ),
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.all(
                    18,
                  ),

                  itemCount:
                      questions.length,

                  itemBuilder: (
                    context,
                    index,
                  ) {
                    final data =
                        questions[
                                index]
                            .data();

                    final question =
                        data['question']
                                ?.toString() ??
                            'Question';

                    final optionA =
                        data['optionA']
                                ?.toString() ??
                            '';

                    final optionB =
                        data['optionB']
                                ?.toString() ??
                            '';

                    final optionC =
                        data['optionC']
                                ?.toString() ??
                            '';

                    final optionD =
                        data['optionD']
                                ?.toString() ??
                            '';

                    final correctAnswer =
                        data['correctAnswer']
                                ?.toString() ??
                            '';

                    return Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 14,
                      ),

                      child:
                          Padding(
                        padding:
                            const EdgeInsets.all(
                          18,
                        ),

                        child:
                            Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            Text(
                              "${index + 1}. $question",

                              style:
                                  const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 14,
                            ),

                            _option(
                              "A",
                              optionA,
                              correctAnswer,
                            ),

                            _option(
                              "B",
                              optionB,
                              correctAnswer,
                            ),

                            _option(
                              "C",
                              optionC,
                              correctAnswer,
                            ),

                            _option(
                              "D",
                              optionD,
                              correctAnswer,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _AssessmentReviewPage extends StatefulWidget {
  final String submissionId;
  final Map<String, dynamic> submissionData;
  final List<Map<String, dynamic>> questions;
  final Map<String, dynamic> answers;

  const _AssessmentReviewPage({
    required this.submissionId,
    required this.submissionData,
    required this.questions,
    required this.answers,
  });

  @override
  State<_AssessmentReviewPage> createState() =>
      _AssessmentReviewPageState();
}

class _AssessmentReviewPageState
    extends State<_AssessmentReviewPage> {
  bool isReleasing = false;

  Future<void> _releaseMark() async {
    setState(() {
      isReleasing = true;
    });

    try {
      final tutor = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance
          .collection('student_test_submissions')
          .doc(widget.submissionId)
          .update({
        'reviewedByTutor': true,
        'reviewedByTutorId': tutor?.uid,
        'reviewedAt': FieldValue.serverTimestamp(),
        'markReleased': true,
        'status': 'released',
        'releasedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Mark released to the student successfully.",
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isReleasing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Could not release mark: $e",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.submissionData;

    final score = data['score'] ?? 0;
    final total = data['totalMarks'] ?? 0;

    final percentage = data['percentage'] is num
        ? (data['percentage'] as num).toDouble()
        : 0.0;

    final released = data['markReleased'] == true;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text("Review Assessment"),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          18,
          18,
          18,
          110,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF4859B9),
                  Color(0xFF7A89D7),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['studentName']?.toString() ?? 'Student',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  data['batchName']?.toString() ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "Calculated Score: $score / $total  "
                  "(${percentage.toStringAsFixed(1)}%)",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ...widget.questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            final questionId =
                question['id']?.toString() ?? '';

            final answer = Map<String, dynamic>.from(
              widget.answers[questionId] ??
                  const <String, dynamic>{},
            );

            final selected =
                answer['selectedAnswer']?.toString() ?? '';

            final correct =
                answer['correctAnswer']?.toString() ??
                    question['correctAnswer']?.toString() ??
                    '';

            final isCorrect =
                answer['isCorrect'] == true;

            String optionText(String key) {
              return question['option$key']?.toString() ?? '';
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${index + 1}. ${question['question'] ?? 'Question'}",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final label in ['A', 'B', 'C', 'D'])
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 7),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: label == correct
                              ? Colors.green.withOpacity(0.10)
                              : label == selected && !isCorrect
                                  ? Colors.red.withOpacity(0.08)
                                  : const Color(0xFFF8FAFC),
                          borderRadius:
                              BorderRadius.circular(10),
                          border: Border.all(
                            color: label == correct
                                ? Colors.green
                                : label == selected && !isCorrect
                                    ? Colors.red
                                    : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Text(
                          "$label. ${optionText(label)}"
                          "${label == selected ? '  ← Student answer' : ''}"
                          "${label == correct ? '  ✓ Correct' : ''}",
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          isCorrect
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          color: isCorrect
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isCorrect ? "Correct" : "Incorrect",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isCorrect
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
      bottomNavigationBar: released
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F3F1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF00897B),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Mark already released",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00897B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed:
                      isReleasing ? null : _releaseMark,
                  icon: isReleasing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.publish_rounded,
                        ),
                  label: Text(
                    isReleasing
                        ? "Releasing..."
                        : "Release Mark to Student",
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize:
                        const Size.fromHeight(52),
                    backgroundColor:
                        const Color(0xFF3F51B5),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
    );
  }
}
