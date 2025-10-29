import 'package:flutter/material.dart';
import '../models/app_settings.dart';

class SettingsScreen extends StatefulWidget {
  final AppSettings settings;
  final Function(AppSettings) onSettingsChanged;

  const SettingsScreen({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  void _updateSettings(AppSettings newSettings) {
    setState(() {
      _settings = newSettings;
    });
    widget.onSettingsChanged(newSettings);
  }

  Future<void> _selectTime({
    required String title,
    required int initialHour,
    required Function(int) onSelected,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: 0),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onSelected(picked.hour);
    }
  }

  String _formatHour(int hour) {
    final time = TimeOfDay(hour: hour, minute: 0);
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format24 = TimeOfDay.fromDateTime(dt);
    return format24.format(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Quiet Hours'),
            subtitle: const Text('Delay notifications during quiet hours'),
            value: _settings.quietHoursEnabled,
            onChanged: (value) {
              _updateSettings(_settings.copyWith(quietHoursEnabled: value));
            },
          ),
          if (_settings.quietHoursEnabled) ...[
            ListTile(
              leading: const Icon(Icons.bedtime),
              title: const Text('Start Time'),
              subtitle: Text(_formatHour(_settings.quietHoursStartHour)),
              onTap: () => _selectTime(
                title: 'Start Time',
                initialHour: _settings.quietHoursStartHour,
                onSelected: (hour) {
                  _updateSettings(_settings.copyWith(quietHoursStartHour: hour));
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.wb_sunny),
              title: const Text('End Time'),
              subtitle: Text(_formatHour(_settings.quietHoursEndHour)),
              onTap: () => _selectTime(
                title: 'End Time',
                initialHour: _settings.quietHoursEndHour,
                onSelected: (hour) {
                  _updateSettings(_settings.copyWith(quietHoursEndHour: hour));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Notifications scheduled during quiet hours will be delayed until ${_formatHour(_settings.quietHoursEndHour)}.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
