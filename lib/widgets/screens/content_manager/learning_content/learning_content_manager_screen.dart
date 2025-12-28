import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/add_topic_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/topic_cubit.dart';

import '../../../../common/enum/load_status.dart';
import '../../../../services/topic_service.dart';
import '../../../common_widgets/noti_bar.dart';
import 'list_math_types_screen.dart';

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
      child: Page(),
    );
  }
}

class Page extends StatelessWidget {
  const Page({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Các chủ đề"),
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
        child: Icon(Icons.add),
      ),
      body: Body(),
    );
  }
}

class Body extends StatelessWidget {
  const Body({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopicCubit, TopicState>(
      builder: (context, state) {
        if (state.loadStatus == LoadStatus.Loading)
          return Center(child: CircularProgressIndicator());
        if (state.loadStatus == LoadStatus.Error) return Center(child: Text("Lỗi tải nội dung"));
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 100),
          itemCount: state.listTopic.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: ListTile(
                title: Text(state.listTopic[index].title),
                subtitle: Text(state.listTopic[index].description),
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
                  Navigator.pushNamed(
                    context,
                    ListMathTypesScreen.route,
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
        content: Text("Bạn có chắc chắn muốn xóa chủ đề '${state.listTopic[index].title}' không?"),
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
                notiBar("Xóa chủ đề thành công", false),
              );
            },
            child: const Text("XÓA", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
