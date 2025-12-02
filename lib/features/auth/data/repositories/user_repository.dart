import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../settings/data/models/user.dart';

part 'user_repository.g.dart';

@riverpod
UserRepository userRepository(UserRepositoryRef ref) {
  return UserRepository(FirebaseFirestore.instance, auth.FirebaseAuth.instance);
}

class UserRepository {
  final FirebaseFirestore _firestore;
  final auth.FirebaseAuth _auth;

  UserRepository(this._firestore, this._auth);

  Future<void> saveUserToFirestore(User user, String uid) async {
    try {
      print('Saving user to Firestore: $uid, email: ${user.email}');
      await _firestore.collection('users').doc(uid).set({
        'name': user.name,
        'grade': user.grade,
        'schoolName': user.schoolName,
        'email': user.email,
        'createdAt': user.createdAt.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
      print('User saved to Firestore successfully');
    } catch (e) {
      print('Error saving user to Firestore: $e');
      throw Exception('Failed to save user profile to cloud: $e');
    }
  }

  Future<User?> fetchUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return User()
          ..name = data['name'] ?? ''
          ..grade = data['grade'] ?? ''
          ..schoolName = data['schoolName']
          ..email = data['email'] ?? ''
          ..createdAt = DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user profile from cloud: $e');
    }
  }

  Future<void> updateUserEmail(String newEmail) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      await user.verifyBeforeUpdateEmail(newEmail);
    } catch (e) {
      throw Exception('Failed to initiate email update: $e');
    }
  }
}
