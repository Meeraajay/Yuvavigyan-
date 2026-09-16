import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class AllocateStudentsScreen extends StatefulWidget {
  const AllocateStudentsScreen({super.key});

  @override
  State<AllocateStudentsScreen> createState() =>
      _AllocateStudentsScreenState();
}

class _AllocateStudentsScreenState extends State<AllocateStudentsScreen> {
  bool isLoading = false;
  bool isAllocating = false;

  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> tutors = [];
  List<Map<String, String>> allocationResult = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() => isLoading = true);

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      final allUsers = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'No Name',
          'email': data['email'] ?? '',
          'role': data['role'] ?? '',
          'isActive': data['isActive'] ?? true,
          'assignedTutorId': data['assignedTutorId'],
        };
      }).toList();

      setState(() {
        students = allUsers
            .where((u) => u['role'] == 'student' && u['isActive'] == true)
            .toList();

        // Filter only Tutors (Core Tutors are excluded)
        tutors = allUsers
            .where((u) => u['role'] == 'tutor' && u['isActive'] == true)
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading users: $e')),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> allocateStudents() async {
    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active students found.')),
      );
      return;
    }

    if (tutors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active tutors found.')),
      );
      return;
    }

    setState(() {
      isAllocating = true;
      allocationResult = [];
    });

    try {
      // Shuffle lists for random assignment
      final shuffledStudents = List<Map<String, dynamic>>.from(students)
        ..shuffle(Random());
      final shuffledTutors = List<Map<String, dynamic>>.from(tutors)
        ..shuffle(Random());

      final batch = FirebaseFirestore.instance.batch();
      final results = <Map<String, String>>[];

      final pairCount = shuffledStudents.length < shuffledTutors.length
          ? shuffledStudents.length
          : shuffledTutors.length;

      // 1. Pair 1 Student -> 1 Tutor
      for (int i = 0; i < pairCount; i++) {
        final student = shuffledStudents[i];
        final tutor = shuffledTutors[i];

        final studentRef = FirebaseFirestore.instance
            .collection('users')
            .doc(student['id']);

        batch.update(studentRef, {
          'assignedTutorId': tutor['id'],
        });

        results.add({
          'studentName': student['name'],
          'tutorName': tutor['name'],
          'status': 'Assigned',
        });
      }

      // 2. Extra Students -> No Tutor (Not Applicable)
      for (int i = pairCount; i < shuffledStudents.length; i++) {
        final student = shuffledStudents[i];

        final studentRef = FirebaseFirestore.instance
            .collection('users')
            .doc(student['id']);

        batch.update(studentRef, {
          'assignedTutorId': null,
        });

        results.add({
          'studentName': student['name'],
          'tutorName': 'No Tutor',
          'status': 'Not Applicable',
        });
      }

      // 3. Extra Tutors -> No Student (Not Applicable)
      for (int i = pairCount; i < shuffledTutors.length; i++) {
        final tutor = shuffledTutors[i];

        results.add({
          'studentName': 'No Student',
          'tutorName': tutor['name'],
          'status': 'Not Applicable',
        });
      }

      await batch.commit();

      setState(() {
        allocationResult = results;
      });

      await fetchUsers();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Allocation complete! ✅')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error allocating: $e')),
      );
    }

    setState(() => isAllocating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Allocate Students'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _statCard('Active Students', students.length, Colors.blue),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statCard('Active Tutors', tutors.length, Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isAllocating ? null : allocateStudents,
                      icon: isAllocating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.shuffle),
                      label: Text(
                        isAllocating ? 'Allocating...' : 'Allocate Randomly',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: allocationResult.isEmpty
                        ? const Center(
                            child: Text(
                              'Click "Allocate Randomly" to pair students with tutors.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: allocationResult.length,
                            itemBuilder: (context, index) {
                              final item = allocationResult[index];
                              final isNA = item['status'] == 'Not Applicable';

                              return Card(
                                color: isNA
                                    ? Colors.orange.shade50
                                    : Colors.green.shade50,
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: Icon(
                                    isNA
                                        ? Icons.warning_amber_rounded
                                        : Icons.check_circle_rounded,
                                    color: isNA ? Colors.orange : Colors.green,
                                  ),
                                  title: Text(
                                    '${item['studentName']}  ➔  ${item['tutorName']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Status: ${item['status']}',
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _statCard(String label, int count, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}