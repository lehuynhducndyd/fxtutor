import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/models/learning_content.dart';
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Ẩn bàn phím khi chạm ra ngoài
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text(
            widget.isAddMode ? "Thêm nội dung bài học" : "Sửa nội dung",
            style: const TextStyle(fontWeight: FontWeight.bold),
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
  final _titleController = TextEditingController();

  List<ContentBlock> _blocks = [const ContentBlock(type: 'text', data: '')];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isAddMode && widget.editIndex != null) {
      final state = context.read<LearningCubit>().state;
      if (widget.editIndex! < state.contents.length) {
        final content = state.contents[widget.editIndex!];
        _titleController.text = content.title;
        _blocks = List.from(content.blocks);
      }
    }
  }

  // --- LOGIC XỬ LÝ KHỐI ---
  void _addBlock(String type) {
    setState(() {
      _blocks.add(ContentBlock(type: type, data: '', url: '', caption: ''));
    });
  }

  void _removeBlock(int index) {
    setState(() {
      _blocks.removeAt(index);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi upload ảnh: $e"), backgroundColor: Colors.red),
      );
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

  // --- GIAO DIỆN ---
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: colorScheme.surface,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              spacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => Navigator.pushNamed(context, GuideScreen.route),
                  label: const Text("Hướng dẫn"),
                  style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => Navigator.pushNamed(context, CalculatorScreen.route),
                  label: const Text("Lấy Keylog"),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              bottom: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                offset: const Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: PopupMenuButton<String>(
                onSelected: _addBlock,
                position: PopupMenuPosition.under,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                    border: Border.all(color: colorScheme.primary.withOpacity(0.5), width: 1.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline_rounded, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        "Thêm khối nội dung",
                        style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // ================= KHU VỰC SOẠN THẢO CHÍNH (TỐI ƯU TABLET - SCROLLABLE) =================
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TIÊU ĐỀ BÀI HỌC
                    Text(
                      "Tiêu đề bài học",
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: "VD: Phương trình bậc 2",
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // DANH SÁCH CÁC KHỐI ĐÃ THÊM
                    if (_blocks.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            "Chưa có nội dung. Hãy nhấp 'Thêm khối nội dung' ở trên.",
                            style: TextStyle(color: colorScheme.outline, fontSize: 16),
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
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, -4),
                blurRadius: 10,
              ),
            ],
          ),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: FilledButton.icon(
                  onPressed: _onSave,
                  icon: const Icon(Icons.save_rounded),
                  label: Text(
                    widget.isAddMode ? "Tạo bài học" : "Lưu thay đổi",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(text),
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

  Widget _buildBlockItem(int index, ContentBlock block, ColorScheme colorScheme) {
    final Color colorTheme = _getBlockColor(block.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER KHỐI ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorTheme.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(_getBlockIcon(block.type), size: 16, color: colorTheme),
                      const SizedBox(width: 6),
                      Text(
                        _getBlockTitle(block.type),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorTheme,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: colorScheme.error, size: 20),
                  onPressed: () => _removeBlock(index),
                  tooltip: "Xóa khối này",
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- NỘI DUNG TÙY THEO LOẠI ---

            // 1. VĂN BẢN
            if (block.type == 'text')
              TextField(
                controller: TextEditingController(text: block.data)
                  ..selection = TextSelection.collapsed(offset: block.data?.length ?? 0),
                onChanged: (v) => _blocks[index] = block.copyWith(data: v),
                maxLines: null,
                minLines: 3,
                decoration: InputDecoration(
                  hintText: "Nhập văn bản thông thường...",
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

            // 2. LATEX
            if (block.type == 'latex')
              TextField(
                controller: TextEditingController(text: block.data)
                  ..selection = TextSelection.collapsed(offset: block.data?.length ?? 0),
                onChanged: (v) => _blocks[index] = block.copyWith(data: v),
                maxLines: null,
                minLines: 2,
                style: const TextStyle(
                  fontFamily: 'Courier',
                  color: Colors.teal,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: "Nhập công thức (VD: x = \\frac{-b \\pm \\sqrt{\\Delta}}{2a})",
                  prefixText: "\$\$ ",
                  suffixText: " \$\$",
                  filled: true,
                  fillColor: Colors.teal.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.teal.withOpacity(0.3)),
                  ),
                ),
              ),

            // 3. FX-580 / FX-880 KEYLOG
            if (block.type == '580keylog' || block.type == '880keylog')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: TextEditingController(text: block.data)
                      ..selection = TextSelection.collapsed(offset: block.data?.length ?? 0),
                    onChanged: (v) => _blocks[index] = block.copyWith(data: v),
                    maxLines: null,
                    minLines: 1,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.keyboard_rounded),
                      filled: true,
                      fillColor: colorTheme.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorTheme.withOpacity(0.3)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Nhập chuỗi phím theo dạng [SHIFT][MENU]...",
                    style: TextStyle(fontSize: 12, color: colorScheme.outline),
                  ),
                ],
              ),

            // 4. HÌNH ẢNH
            if (block.type == 'image') ...[
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: block.url != null && block.url!.isNotEmpty
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              block.url!,
                              fit: BoxFit.cover,
                              errorBuilder: (c, o, s) => Center(
                                child: Icon(
                                  Icons.broken_image_rounded,
                                  color: colorScheme.error,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: FilledButton.icon(
                              onPressed: () => _pickAndUploadImage(index),
                              icon: const Icon(Icons.edit_rounded, size: 16),
                              label: const Text("Đổi ảnh"),
                              style: FilledButton.styleFrom(
                                backgroundColor: colorScheme.surface.withOpacity(0.9),
                                foregroundColor: colorScheme.onSurface,
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
                              size: 48,
                              color: colorScheme.outline,
                            ),
                            const SizedBox(height: 12),
                            FilledButton.tonal(
                              onPressed: () => _pickAndUploadImage(index),
                              child: const Text("Chọn & Upload Ảnh"),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: TextEditingController(text: block.caption)
                  ..selection = TextSelection.collapsed(offset: block.caption?.length ?? 0),
                onChanged: (v) => _blocks[index] = block.copyWith(caption: v),
                decoration: InputDecoration(
                  hintText: "Chú thích ảnh (tùy chọn)",
                  prefixIcon: const Icon(Icons.description_outlined, size: 20),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
