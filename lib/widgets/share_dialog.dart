import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../models/participant.dart';
import '../constants/permissions.dart';

class ShareDialog extends StatefulWidget {
  final List<Contact> contacts;
  final List<Participant> currentParticipants;
  final Function(List<Participant>) onShare;

  const ShareDialog({
    super.key,
    required this.contacts,
    required this.currentParticipants,
    required this.onShare,
  });

  @override
  State<ShareDialog> createState() => _ShareDialogState();
}

class _ShareDialogState extends State<ShareDialog> {
  final Map<String, PermissionRole> _selectedContacts = {};

  @override
  void initState() {
    super.initState();
    for (final participant in widget.currentParticipants) {
      _selectedContacts[participant.userId] = participant.role;
    }
  }

  List<Contact> get availableContacts {
    final participantIds = widget.currentParticipants.map((p) => p.userId).toSet();
    return widget.contacts.where((c) => !participantIds.contains(c.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Share List',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: availableContacts.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No contacts available to share with'),
                      ),
                    )
                  : ListView.builder(
                      itemCount: availableContacts.length,
                      itemBuilder: (context, index) {
                        final contact = availableContacts[index];
                        final isSelected = _selectedContacts.containsKey(contact.id);
                        final role = _selectedContacts[contact.id] ?? PermissionRole.viewer;

                        return ListTile(
                          leading: Checkbox(
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedContacts[contact.id] = PermissionRole.viewer;
                                } else {
                                  _selectedContacts.remove(contact.id);
                                }
                              });
                            },
                          ),
                          title: Text(contact.name),
                          subtitle: Text(contact.email),
                          trailing: isSelected
                              ? DropdownButton<PermissionRole>(
                                  value: role,
                                  onChanged: (newRole) {
                                    if (newRole != null) {
                                      setState(() {
                                        _selectedContacts[contact.id] = newRole;
                                      });
                                    }
                                  },
                                  items: [
                                    DropdownMenuItem(
                                      value: PermissionRole.viewer,
                                      child: Text(PermissionRole.viewer.displayName),
                                    ),
                                    DropdownMenuItem(
                                      value: PermissionRole.editor,
                                      child: Text(PermissionRole.editor.displayName),
                                    ),
                                  ],
                                )
                              : null,
                        );
                      },
                    ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _selectedContacts.isEmpty
                        ? null
                        : () {
                            final newParticipants = _selectedContacts.entries
                                .where((entry) => !widget.currentParticipants
                                    .any((p) => p.userId == entry.key))
                                .map((entry) {
                              final contact = widget.contacts
                                  .firstWhere((c) => c.id == entry.key);
                              return Participant(
                                userId: contact.id,
                                userName: contact.name,
                                userEmail: contact.email,
                                role: entry.value,
                                addedAt: DateTime.now(),
                              );
                            }).toList();

                            widget.onShare(newParticipants);
                            Navigator.of(context).pop();
                          },
                    child: const Text('Share'),
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
