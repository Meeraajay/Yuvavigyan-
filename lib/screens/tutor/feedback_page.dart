import 'package:flutter/material.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  double rating = 3;
  String selectedCategory = "General";

  final TextEditingController feedbackController =
      TextEditingController();

  @override
  void dispose() {
    feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Give Feedback"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Student Feedback",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            // STUDENT INFORMATION
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),

              child: const Padding(
                padding: EdgeInsets.all(18),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      "Student Information",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 15),

                    ListTile(
                      leading: CircleAvatar(
                        child: Icon(Icons.person),
                      ),

                      title: Text("Lakshmi Amma"),

                      subtitle: Text(
                        "Batch: YUVAVIJNAN 2026",
                      ),
                    ),

                    Divider(),

                    ListTile(
                      leading: Icon(Icons.menu_book),

                      title: Text("Current Session"),

                      subtitle: Text(
                        "Session 4 • Digital Payments",
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // FEEDBACK CATEGORY
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),

              child: Padding(
                padding: const EdgeInsets.all(18),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Feedback Category",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      value: selectedCategory,

                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      items: const [
                        DropdownMenuItem(
                          value: "General",
                          child: Text("General"),
                        ),

                        DropdownMenuItem(
                          value: "Understanding",
                          child: Text("Understanding"),
                        ),

                        DropdownMenuItem(
                          value: "Participation",
                          child: Text("Participation"),
                        ),

                        DropdownMenuItem(
                          value: "Practice",
                          child: Text("Practice"),
                        ),

                        DropdownMenuItem(
                          value: "Improvement",
                          child: Text("Needs Improvement"),
                        ),
                      ],

                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // RATING
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),

              child: Padding(
                padding: const EdgeInsets.all(18),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Student Performance Rating",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Slider(
                      value: rating,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: rating.toInt().toString(),

                      onChanged: (value) {
                        setState(() {
                          rating = value;
                        });
                      },
                    ),

                    Center(
                      child: Text(
                        "${rating.toInt()} / 5",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // FEEDBACK TEXT
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),

              child: Padding(
                padding: const EdgeInsets.all(18),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Tutor Feedback",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: feedbackController,

                      maxLines: 6,

                      decoration: InputDecoration(
                        hintText:
                            "Enter your feedback about the student...",

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed: () {

                  if (feedbackController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please enter feedback before saving.",
                        ),
                      ),
                    );

                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Feedback Saved Successfully",
                      ),
                    ),
                  );
                },

                icon: const Icon(Icons.save),

                label: const Text(
                  "Save Feedback",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}