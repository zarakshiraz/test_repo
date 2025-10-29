import 'package:flutter/material.dart';
import '../models/list_template.dart';

class TemplateDetailScreen extends StatelessWidget {
  final ListTemplate template;
  final String userId;
  final VoidCallback onDuplicate;

  const TemplateDetailScreen({
    super.key,
    required this.template,
    required this.userId,
    required this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(template.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Duplicate to new list',
            onPressed: () {
              onDuplicate();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Template Preview',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '${template.itemCount} items',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Created ${_formatDate(template.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: template.items.isEmpty
                ? const Center(
                    child: Text('No items in this template'),
                  )
                : ListView.builder(
                    itemCount: template.items.length,
                    itemBuilder: (context, index) {
                      final item = template.items[index];
                      return ListTile(
                        leading: const Icon(Icons.check_box_outline_blank),
                        title: Text(item.text),
                      );
                    },
                  ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                onDuplicate();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.copy),
              label: const Text('Create List from Template'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
