import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/models/learning_content.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/latex_generation_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/learning_content_cubit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../caculator/calculator_screen.dart';
import '../../guide/guide_screen.dart';
import 'more_keylog_screen.dart';
import 'more_keylog_screen2.dart';

class AddLearningContentScreen extends StatefulWidget {
  final bool isAddMode;
  final int? editIndex;

  const AddLearningContentScreen({
    super.key,
    required this.isAddMode,
    this.editIndex,
  });

  static const String route = 'AddLearningContentScreen';

  @override
  State<AddLearningContentScreen> createState() => _AddLearningContentScreenState();
}

class _AddLearningContentScreenState extends State<AddLearningContentScreen> {
  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 800;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text(
            widget.isAddMode ? "Thêm nội dung bài học" : "Sửa nội dung",
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: isLargeScreen
            ? SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Body(
                        isAddMode: widget.isAddMode,
                        editIndex: widget.editIndex,
                        isLargeScreen: isLargeScreen,
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
  final _titleController = TextEditingController();

  List<ContentBlock> _blocks = [const ContentBlock(type: 'text', data: '')];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  // GIẢI PHÁP 2: Khai báo Map để lưu trữ các Controller, tránh reset con trỏ
  final Map<int, TextEditingController> _dataControllers = {};
  final Map<int, TextEditingController> _captionControllers = {};

  @override
  void initState() {
    super.initState();
    if (!widget.isAddMode && widget.editIndex != null) {
      final state = context.read<LearningCubit>().state;
      if (widget.editIndex! < state.contents.length) {
        final content = state.contents[widget.editIndex!];
        _titleController.text = content.title;
        _blocks = List.from(content.blocks);

        // Khởi tạo các controller ban đầu
        for (int i = 0; i < _blocks.length; i++) {
          _dataControllers[i] = TextEditingController(text: _blocks[i].data);
          _captionControllers[i] = TextEditingController(text: _blocks[i].caption);
        }
      }
    } else {
      // Nếu là chế độ Thêm mới, khởi tạo controller cho block đầu tiên
      _dataControllers[0] = TextEditingController(text: '');
      _captionControllers[0] = TextEditingController(text: '');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    // Giải phóng bộ nhớ cho các controller
    for (var controller in _dataControllers.values) {
      controller.dispose();
    }
    for (var controller in _captionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // --- LOGIC XỬ LÝ KHỐI ---
  void _addBlock(String type) {
    setState(() {
      final newIndex = _blocks.length;
      _blocks.add(
        ContentBlock(
          type: type,
          data: '',
          url: '',
          caption: '',
          isBold: false,
          isItalic: false,
          isUnderline: false,
          color: 'black',
          fontSize: 'medium',
        ),
      );
      // Tạo mới controller khi thêm khối
      _dataControllers[newIndex] = TextEditingController(text: '');
      _captionControllers[newIndex] = TextEditingController(text: '');
    });
  }

  void _removeBlock(int index) {
    setState(() {
      _blocks.removeAt(index);

      // Xóa controller và dịch chuyển các controller phía sau lên 1 bậc
      _dataControllers[index]?.dispose();
      _captionControllers[index]?.dispose();

      for (int i = index; i < _blocks.length; i++) {
        _dataControllers[i] = _dataControllers[i + 1]!;
        _captionControllers[i] = _captionControllers[i + 1]!;
      }

      _dataControllers.remove(_blocks.length);
      _captionControllers.remove(_blocks.length);
    });
  }

  // --- LOGIC UPLOAD ẢNH ---
  Future<void> _pickAndUploadImage(int index) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _isUploading = true);

      final Uint8List imageBytes = await image.readAsBytes();
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      final String pathName = 'lesson_images/$fileName';

      final String fileExt = image.name.split('.').last.toLowerCase();
      final String contentType = fileExt == 'png' ? 'image/png' : 'image/jpeg';

      await Supabase.instance.client.storage
          .from('images')
          .uploadBinary(
            pathName,
            imageBytes,
            fileOptions: FileOptions(contentType: contentType, upsert: false),
          );

      final String publicUrl = Supabase.instance.client.storage
          .from('images')
          .getPublicUrl(pathName);

      setState(() {
        final currentBlock = _blocks[index];
        _blocks[index] = currentBlock.copyWith(url: publicUrl);
        _isUploading = false;
      });
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi upload ảnh: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- LOGIC SAVE ---
  void _onSave() {
    FocusScope.of(context).unfocus();

    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Vui lòng nhập tiêu đề bài học"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    bool hasError = false;
    for (var block in _blocks) {
      if ((block.type == 'text' || block.type == 'latex') &&
          (block.data == null || block.data!.isEmpty)) {
        hasError = true;
      }
      if (block.type == 'image' && (block.url == null || block.url!.isEmpty)) {
        hasError = true;
      }
    }

    if (hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Vui lòng điền đầy đủ nội dung các khối"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final learningCubit = context.read<LearningCubit>();

    if (widget.isAddMode) {
      learningCubit.addLesson(_titleController.text, _blocks);
    } else {
      final state = learningCubit.state;
      if (widget.editIndex != null && widget.editIndex! < state.contents.length) {
        final contentId = state.contents[widget.editIndex!].id;
        learningCubit.updateLesson(contentId, _titleController.text, _blocks);
      }
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isUploading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              "Đang tải ảnh lên...",
              style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // ================= THANH CÔNG CỤ (TOOL BAR) =================
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
                FilledButton.tonalIcon(
                  onPressed: () => Navigator.pushNamed(context, GuideScreen.route),
                  label: const Text("Hướng dẫn"),
                  style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => Navigator.pushNamed(context, LatexGeneratorScreen.route),
                  label: const Text("Latex"),
                  style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
                if (!widget.isLargeScreen)
                  FilledButton.tonalIcon(
                    onPressed: () => Navigator.pushNamed(context, CalculatorScreen.route),
                    label: const Text("Keylog/Screen"),
                    style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                  ),
                FilledButton.tonalIcon(
                  onPressed: () => Navigator.pushNamed(context, MoreKeylogScreen2.route),
                  label: const Text("2nd Keylog 580"),
                  style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => Navigator.pushNamed(context, MoreKeylogScreen.route),
                  label: const Text("2nd Keylog 880"),
                  style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              ],
            ),
          ),
        ),

        // ================= THANH CỐ ĐỊNH: THÊM KHỐI MỚI =================
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              bottom: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: PopupMenuButton<String>(
                onSelected: _addBlock,
                position: PopupMenuPosition.under,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                itemBuilder: (context) => [
                  _buildPopupItem('text', Icons.notes_rounded, "Văn bản", Colors.blueGrey),
                  _buildPopupItem(
                    'latex',
                    Icons.functions_rounded,
                    "Công thức (LaTeX)",
                    Colors.teal,
                  ),
                  _buildPopupItem('image', Icons.image_rounded, "Hình ảnh", Colors.blue),
                  _buildPopupItem(
                    '580keylog',
                    Icons.calculate_rounded,
                    "Casio fx-580 Keylog",
                    Colors.deepPurple,
                  ),
                  _buildPopupItem(
                    '880keylog',
                    Icons.calculate_outlined,
                    "Casio fx-880 Keylog",
                    Colors.indigo,
                  ),
                ],
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_rounded, color: colorScheme.primary, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        "Thêm khối nội dung",
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                    // TIÊU ĐỀ BÀI HỌC
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: "Tiêu đề bài học",
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                        hintText: "VD: Phương trình bậc 2",
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

                    // DANH SÁCH CÁC KHỐI ĐÃ THÊM
                    if (_blocks.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            "Chưa có nội dung. Hãy nhấp 'Thêm khối nội dung' ở trên.",
                            style: TextStyle(color: colorScheme.outline, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                    ..._blocks.asMap().entries.map((entry) {
                      int idx = entry.key;
                      ContentBlock block = entry.value;
                      return _buildBlockItem(idx, block, colorScheme);
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
                    widget.isAddMode ? "Tạo bài học" : "Lưu thay đổi",
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

  // --- CÁC HÀM HELPER VẼ UI ---

  PopupMenuItem<String> _buildPopupItem(String value, IconData icon, String text, Color color) {
    return PopupMenuItem(
      value: value,
      height: 40,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Color _getBlockColor(String type) {
    switch (type) {
      case 'text':
        return Colors.blueGrey;
      case 'latex':
        return Colors.teal;
      case 'image':
        return Colors.blue;
      case '580keylog':
        return Colors.deepPurple;
      case '880keylog':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  String _getBlockTitle(String type) {
    switch (type) {
      case 'text':
        return "VĂN BẢN";
      case 'latex':
        return "LATEX (TOÁN)";
      case 'image':
        return "HÌNH ẢNH";
      case '580keylog':
        return "FX-580 KEYLOG";
      case '880keylog':
        return "FX-880 KEYLOG";
      default:
        return type.toUpperCase();
    }
  }

  IconData _getBlockIcon(String type) {
    switch (type) {
      case 'text':
        return Icons.notes_rounded;
      case 'latex':
        return Icons.functions_rounded;
      case 'image':
        return Icons.image_rounded;
      case '580keylog':
        return Icons.calculate_rounded;
      case '880keylog':
        return Icons.calculate_outlined;
      default:
        return Icons.block;
    }
  }

  Color _mapStringToColor(String colorStr) {
    switch (colorStr) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      default:
        return Colors.black87;
    }
  }

  double _mapStringToSize(String sizeStr) {
    switch (sizeStr) {
      case 'small':
        return 12.0;
      case 'large':
        return 18.0;
      default:
        return 14.0; // medium
    }
  }

  Widget _buildBlockItem(int index, ContentBlock block, ColorScheme colorScheme) {
    final Color colorTheme = _getBlockColor(block.type);

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
            // --- HEADER KHỐI ---
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorTheme.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(_getBlockIcon(block.type), size: 14, color: colorTheme),
                      const SizedBox(width: 6),
                      Text(
                        _getBlockTitle(block.type),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: colorTheme,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // === THANH CÔNG CỤ MINI (ĐÃ THÊM TÍNH NĂNG CUỘN NGANG) ===
                if (block.type == 'text') ...[
                  // GIẢI PHÁP 1: Bọc trong Expanded + SingleChildScrollView để cuộn ngang được
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true, // Để mặc định các nút dồn về bên phải
                      child: Container(
                        height: 34,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // --- IN ĐẬM ---
                            const SizedBox(width: 20),
                            IconButton(
                              icon: const Icon(Icons.format_bold_rounded, size: 18),
                              tooltip: "In đậm",
                              color: (block.isBold ?? false)
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurfaceVariant,
                              style: IconButton.styleFrom(
                                backgroundColor: (block.isBold ?? false)
                                    ? colorScheme.primaryContainer
                                    : Colors.transparent,
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(26, 26),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: () => setState(
                                () => _blocks[index] = block.copyWith(
                                  isBold: !(block.isBold ?? false),
                                ),
                              ),
                            ),
                            const SizedBox(width: 2),

                            // --- IN NGHIÊNG ---
                            IconButton(
                              icon: const Icon(Icons.format_italic_rounded, size: 18),
                              tooltip: "In nghiêng",
                              color: (block.isItalic ?? false)
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurfaceVariant,
                              style: IconButton.styleFrom(
                                backgroundColor: (block.isItalic ?? false)
                                    ? colorScheme.primaryContainer
                                    : Colors.transparent,
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(26, 26),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: () => setState(
                                () => _blocks[index] = block.copyWith(
                                  isItalic: !(block.isItalic ?? false),
                                ),
                              ),
                            ),
                            const SizedBox(width: 2),

                            // --- GẠCH CHÂN ---
                            IconButton(
                              icon: const Icon(Icons.format_underlined_rounded, size: 18),
                              tooltip: "Gạch chân",
                              color: (block.isUnderline ?? false)
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurfaceVariant,
                              style: IconButton.styleFrom(
                                backgroundColor: (block.isUnderline ?? false)
                                    ? colorScheme.primaryContainer
                                    : Colors.transparent,
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(26, 26),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: () => setState(
                                () => _blocks[index] = block.copyWith(
                                  isUnderline: !(block.isUnderline ?? false),
                                ),
                              ),
                            ),

                            // --- VẠCH NGĂN CÁCH ---
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: VerticalDivider(
                                width: 1,
                                indent: 6,
                                endIndent: 6,
                                color: colorScheme.outlineVariant,
                              ),
                            ),

                            // --- CHỌN MÀU CHỮ ---
                            PopupMenuButton<String>(
                              tooltip: "Màu chữ",
                              initialValue: block.color ?? 'black',
                              onSelected: (val) =>
                                  setState(() => _blocks[index] = block.copyWith(color: val)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              offset: const Offset(0, 30),
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'black', child: Text('Đen')),
                                const PopupMenuItem(
                                  value: 'red',
                                  child: Text('Đỏ', style: TextStyle(color: Colors.red)),
                                ),
                                const PopupMenuItem(
                                  value: 'green',
                                  child: Text('Lục', style: TextStyle(color: Colors.green)),
                                ),
                                const PopupMenuItem(
                                  value: 'blue',
                                  child: Text('Lam', style: TextStyle(color: Colors.blue)),
                                ),
                              ],
                              child: Container(
                                width: 26,
                                height: 26,
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
                                child: Icon(
                                  Icons.palette_rounded,
                                  size: 18,
                                  color: _mapStringToColor(block.color ?? 'black'),
                                ),
                              ),
                            ),

                            // --- CHỌN SIZE CHỮ ---
                            PopupMenuButton<String>(
                              tooltip: "Kích thước chữ",
                              initialValue: block.fontSize ?? 'medium',
                              onSelected: (val) =>
                                  setState(() => _blocks[index] = block.copyWith(fontSize: val)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              offset: const Offset(0, 30),
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'small',
                                  child: Text('Nhỏ (Small)', style: TextStyle(fontSize: 12)),
                                ),
                                PopupMenuItem(
                                  value: 'medium',
                                  child: Text('Vừa (Medium)', style: TextStyle(fontSize: 14)),
                                ),
                                PopupMenuItem(
                                  value: 'large',
                                  child: Text('Lớn (Large)', style: TextStyle(fontSize: 18)),
                                ),
                              ],
                              child: Container(
                                width: 26,
                                height: 26,
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
                                child: Icon(
                                  Icons.text_fields_rounded,
                                  size: 18,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const SizedBox(width: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ] else
                  const Spacer(),

                // Nút Xóa
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.close_rounded, color: colorScheme.error, size: 20),
                    onPressed: () => _removeBlock(index),
                    tooltip: "Xóa khối",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // --- NỘI DUNG TÙY THEO LOẠI ---

            // 1. VĂN BẢN
            if (block.type == 'text')
              TextField(
                // Sử dụng Controller từ Map đã khai báo ở trên để không bị reset con trỏ
                controller: _dataControllers[index],
                onChanged: (v) => _blocks[index] = block.copyWith(data: v),
                maxLines: null,
                minLines: 2,
                style: TextStyle(
                  fontSize: _mapStringToSize(block.fontSize ?? 'medium'),
                  color: _mapStringToColor(block.color ?? 'black'),
                  fontWeight: (block.isBold ?? false) ? FontWeight.bold : FontWeight.normal,
                  fontStyle: (block.isItalic ?? false) ? FontStyle.italic : FontStyle.normal,
                  decoration: (block.isUnderline ?? false)
                      ? TextDecoration.underline
                      : TextDecoration.none,
                ),
                decoration: InputDecoration(
                  hintText: "Nhập văn bản thông thường...",
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

            // 2. LATEX
            if (block.type == 'latex')
              TextField(
                controller: _dataControllers[index],
                onChanged: (v) => _blocks[index] = block.copyWith(data: v),
                maxLines: null,
                minLines: 1,
                style: const TextStyle(
                  fontFamily: 'Courier',
                  color: Colors.teal,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: "VD: x = \\frac{-b \\pm \\sqrt{\\Delta}}{2a}",
                  hintStyle: TextStyle(
                    color: Colors.teal.withOpacity(0.6),
                    fontWeight: FontWeight.normal,
                  ),
                  prefixText: "\$\$ ",
                  suffixText: " \$\$",
                  filled: true,
                  fillColor: Colors.teal.withOpacity(0.05),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.teal.withOpacity(0.3)),
                  ),
                ),
              ),

            // 3. KEYLOG
            if (block.type == '580keylog' || block.type == '880keylog')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _dataControllers[index],
                    onChanged: (v) => _blocks[index] = block.copyWith(data: v),
                    maxLines: null,
                    minLines: 1,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.keyboard_rounded, size: 20, color: colorTheme),
                      filled: true,
                      fillColor: colorTheme.withOpacity(0.05),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: colorTheme.withOpacity(0.3)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Nhập chuỗi phím theo dạng [SHIFT][MENU]...",
                    style: TextStyle(fontSize: 11, color: colorScheme.outline),
                  ),
                ],
              ),

            // 4. HÌNH ẢNH
            if (block.type == 'image') ...[
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: block.url != null && block.url!.isNotEmpty
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              block.url!,
                              fit: BoxFit.cover,
                              errorBuilder: (c, o, s) => Center(
                                child: Icon(Icons.broken_image_rounded, color: colorScheme.error),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: FilledButton.icon(
                              onPressed: () => _pickAndUploadImage(index),
                              icon: const Icon(Icons.edit_rounded, size: 14),
                              label: const Text("Đổi ảnh", style: TextStyle(fontSize: 12)),
                              style: FilledButton.styleFrom(
                                backgroundColor: colorScheme.surface.withOpacity(0.9),
                                foregroundColor: colorScheme.onSurface,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_rounded,
                              size: 36,
                              color: colorScheme.outline,
                            ),
                            const SizedBox(height: 8),
                            FilledButton.tonal(
                              onPressed: () => _pickAndUploadImage(index),
                              style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                              child: const Text("Chọn Ảnh", style: TextStyle(fontSize: 13)),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _captionControllers[index],
                onChanged: (v) => _blocks[index] = block.copyWith(caption: v),
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: "Chú thích ảnh (tùy chọn)",
                  prefixIcon: const Icon(Icons.description_outlined, size: 18),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
