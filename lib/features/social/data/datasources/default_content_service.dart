import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../features/ai_chat/data/datasources/ai_service.dart'; // For QuizQuestion model if reused? Or just map it.
// Actually we need the QuizQuestion model or similar structure.
// Let's use the one from AIService or define a simple DTO here.
// Maybe not best fit.
// Let's reuse the QuizQuestion from existing code or make a local struct.
// The BattleRepository expects `List<QuizQuestion>` from AIService.
// Let's check AIService return type. It returns `List<QuizQuestion>`.
// So we should return the same.

import 'offline_questions_data.dart';

part 'default_content_service.g.dart';

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctIndex: json['correctIndex'] as int,
      explanation: json['explanation'] as String? ?? '',
    );
  }
}

@Riverpod(keepAlive: true)
DefaultContentService defaultContentService(DefaultContentServiceRef ref) {
  return DefaultContentService();
}

class DefaultContentService {
  static const String _fileName = 'offline_battle_data.json';

  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$_fileName';
  }

  Future<bool> isDataAvailable() async {
    final path = await _getFilePath();
    final exists = await File(path).exists();
    print('DefaultContentService: Checking path: $path, Exists: $exists');
    return exists;
  }

  Future<void> downloadData({Function(double)? onProgress}) async {
    print('DefaultContentService: downloadData called');
    // SIMULATED DOWNLOAD: Write a static JSON string to the file.
    // In a real app, this would fetch from a URL.
    
    // Simulate progress behavior
    for (int i = 0; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 500)); // Slower for visibility
      if (onProgress != null) {
        onProgress(i / 10.0);
      }
    }
    
    // Use the massive dataset defined in separate file
    final data = OfflineQuestionsData.data;

    final path = await _getFilePath();
    final file = File(path);
    print('DefaultContentService: Writing to path: $path');
    await file.writeAsString(jsonEncode(data), flush: true);
    print('DefaultContentService: Write complete. Exists? ${await file.exists()}');
  }

  Future<List<QuizQuestion>> getQuestions({
    required String topic,
    required String language,
    required int count,
  }) async {
    final path = await _getFilePath();
    final file = File(path);
    
    if (!await file.exists()) {
      return [];
    }

    try {
      final jsonString = await file.readAsString();
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      final List<dynamic> allQuestions = jsonData['questions'] ?? [];

      // Filter
      final filtered = allQuestions.where((q) {
        final qTopic = (q['topic'] as String).toLowerCase();
        final qLang = (q['language'] as String).toLowerCase();
        final reqTopic = topic.toLowerCase();
        final reqLang = language.toLowerCase();
        
        // Loose matching for topic
        bool topicMatch = qTopic == reqTopic || reqTopic.contains(qTopic) || qTopic.contains(reqTopic);
        // Special case: if topic is "General" or "Any", take all
        if (reqTopic == "general" || reqTopic == "any") topicMatch = true;

        return topicMatch && qLang == reqLang;
      }).toList();

      if (filtered.isEmpty) {
        // Fallback: If strict topic match fails, try finding ANY questions in that language
        // to avoid empty return if possible, or just return empty.
        // User asked for specific topic, so maybe empty is correct.
        // But for "General Knowledge", let's be flexible.
         final fallback = allQuestions.where((q) {
             return (q['language'] as String).toLowerCase() == language.toLowerCase();
         }).toList();
         
         if (fallback.isNotEmpty) {
             fallback.shuffle();
             return fallback.take(count).map((q) => QuizQuestion.fromJson(q)).toList();
         }
         return [];
      }

      // Randomize
      filtered.shuffle(Random());
      
      // Select
      final selected = filtered.take(count).toList();
      
      return selected.map((q) => QuizQuestion.fromJson(q)).toList();
      
    } catch (e) {
      print('Error reading/parsing offline data: $e');
      return [];
    }
  }
}
