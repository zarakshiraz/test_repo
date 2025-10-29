import 'package:flutter/material.dart';
import '../models/todo_list.dart';
import '../models/todo_item.dart';
import '../services/todo_repository.dart';
import '../services/sync_service.dart';
import '../widgets/sync_status_badge.dart';

class TodoItemsScreen extends StatefulWidget {
  final TodoList list;
  final TodoRepository repository;
  final SyncService syncService;

  const TodoItemsScreen({
    super.key,
    required this.list,
    required this.repository,
    required this.syncService,
  });

  @override
  State<TodoItemsScreen> createState() => _TodoItemsScreenState();
}

class _TodoItemsScreenState extends State<TodoItemsScreen> {
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _createItem() async {
    if (_titleController.text.trim().isEmpty) return;

    await widget.repository.createTodoItem(
      widget.list.id,
      _titleController.text.trim(),
    );
    _titleController.clear();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _toggleItem(TodoItem item) async {
    await widget.repository.updateTodoItem(
      item.id,
      completed: !item.completed,
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _deleteItem(String id) async {
    await widget.repository.deleteTodoItem(id);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _editItem(TodoItem item) async {
    final controller = TextEditingController(text: item.title);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Item'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Item title'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      await widget.repository.updateTodoItem(item.id, title: result.trim());
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.repository.getTodoItemsForList(widget.list.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.list.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'New item',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _createItem(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _createItem,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text(
                      'No items yet. Add one above!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: item.completed,
                            onChanged: (_) => _toggleItem(item),
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              decoration: item.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Text(
                            'Updated: ${item.updatedAt.toString().substring(0, 16)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SyncStatusBadge(status: item.syncStatus),
                              const SizedBox(width: 8),
                              PopupMenuButton(
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _editItem(item);
                                  } else if (value == 'delete') {
                                    _deleteItem(item.id);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
