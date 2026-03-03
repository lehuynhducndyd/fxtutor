import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/common/enum/load_status.dart';
import 'package:fx_tutor/services/ai_chat_service.dart';
import 'package:fx_tutor/widgets/screens/ai_chat/ai_chat_cubit.dart';
import 'package:fx_tutor/widgets/screens/ai_chat/ai_chat_state.dart';
import 'package:quick_quiz/quick_quiz.dart';

import '../../../models/learning_content.dart';

// 1. CHUYỂN THÀNH STATEFUL WIDGET
class QuizScreen extends StatefulWidget {
  static const String route = 'QuizScreen';
  final LearningContent content;

  const QuizScreen({super.key, required this.content});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

// 2. THÊM MIXIN ĐỂ GIỮ TRẠNG THÁI KHÔNG BỊ HỦY KHI CHUYỂN TAB
class _QuizScreenState extends State<QuizScreen> with AutomaticKeepAliveClientMixin {
  // 3. BIẾN CACHE ĐỂ LƯU TRỮ BÀI TRẮC NGHIỆM
  Quiz? _cachedQuiz;

  @override
  bool get wantKeepAlive => true; // Xác nhận muốn giữ trạng thái

  @override
  Widget build(BuildContext context) {
    super.build(context); // Bắt buộc phải gọi dòng này khi dùng KeepAlive

    return BlocProvider(
      create: (context) => AiChatCubit(context.read<AiChatService>())..generateQuiz(widget.content),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Trắc nghiệm: ${widget.content.title}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: BlocBuilder<AiChatCubit, AiChatState>(
          builder: (context, state) {
            final colorScheme = Theme.of(context).colorScheme;
            final textTheme = Theme.of(context).textTheme;

            // ================= TRẠNG THÁI LOADING =================
            if (state.status == LoadStatus.Loading) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          size: 48,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const CircularProgressIndicator(),
                      const SizedBox(height: 24),
                      Text(
                        "AI đang phân tích và tạo trắc nghiệm...",
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Bạn sẽ có 5 phút để hoàn thành 5 câu hỏi.\nVui lòng đợi giây lát!",
                        style: TextStyle(color: colorScheme.onSurfaceVariant, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            // ================= TRẠNG THÁI LỖI =================
            if (state.status == LoadStatus.Error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded, size: 64, color: colorScheme.error),
                      const SizedBox(height: 16),
                      Text(
                        "Rất tiếc, đã có lỗi xảy ra",
                        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.errorMessage ??
                            "Lỗi khi tạo trắc nghiệm. Máy chủ AI có thể đang quá tải.",
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () {
                          setState(() => _cachedQuiz = null); // Reset lại cache nếu thử lại
                          context.read<AiChatCubit>().generateQuiz(widget.content);
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text("Tạo lại trắc nghiệm"),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ================= TRẠNG THÁI THÀNH CÔNG =================
            if (state.quiz != null && state.quiz!.isNotEmpty) {
              // 4. CHỈ KHỞI TẠO QUIZ 1 LẦN DUY NHẤT VÀ LƯU VÀO CACHE
              if (_cachedQuiz == null) {
                _cachedQuiz = Quiz(
                  questions: state.quiz!
                      .map(
                        (q) => QuestionModel(
                          question: q.question,
                          options: q.options,
                          correctAnswerIndex: q.correctAnswerIndex,
                          explanation: q.explanation,
                        ),
                      )
                      .toList(),
                  timerDuration: 300,
                );
              }

              // Truyền đối tượng đã cache vào QuizPage
              return QuizPage(quiz: _cachedQuiz!);
            }

            // ================= TRẠNG THÁI TRỐNG =================
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_outlined, size: 64, color: colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    "Không có dữ liệu trắc nghiệm.",
                    style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
