import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EvaluationHistoryPage
    extends StatefulWidget {
  const EvaluationHistoryPage({
    super.key,
  });

  @override
  State<EvaluationHistoryPage>
      createState() =>
          _EvaluationHistoryPageState();
}

class _EvaluationHistoryPageState
    extends State<EvaluationHistoryPage> {
  bool isLoading = true;
  String? errorMessage;

  List<
          QueryDocumentSnapshot<
              Map<String, dynamic>>>
      evaluations = [];

  @override
  void initState() {
    super.initState();
    _loadEvaluations();
  }

  Future<void>
      _loadEvaluations() async {
    try {
      final tutor =
          FirebaseAuth.instance.currentUser;

      if (tutor == null) {
        throw Exception(
          "No tutor is currently logged in.",
        );
      }

      final snapshot =
          await FirebaseFirestore.instance
              .collection('evaluations')
              .where(
                'tutorId',
                isEqualTo: tutor.uid,
              )
              .get();

      final docs =
          snapshot.docs.toList();

      docs.sort(
        (a, b) {
          final aValue =
              a.data()['createdAt'];
          final bValue =
              b.data()['createdAt'];

          final aDate =
              aValue is Timestamp
                  ? aValue.toDate()
                  : DateTime(1970);

          final bDate =
              bValue is Timestamp
                  ? bValue.toDate()
                  : DateTime(1970);

          return bDate.compareTo(
            aDate,
          );
        },
      );

      if (!mounted) return;

      setState(() {
        evaluations = docs;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  String _formatDate(
    dynamic value,
  ) {
    if (value is! Timestamp) {
      return "Date unavailable";
    }

    final date = value.toDate();

    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F8FC),
      appBar: AppBar(
        title:
            const Text("Evaluation History"),
        backgroundColor:
            Colors.white,
        foregroundColor:
            const Color(0xFF222222),
        elevation: 0.5,
      ),
      body: RefreshIndicator(
        onRefresh: _loadEvaluations,
        child: isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )
            : errorMessage != null
                ? ListView(
                    padding:
                        const EdgeInsets.all(
                      24,
                    ),
                    children: [
                      Text(
                        "Could not load evaluations.\n\n"
                        "$errorMessage",
                        textAlign:
                            TextAlign.center,
                      ),
                    ],
                  )
                : evaluations.isEmpty
                    ? ListView(
                        padding:
                            const EdgeInsets.all(
                          24,
                        ),
                        children:
                            const [
                          SizedBox(
                            height: 140,
                          ),
                          Icon(
                            Icons
                                .grading_outlined,
                            size: 72,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            "No evaluations saved yet.",
                            textAlign:
                                TextAlign.center,
                            style:
                                TextStyle(
                              color:
                                  Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                    : ListView(
                        padding:
                            const EdgeInsets.all(
                          18,
                        ),
                        children: [
                          const Text(
                            "Saved Evaluations",
                            style:
                                TextStyle(
                              fontSize: 26,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Text(
                            "${evaluations.length} evaluation"
                            "${evaluations.length == 1 ? '' : 's'}",
                            style:
                                const TextStyle(
                              color:
                                  Colors.grey,
                            ),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          ...evaluations.map(
                            (doc) {
                              final data =
                                  doc.data();

                              final name =
                                  data['studentName']
                                          ?.toString() ??
                                      'Student';

                              final batch =
                                  data['batchName']
                                          ?.toString() ??
                                      '';

                              final understanding =
                                  (data['understandingRating']
                                              as num?)
                                          ?.toDouble() ??
                                      0;

                              final score =
                                  data['assessmentScore'] ??
                                      0;

                              final total =
                                  data['assessmentTotal'] ??
                                      10;

                              final remarks =
                                  data['remarks']
                                          ?.toString() ??
                                      '';

                              return Container(
                                margin:
                                    const EdgeInsets
                                        .only(
                                  bottom:
                                      14,
                                ),
                                padding:
                                    const EdgeInsets
                                        .all(
                                  18,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color:
                                      Colors.white,
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    18,
                                  ),
                                  border:
                                      Border.all(
                                    color:
                                        const Color(
                                      0xFFEEF0F5,
                                    ),
                                  ),
                                ),
                                child:
                                    Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Row(
                                      children: [
                                        const CircleAvatar(
                                          backgroundColor:
                                              Color(
                                            0xFFE8EAF6,
                                          ),
                                          child:
                                              Icon(
                                            Icons
                                                .person_rounded,
                                            color:
                                                Color(
                                              0xFF3F51B5,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width:
                                              12,
                                        ),
                                        Expanded(
                                          child:
                                              Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              Text(
                                                name,
                                                style:
                                                    const TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  fontSize:
                                                      17,
                                                ),
                                              ),
                                              if (batch.isNotEmpty)
                                                Text(
                                                  batch,
                                                  style:
                                                      const TextStyle(
                                                    color:
                                                        Colors.grey,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          _formatDate(
                                            data['createdAt'],
                                          ),
                                          style:
                                              const TextStyle(
                                            color:
                                                Colors.grey,
                                            fontSize:
                                                12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height:
                                          16,
                                    ),
                                    Wrap(
                                      spacing:
                                          10,
                                      runSpacing:
                                          10,
                                      children: [
                                        _ScoreBadge(
                                          label:
                                              "Understanding",
                                          value:
                                              "${understanding.toStringAsFixed(0)} / 5",
                                          color:
                                              const Color(
                                            0xFF3F51B5,
                                          ),
                                        ),
                                        _ScoreBadge(
                                          label:
                                              "Assessment",
                                          value:
                                              "$score / $total",
                                          color:
                                              const Color(
                                            0xFF009688,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (remarks.isNotEmpty) ...[
                                      const SizedBox(
                                        height:
                                            14,
                                      ),
                                      Container(
                                        width:
                                            double.infinity,
                                        padding:
                                            const EdgeInsets.all(
                                          12,
                                        ),
                                        decoration:
                                            BoxDecoration(
                                          color:
                                              const Color(
                                            0xFFF8FAFC,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child:
                                            Text(
                                          remarks,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ScoreBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(
          0.10,
        ),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style:
                const TextStyle(
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
