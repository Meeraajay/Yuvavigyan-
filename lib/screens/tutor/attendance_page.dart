import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AttendancePage extends StatefulWidget {
  final String studentId;

  const AttendancePage({
    super.key,
    required this.studentId,
  });

  @override
  State<AttendancePage> createState() =>
      _AttendancePageState();
}

class _AttendancePageState
    extends State<AttendancePage> {
  bool isLoading = true;
  bool isSaving = false;
  bool isPresent = true;

  DateTime selectedDate = DateTime.now();

  final remarksController =
      TextEditingController();

  String studentName = "Student";
  String batchId = "";
  String batchName = "";

  @override
  void initState() {
    super.initState();
    _loadStudent();
  }

  @override
  void dispose() {
    remarksController.dispose();
    super.dispose();
  }

  String _dateKey(
    DateTime date,
  ) {
    return "${date.year}"
        "${date.month.toString().padLeft(2, '0')}"
        "${date.day.toString().padLeft(2, '0')}";
  }

  String _formattedDate(
    DateTime date,
  ) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  Future<void> _loadStudent() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.studentId)
              .get();

      if (!doc.exists ||
          doc.data() == null) {
        throw Exception(
          "Student record was not found.",
        );
      }

      final data = doc.data()!;

      studentName =
          data['name']?.toString() ??
              'Student';

      batchId =
          data['batchId']?.toString() ??
              '';

      batchName =
          data['batchName']?.toString() ??
              '';

      await _loadAttendanceForDate();

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Could not load attendance page: $e",
          ),
        ),
      );
    }
  }

  Future<void>
      _loadAttendanceForDate() async {
    final docId =
        "${widget.studentId}_${_dateKey(selectedDate)}";

    final doc =
        await FirebaseFirestore.instance
            .collection('attendance')
            .doc(docId)
            .get();

    final data = doc.data();

    if (data == null) {
      isPresent = true;
      remarksController.clear();
      return;
    }

    isPresent =
        data['status']?.toString() !=
            'Absent';

    remarksController.text =
        data['remarks']?.toString() ??
            '';
  }

  Future<void> _selectDate() async {
    final pickedDate =
        await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) return;

    setState(() {
      selectedDate = pickedDate;
      isLoading = true;
    });

    await _loadAttendanceForDate();

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _saveAttendance() async {
    setState(() {
      isSaving = true;
    });

    try {
      final tutor =
          FirebaseAuth.instance.currentUser;

      if (tutor == null) {
        throw Exception(
          "No tutor is currently logged in.",
        );
      }

      final docId =
          "${widget.studentId}_${_dateKey(selectedDate)}";

      final attendanceRef =
          FirebaseFirestore.instance
              .collection('attendance')
              .doc(docId);

      final previous =
          await attendanceRef.get();

      final data = <String, dynamic>{
        'studentId':
            widget.studentId,
        'studentName':
            studentName,
        'batchId': batchId,
        'batchName': batchName,
        'tutorId': tutor.uid,
        'date': Timestamp.fromDate(
          DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
          ),
        ),
        'dateKey':
            _dateKey(selectedDate),
        'status': isPresent
            ? 'Present'
            : 'Absent',
        'remarks':
            remarksController.text
                .trim(),
        'updatedAt':
            FieldValue.serverTimestamp(),
      };

      if (!previous.exists) {
        data['createdAt'] =
            FieldValue.serverTimestamp();
      }

      await attendanceRef.set(
        data,
        SetOptions(
          merge: true,
        ),
      );

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Attendance saved for $studentName\n"
            "${_formattedDate(selectedDate)} • "
            "${isPresent ? 'Present' : 'Absent'}",
          ),
          backgroundColor: isPresent
              ? Colors.green
              : Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Could not save attendance: $e",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F8FC),
      appBar: AppBar(
        title:
            const Text("Mark Attendance"),
        backgroundColor:
            Colors.white,
        foregroundColor:
            const Color(
          0xFF222222,
        ),
        elevation: 0.5,
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : ListView(
              padding:
                  const EdgeInsets.all(
                18,
              ),
              children: [
                const Text(
                  "Student Attendance",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                Container(
                  padding:
                      const EdgeInsets.all(
                    18,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius
                            .circular(
                      18,
                    ),
                    border: Border.all(
                      color:
                          const Color(
                        0xFFEEF0F5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor:
                            const Color(
                          0xFFE8EAF6,
                        ),
                        child: Text(
                          studentName
                                  .isEmpty
                              ? "S"
                              : studentName[
                                      0]
                                  .toUpperCase(),
                          style:
                              const TextStyle(
                            color:
                                Color(
                              0xFF3F51B5,
                            ),
                            fontSize: 22,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 14,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              studentName,
                              style:
                                  const TextStyle(
                                fontSize:
                                    20,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              batchName
                                      .isEmpty
                                  ? "Batch not assigned"
                                  : "Batch: $batchName",
                              style:
                                  const TextStyle(
                                color:
                                    Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                const Text(
                  "Attendance Date",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Card(
                  elevation: 0,
                  shape:
                      RoundedRectangleBorder(
                    side:
                        const BorderSide(
                      color:
                          Color(
                        0xFFE5E7EB,
                      ),
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      14,
                    ),
                  ),
                  child: ListTile(
                    leading:
                        const Icon(
                      Icons
                          .calendar_today_rounded,
                      color:
                          Color(
                        0xFF3F51B5,
                      ),
                    ),
                    title: Text(
                      _formattedDate(
                        selectedDate,
                      ),
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    subtitle:
                        const Text(
                      "Tap to select attendance date",
                    ),
                    trailing:
                        const Icon(
                      Icons
                          .chevron_right_rounded,
                    ),
                    onTap: _selectDate,
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                const Text(
                  "Attendance Status",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                Row(
                  children: [
                    Expanded(
                      child:
                          _StatusCard(
                        selected:
                            isPresent,
                        title:
                            "Present",
                        icon: Icons
                            .check_circle_rounded,
                        color:
                            Colors.green,
                        onTap: () {
                          setState(() {
                            isPresent =
                                true;
                          });
                        },
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child:
                          _StatusCard(
                        selected:
                            !isPresent,
                        title:
                            "Absent",
                        icon: Icons
                            .cancel_rounded,
                        color:
                            Colors.red,
                        onTap: () {
                          setState(() {
                            isPresent =
                                false;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 24,
                ),

                TextField(
                  controller:
                      remarksController,
                  maxLines: 4,
                  decoration:
                      InputDecoration(
                    labelText:
                        "Remarks (optional)",
                    alignLabelWithHint:
                        true,
                    filled: true,
                    fillColor:
                        Colors.white,
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                SizedBox(
                  height: 52,
                  child:
                      ElevatedButton.icon(
                    onPressed: isSaving
                        ? null
                        : _saveAttendance,
                    icon: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(
                              strokeWidth:
                                  2,
                            ),
                          )
                        : const Icon(
                            Icons.save,
                          ),
                    label: Text(
                      isSaving
                          ? "Saving..."
                          : "Save Attendance",
                    ),
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          const Color(
                        0xFF3F51B5,
                      ),
                      foregroundColor:
                          Colors.white,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final bool selected;
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatusCard({
    required this.selected,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(16),
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 20,
        ),
        decoration: BoxDecoration(
          color: selected
              ? color.withOpacity(0.10)
              : Colors.white,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? color
                : const Color(
                    0xFFE5E7EB,
                  ),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 38,
              color: selected
                  ? color
                  : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                color: selected
                    ? color
                    : const Color(
                        0xFF555555,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
