import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/firestore_providers.dart';
import '../widgets/connection_status_indicator.dart';
import 'list_detail_screen.dart';

class ListsScreen extends ConsumerStatefulWidget {
  const ListsScreen({super.key});

  @override
  ConsumerState<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends ConsumerState<ListsScreen> {
  final TextEditingController _listTitleController = TextEditingController();

  @override
  void dispose() {
    _listTitleController.dispose();
    super.dispose();
  }

  Future<void> _createList() async {
    if (_listTitleController.text.trim().isEmpty) return;

    final auth = ref.read(authProvider);
    final service = ref.read(firestoreServiceProvider);

    try {
      final listId = await service.createList(
        title: _listTitleController.text.trim(),
        userId: auth.userId,
        userName: auth.userName,
      );
      _listTitleController.clear();
      if (mounted) {
        Navigator.pop(context);
        ref.read(currentListIdProvider.notifier).state = listId;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ListDetailScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create list: $e')),
        );
      }
    }
  }

  void _showCreateListDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New List'),
        content: TextField(
          controller: _listTitleController,
          decoration: const InputDecoration(
            hintText: 'List title',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (_) => _createList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _createList,
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showUserNameDialog() {
    final controller = TextEditingController(
      text: ref.read(authProvider).userName,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Your Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Your name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              ref.read(authProvider.notifier).setUserName(value.trim());
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(authProvider.notifier).setUserName(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listsAsync = ref.watch(listsProvider);
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collaboration Lists'),
        actions: [
          const ConnectionStatusIndicator(),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _showUserNameDialog,
            tooltip: auth.userName,
          ),
        ],
      ),
      body: listsAsync.when(
        data: (lists) {
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
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(list.title),
                  subtitle: Text('${list.participants.length} participants'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    ref.read(currentListIdProvider.notifier).state = list.id;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ListDetailScreen(),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading lists: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateListDialog,
        tooltip: 'Create List',
        child: const Icon(Icons.add),
      ),
    );
  }
}
