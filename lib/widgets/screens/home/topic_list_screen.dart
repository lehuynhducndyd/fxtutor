import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/models/user_model.dart';
import 'package:fx_tutor/services/learning_content_service.dart';
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
    return const _Body(); // Thêm const cho tối ưu
  }
}

// Chuyển _Body thành StatefulWidget để quản lý thanh tìm kiếm cục bộ
class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  String _searchQuery = ''; // Biến lưu từ khóa tìm kiếm

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

        // 3. Trạng thái trống hoàn toàn (Chưa có dữ liệu nào trên Database)
        if (state.listTopic.isEmpty) {
          return const Center(
            child: Text(
              "Chưa có chủ đề nào được cập nhật.",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        // ================= LỌC DANH SÁCH THEO TỪ KHÓA =================
        final filteredTopics = state.listTopic.where((topic) {
          final query = _searchQuery.toLowerCase();
          final titleMatch = topic.title.toLowerCase().contains(query);
          final descMatch = topic.description.toLowerCase().contains(query);
          return titleMatch || descMatch; // Tìm theo cả tiêu đề và mô tả
        }).toList();

        return Column(
          children: [
            // ================= THANH TÌM KIẾM =================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm chủ đề...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            // ================= DANH SÁCH HIỂN THỊ =================
            Expanded(
              child: filteredTopics.isEmpty
                  ? const Center(
                      child: Text(
                        "Không tìm thấy chủ đề nào phù hợp.",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        context.read<TopicCubit>().loadTopics();
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: filteredTopics.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final topic = filteredTopics[index];
                          // QUAN TRỌNG: Tìm đúng index gốc để truyền sang màn hình sau
                          final originalIndex = state.listTopic.indexOf(topic);

                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                // Set chủ đề đang chọn (dùng originalIndex)
                                context.read<TopicCubit>().setSelectedIdx(originalIndex);

                                // Chuyển sang màn hình danh sách bài học
                                Navigator.pushNamed(
                                  context,
                                  LearningListScreen.route,
                                  arguments: {'cubit': context.read<TopicCubit>()},
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    // Icon trang trí
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
                                          const SizedBox(height: 4),
                                          if (topic.userId != null && topic.userId!.isNotEmpty)
                                            FutureBuilder<UserModel?>(
                                              future: context.read<LearningService>().getUserById(
                                                topic.userId!,
                                              ),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData && snapshot.data != null) {
                                                  return Text(
                                                    "Người tạo: ${snapshot.data!.fullName ?? snapshot.data!.email ?? 'Ẩn danh'}",
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.blueGrey,
                                                    ),
                                                  );
                                                }
                                                return const SizedBox.shrink();
                                              },
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
                    ),
            ),
          ],
        );
      },
    );
  }
}
