import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ============================================================
// TUTOR COURSES PAGE
// ============================================================
//
// Tutor sees ONLY the batches belonging to students
// assigned to that tutor.
//
// ============================================================

class TutorCoursesPage
    extends StatefulWidget {
  const TutorCoursesPage({
    super.key,
  });

  @override
  State<TutorCoursesPage>
      createState() =>
          _TutorCoursesPageState();
}

class _TutorCoursesPageState
    extends State<TutorCoursesPage> {
  bool isLoading = true;
  String? errorMessage;

  List<_TutorBatch> batches = [];

  @override
  void initState() {
    super.initState();

    _loadAssignedBatches();
  }

  Future<void>
      _loadAssignedBatches() async {
    try {
      final tutor =
          FirebaseAuth
              .instance.currentUser;

      if (tutor == null) {
        throw Exception(
          "No tutor is logged in.",
        );
      }

      final snapshot =
          await FirebaseFirestore
              .instance
              .collection('users')
              .where(
                'assignedTutorId',
                isEqualTo:
                    tutor.uid,
              )
              .get();

      final Map<String, _TutorBatch>
          uniqueBatches = {};

      for (final doc
          in snapshot.docs) {
        final data = doc.data();

        if (data['role']
                ?.toString() !=
            'student') {
          continue;
        }

        if (data['isActive'] ==
            false) {
          continue;
        }

        final batchId =
            data['batchId']
                    ?.toString()
                    .trim() ??
                '';

        final batchName =
            data['batchName']
                    ?.toString()
                    .trim() ??
                '';

        if (batchId.isEmpty &&
            batchName.isEmpty) {
          continue;
        }

        final key =
            batchId.isNotEmpty
                ? batchId
                : batchName;

        uniqueBatches[key] =
            _TutorBatch(
          id: batchId,
          name:
              batchName.isNotEmpty
                  ? batchName
                  : batchId,
        );
      }

      final result =
          uniqueBatches.values
              .toList();

      result.sort(
        (a, b) =>
            a.name.compareTo(
          b.name,
        ),
      );

      if (!mounted) return;

      setState(() {
        batches = result;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F8FC),

      appBar: AppBar(
        title: const Text(
          "Courses & Syllabus",
        ),
        backgroundColor:
            Colors.white,
        foregroundColor:
            const Color(0xFF222222),
        elevation: 0.5,
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding:
                        const EdgeInsets
                            .all(24),

                    child: Text(
                      "Could not load courses."
                      "\n\n$errorMessage",
                      textAlign:
                          TextAlign.center,
                    ),
                  ),
                )
              : batches.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize:
                            MainAxisSize
                                .min,
                        children: [
                          Icon(
                            Icons
                                .folder_off_outlined,
                            size: 65,
                            color:
                                Colors.grey,
                          ),
                          SizedBox(
                            height: 14,
                          ),
                          Text(
                            "No assigned batches.",
                            style:
                                TextStyle(
                              fontSize:
                                  18,
                              fontWeight:
                                  FontWeight
                                      .w600,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Courses will appear for the batches "
                            "of your assigned students.",
                            style:
                                TextStyle(
                              color:
                                  Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh:
                          _loadAssignedBatches,

                      child:
                          ListView(
                        padding:
                            const EdgeInsets
                                .all(22),

                        children: [
                          const Text(
                            "Courses by Batch",
                            style:
                                TextStyle(
                              fontSize:
                                  24,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          const Text(
                            "Syllabus uploaded by the Core Tutor.",
                            style:
                                TextStyle(
                              color:
                                  Colors.grey,
                            ),
                          ),

                          const SizedBox(
                            height: 22,
                          ),

                          ...batches.map(
                            (batch) =>
                                Padding(
                              padding:
                                  const EdgeInsets
                                      .only(
                                bottom:
                                    14,
                              ),

                              child:
                                  InkWell(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  18,
                                ),

                                onTap:
                                    () {
                                  Navigator
                                      .push(
                                    context,

                                    MaterialPageRoute(
                                      builder:
                                          (_) =>
                                              _TutorBatchCoursesPage(
                                        batchId:
                                            batch.id,
                                        batchName:
                                            batch.name,
                                      ),
                                    ),
                                  );
                                },

                                child:
                                    Container(
                                  padding:
                                      const EdgeInsets
                                          .all(
                                    20,
                                  ),

                                  decoration:
                                      BoxDecoration(
                                    color:
                                        Colors.white,

                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      18,
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
                                      Row(
                                    children: [
                                      Container(
                                        width:
                                            60,
                                        height:
                                            60,

                                        decoration:
                                            BoxDecoration(
                                          color:
                                              const Color(
                                            0xFFFFF3D6,
                                          ),

                                          borderRadius:
                                              BorderRadius.circular(
                                            16,
                                          ),
                                        ),

                                        child:
                                            const Icon(
                                          Icons
                                              .folder_rounded,
                                          color:
                                              Color(
                                            0xFFFF9800,
                                          ),
                                          size:
                                              34,
                                        ),
                                      ),

                                      const SizedBox(
                                        width:
                                            16,
                                      ),

                                      Expanded(
                                        child:
                                            Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              batch.name,

                                              style:
                                                  const TextStyle(
                                                fontSize:
                                                    18,
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),

                                            const SizedBox(
                                              height:
                                                  5,
                                            ),

                                            const Text(
                                              "Courses & syllabus",
                                              style:
                                                  TextStyle(
                                                color:
                                                    Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const Icon(
                                        Icons
                                            .arrow_forward_ios_rounded,
                                        size:
                                            17,
                                        color:
                                            Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}

// ============================================================
// TUTOR BATCH COURSES
// ============================================================

class _TutorBatchCoursesPage
    extends StatefulWidget {
  final String batchId;
  final String batchName;

  const _TutorBatchCoursesPage({
    required this.batchId,
    required this.batchName,
  });

  @override
  State<_TutorBatchCoursesPage>
      createState() =>
          _TutorBatchCoursesPageState();
}

class _TutorBatchCoursesPageState
    extends State<
        _TutorBatchCoursesPage> {
  bool isLoading = true;
  String? errorMessage;

  List<
      QueryDocumentSnapshot<
          Map<String, dynamic>>> courses =
      [];

  @override
  void initState() {
    super.initState();

    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      Query<Map<String, dynamic>>
          query = FirebaseFirestore
              .instance
              .collection('courses');

      if (widget.batchId
          .trim()
          .isNotEmpty) {
        query = query.where(
          'batchId',
          isEqualTo: widget.batchId,
        );
      } else {
        query = query.where(
          'batchName',
          isEqualTo:
              widget.batchName,
        );
      }

      final snapshot =
          await query.get();

      final result =
          snapshot.docs.where((doc) {
        return doc.data()['isActive'] !=
            false;
      }).toList();

      if (!mounted) return;

      setState(() {
        courses = result;
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

  Future<void> _openSyllabus(
    String url,
  ) async {
    if (url.trim().isEmpty) {
      return;
    }

    final uri =
        Uri.tryParse(url);

    if (uri == null) return;

    final opened =
        await launchUrl(
      uri,
      mode:
          LaunchMode.platformDefault,
    );

    if (!opened && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Could not open syllabus.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F8FC),

      appBar: AppBar(
        title: Text(
          "${widget.batchName} - Courses",
        ),
        backgroundColor:
            Colors.white,
        foregroundColor:
            const Color(0xFF222222),
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : errorMessage != null
              ? Center(
                  child: Text(
                    "Could not load courses."
                    "\n$errorMessage",
                  ),
                )
              : courses.isEmpty
                  ? const Center(
                      child: Text(
                        "No courses uploaded yet.",
                        style:
                            TextStyle(
                          color:
                              Colors.grey,
                          fontSize:
                              17,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding:
                          const EdgeInsets
                              .all(18),

                      itemCount:
                          courses.length,

                      itemBuilder:
                          (context,
                              index) {
                        final data =
                            courses[index]
                                .data();

                        final title =
                            data['title']
                                    ?.toString() ??
                                'Course';

                        final fileName =
                            data['syllabusFileName']
                                    ?.toString() ??
                                '';

                        final url =
                            data['syllabusUrl']
                                    ?.toString() ??
                                '';

                        return Card(
                          margin:
                              const EdgeInsets
                                  .only(
                            bottom: 14,
                          ),

                          child:
                              ListTile(
                            contentPadding:
                                const EdgeInsets
                                    .all(
                              16,
                            ),

                            leading:
                                const CircleAvatar(
                              backgroundColor:
                                  Color(
                                0xFFFFF3D6,
                              ),

                              child: Icon(
                                Icons
                                    .picture_as_pdf_rounded,
                                color:
                                    Color(
                                  0xFFFF9800,
                                ),
                              ),
                            ),

                            title:
                                Text(
                              title,

                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),

                            subtitle:
                                Text(
                              fileName.isEmpty
                                  ? "Tap to open syllabus"
                                  : fileName,
                            ),

                            trailing:
                                const Icon(
                              Icons
                                  .open_in_new_rounded,
                            ),

                            onTap:
                                () {
                              _openSyllabus(
                                url,
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}

class _TutorBatch {
  final String id;
  final String name;

  const _TutorBatch({
    required this.id,
    required this.name,
  });
}