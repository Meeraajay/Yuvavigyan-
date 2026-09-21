import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EvaluationFormPage extends StatefulWidget {
  final String studentId;

  const EvaluationFormPage({
    super.key,
    required this.studentId,
  });

  @override
  State<EvaluationFormPage> createState() =>
      _EvaluationFormPageState();
}

class _EvaluationFormPageState
    extends State<EvaluationFormPage> {
  int selectedScore = 0;
  double understandingRating = 3;

  final TextEditingController
      remarksController =
      TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

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

      if (!mounted) return;

      setState(() {
        studentName =
            data['name']?.toString() ??
                'Student';

        batchId =
            data['batchId']?.toString() ??
                '';

        batchName =
            data['batchName']?.toString() ??
                '';

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
            "Could not load student: $e",
          ),
        ),
      );
    }
  }

  Future<void> _saveEvaluation() async {
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

      await FirebaseFirestore.instance
          .collection('evaluations')
          .add({
        'studentId':
            widget.studentId,
        'studentName':
            studentName,
        'batchId': batchId,
        'batchName': batchName,
        'tutorId': tutor.uid,
        'understandingRating':
            understandingRating,
        'assessmentScore':
            selectedScore,
        'assessmentTotal': 10,
        'remarks':
            remarksController.text
                .trim(),
        'createdAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Evaluation Saved Successfully",
          ),
          backgroundColor:
              Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Could not save evaluation: $e",
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
            const Text("Student Evaluation"),
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
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.zero,
                    leading:
                        CircleAvatar(
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
                      ),
                    ),
                    title: Text(
                      studentName,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      batchName
                              .isEmpty
                          ? "Batch not assigned"
                          : "Batch: $batchName",
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                _SectionCard(
                  title:
                      "Understanding Level",
                  child: Column(
                    children: [
                      Slider(
                        value:
                            understandingRating,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label:
                            understandingRating
                                .toInt()
                                .toString(),
                        onChanged: (value) {
                          setState(() {
                            understandingRating =
                                value;
                          });
                        },
                      ),
                      Text(
                        "${understandingRating.toInt()} / 5",
                        style:
                            const TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                _SectionCard(
                  title:
                      "Assessment Score",
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children:
                        List.generate(
                      11,
                      (index) =>
                          ChoiceChip(
                        label: Text(
                          index
                              .toString(),
                        ),
                        selected:
                            selectedScore ==
                                index,
                        onSelected: (_) {
                          setState(() {
                            selectedScore =
                                index;
                          });
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                _SectionCard(
                  title:
                      "Tutor Remarks",
                  child: TextField(
                    controller:
                        remarksController,
                    maxLines: 5,
                    decoration:
                        InputDecoration(
                      hintText:
                          "Enter evaluation remarks...",
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
                ),

                const SizedBox(
                  height: 24,
                ),

                SizedBox(
                  height: 52,
                  child:
                      ElevatedButton.icon(
                    onPressed: isSaving
                        ? null
                        : _saveEvaluation,
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
                          : "Save Evaluation",
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

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              const Color(
            0xFFEEF0F5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
                const TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }
}
