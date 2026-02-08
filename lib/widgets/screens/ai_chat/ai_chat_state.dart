import 'dart:typed_data';

import '../../../common/enum/load_status.dart';
import '../../../models/ai_quiz_model.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final Uint8List? image; // Để hiển thị lại ảnh user đã gửi

  ChatMessage({required this.text, required this.isUser, this.image});
}

class AiChatState {
  final List<ChatMessage> messages;
  final List<AiQuizModel>? quiz;
  final LoadStatus status;
  final String? errorMessage;

  AiChatState({
    required this.messages,
    this.quiz,
    required this.status,
    this.errorMessage,
  });

  factory AiChatState.initial() => AiChatState(
        messages: [],
        quiz: null,
        status: LoadStatus.Init,
      );

  AiChatState copyWith({
    List<ChatMessage>? messages,
    List<AiQuizModel>? quiz,
    LoadStatus? status,
    String? errorMessage,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      quiz: quiz ?? this.quiz,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
