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
    required Color color,
    required IconData icon,
    required String studentName,
    required String status,
    required List<String> reasons,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

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
                    Expanded(child: Text(reason)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  // Navigate to Student Details later
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
}