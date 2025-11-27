import 'dart:async';
import 'ai_service.dart';

class MockAIService implements AIService {
  @override
  Stream<String> generateResponse(String prompt) async* {
    await Future.delayed(const Duration(milliseconds: 500));
    yield "I am currently offline. Please download an AI model in Settings to enable smart features.";
  }
}
