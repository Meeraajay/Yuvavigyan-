import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

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
        ],
      ),
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
    return const Center(
      child: Text(
        "Welcome Core Tutor",
        style: TextStyle(fontSize: 22),
      ),
    );
  }
}

////////////////////////////////////////////////////
/// COURSE PAGE
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
      body: const Center(
        child: Text(
          "Courses will appear here",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////
/// ADD COURSE DIALOG
////////////////////////////////////////////////////

class AddCourseDialog extends StatefulWidget {
  const AddCourseDialog({super.key});

  @override
  State<AddCourseDialog> createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<AddCourseDialog> {
  final TextEditingController titleController =
      TextEditingController();

  String? syllabusFileName;
  Uint8List? syllabusBytes;

  bool isLoading = false;

  Future<void> pickSyllabus() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        syllabusFileName = result.files.single.name;
        syllabusBytes = result.files.single.bytes;
      });
    }
  }

  Future<void> createCourse() async {
    if (titleController.text.isEmpty ||
        syllabusBytes == null ||
        syllabusFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1️⃣ Upload file to Firebase Storage
      String filePath =
          "syllabus/${titleController.text}_${DateTime.now().millisecondsSinceEpoch}.pdf";

      Reference ref =
          FirebaseStorage.instance.ref().child(filePath);

      await ref.putData(syllabusBytes!);

      String downloadUrl = await ref.getDownloadURL();

      // 2️⃣ Save course to Firestore
      await FirebaseFirestore.instance.collection("courses").add({
        "title": titleController.text.trim(),
        "syllabusFileName": syllabusFileName,
        "syllabusUrl": downloadUrl,
        "createdBy": FirebaseAuth.instance.currentUser!.uid,
        "createdAt": FieldValue.serverTimestamp(),
        "isActive": true,
      });

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Course Created Successfully ✅"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create New Course"),
      content: SingleChildScrollView(
        child: Column(
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
              onPressed: pickSyllabus,
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload Syllabus"),
            ),
            if (syllabusFileName != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  syllabusFileName!,
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
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: createCourse,
                child: const Text("Create"),
              ),
      ],
    );
  }
}
