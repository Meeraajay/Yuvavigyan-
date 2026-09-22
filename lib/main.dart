import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/role_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const YuvavigyanApp(),
  );
}

class YuvavigyanApp
    extends StatelessWidget {
  const YuvavigyanApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false,

      title: 'Yuvavigyan',

      home: const SessionGate(),

      routes: {
        '/login': (_) =>
            const LoginScreen(),
      },
    );
  }
}

// ============================================================
// SESSION GATE
// ============================================================
//
// IMPORTANT:
//
// If Firebase says a user is already logged in,
// DO NOT sign them out.
//
// This allows:
//
// Dashboard
// → Browser Refresh
// → Dashboard again
//
// Firebase persistence determines whether the login
// survives browser close/reopen.
// ============================================================

class SessionGate
    extends StatefulWidget {
  const SessionGate({
    super.key,
  });

  @override
  State<SessionGate> createState() =>
      _SessionGateState();
}

class _SessionGateState
    extends State<SessionGate> {
  bool isChecking = true;
  bool userLoggedIn = false;

  @override
  void initState() {
    super.initState();

    _checkSession();
  }

  Future<void> _checkSession() async {
    // Give Firebase Auth time to restore
    // the persisted browser session.
    await FirebaseAuth.instance
        .authStateChanges()
        .first;

    final currentUser =
        FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    setState(() {
      userLoggedIn =
          currentUser != null;

      isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ========================================================
    // CHECKING SESSION
    // ========================================================

    if (isChecking) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    // ========================================================
    // USER ALREADY LOGGED IN
    //
    // Happens after dashboard refresh.
    // RoleRouter gets role from Firestore
    // and reopens correct dashboard.
    // ========================================================

    if (userLoggedIn) {
      return const RoleRouter();
    }

    // ========================================================
    // NO ACTIVE SESSION
    // ========================================================

    return const LoginScreen();
  }
}