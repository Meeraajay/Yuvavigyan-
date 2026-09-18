import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/cloudinary_service.dart';

// ============================================================
// CORE TUTOR DASHBOARD
// ============================================================

class CoreTutorDashboard extends StatefulWidget {
  const CoreTutorDashboard({super.key});

  @override
  State<CoreTutorDashboard> createState() => _CoreTutorDashboardState();
}

class _CoreTutorDashboardState extends State<CoreTutorDashboard> {
  int index = 0;

  final pages = const [
    CoreHomePage(),
    CoursesPage(),
    MaterialsPage(),
    TestsPage(),
    MappingPage(),
    FeedbackPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Core Tutor Dashboard"),
        centerTitle: true,
      ),
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: (value) {
          setState(() {
            index = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: "Courses",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: "Materials",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: "Tests",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Mapping",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: "Feedback",
          ),
        ],
      ),
    );
  }
}

// ============================================================
// COMMON FOLDER CARD
// ============================================================

class FolderCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const FolderCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.18),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(
                  icon,
                  size: 30,
                  color: color,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildFolderGrid({
  required List<Widget> cards,
}) {
  return GridView.builder(
    padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisExtent: 220,
      crossAxisSpacing: 24,
      mainAxisSpacing: 24,
    ),
    itemCount: cards.length,
    itemBuilder: (context, index) {
      return cards[index];
    },
  );
}

// ============================================================
// ADD NAME DIALOG
// ============================================================

class AddNameDialog extends StatefulWidget {
  final String title;
  final String label;
  final String confirmText;
  final void Function(String value) onCreate;

  const AddNameDialog({
    super.key,
    required this.title,
    required this.label,
    required this.onCreate,
    this.confirmText = "Create",
  });

  @override
  State<AddNameDialog> createState() => _AddNameDialogState();
}

class _AddNameDialogState extends State<AddNameDialog> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: widget.label,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            final value = controller.text.trim();

            if (value.isEmpty) return;

            widget.onCreate(value);
            Navigator.pop(context);
          },
          child: Text(widget.confirmText),
        ),
      ],
    );
  }
}

// ============================================================
// HOME
// ============================================================

class CoreHomePage extends StatelessWidget {
  const CoreHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(20),
      crossAxisCount: 2,
      childAspectRatio: 1.8,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      children: [
        _buildClickCard(context, Icons.book, "Courses", 1),
        _buildClickCard(context, Icons.folder, "Materials", 2),
        _buildClickCard(context, Icons.quiz, "Tests", 3),
        _buildClickCard(
          context,
          Icons.people,
          "Tutor-Student Mapping",
          4,
        ),
        _buildClickCard(
          context,
          Icons.feedback,
          "Feedback",
          5,
        ),
      ],
    );
  }

  Widget _buildClickCard(
    BuildContext context,
    IconData icon,
    String text,
    int pageIndex,
  ) {
    return InkWell(
      onTap: () {
        final parent =
            context.findAncestorStateOfType<_CoreTutorDashboardState>();

        parent?.setState(() {
          parent.index = pageIndex;
        });
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.20),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.blue[50],
              child: Icon(
                icon,
                size: 24,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// COURSES PAGE
// ============================================================

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, String>> batches = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    try {
      final snapshot =
          await _firestore.collection('batches').get();

      if (!mounted) return;

      setState(() {
        batches = snapshot.docs.map((doc) {
          final data = doc.data();

          return {
            'id': doc.id,
            'name': data['name']?.toString() ?? 'Unnamed Batch',
          };
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load batches: $e'),
        ),
      );
    }
  }

  Future<void> _createBatch(String batchName) async {
    try {
      final docRef =
          await _firestore.collection('batches').add({
        'name': batchName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        batches.add({
          'id': docRef.id,
          'name': batchName,
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Batch created successfully'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create batch: $e'),
        ),
      );
    }
  }

  Future<void> _deleteBatch(
    String batchId,
    String batchName,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Batch?'),
          content: Text(
            'Are you sure you want to delete "$batchName"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await _firestore
          .collection('batches')
          .doc(batchId)
          .delete();

      final coursesSnapshot = await _firestore
          .collection('courses')
          .where('batchId', isEqualTo: batchId)
          .get();

      for (final doc in coursesSnapshot.docs) {
        await doc.reference.delete();
      }

      final materialsSnapshot = await _firestore
          .collection('materials')
          .where('batchId', isEqualTo: batchId)
          .get();

      for (final doc in materialsSnapshot.docs) {
        await doc.reference.delete();
      }

      final testsSnapshot = await _firestore
          .collection('tests')
          .where('batchId', isEqualTo: batchId)
          .get();

      for (final doc in testsSnapshot.docs) {
        await doc.reference.delete();
      }

      if (!mounted) return;

      setState(() {
        batches.removeWhere(
          (batch) => batch['id'] == batchId,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Batch deleted successfully'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete batch: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddNameDialog(
              title: "New Batch",
              label: "Batch Name",
              onCreate: _createBatch,
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("New Batch"),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : batches.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 60,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "No batches created yet.",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : buildFolderGrid(
                  cards: batches.map((batch) {
                    final batchId = batch['id']!;
                    final batchName = batch['name']!;

                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        FolderCard(
                          icon: Icons.folder,
                          label: batchName,
                          color: Colors.amber,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    BatchCoursesPage(
                                  batchId: batchId,
                                  batchName: batchName,
                                ),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Material(
                            color: Colors.white,
                            elevation: 3,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder:
                                  const CircleBorder(),
                              onTap: () {
                                _deleteBatch(
                                  batchId,
                                  batchName,
                                );
                              },
                              child: const SizedBox(
                                width: 40,
                                height: 40,
                                child: Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
    );
  }
}

// ============================================================
// BATCH COURSES
// ============================================================

class BatchCoursesPage extends StatefulWidget {
  final String batchId;
  final String batchName;

  const BatchCoursesPage({
    super.key,
    required this.batchId,
    required this.batchName,
  });

  @override
  State<BatchCoursesPage> createState() =>
      _BatchCoursesPageState();
}

class _BatchCoursesPageState
    extends State<BatchCoursesPage> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  bool isLoading = true;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> courses =
      [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final snapshot = await _firestore
          .collection('courses')
          .where(
            'batchId',
            isEqualTo: widget.batchId,
          )
          .get();

      if (!mounted) return;

      setState(() {
        courses = snapshot.docs;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load courses: $e'),
        ),
      );
    }
  }

  Future<void> _deleteCourse(
    String courseId,
    String courseTitle,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Course?'),
          content: Text(
            'Delete "$courseTitle"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await _firestore
          .collection('courses')
          .doc(courseId)
          .delete();

      await _loadCourses();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course deleted'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete course: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.batchName} - Courses"),
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (_) => AddCourseDialog(
              batchId: widget.batchId,
              batchName: widget.batchName,
              onCreated: _loadCourses,
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("New Course"),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : courses.isEmpty
              ? const Center(
                  child: Text(
                    "No courses created yet.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 17,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final doc = courses[index];
                    final data = doc.data();

                    final title =
                        data['title'] as String? ??
                            'Untitled Course';

                    final syllabusName =
                        data['syllabusFileName']
                                as String? ??
                            '';

                    return Card(
                      margin:
                          const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.menu_book),
                        ),
                        title: Text(title),
                        subtitle: syllabusName.isEmpty
                            ? null
                            : Text(
                                syllabusName,
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                              ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            _deleteCourse(
                              doc.id,
                              title,
                            );
                          },
                        ),
                        onTap: () {
                          final url =
                              data['syllabusUrl']
                                  as String?;

                          if (url != null &&
                              url.isNotEmpty) {
                            openUrl(url);
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

// ============================================================
// ADD COURSE
// ============================================================

class AddCourseDialog extends StatefulWidget {
  final String batchId;
  final String batchName;
  final Future<void> Function() onCreated;

  const AddCourseDialog({
    super.key,
    required this.batchId,
    required this.batchName,
    required this.onCreated,
  });

  @override
  State<AddCourseDialog> createState() =>
      _AddCourseDialogState();
}

class _AddCourseDialogState
    extends State<AddCourseDialog> {
  final TextEditingController titleController =
      TextEditingController();

  String? syllabusFileName;
  Uint8List? syllabusBytes;
  bool isLoading = false;

  Future<void> pickSyllabus() async {
    try {
      final result =
          await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
        ],
        allowMultiple: false,
        withData: true,
      );

      if (result == null) return;

      final file = result.files.single;

      if (file.bytes == null) {
        throw Exception(
          "Could not read the selected file.",
        );
      }

      setState(() {
        syllabusFileName = file.name;
        syllabusBytes = file.bytes;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error selecting syllabus: $e",
          ),
        ),
      );
    }
  }

  Future<void> createCourse() async {
    final title = titleController.text.trim();

    if (title.isEmpty ||
        syllabusBytes == null ||
        syllabusFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter a title and select a syllabus.",
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final user =
          FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception(
          "No authenticated user found.",
        );
      }

      final syllabusUrl =
          await CloudinaryService.uploadFile(
        fileBytes: syllabusBytes!,
        fileName: syllabusFileName!,
        resourceType: 'raw',
      );

      if (syllabusUrl == null) {
        throw Exception(
          "Syllabus upload failed.",
        );
      }

      await FirebaseFirestore.instance
          .collection("courses")
          .add({
        "title": title,
        "batchId": widget.batchId,
        "batchName": widget.batchName,
        "syllabusFileName": syllabusFileName,
        "syllabusUrl": syllabusUrl,
        "createdBy": user.uid,
        "createdAt":
            FieldValue.serverTimestamp(),
        "isActive": true,
      });

      if (!mounted) return;

      await widget.onCreated();

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Course Created Successfully ✅"),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create New Course"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Course Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed:
                  isLoading ? null : pickSyllabus,
              icon: const Icon(Icons.upload_file),
              label:
                  const Text("Upload Syllabus"),
            ),
            if (syllabusFileName != null)
              Padding(
                padding:
                    const EdgeInsets.only(top: 8),
                child: Text(
                  syllabusFileName!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.blue,
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: const Text("Cancel"),
        ),
        isLoading
            ? const Padding(
                padding: EdgeInsets.all(8),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              )
            : ElevatedButton(
                onPressed: createCourse,
                child: const Text("Create"),
              ),
      ],
    );
  }
}

// ============================================================
// MATERIALS PAGE
// ============================================================

class MaterialsPage extends StatefulWidget {
  const MaterialsPage({super.key});

  @override
  State<MaterialsPage> createState() =>
      _MaterialsPageState();
}

class _MaterialsPageState
    extends State<MaterialsPage> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  List<Map<String, String>> batches = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    try {
      final snapshot =
          await _firestore.collection('batches').get();

      if (!mounted) return;

      setState(() {
        batches = snapshot.docs.map((doc) {
          final data = doc.data();

          return {
            'id': doc.id,
            'name':
                data['name']?.toString() ??
                    'Unnamed Batch',
          };
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Failed to load batches: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : batches.isEmpty
              ? const Center(
                  child: Text(
                    "No batches created yet.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 17,
                    ),
                  ),
                )
              : buildFolderGrid(
                  cards: batches.map((batch) {
                    final batchId = batch['id']!;
                    final batchName = batch['name']!;

                    return FolderCard(
                      icon: Icons.folder,
                      label: batchName,
                      color: Colors.amber,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BatchMaterialsPage(
                              batchId: batchId,
                              batchName: batchName,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
    );
  }
}

// ============================================================
// BATCH MATERIALS
// ============================================================

class BatchMaterialsPage extends StatelessWidget {
  final String batchId;
  final String batchName;

  const BatchMaterialsPage({
    super.key,
    required this.batchId,
    required this.batchName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$batchName - Materials"),
      ),
      body: buildFolderGrid(
        cards: [
          FolderCard(
            icon: Icons.video_library,
            label: "Videos",
            color: Colors.redAccent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      VideoUploadPage(
                    batchId: batchId,
                    batchName: batchName,
                  ),
                ),
              );
            },
          ),
          FolderCard(
            icon: Icons.picture_as_pdf,
            label: "Notes",
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      NotesUploadPage(
                    batchId: batchId,
                    batchName: batchName,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// VIDEO PAGE
// ============================================================

class VideoUploadPage extends StatefulWidget {
  final String batchId;
  final String batchName;

  const VideoUploadPage({
    super.key,
    required this.batchId,
    required this.batchName,
  });

  @override
  State<VideoUploadPage> createState() =>
      _VideoUploadPageState();
}

class _VideoUploadPageState
    extends State<VideoUploadPage> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  bool isLoading = true;
  bool isUploading = false;

  List<QueryDocumentSnapshot<Map<String, dynamic>>>
      videos = [];

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    try {
      final snapshot = await _firestore
          .collection('materials')
          .where(
            'batchId',
            isEqualTo: widget.batchId,
          )
          .where(
            'type',
            isEqualTo: 'video',
          )
          .get();

      if (!mounted) return;

      setState(() {
        videos = snapshot.docs;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Failed to load videos: $e'),
        ),
      );
    }
  }

  Future<void> pickVideo() async {
    try {
      final result =
          await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
        withData: true,
      );

      if (result == null) return;

      final file = result.files.single;

      if (file.bytes == null) {
        throw Exception(
          "Could not read the video file.",
        );
      }

      setState(() {
        isUploading = true;
      });

      final url =
          await CloudinaryService.uploadFile(
        fileBytes: file.bytes!,
        fileName: file.name,
        resourceType: 'video',
      );

      if (url == null) {
        throw Exception(
          "Video upload failed.",
        );
      }

      final user =
          FirebaseAuth.instance.currentUser;

      await _firestore
          .collection('materials')
          .add({
        'type': 'video',
        'fileName': file.name,
        'url': url,
        'batchId': widget.batchId,
        'batchName': widget.batchName,
        'createdBy': user?.uid,
        'createdAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      await _loadVideos();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Video uploaded and saved successfully!",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Error uploading video: $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  Future<void> _deleteVideo(
    String documentId,
    String fileName,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Delete Video?"),
          content: Text(
            'Are you sure you want to delete "$fileName"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await _firestore
          .collection('materials')
          .doc(documentId)
          .delete();

      await _loadVideos();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Video removed from the app."),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Failed to delete video: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.batchName} - Videos",
        ),
      ),
      floatingActionButton:
          FloatingActionButton(
        onPressed:
            isUploading ? null : pickVideo,
        child: isUploading
            ? const CircularProgressIndicator(
                color: Colors.white,
              )
            : const Icon(Icons.upload),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : videos.isEmpty
              ? const Center(
                  child: Text(
                    "No videos uploaded yet.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 17,
                    ),
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.all(16),
                  itemCount: videos.length,
                  itemBuilder:
                      (context, index) {
                    final doc = videos[index];
                    final data = doc.data();

                    final fileName =
                        data['fileName']
                                as String? ??
                            "Video";

                    final url =
                        data['url']
                                as String? ??
                            "";

                    return Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: ListTile(
                        leading:
                            const CircleAvatar(
                          backgroundColor:
                              Colors.redAccent,
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          fileName,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                        ),
                        subtitle:
                            const Text(
                          "Tap to open video",
                        ),
                        onTap: url.isEmpty
                            ? null
                            : () {
                                openUrl(url);
                              },
                        trailing:
                            IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            _deleteVideo(
                              doc.id,
                              fileName,
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// ============================================================
// NOTES / PDF PAGE
// ============================================================

class NotesUploadPage extends StatefulWidget {
  final String batchId;
  final String batchName;

  const NotesUploadPage({
    super.key,
    required this.batchId,
    required this.batchName,
  });

  @override
  State<NotesUploadPage> createState() =>
      _NotesUploadPageState();
}

class _NotesUploadPageState
    extends State<NotesUploadPage> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  bool isLoading = true;
  bool isUploading = false;

  List<QueryDocumentSnapshot<Map<String, dynamic>>>
      notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      final snapshot = await _firestore
          .collection('materials')
          .where(
            'batchId',
            isEqualTo: widget.batchId,
          )
          .where(
            'type',
            isEqualTo: 'note',
          )
          .get();

      if (!mounted) return;

      setState(() {
        notes = snapshot.docs;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Failed to load notes: $e'),
        ),
      );
    }
  }

  Future<void> pickFile() async {
    try {
      final result =
          await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
        ],
        allowMultiple: false,
        withData: true,
      );

      if (result == null) return;

      final file = result.files.single;

      if (file.bytes == null) {
        throw Exception(
          "Could not read the selected file.",
        );
      }

      setState(() {
        isUploading = true;
      });

      final url =
          await CloudinaryService.uploadFile(
        fileBytes: file.bytes!,
        fileName: file.name,
        resourceType: 'raw',
      );

      if (url == null) {
        throw Exception(
          "File upload failed.",
        );
      }

      final user =
          FirebaseAuth.instance.currentUser;

      await _firestore
          .collection('materials')
          .add({
        'type': 'note',
        'fileName': file.name,
        'url': url,
        'batchId': widget.batchId,
        'batchName': widget.batchName,
        'createdBy': user?.uid,
        'createdAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      await _loadNotes();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "File uploaded and saved successfully!",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Error uploading file: $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  Future<void> _deleteNote(
    String documentId,
    String fileName,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Delete File?"),
          content: Text(
            'Are you sure you want to delete "$fileName"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await _firestore
          .collection('materials')
          .doc(documentId)
          .delete();

      await _loadNotes();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("File removed from the app."),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Failed to delete file: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text("${widget.batchName} - Notes"),
      ),
      floatingActionButton:
          FloatingActionButton(
        onPressed:
            isUploading ? null : pickFile,
        child: isUploading
            ? const CircularProgressIndicator(
                color: Colors.white,
              )
            : const Icon(Icons.upload_file),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : notes.isEmpty
              ? const Center(
                  child: Text(
                    "No notes uploaded yet.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 17,
                    ),
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.all(16),
                  itemCount: notes.length,
                  itemBuilder:
                      (context, index) {
                    final doc = notes[index];
                    final data = doc.data();

                    final fileName =
                        data['fileName']
                                as String? ??
                            "Document";

                    final url =
                        data['url']
                                as String? ??
                            "";

                    return Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: ListTile(
                        leading:
                            const CircleAvatar(
                          backgroundColor:
                              Colors.orange,
                          child: Icon(
                            Icons.picture_as_pdf,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          fileName,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                        ),
                        subtitle:
                            const Text(
                          "Tap to open document",
                        ),
                        onTap: url.isEmpty
                            ? null
                            : () {
                                openUrl(url);
                              },
                        trailing:
                            IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            _deleteNote(
                              doc.id,
                              fileName,
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// ============================================================
// OPEN URL
// ============================================================

Future<void> openUrl(String url) async {
  final uri = Uri.tryParse(url);

  if (uri == null) return;

  try {
    final launched = await launchUrl(
      uri,
      webOnlyWindowName: '_blank',
    );

    if (!launched) {
      debugPrint(
        "Could not open URL: $url",
      );
    }
  } catch (e) {
    debugPrint(
      "Error opening URL: $e",
    );
  }
}

// ============================================================
// TESTS PAGE
// ============================================================

class TestsPage extends StatefulWidget {
  const TestsPage({super.key});

  @override
  State<TestsPage> createState() =>
      _TestsPageState();
}

class _TestsPageState
    extends State<TestsPage> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  List<Map<String, String>> batches = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    try {
      final snapshot =
          await _firestore.collection('batches').get();

      if (!mounted) return;

      setState(() {
        batches = snapshot.docs.map((doc) {
          final data = doc.data();

          return {
            'id': doc.id,
            'name':
                data['name']?.toString() ??
                    'Unnamed Batch',
          };
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Failed to load batches: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : batches.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.quiz_outlined,
                        size: 60,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No batches created yet.",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                )
              : buildFolderGrid(
                  cards: batches.map((batch) {
                    final batchId =
                        batch['id']!;

                    final batchName =
                        batch['name']!;

                    return FolderCard(
                      icon: Icons.quiz,
                      label: batchName,
                      color:
                          Colors.deepPurple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TestQuestionsPage(
                              batchId: batchId,
                              batchName:
                                  batchName,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
    );
  }
}

// ============================================================
// TEST QUESTIONS PAGE
// ============================================================

class TestQuestionsPage extends StatefulWidget {
  final String batchId;
  final String batchName;

  const TestQuestionsPage({
    super.key,
    required this.batchId,
    required this.batchName,
  });

  @override
  State<TestQuestionsPage> createState() =>
      _TestQuestionsPageState();
}

class _TestQuestionsPageState
    extends State<TestQuestionsPage> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  bool isLoading = true;

  List<QueryDocumentSnapshot<Map<String, dynamic>>>
      questions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final snapshot = await _firestore
          .collection('tests')
          .where(
            'batchId',
            isEqualTo: widget.batchId,
          )
          .get();

      if (!mounted) return;

      setState(() {
        questions = snapshot.docs;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Failed to load questions: $e'),
        ),
      );
    }
  }

  Future<void> _deleteQuestion(
    String documentId,
    String question,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title:
              const Text("Delete Question?"),
          content: Text(
            'Are you sure you want to delete this question?\n\n"$question"',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child:
                  const Text("Cancel"),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
                foregroundColor:
                    Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child:
                  const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await _firestore
          .collection('tests')
          .doc(documentId)
          .delete();

      await _loadQuestions();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Question deleted."),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Failed to delete question: $e"),
        ),
      );
    }
  }

  Future<void> _showQuestionDialog({
    QueryDocumentSnapshot<Map<String, dynamic>>?
        existingDocument,
  }) async {
    final data = existingDocument?.data();

    await showDialog(
      context: context,
      builder: (_) {
        return QuestionDialog(
          batchId: widget.batchId,
          batchName: widget.batchName,
          existingData: data,
          documentId: existingDocument?.id,
          onSaved: _loadQuestions,
        );
      },
    );
  }

  Widget _buildOption(
    String label,
    String text,
    String correctAnswer,
  ) {
    final isCorrect =
        correctAnswer == label;

    return Padding(
      padding:
          const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            "$label. ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isCorrect
                  ? Colors.green
                  : Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isCorrect
                    ? Colors.green
                    : Colors.black87,
                fontWeight: isCorrect
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
          if (isCorrect)
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 18,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text("${widget.batchName} - Tests"),
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          _showQuestionDialog();
        },
        icon: const Icon(Icons.add),
        label:
            const Text("Add Question"),
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : questions.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.quiz_outlined,
                        size: 70,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No questions added yet.",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    100,
                  ),
                  itemCount:
                      questions.length,
                  itemBuilder:
                      (context, index) {
                    final doc =
                        questions[index];

                    final data =
                        doc.data();

                    final question =
                        data['question']
                                as String? ??
                            "Question";

                    final optionA =
                        data['optionA']
                                as String? ??
                            "";

                    final optionB =
                        data['optionB']
                                as String? ??
                            "";

                    final optionC =
                        data['optionC']
                                as String? ??
                            "";

                    final optionD =
                        data['optionD']
                                as String? ??
                            "";

                    final correctAnswer =
                        data['correctAnswer']
                                as String? ??
                            "";

                    return Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 14,
                      ),
                      elevation: 2,
                      child: Padding(
                        padding:
                            const EdgeInsets.all(
                          16,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Q${index + 1}. $question",
                                    style:
                                        const TextStyle(
                                      fontSize:
                                          17,
                                      fontWeight:
                                          FontWeight
                                              .w600,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  tooltip:
                                      "Edit",
                                  icon:
                                      const Icon(
                                    Icons.edit_outlined,
                                    color:
                                        Colors.blue,
                                  ),
                                  onPressed: () {
                                    _showQuestionDialog(
                                      existingDocument:
                                          doc,
                                    );
                                  },
                                ),
                                IconButton(
                                  tooltip:
                                      "Delete",
                                  icon:
                                      const Icon(
                                    Icons.delete_outline,
                                    color:
                                        Colors.red,
                                  ),
                                  onPressed: () {
                                    _deleteQuestion(
                                      doc.id,
                                      question,
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            _buildOption(
                              "A",
                              optionA,
                              correctAnswer,
                            ),
                            _buildOption(
                              "B",
                              optionB,
                              correctAnswer,
                            ),
                            _buildOption(
                              "C",
                              optionC,
                              correctAnswer,
                            ),
                            _buildOption(
                              "D",
                              optionD,
                              correctAnswer,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: Colors
                                    .green
                                    .withOpacity(
                                  0.08,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  8,
                                ),
                              ),
                              child: Text(
                                "Correct Answer: $correctAnswer",
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.green,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
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

// ============================================================
// QUESTION CREATE / EDIT DIALOG
// ============================================================

class QuestionDialog extends StatefulWidget {
  final String batchId;
  final String batchName;

  final Map<String, dynamic>? existingData;
  final String? documentId;

  final Future<void> Function() onSaved;

  const QuestionDialog({
    super.key,
    required this.batchId,
    required this.batchName,
    required this.onSaved,
    this.existingData,
    this.documentId,
  });

  @override
  State<QuestionDialog> createState() =>
      _QuestionDialogState();
}

class _QuestionDialogState
    extends State<QuestionDialog> {
  late final TextEditingController
      questionController;

  late final TextEditingController
      optionAController;

  late final TextEditingController
      optionBController;

  late final TextEditingController
      optionCController;

  late final TextEditingController
      optionDController;

  String? correctAnswer;

  bool isSaving = false;

  bool get isEditing =>
      widget.documentId != null;

  @override
  void initState() {
    super.initState();

    final data =
        widget.existingData ?? {};

    questionController =
        TextEditingController(
      text: data['question']?.toString() ??
          '',
    );

    optionAController =
        TextEditingController(
      text: data['optionA']?.toString() ??
          '',
    );

    optionBController =
        TextEditingController(
      text: data['optionB']?.toString() ??
          '',
    );

    optionCController =
        TextEditingController(
      text: data['optionC']?.toString() ??
          '',
    );

    optionDController =
        TextEditingController(
      text: data['optionD']?.toString() ??
          '',
    );

    final savedAnswer =
        data['correctAnswer']?.toString();

    if ([
      'A',
      'B',
      'C',
      'D',
    ].contains(savedAnswer)) {
      correctAnswer = savedAnswer;
    }
  }

  @override
  void dispose() {
    questionController.dispose();
    optionAController.dispose();
    optionBController.dispose();
    optionCController.dispose();
    optionDController.dispose();

    super.dispose();
  }

  Future<void> saveQuestion() async {
    final question =
        questionController.text.trim();

    final optionA =
        optionAController.text.trim();

    final optionB =
        optionBController.text.trim();

    final optionC =
        optionCController.text.trim();

    final optionD =
        optionDController.text.trim();

    if (question.isEmpty ||
        optionA.isEmpty ||
        optionB.isEmpty ||
        optionC.isEmpty ||
        optionD.isEmpty ||
        correctAnswer == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Please fill all fields and select the correct answer.",
          ),
        ),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final user =
          FirebaseAuth.instance.currentUser;

      final data = {
        'batchId': widget.batchId,
        'batchName': widget.batchName,
        'question': question,
        'optionA': optionA,
        'optionB': optionB,
        'optionC': optionC,
        'optionD': optionD,
        'correctAnswer': correctAnswer,
        'createdBy': user?.uid,
        'createdAt':
            FieldValue.serverTimestamp(),
      };

      if (isEditing) {
        await FirebaseFirestore.instance
            .collection('tests')
            .doc(widget.documentId)
            .update(data);
      } else {
        await FirebaseFirestore.instance
            .collection('tests')
            .add(data);
      }

      if (!mounted) return;

      await widget.onSaved();

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? "Question updated successfully."
                : "Question added successfully.",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text("Failed to save question: $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Widget _buildOptionField({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: "Option $label",
          prefixIcon: CircleAvatar(
            radius: 12,
            child: Text(
              label,
              style:
                  const TextStyle(fontSize: 12),
            ),
          ),
          border:
              const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        isEditing
            ? "Edit Question"
            : "Add Question",
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller:
                    questionController,
                maxLines: 3,
                decoration:
                    const InputDecoration(
                  labelText: "Question",
                  alignLabelWithHint: true,
                  border:
                      OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              _buildOptionField(
                label: "A",
                controller:
                    optionAController,
              ),
              _buildOptionField(
                label: "B",
                controller:
                    optionBController,
              ),
              _buildOptionField(
                label: "C",
                controller:
                    optionCController,
              ),
              _buildOptionField(
                label: "D",
                controller:
                    optionDController,
              ),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: correctAnswer,
                decoration:
                    const InputDecoration(
                  labelText:
                      "Correct Answer",
                  border:
                      OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "A",
                    child:
                        Text("A"),
                  ),
                  DropdownMenuItem(
                    value: "B",
                    child:
                        Text("B"),
                  ),
                  DropdownMenuItem(
                    value: "C",
                    child:
                        Text("C"),
                  ),
                  DropdownMenuItem(
                    value: "D",
                    child:
                        Text("D"),
                  ),
                ],
                onChanged: isSaving
                    ? null
                    : (value) {
                        setState(() {
                          correctAnswer =
                              value;
                        });
                      },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSaving
              ? null
              : () {
                  Navigator.pop(context);
                },
          child:
              const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed:
              isSaving ? null : saveQuestion,
          child: isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  isEditing
                      ? "Update"
                      : "Save",
                ),
        ),
      ],
    );
  }
}

// ============================================================
// MAPPING
// ============================================================

class MappingPage extends StatefulWidget {
  const MappingPage({super.key});

  @override
  State<MappingPage> createState() =>
      _MappingPageState();
}

class _MappingPageState
    extends State<MappingPage> {
  final List<String> batches = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) =>
                AddNameDialog(
              title: "New Batch",
              label: "Batch Name",
              onCreate: (value) {
                setState(() {
                  batches.add(value);
                });
              },
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("New Batch"),
      ),
      body: batches.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 60,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "No batches created yet.",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : buildFolderGrid(
              cards: batches.map(
                (batch) {
                  return FolderCard(
                    icon: Icons.folder,
                    label: batch,
                    color: Colors.indigo,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              BatchMappingPage(
                            batchName: batch,
                          ),
                        ),
                      );
                    },
                  );
                },
              ).toList(),
            ),
    );
  }
}

// ============================================================
// BATCH MAPPING
// ============================================================

class BatchMappingPage
    extends StatefulWidget {
  final String batchName;

  const BatchMappingPage({
    super.key,
    required this.batchName,
  });

  @override
  State<BatchMappingPage> createState() =>
      _BatchMappingPageState();
}

class _BatchMappingPageState
    extends State<BatchMappingPage> {
  final List<Map<String, String>>
      mappings = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text("${widget.batchName} - Mapping"),
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) =>
                AddMappingDialog(
              onCreate:
                  (tutor, student) {
                setState(() {
                  mappings.add({
                    "tutor": tutor,
                    "student": student,
                  });
                });
              },
            ),
          );
        },
        icon: const Icon(Icons.add),
        label:
            const Text("Add Mapping"),
      ),
      body: mappings.isEmpty
          ? const Center(
              child: Text(
                "No mappings added yet.",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              padding:
                  const EdgeInsets.all(16),
              itemCount:
                  mappings.length,
              itemBuilder:
                  (context, index) {
                return Card(
                  child: ListTile(
                    leading:
                        const Icon(
                      Icons.person,
                      color: Colors.indigo,
                    ),
                    title: Text(
                      "Tutor: ${mappings[index]["tutor"]}",
                    ),
                    subtitle: Text(
                      "Student: ${mappings[index]["student"]}",
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ============================================================
// ADD MAPPING
// ============================================================

class AddMappingDialog
    extends StatefulWidget {
  final void Function(
    String tutor,
    String student,
  ) onCreate;

  const AddMappingDialog({
    super.key,
    required this.onCreate,
  });

  @override
  State<AddMappingDialog> createState() =>
      _AddMappingDialogState();
}

class _AddMappingDialogState
    extends State<AddMappingDialog> {
  final TextEditingController
      tutorController =
      TextEditingController();

  final TextEditingController
      studentController =
      TextEditingController();

  @override
  void dispose() {
    tutorController.dispose();
    studentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Add Tutor-Student Mapping",
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller:
                tutorController,
            decoration:
                const InputDecoration(
              labelText:
                  "Tutor Name",
              border:
                  OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller:
                studentController,
            decoration:
                const InputDecoration(
              labelText:
                  "Student Name",
              border:
                  OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child:
              const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            final tutor =
                tutorController.text
                    .trim();

            final student =
                studentController.text
                    .trim();

            if (tutor.isEmpty ||
                student.isEmpty) {
              return;
            }

            widget.onCreate(
              tutor,
              student,
            );

            Navigator.pop(context);
          },
          child:
              const Text("Add"),
        ),
      ],
    );
  }
}

// ============================================================
// FEEDBACK
// ============================================================

class FeedbackPage
    extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    const List<
        Map<String, String>>
        feedbacks = [];

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Feedback"),
      ),
      body: feedbacks.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.feedback_outlined,
                    size: 60,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "No feedback received yet.",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding:
                  const EdgeInsets.all(16),
              itemCount:
                  feedbacks.length,
              itemBuilder:
                  (context, index) {
                return Card(
                  child: ListTile(
                    leading:
                        const Icon(
                      Icons.comment,
                      color: Colors.pink,
                    ),
                    title: Text(
                      feedbacks[index]
                              ["message"] ??
                          "",
                    ),
                    subtitle: Text(
                      feedbacks[index]
                              ["from"] ??
                          "",
                    ),
                  ),
                );
              },
            ),
    );
  }
}