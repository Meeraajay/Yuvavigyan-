import 'package:flutter/material.dart';

class CoreTutorDashboard extends StatefulWidget {
  const CoreTutorDashboard({super.key});

  @override
  State<CoreTutorDashboard> createState() => _CoreTutorDashboardState();
}

class _CoreTutorDashboardState extends State<CoreTutorDashboard> {
  int index = 0;

  final pages = const [
    CoreHomePage(),
    CoursePage(),
    VideoPage(),
    MaterialPage(),
    QuestionBankPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Core Tutor Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // logout later
            },
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
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Courses"),
          BottomNavigationBarItem(icon: Icon(Icons.video_library), label: "Videos"),
          BottomNavigationBarItem(icon: Icon(Icons.picture_as_pdf), label: "Materials"),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: "Questions"),
        ],
      ),
    );
  }
}

class CoreHomePage extends StatelessWidget {
  const CoreHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(20),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: const [
        DashboardCard(title: "Total Courses", value: "0", icon: Icons.book),
        DashboardCard(title: "Videos", value: "0", icon: Icons.video_library),
        DashboardCard(title: "Materials", value: "0", icon: Icons.picture_as_pdf),
        DashboardCard(title: "Questions", value: "0", icon: Icons.quiz),
      ],
    );
  }
}

class CoursePage extends StatelessWidget {
  const CoursePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: const Center(
        child: Text("Course List\n(Create Syllabus / Manage Courses)"),
      ),
    );
  }
}

class VideoPage extends StatelessWidget {
  const VideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.upload),
      ),
      body: const Center(
        child: Text("Upload and Manage Videos"),
      ),
    );
  }
}

class MaterialPage extends StatelessWidget {
  const MaterialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.upload_file),
      ),
      body: const Center(
        child: Text("Upload PDFs / Study Materials"),
      ),
    );
  }
}

class QuestionBankPage extends StatelessWidget {
  const QuestionBankPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: const Center(
        child: Text("Create Question Bank"),
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