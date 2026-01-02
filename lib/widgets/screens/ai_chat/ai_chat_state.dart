import 'dart:typed_data';

import '../../../common/enum/load_status.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final Uint8List? image; // Để hiển thị lại ảnh user đã gửi

  ChatMessage({required this.text, required this.isUser, this.image});
}

class AiChatState {
  final List<ChatMessage> messages;
  final LoadStatus status;
  final String? errorMessage;

  AiChatState({
    required this.messages,
    required this.status,
    this.errorMessage,
  });

  factory AiChatState.initial() => AiChatState(
    messages: [],
    status: LoadStatus.Init,
  );

  AiChatState copyWith({
    List<ChatMessage>? messages,
    LoadStatus? status,
    String? errorMessage,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
