import 'package:flutter/material.dart';

class StudentCard extends StatelessWidget {
  final String name;
  final String email;
  final String batchName;
  final bool applicationCompleted;
  final VoidCallback onViewDetails;

  const StudentCard({
    super.key,
    required this.name,
    required this.email,
    required this.batchName,
    required this.applicationCompleted,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final initial =
        name.trim().isEmpty
            ? "S"
            : name.trim()[0].toUpperCase();

    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFEEF0F5),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.04,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor:
                    const Color(
                  0xFFE8EAF6,
                ),
                child: Text(
                  initial,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF3F51B5,
                    ),
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style:
                          const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (email.isNotEmpty)
                      Text(
                        email,
                        style:
                            const TextStyle(
                          color:
                              Colors.grey,
                        ),
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons
                              .school_outlined,
                          size: 17,
                          color:
                              Color(
                            0xFF3F51B5,
                          ),
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Expanded(
                          child: Text(
                            batchName,
                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xFF555555,
                              ),
                              fontWeight:
                                  FontWeight
                                      .w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: applicationCompleted
                      ? const Color(
                          0xFFE0F3F1,
                        )
                      : const Color(
                          0xFFFFF0D7,
                        ),
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child: Text(
                  applicationCompleted
                      ? "Admission Done"
                      : "Form Pending",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        applicationCompleted
                            ? const Color(
                                0xFF00897B,
                              )
                            : const Color(
                                0xFFEF6C00,
                              ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Align(
            alignment:
                Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: onViewDetails,
              icon: const Icon(
                Icons
                    .visibility_outlined,
              ),
              label:
                  const Text(
                "View Details",
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFF3F51B5,
                ),
                foregroundColor:
                    Colors.white,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
