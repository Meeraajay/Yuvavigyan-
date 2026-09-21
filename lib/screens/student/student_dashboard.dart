import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ============================================================
// STUDENT DASHBOARD
// File: lib/screens/student/student_dashboard.dart
// ============================================================

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int index = 0;
  bool isLoading = true;
  String? errorMessage;
  StudentProfile? profile;

  @override
  void initState() {
    super.initState();
    _loadStudentProfile();
  }

  Future<void> _loadStudentProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("No authenticated student found.");
      }

      final profileData = await _findStudentProfile(user);

      if (!mounted) return;

      setState(() {
        profile = profileData;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<StudentProfile> _findStudentProfile(User user) async {
    final firestore = FirebaseFirestore.instance;

    // 1. Try users/{uid}
    final userDoc =
        await firestore.collection('users').doc(user.uid).get();

    if (userDoc.exists && userDoc.data() != null) {
      return StudentProfile.fromMap(
        uid: user.uid,
        email: user.email ?? '',
        data: userDoc.data()!,
      );
    }

    // 2. Try students/{uid}
    final studentDoc =
        await firestore.collection('students').doc(user.uid).get();

    if (studentDoc.exists && studentDoc.data() != null) {
      return StudentProfile.fromMap(
        uid: user.uid,
        email: user.email ?? '',
        data: studentDoc.data()!,
      );
    }

    // 3. Try users where uid == current uid
    final usersQuery = await firestore
        .collection('users')
        .where('uid', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (usersQuery.docs.isNotEmpty) {
      return StudentProfile.fromMap(
        uid: user.uid,
        email: user.email ?? '',
        data: usersQuery.docs.first.data(),
      );
    }

    // 4. Try students where uid == current uid
    final studentsQuery = await firestore
        .collection('students')
        .where('uid', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (studentsQuery.docs.isNotEmpty) {
      return StudentProfile.fromMap(
        uid: user.uid,
        email: user.email ?? '',
        data: studentsQuery.docs.first.data(),
      );
    }

    // Login exists, but no Firestore student profile was found.
    return StudentProfile(
      uid: user.uid,
      email: user.email ?? '',
      name: user.displayName?.trim().isNotEmpty == true
          ? user.displayName!.trim()
          : 'Student',
      batchId: '',
      batchName: '',
      assignedTutorId: '',
    );
  }

  void _goToPage(int pageIndex) {
    setState(() {
      index = pageIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Student Dashboard"),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              "Could not load student profile.\n\n$errorMessage",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final student = profile!;

    final pages = [
      StudentHomePage(
        profile: student,
        onNavigate: _goToPage,
      ),
      StudentMaterialsPage(profile: student),
      StudentTestsPage(profile: student),
      StudentMarksPage(profile: student),
      StudentFeedbackPage(profile: student),
    ];

    const pageTitles = [
      "",
      "Learning Materials",
      "Tests",
      "My Marks",
      "Feedback",
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: index == 0
          ? null
          : AppBar(
              title: Text(pageTitles[index]),
              centerTitle: true,
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF222222),
              elevation: 0.5,
            ),
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF3F51B5),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        elevation: 12,
        onTap: _goToPage,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_rounded),
            label: "Materials",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz_rounded),
            label: "Tests",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: "Marks",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback_rounded),
            label: "Feedback",
          ),
        ],
      ),
    );
  }
}

// ============================================================
// STUDENT PROFILE
// ============================================================

class StudentProfile {
  final String uid;
  final String email;
  final String name;
  final String batchId;
  final String batchName;
  final String assignedTutorId;

  const StudentProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.batchId,
    required this.batchName,
    required this.assignedTutorId,
  });

  factory StudentProfile.fromMap({
    required String uid,
    required String email,
    required Map<String, dynamic> data,
  }) {
    String firstNonEmpty(List<dynamic> values) {
      for (final value in values) {
        final text = value?.toString().trim() ?? '';
        if (text.isNotEmpty) return text;
      }
      return '';
    }

    return StudentProfile(
      uid: uid,
      email: firstNonEmpty([
        data['email'],
        email,
      ]),
      name: firstNonEmpty([
        data['name'],
        data['fullName'],
        data['studentName'],
        'Student',
      ]),
      batchId: firstNonEmpty([
        data['batchId'],
        data['batch_id'],
      ]),
      batchName: firstNonEmpty([
        data['batchName'],
        data['batch'],
        data['batch_name'],
      ]),
      assignedTutorId: firstNonEmpty([
        data['assignedTutorId'],
      ]),
    );
  }

  bool get hasBatch =>
      batchId.trim().isNotEmpty || batchName.trim().isNotEmpty;

  bool get hasAssignedTutor => assignedTutorId.trim().isNotEmpty;

  String get batchDisplayName {
    if (batchName.trim().isNotEmpty) return batchName;
    if (batchId.trim().isNotEmpty) return batchId;
    return "Not assigned";
  }
}

// ============================================================
// HOME PAGE
// ============================================================

class StudentHomePage extends StatefulWidget {
  final StudentProfile profile;
  final void Function(int index) onNavigate;

  const StudentHomePage({
    super.key,
    required this.profile,
    required this.onNavigate,
  });

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  int materialsCount = 0;
  int questionsCount = 0;
  int attemptsCount = 0;
  double averageScore = 0;
  bool isLoadingStats = true;

  bool isLoadingTutor = true;
  String assignedTutorName = '';
  String assignedTutorEmail = '';

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadAssignedTutor();
  }

  Future<void> _loadAssignedTutor() async {
    final tutorId = widget.profile.assignedTutorId.trim();

    if (tutorId.isEmpty) {
      if (!mounted) return;
      setState(() {
        isLoadingTutor = false;
      });
      return;
    }

    try {
      final tutorDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(tutorId)
          .get();

      if (!mounted) return;

      if (!tutorDoc.exists || tutorDoc.data() == null) {
        setState(() {
          isLoadingTutor = false;
        });
        return;
      }

      final data = tutorDoc.data()!;

      setState(() {
        assignedTutorName =
            data['name']?.toString().trim().isNotEmpty == true
                ? data['name'].toString().trim()
                : 'Assigned Tutor';
        assignedTutorEmail = data['email']?.toString() ?? '';
        isLoadingTutor = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isLoadingTutor = false;
      });
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _queryByBatch(
    String collectionName,
  ) async {
    final collection =
        FirebaseFirestore.instance.collection(collectionName);

    if (widget.profile.batchId.trim().isNotEmpty) {
      return collection
          .where(
            'batchId',
            isEqualTo: widget.profile.batchId,
          )
          .get();
    }

    return collection
        .where(
          'batchName',
          isEqualTo: widget.profile.batchName,
        )
        .get();
  }

  Future<void> _loadStats() async {
    try {
      int materialTotal = 0;
      int questionTotal = 0;

      if (widget.profile.hasBatch) {
        final materials = await _queryByBatch('materials');
        final tests = await _queryByBatch('tests');

        materialTotal = materials.docs.length;
        questionTotal = tests.docs.length;
      }

      final attempts = await FirebaseFirestore.instance
          .collection('student_test_submissions')
          .where(
            'studentId',
            isEqualTo: widget.profile.uid,
          )
          .get();

      double percentageTotal = 0;
      int releasedCount = 0;

      for (final doc in attempts.docs) {
        final data = doc.data();

        if (data['markReleased'] != true) {
          continue;
        }

        final value = data['percentage'];

        if (value is num) {
          percentageTotal += value.toDouble();
          releasedCount++;
        }
      }

      if (!mounted) return;

      setState(() {
        materialsCount = materialTotal;
        questionsCount = questionTotal;
        attemptsCount = attempts.docs.length;
        averageScore = releasedCount == 0
            ? 0
            : percentageTotal / releasedCount;
        isLoadingStats = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoadingStats = false;
      });
    }
  }

  String _greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return "Good morning,";
    if (hour < 17) return "Good afternoon,";
    return "Good evening,";
  }

  String _formattedDate() {
    const weekdays = [
      "Mon",
      "Tue",
      "Wed",
      "Thu",
      "Fri",
      "Sat",
      "Sun",
    ];

    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    final now = DateTime.now();

    return "${weekdays[now.weekday - 1]}, "
        "${now.day} ${months[now.month - 1]}";
  }

  String _initial() {
    final name = widget.profile.name.trim();
    if (name.isEmpty) return "S";
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadStats,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final horizontalPadding = width < 600 ? 16.0 : 22.0;
          final quickCardHeight = width < 700 ? 155.0 : 168.0;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // ------------------------------------------------
              // TOP PROFILE HEADER
              // ------------------------------------------------
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  width < 600 ? 22 : 28,
                  horizontalPadding,
                  26,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1F2D86),
                      Color(0xFF6174CE),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: width < 600 ? 68 : 82,
                          height: width < 600 ? 68 : 82,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.45),
                              width: 4,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _initial(),
                            style: TextStyle(
                              color: const Color(0xFF3448A5),
                              fontSize: width < 600 ? 28 : 38,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                _greeting(),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.82),
                                  fontSize: width < 600 ? 14 : 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.profile.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: width < 600 ? 24 : 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (widget.profile.email.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  widget.profile.email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.78),
                                    fontSize: width < 600 ? 12 : 14,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _HeaderBadge(
                          icon: Icons.verified_rounded,
                          text: "Student",
                        ),
                        _HeaderBadge(
                          icon: Icons.calendar_month_rounded,
                          text: _formattedDate(),
                        ),
                        _HeaderBadge(
                          icon: Icons.school_rounded,
                          text: widget.profile.batchDisplayName,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  22,
                  horizontalPadding,
                  28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!widget.profile.hasBatch)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF2E8),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "No batch is assigned to this student yet. "
                                "Materials and tests will appear after a batch is assigned.",
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ------------------------------------------------
                    // NEW FEEDBACK FROM TUTOR
                    // ------------------------------------------------
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('tutor_feedback')
                          .where(
                            'studentId',
                            isEqualTo: widget.profile.uid,
                          )
                          .snapshots(),
                      builder: (context, snapshot) {
                        final unreadCount = snapshot.data?.docs
                                .where(
                                  (doc) =>
                                      doc.data()['readByStudent'] != true,
                                )
                                .length ??
                            0;

                        if (unreadCount == 0) {
                          return const SizedBox.shrink();
                        }

                        return InkWell(
                          onTap: () => widget.onNavigate(4),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8EAF6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFB8C0EA),
                              ),
                            ),
                            child: Row(
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    const Icon(
                                      Icons.notifications_active_rounded,
                                      color: Color(0xFF3F51B5),
                                      size: 28,
                                    ),
                                    Positioned(
                                      right: -8,
                                      top: -8,
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          "$unreadCount",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    unreadCount == 1
                                        ? "You have 1 new feedback message from your tutor."
                                        : "You have $unreadCount new feedback messages from your tutor.",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF283593),
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Color(0xFF3F51B5),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // ------------------------------------------------
                    // ASSIGNED TUTOR
                    // ------------------------------------------------
                    const Text(
                      "Assigned Tutor",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (isLoadingTutor)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(18),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      )
                    else if (widget.profile.hasAssignedTutor &&
                        assignedTutorName.isNotEmpty)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 22),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8EAF6),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Color(0xFF3F51B5),
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    assignedTutorName,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (assignedTutorEmail.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      assignedTutorEmail,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const Chip(
                              label: Text("Tutor"),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 22),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF2E8),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "No tutor has been assigned to this student yet.",
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ------------------------------------------------
                    // STAT CARDS
                    // ------------------------------------------------
                    if (isLoadingStats)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      LayoutBuilder(
                        builder: (context, statConstraints) {
                          final columns =
                              statConstraints.maxWidth < 700 ? 2 : 4;
                          const spacing = 12.0;
                          final cardWidth =
                              (statConstraints.maxWidth -
                                      spacing * (columns - 1)) /
                                  columns;

                          final cards = [
                            _TopStatCard(
                              icon: Icons.folder_special_rounded,
                              value: "$materialsCount",
                              label: "Materials",
                              iconColor: const Color(0xFFFF9800),
                              iconBackground:
                                  const Color(0xFFFFF0D7),
                            ),
                            _TopStatCard(
                              icon: Icons.menu_book_rounded,
                              value: "$questionsCount",
                              label: "Questions",
                              iconColor: const Color(0xFF3F51B5),
                              iconBackground:
                                  const Color(0xFFE8EAF6),
                            ),
                            _TopStatCard(
                              icon: Icons.assignment_turned_in_rounded,
                              value: "$attemptsCount",
                              label: "Attempts",
                              iconColor: const Color(0xFFE84B59),
                              iconBackground:
                                  const Color(0xFFFFE7E9),
                            ),
                            _TopStatCard(
                              icon: Icons.bar_chart_rounded,
                              value:
                                  "${averageScore.toStringAsFixed(1)}%",
                              label: "Average",
                              iconColor: const Color(0xFF009688),
                              iconBackground:
                                  const Color(0xFFE0F3F1),
                            ),
                          ];

                          return Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: cards
                                .map(
                                  (card) => SizedBox(
                                    width: cardWidth,
                                    child: card,
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),

                    const SizedBox(height: 28),
                    Text(
                      "Quick access",
                      style: TextStyle(
                        fontSize: width < 600 ? 20 : 23,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ------------------------------------------------
                    // QUICK ACCESS
                    // ------------------------------------------------
                    LayoutBuilder(
                      builder: (context, quickConstraints) {
                        final columns =
                            quickConstraints.maxWidth < 650 ? 1 : 2;
                        const spacing = 14.0;

                        final cardWidth =
                            (quickConstraints.maxWidth -
                                    spacing * (columns - 1)) /
                                columns;

                        final cards = [
                          _QuickAccessCard(
                            icon: Icons.folder_rounded,
                            title: "Materials",
                            subtitle: "Videos & notes",
                            colors: const [
                              Color(0xFFFF7A00),
                              Color(0xFFFFB13B),
                            ],
                            onTap: () => widget.onNavigate(1),
                          ),
                          _QuickAccessCard(
                            icon: Icons.quiz_rounded,
                            title: "Tests",
                            subtitle: "Assessments & questions",
                            colors: const [
                              Color(0xFF009688),
                              Color(0xFF45B5A8),
                            ],
                            onTap: () => widget.onNavigate(2),
                          ),
                          _QuickAccessCard(
                            icon: Icons.bar_chart_rounded,
                            title: "My Marks",
                            subtitle: "Scores & performance",
                            colors: const [
                              Color(0xFF159BD7),
                              Color(0xFF51C0EE),
                            ],
                            onTap: () => widget.onNavigate(3),
                          ),
                          _QuickAccessCard(
                            icon: Icons.feedback_rounded,
                            title: "Feedback",
                            subtitle: "Message your tutor",
                            colors: const [
                              Color(0xFF4859B9),
                              Color(0xFF7A89D7),
                            ],
                            onTap: () => widget.onNavigate(4),
                          ),
                        ];

                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: cards
                              .map(
                                (card) => SizedBox(
                                  width: cardWidth,
                                  height: quickCardHeight,
                                  child: card,
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeaderBadge({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 17,
            color: Colors.white,
          ),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final Color iconBackground;

  const _TopStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    required this.iconBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 138,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 25,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w600,
              color: Color(0xFF252525),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF777777),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colors.first.withOpacity(0.20),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.88),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MATERIALS PAGE
// ============================================================

class StudentMaterialsPage extends StatefulWidget {
  final StudentProfile profile;

  const StudentMaterialsPage({
    super.key,
    required this.profile,
  });

  @override
  State<StudentMaterialsPage> createState() =>
      _StudentMaterialsPageState();
}

class _StudentMaterialsPageState
    extends State<StudentMaterialsPage> {
  bool isLoading = true;
  String? errorMessage;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> videos = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> notes = [];

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    if (!widget.profile.hasBatch) {
      if (!mounted) return;

      setState(() {
        videos = [];
        notes = [];
        isLoading = false;
      });
      return;
    }

    try {
      Query<Map<String, dynamic>> query =
          FirebaseFirestore.instance.collection('materials');

      if (widget.profile.batchId.trim().isNotEmpty) {
        query = query.where(
          'batchId',
          isEqualTo: widget.profile.batchId,
        );
      } else {
        query = query.where(
          'batchName',
          isEqualTo: widget.profile.batchName,
        );
      }

      final snapshot = await query.get();

      if (!mounted) return;

      setState(() {
        videos = snapshot.docs
            .where(
              (doc) => doc.data()['type'] == 'video',
            )
            .toList();

        notes = snapshot.docs
            .where(
              (doc) => doc.data()['type'] == 'note',
            )
            .toList();

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

  Widget _buildMaterialList(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> items,
    bool isVideo,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          isVideo
              ? "No videos uploaded yet."
              : "No notes uploaded yet.",
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMaterials,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final data = items[index].data();

          final fileName =
              data['fileName']?.toString() ?? 'Material';

          final url = data['url']?.toString() ?? '';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    isVideo ? Colors.redAccent : Colors.orange,
                child: Icon(
                  isVideo
                      ? Icons.play_arrow
                      : Icons.description,
                  color: Colors.white,
                ),
              ),
              title: Text(
                fileName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                isVideo
                    ? "Tap to watch video"
                    : "Tap to open document",
              ),
              trailing: const Icon(
                Icons.open_in_new,
              ),
              onTap: url.isEmpty
                  ? null
                  : () {
                      openStudentUrl(url);
                    },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.profile.hasBatch) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            "Your batch has not been assigned yet.",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Could not load materials.\n\n$errorMessage",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });
                  _loadMaterials();
                },
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const Material(
            child: TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.video_library),
                  text: "Videos",
                ),
                Tab(
                  icon: Icon(Icons.description),
                  text: "Notes",
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildMaterialList(videos, true),
                _buildMaterialList(notes, false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TESTS PAGE
// ============================================================

class StudentTestsPage extends StatefulWidget {
  final StudentProfile profile;

  const StudentTestsPage({
    super.key,
    required this.profile,
  });

  @override
  State<StudentTestsPage> createState() =>
      _StudentTestsPageState();
}

class _StudentTestsPageState extends State<StudentTestsPage> {
  bool isLoading = true;
  String? errorMessage;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> questions = [];
  int previousAttempts = 0;

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  Future<void> _loadTests() async {
    if (!widget.profile.hasBatch) {
      if (!mounted) return;

      setState(() {
        questions = [];
        isLoading = false;
      });
      return;
    }

    try {
      Query<Map<String, dynamic>> query =
          FirebaseFirestore.instance.collection('tests');

      if (widget.profile.batchId.trim().isNotEmpty) {
        query = query.where(
          'batchId',
          isEqualTo: widget.profile.batchId,
        );
      } else {
        query = query.where(
          'batchName',
          isEqualTo: widget.profile.batchName,
        );
      }

      final testSnapshot = await query.get();

      final submissions = await FirebaseFirestore.instance
          .collection('student_test_submissions')
          .where(
            'studentId',
            isEqualTo: widget.profile.uid,
          )
          .get();

      final matchingAttempts = submissions.docs.where((doc) {
        final data = doc.data();

        if (widget.profile.batchId.trim().isNotEmpty) {
          return data['batchId']?.toString() ==
              widget.profile.batchId;
        }

        return data['batchName']?.toString() ==
            widget.profile.batchName;
      }).length;

      if (!mounted) return;

      setState(() {
        questions = testSnapshot.docs;
        previousAttempts = matchingAttempts;
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

  Future<void> _startTest() async {
    if (questions.isEmpty) return;

    final submitted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => StudentTestAttemptPage(
          profile: widget.profile,
          questions: questions,
        ),
      ),
    );

    if (submitted == true) {
      _loadTests();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.profile.hasBatch) {
      return const Center(
        child: Text(
          "Your batch has not been assigned yet.",
        ),
      );
    }

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            "Could not load tests.\n\n$errorMessage",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (questions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 70,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              "No test questions posted yet.",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 17,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTests,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.assignment_rounded,
                    size: 55,
                    color: Color(0xFF3F51B5),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Current Assessment",
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${questions.length} questions",
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Previous attempts: $previousAttempts",
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _startTest,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(
                        previousAttempts == 0
                            ? "Start Assessment"
                            : "Attempt Again",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Answer every question and submit it. "
            "Your tutor will review the submission and release the mark.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TEST ATTEMPT PAGE
// ============================================================

class StudentTestAttemptPage extends StatefulWidget {
  final StudentProfile profile;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> questions;

  const StudentTestAttemptPage({
    super.key,
    required this.profile,
    required this.questions,
  });

  @override
  State<StudentTestAttemptPage> createState() =>
      _StudentTestAttemptPageState();
}

class _StudentTestAttemptPageState
    extends State<StudentTestAttemptPage> {
  final Map<String, String> selectedAnswers = {};
  bool isSubmitting = false;

  Future<void> _submitTest() async {
    if (selectedAnswers.length != widget.questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please answer all questions before submitting.",
          ),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Submit Assessment?"),
          content: const Text(
            "Your answers will be sent to your tutor for review.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      int score = 0;
      final Map<String, dynamic> answerDetails = {};

      for (final doc in widget.questions) {
        final data = doc.data();

        final selected = selectedAnswers[doc.id] ?? '';
        final correct =
            data['correctAnswer']?.toString() ?? '';

        if (selected == correct) {
          score++;
        }

        answerDetails[doc.id] = {
          'selectedAnswer': selected,
          'correctAnswer': correct,
          'isCorrect': selected == correct,
        };
      }

      await FirebaseFirestore.instance
          .collection('student_test_submissions')
          .add({
        'studentId': widget.profile.uid,
        'studentName': widget.profile.name,
        'studentEmail': widget.profile.email,
        'tutorId': widget.profile.assignedTutorId,
        'batchId': widget.profile.batchId,
        'batchName': widget.profile.batchName,
        'answers': answerDetails,
        'questionIds':
            widget.questions.map((doc) => doc.id).toList(),
        'score': score,
        'totalMarks': widget.questions.length,
        'percentage': widget.questions.isEmpty
            ? 0
            : (score / widget.questions.length) * 100,
        'status': 'submitted',
        'reviewedByTutor': false,
        'markReleased': false,
        'submittedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text("Assessment Submitted"),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 60,
                  color: Colors.green,
                ),
                SizedBox(height: 14),
                Text(
                  "Your answers were submitted successfully.\n\n"
                  "Your score will appear in My Marks after your tutor reviews and releases it.",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text("Done"),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to submit assessment: $e",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  Widget _optionTile({
    required String questionId,
    required String label,
    required String text,
  }) {
    return RadioListTile<String>(
      value: label,
      groupValue: selectedAnswers[questionId],
      title: Text("$label. $text"),
      onChanged: isSubmitting
          ? null
          : (value) {
              if (value == null) return;

              setState(() {
                selectedAnswers[questionId] = value;
              });
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assessment"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          100,
        ),
        itemCount: widget.questions.length,
        itemBuilder: (context, index) {
          final doc = widget.questions[index];
          final data = doc.data();

          final question =
              data['question']?.toString() ?? 'Question';

          final optionA =
              data['optionA']?.toString() ?? '';
          final optionB =
              data['optionB']?.toString() ?? '';
          final optionC =
              data['optionC']?.toString() ?? '';
          final optionD =
              data['optionD']?.toString() ?? '';

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      "${index + 1}. $question",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _optionTile(
                    questionId: doc.id,
                    label: "A",
                    text: optionA,
                  ),
                  _optionTile(
                    questionId: doc.id,
                    label: "B",
                    text: optionB,
                  ),
                  _optionTile(
                    questionId: doc.id,
                    label: "C",
                    text: optionC,
                  ),
                  _optionTile(
                    questionId: doc.id,
                    label: "D",
                    text: optionD,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed:
                isSubmitting ? null : _submitTest,
            icon: isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.send),
            label: Text(
              isSubmitting
                  ? "Submitting..."
                  : "Submit Assessment",
            ),
          ),
        ),
      ),
    );
  }
}


// ============================================================
// MARKS / PERFORMANCE PAGE
// ============================================================

class StudentMarksPage extends StatefulWidget {
  final StudentProfile profile;

  const StudentMarksPage({
    super.key,
    required this.profile,
  });

  @override
  State<StudentMarksPage> createState() =>
      _StudentMarksPageState();
}

class _StudentMarksPageState extends State<StudentMarksPage> {
  bool isLoading = true;
  String? errorMessage;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> released = [];
  int pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadMarks();
  }

  Future<void> _loadMarks() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('student_test_submissions')
          .where(
            'studentId',
            isEqualTo: widget.profile.uid,
          )
          .get();

      final allDocs = snapshot.docs.toList();

      final releasedDocs = allDocs
          .where(
            (doc) => doc.data()['markReleased'] == true,
          )
          .toList();

      releasedDocs.sort((a, b) {
        final aTime =
            a.data()['releasedAt'] ?? a.data()['submittedAt'];
        final bTime =
            b.data()['releasedAt'] ?? b.data()['submittedAt'];

        final aDate =
            aTime is Timestamp ? aTime.toDate() : DateTime(1970);
        final bDate =
            bTime is Timestamp ? bTime.toDate() : DateTime(1970);

        return bDate.compareTo(aDate);
      });

      if (!mounted) return;

      setState(() {
        released = releasedDocs;
        pendingCount =
            allDocs.length - releasedDocs.length;
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

  double get averagePercentage {
    if (released.isEmpty) return 0;

    double total = 0;

    for (final doc in released) {
      final value = doc.data()['percentage'];

      if (value is num) {
        total += value.toDouble();
      }
    }

    return total / released.length;
  }

  String _formatDate(dynamic value) {
    if (value is! Timestamp) {
      return "Date unavailable";
    }

    final date = value.toDate();

    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            "Could not load marks.\n\n$errorMessage",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMarks,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (pendingCount > 0)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.hourglass_top_rounded,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "$pendingCount assessment${pendingCount == 1 ? '' : 's'} "
                      "awaiting tutor review / mark release.",
                    ),
                  ),
                ],
              ),
            ),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        "${released.length}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Released",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "${averagePercentage.toStringAsFixed(1)}%",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Average",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            "Assessment Marks",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          if (released.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Column(
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 14),
                  Text(
                    "No marks have been released yet.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          else
            ...released.asMap().entries.map((entry) {
              final data = entry.value.data();

              final score = data['score'] ?? 0;
              final totalMarks =
                  data['totalMarks'] ?? 0;
              final percentage =
                  (data['percentage'] is num)
                      ? (data['percentage'] as num)
                          .toDouble()
                      : 0.0;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.verified_rounded),
                  ),
                  title: Text(
                    "Score: $score / $totalMarks",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "${percentage.toStringAsFixed(1)}% • "
                    "${_formatDate(data['releasedAt'] ?? data['submittedAt'])}",
                  ),
                  trailing: const Chip(
                    label: Text("Released"),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}


// ============================================================
// FEEDBACK PAGE
// ============================================================

class StudentFeedbackPage extends StatefulWidget {
  final StudentProfile profile;

  const StudentFeedbackPage({
    super.key,
    required this.profile,
  });

  @override
  State<StudentFeedbackPage> createState() =>
      _StudentFeedbackPageState();
}

class _StudentFeedbackPageState
    extends State<StudentFeedbackPage> {
  final TextEditingController feedbackController =
      TextEditingController();

  bool isLoadingTutor = true;
  bool isSending = false;

  String tutorId = '';
  String tutorName = '';
  String tutorEmail = '';
  String? mappingMessage;

  @override
  void initState() {
    super.initState();
    _loadAssignedTutor();
  }

  Future<void> _loadAssignedTutor() async {
    try {
      tutorId = widget.profile.assignedTutorId.trim();

      if (tutorId.isEmpty) {
        if (!mounted) return;

        setState(() {
          isLoadingTutor = false;
          mappingMessage =
              "No tutor has been assigned to this student yet.";
        });
        return;
      }

      final tutorDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(tutorId)
          .get();

      if (!mounted) return;

      if (!tutorDoc.exists || tutorDoc.data() == null) {
        setState(() {
          isLoadingTutor = false;
          mappingMessage =
              "The assigned tutor account could not be found.";
        });
        return;
      }

      final data = tutorDoc.data()!;

      setState(() {
        tutorName =
            data['name']?.toString() ?? 'Assigned Tutor';
        tutorEmail =
            data['email']?.toString() ?? '';
        isLoadingTutor = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingTutor = false;
        mappingMessage =
            "Could not load assigned tutor: $e";
      });
    }
  }

  Future<void> _sendFeedback() async {
    final message = feedbackController.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter your feedback.",
          ),
        ),
      );
      return;
    }

    if (tutorId.isEmpty || tutorName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "No tutor is assigned to this student yet.",
          ),
        ),
      );
      return;
    }

    setState(() {
      isSending = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('feedback')
          .add({
        'studentId': widget.profile.uid,
        'studentName': widget.profile.name,
        'studentEmail': widget.profile.email,
        'tutorId': tutorId,
        'tutorName': tutorName,
        'tutorEmail': tutorEmail,
        'batchId': widget.profile.batchId,
        'batchName': widget.profile.batchName,
        'message': message,
        'status': 'sent',
        'readByTutor': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      feedbackController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Feedback sent successfully.",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to send feedback: $e",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSending = false;
        });
      }
    }
  }

  Future<void> _markTutorFeedbackRead() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('tutor_feedback')
        .where(
          'studentId',
          isEqualTo: widget.profile.uid,
        )
        .get();

    final batch = FirebaseFirestore.instance.batch();
    bool hasChanges = false;

    for (final doc in snapshot.docs) {
      if (doc.data()['readByStudent'] != true) {
        batch.update(
          doc.reference,
          {
            'readByStudent': true,
            'readByStudentAt': FieldValue.serverTimestamp(),
          },
        );
        hasChanges = true;
      }
    }

    if (hasChanges) {
      await batch.commit();
    }
  }

  String _formatDate(dynamic value) {
    if (value is! Timestamp) return '';

    final date = value.toDate();

    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  Widget _sendTab() {
    if (isLoadingTutor) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          "Send Feedback",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Your feedback will be sent directly to your assigned tutor.",
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 20),

        if (tutorId.isNotEmpty && tutorName.isNotEmpty)
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(tutorName),
              subtitle: tutorEmail.isEmpty
                  ? const Text("Assigned Tutor")
                  : Text(tutorEmail),
              trailing: const Chip(
                label: Text("Tutor"),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Colors.orange,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    mappingMessage ??
                        "No tutor has been assigned yet.",
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 20),

        TextField(
          controller: feedbackController,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: "Write your feedback",
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isSending ||
                    tutorId.isEmpty ||
                    tutorName.isEmpty
                ? null
                : _sendFeedback,
            icon: isSending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.send),
            label: Text(
              isSending
                  ? "Sending..."
                  : "Send Feedback",
            ),
          ),
        ),
      ],
    );
  }

  Widget _receivedTab() {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('tutor_feedback')
          .where(
            'studentId',
            isEqualTo: widget.profile.uid,
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Could not load tutor feedback.\n${snapshot.error}",
              textAlign: TextAlign.center,
            ),
          );
        }

        final docs = snapshot.data?.docs.toList() ?? [];

        docs.sort((a, b) {
          final aValue = a.data()['createdAt'];
          final bValue = b.data()['createdAt'];

          final aDate = aValue is Timestamp
              ? aValue.toDate()
              : DateTime(1970);

          final bDate = bValue is Timestamp
              ? bValue.toDate()
              : DateTime(1970);

          return bDate.compareTo(aDate);
        });

        if (docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                "No feedback received from your tutor yet.",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(18),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.feedback_rounded),
                ),
                title: Text(
                  data['category']?.toString() ?? 'Tutor Feedback',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    "${data['message']?.toString() ?? ''}\n"
                    "Rating: ${data['rating'] ?? '-'} / 5"
                    "${_formatDate(data['createdAt']).isEmpty ? '' : ' • ${_formatDate(data['createdAt'])}'}",
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            color: Colors.white,
            child: TabBar(
              onTap: (index) {
                if (index == 1) {
                  _markTutorFeedbackRead();
                }
              },
              tabs: const [
                Tab(
                  icon: Icon(Icons.send_rounded),
                  text: "Send",
                ),
                Tab(
                  icon: Icon(Icons.inbox_rounded),
                  text: "Tutor Feedback",
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _sendTab(),
                _receivedTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ============================================================
// OPEN MATERIAL URL
// ============================================================

Future<void> openStudentUrl(String url) async {
  final uri = Uri.tryParse(url);

  if (uri == null) return;

  try {
    final launched = await launchUrl(uri);

    if (!launched) {
      debugPrint("Could not open URL: $url");
    }
  } catch (e) {
    debugPrint("Error opening URL: $e");
  }
}
