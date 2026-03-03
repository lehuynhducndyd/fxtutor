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
    return const _Body();
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  "Không thể tải danh sách chủ đề",
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

        // 3. Trạng thái trống (Database chưa có dữ liệu)
        if (state.listTopic.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: colorScheme.outline),
                const SizedBox(height: 16),
                Text(
                  "Chưa có chủ đề nào được cập nhật.",
                  style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        // ================= LỌC DANH SÁCH =================
        final filteredTopics = state.listTopic.where((topic) {
          final query = _searchQuery.toLowerCase();
          final titleMatch = topic.title.toLowerCase().contains(query);
          final descMatch = topic.description.toLowerCase().contains(query);
          return titleMatch || descMatch;
        }).toList();

        return Column(
          children: [
            // ================= THANH TÌM KIẾM M3 =================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm chủ đề...',
                  prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none, // Ẩn viền để nhìn hiện đại hơn
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
              child: filteredTopics.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 64, color: colorScheme.outline),
                          const SizedBox(height: 16),
                          Text(
                            "Không tìm thấy chủ đề nào phù hợp.",
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        context.read<TopicCubit>().loadTopics();
                      },
                      child: ListView.separated(
                        physics:
                            const AlwaysScrollableScrollPhysics(), // Đảm bảo luôn kéo refresh được kể cả khi list ngắn
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: filteredTopics.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final topic = filteredTopics[index];
                          final originalIndex = state.listTopic.indexOf(topic);

                          return Card(
                            elevation: 0, // M3 style
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
                                  LearningListScreen.route,
                                  arguments: {'cubit': context.read<TopicCubit>()},
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Icon trang trí hiện đại
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.menu_book_rounded,
                                        color: colorScheme.onPrimaryContainer,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Nội dung text
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
                                          const SizedBox(height: 6),
                                          Text(
                                            topic.description,
                                            style: textTheme.bodyMedium?.copyWith(
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 10),

                                          // Người tạo
                                          if (topic.userId != null && topic.userId!.isNotEmpty)
                                            FutureBuilder<UserModel?>(
                                              future: context.read<LearningService>().getUserById(
                                                topic.userId!,
                                              ),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData && snapshot.data != null) {
                                                  return Row(
                                                    children: [
                                                      Icon(
                                                        Icons.edit_square,
                                                        size: 14,
                                                        color: colorScheme.primary,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        snapshot.data!.fullName ??
                                                            snapshot.data!.email ??
                                                            'Ẩn danh',
                                                        style: textTheme.labelMedium?.copyWith(
                                                          color: colorScheme.primary,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }
                                                return const SizedBox.shrink();
                                              },
                                            ),
                                        ],
                                      ),
                                    ),
                                    // Mũi tên điều hướng (canh giữa chiều dọc)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 12.0),
                                      child: Icon(Icons.chevron_right, color: Colors.grey),
                                    ),
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
