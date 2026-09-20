import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/cloudinary_service.dart';

// ============================================================
// THEME + SHARED HELPERS
// ============================================================

const Color kBg = Color(0xFFF4F6FB);
const Color kPrimary = Color(0xFF3949AB);

const LinearGradient kHeaderGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF1A237E), Color(0xFF5C6BC0)],
);

/// Gradient app bar used on every inner page.
AppBar gradientAppBar(String title) {
  return AppBar(
    title: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    centerTitle: true,
    elevation: 0,
    foregroundColor: Colors.white,
    backgroundColor: Colors.transparent,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    flexibleSpace: Container(
      decoration: const BoxDecoration(gradient: kHeaderGradient),
    ),
  );
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

/// Shows a delete confirmation dialog. Returns true if the user confirmed.
Future<bool> confirmDelete(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  return result == true;
}

/// Deletes every document in [collection] where [field] == [value].
Future<void> deleteWhere(
  String collection,
  String field,
  String value,
) async {
  final snapshot = await FirebaseFirestore.instance
      .collection(collection)
      .where(field, isEqualTo: value)
      .get();

  for (final doc in snapshot.docs) {
    await doc.reference.delete();
  }
}

DateTime? _createdAt(Map<String, dynamic> data) {
  final value = data['createdAt'];
  return value is Timestamp ? value.toDate() : null;
}

/// Sorts documents by their createdAt field on the client, so no
/// Firestore composite index is needed.
List<QueryDocumentSnapshot<Map<String, dynamic>>> sortByCreated(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, {
  bool descending = false,
}) {
  final now = DateTime.now();
  final sorted =
      List<QueryDocumentSnapshot<Map<String, dynamic>>>.of(docs);

  sorted.sort((a, b) {
    final ta = _createdAt(a.data()) ?? now;
    final tb = _createdAt(b.data()) ?? now;
    return descending ? tb.compareTo(ta) : ta.compareTo(tb);
  });

  return sorted;
}

// ============================================================
// CORE TUTOR DASHBOARD
// ============================================================

class CoreTutorDashboard extends StatefulWidget {
  const CoreTutorDashboard({super.key});

  @override
  State<CoreTutorDashboard> createState() => _CoreTutorDashboardState();
}

class _CoreTutorDashboardState extends State<CoreTutorDashboard> {
  int index = 0;

  static const List<String> _titles = [
    'Home',
    'Courses',
    'Materials',
    'Tests',
    'Reports',
    'Tutor-Student Mapping',
    'Feedback',
  ];

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      CoreHomePage(
        onNavigate: (value) {
          setState(() {
            index = value;
          });
        },
      ),
      const CoursesPage(),
      const MaterialsPage(),
      const TestsPage(),
      const ReportsPage(),
      const MappingPage(),
      const FeedbackPage(),
    ];

    return Scaffold(
      backgroundColor: kBg,
      // The home tab draws its own welcome header.
      appBar: index == 0 ? null : gradientAppBar(_titles[index]),
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 16,
        iconSize: 24,
        selectedItemColor: kPrimary,
        unselectedItemColor: Colors.grey.shade500,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        onTap: (value) {
          setState(() {
            index = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_rounded),
            label: 'Materials',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz_rounded),
            label: 'Tests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment_rounded),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: 'Mapping',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback_rounded),
            label: 'Feedback',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// COMMON WIDGETS
// ============================================================

class FolderCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;

  const FolderCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color.withOpacity(0.70), color],
                    ),
                  ),
                  child: Icon(icon, size: 42, color: Colors.white),
                ),
                const SizedBox(height: 14),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A folder card with a small delete button in the corner.
class DeletableFolder extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const DeletableFolder({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.onDelete,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        FolderCard(
          icon: icon,
          label: label,
          subtitle: subtitle,
          color: color,
          onTap: onTap,
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.white,
            elevation: 3,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onDelete,
              child: const SizedBox(
                width: 36,
                height: 36,
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget buildFolderGrid({
  required List<Widget> cards,
}) {
  return GridView.builder(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisExtent: 200,
      crossAxisSpacing: 18,
      mainAxisSpacing: 18,
    ),
    itemCount: cards.length,
    itemBuilder: (context, index) {
      return cards[index];
    },
  );
}

/// Row-style card used for list pages (courses, files, mappings...).
class ItemCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ItemCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 28, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? hint;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 54,
                color: kPrimary.withOpacity(0.55),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            if (hint != null) ...[
              const SizedBox(height: 6),
              Text(
                hint!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AddNameDialog extends StatefulWidget {
  final String title;
  final String label;
  final String confirmText;
  final void Function(String value) onCreate;

  const AddNameDialog({
    super.key,
    required this.title,
    required this.label,
    required this.onCreate,
    this.confirmText = "Create",
  });

  @override
  State<AddNameDialog> createState() => _AddNameDialogState();
}

class _AddNameDialogState extends State<AddNameDialog> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(widget.title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: widget.label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            final value = controller.text.trim();

            if (value.isEmpty) return;

            widget.onCreate(value);
            Navigator.pop(context);
          },
          child: Text(widget.confirmText),
        ),
      ],
    );
  }
}

/// Loads all batches and shows them as folders. Used by Materials and Tests.
class BatchFolderList extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String subtitle;
  final Widget Function(String batchId, String batchName) pageBuilder;

  const BatchFolderList({
    super.key,
    required this.icon,
    required this.color,
    required this.subtitle,
    required this.pageBuilder,
  });

  @override
  State<BatchFolderList> createState() => _BatchFolderListState();
}

class _BatchFolderListState extends State<BatchFolderList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, String>> batches = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    try {
      final snapshot = await _firestore.collection('batches').get();

      if (!mounted) return;

      setState(() {
        batches = snapshot.docs.map((doc) {
          final data = doc.data();

          return {
            'id': doc.id,
            'name': data['name']?.toString() ?? 'Unnamed Batch',
          };
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showSnack(context, 'Failed to load batches: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : batches.isEmpty
              ? EmptyState(
                  icon: widget.icon,
                  message: "No batches created yet.",
                  hint: "Create a batch from the Courses tab first.",
                )
              : buildFolderGrid(
                  cards: batches.map((batch) {
                    final batchId = batch['id']!;
                    final batchName = batch['name']!;

                    return FolderCard(
                      icon: Icons.folder_rounded,
                      label: batchName,
                      subtitle: widget.subtitle,
                      color: widget.color,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                widget.pageBuilder(batchId, batchName),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
    );
  }
}

// ============================================================
// HOME
// ============================================================

class CoreHomePage extends StatefulWidget {
  final void Function(int pageIndex) onNavigate;

  const CoreHomePage({
    super.key,
    required this.onNavigate,
  });

  @override
  State<CoreHomePage> createState() => _CoreHomePageState();
}

class _CoreHomePageState extends State<CoreHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String tutorName = '';
  String tutorEmail = '';
  bool nameLoading = true;

  bool statsLoading = true;
  int batchCount = 0;
  int courseCount = 0;
  int materialCount = 0;
  int questionCount = 0;

  @override
  void initState() {
    super.initState();
    _loadTutor();
    _loadStats();
  }

  Future<void> _loadTutor() async {
    final user = FirebaseAuth.instance.currentUser;

    String name = user?.displayName?.trim() ?? '';
    final email = user?.email ?? '';

    try {
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        final data = doc.data();

        if (data != null) {
          final value = (data['name'] ??
                  data['fullName'] ??
                  data['displayName'] ??
                  data['username'])
              ?.toString()
              .trim();

          if (value != null && value.isNotEmpty) {
            name = value;
          }
        }
      }
    } catch (_) {
      // Fall back to the auth profile below.
    }

    if (name.isEmpty) {
      name = email.contains('@') ? email.split('@').first : 'Tutor';
    }

    if (!mounted) return;

    setState(() {
      tutorName = name;
      tutorEmail = email;
      nameLoading = false;
    });
  }

  Future<int> _count(String collection) async {
    final snapshot = await _firestore.collection(collection).count().get();
    return snapshot.count ?? 0;
  }

  Future<void> _loadStats() async {
    try {
      final results = await Future.wait([
        _count('batches'),
        _count('courses'),
        _count('materials'),
        _count('tests'),
      ]);

      if (!mounted) return;

      setState(() {
        batchCount = results[0];
        courseCount = results[1];
        materialCount = results[2];
        questionCount = results[3];
        statsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        statsLoading = false;
      });
    }
  }

  String _greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  String _todayLabel() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final now = DateTime.now();

    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  Widget _buildChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final initial =
        tutorName.isNotEmpty ? tutorName[0].toUpperCase() : 'T';

    return Container(
      decoration: const BoxDecoration(
        gradient: kHeaderGradient,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(36),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.28),
                    ),
                    child: CircleAvatar(
                      radius: 34,
                      backgroundColor: Colors.white,
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: kPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        nameLoading
                            ? Container(
                                width: 140,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              )
                            : Text(
                                tutorName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                        if (tutorEmail.isNotEmpty)
                          Text(
                            tutorEmail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12.5,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _buildChip(Icons.verified_rounded, 'Core Tutor'),
                  _buildChip(Icons.calendar_today_rounded, _todayLabel()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([_loadTutor(), _loadStats()]);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.folder_special_rounded,
                          label: 'Batches',
                          value: batchCount,
                          color: Colors.amber.shade700,
                          loading: statsLoading,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.menu_book_rounded,
                          label: 'Courses',
                          value: courseCount,
                          color: Colors.indigo,
                          loading: statsLoading,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.video_library_rounded,
                          label: 'Materials',
                          value: materialCount,
                          color: Colors.redAccent,
                          loading: statsLoading,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.quiz_rounded,
                          label: 'Questions',
                          value: questionCount,
                          color: Colors.teal,
                          loading: statsLoading,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Quick access',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 14),
                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisExtent: 150,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    children: [
                      _ActionCard(
                        icon: Icons.menu_book_rounded,
                        title: 'Courses',
                        subtitle: 'Batches & syllabus',
                        colors: const [
                          Color(0xFF3949AB),
                          Color(0xFF7986CB),
                        ],
                        onTap: () => widget.onNavigate(1),
                      ),
                      _ActionCard(
                        icon: Icons.folder_rounded,
                        title: 'Materials',
                        subtitle: 'Videos & notes',
                        colors: const [
                          Color(0xFFEF6C00),
                          Color(0xFFFFB74D),
                        ],
                        onTap: () => widget.onNavigate(2),
                      ),
                      _ActionCard(
                        icon: Icons.quiz_rounded,
                        title: 'Tests',
                        subtitle: 'Tests by portion',
                        colors: const [
                          Color(0xFF00897B),
                          Color(0xFF4DB6AC),
                        ],
                        onTap: () => widget.onNavigate(3),
                      ),
                      _ActionCard(
                        icon: Icons.assessment_rounded,
                        title: 'Reports',
                        subtitle: 'Class report PDFs',
                        colors: const [
                          Color(0xFF0288D1),
                          Color(0xFF4FC3F7),
                        ],
                        onTap: () => widget.onNavigate(4),
                      ),
                      _ActionCard(
                        icon: Icons.people_alt_rounded,
                        title: 'Mapping',
                        subtitle: 'Tutor-student pairs',
                        colors: const [
                          Color(0xFF8E24AA),
                          Color(0xFFBA68C8),
                        ],
                        onTap: () => widget.onNavigate(5),
                      ),
                      _ActionCard(
                        icon: Icons.feedback_rounded,
                        title: 'Feedback',
                        subtitle: 'Live from students',
                        colors: const [
                          Color(0xFFD81B60),
                          Color(0xFFF06292),
                        ],
                        onTap: () => widget.onNavigate(6),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;
  final bool loading;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.16),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 26,
            child: loading
                ? const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final VoidCallback onTap;
  final bool wide;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.onTap,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconBubble = Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 30, color: Colors.white),
    );

    final texts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12.5,
          ),
        ),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: wide
                ? Row(
                    children: [
                      iconBubble,
                      const SizedBox(width: 14),
                      Expanded(child: texts),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      iconBubble,
                      texts,
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// COURSES PAGE (BATCH FOLDERS)
// ============================================================

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, String>> batches = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    try {
      final snapshot = await _firestore.collection('batches').get();

      if (!mounted) return;

      setState(() {
        batches = snapshot.docs.map((doc) {
          final data = doc.data();

          return {
            'id': doc.id,
            'name': data['name']?.toString() ?? 'Unnamed Batch',
          };
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showSnack(context, 'Failed to load batches: $e');
    }
  }

  Future<void> _createBatch(String batchName) async {
    try {
      final docRef = await _firestore.collection('batches').add({
        'name': batchName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        batches.add({
          'id': docRef.id,
          'name': batchName,
        });
      });

      showSnack(context, 'Batch created successfully');
    } catch (e) {
      if (!mounted) return;

      showSnack(context, 'Failed to create batch: $e');
    }
  }

  Future<void> _deleteBatch(String batchId, String batchName) async {
    final shouldDelete = await confirmDelete(
      context,
      title: 'Delete Batch?',
      message:
          'Are you sure you want to delete "$batchName"? Its courses, materials, tests and reports will be deleted too.',
    );

    if (!shouldDelete) return;

    try {
      await _firestore.collection('batches').doc(batchId).delete();

      await deleteWhere('courses', 'batchId', batchId);
      await deleteWhere('materials', 'batchId', batchId);
      await deleteWhere('testFolders', 'batchId', batchId);
      await deleteWhere('tests', 'batchId', batchId);
      await deleteWhere('reports', 'batchId', batchId);

      if (!mounted) return;

      setState(() {
        batches.removeWhere((batch) => batch['id'] == batchId);
      });

      showSnack(context, 'Batch deleted successfully');
    } catch (e) {
      if (!mounted) return;

      showSnack(context, 'Failed to delete batch: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddNameDialog(
              title: "New Batch",
              label: "Batch Name",
              onCreate: _createBatch,
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("New Batch"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : batches.isEmpty
              ? const EmptyState(
                  icon: Icons.folder_open_rounded,
                  message: "No batches created yet.",
                  hint: "Tap \"New Batch\" to create your first one.",
                )
              : buildFolderGrid(
                  cards: batches.map((batch) {
                    final batchId = batch['id']!;
                    final batchName = batch['name']!;

                    return DeletableFolder(
                      icon: Icons.folder_rounded,
                      label: batchName,
                      subtitle: 'Courses & syllabus',
                      color: Colors.amber.shade700,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BatchCoursesPage(
                              batchId: batchId,
                              batchName: batchName,
                            ),
                          ),
                        );
                      },
                      onDelete: () => _deleteBatch(batchId, batchName),
                    );
                  }).toList(),
                ),
    );
  }
}

// ============================================================
// BATCH COURSES
// ============================================================

class BatchCoursesPage extends StatefulWidget {
  final String batchId;
  final String batchName;

  const BatchCoursesPage({
    super.key,
    required this.batchId,
    required this.batchName,
  });

  @override
  State<BatchCoursesPage> createState() => _BatchCoursesPageState();
}

class _BatchCoursesPageState extends State<BatchCoursesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> courses = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final snapshot = await _firestore
          .collection('courses')
          .where('batchId', isEqualTo: widget.batchId)
          .get();

      if (!mounted) return;

      setState(() {
        courses = sortByCreated(snapshot.docs);
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showSnack(context, 'Failed to load courses: $e');
    }
  }

  Future<void> _deleteCourse(String courseId, String courseTitle) async {
    final shouldDelete = await confirmDelete(
      context,
      title: 'Delete Course?',
      message: 'Delete "$courseTitle"?',
    );

    if (!shouldDelete) return;

    try {
      await _firestore.collection('courses').doc(courseId).delete();

      await _loadCourses();

      if (!mounted) return;

      showSnack(context, 'Course deleted');
    } catch (e) {
      if (!mounted) return;

      showSnack(context, 'Failed to delete course: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: gradientAppBar("${widget.batchName} - Courses"),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (_) => AddCourseDialog(
              batchId: widget.batchId,
              batchName: widget.batchName,
              onCreated: _loadCourses,
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("New Course"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : courses.isEmpty
              ? const EmptyState(
                  icon: Icons.menu_book_rounded,
                  message: "No courses created yet.",
                  hint: "Tap \"New Course\" to add one with its syllabus.",
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final doc = courses[index];
                    final data = doc.data();

                    final title =
                        data['title'] as String? ?? 'Untitled Course';

                    final syllabusName =
                        data['syllabusFileName'] as String? ?? '';

                    return ItemCard(
                      icon: Icons.menu_book_rounded,
                      color: kPrimary,
                      title: title,
                      subtitle: syllabusName.isEmpty ? null : syllabusName,
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => _deleteCourse(doc.id, title),
                      ),
                      onTap: () {
                        final url = data['syllabusUrl'] as String?;

                        if (url != null && url.isNotEmpty) {
                          openUrl(url);
                        }
                      },
                    );
                  },
                ),
    );
  }
}

// ============================================================
// ADD COURSE
// ============================================================

class AddCourseDialog extends StatefulWidget {
  final String batchId;
  final String batchName;
  final Future<void> Function() onCreated;

  const AddCourseDialog({
    super.key,
    required this.batchId,
    required this.batchName,
    required this.onCreated,
  });

  @override
  State<AddCourseDialog> createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<AddCourseDialog> {
  final TextEditingController titleController = TextEditingController();

  String? syllabusFileName;
  Uint8List? syllabusBytes;
  bool isLoading = false;

  Future<void> pickSyllabus() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
        withData: true,
      );

      if (result == null) return;

      final file = result.files.single;

      if (file.bytes == null) {
        throw Exception("Could not read the selected file.");
      }

      setState(() {
        syllabusFileName = file.name;
        syllabusBytes = file.bytes;
      });
    } catch (e) {
      if (!mounted) return;

      showSnack(context, "Error selecting syllabus: $e");
    }
  }

  Future<void> createCourse() async {
    final title = titleController.text.trim();

    if (title.isEmpty ||
        syllabusBytes == null ||
        syllabusFileName == null) {
      showSnack(context, "Please enter a title and select a syllabus.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("No authenticated user found.");
      }

      final syllabusUrl = await CloudinaryService.uploadFile(
        fileBytes: syllabusBytes!,
        fileName: syllabusFileName!,
        resourceType: 'raw',
      );

      if (syllabusUrl == null) {
        throw Exception("Syllabus upload failed.");
      }

      await FirebaseFirestore.instance.collection("courses").add({
        "title": title,
        "batchId": widget.batchId,
        "batchName": widget.batchName,
        "syllabusFileName": syllabusFileName,
        "syllabusUrl": syllabusUrl,
        "createdBy": user.uid,
        "createdAt": FieldValue.serverTimestamp(),
        "isActive": true,
      });

      if (!mounted) return;

      await widget.onCreated();

      if (!mounted) return;

      Navigator.pop(context);

      showSnack(context, "Course Created Successfully ✅");
    } catch (e) {
      if (!mounted) return;

      showSnack(context, "Error: $e");
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
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text("Create New Course"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Course Title",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: isLoading ? null : pickSyllabus,
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload Syllabus"),
            ),
            if (syllabusFileName != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  syllabusFileName!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: const Text("Cancel"),
        ),
        isLoading
            ? const Padding(
                padding: EdgeInsets.all(8),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : ElevatedButton(
                onPressed: createCourse,
                child: const Text("Create"),
              ),
      ],
    );
  }
}

// ============================================================
// MATERIALS
// ============================================================

class MaterialsPage extends StatelessWidget {
  const MaterialsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BatchFolderList(
      icon: Icons.folder_rounded,
      color: Colors.orange,
      subtitle: 'Videos & notes',
      pageBuilder: (batchId, batchName) => BatchMaterialsPage(
        batchId: batchId,
        batchName: batchName,
      ),
    );
  }
}

class BatchMaterialsPage extends StatelessWidget {
  final String batchId;
  final String batchName;

  const BatchMaterialsPage({
    super.key,
    required this.batchId,
    required this.batchName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: gradientAppBar("$batchName - Materials"),
      body: buildFolderGrid(
        cards: [
          FolderCard(
            icon: Icons.video_library_rounded,
            label: "Videos",
            subtitle: "Recorded lessons",
            color: Colors.redAccent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoUploadPage(
                    batchId: batchId,
                    batchName: batchName,
                  ),
                ),
              );
            },
          ),
          FolderCard(
            icon: Icons.picture_as_pdf_rounded,
            label: "Notes",
            subtitle: "PDF & documents",
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotesUploadPage(
                    batchId: batchId,
                    batchName: batchName,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class VideoUploadPage extends StatelessWidget {
  final String batchId;
  final String batchName;

  const VideoUploadPage({
    super.key,
    required this.batchId,
    required this.batchName,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialTypePage(
      batchId: batchId,
      batchName: batchName,
      isVideo: true,
    );
  }
}

class NotesUploadPage extends StatelessWidget {
  final String batchId;
  final String batchName;

  const NotesUploadPage({
    super.key,
    required this.batchId,
    required this.batchName,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialTypePage(
      batchId: batchId,
      batchName: batchName,
      isVideo: false,
    );
  }
}

/// Shared page for uploading / listing videos and notes.
class MaterialTypePage extends StatefulWidget {
  final String batchId;
  final String batchName;
  final bool isVideo;

  const MaterialTypePage({
    super.key,
    required this.batchId,
    required this.batchName,
    required this.isVideo,
  });

  @override
  State<MaterialTypePage> createState() => _MaterialTypePageState();
}

class _MaterialTypePageState extends State<MaterialTypePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true;
  bool isUploading = false;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> items = [];

  bool get isVideo => widget.isVideo;
  String get type => isVideo ? 'video' : 'note';
  String get pluralLabel => isVideo ? 'Videos' : 'Notes';
  String get singularLabel => isVideo ? 'video' : 'file';
  Color get color => isVideo ? Colors.redAccent : Colors.orange;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final snapshot = await _firestore
          .collection('materials')
          .where('batchId', isEqualTo: widget.batchId)
          .where('type', isEqualTo: type)
          .get();

      if (!mounted) return;

      setState(() {
        items = sortByCreated(snapshot.docs, descending: true);
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showSnack(context, 'Failed to load ${pluralLabel.toLowerCase()}: $e');
    }
  }

  Future<void> _pickAndUpload() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: isVideo ? FileType.video : FileType.custom,
        allowedExtensions: isVideo ? null : ['pdf', 'doc', 'docx'],
        allowMultiple: false,
        withData: true,
      );

      if (result == null) return;

      final file = result.files.single;

      if (file.bytes == null) {
        throw Exception("Could not read the selected $singularLabel.");
      }

      setState(() {
        isUploading = true;
      });

      final url = await CloudinaryService.uploadFile(
        fileBytes: file.bytes!,
        fileName: file.name,
        resourceType: isVideo ? 'video' : 'raw',
      );

      if (url == null) {
        throw Exception("Upload failed.");
      }

      final user = FirebaseAuth.instance.currentUser;

      await _firestore.collection('materials').add({
        'type': type,
        'fileName': file.name,
        'url': url,
        'batchId': widget.batchId,
        'batchName': widget.batchName,
        'createdBy': user?.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      await _loadItems();

      if (!mounted) return;

      showSnack(
        context,
        isVideo
            ? "Video uploaded and saved successfully!"
            : "File uploaded and saved successfully!",
      );
    } catch (e) {
      if (!mounted) return;

      showSnack(context, "Error uploading $singularLabel: $e");
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  Future<void> _deleteItem(String documentId, String fileName) async {
    final shouldDelete = await confirmDelete(
      context,
      title: isVideo ? "Delete Video?" : "Delete File?",
      message: 'Are you sure you want to delete "$fileName"?',
    );

    if (!shouldDelete) return;

    try {
      await _firestore.collection('materials').doc(documentId).delete();

      await _loadItems();

      if (!mounted) return;

      showSnack(
        context,
        isVideo ? "Video removed from the app." : "File removed from the app.",
      );
    } catch (e) {
      if (!mounted) return;

      showSnack(context, "Failed to delete $singularLabel: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: gradientAppBar("${widget.batchName} - $pluralLabel"),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isUploading ? null : _pickAndUpload,
        backgroundColor: isUploading ? Colors.grey : null,
        icon: isUploading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(isVideo ? Icons.upload : Icons.upload_file),
        label: Text(
          isUploading
              ? "Uploading..."
              : (isVideo ? "Upload Video" : "Upload Notes"),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? EmptyState(
                  icon: isVideo
                      ? Icons.video_library_rounded
                      : Icons.picture_as_pdf_rounded,
                  message: isVideo
                      ? "No videos uploaded yet."
                      : "No notes uploaded yet.",
                  hint: "Use the upload button to add one.",
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final doc = items[index];
                    final data = doc.data();

                    final fileName = data['fileName'] as String? ??
                        (isVideo ? "Video" : "Document");

                    final url = data['url'] as String? ?? "";

                    return ItemCard(
                      icon: isVideo
                          ? Icons.play_arrow_rounded
                          : Icons.picture_as_pdf_rounded,
                      color: color,
                      title: fileName,
                      subtitle: isVideo
                          ? "Tap to open video"
                          : "Tap to open document",
                      onTap: url.isEmpty ? null : () => openUrl(url),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => _deleteItem(doc.id, fileName),
                      ),
                    );
                  },
                ),
    );
  }
}

// ============================================================
// OPEN URL
// ============================================================

Future<void> openUrl(String url) async {
  final uri = Uri.tryParse(url);

  if (uri == null) return;

  try {
    final launched = await launchUrl(
      uri,
      webOnlyWindowName: '_blank',
    );

    if (!launched) {
      debugPrint("Could not open URL: $url");
    }
  } catch (e) {
    debugPrint("Error opening URL: $e");
  }
}

// ============================================================
// TESTS  (Batch -> Test folders -> Questions)
// ============================================================

class TestsPage extends StatelessWidget {
  const TestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BatchFolderList(
      icon: Icons.quiz_rounded,
      color: Colors.deepPurple,
      subtitle: 'Test folders',
      pageBuilder: (batchId, batchName) => BatchTestsPage(
        batchId: batchId,
        batchName: batchName,
      ),
    );
  }
}

// ------------------------------------------------------------
// Test folders inside a batch (Test 1, Test 2, Algebra, ...)
// ------------------------------------------------------------

class BatchTestsPage extends StatefulWidget {
  final String batchId;
  final String batchName;

  const BatchTestsPage({
    super.key,
    required this.batchId,
    required this.batchName,
  });

  @override
  State<BatchTestsPage> createState() => _BatchTestsPageState();
}

class _BatchTestsPageState extends State<BatchTestsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> tests = [];

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  Future<void> _loadTests() async {
    try {
      final snapshot = await _firestore
          .collection('testFolders')
          .where('batchId', isEqualTo: widget.batchId)
          .get();

      if (!mounted) return;

      setState(() {
        tests = sortByCreated(snapshot.docs);
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showSnack(context, 'Failed to load tests: $e');
    }
  }

  Future<void> _createTest(String name) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      await _firestore.collection('testFolders').add({
        'name': name,
        'batchId': widget.batchId,
        'batchName': widget.batchName,
        'createdBy': user?.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _loadTests();

      if (!mounted) return;

      showSnack(context, 'Test folder created');
    } catch (e) {
      if (!mounted) return;

      showSnack(context, 'Failed to create test: $e');
    }
  }

  Future<void> _deleteTest(String testId, String testName) async {
    final shouldDelete = await confirmDelete(
      context,
      title: 'Delete Test?',
      message:
          'Delete "$testName" and all of its questions? This cannot be undone.',
    );

    if (!shouldDelete) return;

    try {
      await deleteWhere('tests', 'testId', testId);
      await _firestore.collection('testFolders').doc(testId).delete();

      await _loadTests();

      if (!mounted) return;

      showSnack(context, 'Test deleted');
    } catch (e) {
      if (!mounted) return;

      showSnack(context, 'Failed to delete test: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: gradientAppBar("${widget.batchName} - Tests"),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddNameDialog(
              title: "New Test",
              label: "Test name (e.g. Test 1, Algebra)",
              onCreate: _createTest,
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("New Test"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tests.isEmpty
              ? const EmptyState(
                  icon: Icons.quiz_rounded,
                  message: "No tests created yet.",
                  hint:
                      "Tap \"New Test\" and name it after the portion it covers.",
                )
              : buildFolderGrid(
                  cards: tests.map((doc) {
                    final name = doc.data()['name']?.toString() ?? 'Test';

                    return DeletableFolder(
                      icon: Icons.assignment_rounded,
                      label: name,
                      subtitle: 'Open questions',
                      color: Colors.deepPurple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TestQuestionsPage(
                              batchId: widget.batchId,
                              batchName: widget.batchName,
                              testId: doc.id,
                              testName: name,
                            ),
                          ),
                        );
                      },
                      onDelete: () => _deleteTest(doc.id, name),
                    );
                  }).toList(),
                ),
    );
  }
}

// ------------------------------------------------------------
// Questions of one test
// ------------------------------------------------------------

class TestQuestionsPage extends StatefulWidget {
  final String batchId;
  final String batchName;
  final String testId;
  final String testName;

  const TestQuestionsPage({
    super.key,
    required this.batchId,
    required this.batchName,
    required this.testId,
    required this.testName,
  });

  @override
  State<TestQuestionsPage> createState() => _TestQuestionsPageState();
}

class _TestQuestionsPageState extends State<TestQuestionsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> questions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final snapshot = await _firestore
          .collection('tests')
          .where('batchId', isEqualTo: widget.batchId)
          .where('testId', isEqualTo: widget.testId)
          .get();

      if (!mounted) return;

      setState(() {
        questions = sortByCreated(snapshot.docs);
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showSnack(context, 'Failed to load questions: $e');
    }
  }

  Future<void> _deleteQuestion(String documentId, String question) async {
    final shouldDelete = await confirmDelete(
      context,
      title: "Delete Question?",
      message:
          'Are you sure you want to delete this question?\n\n"$question"',
    );

    if (!shouldDelete) return;

    try {
      await _firestore.collection('tests').doc(documentId).delete();

      await _loadQuestions();

      if (!mounted) return;

      showSnack(context, "Question deleted.");
    } catch (e) {
      if (!mounted) return;

      showSnack(context, "Failed to delete question: $e");
    }
  }

  Future<void> _showQuestionDialog({
    QueryDocumentSnapshot<Map<String, dynamic>>? existingDocument,
  }) async {
    final data = existingDocument?.data();

    await showDialog(
      context: context,
      builder: (_) {
        return QuestionDialog(
          batchId: widget.batchId,
          batchName: widget.batchName,
          testId: widget.testId,
          testName: widget.testName,
          existingData: data,
          documentId: existingDocument?.id,
          onSaved: _loadQuestions,
        );
      },
    );
  }

  Widget _buildOption(String label, String text, String correctAnswer) {
    final isCorrect = correctAnswer == label;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCorrect
            ? Colors.green.withOpacity(0.10)
            : Colors.grey.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isCorrect ? Colors.green.withOpacity(0.5) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor:
                isCorrect ? Colors.green : Colors.grey.shade300,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isCorrect ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: isCorrect ? Colors.green.shade800 : Colors.black87,
                fontWeight: isCorrect ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ),
          if (isCorrect)
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: gradientAppBar(widget.testName),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showQuestionDialog();
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Question"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : questions.isEmpty
              ? EmptyState(
                  icon: Icons.help_outline_rounded,
                  message: "No questions in ${widget.testName} yet.",
                  hint: "Tap \"Add Question\" to write the first one.",
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final doc = questions[index];
                    final data = doc.data();

                    final question = data['question'] as String? ?? "Question";
                    final optionA = data['optionA'] as String? ?? "";
                    final optionB = data['optionB'] as String? ?? "";
                    final optionC = data['optionC'] as String? ?? "";
                    final optionD = data['optionD'] as String? ?? "";
                    final correctAnswer =
                        data['correctAnswer'] as String? ?? "";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "Q${index + 1}",
                                  style: const TextStyle(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    question,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: "Edit",
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  _showQuestionDialog(existingDocument: doc);
                                },
                              ),
                              IconButton(
                                tooltip: "Delete",
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  _deleteQuestion(doc.id, question);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildOption("A", optionA, correctAnswer),
                          _buildOption("B", optionB, correctAnswer),
                          _buildOption("C", optionC, correctAnswer),
                          _buildOption("D", optionD, correctAnswer),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

// ------------------------------------------------------------
// Question create / edit dialog
// ------------------------------------------------------------

class QuestionDialog extends StatefulWidget {
  final String batchId;
  final String batchName;
  final String testId;
  final String testName;

  final Map<String, dynamic>? existingData;
  final String? documentId;

  final Future<void> Function() onSaved;

  const QuestionDialog({
    super.key,
    required this.batchId,
    required this.batchName,
    required this.testId,
    required this.testName,
    required this.onSaved,
    this.existingData,
    this.documentId,
  });

  @override
  State<QuestionDialog> createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<QuestionDialog> {
  late final TextEditingController questionController;
  late final TextEditingController optionAController;
  late final TextEditingController optionBController;
  late final TextEditingController optionCController;
  late final TextEditingController optionDController;

  String? correctAnswer;

  bool isSaving = false;

  bool get isEditing => widget.documentId != null;

  @override
  void initState() {
    super.initState();

    final data = widget.existingData ?? {};

    questionController =
        TextEditingController(text: data['question']?.toString() ?? '');
    optionAController =
        TextEditingController(text: data['optionA']?.toString() ?? '');
    optionBController =
        TextEditingController(text: data['optionB']?.toString() ?? '');
    optionCController =
        TextEditingController(text: data['optionC']?.toString() ?? '');
    optionDController =
        TextEditingController(text: data['optionD']?.toString() ?? '');

    final savedAnswer = data['correctAnswer']?.toString();

    if (['A', 'B', 'C', 'D'].contains(savedAnswer)) {
      correctAnswer = savedAnswer;
    }
  }

  @override
  void dispose() {
    questionController.dispose();
    optionAController.dispose();
    optionBController.dispose();
    optionCController.dispose();
    optionDController.dispose();

    super.dispose();
  }

  Future<void> saveQuestion() async {
    final question = questionController.text.trim();
    final optionA = optionAController.text.trim();
    final optionB = optionBController.text.trim();
    final optionC = optionCController.text.trim();
    final optionD = optionDController.text.trim();

    if (question.isEmpty ||
        optionA.isEmpty ||
        optionB.isEmpty ||
        optionC.isEmpty ||
        optionD.isEmpty ||
        correctAnswer == null) {
      showSnack(
        context,
        "Please fill all fields and select the correct answer.",
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      final data = <String, dynamic>{
        'batchId': widget.batchId,
        'batchName': widget.batchName,
        'testId': widget.testId,
        'testName': widget.testName,
        'question': question,
        'optionA': optionA,
        'optionB': optionB,
        'optionC': optionC,
        'optionD': optionD,
        'correctAnswer': correctAnswer,
      };

      if (isEditing) {
        data['updatedAt'] = FieldValue.serverTimestamp();

        await FirebaseFirestore.instance
            .collection('tests')
            .doc(widget.documentId)
            .update(data);
      } else {
        data['createdBy'] = user?.uid;
        data['createdAt'] = FieldValue.serverTimestamp();

        await FirebaseFirestore.instance.collection('tests').add(data);
      }

      if (!mounted) return;

      await widget.onSaved();

      if (!mounted) return;

      Navigator.pop(context);

      showSnack(
        context,
        isEditing
            ? "Question updated successfully."
            : "Question added successfully.",
      );
    } catch (e) {
      if (!mounted) return;

      showSnack(context, "Failed to save question: $e");
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Widget _buildOptionField({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: "Option $label",
          prefixIcon: Padding(
            padding: const EdgeInsets.all(10),
            child: CircleAvatar(
              radius: 12,
              child: Text(
                label,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(isEditing ? "Edit Question" : "Add Question"),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Question",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildOptionField(label: "A", controller: optionAController),
              _buildOptionField(label: "B", controller: optionBController),
              _buildOptionField(label: "C", controller: optionCController),
              _buildOptionField(label: "D", controller: optionDController),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: correctAnswer,
                decoration: InputDecoration(
                  labelText: "Correct Answer",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: "A", child: Text("A")),
                  DropdownMenuItem(value: "B", child: Text("B")),
                  DropdownMenuItem(value: "C", child: Text("C")),
                  DropdownMenuItem(value: "D", child: Text("D")),
                ],
                onChanged: isSaving
                    ? null
                    : (value) {
                        setState(() {
                          correctAnswer = value;
                        });
                      },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSaving
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: isSaving ? null : saveQuestion,
          child: isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? "Update" : "Save"),
        ),
      ],
    );
  }
}

// ============================================================
// REPORTS  (Batch -> PDF class reports)
// ============================================================

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BatchFolderList(
      icon: Icons.assessment_rounded,
      color: Colors.teal,
      subtitle: 'Class reports',
      pageBuilder: (batchId, batchName) => BatchReportsPage(
        batchId: batchId,
        batchName: batchName,
      ),
    );
  }
}

class BatchReportsPage extends StatefulWidget {
  final String batchId;
  final String batchName;

  const BatchReportsPage({
    super.key,
    required this.batchId,
    required this.batchName,
  });

  @override
  State<BatchReportsPage> createState() => _BatchReportsPageState();
}

class _BatchReportsPageState extends State<BatchReportsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true;
  bool isUploading = false;
  int uploadTotal = 0;
  int uploadDone = 0;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      final snapshot = await _firestore
          .collection('reports')
          .where('batchId', isEqualTo: widget.batchId)
          .get();

      if (!mounted) return;

      setState(() {
        reports = sortByCreated(snapshot.docs, descending: true);
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showSnack(context, 'Failed to load reports: $e');
    }
  }

  /// Uploads one PDF to Cloudinary (up to 3 attempts) and only then saves
  /// it to Firestore, so a report never shows up without its file.
  Future<void> _uploadOne(PlatformFile file) async {
    String? url;
    Object? lastError;

    for (var attempt = 1; attempt <= 3 && url == null; attempt++) {
      try {
        url = await CloudinaryService.uploadFile(
          fileBytes: file.bytes!,
          fileName: file.name,
          resourceType: 'raw',
        );
      } catch (e) {
        lastError = e;
      }

      if (url == null && attempt < 3) {
        await Future.delayed(Duration(seconds: attempt));
      }
    }

    if (url == null) {
      throw lastError ?? Exception('Upload failed');
    }

    final user = FirebaseAuth.instance.currentUser;

    await _firestore.collection('reports').add({
      'fileName': file.name,
      'url': url,
      'batchId': widget.batchId,
      'batchName': widget.batchName,
      'createdBy': user?.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _pickAndUpload() async {
    final FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
        withData: true,
      );
    } catch (e) {
      if (!mounted) return;

      showSnack(context, 'Could not open the file picker: $e');
      return;
    }

    if (result == null || result.files.isEmpty) return;

    final files = result.files;

    setState(() {
      isUploading = true;
      uploadTotal = files.length;
      uploadDone = 0;
    });

    int successCount = 0;
    final failed = <String>[];

    for (final file in files) {
      if (file.bytes == null) {
        failed.add(file.name);
      } else {
        try {
          await _uploadOne(file);
          successCount++;
        } catch (_) {
          failed.add(file.name);
        }
      }

      if (mounted) {
        setState(() {
          uploadDone++;
        });
      }
    }

    if (!mounted) return;

    setState(() {
      isUploading = false;
    });

    await _loadReports();

    if (!mounted) return;

    if (failed.isEmpty) {
      showSnack(
        context,
        successCount == 1
            ? 'Report uploaded successfully!'
            : '$successCount reports uploaded successfully!',
      );
    } else {
      showSnack(
        context,
        'Uploaded $successCount. Could not upload: ${failed.join(', ')}. '
        'Please try again.',
      );
    }
  }

  Future<void> _deleteReport(String documentId, String fileName) async {
    final shouldDelete = await confirmDelete(
      context,
      title: 'Delete Report?',
      message: 'Are you sure you want to delete "$fileName"?',
    );

    if (!shouldDelete) return;

    try {
      await _firestore.collection('reports').doc(documentId).delete();

      await _loadReports();

      if (!mounted) return;

      showSnack(context, 'Report removed from the app.');
    } catch (e) {
      if (!mounted) return;

      showSnack(context, 'Failed to delete report: $e');
    }
  }

  String _dateLabel(Map<String, dynamic> data) {
    final date = _createdAt(data);

    if (date == null) return 'Tap to open report';

    return 'Uploaded ${date.day}/${date.month}/${date.year}  •  Tap to open';
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (reports.isEmpty) {
      content = const EmptyState(
        icon: Icons.picture_as_pdf_rounded,
        message: "No reports uploaded yet.",
        hint: "Tap \"Upload PDF\" to add a class report.",
      );
    } else {
      content = ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final doc = reports[index];
          final data = doc.data();

          final fileName = data['fileName'] as String? ?? 'Report';
          final url = data['url'] as String? ?? '';

          return ItemCard(
            icon: Icons.picture_as_pdf_rounded,
            color: Colors.red.shade400,
            title: fileName,
            subtitle: _dateLabel(data),
            onTap: url.isEmpty ? null : () => openUrl(url),
            trailing: IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
              onPressed: () => _deleteReport(doc.id, fileName),
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: kBg,
      appBar: gradientAppBar("${widget.batchName} - Reports"),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isUploading ? null : _pickAndUpload,
        backgroundColor: isUploading ? Colors.grey : null,
        icon: isUploading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.upload_file),
        label: Text(
          isUploading
              ? 'Uploading $uploadDone/$uploadTotal'
              : 'Upload PDF',
        ),
      ),
      body: Column(
        children: [
          if (isUploading) const LinearProgressIndicator(minHeight: 4),
          Expanded(child: content),
        ],
      ),
    );
  }
}

// ============================================================
// TUTOR-STUDENT MAPPING  (read-only, assigned by the admin)
// ============================================================
//
// The admin creates the mappings. This page only READS them, live.
//
// If your admin app stores mappings under a different collection name,
// change kMappingCollection below. Each mapping document is expected to
// have (alternative field names are also accepted):
//   tutorName   [tutor, tutor_name]
//   studentName [student, student_name]
//   batchName   [batch, batch_name]     (or batchId, matched against `batches`)

const String kMappingCollection = 'mappings';

String pickText(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = data[key]?.toString().trim() ?? '';

    if (value.isNotEmpty) return value;
  }

  return '';
}

class MappingEntry {
  final String tutor;
  final String student;
  final String batch;

  const MappingEntry({
    required this.tutor,
    required this.student,
    required this.batch,
  });

  factory MappingEntry.fromData(
    Map<String, dynamic> data,
    Map<String, String> batchNames,
  ) {
    final tutor = pickText(data, ['tutorName', 'tutor', 'tutor_name']);
    final student =
        pickText(data, ['studentName', 'student', 'student_name']);

    var batch = pickText(data, ['batchName', 'batch', 'batch_name']);

    if (batch.isEmpty) {
      final batchId = pickText(data, ['batchId']);
      batch = batchNames[batchId] ?? '';
    }

    return MappingEntry(
      tutor: tutor.isEmpty ? 'Unknown tutor' : tutor,
      student: student.isEmpty ? 'Unknown student' : student,
      batch: batch.isEmpty ? 'Unassigned' : batch,
    );
  }
}

List<MappingEntry> parseMappings(
  QuerySnapshot<Map<String, dynamic>> snapshot,
  Map<String, String> batchNames,
) {
  return snapshot.docs
      .map((doc) => MappingEntry.fromData(doc.data(), batchNames))
      .toList();
}

Future<Map<String, String>> loadBatchNames() async {
  try {
    final snapshot =
        await FirebaseFirestore.instance.collection('batches').get();

    return {
      for (final doc in snapshot.docs)
        doc.id: doc.data()['name']?.toString() ?? '',
    };
  } catch (_) {
    return {};
  }
}

class MappingPage extends StatefulWidget {
  const MappingPage({super.key});

  @override
  State<MappingPage> createState() => _MappingPageState();
}

class _MappingPageState extends State<MappingPage> {
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _stream =
      FirebaseFirestore.instance.collection(kMappingCollection).snapshots();

  Map<String, String> batchNames = {};

  @override
  void initState() {
    super.initState();

    loadBatchNames().then((value) {
      if (!mounted) return;

      setState(() {
        batchNames = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return EmptyState(
              icon: Icons.error_outline_rounded,
              message: "Could not load mappings.",
              hint: '${snapshot.error}',
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final entries = parseMappings(snapshot.data!, batchNames);

          if (entries.isEmpty) {
            return const EmptyState(
              icon: Icons.people_alt_rounded,
              message: "No mappings yet.",
              hint: "Tutor-student mappings assigned by the admin "
                  "will appear here.",
            );
          }

          final grouped = <String, List<MappingEntry>>{};

          for (final entry in entries) {
            grouped.putIfAbsent(entry.batch, () => []).add(entry);
          }

          final batches = grouped.keys.toList()..sort();

          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 18,
                      color: Colors.indigo,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Assigned by the admin. View only.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.indigo.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: buildFolderGrid(
                  cards: batches.map((batch) {
                    final count = grouped[batch]!.length;

                    return FolderCard(
                      icon: Icons.folder_rounded,
                      label: batch,
                      subtitle: '$count pair${count == 1 ? '' : 's'}',
                      color: Colors.indigo,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BatchMappingPage(
                              batchName: batch,
                              batchNames: batchNames,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class BatchMappingPage extends StatefulWidget {
  final String batchName;
  final Map<String, String> batchNames;

  const BatchMappingPage({
    super.key,
    required this.batchName,
    required this.batchNames,
  });

  @override
  State<BatchMappingPage> createState() => _BatchMappingPageState();
}

class _BatchMappingPageState extends State<BatchMappingPage> {
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _stream =
      FirebaseFirestore.instance.collection(kMappingCollection).snapshots();

  final TextEditingController searchController = TextEditingController();
  String query = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Widget _buildTutorCard(String tutor, List<String> students) {
    final sortedStudents = students.toSet().toList()..sort();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.10),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.indigo.withOpacity(0.12),
                child: Text(
                  tutor[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.indigo,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tutor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Tutor',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${sortedStudents.length} student'
                  '${sortedStudents.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: Colors.indigo,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sortedStudents.map((student) {
              return Chip(
                backgroundColor: kBg,
                side: BorderSide.none,
                avatar: CircleAvatar(
                  backgroundColor: Colors.indigo.withOpacity(0.15),
                  child: Text(
                    student[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ),
                label: Text(student),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: gradientAppBar("${widget.batchName} - Mapping"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  query = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search tutor or student',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return EmptyState(
                    icon: Icons.error_outline_rounded,
                    message: "Could not load mappings.",
                    hint: '${snapshot.error}',
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final entries = parseMappings(
                  snapshot.data!,
                  widget.batchNames,
                ).where((entry) {
                  if (entry.batch != widget.batchName) return false;

                  if (query.isEmpty) return true;

                  return entry.tutor.toLowerCase().contains(query) ||
                      entry.student.toLowerCase().contains(query);
                }).toList();

                if (entries.isEmpty) {
                  return const EmptyState(
                    icon: Icons.people_alt_rounded,
                    message: "No mappings found.",
                    hint: "Mappings assigned by the admin will appear here.",
                  );
                }

                final byTutor = <String, List<String>>{};

                for (final entry in entries) {
                  byTutor
                      .putIfAbsent(entry.tutor, () => [])
                      .add(entry.student);
                }

                final tutors = byTutor.keys.toList()..sort();

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: tutors.length,
                  itemBuilder: (context, index) {
                    final tutor = tutors[index];

                    return _buildTutorCard(tutor, byTutor[tutor]!);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FEEDBACK  (live from Firestore)
// ============================================================
//
// Reads the `feedback` collection in real time. As soon as a student
// app writes a document there, it appears here without refreshing.
//
// Fields the student app should save:
//   message     : String   (the feedback text)   [also accepts feedback / comment]
//   studentName : String   (who sent it)         [also accepts name / from]
//   batchName   : String   (optional, used for the filter chips)
//   rating      : number   (optional, 1-5 stars)
//   createdAt   : FieldValue.serverTimestamp()

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _stream =
      FirebaseFirestore.instance.collection('feedback').snapshots();

  String? selectedBatch;

  String _firstText(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key]?.toString().trim() ?? '';

      if (value.isNotEmpty) return value;
    }

    return '';
  }

  String _timeAgo(DateTime? time) {
    if (time == null) return 'Just now';

    final diff = DateTime.now().difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    if (diff.inDays < 7) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    }

    return '${time.day}/${time.month}/${time.year}';
  }

  Widget _buildStars(double rating) {
    final rounded = rating.round();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < rounded ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 20,
          color: Colors.amber.shade700,
        );
      }),
    );
  }

  Widget _buildFeedbackCard(Map<String, dynamic> data) {
    final message = _firstText(data, ['message', 'feedback', 'comment']);
    final student = _firstText(data, ['studentName', 'name', 'from']);
    final batch = _firstText(data, ['batchName']);
    final createdAt = _createdAt(data);

    final ratingValue = data['rating'];
    final double? rating = ratingValue is num
        ? ratingValue.toDouble()
        : double.tryParse(ratingValue?.toString() ?? '');

    final isNew = createdAt == null ||
        DateTime.now().difference(createdAt).inHours < 24;

    final displayName = student.isEmpty ? 'Student' : student;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.10),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.pink.withOpacity(0.12),
                child: Text(
                  displayName[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.pink,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      batch.isEmpty
                          ? _timeAgo(createdAt)
                          : '$batch  •  ${_timeAgo(createdAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isNew)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.pink,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'New',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          if (rating != null) ...[
            const SizedBox(height: 12),
            _buildStars(rating),
          ],
          if (message.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return EmptyState(
              icon: Icons.error_outline_rounded,
              message: "Could not load feedback.",
              hint: '${snapshot.error}',
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = sortByCreated(snapshot.data!.docs, descending: true);

          if (docs.isEmpty) {
            return const EmptyState(
              icon: Icons.feedback_rounded,
              message: "No feedback received yet.",
              hint: "New feedback from students will appear here instantly.",
            );
          }

          final batchNames = docs
              .map((d) => d.data()['batchName']?.toString().trim() ?? '')
              .where((name) => name.isNotEmpty)
              .toSet()
              .toList()
            ..sort();

          final activeBatch =
              batchNames.contains(selectedBatch) ? selectedBatch : null;

          final filtered = activeBatch == null
              ? docs
              : docs
                  .where((d) =>
                      d.data()['batchName']?.toString().trim() == activeBatch)
                  .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                child: Row(
                  children: [
                    Text(
                      '${filtered.length} response${filtered.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.circle, size: 9, color: Colors.green),
                          SizedBox(width: 6),
                          Text(
                            'Live',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (batchNames.isNotEmpty)
                SizedBox(
                  height: 52,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: const Text('All'),
                          selected: activeBatch == null,
                          onSelected: (_) {
                            setState(() {
                              selectedBatch = null;
                            });
                          },
                        ),
                      ),
                      ...batchNames.map((name) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(name),
                            selected: activeBatch == name,
                            onSelected: (_) {
                              setState(() {
                                selectedBatch = name;
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _buildFeedbackCard(filtered[index].data());
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}