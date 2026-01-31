import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/common/enum/load_status.dart';
import 'package:fx_tutor/services/learning_content_service.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/learning_content_cubit.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/learning_content_state.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/topic_cubit.dart';
import 'package:fx_tutor/widgets/screens/home/learning_list_detail_screen.dart';

class LearningListScreen extends StatelessWidget {
  const LearningListScreen({super.key});

  static const String route = 'LearningListScreen';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopicCubit, TopicState>(
      builder: (context, topicState) {
        if (topicState.listTopic.isEmpty) {
          return const Scaffold(body: Center(child: Text("Không có dữ liệu")));
        }
        final currentTopic = topicState.listTopic[topicState.selectedIdx];

        return BlocProvider(
          create: (context) =>
              LearningCubit(context.read<LearningService>())..loadContents(currentTopic.id),
          child: Scaffold(
            appBar: AppBar(
              title: Text(currentTopic.title),
              elevation: 0,
            ),
            body: const LearningListBody(),
          ),
        );
      },
    );
  }
}

class LearningListBody extends StatelessWidget {
  const LearningListBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LearningCubit, LearningState>(
      builder: (context, state) {
        if (state.status == LoadStatus.Loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.contents.isEmpty) {
          return const Center(child: Text("Chưa có bài học nào trong chủ đề này"));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: state.contents.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final content = state.contents[index];
            return InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  LearningListDetailScreen.route,
                  arguments: content,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.menu_book_rounded, color: Colors.blue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            content.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
