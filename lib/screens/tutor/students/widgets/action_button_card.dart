import 'package:flutter/material.dart';

class ActionButtonCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const ActionButtonCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 10,
      ),
      child: Material(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(18),
          child: Container(
            padding:
                const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 18,
            ),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
              border: Border.all(
                color: const Color(
                  0xFFEEF0F5,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration:
                      BoxDecoration(
                    color:
                        color.withOpacity(
                      0.12,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      14,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                  ),
                ),

                const SizedBox(
                  width: 16,
                ),

                Expanded(
                  child: Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight
                              .w600,
                    ),
                  ),
                ),

                const Icon(
                  Icons
                      .arrow_forward_ios_rounded,
                  size: 17,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
