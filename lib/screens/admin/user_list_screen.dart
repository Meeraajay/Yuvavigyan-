import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserListScreen extends StatelessWidget {
  final String role;

  const UserListScreen({
    super.key,
    required this.role,
  });

  String getRoleTitle() {
    if (role == "student") {
      return "Students";
    }

    if (role == "tutor") {
      return "Tutors";
    }

    if (role == "core_tutor") {
      return "Core Tutors";
    }

    return "Users";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          getRoleTitle(),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where(
              'role',
              isEqualTo: role,
            )
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFFEFF6FF),
                    child: Icon(
                      Icons.people_outline_rounded,
                      size: 42,
                      color: Color(0xFF2563EB),
                    ),
                  ),

                  SizedBox(height: 15),

                  Text(
                    "No users found",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: snapshot.data!.docs.length,

            itemBuilder: (context, index) {
              final user = snapshot.data!.docs[index];

              final userData =
                  user.data() as Map<String, dynamic>;

              final String userId = user.id;

              final String name =
                  userData['name'] ?? 'No Name';

              final String email =
                  userData['email'] ?? '';

              final bool active =
                  userData['isActive'] ?? true;

              return Container(
                margin: const EdgeInsets.only(
                  bottom: 14,
                ),
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Color(0xFF2563EB),
                            size: 27,
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
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937),
                                ),
                              ),

                              const SizedBox(height: 5),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.email_outlined,
                                    size: 15,
                                    color: Colors.grey,
                                  ),

                                  const SizedBox(width: 5),

                                  Expanded(
                                    child: Text(
                                      email,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          tooltip: "Edit User",
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Color(0xFF2563EB),
                          ),
                          onPressed: () {
                            showEditDialog(
                              context,
                              userId,
                              name,
                            );
                          },
                        ),

                        IconButton(
                          tooltip: "Delete User",
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .delete();
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    const Divider(
                      height: 1,
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 6,
                          ),

                          decoration: BoxDecoration(
                            color: active
                                ? const Color(0xFFECFDF5)
                                : const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 8,
                                color: active
                                    ? Colors.green
                                    : Colors.red,
                              ),

                              const SizedBox(width: 6),

                              Text(
                                active
                                    ? "Active"
                                    : "Inactive",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: active
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        const Text(
                          "Account Status",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(width: 5),

                        Switch(
                          value: active,
                          activeColor: const Color(0xFF2563EB),

                          onChanged: (value) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .update({
                              'isActive': value,
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void showEditDialog(
    BuildContext context,
    String userId,
    String oldName,
  ) {
    final TextEditingController controller =
        TextEditingController(
      text: oldName,
    );

    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),

          title: const Row(
            children: [
              Icon(
                Icons.edit_rounded,
                color: Color(0xFF2563EB),
              ),

              SizedBox(width: 10),

              Text("Edit User"),
            ],
          ),

          content: TextField(
            controller: controller,

            decoration: InputDecoration(
              labelText: "Name",

              prefixIcon: const Icon(
                Icons.person_outline,
              ),

              filled: true,

              fillColor: const Color(0xFFF8FAFC),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),

              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .update({
                  'name': controller.text.trim(),
                });

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },

              child: const Text(
                "Save Changes",
              ),
            ),
          ],
        );
      },
    );
  }
}