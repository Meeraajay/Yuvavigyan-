import 'package:flutter/material.dart';

/// Compatibility widget kept for the older Tutor module structure.
///
/// The redesigned Tutor Home page no longer uses TaskSection.
/// Keeping this lightweight version prevents old constructor calls
/// (AttendancePage / EvaluationFormPage / FeedbackPage without studentId)
/// from creating analyzer errors.
class TaskSection extends StatelessWidget {
  const TaskSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
