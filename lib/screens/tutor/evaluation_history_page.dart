import 'package:flutter/material.dart';

class EvaluationHistoryPage extends StatelessWidget {
  const EvaluationHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Evaluation History"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Evaluation History",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            // ----------------------------------------------------------
            // STUDENT
            // ----------------------------------------------------------

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

                    Row(
                      children: [

                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.deepPurple.shade50,
                          child: const Icon(
                            Icons.person,
                            color: Colors.deepPurple,
                            size: 30,
                          ),
                        ),

                        const SizedBox(width: 15),

                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              "Lakshmi Amma",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 4),

                            Text(
                              "YUVAVIJNAN 2026",
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Divider(height: 30),

                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.menu_book),
                      title: Text("Session 4"),
                      subtitle: Text("Digital Payments"),
                    ),

                    const Divider(),

                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.calendar_today),
                      title: Text("Evaluation Date"),
                      subtitle: Text("24 August 2026"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ----------------------------------------------------------
            // PERFORMANCE
            // ----------------------------------------------------------

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
                      "Performance",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [

                        Expanded(
                          child: _ScoreCard(
                            title: "Understanding",
                            value: "3 / 5",
                            icon: Icons.psychology,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _ScoreCard(
                            title: "Assessment",
                            value: "8 / 10",
                            icon: Icons.assignment_turned_in,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ----------------------------------------------------------
            // TUTOR REMARKS
            // ----------------------------------------------------------

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

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Student understands the topic well but needs "
                        "more practice with digital payments.",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ----------------------------------------------------------
            // FEEDBACK
            // ----------------------------------------------------------

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
                      "Feedback",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: const [

                        Icon(
                          Icons.category,
                          color: Colors.deepPurple,
                        ),

                        SizedBox(width: 10),

                        Text(
                          "General",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "Performance Rating: 3 / 5",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// SCORE CARD
// ======================================================================

class _ScoreCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _ScoreCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [

          Icon(
            icon,
            color: Colors.deepPurple,
            size: 30,
          ),

          const SizedBox(height: 10),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}