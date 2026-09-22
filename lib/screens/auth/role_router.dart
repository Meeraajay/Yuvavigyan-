import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../admin/admin_dashboard.dart';
import '../core_tutor/core_tutor_dashboard.dart';
import '../student/student_dashboard.dart';
import '../tutor/tutor_dashboard.dart';

class RoleRouter extends StatefulWidget {
  final String? initialRole;

  const RoleRouter({
    super.key,
    this.initialRole,
  });

  @override
  State<RoleRouter> createState() =>
      _RoleRouterState();
}

class _RoleRouterState extends State<RoleRouter> {
  bool isLoading = true;
  String? role;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    final initialRole =
        widget.initialRole?.trim();

    if (initialRole != null &&
        initialRole.isNotEmpty) {
      role = initialRole;
      isLoading = false;
    } else {
      _loadRole();
    }
  }

  Future<void> _loadRole() async {
    try {
      final user =
          FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception(
          "No logged-in user found.",
        );
      }

      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (!userDoc.exists ||
          userDoc.data() == null) {
        throw Exception(
          "User profile not found.",
        );
      }

      final userRole =
          userDoc.data()!['role']
                  ?.toString()
                  .trim() ??
              '';

      if (!mounted) return;

      setState(() {
        role = userRole;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Widget _dashboardForRole() {
    switch (role) {
      case 'admin':
        return const AdminDashboard();
      case 'tutor':
        return const TutorDashboard();
      case 'core_tutor':
        return const CoreTutorDashboard();
      case 'student':
        return const StudentDashboard();
      default:
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 60,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Invalid user role.",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      AuthService.logout(
                        context,
                      );
                    },
                    icon: const Icon(
                      Icons.logout_rounded,
                    ),
                    label:
                        const Text("Logout"),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding:
                const EdgeInsets.all(24),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Text(
                  "Could not open dashboard.\n\n$errorMessage",
                  textAlign:
                      TextAlign.center,
                ),
                const SizedBox(
                  height: 18,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    AuthService.logout(
                      context,
                    );
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                  ),
                  label:
                      const Text("Logout"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _DashboardWithLogout(
      child: _dashboardForRole(),
    );
  }
}

class _DashboardWithLogout
    extends StatelessWidget {
  final Widget child;

  const _DashboardWithLogout({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: child,
        ),
        Positioned(
          top: 10,
          right: 12,
          child: SafeArea(
            child: Material(
              color: Colors.white,
              elevation: 5,
              borderRadius:
                  BorderRadius.circular(24),
              child: InkWell(
                onTap: () {
                  AuthService.logout(
                    context,
                  );
                },
                borderRadius:
                    BorderRadius.circular(24),
                child: const Padding(
                  padding:
                      EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        size: 20,
                        color: Colors.redAccent,
                      ),
                      SizedBox(width: 7),
                      Text(
                        "Logout",
                        style: TextStyle(
                          color:
                              Colors.redAccent,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
