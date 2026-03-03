import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/models/topic_model.dart'; // Đã thêm import TopicModel
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/add_topic_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/topic_cubit.dart';

import '../../../../common/enum/load_status.dart';
import '../../../../services/topic_service.dart';
import '../../../common_widgets/noti_bar.dart';
import 'guide_content_screen.dart'; // Đã cập nhật import đúng file guide

class GuideContentManagerScreen extends StatefulWidget {
  const GuideContentManagerScreen({super.key});

  static const String route = 'GuideContentManagerScreen';

  @override
  State<GuideContentManagerScreen> createState() => _GuideContentManagerScreenState();
}

class _GuideContentManagerScreenState extends State<GuideContentManagerScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Sử dụng lại TopicCubit theo yêu cầu
      create: (context) => TopicCubit(context.read<TopicService>())..loadTopics(),
      child: const Page(),
    );
  }
}

class Page extends StatelessWidget {
  const Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Các chủ đề hướng dẫn"), // Tiêu đề phù hợp với Guide
      ),
      floatingActionButton: FloatingActionButton(
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
        child: const Icon(Icons.add),
      ),
      body: const Body(),
    );
  }
}

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopicCubit, TopicState>(
      builder: (context, state) {
        if (state.loadStatus == LoadStatus.Loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.loadStatus == LoadStatus.Error) {
          return const Center(child: Text("Lỗi tải nội dung hướng dẫn"));
        }

        // ================= LỌC DANH SÁCH THEO TỪ KHÓA TÌM KIẾM =================
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
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm hướng dẫn...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
                onChanged: (value) {
                  // Gọi hàm searchTopic đã định nghĩa trong TopicCubit từ bài trước
                  context.read<TopicCubit>().searchTopic(value);
                },
              ),
            ),

            // ================= DANH SÁCH HIỂN THỊ =================
            Expanded(
              child: filteredTopics.isEmpty
                  ? const Center(child: Text("Không tìm thấy chủ đề hướng dẫn nào."))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
                      itemCount: filteredTopics.length,
                      itemBuilder: (context, index) {
                        final topic = filteredTopics[index];
                        // QUAN TRỌNG: Tìm vị trí thực tế của topic trong danh sách gốc (listTopic)
                        final originalIndex = state.listTopic.indexOf(topic);

                        return Card(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: ListTile(
                            title: Text(topic.title),
                            subtitle: Text(topic.description),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  // Lưu ý truyền originalIndex thay vì index của list đã lọc
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
                              context.read<TopicCubit>().setSelectedIdx(originalIndex);
                              // Điều hướng tới GuideContentScreen
                              Navigator.pushNamed(
                                context,
                                GuideContentScreen.route,
                                arguments: {'cubit': context.read<TopicCubit>()},
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

  // Cập nhật hàm xóa để truyền object TopicModel thay vì index
  void _showDeleteDialog(BuildContext context, TopicModel topic) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text(
          "Bạn có chắc chắn muốn xóa mục hướng dẫn '${topic.title}' không?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("HỦY"),
          ),
          TextButton(
            onPressed: () {
              context.read<TopicCubit>().deleteTopic(topic.id);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                notiBar("Xóa thành công", false),
              );
            },
            child: const Text("XÓA", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
