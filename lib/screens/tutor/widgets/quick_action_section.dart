import 'package:flutter/material.dart';

class QuickActionSection extends StatelessWidget {
  final void Function(int) onNavigate;

  const QuickActionSection({
    super.key,
    required this.onNavigate,
  });

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
              () {
                onNavigate(1);
              },
            ),

            _actionCard(
              "Tests",
              Icons.assignment,
              Colors.green,
              () {
                _showTestsComingSoon(context);
              },
            ),

            _actionCard(
              "Evaluate",
              Icons.grading,
              Colors.orange,
              () {
                onNavigate(2);
              },
            ),

            _actionCard(
              "Feedback",
              Icons.feedback,
              Colors.purple,
              () {
                onNavigate(4);
              },
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
    VoidCallback onTap,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,

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

  void _showTestsComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Tests"),
          content: const Text(
            "The Tests module is still under development.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}