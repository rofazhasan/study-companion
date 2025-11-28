import '../../../ai_chat/data/datasources/ai_service.dart';

class SummaryService {
  final AIService _aiService;

  SummaryService(this._aiService);

  Stream<String> generateSummary(String content, {
    String tone = 'Standard',
    String length = 'Medium',
    String format = 'Paragraph',
  }) {
    final prompt = '''
You are a helpful AI study assistant. Summarize the following text.

Options:
- Tone: $tone
- Length: $length
- Format: $format

Instructions:
- Capture the main ideas and key details.
- Do not lose important information.
- Follow the requested tone, length, and format strictly.

Text:
$content

Summary:
''';

    return _aiService.generateResponse(prompt);
  }
}
