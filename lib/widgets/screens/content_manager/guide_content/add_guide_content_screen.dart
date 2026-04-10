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
    // 1. Xác định kích thước màn hình
    final isLargeScreen = MediaQuery.of(context).size.width >= 800;
    // 2. Lấy chiều cao bàn phím để tránh vỡ layout WebView
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,

        // 3. Tắt tự bóp màn hình ở màn hình lớn để bảo vệ WebView
        resizeToAvoidBottomInset: !isLargeScreen,

        appBar: AppBar(
          title: Text(
            widget.isAddMode ? "Thêm hướng dẫn" : "Sửa hướng dẫn",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
          ),
          centerTitle: true,
          elevation: 0,
        ),

        // 4. Chia màn hình tỉ lệ 2:1
        body: isLargeScreen
            ? SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      // 5. Đẩy khung soạn thảo lên bằng đúng chiều cao bàn phím ảo
                      child: Padding(
                        padding: EdgeInsets.only(bottom: bottomInset),
                        child: Body(
                          isAddMode: widget.isAddMode,
                          editIndex: widget.editIndex,
                          isLargeScreen: isLargeScreen, // Truyền biến màn hình lớn xuống
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 1, thickness: 1),
                    const Expanded(
                      flex: 1,
                      child: CalculatorScreen(),
                    ),
                  ],
                ),
              )
            : Body(
                isAddMode: widget.isAddMode,
                editIndex: widget.editIndex,
                isLargeScreen: isLargeScreen,
              ),
      ),
    );
  }
}

class Body extends StatefulWidget {
  final bool isAddMode;
  final int? editIndex;
  final bool isLargeScreen;

  const Body({
    super.key,
    required this.isAddMode,
    this.editIndex,
    required this.isLargeScreen,
  });

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

  // --- HÀM THÊM NHANH DÒNG MÁY ---
  void _addModelChip(String modelName) {
    String currentText = _modelsController.text.trim();
    if (currentText.isEmpty) {
      _modelsController.text = modelName;
    } else {
      // Kiểm tra xem đã có model này chưa để tránh chèn đúp
      if (!currentText.contains(modelName)) {
        if (currentText.endsWith(',')) {
          _modelsController.text = "$currentText $modelName";
        } else {
          _modelsController.text = "$currentText, $modelName";
        }
      }
    }
    // Chuyển con trỏ về cuối dòng
    _modelsController.selection = TextSelection.fromPosition(
      TextPosition(offset: _modelsController.text.length),
    );
  }

  void _onSave() {
    FocusScope.of(context).unfocus();

    final colorScheme = Theme.of(context).colorScheme;

    if (_actionNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng nhập tên hành động'),
          backgroundColor: colorScheme.error,
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    if (_modelsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng nhập dòng máy hỗ trợ'),
          backgroundColor: colorScheme.error,
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    if (_methods.any((m) => m.methodName.trim().isEmpty || m.content.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng nhập đầy đủ tên và nội dung các phương thức'),
          backgroundColor: colorScheme.error,
          duration: const Duration(seconds: 1),
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
        // ================= THANH CÔNG CỤ TÍCH HỢP (TOOLBAR) =================
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6),
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
                FilledButton.icon(
                  onPressed: _addMethod,
                  label: const Text("Thêm Cách giải", style: TextStyle(fontSize: 13)),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: colorScheme.primary,
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => Navigator.pushNamed(context, GuideScreen.route),
                  label: const Text("Xem Hướng dẫn", style: TextStyle(fontSize: 13)),
                  style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
                // Ẩn nút nếu đang dùng màn hình lớn (vì WebView máy tính đã mở sẵn bên cạnh)
                if (!widget.isLargeScreen)
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
              constraints: const BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- TÊN HÀNH ĐỘNG ---
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

                    // --- DÒNG MÁY HỖ TRỢ ---
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _modelsController,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            labelText: "Dòng máy hỗ trợ (cách nhau bởi dấu phẩy)",
                            hintText: "VD: 580, 880",
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // CÁC NÚT CHỌN NHANH MODEL MÁY TÍNH
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Text(
                                "Chọn nhanh: ",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ActionChip(
                                label: const Text("fx-580VNX"),
                                labelStyle: const TextStyle(fontSize: 12),
                                visualDensity: VisualDensity.compact,
                                onPressed: () => _addModelChip("fx-580VNX"),
                              ),
                              const SizedBox(width: 6),
                              ActionChip(
                                label: const Text("fx-880BTG"),
                                labelStyle: const TextStyle(fontSize: 12),
                                visualDensity: VisualDensity.compact,
                                onPressed: () => _addModelChip("fx-880BTG"),
                              ),
                              const SizedBox(width: 6),
                            ],
                          ),
                        ),
                      ],
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
                    const SizedBox(height: 12),

                    // --- DANH SÁCH CÁC PHƯƠNG THỨC (CÁCH GIẢI) ---
                    ..._methods.asMap().entries.map((entry) {
                      int idx = entry.key;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        color: colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
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
                                        ),
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
                                ),
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
                    minimumSize: const Size.fromHeight(48),
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
