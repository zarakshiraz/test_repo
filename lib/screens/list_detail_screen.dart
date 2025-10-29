import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/todo_list.dart';
import '../models/list_item.dart';
import '../services/firestore_service.dart';

class ListDetailScreen extends StatefulWidget {
  final TodoList list;
  final String userId;

  const ListDetailScreen({
    super.key,
    required this.list,
    required this.userId,
  });

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _uuid = const Uuid();
  late TodoList _currentList;

  @override
  void initState() {
    super.initState();
    _currentList = widget.list;
  }

  Future<void> _addItem() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('New Item'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Item',
              hintText: 'Enter item text',
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
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      final newItem = ListItem(
        id: _uuid.v4(),
        text: result,
        createdAt: DateTime.now(),
      );

      final updatedList = _currentList.copyWith(
        items: [..._currentList.items, newItem],
        updatedAt: DateTime.now(),
      );

      await _firestoreService.saveList(updatedList);
      setState(() {
        _currentList = updatedList;
      });
    }
  }

  Future<void> _toggleItem(ListItem item) async {
    final updatedItems = _currentList.items.map((i) {
      if (i.id == item.id) {
        return i.copyWith(isCompleted: !i.isCompleted);
      }
      return i;
    }).toList();

    final updatedList = _currentList.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );

    await _firestoreService.saveList(updatedList);
    setState(() {
      _currentList = updatedList;
    });
  }

  Future<void> _deleteItem(ListItem item) async {
    final updatedItems =
        _currentList.items.where((i) => i.id != item.id).toList();

    final updatedList = _currentList.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );

    await _firestoreService.saveList(updatedList);
    setState(() {
      _currentList = updatedList;
    });
  }

  Future<void> _saveAsTemplate() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save as Template'),
          content:
              const Text('Save this list as a template for future use?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _firestoreService.saveListAsTemplate(
        templateId: _uuid.v4(),
        userId: widget.userId,
        list: _currentList,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Template saved successfully!'),
          ),
        );
      }
    }
  }

  Future<void> _deleteList() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete List'),
          content: const Text('Are you sure you want to delete this list?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _firestoreService.deleteList(_currentList.id);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  bool get _isSharedList => _currentList.userId != widget.userId;
  bool get _isOwner => _currentList.userId == widget.userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentList.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add),
            tooltip: _isSharedList 
                ? 'Save copy as Template' 
                : 'Save as Template',
            onPressed: _saveAsTemplate,
          ),
          if (_isOwner)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete List',
              onPressed: _deleteList,
            ),
        ],
      ),
      body: _currentList.items.isEmpty
          ? const Center(
              child: Text('No items yet. Add one to get started!'),
            )
          : ListView.builder(
              itemCount: _currentList.items.length,
              itemBuilder: (context, index) {
                final item = _currentList.items[index];
                final child = CheckboxListTile(
                  title: Text(
                    item.text,
                    style: TextStyle(
                      decoration: item.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  value: item.isCompleted,
                  onChanged: _isOwner ? (value) => _toggleItem(item) : null,
                );

                if (!_isOwner) {
                  return child;
                }

                return Dismissible(
                  key: Key(item.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) => _deleteItem(item),
                  child: child,
                );
              },
            ),
      floatingActionButton: _isOwner
          ? FloatingActionButton(
              onPressed: _addItem,
              tooltip: 'Add Item',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
