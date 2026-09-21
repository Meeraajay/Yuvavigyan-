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

  List<QueryDocumentSnapshot<Map<String, dynamic>>> questions = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> submissions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final tutor = FirebaseAuth.instance.currentUser;

      if (tutor == null) {
        throw Exception("No tutor is currently logged in.");
      }

      final studentsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(
            'assignedTutorId',
            isEqualTo: tutor.uid,
          )
          .get();

      final activeStudents = studentsSnapshot.docs.where((doc) {
        final data = doc.data();

        return data['role']?.toString() == 'student' &&
            data['isActive'] != false;
      }).toList();

      final studentIds = activeStudents.map((doc) => doc.id).toSet();

      final batchIds = activeStudents
          .map(
            (doc) => doc.data()['batchId']?.toString().trim() ?? '',
          )
          .where((id) => id.isNotEmpty)
          .toSet();

      final testsSnapshot =
          await FirebaseFirestore.instance.collection('tests').get();

      final tutorQuestions = testsSnapshot.docs.where((doc) {
        final batchId = doc.data()['batchId']?.toString() ?? '';
        return batchIds.contains(batchId);
      }).toList();

      final submissionSnapshot = await FirebaseFirestore.instance
          .collection('student_test_submissions')
          .get();

      final tutorSubmissions = submissionSnapshot.docs.where((doc) {
        return studentIds.contains(
          doc.data()['studentId']?.toString(),
        );
      }).toList();

      tutorSubmissions.sort((a, b) {
        final aTime = a.data()['submittedAt'];
        final bTime = b.data()['submittedAt'];

        final aDate =
            aTime is Timestamp ? aTime.toDate() : DateTime(1970);

        final bDate =
            bTime is Timestamp ? bTime.toDate() : DateTime(1970);

        return bDate.compareTo(aDate);
      });

      if (!mounted) return;

      setState(() {
        questions = tutorQuestions;
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

  String _formatDate(dynamic value) {
    if (value is! Timestamp) return "Date unavailable";

    final date = value.toDate();

    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  Future<void> _openReview(
    QueryDocumentSnapshot<Map<String, dynamic>> submission,
  ) async {
    final data = submission.data();

    final questionIds = List<String>.from(
      data['questionIds'] ?? const <String>[],
    );

    final answers = Map<String, dynamic>.from(
      data['answers'] ?? const <String, dynamic>{},
    );

    final List<Map<String, dynamic>> questionData = [];

    for (final id in questionIds) {
      final doc = await FirebaseFirestore.instance
          .collection('tests')
          .doc(id)
          .get();

      if (doc.exists && doc.data() != null) {
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
        builder: (_) => _AssessmentReviewPage(
          submissionId: submission.id,
          submissionData: data,
          questions: questionData,
          answers: answers,
        ),
      ),
    );

    _loadData();
  }

  Widget _questionsTab() {
    if (questions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            "No assessment questions are available for your students' batches.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          "Questions for Assigned Batches",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "These questions were posted by the Core Tutor.",
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 18),
        ...questions.asMap().entries.map((entry) {
          final data = entry.value.data();

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${entry.key + 1}. ${data['question'] ?? 'Question'}",
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("A. ${data['optionA'] ?? ''}"),
                  Text("B. ${data['optionB'] ?? ''}"),
                  Text("C. ${data['optionC'] ?? ''}"),
                  Text("D. ${data['optionD'] ?? ''}"),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.school_outlined,
                        size: 17,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        data['batchName']?.toString() ??
                            'Batch',
                        style: const TextStyle(
                          color: Colors.grey,
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
    );
  }

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

    final pendingCount = submissions
        .where(
          (doc) => doc.data()['markReleased'] != true,
        )
        .length;

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
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (pendingCount > 0)
                Chip(
                  avatar: const Icon(
                    Icons.notifications_active_rounded,
                    size: 18,
                    color: Colors.orange,
                  ),
                  label: Text("$pendingCount pending"),
                ),
            ],
          ),
          const SizedBox(height: 18),
          ...submissions.map((submission) {
            final data = submission.data();

            final released =
                data['markReleased'] == true;

            final score = data['score'] ?? 0;
            final total = data['totalMarks'] ?? 0;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: released
                      ? const Color(0xFFE0F3F1)
                      : const Color(0xFFFFF0D7),
                  child: Icon(
                    released
                        ? Icons.verified_rounded
                        : Icons.pending_actions_rounded,
                    color: released
                        ? const Color(0xFF00897B)
                        : const Color(0xFFEF6C00),
                  ),
                ),
                title: Text(
                  data['studentName']?.toString() ??
                      'Student',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "${data['batchName']?.toString().isNotEmpty == true ? data['batchName'] : 'Batch not assigned'}\n"
                  "${released ? 'Released: $score / $total' : 'Submitted • Awaiting review'}"
                  " • ${_formatDate(data['submittedAt'])}",
                ),
                isThreeLine: true,
                trailing: FilledButton.tonal(
                  onPressed: () {
                    _openReview(submission);
                  },
                  child: Text(
                    released ? "View" : "Review",
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FC),
        appBar: AppBar(
          title: const Text("Assessments"),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF222222),
          elevation: 0.5,
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.quiz_outlined),
                text: "Questions",
              ),
              Tab(
                icon: Icon(Icons.assignment_turned_in_outlined),
                text: "Submissions",
              ),
            ],
          ),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        "Could not load assessments.\n\n$errorMessage",
                        textAlign: TextAlign.center,
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
