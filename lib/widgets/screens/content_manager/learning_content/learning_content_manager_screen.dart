import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/models/topic_model.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/add_topic_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/topic_cubit.dart';

import '../../../../common/enum/load_status.dart';
import '../../../../services/topic_service.dart';
import '../../../common_widgets/noti_bar.dart';
import 'learning_content_screen.dart';

class LearningContentManagerScreen extends StatefulWidget {
  const LearningContentManagerScreen({super.key});

  static const String route = 'LearningContentManagerScreen';

  @override
  State<LearningContentManagerScreen> createState() => _LearningContentManagerScreenState();
}

class _LearningContentManagerScreenState extends State<LearningContentManagerScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TopicCubit(context.read<TopicService>())..loadTopics(),
      child: const Page(),
    );
  }
}

class Page extends StatelessWidget {
  const Page({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          "Quản lý Chủ đề",
        ),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AddTopicScreen.route,
            arguments: {
              'cubit': context.read<TopicCubit>(),
              'isAddMode': true,
            },
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text("Thêm chủ đề", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: const Body(),
    );
  }
}

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<TopicCubit, TopicState>(
      builder: (context, state) {
        // ================= TRẠNG THÁI LOADING =================
        if (state.loadStatus == LoadStatus.Loading) {
          return const Center(child: CircularProgressIndicator());
        }

        // ================= TRẠNG THÁI LỖI =================
        if (state.loadStatus == LoadStatus.Error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded, size: 64, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  "Lỗi tải danh sách chủ đề",
                  style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () => context.read<TopicCubit>().loadTopics(),
                  child: const Text("Thử lại"),
                ),
              ],
            ),
          );
        }

        // LỌC DANH SÁCH THEO TỪ KHÓA TÌM KIẾM
        final filteredTopics = state.listTopic.where((topic) {
          final query = state.searchQuery.toLowerCase();
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
                  context.read<TopicCubit>().searchTopic(value);
                },
              ),
            ),

            // ================= DANH SÁCH HIỂN THỊ =================
            Expanded(
              child: filteredTopics.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 64, color: colorScheme.outline),
                          const SizedBox(height: 16),
                          Text(
                            "Không tìm thấy chủ đề nào.",
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        8,
                        16,
                        100,
                      ), // Padding bottom để không bị che bởi FAB
                      itemCount: filteredTopics.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final topic = filteredTopics[index];
                        // Tìm vị trí thực tế của topic trong danh sách gốc
                        final originalIndex = state.listTopic.indexOf(topic);

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
                              context.read<TopicCubit>().setSelectedIdx(originalIndex);
                              Navigator.pushNamed(
                                context,
                                LearningContentScreen.route,
                                arguments: {'cubit': context.read<TopicCubit>()},
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  // Icon trang trí
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

                                  // Nội dung chữ
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          topic.title,
                                          style: textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          topic.description,
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Nút Menu (Sửa / Xóa)
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
                                        context.read<TopicCubit>().setSelectedIdx(originalIndex);
                                        Navigator.pushNamed(
                                          context,
                                          AddTopicScreen.route,
                                          arguments: {
                                            'cubit': context.read<TopicCubit>(),
                                            'isAddMode': false,
                                          },
                                        );
                                      } else if (value == 'delete') {
                                        _showDeleteDialog(context, topic);
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
                                            const Text("Sửa chủ đề"),
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
        );
      },
    );
  }

  // Truyền thẳng đối tượng TopicModel vào hàm xóa thay vì index
  void _showDeleteDialog(BuildContext context, TopicModel topic) {
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
          "Bạn có chắc chắn muốn xóa chủ đề '${topic.title}' không? Hành động này không thể hoàn tác.",
          style: TextStyle(height: 1.5, color: colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("HỦY", style: TextStyle(color: colorScheme.outline)),
          ),
          FilledButton(
            onPressed: () {
              context.read<TopicCubit>().deleteTopic(topic.id);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                notiBar("Đã xóa chủ đề '${topic.title}'", false),
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
