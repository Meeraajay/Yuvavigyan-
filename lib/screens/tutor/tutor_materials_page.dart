import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TutorMaterialsPage extends StatefulWidget {
  final String? initialBatchId;
  final String? initialBatchName;

  const TutorMaterialsPage({
    super.key,
    this.initialBatchId,
    this.initialBatchName,
  });

  @override
  State<TutorMaterialsPage> createState() =>
      _TutorMaterialsPageState();
}

class _TutorMaterialsPageState
    extends State<TutorMaterialsPage> {
  bool isLoading = true;
  String? errorMessage;

  List<Map<String, dynamic>> batches = [];

  @override
  void initState() {
    super.initState();
    _loadAssignedBatches();
  }

  Future<void> _loadAssignedBatches() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception(
          "No tutor is currently logged in.",
        );
      }

      final studentSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where(
                'assignedTutorId',
                isEqualTo: user.uid,
              )
              .get();

      final Map<String, Map<String, dynamic>>
          uniqueBatches = {};

      for (final doc in studentSnapshot.docs) {
        final data = doc.data();

        if (data['role']?.toString() != 'student' ||
            data['isActive'] == false) {
          continue;
        }

        final batchId =
            data['batchId']?.toString().trim() ?? '';

        if (batchId.isEmpty) continue;

        final batchName =
            data['batchName']?.toString().trim() ??
                'Unnamed Batch';

        uniqueBatches.putIfAbsent(
          batchId,
          () => {
            'id': batchId,
            'name': batchName,
            'studentCount': 0,
          },
        );

        uniqueBatches[batchId]!['studentCount'] =
            (uniqueBatches[batchId]!['studentCount']
                    as int) +
                1;
      }

      var result = uniqueBatches.values.toList();

      if (widget.initialBatchId != null &&
          widget.initialBatchId!.trim().isNotEmpty) {
        result = result
            .where(
              (batch) =>
                  batch['id'] ==
                  widget.initialBatchId,
            )
            .toList();
      }

      result.sort(
        (a, b) => a['name']
            .toString()
            .toLowerCase()
            .compareTo(
              b['name']
                  .toString()
                  .toLowerCase(),
            ),
      );

      if (!mounted) return;

      setState(() {
        batches = result;
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

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);

    if (uri == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Invalid material URL.",
          ),
        ),
      );
      return;
    }

    final opened = await launchUrl(uri);

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Could not open the material.",
          ),
        ),
      );
    }
  }

  Future<List<QueryDocumentSnapshot<
      Map<String, dynamic>>>> _loadMaterials(
    String batchId,
  ) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('materials')
            .where(
              'batchId',
              isEqualTo: batchId,
            )
            .get();

    final docs = snapshot.docs.toList();

    docs.sort((a, b) {
      final aValue = a.data()['createdAt'];
      final bValue = b.data()['createdAt'];

      final aDate = aValue is Timestamp
          ? aValue.toDate()
          : DateTime(1970);

      final bDate = bValue is Timestamp
          ? bValue.toDate()
          : DateTime(1970);

      return bDate.compareTo(aDate);
    });

    return docs;
  }

  Widget _materialTile(
    Map<String, dynamic> data,
  ) {
    final type =
        data['type']?.toString() ?? 'note';

    final fileName =
        data['fileName']?.toString() ??
            'Material';

    final url =
        data['url']?.toString() ?? '';

    final isVideo = type == 'video';

    return Card(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isVideo
              ? const Color(0xFFFFE7E9)
              : const Color(0xFFFFF0D7),
          child: Icon(
            isVideo
                ? Icons.play_arrow_rounded
                : Icons.description_rounded,
            color: isVideo
                ? const Color(0xFFE84B59)
                : const Color(0xFFFF9800),
          ),
        ),
        title: Text(
          fileName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          isVideo ? "Video" : "Note / Document",
        ),
        trailing: const Icon(
          Icons.open_in_new_rounded,
        ),
        onTap: url.isEmpty
            ? null
            : () => _openUrl(url),
      ),
    );
  }

  Widget _batchCard(
    Map<String, dynamic> batch,
  ) {
    final batchId =
        batch['id'].toString();

    final batchName =
        batch['name'].toString();

    final studentCount =
        batch['studentCount'] as int? ?? 0;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFEEF0F5),
        ),
      ),
      child: ExpansionTile(
        tilePadding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        childrenPadding:
            const EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color:
                const Color(0xFFFFF0D7),
            borderRadius:
                BorderRadius.circular(
              14,
            ),
          ),
          child: const Icon(
            Icons.folder_rounded,
            color: Color(0xFFFF9800),
          ),
        ),
        title: Text(
          batchName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "$studentCount assigned student"
          "${studentCount == 1 ? '' : 's'}",
        ),
        children: [
          FutureBuilder<
              List<
                  QueryDocumentSnapshot<
                      Map<String, dynamic>>>>(
            future: _loadMaterials(batchId),
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(18),
                  child:
                      CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  child: Text(
                    "Could not load materials: "
                    "${snapshot.error}",
                  ),
                );
              }

              final materials =
                  snapshot.data ?? [];

              if (materials.isEmpty) {
                return const Padding(
                  padding:
                      EdgeInsets.all(18),
                  child: Text(
                    "No videos or notes have been "
                    "uploaded for this batch yet.",
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                );
              }

              final videos = materials
                  .where(
                    (doc) =>
                        doc.data()['type'] ==
                        'video',
                  )
                  .toList();

              final notes = materials
                  .where(
                    (doc) =>
                        doc.data()['type'] ==
                        'note',
                  )
                  .toList();

              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  if (videos.isNotEmpty) ...[
                    const Padding(
                      padding:
                          EdgeInsets.only(
                        bottom: 8,
                      ),
                      child: Text(
                        "Videos",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                    ...videos.map(
                      (doc) => _materialTile(
                        doc.data(),
                      ),
                    ),
                  ],

                  if (notes.isNotEmpty) ...[
                    if (videos.isNotEmpty)
                      const SizedBox(
                        height: 10,
                      ),
                    const Padding(
                      padding:
                          EdgeInsets.only(
                        bottom: 8,
                      ),
                      child: Text(
                        "Notes",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                    ...notes.map(
                      (doc) => _materialTile(
                        doc.data(),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: Text(
          widget.initialBatchName != null
              ? "${widget.initialBatchName} - Materials"
              : "Learning Materials",
        ),
        backgroundColor: Colors.white,
        foregroundColor:
            const Color(0xFF222222),
        elevation: 0.5,
      ),
      body: RefreshIndicator(
        onRefresh: _loadAssignedBatches,
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
                        "Could not load materials.\n\n"
                        "$errorMessage",
                        textAlign:
                            TextAlign.center,
                      ),
                    ],
                  )
                : batches.isEmpty
                    ? ListView(
                        padding:
                            const EdgeInsets.all(
                          24,
                        ),
                        children:
                            const [
                          SizedBox(
                            height: 120,
                          ),
                          Icon(
                            Icons
                                .folder_off_outlined,
                            size: 70,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            "No batch is available "
                            "through your assigned students.",
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
                            "Materials by Batch",
                            style:
                                TextStyle(
                              fontSize: 24,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          const Text(
                            "These videos and notes were uploaded "
                            "by the Core Tutor for the batches of "
                            "your assigned students.",
                            style:
                                TextStyle(
                              color:
                                  Colors.grey,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ...batches.map(
                            _batchCard,
                          ),
                        ],
                      ),
      ),
    );
  }
}
