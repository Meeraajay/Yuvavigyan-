import 'package:flutter/material.dart';
import 'add_user_screen.dart';
import 'user_list_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddUserScreen(),
                  ),
                );
              },
              child: const Text("Add User"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UserListScreen(role: "student"),
                  ),
                );
              },
              child: const Text("View Students"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UserListScreen(role: "tutor"),
                  ),
                );
              },
              child: const Text("View Tutors"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UserListScreen(role: "core_tutor"),
                  ),
                );
              },
              child: const Text("View Core Tutors"),
            ),
          ],
        ),
      ),
    );
  }
}