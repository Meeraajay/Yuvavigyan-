import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'widgets/welcome_card.dart';
import 'widgets/dashboard_card.dart';
import 'widgets/quick_action_section.dart';

class TutorHomePage extends StatefulWidget {
  final void Function(int) onNavigate;

  const TutorHomePage({
    super.key,
    required this.onNavigate,
  });

  @override
  State<TutorHomePage> createState() => _TutorHomePageState();
}

class _TutorHomePageState extends State<TutorHomePage> {
  bool isLoading = true;

  String tutorName = "Tutor";
  String tutorEmail = "";

  int assignedStudentCount = 0;
  int uniqueBatchCount = 0;
  int completedApplications = 0;
  int pendingApplications = 0;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _tutorSubscription;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _studentsSubscription;

  @override
  void initState() {
    super.initState();
    _listenToDashboard();
  }

  @override
  void dispose() {
    _tutorSubscription?.cancel();
    _studentsSubscription?.cancel();
    super.dispose();
  }

  void _listenToDashboard() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "No tutor is currently logged in.",
            ),
          ),
        );
      });

      return;
    }

    // ----------------------------------------------------------
    // LIVE TUTOR PROFILE
    // ----------------------------------------------------------
    _tutorSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen(
      (doc) {
        if (!mounted) return;

        final data = doc.data() ?? {};

        setState(() {
          tutorName =
              data['name']?.toString().trim().isNotEmpty == true
                  ? data['name'].toString().trim()
                  : (user.displayName?.trim().isNotEmpty == true
                      ? user.displayName!.trim()
                      : "Tutor");

          tutorEmail =
              data['email']?.toString().trim().isNotEmpty == true
                  ? data['email'].toString().trim()
                  : (user.email ?? "");
        });
      },
      onError: (error) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Could not load tutor profile: $error",
            ),
          ),
        );
      },
    );

    // ----------------------------------------------------------
    // LIVE ASSIGNED STUDENTS + APPLICATION COUNTS
    // ----------------------------------------------------------
    _studentsSubscription = FirebaseFirestore.instance
        .collection('users')
        .where(
          'assignedTutorId',
          isEqualTo: user.uid,
        )
        .snapshots()
        .listen(
      (snapshot) {
        final students = snapshot.docs.where((doc) {
          final data = doc.data();

          return data['role']?.toString() == 'student' &&
              data['isActive'] != false;
        }).toList();

        final uniqueBatchIds = <String>{};
        int completed = 0;

        for (final doc in students) {
          final data = doc.data();

          final batchId =
              data['batchId']?.toString().trim() ?? '';

          if (batchId.isNotEmpty) {
            uniqueBatchIds.add(batchId);
          }

          final applicationCompleted =
              data['applicationCompleted'] == true ||
                  data['applicationStatus']?.toString().toLowerCase() ==
                      'completed';

          if (applicationCompleted) {
            completed++;
          }
        }

        if (!mounted) return;

        setState(() {
          assignedStudentCount = students.length;
          uniqueBatchCount = uniqueBatchIds.length;
          completedApplications = completed;
          pendingApplications = students.length - completed;
          isLoading = false;
        });
      },
      onError: (error) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Could not load tutor dashboard: $error",
            ),
          ),
        );
      },
    );
  }

  Future<void> _refreshDashboard() async {
    // The page already uses Firestore live listeners.
    // This simply waits briefly so the RefreshIndicator has normal behavior.
    await Future<void>.delayed(
      const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = width < 600 ? 16.0 : 22.0;

    return RefreshIndicator(
      onRefresh: _refreshDashboard,
      child: ListView(
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          WelcomeCard(
            tutorName: tutorName,
            tutorEmail: tutorEmail,
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              24,
              horizontalPadding,
              30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('feedback')
                      .where(
                        'tutorId',
                        isEqualTo:
                            FirebaseAuth.instance.currentUser?.uid ??
                                '__no_tutor__',
                      )
                      .snapshots(),
                  builder: (context, snapshot) {
                    final unreadCount = snapshot.data?.docs
                            .where(
                              (doc) =>
                                  doc.data()['readByTutor'] != true,
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
                            const Icon(
                              Icons.notifications_active_rounded,
                              color: Color(0xFF3F51B5),
                              size: 28,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                unreadCount == 1
                                    ? "1 new feedback message from a student."
                                    : "$unreadCount new feedback messages from students.",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF283593),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "$unreadCount",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const Text(
                  "Overview",
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                  ),
                ),

                const SizedBox(height: 16),

                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      int columns;

                      if (constraints.maxWidth < 600) {
                        columns = 1;
                      } else if (constraints.maxWidth < 950) {
                        columns = 2;
                      } else {
                        columns = 4;
                      }

                      const spacing = 12.0;

                      final cardWidth =
                          (constraints.maxWidth -
                                  spacing * (columns - 1)) /
                              columns;

                      final cards = [
                        DashboardCard(
                          title: "Assigned Students",
                          value: "$assignedStudentCount",
                          subtitle: "Assigned by Admin",
                          icon: Icons.people_alt_rounded,
                          color: const Color(0xFF3F51B5),
                        ),
                        DashboardCard(
                          title: "Student Batches",
                          value: "$uniqueBatchCount",
                          subtitle: "From assigned students",
                          icon: Icons.folder_copy_rounded,
                          color: const Color(0xFFFF9800),
                        ),
                        DashboardCard(
                          title: "Applications Done",
                          value: "$completedApplications",
                          subtitle: "Admission forms completed",
                          icon: Icons.task_alt_rounded,
                          color: const Color(0xFF009688),
                        ),
                        DashboardCard(
                          title: "Applications Pending",
                          value: "$pendingApplications",
                          subtitle: "Need admission form",
                          icon: Icons.pending_actions_rounded,
                          color: const Color(0xFFE84B59),
                        ),
                      ];

                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: cards
                            .map(
                              (card) => SizedBox(
                                width: cardWidth,
                                height: 180,
                                child: card,
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),

                const SizedBox(height: 30),

                QuickActionSection(
                  onNavigate: widget.onNavigate,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
