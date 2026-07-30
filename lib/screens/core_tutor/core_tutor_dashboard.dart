import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
// Ensure this path matches your widgets folder
import '../../widgets/dashboard_card.dart'; 

class CoreTutorDashboard extends StatefulWidget {
  const CoreTutorDashboard({super.key});

  @override
  State<CoreTutorDashboard> createState() => _CoreTutorDashboardState();
}

class _CoreTutorDashboardState extends State<CoreTutorDashboard> {
  int index = 0;

  final pages = const [
    CoreHomePage(),
    CoursePage(),
    VideoPage(),
    MaterialPage(),
    QuestionBankPage(),
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
        onTap: (value) {
          setState(() {
            index = value;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Courses"),
          BottomNavigationBarItem(icon: Icon(Icons.video_library), label: "Videos"),
          BottomNavigationBarItem(icon: Icon(Icons.picture_as_pdf), label: "Materials"),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: "Tests"),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////
/// ✅ HOME PAGE WITH CLICKABLE SMALL CARDS
////////////////////////////////////////////////////

class CoreHomePage extends StatelessWidget {
  const CoreHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(20),
      crossAxisCount: 2,
      childAspectRatio: 1.5, 
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: [
        _buildClickCard(
          context,
          const DashboardCard(
            title: "Total Courses",
            value: "0",
            icon: Icons.book,
          ),
          1,
        ),
        _buildClickCard(
          context,
          const DashboardCard(
            title: "Videos",
            value: "0",
            icon: Icons.video_library,
          ),
          2,
        ),
        _buildClickCard(
          context,
          const DashboardCard(
            title: "Materials",
            value: "0",
            icon: Icons.picture_as_pdf,
          ),
          3,
        ),
        _buildClickCard(
          context,
          const DashboardCard(
            title: "Tests",
            value: "0",
            icon: Icons.quiz,
          ),
          4,
        ),
      ],
      ],
    );
  }

  Widget _buildClickCard(BuildContext context, IconData icon, String text, int pageIndex) {
    return InkWell(
      onTap: () {
        final parent = context.findAncestorStateOfType<_CoreTutorDashboardState>();
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
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.blue[50],
              child: Icon(icon, size: 30, color: Colors.blue),
            ),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
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
/// ✅ COURSE PAGE
////////////////////////////////////////////////////

class CoursePage extends StatelessWidget {
  const CoursePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AddCourseDialog(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("New Course"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 60, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              "No courses created yet.",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class AddCourseDialog extends StatefulWidget {
  const AddCourseDialog({super.key});

  @override
  State<AddCourseDialog> createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<AddCourseDialog> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController syllabusController = TextEditingController();

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
            TextField(
              controller: syllabusController,
              decoration: const InputDecoration(
                labelText: "Syllabus Description",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            print("Course Created: ${titleController.text}");
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Course Created!")));
          },
          child: const Text("Create"),
        )
      ],
    );
  }
}

////////////////////////////////////////////////////
/// ✅ VIDEO PAGE (FIXED FOR V6.1.1)
////////////////////////////////////////////////////

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  String? selectedFileName;

  Future<void> pickVideo() async {
    try {
      // Correct syntax for v6.1.1
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
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
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No file selected")));
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error picking file.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Videos")),
      floatingActionButton: FloatingActionButton(onPressed: pickVideo, child: const Icon(Icons.upload)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selectedFileName != null) ...[
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 50),
              const SizedBox(height: 15),
              Text("Ready to upload:", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(selectedFileName!, style: const TextStyle(fontSize: 16, color: Colors.blue)),
            ] else ...[
              const Icon(Icons.videocam_outlined, size: 80, color: Colors.grey),
              const SizedBox(height: 20),
              const Text("Tap the button to select a video.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////
/// ✅ MATERIAL PAGE (FIXED FOR V6.1.1)
////////////////////////////////////////////////////

class MaterialPage extends StatefulWidget {
  const MaterialPage({super.key});

  @override
  State<MaterialPage> createState() => _MaterialPageState();
}

class _MaterialPageState extends State<MaterialPage> {
  String? selectedFileName;

  Future<void> pickFile() async {
    try {
      // Correct syntax for v6.1.1
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
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No file selected")));
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error picking file.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Materials")),
      floatingActionButton: FloatingActionButton(onPressed: pickFile, child: const Icon(Icons.upload_file)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selectedFileName != null) ...[
              const Icon(Icons.insert_drive_file, color: Colors.orange, size: 50),
              const SizedBox(height: 15),
              Text("Ready to upload:", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(selectedFileName!, style: const TextStyle(fontSize: 16, color: Colors.orange)),
            ] else ...[
              const Icon(Icons.folder_open, size: 80, color: Colors.grey),
              const SizedBox(height: 20),
              const Text("Tap the button to select a PDF or material.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////
/// ✅ QUESTION BANK PAGE
////////////////////////////////////////////////////

class QuestionBankPage extends StatelessWidget {
  const QuestionBankPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Question Bank")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Coming soon"))),
        icon: const Icon(Icons.add),
        label: const Text("Add Question"),
      ),
      body: const Center(child: Text("Question bank is empty.", style: TextStyle(color: Colors.grey))),
    );
  }
}
