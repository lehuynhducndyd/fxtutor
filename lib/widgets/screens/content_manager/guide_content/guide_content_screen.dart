import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/common/enum/load_status.dart';
import 'package:fx_tutor/models/topic_model.dart';
import 'package:fx_tutor/services/guide_management_service.dart';
import 'package:fx_tutor/widgets/common_widgets/noti_bar.dart';
import 'package:fx_tutor/widgets/screens/content_manager/guide_content/guide_detail_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/guide_content/guide_manage_cubit.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/topic_cubit.dart';

import 'add_guide_content_screen.dart';

class GuideContentScreen extends StatefulWidget {
  const GuideContentScreen({super.key});

  static const String route = 'GuideContentScreen';

  @override
  State<GuideContentScreen> createState() => _GuideContentScreenState();
}

class _GuideContentScreenState extends State<GuideContentScreen> {
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
              GuideManageCubit(context.read<GuideManagementService>())..loadGuides(currentTopic.id),
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
        title: const Text("Hướng dẫn máy tính"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AddGuideContentScreen.route,
            arguments: {
              'topicCubit': context.read<TopicCubit>(),
              'guideCubit': context.read<GuideManageCubit>(),
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

// Chuyển Body sang StatefulWidget để quản lý thanh tìm kiếm cục bộ
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
    return BlocBuilder<GuideManageCubit, GuideManageState>(
      builder: (context, state) {
        if (state.status == LoadStatus.Loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == LoadStatus.Error) {
          return Center(child: Text(state.errorMessage ?? "Lỗi tải dữ liệu"));
        }

        // ================= XỬ LÝ KHI DANH SÁCH RỖNG HOÀN TOÀN =================
        if (state.guides.isEmpty) {
          return Column(
            children: [
              _buildTopicHeader(widget.currentTopic),
              const Expanded(child: Center(child: Text("Chưa có hướng dẫn nào"))),
            ],
          );
        }

        // ================= LỌC DANH SÁCH THEO TỪ KHÓA =================
        final filteredGuides = state.guides.where((guide) {
          // Lọc theo tên hướng dẫn (actionName)
          return guide.actionName.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        return Column(
          children: [
            _buildTopicHeader(widget.currentTopic),

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
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            // ================= DANH SÁCH HIỂN THỊ =================
            Expanded(
              child: filteredGuides.isEmpty
                  ? const Center(child: Text("Không tìm thấy hướng dẫn nào."))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
                      itemCount: filteredGuides.length,
                      itemBuilder: (context, index) {
                        final guide = filteredGuides[index];
                        // QUAN TRỌNG: Tìm đúng index gốc để truyền qua màn hình Sửa
                        final originalIndex = state.guides.indexOf(guide);

                        return Card(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: ListTile(
                            leading: const Icon(Icons.calculate, color: Colors.blue),
                            title: Text(
                              guide.actionName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "Dòng máy: ${guide.compatibleModels.join(', ')}",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  Navigator.pushNamed(
                                    context,
                                    AddGuideContentScreen.route,
                                    arguments: {
                                      'topicCubit': context.read<TopicCubit>(),
                                      'guideCubit': context.read<GuideManageCubit>(),
                                      'isAddMode': false,
                                      'editIndex': originalIndex, // Truyền originalIndex
                                    },
                                  );
                                } else if (value == 'delete') {
                                  _showDeleteDialog(context, guide.id!, guide.actionName);
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
                                GuideDetailScreen.route,
                                arguments: guide,
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

  // Widget hiển thị tiêu đề chủ đề hiện tại
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
        content: Text("Bạn có chắc muốn xóa hướng dẫn '$title' không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("HỦY"),
          ),
          TextButton(
            onPressed: () {
              context.read<GuideManageCubit>().deleteGuide(id);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                notiBar("Đã xóa hướng dẫn", false),
              );
            },
            child: const Text("XÓA", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
