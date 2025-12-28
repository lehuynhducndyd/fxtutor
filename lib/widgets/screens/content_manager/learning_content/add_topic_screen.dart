import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/topic_cubit.dart';

class AddTopicScreen extends StatefulWidget {
  const AddTopicScreen(this.isAddMode, {super.key});
  static const String route = 'AddTopicScreen';
  final bool isAddMode;

  @override
  State<AddTopicScreen> createState() => _AddTopicScreenState();
}

class _AddTopicScreenState extends State<AddTopicScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAddMode ? "Thêm chủ đề" : "Sửa chủ đề"),
      ),
      // Truyền isAddMode vào Body
      body: BlocBuilder<TopicCubit, TopicState>(
        builder: (context, state) {
          return Body(isAddMode: widget.isAddMode);
        },
      ),
    );
  }
}

class Body extends StatefulWidget {
  final bool isAddMode;
  const Body({super.key, required this.isAddMode});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!widget.isAddMode) {
      final state = context.read<TopicCubit>().state;
      if (state.selectedIdx != -1) {
        final topic = state.listTopic[state.selectedIdx];
        _nameController.text = topic.title;
        _descController.text = topic.description;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tên chủ đề",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: "Nhập tên chủ đề (VD: Đạo hàm...)",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Mô tả chi tiết",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "Nhập mô tả cho chủ đề này",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                final name = _nameController.text;
                final desc = _descController.text;
                if (widget.isAddMode) {
                  context.read<TopicCubit>().addTopic(name, desc);
                  Navigator.pop(context);
                } else {
                  context.read<TopicCubit>().updateTopic(name, desc);
                  Navigator.pop(context);
                }
              },
              child: Text(
                widget.isAddMode ? "TẠO MỚI" : "CẬP NHẬT",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
