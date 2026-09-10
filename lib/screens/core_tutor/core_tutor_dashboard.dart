import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../widgets/dashboard_card.dart';
import '../../services/cloudinary_service.dart';

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

////////////////////////////////////////////////////
/// SHARED: SMALL FOLDER CARD
////////////////////////////////////////////////////

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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.25),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared small-grid layout for folder cards (used by every "folder" page).
Widget buildFolderGrid({required List<Widget> cards}) {
  return GridView.count(
    padding: const EdgeInsets.all(16),
    crossAxisCount: 3,
    childAspectRatio: 0.95,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
    children: cards,
  );
}

////////////////////////////////////////////////////
/// SHARED: GENERIC "ADD NAME" DIALOG
////////////////////////////////////////////////////

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
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (controller.text.trim().isEmpty) return;
            widget.onCreate(controller.text.trim());
            Navigator.pop(context);
          },
          child: Text(widget.confirmText),
        ),
      ],
    );
  }
}

////////////////////////////////////////////////////
/// HOME PAGE
////////////////////////////////////////////////////

class CoreHomePage extends StatelessWidget {
  const CoreHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(20),
      crossAxisCount: 2,
      childAspectRatio: 1.9,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildClickCard(context, Icons.book, "Courses", 1),
        _buildClickCard(context, Icons.folder, "Materials", 2),
        _buildClickCard(context, Icons.quiz, "Tests", 3),
        _buildClickCard(context, Icons.people, "Tutor-Student Mapping", 4),
        _buildClickCard(context, Icons.feedback, "Feedback", 5),
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
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
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
              radius: 20,
              backgroundColor: Colors.blue[50],
              child: Icon(
                icon,
                size: 22,
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

////////////////////////////////////////////////////
/// COURSES PAGE  (folders by batch)
////////////////////////////////////////////////////

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final List<String> batches = [];

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
              onCreate: (value) => setState(() => batches.add(value)),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("New Batch"),
      ),
      body: batches.isEmpty
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
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : buildFolderGrid(
              cards: batches
                  .map(
                    (batch) => FolderCard(
                      icon: Icons.folder,
                      label: batch,
                      color: Colors.amber,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BatchCoursesPage(batchName: batch),
                          ),
                        );
                      },
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

////////////////////////////////////////////////////
/// COURSES INSIDE A BATCH
////////////////////////////////////////////////////

class BatchCoursesPage extends StatefulWidget {
  final String batchName;
  const BatchCoursesPage({super.key, required this.batchName});

  @override
  State<BatchCoursesPage> createState() => _BatchCoursesPageState();
}

class _BatchCoursesPageState extends State<BatchCoursesPage> {
  final List<String> courses = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.batchName} - Courses")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddNameDialog(
              title: "Create New Course",
              label: "Course Title",
              onCreate: (value) => setState(() => courses.add(value)),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("New Course"),
      ),
      body: courses.isEmpty
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
                    "No courses created yet.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: courses.length,
              itemBuilder: (context, i) => Card(
                child: ListTile(
                  leading: const Icon(Icons.menu_book, color: Colors.blue),
                  title: Text(courses[i]),
                ),
              ),
            ),
    );
  }
}

////////////////////////////////////////////////////
/// MATERIALS PAGE (merged Videos + Materials, folders by batch)
////////////////////////////////////////////////////

class MaterialsPage extends StatefulWidget {
  const MaterialsPage({super.key});

  @override
  State<MaterialsPage> createState() => _MaterialsPageState();
}

class _MaterialsPageState extends State<MaterialsPage> {
  final List<String> batches = [];

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
              onCreate: (value) => setState(() => batches.add(value)),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("New Batch"),
      ),
      body: batches.isEmpty
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
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : buildFolderGrid(
              cards: batches
                  .map(
                    (batch) => FolderCard(
                      icon: Icons.folder,
                      label: batch,
                      color: Colors.amber,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BatchMaterialsPage(batchName: batch),
                          ),
                        );
                      },
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

////////////////////////////////////////////////////
/// VIDEOS + NOTES INSIDE A BATCH
////////////////////////////////////////////////////

class BatchMaterialsPage extends StatelessWidget {
  final String batchName;
  const BatchMaterialsPage({super.key, required this.batchName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$batchName - Materials")),
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
                  builder: (_) => VideoUploadPage(batchName: batchName),
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
                  builder: (_) => NotesUploadPage(batchName: batchName),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////
/// VIDEO UPLOAD PAGE
////////////////////////////////////////////////////

class VideoUploadPage extends StatefulWidget {
  final String batchName;
  const VideoUploadPage({super.key, required this.batchName});

  @override
  State<VideoUploadPage> createState() => _VideoUploadPageState();
}

class _VideoUploadPageState extends State<VideoUploadPage> {
  String? selectedFileName;

  Future<void> pickVideo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
        withData: true,
      );

      if (result != null) {
  final file = result.files.single;

  if (file.bytes == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Could not read the video file.")),
    );
    return;
  }

  setState(() {
    selectedFileName = file.name;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Uploading video...")),
  );

  final url = await CloudinaryService.uploadFile(
    fileBytes: file.bytes!,
    fileName: file.name,
    resourceType: 'video',
  );

  if (url != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Video uploaded successfully!")),
    );

    print("Cloudinary Video URL: $url");
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Video upload failed.")),
    );
  }
} else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No file selected")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error picking file.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.batchName} - Videos")),
      floatingActionButton: FloatingActionButton(
        onPressed: pickVideo,
        child: const Icon(Icons.upload),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selectedFileName != null) ...[
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 50,
              ),
              const SizedBox(height: 15),
              const Text(
                "Ready to upload:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                selectedFileName!,
                style: const TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ] else ...[
              const Icon(
                Icons.videocam_outlined,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 20),
              const Text(
                "Tap the button to select a video.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////
/// NOTES UPLOAD PAGE
////////////////////////////////////////////////////

class NotesUploadPage extends StatefulWidget {
  final String batchName;
  const NotesUploadPage({super.key, required this.batchName});

  @override
  State<NotesUploadPage> createState() => _NotesUploadPageState();
}

class _NotesUploadPageState extends State<NotesUploadPage> {
  String? selectedFileName;

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          selectedFileName = result.files.single.name;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Selected: $selectedFileName")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No file selected")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error picking file.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.batchName} - Notes")),
      floatingActionButton: FloatingActionButton(
        onPressed: pickFile,
        child: const Icon(Icons.upload_file),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selectedFileName != null) ...[
              const Icon(
                Icons.insert_drive_file,
                color: Colors.orange,
                size: 50,
              ),
              const SizedBox(height: 15),
              const Text(
                "Ready to upload:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                selectedFileName!,
                style: const TextStyle(fontSize: 16, color: Colors.orange),
              ),
            ] else ...[
              const Icon(
                Icons.folder_open,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 20),
              const Text(
                "Tap the button to select a PDF or note.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////
/// TESTS PAGE (Questions & Answer Key folders)
////////////////////////////////////////////////////

class TestsPage extends StatelessWidget {
  const TestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tests")),
      body: buildFolderGrid(
        cards: [
          FolderCard(
            icon: Icons.help_outline,
            label: "Questions",
            color: Colors.deepPurple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TestItemsPage(
                    title: "Questions",
                    emptyText: "No questions added yet.",
                    addLabel: "Add Question",
                  ),
                ),
              );
            },
          ),
          FolderCard(
            icon: Icons.key,
            label: "Answer Key",
            color: Colors.teal,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TestItemsPage(
                    title: "Answer Key",
                    emptyText: "No answer keys added yet.",
                    addLabel: "Add Answer Key",
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

////////////////////////////////////////////////////
/// GENERIC TEST ITEMS LIST (used by both Questions & Answer Key)
////////////////////////////////////////////////////

class TestItemsPage extends StatefulWidget {
  final String title;
  final String emptyText;
  final String addLabel;

  const TestItemsPage({
    super.key,
    required this.title,
    required this.emptyText,
    required this.addLabel,
  });

  @override
  State<TestItemsPage> createState() => _TestItemsPageState();
}

class _TestItemsPageState extends State<TestItemsPage> {
  final List<String> items = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddNameDialog(
              title: widget.addLabel,
              label: "Title",
              onCreate: (value) => setState(() => items.add(value)),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(widget.addLabel),
      ),
      body: items.isEmpty
          ? Center(
              child: Text(
                widget.emptyText,
                style: const TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, i) => Card(
                child: ListTile(
                  leading: const Icon(Icons.description, color: Colors.blueGrey),
                  title: Text(items[i]),
                ),
              ),
            ),
    );
  }
}

////////////////////////////////////////////////////
/// TUTOR-STUDENT MAPPING PAGE (folders by batch)
////////////////////////////////////////////////////

class MappingPage extends StatefulWidget {
  const MappingPage({super.key});

  @override
  State<MappingPage> createState() => _MappingPageState();
}

class _MappingPageState extends State<MappingPage> {
  final List<String> batches = [];

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
              onCreate: (value) => setState(() => batches.add(value)),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("New Batch"),
      ),
      body: batches.isEmpty
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
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : buildFolderGrid(
              cards: batches
                  .map(
                    (batch) => FolderCard(
                      icon: Icons.folder,
                      label: batch,
                      color: Colors.indigo,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BatchMappingPage(batchName: batch),
                          ),
                        );
                      },
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

////////////////////////////////////////////////////
/// MAPPING INSIDE A BATCH
////////////////////////////////////////////////////

class BatchMappingPage extends StatefulWidget {
  final String batchName;
  const BatchMappingPage({super.key, required this.batchName});

  @override
  State<BatchMappingPage> createState() => _BatchMappingPageState();
}

class _BatchMappingPageState extends State<BatchMappingPage> {
  final List<Map<String, String>> mappings = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.batchName} - Mapping")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddMappingDialog(
              onCreate: (tutor, student) {
                setState(() {
                  mappings.add({"tutor": tutor, "student": student});
                });
              },
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Mapping"),
      ),
      body: mappings.isEmpty
          ? const Center(
              child: Text(
                "No mappings added yet.",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mappings.length,
              itemBuilder: (context, i) => Card(
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.indigo),
                  title: Text("Tutor: ${mappings[i]["tutor"]}"),
                  subtitle: Text("Student: ${mappings[i]["student"]}"),
                ),
              ),
            ),
    );
  }
}

////////////////////////////////////////////////////
/// ADD MAPPING DIALOG
////////////////////////////////////////////////////

class AddMappingDialog extends StatefulWidget {
  final void Function(String tutor, String student) onCreate;
  const AddMappingDialog({super.key, required this.onCreate});

  @override
  State<AddMappingDialog> createState() => _AddMappingDialogState();
}

class _AddMappingDialogState extends State<AddMappingDialog> {
  final TextEditingController tutorController = TextEditingController();
  final TextEditingController studentController = TextEditingController();

  @override
  void dispose() {
    tutorController.dispose();
    studentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Tutor-Student Mapping"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: tutorController,
            decoration: const InputDecoration(
              labelText: "Tutor Name",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: studentController,
            decoration: const InputDecoration(
              labelText: "Student Name",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (tutorController.text.trim().isEmpty ||
                studentController.text.trim().isEmpty) {
              return;
            }
            widget.onCreate(
              tutorController.text.trim(),
              studentController.text.trim(),
            );
            Navigator.pop(context);
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}

////////////////////////////////////////////////////
/// FEEDBACK PAGE
////////////////////////////////////////////////////

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Wire this up to real feedback data once you have a backend/store.
    final List<Map<String, String>> feedbacks = [];

    return Scaffold(
      appBar: AppBar(title: const Text("Feedback")),
      body: feedbacks.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.feedback_outlined,
                    size: 60,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "No feedback received yet.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: feedbacks.length,
              itemBuilder: (context, i) => Card(
                child: ListTile(
                  leading: const Icon(Icons.comment, color: Colors.pink),
                  title: Text(feedbacks[i]["message"] ?? ""),
                  subtitle: Text(feedbacks[i]["from"] ?? ""),
                ),
              ),
            ),
    );
  }
}