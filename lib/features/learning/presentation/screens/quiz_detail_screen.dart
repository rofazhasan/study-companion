import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:study_companion/features/learning/data/models/saved_exam.dart';

class QuizDetailScreen extends StatelessWidget {
  final SavedExam exam;

  const QuizDetailScreen({super.key, required this.exam});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${exam.topic} Details'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: exam.questions.length,
        separatorBuilder: (context, index) => const Gap(24),
        itemBuilder: (context, index) {
          final question = exam.questions[index];
          // SavedExam stores questions as QuizQuestionEmbedded, which might not have 'selectedOptionIndex' directly if not stored.
          // Wait, SavedExam doesn't store the user's selected answer index per question in the current model?
          // Let's check SavedExam model.
          
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Q${index + 1}: ',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Expanded(
                        child: _buildQuestionContent(
                          question.question,
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                  ...List.generate(question.options.length, (optIndex) {
                    final isCorrect = optIndex == question.correctIndex;
                    // We don't have the user's selected answer in the current SavedExam model?
                    // I need to check the model. If it's missing, I can't show what they picked, only the correct answer.
                    // But for now, I'll show the options and highlight the correct one.
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.transparent,
                        border: Border.all(
                          color: isCorrect ? Colors.green : Colors.grey.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isCorrect ? Icons.check_circle : Icons.circle_outlined,
                            size: 20,
                            color: isCorrect ? Colors.green : Colors.grey,
                          ),
                          const Gap(12),
                          Expanded(
                            child: _buildQuestionContent(
                              question.options[optIndex],
                              fontSize: 14,
                              color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Gap(12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lightbulb, size: 16, color: Colors.amber),
                            Gap(8),
                            Text('Explanation', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                          ],
                        ),
                        const Gap(8),
                        _buildQuestionContent(
                          question.explanation,
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestionContent(String text, {double fontSize = 18, Color color = Colors.black, TextAlign textAlign = TextAlign.start}) {
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
