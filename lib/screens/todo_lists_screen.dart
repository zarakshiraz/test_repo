import 'package:flutter/material.dart';
import '../models/todo_list.dart';
import '../services/todo_repository.dart';
import '../services/sync_service.dart';
import '../widgets/sync_status_badge.dart';
import '../widgets/offline_indicator.dart';
import 'todo_items_screen.dart';

class TodoListsScreen extends StatefulWidget {
  final TodoRepository repository;
  final SyncService syncService;

  const TodoListsScreen({
    super.key,
    required this.repository,
    required this.syncService,
  });

  @override
  State<TodoListsScreen> createState() => _TodoListsScreenState();
}

class _TodoListsScreenState extends State<TodoListsScreen> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.syncService.conflictStream.listen((message) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createList() async {
    if (_nameController.text.trim().isEmpty) return;

    await widget.repository.createTodoList(_nameController.text.trim());
    _nameController.clear();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _deleteList(String id) async {
    await widget.repository.deleteTodoList(id);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _editList(TodoList list) async {
    final controller = TextEditingController(text: list.name);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit List'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'List name'),
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
      await widget.repository.updateTodoList(list.id, result.trim());
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lists = widget.repository.getAllTodoLists();
    final pendingCount = widget.repository.getPendingCount();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Lists'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: StreamBuilder<bool>(
                stream: widget.syncService.syncStatusStream,
                initialData: false,
                builder: (context, snapshot) {
                  return OfflineIndicator(
                    isOnline: widget.syncService.isOnline,
                    pendingCount: pendingCount,
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'New list name',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _createList(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _createList,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: lists.isEmpty
                ? const Center(
                    child: Text(
                      'No lists yet. Create one above!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: lists.length,
                    itemBuilder: (context, index) {
                      final list = lists[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          title: Text(list.name),
                          subtitle: Text(
                            'Updated: ${list.updatedAt.toString().substring(0, 16)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SyncStatusBadge(status: list.syncStatus),
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
                                    _editList(list);
                                  } else if (value == 'delete') {
                                    _deleteList(list.id);
                                  }
                                },
                              ),
                            ],
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TodoItemsScreen(
                                  list: list,
                                  repository: widget.repository,
                                  syncService: widget.syncService,
                                ),
                              ),
                            );
                            if (mounted) {
                              setState(() {});
                            }
                          },
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
