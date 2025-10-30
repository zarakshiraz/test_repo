import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_contact.dart';
import '../providers/contacts_providers.dart';

class ContactListItem extends ConsumerWidget {
  final UserContact contact;
  final String userId;

  const ContactListItem({
    super.key,
    required this.contact,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: contact.photoUrl != null
            ? NetworkImage(contact.photoUrl!)
            : null,
        child: contact.photoUrl == null
            ? Text(contact.displayName[0].toUpperCase())
            : null,
      ),
      title: Text(contact.displayName),
      subtitle: contact.email != null ? Text(contact.email!) : null,
      trailing: PopupMenuButton<String>(
        onSelected: (value) async {
          final repository = ref.read(contactsRepositoryProvider);
          
          if (value == 'block') {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Block Contact'),
                content: Text(
                    'Are you sure you want to block ${contact.displayName}?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Block'),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              await repository.blockContact(
                userId: userId,
                contactUserId: contact.contactUserId,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contact blocked')),
                );
              }
            }
          } else if (value == 'remove') {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Remove Contact'),
                content: Text(
                    'Are you sure you want to remove ${contact.displayName}?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Remove'),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              await repository.removeContact(
                userId: userId,
                contactId: contact.id,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contact removed')),
                );
              }
            }
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'block',
            child: Row(
              children: [
                Icon(Icons.block),
                SizedBox(width: 8),
                Text('Block'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'remove',
            child: Row(
              children: [
                Icon(Icons.delete),
                SizedBox(width: 8),
                Text('Remove'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
