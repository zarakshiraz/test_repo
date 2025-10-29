import 'package:flutter/material.dart';
import '../models/sync_status.dart';

class SyncStatusBadge extends StatelessWidget {
  final SyncStatus status;

  const SyncStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String tooltip;

    switch (status) {
      case SyncStatus.synced:
        icon = Icons.cloud_done;
        color = Colors.green;
        tooltip = 'Synced';
        break;
      case SyncStatus.pending:
        icon = Icons.cloud_upload;
        color = Colors.orange;
        tooltip = 'Pending sync';
        break;
      case SyncStatus.conflict:
        icon = Icons.warning;
        color = Colors.red;
        tooltip = 'Sync conflict';
        break;
    }

    return Tooltip(
      message: tooltip,
      child: Icon(
        icon,
        color: color,
        size: 16,
      ),
    );
  }
}
