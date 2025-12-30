import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/add_topic_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/topic_cubit.dart';

import '../../../../common/enum/load_status.dart';
import '../../../../services/topic_service.dart';
import '../../../common_widgets/noti_bar.dart';
import 'manual_content_screen.dart'; // Đảm bảo import đúng file màn hình chi tiết manual

class ManualContentManagerScreen extends StatefulWidget {
  const ManualContentManagerScreen({super.key});

  static const String route = 'ManualContentManagerScreen';

  @override
  State<ManualContentManagerScreen> createState() => _ManualContentManagerScreenState();
}

class _ManualContentManagerScreenState extends State<ManualContentManagerScreen> {
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
        title: const Text("Các chủ đề hướng dẫn"), // Tiêu đề phù hợp với Manual
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

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
          itemCount: state.listTopic.length,
          itemBuilder: (context, index) {
            final topic = state.listTopic[index];
            return Card(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: ListTile(
                title: Text(topic.title),
                subtitle: Text(topic.description),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      context.read<TopicCubit>().setSelectedIdx(index);
                      Navigator.pushNamed(
                        context,
                        AddTopicScreen.route,
                        arguments: {
                          'cubit': context.read<TopicCubit>(),
                          'isAddMode': false,
                        },
                      );
                    } else if (value == 'delete') {
                      _showDeleteDialog(context, state, index);
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
                  context.read<TopicCubit>().setSelectedIdx(index);
                  // Điều hướng tới ManualContentScreen
                  Navigator.pushNamed(
                    context,
                    ManualContentScreen.route,
                    arguments: {'cubit': context.read<TopicCubit>()},
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, TopicState state, int index) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text(
          "Bạn có chắc chắn muốn xóa mục hướng dẫn '${state.listTopic[index].title}' không?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("HỦY"),
          ),
          TextButton(
            onPressed: () {
              context.read<TopicCubit>().deleteTopic(state.listTopic[index].id);
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
