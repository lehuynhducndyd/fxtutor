import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/models/calculator_guide_model.dart';
import 'package:fx_tutor/widgets/screens/content_manager/guide_content/guide_manage_cubit.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/topic_cubit.dart';
import 'package:fx_tutor/widgets/screens/guide/guide_screen.dart';

import '../../caculator/calculator_screen.dart';

class AddGuideContentScreen extends StatefulWidget {
  final bool isAddMode;
  final int? editIndex;

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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Chạm ra ngoài để hạ bàn phím
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text(
            widget.isAddMode ? "Thêm hướng dẫn" : "Sửa hướng dẫn",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal), // Không in đậm
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: Body(isAddMode: widget.isAddMode, editIndex: widget.editIndex),
      ),
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

  void _onSave() {
    FocusScope.of(context).unfocus(); // Ẩn bàn phím khi lưu

    final colorScheme = Theme.of(context).colorScheme;

    if (_actionNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng nhập tên hành động'),
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    if (_modelsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng nhập dòng máy hỗ trợ'),
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    if (_methods.any((m) => m.methodName.trim().isEmpty || m.content.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng nhập đầy đủ tên và nội dung các phương thức'),
          backgroundColor: colorScheme.error,
        ),
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // ================= THANH CÔNG CỤ TÍCH HỢP (TOOLBAR) GỌN GÀNG =================
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6), // Ép nhỏ padding dọc
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(bottom: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3))),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              spacing: 6,
              children: [
                // Nút Thêm Cách (Nổi bật nhất)
                FilledButton.icon(
                  onPressed: _addMethod,
                  label: const Text("Thêm Cách giải", style: TextStyle(fontSize: 13)),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: colorScheme.primary,
                  ),
                ),
                // Các nút công cụ phụ trợ
                FilledButton.tonalIcon(
                  onPressed: () => Navigator.pushNamed(context, GuideScreen.route),
                  label: const Text("Xem Hướng dẫn", style: TextStyle(fontSize: 13)),
                  style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => Navigator.pushNamed(context, CalculatorScreen.route),
                  label: const Text("Lấy Keylog", style: TextStyle(fontSize: 13)),
                  style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              ],
            ),
          ),
        ),

        // ================= KHU VỰC SOẠN THẢO CHÍNH =================
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800), // Giới hạn 800px giống Word
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 16.0,
                ), // Ép nhẹ lề ngang
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- TÊN HÀNH ĐỘNG (Gộp LabelText) ---
                    TextField(
                      controller: _actionNameController,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: "Tên hành động",
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                        hintText: "VD: Giải phương trình bậc 2",
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- DÒNG MÁY HỖ TRỢ (Gộp LabelText) ---
                    TextField(
                      controller: _modelsController,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: "Dòng máy hỗ trợ (cách nhau bởi dấu phẩy)",
                        hintText: "VD: Casio 580VNX, Vinacal 680EX",
                        prefixIcon: Icon(
                          Icons.devices_rounded,
                          color: colorScheme.outline,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- TIÊU ĐỀ PHẦN PHƯƠNG THỨC ---
                    Row(
                      children: [
                        Icon(Icons.list_alt_rounded, color: colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Các bước thực hiện",
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12), // Giảm khoảng cách
                    // --- DANH SÁCH CÁC PHƯƠNG THỨC (CÁCH GIẢI) ---
                    ..._methods.asMap().entries.map((entry) {
                      int idx = entry.key;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12), // Giảm margin
                        elevation: 0,
                        color: colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0), // Giảm padding trong thẻ
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tiêu đề Cách X & Nút xóa
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      onChanged: (v) => _methods[idx] = GuideMethod(
                                        methodName: v,
                                        content: _methods[idx].content,
                                      ),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                        fontSize: 14,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "VD: Cách 1 (Dùng Mode)",
                                        labelText: "Tên phương thức ${idx + 1}",
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ), // Ép lùn
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: colorScheme.outlineVariant),
                                        ),
                                        isDense: true,
                                      ),
                                      controller:
                                          TextEditingController(text: _methods[idx].methodName)
                                            ..selection = TextSelection.collapsed(
                                              offset: _methods[idx].methodName.length,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 36,
                                    height: 36,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: Icon(
                                        Icons.delete_outline_rounded,
                                        color: colorScheme.error,
                                        size: 20,
                                      ),
                                      tooltip: "Xóa cách này",
                                      onPressed: () => _removeMethod(idx),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Nội dung chi tiết các bước bấm
                              TextField(
                                onChanged: (v) => _methods[idx] = GuideMethod(
                                  methodName: _methods[idx].methodName,
                                  content: v,
                                ),
                                maxLines: 6,
                                minLines: 2,
                                style: const TextStyle(
                                  height: 1.5,
                                  fontSize: 14,
                                ), // Dùng font mono để dễ nhìn phím bấm
                                decoration: InputDecoration(
                                  hintText:
                                      "Nhập nội dung các bước. Dùng [PHÍM] để hiển thị icon phím bấm trên giao diện.",
                                  filled: true,
                                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                controller: TextEditingController(text: _methods[idx].content)
                                  ..selection = TextSelection.collapsed(
                                    offset: _methods[idx].content.length,
                                  ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ================= NÚT LƯU CỐ ĐỊNH Ở ĐÁY =================
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(top: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3))),
          ),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: FilledButton.icon(
                  onPressed: _onSave,
                  icon: const Icon(Icons.save_rounded, size: 20),
                  label: Text(
                    widget.isAddMode ? "Tạo Hướng dẫn" : "Lưu Thay đổi",
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48), // Chiều cao gọn gàng chuẩn M3
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
