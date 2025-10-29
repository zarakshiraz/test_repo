import 'package:flutter/material.dart';
import '../models/todo_list.dart';
import '../models/reminder.dart';
import '../services/reminders_service.dart';
import '../widgets/reminder_dialog.dart';
import '../widgets/reminder_card.dart';

class ListDetailScreen extends StatefulWidget {
  final TodoList list;
  final String userId;

  const ListDetailScreen({
    super.key,
    required this.list,
    required this.userId,
  });

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  final RemindersService _remindersService = RemindersService();

  void _showReminderDialog({Reminder? reminder}) {
    showDialog(
      context: context,
      builder: (dialogContext) => ReminderDialog(
        listId: widget.list.id,
        userId: widget.userId,
        reminder: reminder,
        onSave: (title, description, scheduledTime, audience) async {
          if (reminder == null) {
            await _remindersService.createReminder(
              listId: widget.list.id,
              title: title,
              description: description,
              scheduledTime: scheduledTime,
              audience: audience,
              userId: widget.userId,
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reminder created')),
              );
            }
          } else {
            await _remindersService.updateReminder(
              reminder.copyWith(
                title: title,
                description: description,
                scheduledTime: scheduledTime,
                audience: audience,
              ),
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reminder updated')),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _deleteReminder(Reminder reminder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: const Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _remindersService.deleteReminder(reminder.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.list.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder<List<Reminder>>(
        stream: _remindersService.getRemindersForList(widget.list.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final reminders = snapshot.data ?? [];

          if (reminders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notification_add,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No reminders yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to create one',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return ReminderCard(
                reminder: reminder,
                onTap: () => _showReminderDialog(reminder: reminder),
                onDelete: () => _deleteReminder(reminder),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showReminderDialog(),
        tooltip: 'Add Reminder',
        child: const Icon(Icons.add),
      ),
    );
  }
}
