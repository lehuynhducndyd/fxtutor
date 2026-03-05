import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/common/enum/load_status.dart';
import 'package:fx_tutor/models/topic_model.dart';
import 'package:fx_tutor/services/learning_content_service.dart';
import 'package:fx_tutor/widgets/common_widgets/noti_bar.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/add_learning_content_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/learning_content_cubit.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/learning_content_state.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/learning_detail_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/topic_cubit.dart';

class LearningContentScreen extends StatefulWidget {
  const LearningContentScreen({super.key});

  static const String route = 'LearningContentScreen';

  @override
  State<LearningContentScreen> createState() => _LearningContentScreenState();
}

class _LearningContentScreenState extends State<LearningContentScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopicCubit, TopicState>(
      builder: (topicContext, topicState) {
        if (topicState.listTopic.isEmpty) {
          return const Scaffold(
            body: Center(child: Text("Không có chủ đề nào")),
          );
        }
        TopicModel currentTopic = topicState.listTopic[topicState.selectedIdx];

        return BlocProvider(
          create: (context) =>
              LearningCubit(context.read<LearningService>())..loadContents(currentTopic.id),
          child: Page(currentTopic: currentTopic),
        );
      },
    );
  }
}

class Page extends StatelessWidget {
  const Page({super.key, required this.currentTopic});
  final TopicModel currentTopic;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          "Quản lý Bài học",
        ),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AddLearningContentScreen.route,
            arguments: {
              'topicCubit': context.read<TopicCubit>(),
              'learningCubit': context.read<LearningCubit>(),
              'isAddMode': true,
              'editIndex': null,
            },
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text("Thêm bài học", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Body(currentTopic: currentTopic),
    );
  }
}

// Đổi Body sang StatefulWidget để quản lý thanh tìm kiếm
class Body extends StatefulWidget {
  final TopicModel currentTopic;

  const Body({super.key, required this.currentTopic});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  String _searchQuery = ''; // Biến lưu từ khóa tìm kiếm

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<LearningCubit, LearningState>(
      builder: (context, state) {
        if (state.status == LoadStatus.Loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == LoadStatus.Error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded, size: 64, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  state.errorMessage ?? "Lỗi tải dữ liệu",
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
            // HEADER CHỦ ĐỀ M3
            _buildTopicHeader(context, widget.currentTopic),

            // NẾU HOÀN TOÀN CHƯA CÓ BÀI HỌC NÀO
            if (state.contents.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu_book_rounded, size: 64, color: colorScheme.outline),
                      const SizedBox(height: 16),
                      Text(
                        "Chưa có bài học nào",
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Hãy nhấn 'Thêm bài học' để bắt đầu",
                        style: TextStyle(color: colorScheme.outline),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // ================= THANH TÌM KIẾM M3 =================
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm nội dung bài học...',
                    prefixIcon: Icon(Icons.search_rounded, color: colorScheme.primary),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
                child: filteredContents.isEmpty
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
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100), // Padding đáy tránh FAB
                        itemCount: filteredContents.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final content = filteredContents[index];
                          // Tìm đúng index gốc để truyền qua màn hình Sửa
                          final originalIndex = state.contents.indexOf(content);

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
                                  LearningDetailScreen
                                      .route, // Nếu có màn hình chi tiết quản lý thì dùng
                                  arguments: content,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    // Icon bài học
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.menu_book_rounded,
                                        color: colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                    const SizedBox(width: 16),

                                    // Chi tiết
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
                                          const SizedBox(height: 4),
                                          Text(
                                            "Số khối nội dung: ${content.blocks.length}",
                                            style: textTheme.bodyMedium?.copyWith(
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Menu Tùy chọn
                                    PopupMenuButton<String>(
                                      icon: Icon(
                                        Icons.more_vert_rounded,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          Navigator.pushNamed(
                                            context,
                                            AddLearningContentScreen.route,
                                            arguments: {
                                              'topicCubit': context.read<TopicCubit>(),
                                              'learningCubit': context.read<LearningCubit>(),
                                              'isAddMode': false,
                                              'editIndex': originalIndex,
                                            },
                                          );
                                        } else if (value == 'delete') {
                                          _showDeleteDialog(context, content.id, content.title);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.edit_rounded,
                                                size: 20,
                                                color: colorScheme.primary,
                                              ),
                                              const SizedBox(width: 12),
                                              const Text("Sửa bài học"),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete_rounded,
                                                color: colorScheme.error,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                "Xóa",
                                                style: TextStyle(
                                                  color: colorScheme.error,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ],
        );
      },
    );
  }

  // Header bo góc hiện đại
  Widget _buildTopicHeader(BuildContext context, TopicModel topic) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.folder_open_rounded,
                size: 16,
                color: colorScheme.onPrimaryContainer.withOpacity(0.7),
              ),
              const SizedBox(width: 6),
              Text(
                "Đang quản lý Chủ đề:",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            topic.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  // Dialog Xóa M3
  void _showDeleteDialog(BuildContext context, int id, String title) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: colorScheme.error),
            const SizedBox(width: 8),
            const Text("Xác nhận xóa"),
          ],
        ),
        content: Text(
          "Bạn có chắc muốn xóa bài học '$title' không? Hành động này không thể hoàn tác.",
          style: TextStyle(height: 1.5, color: colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("HỦY", style: TextStyle(color: colorScheme.outline)),
          ),
          FilledButton(
            onPressed: () {
              context.read<LearningCubit>().deleteLesson(id);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                notiBar("Đã xóa bài học thành công", false),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text("XÓA"),
          ),
        ],
      ),
    );
  }
}
