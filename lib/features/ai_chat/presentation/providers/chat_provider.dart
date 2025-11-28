import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/data/isar_service.dart';
import '../../data/datasources/ai_service.dart';
import '../../data/datasources/gemini_service.dart';
import '../../data/models/chat_message.dart';
import '../../../settings/presentation/providers/api_key_provider.dart';

part 'chat_provider.g.dart';

@riverpod
AIService aiService(AiServiceRef ref) {
  final apiKey = ref.watch(apiKeyProvider).value ?? '';
  return GeminiService(apiKey: apiKey);
}

@riverpod
class ChatNotifier extends _$ChatNotifier {
  @override
  Future<List<ChatMessage>> build() async {
    return ref.read(isarServiceProvider).getMessages();
  }

  Future<void> sendMessage(String content) async {
    final isar = ref.read(isarServiceProvider);
    
    // 1. Save User Message
    final userMsg = ChatMessage()
      ..role = 'user'
      ..content = content
      ..timestamp = DateTime.now();
    await isar.saveMessage(userMsg);
    
    // Optimistic update
    state = AsyncValue.data([...state.value ?? [], userMsg]);

    // 2. Generate AI Response
    final aiService = ref.read(aiServiceProvider);
    final aiMsg = ChatMessage()
      ..role = 'ai'
      ..content = '' // Start empty
      ..timestamp = DateTime.now();
    
    // Add placeholder AI message to UI
    final List<ChatMessage> currentMessages = [...state.value ?? [], aiMsg];
    state = AsyncValue.data(currentMessages);

    final stream = aiService.generateResponse(content);
    
    await for (final chunk in stream) {
      aiMsg.content += chunk;
      // Force UI update
      state = AsyncValue.data([...currentMessages]); 
    }

    // 3. Save AI Message
    await isar.saveMessage(aiMsg);
  }

  Future<void> clearChat() async {
    await ref.read(isarServiceProvider).clearChat();
    state = const AsyncValue.data([]);
  }
}
