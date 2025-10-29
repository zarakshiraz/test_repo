import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reminder.dart';

class ReminderDialog extends StatefulWidget {
  final String listId;
  final String userId;
  final Reminder? reminder;
  final Function(String title, String? description, DateTime scheduledTime, ReminderAudience audience) onSave;

  const ReminderDialog({
    super.key,
    required this.listId,
    required this.userId,
    this.reminder,
    required this.onSave,
  });

  @override
  State<ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<ReminderDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late ReminderAudience _selectedAudience;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.reminder?.title ?? '');
    _descriptionController = TextEditingController(text: widget.reminder?.description ?? '');
    
    final initialDateTime = widget.reminder?.scheduledTime ?? DateTime.now().add(const Duration(hours: 1));
    _selectedDate = initialDateTime;
    _selectedTime = TimeOfDay.fromDateTime(initialDateTime);
    _selectedAudience = widget.reminder?.audience ?? ReminderAudience.self;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  DateTime get _scheduledDateTime {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    if (_scheduledDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a future date and time')),
      );
      return;
    }

    widget.onSave(
      _titleController.text.trim(),
      _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      _scheduledDateTime,
      _selectedAudience,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.reminder == null ? 'New Reminder' : 'Edit Reminder'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
              onTap: _selectDate,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time),
              title: const Text('Time'),
              subtitle: Text(_selectedTime.format(context)),
              onTap: _selectTime,
            ),
            const SizedBox(height: 16),
            const Text(
              'Notify',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Radio<ReminderAudience>(
                value: ReminderAudience.self,
                groupValue: _selectedAudience,
                onChanged: (value) {
                  setState(() {
                    _selectedAudience = value!;
                  });
                },
              ),
              title: const Text('Just me'),
              onTap: () {
                setState(() {
                  _selectedAudience = ReminderAudience.self;
                });
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Radio<ReminderAudience>(
                value: ReminderAudience.allParticipants,
                groupValue: _selectedAudience,
                onChanged: (value) {
                  setState(() {
                    _selectedAudience = value!;
                  });
                },
              ),
              title: const Text('All participants'),
              onTap: () {
                setState(() {
                  _selectedAudience = ReminderAudience.allParticipants;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
