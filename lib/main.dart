import 'package:flutter/material.dart';

void main() {
  runApp(const ListManagementApp());
}

class ListManagementApp extends StatefulWidget {
  const ListManagementApp({super.key});

  @override
  ListManagementAppState createState() => ListManagementAppState();
}

class ListManagementAppState extends State<ListManagementApp> {
  final String _currentUser = 'Alex Johnson';
  final List<TaskList> _activeLists = <TaskList>[];
  final List<TaskList> _archivedLists = <TaskList>[];
  int _itemIdCounter = 0;

  List<TaskList> get activeLists => List.unmodifiable(_activeLists);
  List<TaskList> get archivedLists => List.unmodifiable(_archivedLists);
  String get currentUser => _currentUser;

  @override
  void initState() {
    super.initState();
    _seedLists();
  }

  void _seedLists() {
    TaskList buildProductLaunch() {
      return TaskList(
        id: 'list-product',
        title: 'Product Launch Checklist',
        description:
            'Coordinate all tasks required to deliver the upcoming product launch.',
        items: <ChecklistItem>[
          ChecklistItem(id: 'design-assets', title: 'Prepare design assets'),
          ChecklistItem(
            id: 'update-website',
            title: 'Update marketing website',
          ),
          ChecklistItem(
            id: 'coordinate-marketing',
            title: 'Coordinate marketing outreach',
          ),
        ],
        activity: <ActivityEntry>[
          ActivityEntry(
            actor: 'Jamie Lee',
            summary: 'Created list',
            timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          ),
          ActivityEntry(
            actor: 'Priya Patel',
            summary: 'Added launch checklist items',
            timestamp: DateTime.now().subtract(
              const Duration(hours: 3, minutes: 20),
            ),
          ),
        ],
        chatMessages: <String>[
          'Need final signage copy from design.',
          'Confirm launch date with sales team.',
        ],
      );
    }

    TaskList buildOnboarding() {
      return TaskList(
        id: 'list-onboarding',
        title: 'New Hire Onboarding',
        description:
            'Checklist to welcome new team members during their first week.',
        items: <ChecklistItem>[
          ChecklistItem(
            id: 'dev-env',
            title: 'Provision development environment',
          ),
          ChecklistItem(id: 'intro-meetings', title: 'Schedule intro meetings'),
          ChecklistItem(id: 'benefits', title: 'Send benefits overview'),
        ],
        activity: <ActivityEntry>[
          ActivityEntry(
            actor: 'Morgan Zane',
            summary: 'Set up onboarding template',
            timestamp: DateTime.now().subtract(
              const Duration(days: 1, hours: 2),
            ),
          ),
        ],
        chatMessages: <String>['Remember to add security training link.'],
      );
    }

    _activeLists
      ..clear()
      ..addAll(<TaskList>[buildProductLaunch(), buildOnboarding()]);
    _archivedLists.clear();
    _itemIdCounter = 0;
  }

  String _generateItemId() {
    final String id = 'item-${_itemIdCounter++}';
    return id;
  }

  void _updateList(TaskList list, VoidCallback updates) {
    setState(updates);
  }

  void _completeList(TaskList list) {
    setState(() {
      _activeLists.removeWhere((TaskList element) => element.id == list.id);
      list
        ..isArchived = true
        ..completedBy = _currentUser
        ..completedAt = DateTime.now()
        ..chatMessages = <String>[];
      list.logActivity(
        _currentUser,
        'Marked list as completed and moved to archive',
      );
      _archivedLists.add(list);
    });
  }

  void _restoreList(TaskList list) {
    setState(() {
      _archivedLists.removeWhere((TaskList element) => element.id == list.id);
      list
        ..isArchived = false
        ..completedAt = null
        ..completedBy = null;
      list.logActivity(_currentUser, 'Restored list from archive');
      _activeLists.add(list);
    });
  }

  void _deleteArchivedList(TaskList list) {
    setState(() {
      _archivedLists.removeWhere((TaskList element) => element.id == list.id);
    });
  }

  void _openList(BuildContext context, TaskList list) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => ListDetailScreen(
          list: list,
          currentUser: _currentUser,
          onMutate: (VoidCallback action) => _updateList(list, action),
          onCompleteList: () => _completeList(list),
          nextItemId: _generateItemId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'List Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: DefaultTabController(
        length: 2,
        child: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Team Lists'),
                bottom: const TabBar(
                  tabs: <Widget>[
                    Tab(text: 'Active'),
                    Tab(text: 'Archive'),
                  ],
                ),
              ),
              body: TabBarView(
                children: <Widget>[
                  _ActiveListsView(
                    lists: _activeLists,
                    onOpenList: (TaskList list) => _openList(context, list),
                  ),
                  _ArchiveListsView(
                    lists: _archivedLists,
                    onRestore: _restoreList,
                    onDelete: _deleteArchivedList,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ActiveListsView extends StatelessWidget {
  const _ActiveListsView({required this.lists, required this.onOpenList});

  final List<TaskList> lists;
  final void Function(TaskList list) onOpenList;

  @override
  Widget build(BuildContext context) {
    if (lists.isEmpty) {
      return const Center(child: Text('No active lists yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lists.length,
      itemBuilder: (BuildContext context, int index) {
        final TaskList list = lists[index];
        final int completed = list.completedItemCount;
        final int total = list.items.length;
        final double progress = total == 0 ? 0 : completed / total;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(list.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 4),
                Text(list.description),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 4),
                Text('$completed of $total items complete'),
              ],
            ),
            onTap: () => onOpenList(list),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}

class _ArchiveListsView extends StatelessWidget {
  const _ArchiveListsView({
    required this.lists,
    required this.onRestore,
    required this.onDelete,
  });

  final List<TaskList> lists;
  final void Function(TaskList list) onRestore;
  final void Function(TaskList list) onDelete;

  @override
  Widget build(BuildContext context) {
    if (lists.isEmpty) {
      return const Center(child: Text('No archived lists.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lists.length,
      itemBuilder: (BuildContext context, int index) {
        final TaskList list = lists[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  list.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (list.completedAt != null && list.completedBy != null)
                  Text(
                    'Completed by ${list.completedBy} on ${_formatDate(list.completedAt!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () => onRestore(list),
                      child: const Text('Restore'),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () async {
                        final ScaffoldMessengerState messenger =
                            ScaffoldMessenger.of(context);
                        final bool? confirmed = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Delete list?'),
                            content: const Text(
                              'This will permanently remove the list from the archive.',
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          onDelete(list);
                          messenger.showSnackBar(
                            SnackBar(content: Text('Deleted "${list.title}"')),
                          );
                        }
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ListDetailScreen extends StatefulWidget {
  const ListDetailScreen({
    super.key,
    required this.list,
    required this.currentUser,
    required this.onMutate,
    required this.onCompleteList,
    required this.nextItemId,
  });

  final TaskList list;
  final String currentUser;
  final void Function(VoidCallback action) onMutate;
  final VoidCallback onCompleteList;
  final String Function() nextItemId;

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  late final TextEditingController _newItemController;

  @override
  void initState() {
    super.initState();
    _newItemController = TextEditingController();
  }

  @override
  void dispose() {
    _newItemController.dispose();
    super.dispose();
  }

  void _refresh(VoidCallback action) {
    widget.onMutate(action);
    if (mounted) {
      setState(() {});
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (widget.list.isArchived) {
      return;
    }

    _refresh(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final ChecklistItem item = widget.list.items.removeAt(oldIndex);
      widget.list.items.insert(newIndex, item);
      widget.list.logActivity(widget.currentUser, 'Reordered "${item.title}"');
    });
  }

  void _toggleCompletion(ChecklistItem item, bool value) {
    _refresh(() {
      item
        ..isComplete = value
        ..lastEditedAt = value ? DateTime.now() : null
        ..lastEditedBy = value ? widget.currentUser : null;
      widget.list.logActivity(
        widget.currentUser,
        value
            ? 'Completed "${item.title}"'
            : 'Marked "${item.title}" incomplete',
      );
    });
  }

  void _updateTitle(ChecklistItem item, String newTitle) {
    final String trimmed = newTitle.trim();
    if (trimmed.isEmpty || trimmed == item.title) {
      return;
    }
    _refresh(() {
      item.title = trimmed;
      widget.list.logActivity(widget.currentUser, 'Renamed item to "$trimmed"');
    });
  }

  void _removeItem(ChecklistItem item) {
    _refresh(() {
      widget.list.items.removeWhere(
        (ChecklistItem element) => element.id == item.id,
      );
      widget.list.logActivity(widget.currentUser, 'Removed "${item.title}"');
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Removed "${item.title}"')));
  }

  void _addItem() {
    final String trimmed = _newItemController.text.trim();
    if (trimmed.isEmpty) {
      return;
    }

    _refresh(() {
      widget.list.items.add(
        ChecklistItem(id: widget.nextItemId(), title: trimmed),
      );
      widget.list.logActivity(widget.currentUser, 'Added "$trimmed"');
    });
    _newItemController.clear();
  }

  Future<void> _handleComplete() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Complete this list?'),
        content: const Text(
          'Completing this list will move it to the archive and clear all chat history.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    widget.onCompleteList();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '"${widget.list.title}" moved to archive. Chat has been cleared.',
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  void _openChat() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final List<String> messages = widget.list.chatMessages;
        return AlertDialog(
          title: const Text('List Chat'),
          content: messages.isEmpty
              ? const Text(
                  'Chat is empty. Start a conversation from the team dashboard.',
                )
              : SizedBox(
                  width: 320,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: messages.length,
                    itemBuilder: (BuildContext context, int index) =>
                        Text(messages[index]),
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
                  ),
                ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.list.title),
        actions: <Widget>[
          IconButton(
            key: const Key('complete-list-button'),
            onPressed: widget.list.isArchived ? null : _handleComplete,
            icon: const Icon(Icons.check_circle),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.list.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  if (widget.list.completedBy != null &&
                      widget.list.completedAt != null)
                    Text(
                      'Completed by ${widget.list.completedBy} on ${_formatDate(widget.list.completedAt!)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _ActivitySection(entries: widget.list.activity),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _ChecklistSection(
                  list: widget.list,
                  onReorder: _onReorder,
                  onToggle: _toggleCompletion,
                  onRename: _updateTitle,
                  onRemove: _removeItem,
                ),
              ),
            ),
            if (!widget.list.isArchived)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        key: const Key('add-item-field'),
                        controller: _newItemController,
                        decoration: const InputDecoration(
                          hintText: 'Add an item',
                        ),
                        onSubmitted: (_) => _addItem(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      key: const Key('add-item-button'),
                      onPressed: _addItem,
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Card(
                child: ListTile(
                  title: const Text('Chat'),
                  subtitle: Text(
                    widget.list.chatMessages.isEmpty
                        ? 'Chat has been cleared.'
                        : 'Messages: ${widget.list.chatMessages.length}',
                  ),
                  trailing: ElevatedButton(
                    key: const Key('chat-entry-button'),
                    onPressed: _openChat,
                    child: const Text('Open chat'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistSection extends StatelessWidget {
  const _ChecklistSection({
    required this.list,
    required this.onReorder,
    required this.onToggle,
    required this.onRename,
    required this.onRemove,
  });

  final TaskList list;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(ChecklistItem item, bool value) onToggle;
  final void Function(ChecklistItem item, String newTitle) onRename;
  final void Function(ChecklistItem item) onRemove;

  @override
  Widget build(BuildContext context) {
    if (list.items.isEmpty) {
      return const Center(child: Text('No checklist items yet.'));
    }

    return ReorderableListView.builder(
      key: const Key('checklist-reorderable'),
      buildDefaultDragHandles: false,
      itemCount: list.items.length,
      onReorder: onReorder,
      padding: const EdgeInsets.only(bottom: 24),
      itemBuilder: (BuildContext context, int index) {
        final ChecklistItem item = list.items[index];
        final Widget tile = _ChecklistItemTile(
          key: ValueKey('checklist-item-${item.id}'),
          item: item,
          index: index,
          isReadOnly: list.isArchived,
          onToggle: (bool value) => onToggle(item, value),
          onRename: (String value) => onRename(item, value),
          dragHandle: list.isArchived
              ? const Icon(Icons.drag_handle, color: Colors.grey)
              : ReorderableDragStartListener(
                  key: ValueKey('drag-handle-${item.id}'),
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.drag_handle,
                      key: ValueKey('drag-handle-icon-${item.id}'),
                    ),
                  ),
                ),
        );

        if (list.isArchived) {
          return Container(
            key: ValueKey('reorder-${item.id}'),
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: tile,
          );
        }

        return Container(
          key: ValueKey('reorder-${item.id}'),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Dismissible(
            key: ValueKey('dismiss-${item.id}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => onRemove(item),
            child: tile,
          ),
        );
      },
    );
  }
}

class _ChecklistItemTile extends StatefulWidget {
  const _ChecklistItemTile({
    super.key,
    required this.item,
    required this.index,
    required this.isReadOnly,
    required this.onToggle,
    required this.onRename,
    required this.dragHandle,
  });

  final ChecklistItem item;
  final int index;
  final bool isReadOnly;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onRename;
  final Widget dragHandle;

  @override
  State<_ChecklistItemTile> createState() => _ChecklistItemTileState();
}

class _ChecklistItemTileState extends State<_ChecklistItemTile> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.item.title);
  }

  @override
  void didUpdateWidget(covariant _ChecklistItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.title != widget.item.title) {
      _controller.text = widget.item.title;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _commitChange() {
    widget.onRename(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle baseStyle =
        theme.textTheme.bodyLarge ?? const TextStyle(fontSize: 16);
    final TextStyle textStyle = widget.item.isComplete
        ? baseStyle.copyWith(
            decoration: TextDecoration.lineThrough,
            color: theme.colorScheme.outline,
          )
        : baseStyle;

    final Color backgroundColor = theme.colorScheme.surfaceContainerHighest;

    return Material(
      borderRadius: BorderRadius.circular(12),
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Checkbox(
              key: ValueKey('checklist-checkbox-${widget.item.id}'),
              value: widget.item.isComplete,
              onChanged: widget.isReadOnly
                  ? null
                  : (bool? value) => widget.onToggle(value ?? false),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    key: ValueKey('item-text-${widget.item.id}'),
                    controller: _controller,
                    readOnly: widget.isReadOnly,
                    decoration: const InputDecoration(border: InputBorder.none),
                    style: textStyle,
                    maxLines: null,
                    onEditingComplete: _commitChange,
                    onSubmitted: (_) => _commitChange(),
                  ),
                  if (widget.item.isComplete &&
                      widget.item.lastEditedBy != null &&
                      widget.item.lastEditedAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Checked by ${widget.item.lastEditedBy} at ${_formatTime(widget.item.lastEditedAt!)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
            widget.dragHandle,
          ],
        ),
      ),
    );
  }
}

String _formatTime(DateTime dateTime) {
  final TimeOfDay timeOfDay = TimeOfDay.fromDateTime(dateTime);
  final int hour = timeOfDay.hourOfPeriod == 0 ? 12 : timeOfDay.hourOfPeriod;
  final String minute = timeOfDay.minute.toString().padLeft(2, '0');
  final String period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

String _formatDate(DateTime dateTime) {
  final int month = dateTime.month;
  final int day = dateTime.day;
  final int year = dateTime.year;
  final String time = _formatTime(dateTime);
  return '$month/$day/$year at $time';
}

class _ActivitySection extends StatelessWidget {
  const _ActivitySection({required this.entries});

  final List<ActivityEntry> entries;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (entries.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No recent activity yet.',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    final Iterable<ActivityEntry> latest = entries.take(4);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Recent activity', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final ActivityEntry entry in latest)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(entry.summary, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 4),
                    Text(
                      '${entry.actor} • ${_formatDate(entry.timestamp)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ChecklistItem {
  ChecklistItem({
    required this.id,
    required this.title,
    this.isComplete = false,
    this.lastEditedBy,
    this.lastEditedAt,
  });

  final String id;
  String title;
  bool isComplete;
  String? lastEditedBy;
  DateTime? lastEditedAt;
}

class ActivityEntry {
  ActivityEntry({
    required this.actor,
    required this.summary,
    required this.timestamp,
  });

  final String actor;
  final String summary;
  final DateTime timestamp;
}

class TaskList {
  TaskList({
    required this.id,
    required this.title,
    required this.description,
    required this.items,
    this.isArchived = false,
    List<ActivityEntry>? activity,
    List<String>? chatMessages,
    this.completedAt,
    this.completedBy,
  }) : activity = activity ?? <ActivityEntry>[],
       chatMessages = chatMessages ?? <String>[];

  final String id;
  String title;
  String description;
  final List<ChecklistItem> items;
  bool isArchived;
  final List<ActivityEntry> activity;
  List<String> chatMessages;
  DateTime? completedAt;
  String? completedBy;

  int get completedItemCount =>
      items.where((ChecklistItem e) => e.isComplete).length;

  void logActivity(String actor, String summary) {
    activity.insert(
      0,
      ActivityEntry(actor: actor, summary: summary, timestamp: DateTime.now()),
    );
    if (activity.length > 30) {
      activity.removeRange(30, activity.length);
    }
  }
}
