import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/data/isar_service.dart';
import '../../data/models/user.dart';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../../auth/data/repositories/user_repository.dart';

part 'user_provider.g.dart';

@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  Future<User?> build() async {
    return ref.read(isarServiceProvider).getUser();
  }

  Future<void> saveUser({
    required String name,
    required String grade,
    required String email,
    String? schoolName,
  }) async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    final actualEmail = currentUser?.email ?? email;

    final user = User()
      ..name = name
      ..grade = grade
      ..email = actualEmail
      ..schoolName = schoolName;
    
    // Save locally
    await ref.read(isarServiceProvider).saveUser(user);
    
    // Save to Firestore if logged in
    if (currentUser != null) {
      await ref.read(userRepositoryProvider).saveUserToFirestore(user, currentUser.uid);
    }

    state = AsyncValue.data(user);
  }

  Future<void> updateUser(User user) async {
    print('UserNotifier: Updating user... ${user.email}');
    // Save locally
    await ref.read(isarServiceProvider).updateUser(user);

    // Save to Firestore if logged in
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await ref.read(userRepositoryProvider).saveUserToFirestore(user, currentUser.uid);
    }

    state = AsyncValue.data(user);
  }

  Future<bool> syncUserFromFirestore(String uid) async {
    try {
      print('Syncing user from Firestore: $uid');
      final remoteUser = await ref.read(userRepositoryProvider).fetchUserFromFirestore(uid);
      if (remoteUser != null) {
        print('User found in Firestore: ${remoteUser.email}');
        await ref.read(isarServiceProvider).saveUser(remoteUser);
        state = AsyncValue.data(remoteUser);
        return true;
      }
      print('User not found in Firestore');
      return false;
    } catch (e) {
      print('Sync failed: $e');
      // If sync fails, we rely on local data or return false
      return false;
    }
  }
}
