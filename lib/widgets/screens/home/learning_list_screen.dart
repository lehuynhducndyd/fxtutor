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
              centerTitle: true,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<LearningCubit, LearningState>(
      builder: (context, state) {
        // ================= TRẠNG THÁI LOADING =================
        if (state.status == LoadStatus.Loading) {
          return const Center(child: CircularProgressIndicator());
        }

        // ================= TRẠNG THÁI LỖI =================
        if (state.status == LoadStatus.Error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  "Lỗi tải danh sách bài học",
                  style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        // ================= LỌC DANH SÁCH THEO TỪ KHÓA =================
        final filteredContents = state.contents.where((content) {
          return content.title.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        return Column(
          children: [
            // ================= THANH TÌM KIẾM M3 =================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm bài học...',
                  prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        BorderSide.none, // Ẩn viền để thanh tìm kiếm trông phẳng và hiện đại
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.menu_book_outlined, size: 64, color: colorScheme.outline),
                          const SizedBox(height: 16),
                          Text(
                            "Chưa có bài học nào trong chủ đề này",
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : filteredContents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 64, color: colorScheme.outline),
                          const SizedBox(height: 16),
                          Text(
                            "Không tìm thấy bài học nào.",
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: filteredContents.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        // Dùng danh sách đã lọc (filteredContents) thay vì danh sách gốc
                        final content = filteredContents[index];

                        return Card(
                          elevation: 0,
                          color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                LearningListDetailScreen.route,
                                arguments: content,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Icon đã được tinh gọn lại cho giống màn hình Casio QR
                                  const Icon(
                                    Icons.menu_book_rounded,
                                    color: Colors.blueAccent,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 16),
                                  // Tiêu đề bài học
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          content.title,
                                          style: textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Mũi tên điều hướng
                                  Icon(Icons.chevron_right, color: colorScheme.outline),
                                ],
                              ),
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
