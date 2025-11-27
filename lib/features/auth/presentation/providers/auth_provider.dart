import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/clerk_service.dart';

part 'auth_provider.g.dart';

class AuthUser {
  final String id;
  final String email;
  final bool emailVerified;

  AuthUser({
    required this.id,
    required this.email,
    required this.emailVerified,
  });
}

@riverpod
class ClerkAuth extends _$ClerkAuth {
  final _clerkService = ClerkService();
  String? _currentSignUpId;
  String? _currentEmail;

  @override
  Future<AuthUser?> build() async {
    // TODO: Implement session persistence
    return null;
  }

  Future<void> signUp(String email, String password) async {
    try {
      final result = await _clerkService.signUp(email, password);
      _currentSignUpId = result['id'];
      _currentEmail = email;
      
      // Email code is automatically sent
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  Future<void> verifyEmailCode(String code) async {
    if (_currentSignUpId == null) {
      throw Exception('No sign up in progress');
    }

    try {
      final result = await _clerkService.verifyEmailCode(_currentSignUpId!, code);
      
      // Extract user info from response
      final userId = result['id'] ?? _currentSignUpId;
      
      state = AsyncValue.data(AuthUser(
        id: userId!,
        email: _currentEmail!,
        emailVerified: true,
      ));
      
      _currentSignUpId = null;
      _currentEmail = null;
    } catch (e) {
      throw Exception('Verification failed: $e');
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      final result = await _clerkService.signIn(email, password);
      
      final userId = result['id'];
      
      state = AsyncValue.data(AuthUser(
        id: userId,
        email: email,
        emailVerified: true,
      ));
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.data(null);
  }

  Future<void> resendVerificationCode() async {
    if (_currentSignUpId == null) {
      throw Exception('No sign up in progress');
    }

    try {
      await _clerkService.prepareEmailVerification(_currentSignUpId!);
    } catch (e) {
      throw Exception('Failed to resend code: $e');
    }
  }
}
