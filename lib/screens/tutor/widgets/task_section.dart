import 'package:flutter/material.dart';

class TaskSection extends StatelessWidget {
  const TaskSection({super.key});

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

        _buildTaskCard(
          color: Colors.blue,
          icon: Icons.menu_book_rounded,
          title: "Conduct Session 4",
          subtitle: "Topic: Digital Payments",
          time: "10:00 AM",
        ),

        _buildTaskCard(
          color: Colors.green,
          icon: Icons.how_to_reg,
          title: "Mark Attendance",
          subtitle: "Record today's attendance",
          time: "During Class",
        ),

        _buildTaskCard(
          color: Colors.orange,
          icon: Icons.assignment_turned_in_outlined,
          title: "Conduct Practice Activity",
          subtitle: "Check student understanding",
          time: "After Session",
        ),

        _buildTaskCard(
          color: Colors.purple,
          icon: Icons.rate_review_outlined,
          title: "Submit Feedback",
          subtitle: "Update learning progress",
          time: "Before 5:00 PM",
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
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(.15),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text("$subtitle\n$time"),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}