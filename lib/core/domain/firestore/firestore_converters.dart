import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../models/contact.dart';
import '../models/list_summary.dart';
import '../models/list_item.dart';
import '../models/list_activity.dart';
import '../models/template.dart';
import '../models/message.dart';
import '../models/reminder.dart';

/// Firestore converters for domain models.
/// These converters integrate with Firestore's withConverter() method
/// to provide type-safe document operations.
///
/// Note: Firestore converters are provided as extension methods below.
/// Use them with collection.withConverter() pattern.

/// Helper extension for CollectionReference to easily apply converters
extension CollectionReferenceExtensions on CollectionReference<Map<String, dynamic>> {
  CollectionReference<UserProfile> withUserProfileConverter() =>
      withConverter<UserProfile>(
        fromFirestore: UserProfile.fromFirestore,
        toFirestore: (userProfile, _) => userProfile.toFirestore(),
      );

  CollectionReference<Contact> withContactConverter() =>
      withConverter<Contact>(
        fromFirestore: Contact.fromFirestore,
        toFirestore: (contact, _) => contact.toFirestore(),
      );

  CollectionReference<ListSummary> withListSummaryConverter() =>
      withConverter<ListSummary>(
        fromFirestore: ListSummary.fromFirestore,
        toFirestore: (listSummary, _) => listSummary.toFirestore(),
      );

  CollectionReference<ListItem> withListItemConverter() =>
      withConverter<ListItem>(
        fromFirestore: ListItem.fromFirestore,
        toFirestore: (listItem, _) => listItem.toFirestore(),
      );

  CollectionReference<ListActivity> withListActivityConverter() =>
      withConverter<ListActivity>(
        fromFirestore: ListActivity.fromFirestore,
        toFirestore: (listActivity, _) => listActivity.toFirestore(),
      );

  CollectionReference<Template> withTemplateConverter() =>
      withConverter<Template>(
        fromFirestore: Template.fromFirestore,
        toFirestore: (template, _) => template.toFirestore(),
      );

  CollectionReference<Message> withMessageConverter() =>
      withConverter<Message>(
        fromFirestore: Message.fromFirestore,
        toFirestore: (message, _) => message.toFirestore(),
      );

  CollectionReference<Reminder> withReminderConverter() =>
      withConverter<Reminder>(
        fromFirestore: Reminder.fromFirestore,
        toFirestore: (reminder, _) => reminder.toFirestore(),
      );
}
