import 'package:flutter/material.dart';

class EvaluationFormPage extends StatefulWidget {
  const EvaluationFormPage({super.key});

  @override
  State<EvaluationFormPage> createState() => _EvaluationFormPageState();
}

class _EvaluationFormPageState extends State<EvaluationFormPage> {
  int selectedScore = 0;
  double understandingRating = 3;
  final TextEditingController remarksController = TextEditingController();

  @override
  void dispose() {
    remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Student Evaluation",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

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
                      subtitle: Text("Assigned Student"),
                    ),

                    Divider(),

                    ListTile(
                      leading: Icon(Icons.menu_book),
                      title: Text("Current Session"),
                      subtitle: Text("Session 4 • Digital Payments"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

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
                      "Understanding Level",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Slider(
                      value: understandingRating,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: understandingRating.toString(),
                      onChanged: (value) {
                        setState(() {
                          understandingRating = value;
                        });
                      },
                    ),

                    Center(
                      child: Text(
                        "${understandingRating.toInt()} / 5",
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
                      "Assessment Score",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(
                        11,
                        (index) => ChoiceChip(
                          label: Text(index.toString()),
                          selected: selectedScore == index,
                          onSelected: (_) {
                            setState(() {
                              selectedScore = index;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

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
                      "Tutor Remarks",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: remarksController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: "Enter evaluation remarks...",
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

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Evaluation Saved Successfully"),
                    ),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text(
                  "Save Evaluation",
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