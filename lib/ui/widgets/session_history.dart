/// Scrollable list of past sessions.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants.dart';
import '../../data/database.dart';

class SessionHistory extends StatelessWidget {
  final List<SessionRecord> sessions;

  const SessionHistory({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              'No sessions yet',
              style: TextStyle(color: colorTextDim, fontSize: 14),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Session History',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colorText,
              ),
            ),
            const SizedBox(height: 12),
            ...sessions.map(_buildRow),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(SessionRecord session) {
    final date = DateFormat('MMM d, h:mm a').format(session.startTime);
    final mins = session.durationSeconds ~/ 60;
    final secs = session.durationSeconds % 60;
    final duration = '${mins}m ${secs}s';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            session.completed ? Icons.check_circle : Icons.cancel,
            color: session.completed ? colorSuccess : colorTextDim,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: const TextStyle(color: colorText, fontSize: 13)),
                Text(
                  '$duration  ·  Level ${session.intensity}',
                  style: const TextStyle(color: colorTextDim, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
