import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/contact_status.dart';
import '../providers/contacts_providers.dart';
import '../widgets/contact_list_item.dart';
import 'contact_requests_screen.dart';
import 'add_contact_screen.dart';

class ContactsScreen extends ConsumerWidget {
  final String userId;

  const ContactsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(userContactsProvider(userId));
    final pendingCount = ref.watch(pendingRequestCountProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          if (pendingCount > 0)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ContactRequestsScreen(userId: userId),
                      ),
                    );
                  },
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$pendingCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: contactsAsync.when(
        data: (contacts) {
          final acceptedContacts = contacts
              .where((contact) =>
                  contact.status == ContactStatus.accepted)
              .toList();

          if (acceptedContacts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No contacts yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add contacts to start collaborating',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: acceptedContacts.length,
            itemBuilder: (context, index) {
              final contact = acceptedContacts[index];
              return ContactListItem(
                contact: contact,
                userId: userId,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddContactScreen(userId: userId),
            ),
          );
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
