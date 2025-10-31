import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user.dart';
import '../data/auth_repository.dart';
import '../data/user_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final authStateChangesProvider = StreamProvider<firebase_auth.User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final currentUserProvider = StreamProvider<User?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  
  return authState.when(
    data: (firebaseUser) {
      if (firebaseUser == null) {
        return Stream.value(null);
      }
      return ref.watch(userRepositoryProvider).watchUser(firebaseUser.uid);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(
    authRepository: ref.watch(authRepositoryProvider),
    userRepository: ref.watch(userRepositoryProvider),
  );
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  AuthController({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository,
        super(const AsyncValue.data(null));

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    });
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final credential = await _authRepository.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final user = User(
          id: credential.user!.uid,
          email: email,
          displayName: displayName,
          phoneNumber: phoneNumber,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _userRepository.createUser(user);
      }
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final credential = await _authRepository.signInWithGoogle();

      if (credential.user != null) {
        final userId = credential.user!.uid;
        final exists = await _userRepository.userExists(userId);

        if (!exists) {
          final user = User(
            id: userId,
            email: credential.user!.email!,
            displayName: credential.user!.displayName ?? 'User',
            photoUrl: credential.user!.photoURL,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await _userRepository.createUser(user);
        }
      }
    });
  }

  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final credential = await _authRepository.signInWithApple();

      if (credential.user != null) {
        final userId = credential.user!.uid;
        final exists = await _userRepository.userExists(userId);

        if (!exists) {
          final user = User(
            id: userId,
            email: credential.user!.email!,
            displayName: credential.user!.displayName ?? 'User',
            photoUrl: credential.user!.photoURL,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await _userRepository.createUser(user);
        }
      }
    });
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authRepository.sendPasswordResetEmail(email);
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authRepository.signOut();
    });
  }

  void resetState() {
    state = const AsyncValue.data(null);
  }
}
