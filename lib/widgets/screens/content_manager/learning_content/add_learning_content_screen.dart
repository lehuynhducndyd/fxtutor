import 'dart:typed_data'; // Cần thêm import này để dùng Uint8List

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Đảm bảo import đúng đường dẫn đến model và cubit của bạn
import 'package:fx_tutor/models/learning_content.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/learning_content_cubit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../caculator/calculator_screen.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAddMode ? "Thêm nội dung bài học" : "Sửa nội dung"),
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
  final _titleController = TextEditingController();
  // Khởi tạo mặc định 1 khối text
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

  // --- LOGIC UPLOAD ẢNH SUPABASE (Đã fix lỗi Windows/Web) ---

  Future<void> _pickAndUploadImage(int index) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _isUploading = true);

      // Đọc bytes thay vì File path để chạy tốt trên mọi nền tảng
      final Uint8List imageBytes = await image.readAsBytes();
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      final String pathName = 'lesson_images/$fileName';

      // Xác định ContentType sơ bộ
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
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Vui lòng nhập tiêu đề")));
      return;
    }

    bool hasError = false;
    for (var block in _blocks) {
      // Validate Text & Latex (dùng field data)
      if ((block.type == 'text' || block.type == 'latex') &&
          (block.data == null || block.data!.isEmpty)) {
        hasError = true;
      }
      // Validate Image (dùng field url)
      if (block.type == 'image' && (block.url == null || block.url!.isEmpty)) {
        hasError = true;
      }
    }

    if (hasError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Vui lòng điền đầy đủ nội dung các khối")));
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
    if (_isUploading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Đang tải ảnh lên..."),
          ],
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 8,
        ),
        // Nút Save ở trên
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 5,
            children: [
              ElevatedButton(
                onPressed: _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  widget.isAddMode ? "Tạo" : "Lưu",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                spacing: 5,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      "Hướng dẫn",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
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
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      "Lấy Keylog khác",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 8,
        ),
        PopupMenuButton<String>(
          onSelected: _addBlock,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'text',
              child: Row(
                children: [
                  Icon(Icons.notes, color: Colors.blueGrey),
                  SizedBox(width: 8),
                  Text("Văn bản"),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'latex',
              child: Row(
                children: [
                  Icon(Icons.functions, color: Colors.teal),
                  SizedBox(width: 8),
                  Text("Công thức (LaTeX)"),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'image',
              child: Row(
                children: [
                  Icon(Icons.image, color: Colors.blue),
                  SizedBox(width: 8),
                  Text("Hình ảnh"),
                ],
              ),
            ),
            const PopupMenuItem(
              value: '580keylog',
              child: Row(
                children: [
                  Icon(Icons.calculate, color: Colors.deepPurple),
                  SizedBox(width: 8),
                  Text("Casio fx-580 Keylog"),
                ],
              ),
            ),
            const PopupMenuItem(
              value: '880keylog',
              child: Row(
                children: [
                  Icon(Icons.calculate_outlined, color: Colors.indigo),
                  SizedBox(width: 8),
                  Text("Casio fx-880 Keylog"),
                ],
              ),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue),
            ),
            child: const Row(
              children: [
                Icon(Icons.add, color: Colors.blue, size: 20),
                SizedBox(width: 4),
                Text(
                  "Thêm khối",
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("Tiêu đề bài học"),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: "VD: Phương trình bậc 2",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 24),

                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     _buildLabel("Nội dung chi tiết"),
                //     // --- MENU CHỌN LOẠI KHỐI (3 LOẠI) ---
                //     PopupMenuButton<String>(
                //       onSelected: _addBlock,
                //       itemBuilder: (context) => [
                //         const PopupMenuItem(
                //           value: 'text',
                //           child: Row(
                //             children: [
                //               Icon(Icons.notes, color: Colors.blueGrey),
                //               SizedBox(width: 8),
                //               Text("Văn bản"),
                //             ],
                //           ),
                //         ),
                //         const PopupMenuItem(
                //           value: 'latex',
                //           child: Row(
                //             children: [
                //               Icon(Icons.functions, color: Colors.teal),
                //               SizedBox(width: 8),
                //               Text("Công thức (LaTeX)"),
                //             ],
                //           ),
                //         ),
                //         const PopupMenuItem(
                //           value: 'image',
                //           child: Row(
                //             children: [
                //               Icon(Icons.image, color: Colors.blue),
                //               SizedBox(width: 8),
                //               Text("Hình ảnh"),
                //             ],
                //           ),
                //         ),
                //         const PopupMenuItem(
                //           value: '580keylog',
                //           child: Row(
                //             children: [
                //               Icon(Icons.calculate, color: Colors.deepPurple),
                //               SizedBox(width: 8),
                //               Text("Casio fx-580 Keylog"),
                //             ],
                //           ),
                //         ),
                //         const PopupMenuItem(
                //           value: '880keylog',
                //           child: Row(
                //             children: [
                //               Icon(Icons.calculate_outlined, color: Colors.indigo),
                //               SizedBox(width: 8),
                //               Text("Casio fx-880 Keylog"),
                //             ],
                //           ),
                //         ),
                //       ],
                //       child: Container(
                //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                //         decoration: BoxDecoration(
                //           color: Colors.blue.withOpacity(0.1),
                //           borderRadius: BorderRadius.circular(20),
                //           border: Border.all(color: Colors.blue),
                //         ),
                //         child: const Row(
                //           children: [
                //             Icon(Icons.add, color: Colors.blue, size: 20),
                //             SizedBox(width: 4),
                //             Text(
                //               "Thêm khối",
                //               style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                const SizedBox(height: 10),

                if (_blocks.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        "Chưa có nội dung. Hãy thêm khối mới.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),

                ..._blocks.asMap().entries.map((entry) {
                  int idx = entry.key;
                  ContentBlock block = entry.value;
                  return _buildBlockItem(idx, block);
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16));
  }

  // Helper chọn màu sắc tiêu đề khối
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

  // Helper hiển thị tên khối
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

  // Helper chọn Icon
  IconData _getBlockIcon(String type) {
    switch (type) {
      case 'text':
        return Icons.notes;
      case 'latex':
        return Icons.functions;
      case 'image':
        return Icons.image;
      case '580keylog':
        return Icons.calculate;
      case '880keylog':
        return Icons.calculate_outlined;

      default:
        return Icons.block;
    }
  }

  Widget _buildBlockItem(int index, ContentBlock block) {
    final Color colorTheme = _getBlockColor(block.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER KHỐI ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorTheme.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: colorTheme.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getBlockIcon(block.type),
                        size: 16,
                        color: colorTheme,
                      ),
                      const SizedBox(width: 4),
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
                  icon: const Icon(Icons.close, color: Colors.red, size: 20),
                  onPressed: () => _removeBlock(index),
                  tooltip: "Xóa khối này",
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // --- NỘI DUNG TÙY THEO LOẠI ---

            // 1. VĂN BẢN
            if (block.type == 'text')
              TextField(
                controller: TextEditingController(text: block.data)
                  ..selection = TextSelection.collapsed(offset: block.data?.length ?? 0),
                onChanged: (v) => _blocks[index] = block.copyWith(data: v),
                maxLines: null,
                minLines: 2,
                decoration: const InputDecoration(
                  hintText: "Nhập văn bản thông thường...",
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),

            // 2. LATEX
            if (block.type == 'latex')
              TextField(
                controller: TextEditingController(text: block.data)
                  ..selection = TextSelection.collapsed(offset: block.data?.length ?? 0),
                onChanged: (v) => _blocks[index] = block.copyWith(data: v),
                maxLines: null,
                minLines: 1,
                style: const TextStyle(fontFamily: 'Courier', color: Colors.teal), // Font kiểu code
                decoration: const InputDecoration(
                  hintText: "Nhập công thức (VD: x = \\frac{-b \\pm \\sqrt{\\Delta}}{2a})",
                  border: OutlineInputBorder(),
                  prefixText: "\$\$ ", // Gợi ý trực quan
                  suffixText: " \$\$",
                  isDense: true,
                  fillColor: Color(0xFFE0F2F1), // Màu nền nhẹ cho Latex
                  filled: true,
                ),
              ),
            // 4. FX-580 / FX-880 KEYLOG
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
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: "[SHIFT][MENU][1][+][2]",
                      border: const OutlineInputBorder(),
                      isDense: true,
                      fillColor: Colors.black.withOpacity(0.03),
                      filled: true,
                      prefixIcon: const Icon(Icons.keyboard),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Nhập chuỗi phím theo dạng [SHIFT][MENU]...",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),

            // 3. HÌNH ẢNH
            if (block.type == 'image') ...[
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
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
                              errorBuilder: (c, o, s) =>
                                  const Center(child: Icon(Icons.broken_image)),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: ElevatedButton.icon(
                              onPressed: () => _pickAndUploadImage(index),
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text("Đổi ảnh"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                            const SizedBox(height: 8),
                            TextButton(
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
                decoration: const InputDecoration(
                  labelText: "Chú thích ảnh (Caption)",
                  prefixIcon: Icon(Icons.description, size: 18),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
