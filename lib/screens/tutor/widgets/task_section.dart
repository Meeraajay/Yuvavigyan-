import 'package:flutter/material.dart';

import '../attendance_page.dart';
import '../evaluation_form_page.dart';
import '../feedback_page.dart';

class TaskSection extends StatelessWidget {
  const TaskSection({super.key});

  void _openSessionDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Conduct Session 4"),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Topic: Digital Payments",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text("Session: 4"),
              Text("Time: 10:00 AM"),
              SizedBox(height: 12),
              Text(
                "This session covers the basics of digital payments "
                "and helps students understand how to use digital "
                "payment methods safely.",
              ),
            ],
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Today's Session Plan",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 15),

        // Conduct Session
        _buildTaskCard(
          color: Colors.blue,
          icon: Icons.menu_book_rounded,
          title: "Conduct Session 4",
          subtitle: "Topic: Digital Payments",
          time: "10:00 AM",
          onTap: () {
            _openSessionDetails(context);
          },
        ),

        // Mark Attendance
        _buildTaskCard(
          color: Colors.green,
          icon: Icons.how_to_reg,
          title: "Mark Attendance",
          subtitle: "Record today's attendance",
          time: "During Class",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AttendancePage(),
              ),
            );
          },
        ),

        // Conduct Practice Activity
        _buildTaskCard(
          color: Colors.orange,
          icon: Icons.assignment_turned_in_outlined,
          title: "Conduct Practice Activity",
          subtitle: "Check student understanding",
          time: "After Session",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EvaluationFormPage(),
              ),
            );
          },
        ),

        // Submit Feedback
        _buildTaskCard(
          color: Colors.purple,
          icon: Icons.rate_review_outlined,
          title: "Submit Feedback",
          subtitle: "Update learning progress",
          time: "Before 5:00 PM",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FeedbackPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTaskCard({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required VoidCallback onTap,
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
      child: ListTile(
        onTap: onTap,

        leading: CircleAvatar(
          backgroundColor: color.withOpacity(.15),
          child: Icon(
            icon,
            color: color,
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(
          "$subtitle\n$time",
        ),

        isThreeLine: true,

        trailing: const Icon(
          Icons.chevron_right,
        ),
      ),
    );
  }
}