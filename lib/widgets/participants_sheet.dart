import 'package:flutter/material.dart';
import '../models/participant.dart';
import '../constants/permissions.dart';

class ParticipantsSheet extends StatelessWidget {
  final List<Participant> participants;
  final String ownerId;
  final PermissionRole currentUserRole;
  final Function(Participant, PermissionRole) onRoleChange;
  final Function(Participant) onRemove;

  const ParticipantsSheet({
    super.key,
    required this.participants,
    required this.ownerId,
    required this.currentUserRole,
    required this.onRoleChange,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Participants',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: participants.length,
              itemBuilder: (context, index) {
                final participant = participants[index];
                final isOwner = participant.userId == ownerId;
                final canModify = currentUserRole.canShare && !isOwner;

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      participant.userName.isNotEmpty
                          ? participant.userName[0].toUpperCase()
                          : '?',
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(participant.userName),
                      if (isOwner)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Owner',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(participant.userEmail),
                  trailing: canModify
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DropdownButton<PermissionRole>(
                              value: participant.role,
                              onChanged: (newRole) {
                                if (newRole != null) {
                                  onRoleChange(participant, newRole);
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
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              color: Colors.red,
                              onPressed: () => onRemove(participant),
                            ),
                          ],
                        )
                      : Text(participant.role.displayName),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
