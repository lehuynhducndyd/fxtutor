import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/models/calculator_guide_model.dart';

import '../../../common/enum/load_status.dart';
import '../../../models/learning_content.dart';
import '../../../services/ai_chat_service.dart';
import 'ai_chat_state.dart';

class AiChatCubit extends Cubit<AiChatState> {
  final AiChatService _service;

  AiChatCubit(this._service) : super(AiChatState.initial());
  Future<CalculatorGuideModel?> getGuide({
    String? textInput,
    Uint8List? imageBytes,
  }) async {
    return _service.getGuide(
      textInput: textInput,
      imageBytes: imageBytes,
    );
  }

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
    Future<CalculatorGuideModel?> getGuide({
      String? textInput,
      Uint8List? imageBytes,
    }) {
      return _service.getGuide(
        textInput: textInput,
        imageBytes: imageBytes,
      );
    }

    final updatedMessages = List<ChatMessage>.from(state.messages)..add(userMsg);
    emit(state.copyWith(status: LoadStatus.Loading, messages: updatedMessages));

    try {
      // 2. Gọi service xử lý (Trong service này Gemini sẽ nhận cả input và thực hiện RAG)
      final aiResponse = await _service.solveAndGuide(
        textInput: text,
        imageBytes: image,
      );
      final guide = await getGuide(
        textInput: text,
        imageBytes: image,
      );

      // 3. Thêm phản hồi của AI
      final aiMsg = ChatMessage(text: aiResponse, isUser: false, guide: guide);
      final finalMessages = List<ChatMessage>.from(state.messages)..add(aiMsg);

      emit(state.copyWith(status: LoadStatus.Done, messages: finalMessages));
    } catch (e) {
      emit(state.copyWith(status: LoadStatus.Error, errorMessage: e.toString()));
    }
  }

  Future<void> generateQuiz(LearningContent content) async {
    emit(state.copyWith(status: LoadStatus.Loading));
    try {
      final quizData = await _service.generateQuiz(content);
      emit(state.copyWith(status: LoadStatus.Done, quiz: quizData));
    } catch (e) {
      emit(state.copyWith(status: LoadStatus.Error, errorMessage: "Lỗi tạo bài tập: $e"));
    }
  }
}
