import 'package:flutter/material.dart';

class StudentsSupportSection extends StatelessWidget {
  const StudentsSupportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Students Requiring Support",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 15),

        _buildSupportCard(
          context: context,
          color: Colors.red,
          icon: Icons.priority_high,
          studentName: "Lakshmi Amma",
          status: "Needs Extra Support",
          reasons: const [
            "Assessment Score: 3/10",
            "Practice Activity Pending",
            "Recommended: One-to-one guidance",
          ],
        ),

        _buildSupportCard(
          context: context,
          color: Colors.orange,
          icon: Icons.warning_amber_rounded,
          studentName: "Joseph Uncle",
          status: "Needs Follow-up",
          reasons: const [
            "Session 4 Video Pending",
            "Assessment Yet to Complete",
          ],
        ),
      ],
    );
  }

  Widget _buildSupportCard({
    required BuildContext context,
    required Color color,
    required IconData icon,
    required String studentName,
    required String status,
    required List<String> reasons,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --------------------------------------------------
            // Student information
            // --------------------------------------------------
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.15),
                  child: Icon(
                    icon,
                    color: color,
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        status,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // --------------------------------------------------
            // Reason
            // --------------------------------------------------
            const Text(
              "Reason",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            ...reasons.map(
              (reason) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("• "),
                    Expanded(
                      child: Text(reason),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // --------------------------------------------------
            // View Details button
            // --------------------------------------------------
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  _showStudentSupportDetails(
                    context: context,
                    color: color,
                    icon: icon,
                    studentName: studentName,
                    status: status,
                    reasons: reasons,
                  );
                },
                icon: const Icon(Icons.visibility),
                label: const Text("View Details"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // STUDENT SUPPORT DETAILS
  // ==========================================================

  void _showStudentSupportDetails({
    required BuildContext context,
    required Color color,
    required IconData icon,
    required String studentName,
    required String status,
    required List<String> reasons,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          titlePadding: const EdgeInsets.fromLTRB(
            24,
            24,
            24,
            8,
          ),

          contentPadding: const EdgeInsets.fromLTRB(
            24,
            10,
            24,
            10,
          ),

          actionsPadding: const EdgeInsets.fromLTRB(
            16,
            5,
            16,
            16,
          ),

          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Icon(
                  icon,
                  color: color,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  studentName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        color: color,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          status,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Support Required",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                // Reasons
                ...reasons.map(
                  (reason) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 20,
                          color: color,
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            reason,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Recommended action
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Recommended Action",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),

                      SizedBox(height: 6),

                      Text(
                        "Tutor should follow up with the student "
                        "and provide the required learning support.",
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}