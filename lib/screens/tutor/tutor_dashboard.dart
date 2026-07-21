import 'package:flutter/material.dart';

class TutorDashboard extends StatefulWidget {
  const TutorDashboard({super.key});

  @override
  State<TutorDashboard> createState() => _TutorDashboardState();
}

class _TutorDashboardState extends State<TutorDashboard> {
  int index = 0;

  final pages = const [
    TutorHomePage(),
    AssignedStudentsPage(),
    CreateTestPage(),
    EvaluatePage(),
    FeedbackPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tutor Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {},
          )
        ],
      ),
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        type: BottomNavigationBarType.fixed,
        onTap: (value) {
          setState(() => index = value);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Students"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Tests"),
          BottomNavigationBarItem(icon: Icon(Icons.grading), label: "Evaluate"),
          BottomNavigationBarItem(icon: Icon(Icons.feedback), label: "Feedback"),
        ],
      ),
    );
  }
}

class TutorHomePage extends StatelessWidget {
  const TutorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(20),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: const [
        DashboardCard(title: "Assigned Students", value: "0", icon: Icons.people),
        DashboardCard(title: "Pending Tests", value: "0", icon: Icons.assignment),
        DashboardCard(title: "To Evaluate", value: "0", icon: Icons.grading),
        DashboardCard(title: "Feedback Given", value: "0", icon: Icons.feedback),
      ],
    );
  }
}

class AssignedStudentsPage extends StatelessWidget {
  const AssignedStudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("List of Assigned Students\nTrack Progress Here"),
    );
  }
}

class CreateTestPage extends StatelessWidget {
  const CreateTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: const Center(
        child: Text("Create / Schedule Tests"),
      ),
    );
  }
}

class EvaluatePage extends StatelessWidget {
  const EvaluatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Evaluate Submitted Tests"),
    );
  }
}

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add_comment),
      ),
      body: const Center(
        child: Text("Give Feedback to Students"),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}