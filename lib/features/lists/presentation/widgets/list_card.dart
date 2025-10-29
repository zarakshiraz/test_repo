import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/grocery_list.dart';

class ListCard extends StatelessWidget {
  final GroceryList list;
  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleSave;

  const ListCard({
    super.key,
    required this.list,
    this.onTap,
    this.onShare,
    this.onDelete,
    this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(list.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          if (onShare != null)
            SlidableAction(
              onPressed: (_) => onShare!(),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.share,
              label: 'Share',
            ),
          if (onToggleSave != null)
            SlidableAction(
              onPressed: (_) => onToggleSave!(),
              backgroundColor: list.isSaved ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
              icon: list.isSaved ? Icons.bookmark_remove : Icons.bookmark_add,
              label: list.isSaved ? 'Unsave' : 'Save',
            ),
          if (onDelete != null)
            SlidableAction(
              onPressed: (_) => onDelete!(),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
        ],
      ),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  list.title,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (list.isShared)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.people,
                                        size: 12,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${list.sharedWith.length + 1}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (list.isSaved)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  child: Icon(
                                    Icons.bookmark,
                                    size: 16,
                                    color: Colors.orange[600],
                                  ),
                                ),
                            ],
                          ),
                          if (list.description != null && list.description!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                list.description!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Status Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getStatusColor(list.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getStatusIcon(list.status),
                        color: _getStatusColor(list.status),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Progress Bar
                if (list.totalItems > 0) ...[
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: list.completionPercentage,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getStatusColor(list.status),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${list.completedItems}/${list.totalItems}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Footer
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(list.updatedAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                    if (list.category != null) ...[
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          list.category!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (list.reminderTime != null)
                      Icon(
                        Icons.notifications_active,
                        size: 14,
                        color: Colors.orange[600],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ListStatus status) {
    switch (status) {
      case ListStatus.active:
        return Colors.blue;
      case ListStatus.completed:
        return Colors.green;
      case ListStatus.archived:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(ListStatus status) {
    switch (status) {
      case ListStatus.active:
        return Icons.list_alt;
      case ListStatus.completed:
        return Icons.check_circle;
      case ListStatus.archived:
        return Icons.archive;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}