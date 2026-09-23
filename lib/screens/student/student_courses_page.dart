import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ============================================================
// STUDENT COURSES PAGE
// ============================================================
//
// Shows ONLY the logged-in student's assigned batch.
//
// Example:
//
// Courses
//   2026
//      ↓
//   Course + syllabus
//
// ============================================================

class StudentCoursesPage extends StatelessWidget {
  final String batchId;
  final String batchName;

  const StudentCoursesPage({
    super.key,
    required this.batchId,
    required this.batchName,
  });

  bool get hasBatch =>
      batchId.trim().isNotEmpty ||
      batchName.trim().isNotEmpty;

  String get displayBatchName {
    if (batchName.trim().isNotEmpty) {
      return batchName.trim();
    }

    if (batchId.trim().isNotEmpty) {
      return batchId.trim();
    }

    return 'Batch';
  }

  @override
  Widget build(BuildContext context) {
    if (!hasBatch) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.school_outlined,
              size: 65,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              "No batch assigned yet.",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Courses will appear after a batch is assigned.",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        const Text(
          "Courses by Batch",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          "View your courses and syllabus.",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 24),

        InkWell(
          borderRadius: BorderRadius.circular(20),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    _StudentBatchCoursesPage(
                  batchId: batchId,
                  batchName:
                      displayBatchName,
                ),
              ),
            );
          },

          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(20),

              border: Border.all(
                color:
                    const Color(0xFFE5E7EB),
              ),

              boxShadow: const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
            ),

            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,

                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFFFF3D6),

                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),

                  child: const Icon(
                    Icons.folder_rounded,
                    color:
                        Color(0xFFFF9800),
                    size: 36,
                  ),
                ),

                const SizedBox(width: 18),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayBatchName,
                        style:
                            const TextStyle(
                          fontSize: 19,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Color(
                            0xFF1F2937,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      const Text(
                        "Courses & syllabus",
                        style: TextStyle(
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
                  color: Colors.grey,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// STUDENT BATCH COURSES
// ============================================================

class _StudentBatchCoursesPage
    extends StatefulWidget {
  final String batchId;
  final String batchName;

  const _StudentBatchCoursesPage({
    required this.batchId,
    required this.batchName,
  });

  @override
  State<_StudentBatchCoursesPage>
      createState() =>
          _StudentBatchCoursesPageState();
}

class _StudentBatchCoursesPageState
    extends State<
        _StudentBatchCoursesPage> {
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

      result.sort((a, b) {
        final aTitle =
            a.data()['title']
                    ?.toString()
                    .toLowerCase() ??
                '';

        final bTitle =
            b.data()['title']
                    ?.toString()
                    .toLowerCase() ??
                '';

        return aTitle.compareTo(
          bTitle,
        );
      });

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
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "No syllabus file available.",
          ),
        ),
      );

      return;
    }

    final uri =
        Uri.tryParse(url);

    if (uri == null) {
      return;
    }

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
        centerTitle: true,
        backgroundColor:
            const Color(0xFF3F51B5),
        foregroundColor:
            Colors.white,
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
              : courses.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize:
                            MainAxisSize
                                .min,
                        children: [
                          Icon(
                            Icons
                                .menu_book_outlined,
                            size: 65,
                            color:
                                Colors.grey,
                          ),
                          SizedBox(
                            height: 14,
                          ),
                          Text(
                            "No courses available yet.",
                            style:
                                TextStyle(
                              fontSize:
                                  17,
                              color:
                                  Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh:
                          _loadCourses,

                      child:
                          ListView.builder(
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
                                      ?.toString()
                                      .trim() ??
                                  '';

                          final fileName =
                              data['syllabusFileName']
                                      ?.toString()
                                      .trim() ??
                                  '';

                          final url =
                              data['syllabusUrl']
                                      ?.toString()
                                      .trim() ??
                                  '';

                          return Card(
                            margin:
                                const EdgeInsets
                                    .only(
                              bottom: 14,
                            ),

                            elevation: 1,

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                16,
                              ),
                            ),

                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets
                                      .all(
                                16,
                              ),

                              leading:
                                  Container(
                                width: 54,
                                height: 54,

                                decoration:
                                    BoxDecoration(
                                  color:
                                      const Color(
                                    0xFFFFF3D6,
                                  ),

                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    14,
                                  ),
                                ),

                                child:
                                    const Icon(
                                  Icons
                                      .picture_as_pdf_rounded,
                                  color:
                                      Color(
                                    0xFFFF9800,
                                  ),
                                  size: 29,
                                ),
                              ),

                              title: Text(
                                title.isEmpty
                                    ? "Course"
                                    : title,

                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),

                              subtitle:
                                  Padding(
                                padding:
                                    const EdgeInsets
                                        .only(
                                  top: 5,
                                ),

                                child: Text(
                                  fileName.isEmpty
                                      ? "Tap to open syllabus"
                                      : fileName,
                                ),
                              ),

                              trailing:
                                  const Icon(
                                Icons
                                    .open_in_new_rounded,
                              ),

                              onTap: () {
                                _openSyllabus(
                                  url,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}