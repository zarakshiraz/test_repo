import 'package:flutter/material.dart';
import '../models/list_model.dart';
import '../services/firestore_service.dart';
import 'list_detail_screen.dart';

class ListsScreen extends StatefulWidget {
  const ListsScreen({super.key});

  @override
  State<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends State<ListsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String _currentUserId = 'user123';

  void _createNewList() {
    showDialog(
      context: context,
      builder: (context) => _CreateListDialog(
        firestoreService: _firestoreService,
        currentUserId: _currentUserId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Lists'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder<List<ListModel>>(
        stream: _firestoreService.getLists(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final lists = snapshot.data ?? [];

          if (lists.isEmpty) {
            return const Center(
              child: Text('No lists yet. Create your first list!'),
            );
          }

          return ListView.builder(
            itemCount: lists.length,
            itemBuilder: (context, index) {
              final list = lists[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  title: Text(
                    list.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: list.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Text(list.description),
                  trailing: Icon(
                    list.isCompleted
                        ? Icons.check_circle
                        : Icons.arrow_forward_ios,
                    color: list.isCompleted ? Colors.green : null,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListDetailScreen(
                          list: list,
                          currentUserId: _currentUserId,
                          currentUserName: 'Current User',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewList,
        tooltip: 'Create List',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CreateListDialog extends StatefulWidget {
  final FirestoreService firestoreService;
  final String currentUserId;

  const _CreateListDialog({
    required this.firestoreService,
    required this.currentUserId,
  });

  @override
  State<_CreateListDialog> createState() => _CreateListDialogState();
}

class _CreateListDialogState extends State<_CreateListDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _createList() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty) {
      return;
    }

    final list = ListModel(
      id: '',
      name: name,
      description: description,
      participantIds: [widget.currentUserId],
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    await widget.firestoreService.createList(list);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New List'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'List Name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createList,
          child: const Text('Create'),
        ),
      ],
    );
  }
}
