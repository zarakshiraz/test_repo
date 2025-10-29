import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reminder.dart';

class ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isPast = reminder.scheduledTime.isBefore(DateTime.now());
    final dateFormat = DateFormat('MMM dd, yyyy \'at\' h:mm a');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(
          Icons.notifications,
          color: isPast ? Colors.grey : Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          reminder.title,
          style: TextStyle(
            decoration: isPast ? TextDecoration.lineThrough : null,
            color: isPast ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reminder.description != null) ...[
              const SizedBox(height: 4),
              Text(reminder.description!),
            ],
            const SizedBox(height: 4),
            Text(
              dateFormat.format(reminder.scheduledTime),
              style: TextStyle(
                fontSize: 12,
                color: isPast ? Colors.grey : Colors.black54,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              reminder.audience == ReminderAudience.self ? 'Just me' : 'All participants',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              onTap();
            } else if (value == 'delete') {
              onDelete();
            }
          },
        ),
      ),
    );
  }
}
