import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/contact_request.dart';
import '../../data/models/contact_status.dart';
import '../../data/models/user_contact.dart';
import '../../data/repositories/contacts_repository.dart';

final contactsRepositoryProvider = Provider<ContactsRepository>((ref) {
  return ContactsRepository(firestore: FirebaseFirestore.instance);
});

final userContactsProvider =
    StreamProvider.family<List<UserContact>, String>((ref, userId) {
  final repository = ref.watch(contactsRepositoryProvider);
  return repository.getUserContacts(userId);
});

final contactRequestsProvider =
    StreamProvider.family<List<ContactRequest>, String>((ref, userId) {
  final repository = ref.watch(contactsRepositoryProvider);
  return repository.getContactRequests(userId);
});

final sentContactRequestsProvider =
    StreamProvider.family<List<ContactRequest>, String>((ref, userId) {
  final repository = ref.watch(contactsRepositoryProvider);
  return repository.getSentContactRequests(userId);
});

final acceptedContactsProvider =
    Provider.family<List<UserContact>, String>((ref, userId) {
  final contactsAsync = ref.watch(userContactsProvider(userId));
  return contactsAsync.maybeWhen(
    data: (contacts) => contacts
        .where((contact) => contact.status == ContactStatus.accepted)
        .toList(),
    orElse: () => [],
  );
});

final blockedContactsProvider =
    Provider.family<List<UserContact>, String>((ref, userId) {
  final contactsAsync = ref.watch(userContactsProvider(userId));
  return contactsAsync.maybeWhen(
    data: (contacts) => contacts
        .where((contact) => contact.status == ContactStatus.blocked)
        .toList(),
    orElse: () => [],
  );
});

final pendingRequestCountProvider = Provider.family<int, String>((ref, userId) {
  final requestsAsync = ref.watch(contactRequestsProvider(userId));
  return requestsAsync.maybeWhen(
    data: (requests) => requests.length,
    orElse: () => 0,
  );
});
