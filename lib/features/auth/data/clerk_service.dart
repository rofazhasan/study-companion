import 'dart:convert';
import 'package:http/http.dart' as http;

class ClerkService {
  static const String publishableKey = 'pk_test_ZXhhY3QtdGVybWl0ZS04NS5jbGVyay5hY2NvdW50cy5kZXYk';
  static const String baseUrl = 'https://api.clerk.com/v1';
  
  // Extract domain from publishable key
  static String get frontendApi {
    final decoded = utf8.decode(base64.decode(publishableKey.replaceFirst('pk_test_', '')));
    return decoded; // This gives us the domain
  }

  Future<Map<String, dynamic>> signUp(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('https://$frontendApi/v1/client/sign_ups'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email_address': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Prepare email verification
        final signUpId = data['id'];
        await prepareEmailVerification(signUpId);
        
        return data;
      } else {
        throw Exception('Sign up failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Sign up error: $e');
    }
  }

  Future<void> prepareEmailVerification(String signUpId) async {
    try {
      final response = await http.post(
        Uri.parse('https://$frontendApi/v1/client/sign_ups/$signUpId/prepare_verification'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'strategy': 'email_code',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send verification code: ${response.body}');
      }
    } catch (e) {
      throw Exception('Verification preparation error: $e');
    }
  }

  Future<Map<String, dynamic>> verifyEmailCode(String signUpId, String code) async {
    try {
      final response = await http.post(
        Uri.parse('https://$frontendApi/v1/client/sign_ups/$signUpId/attempt_verification'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'strategy': 'email_code',
          'code': code,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Verification failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Verification error: $e');
    }
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('https://$frontendApi/v1/client/sign_ins'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'identifier': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Sign in failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Sign in error: $e');
    }
  }

  Future<void> signOut(String sessionId) async {
    try {
      await http.post(
        Uri.parse('https://$frontendApi/v1/client/sessions/$sessionId/end'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    } catch (e) {
      throw Exception('Sign out error: $e');
    }
  }
}
