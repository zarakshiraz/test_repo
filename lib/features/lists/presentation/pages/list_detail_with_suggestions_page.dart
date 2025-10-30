import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/grocery_list.dart';
import '../../../../core/models/list_item.dart';
import '../../../../core/providers/list_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/suggestion_provider.dart';
import '../widgets/suggestion_chip_bar.dart';

class ListDetailWithSuggestionsPage extends ConsumerStatefulWidget {
  final String listId;

  const ListDetailWithSuggestionsPage({
    super.key,
    required this.listId,
  });

  @override
  ConsumerState<ListDetailWithSuggestionsPage> createState() => _ListDetailWithSuggestionsPageState();
}

class _ListDetailWithSuggestionsPageState extends ConsumerState<ListDetailWithSuggestionsPage> {
  final _itemController = TextEditingController();
  ListProvider? _listProvider;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _itemController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _itemController.removeListener(_onTextChanged);
    _itemController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    // Debounce text changes to avoid too many updates
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _updateSuggestions();
    });
  }

  void _updateSuggestions() {
    if (_listProvider == null) return;
    
    final items = _listProvider!.currentListItems;
    final searchQuery = _itemController.text.trim();
    
    // Update suggestions with debouncing
    ref.read(suggestionProvider(widget.listId).notifier).loadSuggestions(
      listId: widget.listId,
      currentItems: items,
      recentItems: _getRecentItems(),
      searchQuery: searchQuery,
      debounce: true,
    );
  }

  List<ListItem> _getRecentItems() {
    if (_listProvider == null) return [];
    
    final allLists = [
      ..._listProvider!.lists,
      ..._listProvider!.savedLists,
      ..._listProvider!.sharedLists,
    ];
    
    final recentItems = <ListItem>[];
    for (final list in allLists) {
      if (list.id != widget.listId) {
        // In a real implementation, we'd fetch items from these lists
        // For now, we'll return an empty list
      }
    }
    
    return recentItems;
  }

  Future<void> _addItem(String content) async {
    if (content.trim().isEmpty) return;

    final authProvider = provider.Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) return;

    final success = await _listProvider?.addListItem(
      listId: widget.listId,
      content: content.trim(),
    );

    if (success == true && mounted) {
      _itemController.clear();
      _updateSuggestions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = provider.Provider.of<AuthProvider>(context);
    if (authProvider.currentUser == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    return provider.ChangeNotifierProvider(
      create: (_) {
        final listProv = ListProvider(userId: authProvider.currentUser!.id)
          ..loadListItems(widget.listId);
        _listProvider = listProv;
        
        // Initial load of suggestions
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateSuggestions();
        });
        
        return listProv;
      },
      child: provider.Consumer<ListProvider>(
        builder: (context, listProvider, _) {
          _listProvider = listProvider;
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
                // Suggestion Chip Bar (above input)
                SuggestionChipBar(
                  listId: widget.listId,
                  onAccept: (suggestion) {
                    _addItem(suggestion);
                  },
                  onDismissAll: () {
                    // Optionally reload suggestions after dismissing all
                    Future.delayed(const Duration(milliseconds: 300), () {
                      _updateSuggestions();
                    });
                  },
                ),

                // Add Item Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
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
                            prefixIcon: const Icon(Icons.add_shopping_cart),
                          ),
                          onSubmitted: (_) => _addItem(_itemController.text),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _addItem(_itemController.text),
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
                              const SizedBox(height: 8),
                              Text(
                                'Add items or tap suggestions above',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
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
                                // Update suggestions after item is deleted
                                _updateSuggestions();
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
                                subtitle: item.notes != null
                                    ? Text(item.notes!)
                                    : null,
                                secondary: const Icon(Icons.drag_handle),
                              ),
                            );
                          },
                        ),
                ),
              ],
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
    final authProvider = provider.Provider.of<AuthProvider>(context, listen: false);
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
    final authProvider = provider.Provider.of<AuthProvider>(context, listen: false);
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
