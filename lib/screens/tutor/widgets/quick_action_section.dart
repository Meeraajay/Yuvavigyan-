import 'package:flutter/material.dart';

class QuickActionSection extends StatelessWidget {
  final void Function(int) onNavigate;

  const QuickActionSection({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickActionData(
        title: "My Students",
        subtitle: "Assigned learners",
        icon: Icons.people_alt_rounded,
        colors: const [
          Color(0xFF4859B9),
          Color(0xFF7A89D7),
        ],
        onTap: () => onNavigate(1),
      ),
      _QuickActionData(
        title: "Learning Materials",
        subtitle: "Videos & notes",
        icon: Icons.folder_rounded,
        colors: const [
          Color(0xFFFF7A00),
          Color(0xFFFFB13B),
        ],
        onTap: () => onNavigate(2),
      ),
      _QuickActionData(
        title: "Evaluation",
        subtitle: "Student evaluations",
        icon: Icons.grading_rounded,
        colors: const [
          Color(0xFF009688),
          Color(0xFF45B5A8),
        ],
        onTap: () => onNavigate(3),
      ),
      _QuickActionData(
        title: "Feedback",
        subtitle: "Student feedback",
        icon: Icons.feedback_rounded,
        colors: const [
          Color(0xFF159BD7),
          Color(0xFF51C0EE),
        ],
        onTap: () => onNavigate(4),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick access",
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: Color(0xFF222222),
          ),
        ),

        const SizedBox(height: 18),

        LayoutBuilder(
          builder: (context, constraints) {
            final columns =
                constraints.maxWidth < 650 ? 1 : 2;

            const spacing = 14.0;

            final cardWidth =
                (constraints.maxWidth -
                        spacing * (columns - 1)) /
                    columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: actions
                  .map(
                    (action) => SizedBox(
                      width: cardWidth,
                      height: 160,
                      child: _QuickActionCard(
                        data: action,
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _QuickActionData {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  const _QuickActionData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.onTap,
  });
}

class _QuickActionCard extends StatelessWidget {
  final _QuickActionData data;

  const _QuickActionCard({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: data.colors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: data.colors.first.withOpacity(0.20),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    data.icon,
                    size: 30,
                    color: Colors.white,
                  ),
                ),

                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      data.subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.88),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
