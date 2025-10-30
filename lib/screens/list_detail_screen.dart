import 'package:flutter/material.dart';
import '../models/todo_list.dart';
import '../models/list_item.dart';
import '../repositories/list_repository.dart';
import '../services/contact_service.dart';
import '../services/notification_service.dart';
import '../constants/permissions.dart';
import '../widgets/share_dialog.dart';
import '../widgets/participants_sheet.dart';

class ListDetailScreen extends StatefulWidget {
  final TodoList list;
  final ListRepository repository;
  final ContactService contactService;
  final NotificationService notificationService;
  final String currentUserId;
  final String currentUserName;

  const ListDetailScreen({
    super.key,
    required this.list,
    required this.repository,
    required this.contactService,
    required this.notificationService,
    required this.currentUserId,
    required this.currentUserName,
  });

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  final _itemController = TextEditingController();
  PermissionRole? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  Future<void> _loadUserRole() async {
    final role = await widget.repository.getUserRole(widget.list.id);
    setState(() {
      _userRole = role;
    });
  }

  Future<void> _addItem() async {
    if (_itemController.text.trim().isEmpty) return;

    try {
      await widget.repository.addItem(widget.list.id, _itemController.text.trim());
      _itemController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _toggleItem(ListItem item) async {
    try {
      await widget.repository.updateItem(
        widget.list.id,
        item.id,
        isCompleted: !item.isCompleted,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteItem(String itemId) async {
    try {
      await widget.repository.deleteItem(widget.list.id, itemId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _showShareDialog() async {
    final contacts = await widget.contactService.getContacts(widget.currentUserId);

    if (!mounted) return;

    final participants = await widget.repository
        .getParticipants(widget.list.id)
        .first;

    if (!mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (context) => ShareDialog(
        contacts: contacts,
        currentParticipants: participants,
        onShare: (newParticipants) async {
          try {
            await widget.repository.addParticipants(widget.list.id, newParticipants);

            for (final participant in newParticipants) {
              await widget.notificationService.notifyListShared(
                userId: participant.userId,
                listTitle: widget.list.title,
                sharedByName: widget.currentUserName,
                role: participant.role,
                listId: widget.list.id,
              );
            }

            scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text('List shared successfully')),
            );
          } catch (e) {
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text('Error: ${e.toString()}')),
            );
          }
        },
      ),
    );
  }

  Future<void> _showParticipantsSheet() async {
    final participants = await widget.repository
        .getParticipants(widget.list.id)
        .first;

    if (!mounted) return;

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ParticipantsSheet(
        participants: participants,
        ownerId: widget.list.ownerId,
        currentUserRole: _userRole ?? PermissionRole.viewer,
        onRoleChange: (participant, newRole) async {
          try {
            await widget.repository.updateParticipantRole(
              widget.list.id,
              participant.userId,
              newRole,
            );

            await widget.notificationService.notifyPermissionChanged(
              userId: participant.userId,
              listTitle: widget.list.title,
              changedByName: widget.currentUserName,
              newRole: newRole,
              listId: widget.list.id,
            );

            navigator.pop();
            scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text('Permission updated')),
            );
          } catch (e) {
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text('Error: ${e.toString()}')),
            );
          }
        },
        onRemove: (participant) async {
          try {
            await widget.repository.removeParticipant(
              widget.list.id,
              participant.userId,
            );

            navigator.pop();
            scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text('Participant removed')),
            );
          } catch (e) {
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text('Error: ${e.toString()}')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.list.title),
        actions: [
          if (widget.list.isShared)
            IconButton(
              icon: Badge(
                label: Text('${widget.list.participantCount}'),
                child: const Icon(Icons.people),
              ),
              onPressed: _showParticipantsSheet,
              tooltip: 'View participants',
            ),
          if (_userRole?.canShare ?? false)
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: _showShareDialog,
              tooltip: 'Share list',
            ),
        ],
      ),
      body: Column(
        children: [
          if (_userRole?.canEdit ?? false)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _itemController,
                      decoration: const InputDecoration(
                        hintText: 'Add a new item',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _addItem(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addItem,
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<List<ListItem>>(
              stream: widget.repository.getListItems(widget.list.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final items = snapshot.data ?? [];

                if (items.isEmpty) {
                  return const Center(
                    child: Text('No items yet. Add one to get started!'),
                  );
                }

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      leading: Checkbox(
                        value: item.isCompleted,
                        onChanged: (_userRole?.canEdit ?? false)
                            ? (_) => _toggleItem(item)
                            : null,
                      ),
                      title: Text(
                        item.title,
                        style: item.isCompleted
                            ? const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                      trailing: (_userRole?.canEdit ?? false)
                          ? IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.red,
                              onPressed: () => _deleteItem(item.id),
                            )
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
