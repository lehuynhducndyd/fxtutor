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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nội dung học tập"),
      ),
      floatingActionButton: FloatingActionButton(
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
        child: const Icon(Icons.add),
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
    return BlocBuilder<LearningCubit, LearningState>(
      builder: (context, state) {
        if (state.status == LoadStatus.Loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == LoadStatus.Error) {
          return Center(child: Text(state.errorMessage ?? "Lỗi tải dữ liệu"));
        }

        // Nếu hoàn toàn chưa có nội dung nào trong CSDL
        if (state.contents.isEmpty) {
          return Column(
            children: [
              _buildTopicHeader(widget.currentTopic),
              const Expanded(child: Center(child: Text("Chưa có nội dung nào"))),
            ],
          );
        }

        // ================= LỌC DANH SÁCH THEO TỪ KHÓA =================
        final filteredContents = state.contents.where((content) {
          return content.title.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        return Column(
          children: [
            _buildTopicHeader(widget.currentTopic),

            // ================= THANH TÌM KIẾM =================
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm nội dung bài học...',
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
              child: filteredContents.isEmpty
                  ? const Center(child: Text("Không tìm thấy nội dung nào."))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
                      itemCount: filteredContents.length,
                      itemBuilder: (context, index) {
                        final content = filteredContents[index];
                        // QUAN TRỌNG: Tìm đúng index gốc để truyền qua màn hình Sửa (AddLearningContentScreen)
                        final originalIndex = state.contents.indexOf(content);

                        return Card(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: ListTile(
                            leading: const Icon(Icons.book, color: Colors.blue),
                            title: Text(
                              content.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "Số khối nội dung: ${content.blocks.length}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  Navigator.pushNamed(
                                    context,
                                    AddLearningContentScreen.route,
                                    arguments: {
                                      'topicCubit': context.read<TopicCubit>(),
                                      'learningCubit': context.read<LearningCubit>(),
                                      'isAddMode': false,
                                      'editIndex': originalIndex, // Truyền đúng originalIndex
                                    },
                                  );
                                } else if (value == 'delete') {
                                  _showDeleteDialog(context, content.id, content.title);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 8),
                                      Text("Sửa"),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red, size: 20),
                                      SizedBox(width: 8),
                                      Text("Xóa", style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                LearningDetailScreen.route,
                                arguments: content,
                              );
                            },
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

  Widget _buildTopicHeader(TopicModel topic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        border: const Border(
          bottom: BorderSide(color: Colors.blue, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Chủ đề hiện tại:",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            topic.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int id, String title) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc muốn xóa nội dung '$title' không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("HỦY"),
          ),
          TextButton(
            onPressed: () {
              context.read<LearningCubit>().deleteLesson(id);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                notiBar("Đã xóa nội dung", false),
              );
            },
            child: const Text("XÓA", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
