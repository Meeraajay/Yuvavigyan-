import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String? selectedStudent;
  String? selectedFileName;
  PlatformFile? selectedFile;

  final List<String> students = [
    "Lakshmi Amma",
    "Joseph Uncle",
  ];

  Future<void> _chooseFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
      ],
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    setState(() {
      selectedFile = result.files.first;
      selectedFileName = result.files.first.name;
    });
  }

  void _uploadReport() {
    if (selectedStudent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a student first."),
        ),
      );
      return;
    }

    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please choose a report file."),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Report selected for $selectedStudent. "
          "Storage will be connected with the database.",
        ),
      ),
    );
  }

  void _clearFile() {
    setState(() {
      selectedFile = null;
      selectedFileName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 700,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Reports",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Upload reports for assigned students.",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),

              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.deepPurple,
                            child: Icon(
                              Icons.upload_file_rounded,
                              color: Colors.white,
                              size: 27,
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              "Upload Student Report",
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        "Select Student",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        value: selectedStudent,
                        decoration: InputDecoration(
                          hintText: "Choose a student",
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: students.map((student) {
                          return DropdownMenuItem<String>(
                            value: student,
                            child: Text(student),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedStudent = value;
                          });
                        },
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        "Report File",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 10),

                      InkWell(
                        onTap: _chooseFile,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade300,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.attach_file_rounded,
                                color: Colors.deepPurple,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  selectedFileName ??
                                      "Choose PDF or document",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: selectedFileName == null
                                        ? Colors.grey
                                        : Colors.black87,
                                    fontWeight:
                                        selectedFileName == null
                                            ? FontWeight.normal
                                            : FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (selectedFileName != null)
                                IconButton(
                                  onPressed: _clearFile,
                                  icon: const Icon(
                                    Icons.close_rounded,
                                  ),
                                  tooltip: "Remove file",
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Supported formats: PDF, DOC, DOCX",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _uploadReport,
                          icon: const Icon(
                            Icons.cloud_upload_outlined,
                          ),
                          label: const Text(
                            "Upload Report",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.deepPurple,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Reports will be securely stored and linked "
                        "to the selected student when the database "
                        "and file storage are connected.",
                        style: TextStyle(
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}