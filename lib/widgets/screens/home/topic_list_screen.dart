import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/topic_cubit.dart';

import '../../../../common/enum/load_status.dart';
import '../../../../services/topic_service.dart';
import 'learning_list_screen.dart';

class TopicListScreen extends StatefulWidget {
  const TopicListScreen({super.key});

  static const String route = 'TopicListScreen';

  @override
  State<TopicListScreen> createState() => _TopicListScreenState();
}

class _TopicListScreenState extends State<TopicListScreen> {
  @override
  Widget build(BuildContext context) {
    // Vẫn dùng TopicCubit để load dữ liệu, nhưng chỉ để xem
    return BlocProvider(
      create: (context) => TopicCubit(context.read<TopicService>())..loadTopics(),
      child: const _Page(),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page();

  @override
  Widget build(BuildContext context) {
    return _Body();
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopicCubit, TopicState>(
      builder: (context, state) {
        // 1. Trạng thái đang tải
        if (state.loadStatus == LoadStatus.Loading) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Trạng thái lỗi
        if (state.loadStatus == LoadStatus.Error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text("Không thể tải danh sách chủ đề"),
                TextButton(
                  onPressed: () => context.read<TopicCubit>().loadTopics(),
                  child: const Text("Thử lại"),
                ),
              ],
            ),
          );
        }

        // 3. Trạng thái trống (Không có dữ liệu)
        if (state.listTopic.isEmpty) {
          return const Center(
            child: Text(
              "Chưa có chủ đề nào được cập nhật.",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        // 4. Hiển thị danh sách
        return RefreshIndicator(
          onRefresh: () async {
            context.read<TopicCubit>().loadTopics();
          },
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            itemCount: state.listTopic.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final topic = state.listTopic[index];

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    // Set chủ đề đang chọn vào Cubit (nếu logic bên trong LearningContentScreen cần)
                    context.read<TopicCubit>().setSelectedIdx(index);

                    // Chuyển sang màn hình danh sách bài học
                    Navigator.pushNamed(
                      context,
                      LearningListScreen.route,
                      // Truyền Cubit hiện tại sang màn hình con để dùng chung dữ liệu/state
                      arguments: {'cubit': context.read<TopicCubit>()},
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Icon trang trí cho sinh động
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.menu_book, color: Colors.blue),
                        ),
                        const SizedBox(width: 16),
                        // Nội dung text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                topic.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                topic.description,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Mũi tên chỉ hướng điều hướng
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
