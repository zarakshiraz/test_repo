import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/list_item.dart';
import '../providers/auth_provider.dart';
import '../providers/firestore_providers.dart';
import '../providers/optimistic_updates_provider.dart';

class ListItemTile extends ConsumerStatefulWidget {
  final ListItem item;
  final String listId;

  const ListItemTile({
    super.key,
    required this.item,
    required this.listId,
  });

  @override
  ConsumerState<ListItemTile> createState() => _ListItemTileState();
}

class _ListItemTileState extends ConsumerState<ListItemTile> {
  bool _isEditing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.item.title);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleChecked() async {
    final auth = ref.read(authProvider);
    final service = ref.read(firestoreServiceProvider);
    final optimisticUpdates = ref.read(optimisticUpdatesProvider.notifier);

    final newCheckedState = !widget.item.isChecked;
    final optimisticItem = widget.item.copyWith(
      isChecked: newCheckedState,
      checkedBy: newCheckedState ? auth.userId : null,
      checkedAt: newCheckedState ? DateTime.now() : null,
    );

    optimisticUpdates.addUpdate(widget.item.id, widget.item, optimisticItem);

    try {
      await service.toggleItemChecked(
        listId: widget.listId,
        itemId: widget.item.id,
        isChecked: newCheckedState,
        userId: auth.userId,
        userName: auth.userName,
        itemTitle: widget.item.title,
      );
      optimisticUpdates.confirmUpdate(widget.item.id);
    } catch (e) {
      optimisticUpdates.rollbackUpdate(widget.item.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update item: $e')),
        );
      }
    }
  }

  Future<void> _saveEdit() async {
    if (_controller.text.trim().isEmpty) return;

    final auth = ref.read(authProvider);
    final service = ref.read(firestoreServiceProvider);

    try {
      await service.updateItem(
        listId: widget.listId,
        itemId: widget.item.id,
        title: _controller.text.trim(),
        userId: auth.userId,
        userName: auth.userName,
      );
      setState(() => _isEditing = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update item: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final optimisticUpdate = ref.watch(optimisticUpdatesProvider)[widget.item.id];
    final displayItem = optimisticUpdate?.optimisticItem ?? widget.item;

    return ListTile(
      leading: Checkbox(
        value: displayItem.isChecked,
        onChanged: (_) => _toggleChecked(),
      ),
      title: _isEditing
          ? TextField(
              controller: _controller,
              autofocus: true,
              onSubmitted: (_) => _saveEdit(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            )
          : Text(
              displayItem.title,
              style: TextStyle(
                decoration:
                    displayItem.isChecked ? TextDecoration.lineThrough : null,
              ),
            ),
      subtitle: displayItem.checkedBy != null
          ? Text(
              'Checked by ${displayItem.checkedBy} at ${DateFormat.jm().format(displayItem.checkedAt!)}',
              style: const TextStyle(fontSize: 12),
            )
          : null,
      trailing: _isEditing
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: _saveEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() => _isEditing = false);
                    _controller.text = widget.item.title;
                  },
                ),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => setState(() => _isEditing = true),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final service = ref.read(firestoreServiceProvider);
                    await service.deleteItem(
                      listId: widget.listId,
                      itemId: widget.item.id,
                    );
                  },
                ),
              ],
            ),
    );
  }
}
