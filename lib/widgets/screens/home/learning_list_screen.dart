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

// Chuyển đổi sang StatefulWidget để quản lý trạng thái thanh tìm kiếm
class LearningListBody extends StatefulWidget {
  const LearningListBody({super.key});

  @override
  State<LearningListBody> createState() => _LearningListBodyState();
}

class _LearningListBodyState extends State<LearningListBody> {
  String _searchQuery = ''; // Biến lưu từ khóa tìm kiếm

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LearningCubit, LearningState>(
      builder: (context, state) {
        if (state.status == LoadStatus.Loading) {
          return const Center(child: CircularProgressIndicator());
        }

        // ================= LỌC DANH SÁCH THEO TỪ KHÓA =================
        final filteredContents = state.contents.where((content) {
          return content.title.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        return Column(
          children: [
            // ================= THANH TÌM KIẾM =================
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm bài học...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
                onChanged: (value) {
                  // Cập nhật lại UI mỗi khi gõ phím
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            // ================= DANH SÁCH HIỂN THỊ =================
            Expanded(
              child: state.contents.isEmpty
                  ? const Center(child: Text("Chưa có bài học nào trong chủ đề này"))
                  : filteredContents.isEmpty
                  ? const Center(child: Text("Không tìm thấy bài học nào."))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filteredContents.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        // Dùng danh sách đã lọc (filteredContents) thay vì danh sách gốc
                        final content = filteredContents[index];
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
                    ),
            ),
          ],
        );
      },
    );
  }
}
