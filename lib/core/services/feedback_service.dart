import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';

final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  return FeedbackService();
});

class FeedbackService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  Timer? _vibrationTimer;

  FeedbackService() {
    _init();
  }

  Future<void> _init() async {
    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5); // Slower for countdown
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      _isInitialized = true;
    } catch (e) {
      print("FeedbackService: Error initializing TTS: $e");
    }
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) await _init();
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print("FeedbackService: Error speaking: $e");
    }
  }

  Future<void> vibrate() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(pattern: [0, 500, 200, 500]); // Wait 0, Vibrate 500, Wait 200, Vibrate 500
      }
    } catch (e) {
      print("FeedbackService: Error vibrating: $e");
    }
  }

  Future<void> startCompletionFeedback() async {
    stop(); // Ensure any existing feedback is stopped
    
    // Speak immediately
    await speak("Session Complete");

    // Start vibration loop (10 seconds)
    if (await Vibration.hasVibrator() ?? false) {
      // Initial vibration
      Vibration.vibrate(pattern: [0, 1000, 500, 1000, 500, 1000]); // 3 long pulses
      
      // Repeat every 4 seconds for up to 12 seconds total
      int count = 0;
      _vibrationTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
        count++;
        if (count >= 3) { // Stop after ~12 seconds
          timer.cancel();
        } else {
          Vibration.vibrate(pattern: [0, 1000, 500, 1000, 500, 1000]);
        }
      });
    }
  }

  void stop() {
    _vibrationTimer?.cancel();
    _vibrationTimer = null;
    Vibration.cancel();
    _flutterTts.stop();
  }
}
