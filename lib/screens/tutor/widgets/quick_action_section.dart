import 'package:flutter/material.dart';

class QuickActionSection extends StatelessWidget {
  const QuickActionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 18),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.5,
          children: [
            _actionCard(
              "Students",
              Icons.people,
              Colors.blue,
            ),
            _actionCard(
              "Tests",
              Icons.assignment,
              Colors.green,
            ),
            _actionCard(
              "Evaluate",
              Icons.grading,
              Colors.orange,
            ),
            _actionCard(
              "Feedback",
              Icons.feedback,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionCard(
    String title,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        // Navigation will be added later
      },
      child: Card(
        elevation: 4,
        shadowColor: color.withOpacity(.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: color.withOpacity(.12),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}