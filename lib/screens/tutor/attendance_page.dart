import 'package:flutter/material.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  bool isPresent = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mark Attendance"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Student Attendance",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Student Information
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      child: Icon(
                        Icons.person,
                        size: 30,
                      ),
                    ),

                    SizedBox(width: 15),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Lakshmi Amma",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text("Batch : YUVAVIJNAN 2026"),
                        Text("Session 4 • Digital Payments"),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Date
            const Text(
              "Attendance Date",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  "${DateTime.now().day}/"
                  "${DateTime.now().month}/"
                  "${DateTime.now().year}",
                ),
                subtitle: const Text("Today's Session"),
              ),
            ),

            const SizedBox(height: 25),

            // Attendance Status
            const Text(
              "Attendance Status",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isPresent = true;
                      });
                    },
                    child: Card(
                      color: isPresent
                          ? Colors.green.shade100
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 40,
                              color: isPresent
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Present",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isPresent = false;
                      });
                    },
                    child: Card(
                      color: !isPresent
                          ? Colors.red.shade100
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.cancel,
                              size: 40,
                              color: !isPresent
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Absent",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 35),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isPresent
                            ? "Attendance marked as Present ✅"
                            : "Attendance marked as Absent",
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text(
                  "Save Attendance",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}