import 'package:flutter/material.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  bool isPresent = true;

  DateTime selectedDate = DateTime.now();

  final remarksController = TextEditingController();

  @override
  void dispose() {
    remarksController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) return;

    setState(() {
      selectedDate = pickedDate;
    });
  }

  void _saveAttendance() {
    final date =
        "${selectedDate.day.toString().padLeft(2, '0')}/"
        "${selectedDate.month.toString().padLeft(2, '0')}/"
        "${selectedDate.year}";

    final status = isPresent ? "Present" : "Absent";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Attendance saved for Lakshmi Amma\n"
          "$date • $status",
        ),
        backgroundColor: isPresent ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );

    remarksController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        "${selectedDate.day.toString().padLeft(2, '0')}/"
        "${selectedDate.month.toString().padLeft(2, '0')}/"
        "${selectedDate.year}";

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
                      backgroundColor: Color(0xFFEDE7F6),
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.deepPurple,
                      ),
                    ),

                    SizedBox(width: 15),

                    Expanded(
                      child: Column(
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

                          Text(
                            "Batch : YUVAVIJNAN 2026",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),

                          Text(
                            "Session 4 • Digital Payments",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Attendance Date
            const Text(
              "Attendance Date",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              elevation: 1,
              child: ListTile(
                leading: const Icon(
                  Icons.calendar_today,
                  color: Colors.deepPurple,
                ),
                title: Text(
                  formattedDate,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  "Select attendance date",
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                ),
                onTap: _selectDate,
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
                // Present
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isPresent = true;
                      });
                    },
                    child: Card(
                      elevation: isPresent ? 4 : 1,
                      color: isPresent
                          ? Colors.green.shade100
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isPresent
                              ? Colors.green
                              : Colors.grey.shade300,
                          width: isPresent ? 2 : 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 42,
                              color: isPresent
                                  ? Colors.green
                                  : Colors.grey,
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              "Present",
                              style: TextStyle(
                                fontSize: 16,
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

                // Absent
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isPresent = false;
                      });
                    },
                    child: Card(
                      elevation: !isPresent ? 4 : 1,
                      color: !isPresent
                          ? Colors.red.shade100
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: !isPresent
                              ? Colors.red
                              : Colors.grey.shade300,
                          width: !isPresent ? 2 : 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.cancel,
                              size: 42,
                              color: !isPresent
                                  ? Colors.red
                                  : Colors.grey,
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              "Absent",
                              style: TextStyle(
                                fontSize: 16,
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

            const SizedBox(height: 30),

            // Remarks
            const Text(
              "Remarks",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextFormField(
              controller: remarksController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Enter remarks (optional)",
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(
                    bottom: 60,
                  ),
                  child: Icon(Icons.notes),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Selected Status Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isPresent
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isPresent
                      ? Colors.green.shade200
                      : Colors.red.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isPresent
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: isPresent
                        ? Colors.green
                        : Colors.red,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      "Selected Status: ${isPresent ? "Present" : "Absent"}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isPresent
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _saveAttendance,
                icon: const Icon(Icons.save),
                label: const Text(
                  "Save Attendance",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}