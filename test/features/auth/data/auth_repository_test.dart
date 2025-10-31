import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:grocli/features/auth/data/auth_repository.dart';

@GenerateMocks([
  firebase_auth.FirebaseAuth,
  firebase_auth.UserCredential,
  firebase_auth.User,
  GoogleSignIn,
])
import 'auth_repository_test.mocks.dart';

void main() {
  late AuthRepository repository;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    repository = AuthRepository(
      firebaseAuth: mockFirebaseAuth,
      googleSignIn: mockGoogleSignIn,
    );
  });

  group('AuthRepository -', () {
    test('signInWithEmailAndPassword succeeds', () async {
      final mockCredential = MockUserCredential();
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockCredential);

      final result = await repository.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, equals(mockCredential));
      verify(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
    });

    test('signInWithEmailAndPassword throws on wrong password', () async {
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(
        firebase_auth.FirebaseAuthException(code: 'wrong-password'),
      );

      expect(
        () => repository.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'wrong',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('createUserWithEmailAndPassword succeeds', () async {
      final mockCredential = MockUserCredential();
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockCredential);

      final result = await repository.createUserWithEmailAndPassword(
        email: 'new@example.com',
        password: 'password123',
      );

      expect(result, equals(mockCredential));
      verify(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: 'new@example.com',
        password: 'password123',
      )).called(1);
    });

    test('sendPasswordResetEmail succeeds', () async {
      when(mockFirebaseAuth.sendPasswordResetEmail(
        email: anyNamed('email'),
      )).thenAnswer((_) async => {});

      await repository.sendPasswordResetEmail('test@example.com');

      verify(mockFirebaseAuth.sendPasswordResetEmail(
        email: 'test@example.com',
      )).called(1);
    });

    test('signOut succeeds', () async {
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async => {});
      when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

      await repository.signOut();

      verify(mockFirebaseAuth.signOut()).called(1);
      verify(mockGoogleSignIn.signOut()).called(1);
    });
  });
}
