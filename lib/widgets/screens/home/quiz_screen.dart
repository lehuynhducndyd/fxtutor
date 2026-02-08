import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/common/enum/load_status.dart';
import 'package:fx_tutor/services/ai_chat_service.dart';
import 'package:fx_tutor/widgets/screens/ai_chat/ai_chat_cubit.dart';
import 'package:fx_tutor/widgets/screens/ai_chat/ai_chat_state.dart';
import 'package:quick_quiz/quick_quiz.dart';

import '../../../models/learning_content.dart';

class QuizScreen extends StatelessWidget {
  static const String route = 'QuizScreen';
  final LearningContent content;

  const QuizScreen({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AiChatCubit(context.read<AiChatService>())..generateQuiz(content),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Trắc nghiệm: ${content.title}'),
        ),
        body: BlocBuilder<AiChatCubit, AiChatState>(
          builder: (context, state) {
            if (state.status == LoadStatus.Loading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("AI đang tạo câu hỏi trắc nghiệm..."),
                  ],
                ),
              );
            }

            if (state.status == LoadStatus.Error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.errorMessage ?? "Lỗi khi tạo trắc nghiệm"),
                    ElevatedButton(
                      onPressed: () => context.read<AiChatCubit>().generateQuiz(content),
                      child: const Text("Thử lại"),
                    ),
                  ],
                ),
              );
            }

            if (state.quiz != null && state.quiz!.isNotEmpty) {
              final quiz = Quiz(
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

              return QuizPage(quiz: quiz);
            }

            return const Center(child: Text("Không có dữ liệu trắc nghiệm."));
          },
        ),
      ),
    );
  }
}
