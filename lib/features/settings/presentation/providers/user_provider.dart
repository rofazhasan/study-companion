import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/data/isar_service.dart';
import '../../data/models/user.dart';

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
    final user = User()
      ..name = name
      ..grade = grade
      ..email = email
      ..schoolName = schoolName;
    
    await ref.read(isarServiceProvider).saveUser(user);
    state = AsyncValue.data(user);
  }

  Future<void> updateUser(User user) async {
    await ref.read(isarServiceProvider).updateUser(user);
    state = AsyncValue.data(user);
  }
}
