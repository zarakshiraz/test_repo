import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocli/features/auth/data/user_repository.dart';
import 'package:grocli/core/models/user.dart';

@GenerateMocks([FirebaseFirestore, CollectionReference, DocumentReference, DocumentSnapshot])
import 'user_repository_test.mocks.dart';

void main() {
  late UserRepository repository;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDoc;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDoc = MockDocumentReference<Map<String, dynamic>>();
    repository = UserRepository(firestore: mockFirestore);
  });

  group('UserRepository -', () {
    final testUser = User(
      id: 'test-id',
      email: 'test@example.com',
      displayName: 'Test User',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    test('createUser stores user in Firestore', () async {
      when(mockFirestore.collection('users')).thenReturn(mockCollection);
      when(mockCollection.doc(any)).thenReturn(mockDoc);
      when(mockDoc.set(any)).thenAnswer((_) async => {});

      await repository.createUser(testUser);

      verify(mockFirestore.collection('users')).called(1);
      verify(mockCollection.doc(testUser.id)).called(1);
      verify(mockDoc.set(testUser.toJson())).called(1);
    });

    test('userExists returns true when user exists', () async {
      final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      when(mockFirestore.collection('users')).thenReturn(mockCollection);
      when(mockCollection.doc(any)).thenReturn(mockDoc);
      when(mockDoc.get()).thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.exists).thenReturn(true);

      final exists = await repository.userExists('test-id');

      expect(exists, true);
    });

    test('userExists returns false when user does not exist', () async {
      final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      when(mockFirestore.collection('users')).thenReturn(mockCollection);
      when(mockCollection.doc(any)).thenReturn(mockDoc);
      when(mockDoc.get()).thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.exists).thenReturn(false);

      final exists = await repository.userExists('non-existent-id');

      expect(exists, false);
    });
  });
}
