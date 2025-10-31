import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_provider.dart';
import 'list_provider.dart';
import 'message_provider.dart';
import 'contact_provider.dart';
import 'notification_provider.dart';

final firebaseAuthProvider = Provider<firebase_auth.FirebaseAuth>((ref) {
  return firebase_auth.FirebaseAuth.instance;
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn();
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    googleSignIn: ref.watch(googleSignInProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

final listProvider = ChangeNotifierProvider<ListProvider>((ref) {
  final auth = ref.watch(authProvider);
  return ListProvider(
    firestore: ref.watch(firestoreProvider),
    userId: auth.currentUser?.id ?? '',
  );
});

final messageProvider = ChangeNotifierProvider<MessageProvider>((ref) {
  final auth = ref.watch(authProvider);
  return MessageProvider(
    firestore: ref.watch(firestoreProvider),
    userId: auth.currentUser?.id ?? '',
  );
});

final contactProvider = ChangeNotifierProvider<ContactProvider>((ref) {
  final auth = ref.watch(authProvider);
  return ContactProvider(
    firestore: ref.watch(firestoreProvider),
    userId: auth.currentUser?.id ?? '',
  );
});

final notificationProvider = ChangeNotifierProvider<NotificationProvider>((ref) {
  final auth = ref.watch(authProvider);
  return NotificationProvider(
    firestore: ref.watch(firestoreProvider),
    userId: auth.currentUser?.id ?? '',
  );
});
