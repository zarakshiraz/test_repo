import 'package:flutter/material.dart';
import '../models/todo_list.dart';
import '../repositories/list_repository.dart';
import '../services/contact_service.dart';
import '../services/notification_service.dart';
import 'list_detail_screen.dart';

class ListsScreen extends StatefulWidget {
  final ListRepository repository;
  final ContactService contactService;
  final NotificationService notificationService;
  final String currentUserId;
  final String currentUserName;

  const ListsScreen({
    super.key,
    required this.repository,
    required this.contactService,
    required this.notificationService,
    required this.currentUserId,
    required this.currentUserName,
  });

  @override
  State<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends State<ListsScreen> {
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _createList() async {
    if (_titleController.text.trim().isEmpty) return;

    try {
      await widget.repository.createList(
        _titleController.text.trim(),
        widget.currentUserName,
      );
      _titleController.clear();

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('List created successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _showCreateListDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New List'),
        content: TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: 'List title',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (_) => _createList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _createList,
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _navigateToList(TodoList list) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ListDetailScreen(
          list: list,
          repository: widget.repository,
          contactService: widget.contactService,
          notificationService: widget.notificationService,
          currentUserId: widget.currentUserId,
          currentUserName: widget.currentUserName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Lists'),
      ),
      body: StreamBuilder<List<TodoList>>(
        stream: widget.repository.getUserLists(),
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
              child: Text('No lists yet. Create one to get started!'),
            );
          }

          return ListView.builder(
            itemCount: lists.length,
            itemBuilder: (context, index) {
              final list = lists[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(
                    list.isShared ? Icons.folder_shared : Icons.folder,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(list.title),
                  subtitle: Text(
                    list.isShared
                        ? 'Shared with ${list.participantCount - 1} ${list.participantCount == 2 ? "person" : "people"}'
                        : 'Private list',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _navigateToList(list),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateListDialog,
        tooltip: 'Create List',
        child: const Icon(Icons.add),
      ),
    );
  }
}
