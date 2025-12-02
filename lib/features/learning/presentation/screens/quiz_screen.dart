import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:confetti/confetti.dart';
import 'package:study_companion/core/data/isar_service.dart';
import 'package:study_companion/features/learning/data/models/saved_exam.dart';
import 'package:study_companion/features/learning/data/models/quiz_question.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/quiz_provider.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool _answered = false;
  int? _selectedOptionIndex;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _answer(int index, int correctIndex) {
    if (_answered) return;

    setState(() {
      _answered = true;
      _selectedOptionIndex = index;
      if (index == correctIndex) {
        _score++;
        // Small confetti for correct answer? Maybe too distracting.
        // Let's keep confetti for the end.
      }
    });
  }

  void _nextQuestion(int totalQuestions) {
    if (_currentIndex < totalQuestions - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _selectedOptionIndex = null;
      });
    } else {
      _showResultDialog(totalQuestions);
    }
  }

  Future<void> _saveExam(int totalQuestions) async {
    final quizState = ref.read(quizNotifierProvider).value;
    if (quizState == null) return;
    
    final savedExam = SavedExam()
      ..topic = quizState.topic
      ..score = _score
      ..totalQuestions = totalQuestions
      ..date = DateTime.now()
      ..language = quizState.language
      ..questions = quizState.questions.map((q) => QuizQuestionEmbedded()
        ..question = q.question
        ..options = q.options
        ..correctIndex = q.correctIndex
        ..explanation = q.explanation
      ).toList();

    await ref.read(isarServiceProvider).saveExam(savedExam);
  }

  void _showResultDialog(int totalQuestions) {
    if (_score > totalQuestions / 2) {
      _confettiController.play();
    }
    
    _saveExam(totalQuestions);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Stack(
        alignment: Alignment.center,
        children: [
          AlertDialog(
            title: const Text('Quiz Complete!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _score > totalQuestions / 2 ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                  size: 80,
                  color: _score > totalQuestions / 2 ? Colors.amber : Colors.grey,
                ),
                const Gap(16),
                Text(
                  'You scored $_score / $totalQuestions',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const Gap(8),
                Text(
                  _score == totalQuestions
                      ? 'Perfect Score! 🌟'
                      : _score > totalQuestions / 2
                          ? 'Great Job! 👍'
                          : 'Keep Practicing! 💪',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.pop();
                },
                child: const Text('Finish'),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.read(quizNotifierProvider).value;
    final questions = quizState?.questions ?? [];

    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No quiz loaded.')),
      );
    }

    final question = questions[_currentIndex];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text('Question ${_currentIndex + 1}/${questions.length}'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade900,
              Colors.purple.shade800,
              Colors.deepPurple.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress Bar
                LinearPercentIndicator(
                  lineHeight: 8.0,
                  percent: (_currentIndex + 1) / questions.length,
                  backgroundColor: Colors.white24,
                  progressColor: Colors.amber,
                  barRadius: const Radius.circular(4),
                  animation: true,
                  animateFromLastPercent: true,
                ),
                const Gap(32),

                // Question Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _buildQuestionContent(
                      question.question,
                      fontSize: 20,
                      textAlign: TextAlign.center,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Gap(32),

                // Options
                Expanded(
                  child: ListView.separated(
                    itemCount: question.options.length,
                    separatorBuilder: (context, index) => const Gap(16),
                    itemBuilder: (context, index) {
                      final isSelected = _selectedOptionIndex == index;
                      final isCorrect = index == question.correctIndex;
                      
                      Color backgroundColor = Colors.white.withOpacity(0.05);
                      Color borderColor = Colors.white.withOpacity(0.1);
                      IconData? icon;

                      if (_answered) {
                        if (isCorrect) {
                          backgroundColor = Colors.green.withOpacity(0.2);
                          borderColor = Colors.green;
                          icon = Icons.check_circle;
                        } else if (isSelected) {
                          backgroundColor = Colors.red.withOpacity(0.2);
                          borderColor = Colors.red;
                          icon = Icons.cancel;
                        }
                      }

                      return GestureDetector(
                        onTap: () => _answer(index, question.correctIndex),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildQuestionContent(
                                  question.options[index],
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              if (icon != null) ...[
                                const Gap(8),
                                Icon(icon, color: borderColor),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Explanation & Next Button
                if (_answered) ...[
                  const Gap(16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                            Gap(8),
                            Text('Explanation', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Gap(8),
                        _buildQuestionContent(
                          question.explanation,
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ),
                  const Gap(16),
                  FilledButton(
                    onPressed: () => _nextQuestion(questions.length),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _currentIndex < questions.length - 1 ? 'Next Question' : 'Finish Quiz',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionContent(String text, {double fontSize = 18, Color color = Colors.white, TextAlign textAlign = TextAlign.start}) {
    List<Widget> spans = [];
    final regex = RegExp(r'\$(.*?)\$');
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(Text(
          text.substring(lastMatchEnd, match.start),
          style: TextStyle(fontSize: fontSize, color: color),
        ));
      }
      spans.add(Math.tex(
        match.group(1)!,
        textStyle: TextStyle(fontSize: fontSize, color: color),
      ));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(Text(
        text.substring(lastMatchEnd),
        style: TextStyle(fontSize: fontSize, color: color),
      ));
    }

    return Wrap(
      alignment: textAlign == TextAlign.center ? WrapAlignment.center : WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: spans,
    );
  }
}

