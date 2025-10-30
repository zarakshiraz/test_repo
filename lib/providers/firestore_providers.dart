import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../models/collaboration_list.dart';
import '../models/list_item.dart';
import '../models/participant.dart';
import '../models/activity.dart';
import '../models/chat_message.dart';
import 'auth_provider.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final listsProvider = StreamProvider<List<CollaborationList>>((ref) {
  final auth = ref.watch(authProvider);
  final service = ref.watch(firestoreServiceProvider);
  return service.getLists(auth.userId);
});

final currentListIdProvider = StateProvider<String?>((ref) => null);

final currentListProvider = StreamProvider<CollaborationList?>((ref) {
  final listId = ref.watch(currentListIdProvider);
  if (listId == null) return Stream.value(null);
  
  final service = ref.watch(firestoreServiceProvider);
  return service.getList(listId);
});

final listItemsProvider = StreamProvider<List<ListItem>>((ref) {
  final listId = ref.watch(currentListIdProvider);
  if (listId == null) return Stream.value([]);
  
  final service = ref.watch(firestoreServiceProvider);
  return service.getListItems(listId);
});

final participantsProvider = StreamProvider<List<Participant>>((ref) {
  final listId = ref.watch(currentListIdProvider);
  if (listId == null) return Stream.value([]);
  
  final service = ref.watch(firestoreServiceProvider);
  return service.getParticipants(listId);
});

final activitiesProvider = StreamProvider<List<Activity>>((ref) {
  final listId = ref.watch(currentListIdProvider);
  if (listId == null) return Stream.value([]);
  
  final service = ref.watch(firestoreServiceProvider);
  return service.getActivities(listId);
});

final chatMessagesProvider = StreamProvider<List<ChatMessage>>((ref) {
  final listId = ref.watch(currentListIdProvider);
  if (listId == null) return Stream.value([]);
  
  final service = ref.watch(firestoreServiceProvider);
  return service.getChatMessages(listId);
});
