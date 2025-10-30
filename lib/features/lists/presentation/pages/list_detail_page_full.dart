import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/grocery_list.dart';
import '../../../../core/models/list_item.dart';
import '../../../../core/providers/list_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/ai_provider.dart';
import '../../../../core/services/ai_service.dart';
import '../../../../core/services/ai_transcription_service.dart';
import '../../widgets/ai_item_input_sheet.dart';
import '../../widgets/ai_items_confirmation_dialog.dart';

class ListDetailPageFull extends StatefulWidget {
  final String listId;

  const ListDetailPageFull({
    super.key,
    required this.listId,
  });

  @override
  State<ListDetailPageFull> createState() => _ListDetailPageFullState();
}

class _ListDetailPageFullState extends State<ListDetailPageFull> {
  final _itemController = TextEditingController();
  final _aiService = AIService();
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      final listProvider = ListProvider(userId: authProvider.currentUser!.id);
      listProvider.loadListItems(widget.listId);
    }
  }

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  Future<void> _addItem(BuildContext context) async {
    final text = _itemController.text.trim();
    if (text.isEmpty) return;

    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) return;

    final listProvider = ListProvider(userId: authProvider.currentUser!.id);
    final success = await listProvider.addListItem(
      listId: widget.listId,
      content: text,
    );

    if (success && mounted) {
      _itemController.clear();
      _updateSuggestions([]);
    }
  }

  Future<void> _updateSuggestions(List<ListItem> items) async {
    final suggestions = await _aiService.getSuggestions(
      items.map((i) => i.content).toList(),
    );
    if (mounted) {
      setState(() {
        _suggestions = suggestions;
      });
    }
  }

  void _showAIInputSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => AIProvider(),
        child: AIItemInputSheet(
          onItemsExtracted: (extractedItems) {
            _showItemsConfirmation(context, extractedItems);
          },
        ),
      ),
    );
  }

  void _showItemsConfirmation(
    BuildContext context,
    List<ExtractedItem> extractedItems,
  ) {
    showDialog(
      context: context,
      builder: (context) => AIItemsConfirmationDialog(
        extractedItems: extractedItems,
        onConfirm: (confirmedItems) {
          _addExtractedItems(context, confirmedItems);
        },
      ),
    );
  }

  Future<void> _addExtractedItems(
    BuildContext context,
    List<ExtractedItem> items,
  ) async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) return;

    final listProvider = ListProvider(userId: authProvider.currentUser!.id);
    int successCount = 0;

    for (final item in items) {
      final success = await listProvider.addListItem(
        listId: widget.listId,
        content: item.content,
        notes: item.notes,
      );
      if (success) successCount++;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added $successCount item${successCount == 1 ? '' : 's'}'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              // TODO: Implement undo
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    if (authProvider.currentUser == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    return ChangeNotifierProvider(
      create: (_) => ListProvider(userId: authProvider.currentUser!.id)
        ..loadListItems(widget.listId),
      child: Consumer<ListProvider>(
        builder: (context, listProvider, _) {
          final items = listProvider.currentListItems;
          
          return Scaffold(
            appBar: AppBar(
              title: const Text('List Details'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.chat),
                  onPressed: () {
                    context.go('/lists/chat/${widget.listId}');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => _showShareDialog(context),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'complete',
                      child: Text('Mark as Complete'),
                    ),
                    const PopupMenuItem(
                      value: 'reminder',
                      child: Text('Set Reminder'),
                    ),
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: Text('Duplicate List'),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'complete':
                        _completeList(context);
                        break;
                      case 'reminder':
                        _setReminder(context);
                        break;
                      case 'duplicate':
                        _duplicateList(context);
                        break;
                    }
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                // AI Suggestions
                if (_suggestions.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.blue.shade50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lightbulb_outline, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Suggestions',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _suggestions.map((s) {
                            return ActionChip(
                              label: Text(s),
                              onPressed: () {
                                _itemController.text = s;
                                _addItem(context);
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                // Add Item Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _itemController,
                          decoration: InputDecoration(
                            hintText: 'Add an item...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: (_) => _addItem(context),
                          onChanged: (_) => _updateSuggestions(items),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _addItem(context),
                        icon: const Icon(Icons.add_circle),
                        color: Theme.of(context).primaryColor,
                        iconSize: 32,
                      ),
                    ],
                  ),
                ),

                // Items List
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.list_alt_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No items yet',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                        )
                      : ReorderableListView.builder(
                          itemCount: items.length,
                          onReorder: (oldIndex, newIndex) {
                            final newItems = List<ListItem>.from(items);
                            if (newIndex > oldIndex) newIndex--;
                            final item = newItems.removeAt(oldIndex);
                            newItems.insert(newIndex, item);
                            listProvider.reorderItems(widget.listId, newItems);
                          },
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Dismissible(
                              key: ValueKey(item.id),
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 16),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              direction: DismissDirection.endToStart,
                              onDismissed: (_) {
                                listProvider.deleteListItem(
                                  widget.listId,
                                  item.id,
                                );
                              },
                              child: CheckboxListTile(
                                value: item.isCompleted,
                                onChanged: (value) {
                                  listProvider.updateListItem(
                                    widget.listId,
                                    item.id,
                                    isCompleted: value,
                                  );
                                },
                                title: Text(
                                  item.content,
                                  style: TextStyle(
                                    decoration: item.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                subtitle: item.completedByUserId != null
                                    ? Text('Completed by ${item.completedByUserId}')
                                    : null,
                                secondary: const Icon(Icons.drag_handle),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _showAIInputSheet(context),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('AI Input'),
              tooltip: 'Add items using AI',
            ),
          );
        },
      ),
    );
  }

  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share List'),
        content: const Text('Share functionality coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _completeList(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) return;

    final listProvider = ListProvider(userId: authProvider.currentUser!.id);
    listProvider.updateList(widget.listId, status: ListStatus.completed);
    context.pop();
  }

  void _setReminder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Reminder'),
        content: const Text('Reminder functionality coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _duplicateList(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) return;

    final listProvider = ListProvider(userId: authProvider.currentUser!.id);
    final newList = await listProvider.duplicateList(widget.listId);
    
    if (mounted && newList != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('List duplicated successfully')),
      );
    }
  }
}
