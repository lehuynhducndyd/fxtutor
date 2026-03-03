import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/models/calculator_guide_model.dart';
import 'package:fx_tutor/widgets/screens/content_manager/guide_content/guide_manage_cubit.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/topic_cubit.dart';
import 'package:fx_tutor/widgets/screens/guide/guide_screen.dart';

import '../../caculator/calculator_screen.dart';

class AddGuideContentScreen extends StatefulWidget {
  final bool isAddMode;
  final int? editIndex; // Index của guide trong list nếu ở chế độ sửa

  const AddGuideContentScreen({
    super.key,
    required this.isAddMode,
    this.editIndex,
  });

  static const String route = 'AddGuideContentScreen';

  @override
  State<AddGuideContentScreen> createState() => _AddGuideContentScreenState();
}

class _AddGuideContentScreenState extends State<AddGuideContentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAddMode ? "Thêm hướng dẫn máy tính" : "Sửa hướng dẫn"),
      ),
      body: Body(isAddMode: widget.isAddMode, editIndex: widget.editIndex),
    );
  }
}

class Body extends StatefulWidget {
  final bool isAddMode;
  final int? editIndex;

  const Body({super.key, required this.isAddMode, this.editIndex});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final _actionNameController = TextEditingController();
  final _modelsController = TextEditingController();

  // Danh sách các phương thức (Method)
  List<GuideMethod> _methods = [GuideMethod(methodName: "Cách 1", content: "")];

  @override
  void initState() {
    super.initState();
    if (!widget.isAddMode && widget.editIndex != null) {
      final state = context.read<GuideManageCubit>().state;
      final guide = state.guides[widget.editIndex!];
      _actionNameController.text = guide.actionName;
      _modelsController.text = guide.compatibleModels.join(", ");
      _methods = List.from(guide.methods);
    }
  }

  void _addMethod() {
    setState(() {
      _methods.add(GuideMethod(methodName: "Cách ${_methods.length + 1}", content: ""));
    });
  }

  void _removeMethod(int index) {
    if (_methods.length > 1) {
      setState(() {
        _methods.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Tên hành động"),
          TextField(
            controller: _actionNameController,
            decoration: const InputDecoration(
              hintText: "VD: Giải phương trình bậc 2",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          _buildLabel("Dòng máy hỗ trợ (cách nhau bởi dấu phẩy)"),
          TextField(
            controller: _modelsController,
            decoration: const InputDecoration(
              hintText: "VD: Casio 580VNX, Vinacal 680EX",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLabel("Các bước thực hiện"),
              TextButton.icon(
                onPressed: _addMethod,
                icon: const Icon(Icons.add),
                label: const Text("Thêm cách"),
              ),
            ],
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, GuideScreen.route);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  "Hướng dẫn",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: 5),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, CalculatorScreen.route);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  "Lấy Keylog",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          // Danh sách các Method
          ..._methods.asMap().entries.map((entry) {
            int idx = entry.key;
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              color: Colors.grey[50],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (v) => _methods[idx] = GuideMethod(
                              methodName: v,
                              content: _methods[idx].content,
                            ),
                            decoration: InputDecoration(
                              hintText: "Tên phương thức",
                              labelText: "Phương thức ${idx + 1}",
                            ),
                            controller: TextEditingController(text: _methods[idx].methodName)
                              ..selection = TextSelection.collapsed(
                                offset: _methods[idx].methodName.length,
                              ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _removeMethod(idx),
                        ),
                      ],
                    ),
                    TextField(
                      onChanged: (v) => _methods[idx] = GuideMethod(
                        methodName: _methods[idx].methodName,
                        content: v,
                      ),
                      maxLines: 8,
                      decoration: const InputDecoration(
                        hintText: "Nhập nội dung (Dùng [PHÍM] để hiển thị icon phím)",
                      ),
                      controller: TextEditingController(text: _methods[idx].content)
                        ..selection = TextSelection.collapsed(offset: _methods[idx].content.length),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _onSave,
              child: Text(
                widget.isAddMode ? "TẠO HƯỚNG DẪN" : "CẬP NHẬT",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  void _onSave() {
    if (_actionNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên hành động')),
      );
      return;
    }

    if (_modelsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập dòng máy hỗ trợ')),
      );
      return;
    }

    if (_methods.any((m) => m.methodName.trim().isEmpty || m.content.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ tên và nội dung các phương thức')),
      );
      return;
    }

    final topicState = context.read<TopicCubit>().state;
    final topicId = topicState.listTopic[topicState.selectedIdx].id!;

    if (widget.isAddMode) {
      context.read<GuideManageCubit>().addGuide(
        null,
        topicId,
        _actionNameController.text,
        _modelsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        _methods,
      );
    } else {
      context.read<GuideManageCubit>().editGuide(
        context.read<GuideManageCubit>().state.guides[widget.editIndex!].id,
        topicId,
        _actionNameController.text,
        _modelsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        _methods,
      );
    }
    Navigator.pop(context);
  }
}
