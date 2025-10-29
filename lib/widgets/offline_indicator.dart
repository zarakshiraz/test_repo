import 'package:flutter/material.dart';

class OfflineIndicator extends StatelessWidget {
  final bool isOnline;
  final int pendingCount;

  const OfflineIndicator({
    super.key,
    required this.isOnline,
    required this.pendingCount,
  });

  @override
  Widget build(BuildContext context) {
    if (isOnline && pendingCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOnline ? Colors.orange : Colors.red,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnline ? Icons.cloud_upload : Icons.cloud_off,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            isOnline
                ? 'Syncing ($pendingCount pending)'
                : 'Offline ($pendingCount pending)',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
