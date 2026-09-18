import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/login_screen.dart';
import 'add_user_screen.dart';
import 'user_list_screen.dart';
import 'allocate_students_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  static const Color primaryColor = Color(0xFF1E3A8A);
  static const Color backgroundColor = Color(0xFFF5F7FB);

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    }
  }

  void openScreen(
    BuildContext context,
    Widget screen,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            tooltip: "Logout",
            onPressed: () => logout(context),
            icon: const Icon(
              Icons.logout_rounded,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            int columns = 1;

            if (constraints.maxWidth >= 900) {
              columns = 3;
            } else if (constraints.maxWidth >= 600) {
              columns = 2;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1E3A8A),
                          Color(0xFF2563EB),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius:
                          BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x18000000),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),

                    child: const Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome, Admin 👋",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 8),

                        Text(
                          "Manage users and student allocations from your dashboard.",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Management",
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Choose an option to continue",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 20),

                  GridView.count(
                    crossAxisCount: columns,
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio:
                        columns == 1 ? 2.8 : 1.7,

                    children: [
                      AdminCard(
                        icon:
                            Icons.person_add_alt_1_rounded,
                        title: "Add User",
                        subtitle:
                            "Create a new user account",
                        color:
                            const Color(0xFF2563EB),
                        onTap: () {
                          openScreen(
                            context,
                            const AddUserScreen(),
                          );
                        },
                      ),

                      AdminCard(
                        icon: Icons.shuffle_rounded,
                        title: "Allocate Students",
                        subtitle:
                            "Assign students to tutors",
                        color:
                            const Color(0xFF7C3AED),
                        onTap: () {
                          openScreen(
                            context,
                            const AllocateStudentsScreen(),
                          );
                        },
                      ),

                      AdminCard(
                        icon: Icons.school_rounded,
                        title: "Students",
                        subtitle:
                            "View and manage students",
                        color:
                            const Color(0xFF0891B2),
                        onTap: () {
                          openScreen(
                            context,
                            const UserListScreen(
                              role: "student",
                            ),
                          );
                        },
                      ),

                      AdminCard(
                        icon: Icons.person_rounded,
                        title: "Tutors",
                        subtitle:
                            "View and manage tutors",
                        color:
                            const Color(0xFF059669),
                        onTap: () {
                          openScreen(
                            context,
                            const UserListScreen(
                              role: "tutor",
                            ),
                          );
                        },
                      ),

                      AdminCard(
                        icon:
                            Icons.supervisor_account_rounded,
                        title: "Core Tutors",
                        subtitle:
                            "View core tutor accounts",
                        color:
                            const Color(0xFFD97706),
                        onTap: () {
                          openScreen(
                            context,
                            const UserListScreen(
                              role: "core_tutor",
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class AdminCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const AdminCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(18),

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),

        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 29,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 17,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}