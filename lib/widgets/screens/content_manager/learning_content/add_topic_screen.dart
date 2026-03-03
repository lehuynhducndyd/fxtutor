import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/widgets/screens/content_manager/learning_content/topic_cubit.dart';

class AddTopicScreen extends StatelessWidget {
  const AddTopicScreen(this.isAddMode, {super.key});

  static const String route = 'AddTopicScreen';
  final bool isAddMode;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Chạm ra ngoài khoảng trống để tự động hạ bàn phím
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text(
            isAddMode ? "Thêm chủ đề mới" : "Sửa chủ đề",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: Body(isAddMode: isAddMode),
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
    // Nếu là chế độ sửa, lấy dữ liệu chủ đề hiện tại điền vào form
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

  // Logic Xử lý Lưu
  void _handleSave() {
    FocusScope.of(context).unfocus(); // Ẩn bàn phím

    final name = _nameController.text.trim();
    final desc = _descController.text.trim();

    // Validate: Không cho phép để trống
    if (name.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Vui lòng điền đầy đủ tên và mô tả chủ đề!"),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Gọi Cubit xử lý
    if (widget.isAddMode) {
      context.read<TopicCubit>().addTopic(name, desc);
    } else {
      context.read<TopicCubit>().updateTopic(name, desc);
    }

    // Đóng màn hình
    Navigator.pop(context);

    // Hiển thị thông báo thành công
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.isAddMode ? "Đã thêm chủ đề mới!" : "Đã cập nhật chủ đề!"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600), // Giới hạn độ rộng tối ưu cho Tablet/Web
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Lời chào / Hướng dẫn
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.primaryContainer),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.isAddMode
                            ? "Tạo một chủ đề học tập lớn để chứa các bài học, công thức hoặc hướng dẫn bấm máy bên trong."
                            : "Chỉnh sửa lại thông tin của chủ đề học tập này.",
                        style: TextStyle(color: colorScheme.onSurfaceVariant, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ================= TÊN CHỦ ĐỀ =================
              Text(
                "Tên chủ đề",
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                decoration: InputDecoration(
                  hintText: "VD: Đạo hàm, Tích phân, Số phức...",
                  prefixIcon: Icon(Icons.title_rounded, color: colorScheme.outline),
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

              // ================= MÔ TẢ CHI TIẾT =================
              Text(
                "Mô tả chi tiết",
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descController,
                maxLines: 4, // Cho phép nhập dài
                minLines: 3,
                decoration: InputDecoration(
                  hintText: "Nhập tóm tắt nội dung mà chủ đề này sẽ đề cập...",
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 40),

              // ================= NÚT LƯU =================
              FilledButton.icon(
                onPressed: _handleSave,
                icon: Icon(
                  widget.isAddMode ? Icons.add_circle_outline_rounded : Icons.save_rounded,
                ),
                label: Text(
                  widget.isAddMode ? "Tạo chủ đề mới" : "Lưu thay đổi",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
