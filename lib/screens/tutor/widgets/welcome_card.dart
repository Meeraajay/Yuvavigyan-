import 'package:flutter/material.dart';

class WelcomeCard extends StatelessWidget {
  final String tutorName;
  final String tutorEmail;

  const WelcomeCard({
    super.key,
    required this.tutorName,
    required this.tutorEmail,
  });

  String _greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return "Good morning,";
    if (hour < 17) return "Good afternoon,";
    return "Good evening,";
  }

  String _formattedDate() {
    const weekdays = [
      "Mon",
      "Tue",
      "Wed",
      "Thu",
      "Fri",
      "Sat",
      "Sun",
    ];

    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    final now = DateTime.now();

    return "${weekdays[now.weekday - 1]}, "
        "${now.day} ${months[now.month - 1]}";
  }

  String _initial() {
    final name = tutorName.trim();
    if (name.isEmpty) return "T";
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = width < 600 ? 16.0 : 24.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        width < 600 ? 22 : 28,
        horizontalPadding,
        26,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1F2D86),
            Color(0xFF6174CE),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: width < 600 ? 68 : 82,
                height: width < 600 ? 68 : 82,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.45),
                    width: 4,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initial(),
                  style: TextStyle(
                    color: const Color(0xFF3448A5),
                    fontSize: width < 600 ? 28 : 38,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.82),
                        fontSize: width < 600 ? 14 : 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tutorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width < 600 ? 24 : 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (tutorEmail.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        tutorEmail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.78),
                          fontSize: width < 600 ? 12 : 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Badge(
                icon: Icons.verified_rounded,
                text: "Tutor",
              ),
              _Badge(
                icon: Icons.calendar_month_rounded,
                text: _formattedDate(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Badge({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 17,
            color: Colors.white,
          ),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
