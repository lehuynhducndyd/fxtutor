import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/enum/load_status.dart';
import '../../../services/ai_chat_service.dart';
import 'ai_chat_state.dart';

class AiChatCubit extends Cubit<AiChatState> {
  final AiChatService _service;

  AiChatCubit(this._service) : super(AiChatState.initial());

  Future<void> sendMessage({
    String? text,
    Uint8List? image,
  }) async {
    if (text == null && image == null) return;

    // 1. Thêm tin nhắn của User vào danh sách
    final userMsg = ChatMessage(
      text: text ?? "Đã gửi một ảnh",
      isUser: true,
      image: image,
    );

    final updatedMessages = List<ChatMessage>.from(state.messages)..add(userMsg);
    emit(state.copyWith(status: LoadStatus.Loading, messages: updatedMessages));

    try {
      // 2. Gọi service xử lý (Trong service này Gemini sẽ nhận cả input và thực hiện RAG)
      // Để follow hội thoại, bạn có thể truyền thêm state.messages vào service nếu service hỗ trợ ChatSession
      final aiResponse = await _service.solveAndGuide(
        textInput: text,
        imageBytes: image,
      );

      // 3. Thêm phản hồi của AI
      final aiMsg = ChatMessage(text: aiResponse, isUser: false);
      final finalMessages = List<ChatMessage>.from(state.messages)..add(aiMsg);

      emit(state.copyWith(status: LoadStatus.Done, messages: finalMessages));
    } catch (e) {
      emit(state.copyWith(status: LoadStatus.Error, errorMessage: e.toString()));
    }
  }
}
