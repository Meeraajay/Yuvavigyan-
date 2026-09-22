import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'role_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final FocusNode passwordFocusNode = FocusNode();

  bool isLoading = false;
  bool rememberMe = true;
  bool obscurePassword = true;

  Future<void> loginUser() async {
    if (isLoading) return;

    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter both email and password.",
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // ========================================================
      // LOGIN
      // ========================================================

      final userCredential =
          await FirebaseAuth.instance
              .signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // ========================================================
      // GET USER ROLE
      // ========================================================

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists ||
          userDoc.data() == null) {
        await FirebaseAuth.instance.signOut();

        throw Exception(
          "User data not found.",
        );
      }

      final role =
          userDoc.data()!['role']
                  ?.toString()
                  .trim() ??
              '';

      const validRoles = {
        'admin',
        'tutor',
        'core_tutor',
        'student',
      };

      if (!validRoles.contains(role)) {
        await FirebaseAuth.instance.signOut();

        throw Exception(
          "Invalid user role.",
        );
      }

      // ========================================================
      // FIREBASE LOGIN PERSISTENCE
      // ========================================================
      //
      // STUDENT + REMEMBER ME
      //    LOCAL
      //    survives browser close + reopen
      //
      // ALL OTHER USERS
      //    SESSION
      //    survives REFRESH
      //    but ends when browser session is closed
      // ========================================================

      if (kIsWeb) {
        if (role == 'student' && rememberMe) {
          await FirebaseAuth.instance.setPersistence(
            Persistence.LOCAL,
          );
        } else {
          await FirebaseAuth.instance.setPersistence(
            Persistence.SESSION,
          );
        }
      }

      // ========================================================
      // SAVE REMEMBER ME
      // ONLY STUDENTS ARE ALLOWED
      // ========================================================

      final preferences =
          await SharedPreferences.getInstance();

      final shouldRemember =
          role == 'student' && rememberMe;

      await preferences.setBool(
        'remember_me',
        shouldRemember,
      );

      if (shouldRemember) {
        await preferences.setString(
          'remembered_student_uid',
          uid,
        );
      } else {
        await preferences.remove(
          'remembered_student_uid',
        );
      }

      if (!mounted) return;

      // ========================================================
      // OPEN DASHBOARD
      // ========================================================

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => RoleRouter(
            initialRole: role,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Login failed.";

      if (e.code == 'invalid-credential' ||
          e.code == 'wrong-password' ||
          e.code == 'user-not-found') {
        message =
            "Incorrect email or password.";
      } else if (e.code == 'invalid-email') {
        message =
            "Please enter a valid email address.";
      } else if (e.code ==
          'too-many-requests') {
        message =
            "Too many login attempts. Please try again later.";
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Login Failed: $e",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    passwordFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F8FC),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(24),

            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 460,
              ),

              child: Card(
                elevation: 3,

                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    28,
                  ),

                  child: AutofillGroup(
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,

                      crossAxisAlignment:
                          CrossAxisAlignment
                              .stretch,

                      children: [
                        const Icon(
                          Icons
                              .account_circle_rounded,
                          size: 72,
                          color:
                              Color(0xFF3F51B5),
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        const Text(
                          "Yuvavigyan Login",
                          textAlign:
                              TextAlign.center,

                          style: TextStyle(
                            fontSize: 26,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        const Text(
                          "Enter your email and password",
                          textAlign:
                              TextAlign.center,

                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(
                          height: 28,
                        ),

                        // =================================================
                        // EMAIL
                        // =================================================

                        TextField(
                          controller:
                              emailController,

                          enabled: !isLoading,

                          keyboardType:
                              TextInputType
                                  .emailAddress,

                          textInputAction:
                              TextInputAction
                                  .next,

                          autofillHints:
                              const [
                            AutofillHints.email,
                            AutofillHints
                                .username,
                          ],

                          decoration:
                              const InputDecoration(
                            labelText: "Email",

                            prefixIcon:
                                Icon(
                              Icons
                                  .email_outlined,
                            ),

                            border:
                                OutlineInputBorder(),
                          ),

                          onSubmitted: (_) {
                            passwordFocusNode
                                .requestFocus();
                          },
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        // =================================================
                        // PASSWORD
                        // =================================================

                        TextField(
                          controller:
                              passwordController,

                          focusNode:
                              passwordFocusNode,

                          enabled: !isLoading,

                          obscureText:
                              obscurePassword,

                          textInputAction:
                              TextInputAction
                                  .done,

                          autofillHints:
                              const [
                            AutofillHints.password,
                          ],

                          decoration:
                              InputDecoration(
                            labelText:
                                "Password",

                            prefixIcon:
                                const Icon(
                              Icons.lock_outline,
                            ),

                            border:
                                const OutlineInputBorder(),

                            suffixIcon:
                                IconButton(
                              tooltip:
                                  obscurePassword
                                      ? "Show password"
                                      : "Hide password",

                              onPressed: () {
                                setState(() {
                                  obscurePassword =
                                      !obscurePassword;
                                });
                              },

                              icon: Icon(
                                obscurePassword
                                    ? Icons
                                        .visibility_outlined
                                    : Icons
                                        .visibility_off_outlined,
                              ),
                            ),
                          ),

                          // Laptop:
                          // ENTER = LOGIN
                          onSubmitted: (_) {
                            loginUser();
                          },
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        // =================================================
                        // REMEMBER ME
                        // =================================================

                        CheckboxListTile(
                          contentPadding:
                              EdgeInsets.zero,

                          controlAffinity:
                              ListTileControlAffinity
                                  .leading,

                          value: rememberMe,

                          title: const Text(
                            "Remember me",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),

                          subtitle: const Text(
                            "Keep me signed in on this device "
                            "(Students only)",
                          ),

                          onChanged: isLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    rememberMe =
                                        value ??
                                            true;
                                  });
                                },
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        // =================================================
                        // LOGIN BUTTON
                        // =================================================

                        SizedBox(
                          height: 52,

                          child:
                              ElevatedButton.icon(
                            onPressed:
                                isLoading
                                    ? null
                                    : loginUser,

                            icon: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height:
                                        20,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2,
                                    ),
                                  )
                                : const Icon(
                                    Icons
                                        .login_rounded,
                                  ),

                            label: Text(
                              isLoading
                                  ? "Logging in..."
                                  : "Login",

                              style:
                                  const TextStyle(
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}