import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/todo_list.dart';
import '../services/firestore_service.dart';
import 'list_detail_screen.dart';

class ListsScreen extends StatefulWidget {
  final String userId;

  const ListsScreen({super.key, required this.userId});

  @override
  State<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends State<ListsScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final _uuid = const Uuid();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _createNewList() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('New List'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'List Title',
              hintText: 'Enter list title',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      final now = DateTime.now();
      final newList = TodoList(
        id: _uuid.v4(),
        title: result,
        userId: widget.userId,
        createdAt: now,
        updatedAt: now,
      );
      await _firestoreService.saveList(newList);
    }
  }

  Widget _buildListView(Stream<List<TodoList>> stream, String emptyMessage) {
    return StreamBuilder<List<TodoList>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final lists = snapshot.data!;

        if (lists.isEmpty) {
          return Center(
            child: Text(emptyMessage),
          );
        }

        return ListView.builder(
          itemCount: lists.length,
          itemBuilder: (context, index) {
            final list = lists[index];
            return ListTile(
              title: Text(list.title),
              subtitle: Text(
                '${list.items.length} items • Updated ${_formatDate(list.updatedAt)}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListDetailScreen(
                      list: list,
                      userId: widget.userId,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Lists'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Lists'),
            Tab(text: 'Shared with Me'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListView(
            _firestoreService.getLists(widget.userId),
            'No lists yet. Create one to get started!',
          ),
          _buildListView(
            _firestoreService.getSharedLists(widget.userId),
            'No shared lists yet.',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewList,
        tooltip: 'Create New List',
        child: const Icon(Icons.add),
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
