import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'add_user_screen.dart';
import 'allocate_students_screen.dart';
import 'user_list_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() =>
      _AdminDashboardState();
}

class _AdminDashboardState
    extends State<AdminDashboard> {
  int studentCount = 0;
  int tutorCount = 0;
  int coreTutorCount = 0;
  int allocatedStudentCount = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOverview();
  }

  // ============================================================
  // LOAD OVERVIEW
  // ============================================================

  Future<void> _loadOverview() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      int students = 0;
      int tutors = 0;
      int coreTutors = 0;
      int allocated = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();

        final role =
            data['role']?.toString() ?? '';

        final isActive =
            data['isActive'] != false;

        if (!isActive) {
          continue;
        }

        if (role == 'student') {
          students++;

          final assignedTutorId =
              data['assignedTutorId']
                      ?.toString()
                      .trim() ??
                  '';

          if (assignedTutorId.isNotEmpty) {
            allocated++;
          }
        } else if (role == 'tutor') {
          tutors++;
        } else if (role == 'core_tutor') {
          coreTutors++;
        }
      }

      if (!mounted) return;

      setState(() {
        studentCount = students;
        tutorCount = tutors;
        coreTutorCount = coreTutors;
        allocatedStudentCount = allocated;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Could not load dashboard details: $e",
          ),
        ),
      );
    }
  }

  // ============================================================
  // OPEN SCREEN
  // ============================================================

  Future<void> _openScreen(
    Widget screen,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );

    // Refresh overview when returning.
    _loadOverview();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final width =
        MediaQuery.of(context).size.width;

    final horizontalPadding =
        width < 600 ? 16.0 : 22.0;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F8FC),

      body: RefreshIndicator(
        onRefresh: _loadOverview,

        child: ListView(
          padding: EdgeInsets.zero,

          children: [
            // ====================================================
            // HEADER
            // ====================================================

            Container(
              width: double.infinity,

              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                24,
                horizontalPadding,
                28,
              ),

              decoration:
                  const BoxDecoration(
                gradient:
                    LinearGradient(
                  colors: [
                    Color(0xFF1F2D86),
                    Color(0xFF6174CE),
                  ],
                  begin:
                      Alignment.topLeft,
                  end:
                      Alignment.bottomRight,
                ),
              ),

              child: Row(
                children: [
                  // ------------------------------------------------
                  // ADMIN ICON
                  // ------------------------------------------------

                  Container(
                    width: 64,
                    height: 64,

                    decoration:
                        BoxDecoration(
                      color: Colors.white
                          .withOpacity(
                        0.18,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),
                    ),

                    child: const Icon(
                      Icons
                          .admin_panel_settings_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),

                  const SizedBox(
                    width: 18,
                  ),

                  // ------------------------------------------------
                  // TITLE
                  // ------------------------------------------------

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        Text(
                          "Welcome, Admin",
                          style:
                              TextStyle(
                            color:
                                Colors.white,
                            fontSize: 27,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        SizedBox(
                          height: 5,
                        ),

                        Text(
                          "Manage users and student allocations",
                          style:
                              TextStyle(
                            color:
                                Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // NO LOGOUT HERE.
                  // Logout is handled globally by role_router.dart
                ],
              ),
            ),

            // ====================================================
            // MAIN BODY
            // ====================================================

            Padding(
              padding:
                  EdgeInsets.fromLTRB(
                horizontalPadding,
                24,
                horizontalPadding,
                35,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  // =================================================
                  // OVERVIEW
                  // =================================================

                  const Text(
                    "Overview",
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Color(0xFF222222),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding:
                            EdgeInsets.all(
                          30,
                        ),
                        child:
                            CircularProgressIndicator(),
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder:
                          (
                        context,
                        constraints,
                      ) {
                        int columns;

                        if (constraints
                                .maxWidth <
                            600) {
                          columns = 1;
                        } else if (constraints
                                .maxWidth <
                            950) {
                          columns = 2;
                        } else {
                          columns = 4;
                        }

                        const spacing =
                            12.0;

                        final cardWidth =
                            (constraints
                                        .maxWidth -
                                    spacing *
                                        (columns -
                                            1)) /
                                columns;

                        final cards = [
                          AdminOverviewCard(
                            title:
                                "Students",
                            value:
                                "$studentCount",
                            subtitle:
                                "Active students",
                            icon:
                                Icons
                                    .school_rounded,
                            color:
                                const Color(
                              0xFF3F51B5,
                            ),
                          ),

                          AdminOverviewCard(
                            title:
                                "Tutors",
                            value:
                                "$tutorCount",
                            subtitle:
                                "Active tutors",
                            icon:
                                Icons
                                    .people_alt_rounded,
                            color:
                                const Color(
                              0xFF009688,
                            ),
                          ),

                          AdminOverviewCard(
                            title:
                                "Core Tutors",
                            value:
                                "$coreTutorCount",
                            subtitle:
                                "Core tutor accounts",
                            icon:
                                Icons
                                    .supervisor_account_rounded,
                            color:
                                const Color(
                              0xFFFF9800,
                            ),
                          ),

                          AdminOverviewCard(
                            title:
                                "Allocated",
                            value:
                                "$allocatedStudentCount",
                            subtitle:
                                "Students with tutors",
                            icon:
                                Icons
                                    .assignment_ind_rounded,
                            color:
                                const Color(
                              0xFFE84B59,
                            ),
                          ),
                        ];

                        return Wrap(
                          spacing:
                              spacing,
                          runSpacing:
                              spacing,

                          children:
                              cards
                                  .map(
                                    (
                                      card,
                                    ) =>
                                        SizedBox(
                                      width:
                                          cardWidth,
                                      height:
                                          180,
                                      child:
                                          card,
                                    ),
                                  )
                                  .toList(),
                        );
                      },
                    ),

                  const SizedBox(
                    height: 32,
                  ),

                  // =================================================
                  // QUICK ACCESS
                  // =================================================

                  const Text(
                    "Quick access",
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Color(0xFF222222),
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  LayoutBuilder(
                    builder:
                        (
                      context,
                      constraints,
                    ) {
                      final columns =
                          constraints
                                      .maxWidth <
                                  650
                              ? 1
                              : 2;

                      const spacing =
                          14.0;

                      final cardWidth =
                          (constraints
                                      .maxWidth -
                                  spacing *
                                      (columns -
                                          1)) /
                              columns;

                      final actions = [
                        // =========================================
                        // ADD USER
                        // =========================================

                        AdminQuickAction(
                          title:
                              "Add User",
                          subtitle:
                              "Create a new account",
                          icon:
                              Icons
                                  .person_add_alt_1_rounded,

                          colors: const [
                            Color(
                              0xFF4859B9,
                            ),
                            Color(
                              0xFF7A89D7,
                            ),
                          ],

                          onTap: () {
                            _openScreen(
                              const AddUserScreen(),
                            );
                          },
                        ),

                        // =========================================
                        // ALLOCATE STUDENTS
                        // =========================================

                        AdminQuickAction(
                          title:
                              "Allocate Students",
                          subtitle:
                              "Assign students to tutors",
                          icon:
                              Icons
                                  .shuffle_rounded,

                          colors: const [
                            Color(
                              0xFF7C3AED,
                            ),
                            Color(
                              0xFF9F67E8,
                            ),
                          ],

                          onTap: () {
                            _openScreen(
                              const AllocateStudentsScreen(),
                            );
                          },
                        ),

                        // =========================================
                        // STUDENTS
                        // =========================================

                        AdminQuickAction(
                          title:
                              "Students",
                          subtitle:
                              "View and manage students",
                          icon:
                              Icons
                                  .school_rounded,

                          colors: const [
                            Color(
                              0xFF159BD7,
                            ),
                            Color(
                              0xFF51C0EE,
                            ),
                          ],

                          onTap: () {
                            _openScreen(
                              const UserListScreen(
                                role:
                                    "student",
                              ),
                            );
                          },
                        ),

                        // =========================================
                        // TUTORS
                        // =========================================

                        AdminQuickAction(
                          title:
                              "Tutors",
                          subtitle:
                              "View and manage tutors",
                          icon:
                              Icons
                                  .people_alt_rounded,

                          colors: const [
                            Color(
                              0xFF009688,
                            ),
                            Color(
                              0xFF45B5A8,
                            ),
                          ],

                          onTap: () {
                            _openScreen(
                              const UserListScreen(
                                role:
                                    "tutor",
                              ),
                            );
                          },
                        ),

                        // =========================================
                        // CORE TUTORS
                        // =========================================

                        AdminQuickAction(
                          title:
                              "Core Tutors",
                          subtitle:
                              "Manage core tutor accounts",
                          icon:
                              Icons
                                  .supervisor_account_rounded,

                          colors: const [
                            Color(
                              0xFFFF7A00,
                            ),
                            Color(
                              0xFFFFB13B,
                            ),
                          ],

                          onTap: () {
                            _openScreen(
                              const UserListScreen(
                                role:
                                    "core_tutor",
                              ),
                            );
                          },
                        ),
                      ];

                      return Wrap(
                        spacing:
                            spacing,
                        runSpacing:
                            spacing,

                        children:
                            actions
                                .map(
                                  (
                                    action,
                                  ) =>
                                      SizedBox(
                                    width:
                                        cardWidth,
                                    height:
                                        160,
                                    child:
                                        action,
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
        ),
      ),
    );
  }
}

// ============================================================
// OVERVIEW CARD
// ============================================================

class AdminOverviewCard
    extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const AdminOverviewCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(
        16,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          19,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFEEF0F5,
          ),
        ),

        boxShadow:
            const [
          BoxShadow(
            color:
                Color(
              0x0F000000,
            ),
            blurRadius:
                16,
            offset:
                Offset(
              0,
              5,
            ),
          ),
        ],
      ),

      child:
          Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Container(
            width:
                48,
            height:
                48,

            decoration:
                BoxDecoration(
              color:
                  color.withOpacity(
                0.12,
              ),

              borderRadius:
                  BorderRadius
                      .circular(
                14,
              ),
            ),

            child:
                Icon(
              icon,
              color:
                  color,
              size:
                  25,
            ),
          ),

          const SizedBox(
            height:
                9,
          ),

          Text(
            value,

            style:
                const TextStyle(
              fontSize:
                  25,
              fontWeight:
                  FontWeight
                      .bold,
              color:
                  Color(
                0xFF252525,
              ),
            ),
          ),

          const SizedBox(
            height:
                4,
          ),

          Text(
            title,

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              fontSize:
                  14,
              fontWeight:
                  FontWeight
                      .w600,
              color:
                  Color(
                0xFF666666,
              ),
            ),
          ),

          const SizedBox(
            height:
                3,
          ),

          Text(
            subtitle,

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              fontSize:
                  11,
              color:
                  Color(
                0xFF999999,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// QUICK ACCESS CARD
// ============================================================

class AdminQuickAction
    extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  const AdminQuickAction({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          Colors.transparent,

      child:
          InkWell(
        onTap:
            onTap,

        borderRadius:
            BorderRadius.circular(
          24,
        ),

        child:
            Ink(
          decoration:
              BoxDecoration(
            gradient:
                LinearGradient(
              colors:
                  colors,
              begin:
                  Alignment.centerLeft,
              end:
                  Alignment.centerRight,
            ),

            borderRadius:
                BorderRadius
                    .circular(
              24,
            ),

            boxShadow:
                [
              BoxShadow(
                color:
                    colors.first
                        .withOpacity(
                  0.20,
                ),

                blurRadius:
                    16,

                offset:
                    const Offset(
                  0,
                  7,
                ),
              ),
            ],
          ),

          child:
              Padding(
            padding:
                const EdgeInsets
                    .all(
              18,
            ),

            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [
                Container(
                  width:
                      56,
                  height:
                      56,

                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white
                            .withOpacity(
                      0.18,
                    ),

                    shape:
                        BoxShape
                            .circle,
                  ),

                  child:
                      Icon(
                    icon,
                    size:
                        30,
                    color:
                        Colors.white,
                  ),
                ),

                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    Text(
                      title,

                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize:
                            20,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),

                    const SizedBox(
                      height:
                          3,
                    ),

                    Text(
                      subtitle,

                      style:
                          TextStyle(
                        color:
                            Colors.white
                                .withOpacity(
                          0.88,
                        ),
                        fontSize:
                            14,
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